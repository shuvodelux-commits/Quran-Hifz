import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/storage/disk_capacity_storage.dart';
import '../data/file_audio_download_repository.dart';

import '../domain/audio_download_repository.dart';
import '../domain/download_job.dart';

final audioDownloadRepositoryProvider = Provider<AudioDownloadRepository>((
  ref,
) {
  final transport = DartIoAudioDownloadTransport();
  ref.onDispose(transport.close);
  return FileAudioDownloadRepository(
    database: ref.watch(userDatabaseProvider),
    rootDirectory: () async {
      final appSupport = await getApplicationSupportDirectory();
      final directory = Directory(p.join(appSupport.path, 'quran_audio'));
      await directory.create(recursive: true);
      return directory;
    },
    transport: transport,
    storageCapacity: DiskCapacityStorage(),
  );
});

final downloadControllerProvider =
    NotifierProvider<DownloadController, Map<String, DownloadJob>>(
      DownloadController.new,
    );

class DownloadController extends Notifier<Map<String, DownloadJob>> {
  AudioDownloadRepository get _repository =>
      ref.read(audioDownloadRepositoryProvider);

  @override
  Map<String, DownloadJob> build() => const {};

  Future<void> refresh() async {
    final jobs = await _repository.listJobs();
    state = {for (final job in jobs) job.audioKey: job};
  }

  Future<void> enqueue(AudioDownloadRequest request) async {
    if (state.containsKey(request.audioKey)) return;
    final existing = await _repository.getJob(request.audioKey);
    if (existing != null) {
      state = {...state, existing.audioKey: existing};
      return;
    }
    final job = await _repository.enqueue(request);
    state = {...state, job.audioKey: job};
  }

  Future<DownloadJob> start(String audioKey) =>
      _run(audioKey, _repository.download);

  Future<void> pause(String audioKey) async {
    await _repository.pause(audioKey);
    await _refreshOne(audioKey);
  }

  Future<DownloadJob> resume(String audioKey) =>
      _run(audioKey, _repository.resume);

  Future<DownloadJob> retry(String audioKey) =>
      _run(audioKey, _repository.retry);

  Future<void> cancel(String audioKey) async {
    await _repository.cancel(audioKey);
    await _refreshOne(audioKey);
  }

  Future<void> delete(String audioKey) async {
    await _repository.delete(audioKey);
    final next = Map<String, DownloadJob>.of(state)..remove(audioKey);
    state = next;
  }

  Future<DownloadJob> _run(
    String audioKey,
    Future<DownloadJob> Function(String audioKey) operation,
  ) async {
    final result = await operation(audioKey);
    state = {...state, audioKey: result};
    return result;
  }

  Future<void> _refreshOne(String audioKey) async {
    final job = await _repository.getJob(audioKey);
    final next = Map<String, DownloadJob>.of(state);
    if (job == null) {
      next.remove(audioKey);
    } else {
      next[audioKey] = job;
    }
    state = next;
  }
}
