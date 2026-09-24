import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/config/app_config.dart';
import '../../../core/database/user_database.dart';
import '../../../core/storage/storage_capacity.dart';
import '../domain/audio_download_repository.dart';
import '../domain/download_job.dart';

class AudioTransportResponse {
  const AudioTransportResponse({
    required this.statusCode,
    required this.bytes,
    required this.contentLength,
  });

  final int statusCode;
  final Stream<List<int>> bytes;
  final int? contentLength;
}

abstract class AudioDownloadTransport {
  Future<AudioTransportResponse> open(Uri uri, {required int startByte});
  void close();
}

class DartIoAudioDownloadTransport implements AudioDownloadTransport {
  DartIoAudioDownloadTransport({HttpClient? client})
    : _client = client ?? HttpClient();

  final HttpClient _client;

  @override
  Future<AudioTransportResponse> open(Uri uri, {required int startByte}) async {
    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.userAgentHeader, AppConfig.audioUserAgent);
    request.headers.set(
      HttpHeaders.acceptHeader,
      'audio/mpeg,audio/*;q=0.9,*/*;q=0.8',
    );
    if (startByte > 0) {
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=$startByte-');
    }
    final response = await request.close();
    return AudioTransportResponse(
      statusCode: response.statusCode,
      bytes: response,
      contentLength: response.contentLength >= 0
          ? response.contentLength
          : null,
    );
  }

  @override
  void close() => _client.close(force: true);
}

class FileAudioDownloadRepository implements AudioDownloadRepository {
  FileAudioDownloadRepository({
    required UserDatabase database,
    required Future<Directory> Function() rootDirectory,
    required AudioDownloadTransport transport,
    required StorageCapacity storageCapacity,
  }) : _database = database,
       _rootDirectory = rootDirectory,
       _transport = transport,
       _storageCapacity = storageCapacity;

  final UserDatabase _database;
  final Future<Directory> Function() _rootDirectory;
  final AudioDownloadTransport _transport;
  final StorageCapacity _storageCapacity;
  final Map<String, _DownloadControl> _active = {};

  @override
  Future<DownloadJob?> getJob(String audioKey) async {
    final row = await _database.getDownloadJob(audioKey);
    return row == null ? null : _fromRecord(row);
  }

  @override
  Future<List<DownloadJob>> listJobs() async {
    final rows = await _database.listDownloadJobs();
    return rows.map(_fromRecord).toList(growable: false);
  }

  @override
  Future<DownloadJob> enqueue(AudioDownloadRequest request) async {
    _validateRelativePath(request.relativePath);
    await _database.registerAudioSource(
      audioKey: request.audioKey,
      audioType: request.audioType,
      remoteUrl: request.remoteUrl,
      reciterId: request.reciterId,
      surahNumber: request.surahNumber,
      ayahNumber: request.ayahNumber,
      wordPosition: request.wordPosition,
      format: request.format,
      fileSize: request.expectedBytes,
    );

    final existing = await getJob(request.audioKey);
    if (existing != null) {
      final refreshed = DownloadJob(
        audioKey: request.audioKey,
        audioType: request.audioType,
        remoteUrl: request.remoteUrl,
        relativePath: request.relativePath,
        status: existing.status,
        downloadedBytes: existing.downloadedBytes,
        expectedBytes: request.expectedBytes ?? existing.expectedBytes,
        reciterId: request.reciterId ?? existing.reciterId,
        surahNumber: request.surahNumber ?? existing.surahNumber,
        ayahNumber: request.ayahNumber ?? existing.ayahNumber,
        wordPosition: request.wordPosition ?? existing.wordPosition,
        format: request.format ?? existing.format,
        localPath: existing.localPath,
        errorCode: existing.errorCode,
      );
      await _save(refreshed);
      return refreshed;
    }

    final job = DownloadJob.fromRequest(request);
    await _save(job);
    return job;
  }

  @override
  Future<DownloadJob> download(String audioKey) async {
    final existing = await getJob(audioKey);
    if (existing == null) {
      throw StateError('Download job not found: $audioKey');
    }
    if (_active.containsKey(audioKey)) return existing;

    final root = await _rootDirectory();
    final finalFile = File(p.join(root.path, existing.relativePath));
    final partFile = File('${finalFile.path}.part');
    await finalFile.parent.create(recursive: true);

    if (await _validFinalFile(finalFile, existing)) {
      final size = await finalFile.length();
      final completed = existing.copyWith(
        status: DownloadJobStatus.completed,
        downloadedBytes: size,
        localPath: finalFile.path,
        errorCode: null,
      );
      await _markCompleted(completed, finalFile.path, size);
      return completed;
    }

    var startByte = await partFile.exists() ? await partFile.length() : 0;
    if (existing.expectedBytes != null && startByte > existing.expectedBytes!) {
      await partFile.delete();
      startByte = 0;
    }

    final freeBytes = await _storageCapacity.freeBytesFor(
      finalFile.parent.path,
    );

    final control = _DownloadControl();
    _active[audioKey] = control;
    var downloading = existing.copyWith(
      status: DownloadJobStatus.downloading,
      downloadedBytes: startByte,
      errorCode: null,
    );
    await _save(downloading);

    IOSink? sink;
    try {
      var response = await _transport.open(
        Uri.parse(existing.remoteUrl),
        startByte: startByte,
      );

      if (startByte > 0 &&
          response.statusCode == HttpStatus.requestedRangeNotSatisfiable) {
        await response.bytes.drain<void>();
        if (await partFile.exists()) await partFile.delete();
        startByte = 0;
        downloading = downloading.copyWith(downloadedBytes: 0);
        await _save(downloading);
        response = await _transport.open(
          Uri.parse(existing.remoteUrl),
          startByte: 0,
        );
      }

      var append = startByte > 0;
      if (startByte > 0 && response.statusCode == HttpStatus.ok) {
        startByte = 0;
        append = false;
      } else {
        final expectedStatus = startByte > 0
            ? HttpStatus.partialContent
            : HttpStatus.ok;
        if (response.statusCode != expectedStatus) {
          return await _fail(
            existing,
            DownloadErrorCode.httpFailure,
            startByte,
          );
        }
      }

      final bytesToWrite = response.contentLength;
      if (freeBytes != null &&
          bytesToWrite != null &&
          freeBytes < bytesToWrite) {
        return await _fail(
          existing,
          DownloadErrorCode.insufficientStorage,
          startByte,
        );
      }

      sink = partFile.openWrite(
        mode: append ? FileMode.append : FileMode.write,
      );

      var received = startByte;
      var lastReported = startByte;
      Future<void> progressWrite = Future.value();
      final streamDone = Completer<void>();
      Object? streamError;
      StackTrace? streamStackTrace;
      final subscription = response.bytes.listen(
        (chunk) {
          if (control.paused || control.cancelled) return;
          sink!.add(chunk);
          received += chunk.length;
          if (received - lastReported >= 64 * 1024) {
            lastReported = received;
            final bytes = received;
            progressWrite = progressWrite.then(
              (_) => _save(downloading.copyWith(downloadedBytes: bytes)),
            );
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          streamError = error;
          streamStackTrace = stackTrace;
          if (!streamDone.isCompleted) streamDone.complete();
        },
        onDone: () {
          if (!streamDone.isCompleted) streamDone.complete();
        },
        cancelOnError: true,
      );
      control.subscription = subscription;

      await Future.any([streamDone.future, control.interrupted.future]);
      await progressWrite;
      if (!streamDone.isCompleted) {
        await subscription.cancel();
      }

      if (control.cancelled) {
        await sink.flush();
        await sink.close();
        sink = null;
        if (await partFile.exists()) await partFile.delete();
        final cancelled = downloading.copyWith(
          status: DownloadJobStatus.cancelled,
          downloadedBytes: 0,
          errorCode: null,
        );
        await _save(cancelled);
        return cancelled;
      }

      if (control.paused) {
        await sink.flush();
        await sink.close();
        sink = null;
        final paused = downloading.copyWith(
          status: DownloadJobStatus.paused,
          downloadedBytes: received,
          errorCode: null,
        );
        await _save(paused);
        return paused;
      }

      if (streamError != null) {
        Error.throwWithStackTrace(
          streamError!,
          streamStackTrace ?? StackTrace.current,
        );
      }

      await sink.flush();
      await sink.close();
      sink = null;

      final responseTotalBytes = response.contentLength == null
          ? null
          : startByte + response.contentLength!;
      if (received <= 0 ||
          (responseTotalBytes != null && received != responseTotalBytes)) {
        return await _fail(existing, DownloadErrorCode.sizeMismatch, received);
      }

      if (await finalFile.exists()) await finalFile.delete();
      await partFile.rename(finalFile.path);

      final completed = downloading.copyWith(
        status: DownloadJobStatus.completed,
        downloadedBytes: received,
        localPath: finalFile.path,
        errorCode: null,
      );
      await _markCompleted(completed, finalFile.path, received);
      return completed;
    } catch (_) {
      if (sink != null) {
        await sink.flush();
        await sink.close();
        sink = null;
      }
      final bytes = await partFile.exists()
          ? await partFile.length()
          : startByte;
      return _fail(existing, DownloadErrorCode.ioFailure, bytes);
    } finally {
      if (sink != null) {
        await sink.flush();
        await sink.close();
      }
      _active.remove(audioKey);
      control.markSettled();
    }
  }

  @override
  Future<void> pause(String audioKey) async {
    final control = _active[audioKey];
    if (control != null) {
      control.paused = true;
      control.interrupt();
      await control.settled.future;
      return;
    }
    final job = await getJob(audioKey);
    if (job == null || job.status == DownloadJobStatus.completed) return;
    await _save(job.copyWith(status: DownloadJobStatus.paused));
  }

  @override
  Future<DownloadJob> resume(String audioKey) async {
    final job = await getJob(audioKey);
    if (job == null) throw StateError('Download job not found: $audioKey');
    if (job.status == DownloadJobStatus.completed) return job;
    await _save(
      job.copyWith(status: DownloadJobStatus.queued, errorCode: null),
    );
    return download(audioKey);
  }

  @override
  Future<DownloadJob> retry(String audioKey) => resume(audioKey);

  @override
  Future<void> cancel(String audioKey) async {
    final control = _active[audioKey];
    if (control != null) {
      control.cancelled = true;
      control.interrupt();
      await control.settled.future;
      return;
    }
    final job = await getJob(audioKey);
    if (job == null) return;
    final root = await _rootDirectory();
    final part = File('${p.join(root.path, job.relativePath)}.part');
    if (await part.exists()) await part.delete();
    await _save(
      job.copyWith(
        status: DownloadJobStatus.cancelled,
        downloadedBytes: 0,
        errorCode: null,
      ),
    );
  }

  @override
  Future<void> delete(String audioKey) async {
    await cancel(audioKey);
    final job = await getJob(audioKey);
    if (job != null) {
      final root = await _rootDirectory();
      final finalFile = File(p.join(root.path, job.relativePath));
      final partFile = File('${finalFile.path}.part');
      if (await finalFile.exists()) await finalFile.delete();
      if (await partFile.exists()) await partFile.delete();
    }
    await _database.deleteAudio(audioKey);
    await _database.deleteDownloadJob(audioKey);
  }

  Future<DownloadJob> _fail(
    DownloadJob source,
    DownloadErrorCode error,
    int downloadedBytes,
  ) async {
    final failed = source.copyWith(
      status: DownloadJobStatus.failed,
      downloadedBytes: downloadedBytes,
      errorCode: error.name,
    );
    await _save(failed);
    return failed;
  }

  Future<void> _markCompleted(
    DownloadJob job,
    String localPath,
    int bytes,
  ) async {
    await _database.markAudioDownloaded(
      audioKey: job.audioKey,
      localPath: localPath,
      bytes: bytes,
    );
    await _save(job);
  }

  Future<void> _save(DownloadJob job) {
    return _database.upsertDownloadJob(
      audioKey: job.audioKey,
      audioType: job.audioType,
      remoteUrl: job.remoteUrl,
      relativePath: job.relativePath,
      status: job.status.name,
      downloadedBytes: job.downloadedBytes,
      expectedBytes: job.expectedBytes,
      reciterId: job.reciterId,
      surahNumber: job.surahNumber,
      ayahNumber: job.ayahNumber,
      wordPosition: job.wordPosition,
      format: job.format,
      localPath: job.localPath,
      errorCode: job.errorCode,
    );
  }

  DownloadJob _fromRecord(DownloadJobRecord row) {
    return DownloadJob(
      audioKey: row.audioKey,
      audioType: row.audioType,
      remoteUrl: row.remoteUrl,
      relativePath: row.relativePath,
      status: DownloadJobStatus.values.byName(row.status),
      downloadedBytes: row.downloadedBytes,
      expectedBytes: row.expectedBytes,
      reciterId: row.reciterId,
      surahNumber: row.surahNumber,
      ayahNumber: row.ayahNumber,
      wordPosition: row.wordPosition,
      format: row.format,
      localPath: row.localPath,
      errorCode: row.errorCode,
    );
  }

  void _validateRelativePath(String relativePath) {
    final normalized = p.normalize(relativePath);
    if (p.isAbsolute(relativePath) ||
        normalized == '..' ||
        normalized.startsWith('../')) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'must stay inside the Quran audio directory',
      );
    }
  }

  Future<bool> _validFinalFile(File file, DownloadJob job) async {
    if (!await file.exists()) return false;
    final length = await file.length();
    if (length <= 0) return false;
    if (job.status == DownloadJobStatus.completed &&
        job.downloadedBytes > 0 &&
        length == job.downloadedBytes) {
      return true;
    }
    return job.expectedBytes == null || length == job.expectedBytes;
  }
}

class _DownloadControl {
  bool paused = false;
  bool cancelled = false;
  StreamSubscription<List<int>>? subscription;
  final Completer<void> interrupted = Completer<void>();
  final Completer<void> settled = Completer<void>();

  void interrupt() {
    if (!interrupted.isCompleted) interrupted.complete();
  }

  void markSettled() {
    if (!settled.isCompleted) settled.complete();
  }
}
