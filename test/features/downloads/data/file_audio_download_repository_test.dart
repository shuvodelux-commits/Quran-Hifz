import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/config/app_config.dart';
import 'package:quran_hifz/core/audio/offline_audio_resolver.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/core/storage/storage_capacity.dart';
import 'package:quran_hifz/features/downloads/data/file_audio_download_repository.dart';
import 'package:quran_hifz/features/downloads/domain/download_job.dart';

void main() {
  late Directory temp;
  late UserDatabase database;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('quran-audio-download-test-');
    database = UserDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  FileAudioDownloadRepository _repository({
    required FakeDownloadTransport transport,
    int freeBytes = 1024 * 1024,
  }) {
    return FileAudioDownloadRepository(
      database: database,
      rootDirectory: () async => temp,
      transport: transport,
      storageCapacity: FakeStorageCapacity(freeBytes),
    );
  }

  test(
    'active download reports persisted byte progress before completion',
    () async {
      final listened = Completer<void>();
      final stream = StreamController<List<int>>(onListen: listened.complete);
      final transport = FakeDownloadTransport.responses([
        FakeTransportResponse._(
          AudioTransportResponse(
            statusCode: HttpStatus.ok,
            contentLength: 140000,
            bytes: stream.stream,
          ),
        ),
      ]);
      final repository = _repository(transport: transport);
      final request = _request(expectedBytes: 140000);
      await repository.enqueue(request);
      final running = repository.download(request.audioKey);
      await listened.future;
      stream.add(List.filled(70000, 1));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(
        (await repository.getJob(request.audioKey))?.downloadedBytes,
        70000,
      );
      await repository.cancel(request.audioKey);
      await stream.close();
      await running;
    },
  );

  test('dart io transport identifies Quran audio requests', () async {
    final observed = Completer<Map<String, String?>>();
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final subscription = server.listen((request) async {
      if (!observed.isCompleted) {
        observed.complete({
          'userAgent': request.headers.value(HttpHeaders.userAgentHeader),
          'accept': request.headers.value(HttpHeaders.acceptHeader),
        });
      }
      request.response.statusCode = HttpStatus.ok;
      request.response.add([1]);
      await request.response.close();
    });
    final transport = DartIoAudioDownloadTransport();

    try {
      final response = await transport.open(
        Uri.parse('http://${server.address.address}:${server.port}/001.mp3'),
        startByte: 0,
      );
      await response.bytes.drain<void>();
      final headers = await observed.future;

      expect(headers['userAgent'], AppConfig.audioUserAgent);
      expect(headers['accept'], contains('audio/mpeg'));
    } finally {
      transport.close();
      await subscription.cancel();
      await server.close(force: true);
    }
  });

  test('server content length wins over stale metadata file size', () async {
    final transport = FakeDownloadTransport.responses([
      FakeTransportResponse.ok([
        [1, 2, 3],
        [4, 5],
      ]),
    ]);
    final repository = _repository(transport: transport);
    final request = _request(expectedBytes: 6);

    await repository.enqueue(request);
    final result = await repository.download(request.audioKey);

    expect(result.status, DownloadJobStatus.completed);
    expect(result.downloadedBytes, 5);
    expect(result.expectedBytes, 6);
    expect(transport.starts, [0]);
    expect(await File('${temp.path}/${request.relativePath}').readAsBytes(), [
      1,
      2,
      3,
      4,
      5,
    ]);
  });

  test('416 from stale complete part restarts once from byte zero', () async {
    final part = File('${temp.path}/reciters/7/001.mp3.part');
    await part.parent.create(recursive: true);
    await part.writeAsBytes([1, 2, 3, 4, 5]);
    final transport = FakeDownloadTransport.responses([
      FakeTransportResponse.rangeNotSatisfiable(),
      FakeTransportResponse.ok([
        [1, 2, 3, 4, 5],
      ]),
    ]);
    final repository = _repository(transport: transport);
    final request = _request(expectedBytes: 6);
    await repository.enqueue(request);

    final result = await repository.download(request.audioKey);

    expect(result.status, DownloadJobStatus.completed);
    expect(result.downloadedBytes, 5);
    expect(transport.starts, [5, 0]);
    expect(await File('${temp.path}/${request.relativePath}').readAsBytes(), [
      1,
      2,
      3,
      4,
      5,
    ]);
  });

  test('completed file stays valid when metadata size is stale', () async {
    final transport = FakeDownloadTransport.responses([
      FakeTransportResponse.ok([
        [1, 2, 3, 4, 5],
      ]),
    ]);
    final repository = _repository(transport: transport);
    final request = _request(expectedBytes: 6);
    await repository.enqueue(request);

    final first = await repository.download(request.audioKey);
    final second = await repository.download(request.audioKey);

    expect(first.status, DownloadJobStatus.completed);
    expect(second.status, DownloadJobStatus.completed);
    expect(second.downloadedBytes, 5);
    expect(transport.starts, [0]);
  });

  test('successful download promotes .part atomically to final file', () async {
    final transport = FakeDownloadTransport.responses([
      FakeTransportResponse.ok([
        [1, 2, 3],
        [4, 5],
      ]),
    ]);
    final repository = _repository(transport: transport);
    final request = _request(expectedBytes: 5);

    await repository.enqueue(request);
    final result = await repository.download(request.audioKey);

    final finalFile = File('${temp.path}/${request.relativePath}');
    final partFile = File('${finalFile.path}.part');
    expect(result.status, DownloadJobStatus.completed);
    expect(await finalFile.readAsBytes(), [1, 2, 3, 4, 5]);
    expect(await partFile.exists(), isFalse);
    expect(transport.starts, [0]);
  });

  test(
    'failed download keeps resumable .part but resolver never exposes it',
    () async {
      final transport = FakeDownloadTransport.responses([
        FakeTransportResponse.failingAfter([1, 2, 3]),
      ]);
      final repository = _repository(transport: transport);
      final request = _request(expectedBytes: 6);
      await repository.enqueue(request);

      final result = await repository.download(request.audioKey);

      final finalFile = File('${temp.path}/${request.relativePath}');
      final partFile = File('${finalFile.path}.part');
      expect(result.status, DownloadJobStatus.failed);
      expect(await finalFile.exists(), isFalse);
      expect(await partFile.exists(), isTrue);

      final resolver = OfflineAudioResolver(database);
      expect(await resolver.resolve(request.audioKey), request.remoteUrl);
    },
  );

  test('retry resumes from existing .part byte count', () async {
    final transport = FakeDownloadTransport.responses([
      FakeTransportResponse.failingAfter([1, 2, 3]),
      FakeTransportResponse.partial([
        [4, 5, 6],
      ]),
    ]);
    final repository = _repository(transport: transport);
    final request = _request(expectedBytes: 6);
    await repository.enqueue(request);

    final failed = await repository.download(request.audioKey);
    expect(failed.status, DownloadJobStatus.failed);

    final completed = await repository.retry(request.audioKey);
    expect(completed.status, DownloadJobStatus.completed);
    expect(transport.starts, [0, 3]);
    expect(await File('${temp.path}/${request.relativePath}').readAsBytes(), [
      1,
      2,
      3,
      4,
      5,
      6,
    ]);
  });

  test(
    'pause preserves partial bytes and resume continues with Range',
    () async {
      final firstStreamListened = Completer<void>();
      final firstStream = StreamController<List<int>>(
        onListen: () => firstStreamListened.complete(),
      );
      final transport = FakeDownloadTransport.responses([
        FakeTransportResponse._(
          AudioTransportResponse(
            statusCode: HttpStatus.ok,
            contentLength: 6,
            bytes: firstStream.stream,
          ),
        ),
        FakeTransportResponse.partial([
          [4, 5, 6],
        ]),
      ]);
      final repository = _repository(transport: transport);
      final request = _request(expectedBytes: 6);
      await repository.enqueue(request);

      final running = repository.download(request.audioKey);
      await firstStreamListened.future;
      firstStream.add([1, 2, 3]);
      await Future<void>.delayed(Duration.zero);
      await repository.pause(request.audioKey);
      firstStream.add([9]);
      await firstStream.close();

      final paused = await running;
      expect(paused.status, DownloadJobStatus.paused);
      expect(paused.downloadedBytes, 3);

      final completed = await repository.resume(request.audioKey);
      expect(completed.status, DownloadJobStatus.completed);
      expect(transport.starts, [0, 3]);
      expect(await File('${temp.path}/${request.relativePath}').readAsBytes(), [
        1,
        2,
        3,
        4,
        5,
        6,
      ]);
    },
  );

  test(
    'insufficient storage rejects after reading authoritative response size',
    () async {
      final transport = FakeDownloadTransport.responses([
        FakeTransportResponse.ok([
          [1, 2, 3, 4, 5],
        ]),
      ]);
      final repository = _repository(transport: transport, freeBytes: 4);
      final request = _request(expectedBytes: 5);
      await repository.enqueue(request);

      final result = await repository.download(request.audioKey);

      expect(result.status, DownloadJobStatus.failed);
      expect(result.errorCode, DownloadErrorCode.insufficientStorage.name);
      expect(transport.starts, [0]);
    },
  );

  test('delete removes final file and audio metadata', () async {
    final transport = FakeDownloadTransport.responses([
      FakeTransportResponse.ok([
        [1, 2, 3],
      ]),
    ]);
    final repository = _repository(transport: transport);
    final request = _request(expectedBytes: 3);
    await repository.enqueue(request);
    await repository.download(request.audioKey);

    await repository.delete(request.audioKey);

    expect(
      await File('${temp.path}/${request.relativePath}').exists(),
      isFalse,
    );
    expect(await database.getAudio(request.audioKey), isNull);
    expect(await repository.getJob(request.audioKey), isNull);
  });

  test('source refresh preserves an existing valid local path', () async {
    final local = File('${temp.path}/existing.mp3');
    await local.writeAsBytes([1, 2, 3]);
    await database.upsertAudioFile(
      audioKey: 'chapter:7:1',
      audioType: 'chapter',
      remoteUrl: 'https://old.example/001.mp3',
      localPath: local.path,
      downloadedBytes: 3,
      status: 'downloaded',
    );
    final repository = _repository(
      transport: FakeDownloadTransport.responses(const []),
    );

    await repository.enqueue(
      AudioDownloadRequest(
        audioKey: 'chapter:7:1',
        audioType: 'chapter',
        remoteUrl: 'https://new.example/001.mp3',
        relativePath: 'reciters/7/001.mp3',
      ),
    );

    final audio = await database.getAudio('chapter:7:1');
    expect(audio?.remoteUrl, 'https://new.example/001.mp3');
    expect(audio?.localPath, local.path);
    expect(audio?.status, 'downloaded');
  });

  test('Range fallback to full response rechecks full-file storage', () async {
    final part = File('${temp.path}/reciters/7/001.mp3.part');
    await part.parent.create(recursive: true);
    await part.writeAsBytes([1, 2, 3]);
    final transport = FakeDownloadTransport.responses([
      FakeTransportResponse.ok([
        [1, 2, 3, 4, 5, 6],
      ]),
    ]);
    final repository = _repository(transport: transport, freeBytes: 4);
    final request = _request(expectedBytes: 6);
    await repository.enqueue(request);

    final result = await repository.download(request.audioKey);

    expect(result.status, DownloadJobStatus.failed);
    expect(result.errorCode, DownloadErrorCode.insufficientStorage.name);
    expect(transport.starts, [3]);
    expect(await part.readAsBytes(), [1, 2, 3]);
  });

  test(
    'unknown-size download uses response length for storage refusal',
    () async {
      final transport = FakeDownloadTransport.responses([
        FakeTransportResponse.ok([
          [1, 2, 3, 4, 5],
        ]),
      ]);
      final repository = _repository(transport: transport, freeBytes: 4);
      final request = AudioDownloadRequest(
        audioKey: 'word:1:1:1',
        audioType: 'word',
        remoteUrl: 'https://example.test/w.mp3',
        relativePath: 'words/001/001/001.mp3',
      );
      await repository.enqueue(request);

      final result = await repository.download(request.audioKey);

      expect(result.status, DownloadJobStatus.failed);
      expect(result.errorCode, DownloadErrorCode.insufficientStorage.name);
      expect(
        await File('${temp.path}/${request.relativePath}.part').exists(),
        isFalse,
      );
    },
  );

  test('enqueue rejects a path that escapes the audio directory', () async {
    final repository = _repository(
      transport: FakeDownloadTransport.responses(const []),
    );

    expect(
      () => repository.enqueue(
        const AudioDownloadRequest(
          audioKey: 'bad',
          audioType: 'word',
          remoteUrl: 'https://example.test/bad.mp3',
          relativePath: '../outside.mp3',
        ),
      ),
      throwsArgumentError,
    );
  });

  test(
    'resolver ignores a zero-byte final file and falls back to remote',
    () async {
      final zero = File('${temp.path}/zero.mp3');
      await zero.create();
      await database.upsertAudioFile(
        audioKey: 'word:1:1:1',
        audioType: 'word',
        remoteUrl: 'https://example.test/w.mp3',
        localPath: zero.path,
        status: 'downloaded',
      );

      final resolver = OfflineAudioResolver(database);
      expect(
        await resolver.resolve('word:1:1:1'),
        'https://example.test/w.mp3',
      );
    },
  );

  test('duplicate enqueue reuses one persisted job', () async {
    final repository = _repository(
      transport: FakeDownloadTransport.responses(const []),
    );
    final request = _request(expectedBytes: 3);

    final first = await repository.enqueue(request);
    final second = await repository.enqueue(request);

    expect(second.audioKey, first.audioKey);
    expect((await repository.listJobs()).length, 1);
  });
}

AudioDownloadRequest _request({required int expectedBytes}) {
  return AudioDownloadRequest(
    audioKey: 'chapter:7:1',
    audioType: 'chapter',
    remoteUrl: 'https://example.test/001.mp3',
    relativePath: 'reciters/7/001.mp3',
    expectedBytes: expectedBytes,
    reciterId: 7,
    surahNumber: 1,
    format: 'mp3',
  );
}

class FakeStorageCapacity implements StorageCapacity {
  FakeStorageCapacity(this.bytes);

  final int bytes;

  @override
  Future<int?> freeBytesFor(String path) async => bytes;
}

class FakeDownloadTransport implements AudioDownloadTransport {
  FakeDownloadTransport.responses(this._responses);

  final List<FakeTransportResponse> _responses;
  final List<int> starts = [];
  var _index = 0;

  @override
  Future<AudioTransportResponse> open(Uri uri, {required int startByte}) async {
    starts.add(startByte);
    return _responses[_index++].response;
  }

  @override
  void close() {}
}

class FakeTransportResponse {
  FakeTransportResponse._(this.response);

  final AudioTransportResponse response;

  factory FakeTransportResponse.ok(List<List<int>> chunks) {
    return FakeTransportResponse._(
      AudioTransportResponse(
        statusCode: HttpStatus.ok,
        contentLength: chunks.fold<int>(0, (sum, chunk) => sum + chunk.length),
        bytes: Stream.fromIterable(chunks),
      ),
    );
  }

  factory FakeTransportResponse.rangeNotSatisfiable() {
    return FakeTransportResponse._(
      AudioTransportResponse(
        statusCode: HttpStatus.requestedRangeNotSatisfiable,
        contentLength: 0,
        bytes: Stream.empty(),
      ),
    );
  }

  factory FakeTransportResponse.partial(List<List<int>> chunks) {
    return FakeTransportResponse._(
      AudioTransportResponse(
        statusCode: HttpStatus.partialContent,
        contentLength: chunks.fold<int>(0, (sum, chunk) => sum + chunk.length),
        bytes: Stream.fromIterable(chunks),
      ),
    );
  }

  factory FakeTransportResponse.failingAfter(List<int> prefix) {
    final controller = StreamController<List<int>>();
    scheduleMicrotask(() {
      controller.add(prefix);
      controller.addError(SocketException('connection lost'));
      controller.close();
    });
    return FakeTransportResponse._(
      AudioTransportResponse(
        statusCode: HttpStatus.ok,
        contentLength: null,
        bytes: controller.stream,
      ),
    );
  }
}
