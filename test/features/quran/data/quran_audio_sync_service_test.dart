import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/downloads/domain/audio_download_repository.dart';
import 'package:quran_hifz/features/downloads/domain/download_job.dart';
import 'package:quran_hifz/features/quran/data/quran_audio_sync_service.dart';
import 'package:quran_hifz/features/reciters/domain/chapter_audio_source.dart';

void main() {
  test(
    'syncs bundled chapter metadata and downloads without a backend client',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final source = _FakeChapterAudioSource();
      final downloads = _FakeAudioDownloadRepository();
      final service = QuranAudioSyncService(
        chapterAudioSource: source,
        database: database,
        downloads: downloads,
      );

      final result = await service.syncChapter(
        reciterId: 7,
        surahNumber: 67,
        downloadAudio: true,
      );

      expect(source.calls, [(7, 67)]);
      expect(result.localPath, '/offline/7/067.mp3');
      expect(result.ayahTimingCount, 1);

      final audio = await database.getAudio('chapter:7:67');
      expect(audio, isNotNull);
      expect(
        audio!.remoteUrl,
        'https://download.quranicaudio.com/test/7/67.mp3',
      );
      expect(audio.reciterId, 7);
      expect(audio.surahNumber, 67);

      final ayahTiming = await database.getAyahTiming(
        reciterId: 7,
        surahNumber: 67,
        ayahNumber: 1,
      );
      expect(ayahTiming?.startMs, 0);
      expect(ayahTiming?.endMs, 1000);
      final wordTimings = await database.getWordTimings(
        reciterId: 7,
        surahNumber: 67,
        ayahNumber: 1,
      );
      expect(wordTimings.single.wordPosition, 1);

      expect(downloads.enqueued, hasLength(1));
      final request = downloads.enqueued.single;
      expect(request.audioKey, 'chapter:7:67');
      expect(request.relativePath, 'reciters/7/067.mp3');
      expect(request.remoteUrl, result.remoteUrl);
    },
  );

  test(
    'surfaces the download failure instead of returning a null local path',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final source = _FakeChapterAudioSource();
      final downloads = _FailingAudioDownloadRepository(
        errorCode: DownloadErrorCode.sizeMismatch.name,
      );
      final service = QuranAudioSyncService(
        chapterAudioSource: source,
        database: database,
        downloads: downloads,
      );

      await expectLater(
        service.syncChapter(reciterId: 7, surahNumber: 67, downloadAudio: true),
        throwsA(
          isA<ChapterAudioDownloadException>()
              .having(
                (error) => error.status,
                'status',
                DownloadJobStatus.failed,
              )
              .having(
                (error) => error.errorCode,
                'errorCode',
                DownloadErrorCode.sizeMismatch.name,
              ),
        ),
      );
    },
  );
}

class _FakeChapterAudioSource implements ChapterAudioSource {
  final calls = <(int, int)>[];

  @override
  Future<Map<String, dynamic>> loadChapterAudio({
    required int reciterId,
    required int surahNumber,
  }) async {
    calls.add((reciterId, surahNumber));
    return {
      'audio_file': {
        'id': 1,
        'chapter_id': surahNumber,
        'file_size': 5000,
        'format': 'mp3',
        'audio_url':
            'https://download.quranicaudio.com/test/$reciterId/$surahNumber.mp3',
        'timestamps': [
          {
            'verse_key': '$surahNumber:1',
            'timestamp_from': 0,
            'timestamp_to': 1000,
            'duration': 1000,
            'segments': [
              [1, 0, 400],
            ],
          },
        ],
      },
    };
  }
}

class _FakeAudioDownloadRepository implements AudioDownloadRepository {
  final enqueued = <AudioDownloadRequest>[];
  final _requests = <String, AudioDownloadRequest>{};

  @override
  Future<DownloadJob> enqueue(AudioDownloadRequest request) async {
    enqueued.add(request);
    _requests[request.audioKey] = request;
    return DownloadJob.fromRequest(request);
  }

  @override
  Future<DownloadJob> download(String audioKey) async {
    final request = _requests[audioKey]!;
    return DownloadJob.fromRequest(request).copyWith(
      status: DownloadJobStatus.completed,
      downloadedBytes: request.expectedBytes ?? 0,
      localPath:
          '/offline/${request.reciterId}/${request.surahNumber!.toString().padLeft(3, '0')}.mp3',
    );
  }

  @override
  Future<DownloadJob?> getJob(String audioKey) async => null;

  @override
  Future<List<DownloadJob>> listJobs() async => const [];

  @override
  Future<void> pause(String audioKey) async => throw UnsupportedError('unused');

  @override
  Future<DownloadJob> resume(String audioKey) async =>
      throw UnsupportedError('unused');

  @override
  Future<DownloadJob> retry(String audioKey) async =>
      throw UnsupportedError('unused');

  @override
  Future<void> cancel(String audioKey) async =>
      throw UnsupportedError('unused');

  @override
  Future<void> delete(String audioKey) async =>
      throw UnsupportedError('unused');
}

class _FailingAudioDownloadRepository implements AudioDownloadRepository {
  _FailingAudioDownloadRepository({required this.errorCode});

  final String errorCode;
  final _requests = <String, AudioDownloadRequest>{};

  @override
  Future<DownloadJob> enqueue(AudioDownloadRequest request) async {
    _requests[request.audioKey] = request;
    return DownloadJob.fromRequest(request);
  }

  @override
  Future<DownloadJob> download(String audioKey) async {
    final request = _requests[audioKey]!;
    return DownloadJob.fromRequest(
      request,
    ).copyWith(status: DownloadJobStatus.failed, errorCode: errorCode);
  }

  @override
  Future<DownloadJob?> getJob(String audioKey) async => null;
  @override
  Future<List<DownloadJob>> listJobs() async => const [];
  @override
  Future<void> pause(String audioKey) async => throw UnsupportedError('unused');
  @override
  Future<DownloadJob> resume(String audioKey) async =>
      throw UnsupportedError('unused');
  @override
  Future<DownloadJob> retry(String audioKey) async =>
      throw UnsupportedError('unused');
  @override
  Future<void> cancel(String audioKey) async =>
      throw UnsupportedError('unused');
  @override
  Future<void> delete(String audioKey) async =>
      throw UnsupportedError('unused');
}
