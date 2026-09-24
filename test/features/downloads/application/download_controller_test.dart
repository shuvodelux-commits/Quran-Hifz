import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/downloads/application/download_controller.dart';
import 'package:quran_hifz/features/downloads/domain/audio_download_repository.dart';
import 'package:quran_hifz/features/downloads/domain/download_job.dart';

void main() {
  test('queue ignores duplicate active audio keys', () async {
    final repository = FakeAudioDownloadRepository();
    final container = ProviderContainer(
      overrides: [
        audioDownloadRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(downloadControllerProvider.notifier);
    final request = _request('chapter:7:1');

    await controller.enqueue(request);
    await controller.enqueue(request);

    expect(repository.enqueued, ['chapter:7:1']);
  });

  test(
    'pause, resume, retry, cancel and delete delegate by audio key',
    () async {
      final repository = FakeAudioDownloadRepository();
      final container = ProviderContainer(
        overrides: [
          audioDownloadRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(downloadControllerProvider.notifier);

      await controller.pause('chapter:7:1');
      await controller.resume('chapter:7:1');
      await controller.retry('chapter:7:1');
      await controller.cancel('chapter:7:1');
      await controller.delete('chapter:7:1');

      expect(repository.operations, [
        'pause:chapter:7:1',
        'resume:chapter:7:1',
        'retry:chapter:7:1',
        'cancel:chapter:7:1',
        'delete:chapter:7:1',
      ]);
    },
  );
}

AudioDownloadRequest _request(String key) => AudioDownloadRequest(
  audioKey: key,
  audioType: 'chapter',
  remoteUrl: 'https://example.test/001.mp3',
  relativePath: 'reciters/7/001.mp3',
);

class FakeAudioDownloadRepository implements AudioDownloadRepository {
  final List<String> enqueued = [];
  final List<String> operations = [];
  final Map<String, DownloadJob> jobs = {};

  @override
  Future<DownloadJob> enqueue(AudioDownloadRequest request) async {
    final existing = jobs[request.audioKey];
    if (existing != null) return existing;
    enqueued.add(request.audioKey);
    final job = DownloadJob.fromRequest(request);
    jobs[request.audioKey] = job;
    return job;
  }

  @override
  Future<void> cancel(String audioKey) async =>
      operations.add('cancel:$audioKey');

  @override
  Future<void> delete(String audioKey) async =>
      operations.add('delete:$audioKey');

  @override
  Future<DownloadJob> download(String audioKey) async => jobs[audioKey]!;

  @override
  Future<DownloadJob?> getJob(String audioKey) async => jobs[audioKey];

  @override
  Future<List<DownloadJob>> listJobs() async => jobs.values.toList();

  @override
  Future<void> pause(String audioKey) async =>
      operations.add('pause:$audioKey');

  @override
  Future<DownloadJob> resume(String audioKey) async {
    operations.add('resume:$audioKey');
    return jobs[audioKey] ?? DownloadJob.fromRequest(_request(audioKey));
  }

  @override
  Future<DownloadJob> retry(String audioKey) async {
    operations.add('retry:$audioKey');
    return jobs[audioKey] ?? DownloadJob.fromRequest(_request(audioKey));
  }
}
