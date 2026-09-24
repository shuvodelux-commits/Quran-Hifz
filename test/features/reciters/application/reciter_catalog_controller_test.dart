import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/quran/data/quran_audio_sync_service.dart';
import 'package:quran_hifz/features/quran/domain/word_audio_source.dart';
import 'package:quran_hifz/features/reciters/application/reciter_audio_providers.dart';
import 'package:quran_hifz/features/reciters/application/reciter_catalog_controller.dart';
import 'package:quran_hifz/features/reciters/data/bundled_reciter_catalog_source.dart';
import 'package:quran_hifz/features/reciters/domain/chapter_reciter.dart';
import 'package:quran_hifz/features/reciters/domain/reciter_repository.dart';
import 'package:quran_hifz/features/downloads/domain/download_job.dart';
import 'package:quran_hifz/features/downloads/domain/audio_download_repository.dart';
import 'package:quran_hifz/features/downloads/application/download_controller.dart';
import 'dart:async';

class _FakeRepository implements ReciterRepository {
  _FakeRepository({this.initialSelectedReciterId});

  final int? initialSelectedReciterId;
  final selected = <int>[];

  @override
  Future<List<ChapterReciter>> loadCatalog() async => const [
    ChapterReciter(
      id: 4,
      name: 'Four',
      styleName: 'Murattal',
      styleLanguageName: 'English',
      qiratName: 'Hafs',
      qiratLanguageName: 'English',
    ),
  ];

  @override
  Future<int?> loadSelectedReciterId() async => initialSelectedReciterId;

  @override
  Future<void> clearSelectedReciter() async {}

  @override
  Future<void> selectReciter(int id) async => selected.add(id);
}

class _FakeChapterAudioPreparer implements ChapterAudioPreparer {
  final calls = <(int, int, bool)>[];

  @override
  Future<ChapterAudioSyncResult> prepare({
    required int reciterId,
    required int surahNumber,
    required bool downloadAudio,
    ChapterAudioPreparationProgressCallback? onProgress,
    bool Function()? isCancelled,
  }) async {
    calls.add((reciterId, surahNumber, downloadAudio));
    return ChapterAudioSyncResult(
      reciterId: reciterId,
      surahNumber: surahNumber,
      remoteUrl: 'https://example.test/$surahNumber.mp3',
      localPath: downloadAudio ? '/tmp/$surahNumber.mp3' : null,
      format: 'mp3',
      fileSize: 10,
      ayahTimingCount: 7,
    );
  }
}

class _PendingChapterPreparer implements ChapterAudioPreparer {
  final started = Completer<void>();
  final _finished = Completer<void>();
  void finish() => _finished.complete();

  @override
  Future<ChapterAudioSyncResult> prepare({
    required int reciterId,
    required int surahNumber,
    required bool downloadAudio,
    ChapterAudioPreparationProgressCallback? onProgress,
    bool Function()? isCancelled,
  }) async {
    started.complete();
    await _finished.future;
    return ChapterAudioSyncResult(
      reciterId: reciterId,
      surahNumber: surahNumber,
      remoteUrl: 'https://example.test/audio.mp3',
      localPath: '/tmp/audio.mp3',
      format: 'mp3',
      fileSize: 100,
      ayahTimingCount: 1,
    );
  }
}

class _RecordingDownloads implements AudioDownloadRepository {
  final cancelled = <String>[];
  @override
  Future<void> cancel(String audioKey) async => cancelled.add(audioKey);
  @override
  Future<List<DownloadJob>> listJobs() async => [];
  @override
  Future<DownloadJob?> getJob(String audioKey) async => null;
  @override
  Future<DownloadJob> enqueue(AudioDownloadRequest request) async =>
      DownloadJob.fromRequest(request);
  @override
  Future<DownloadJob> download(String audioKey) => throw UnimplementedError();
  @override
  Future<void> pause(String audioKey) async {}
  @override
  Future<DownloadJob> resume(String audioKey) => throw UnimplementedError();
  @override
  Future<DownloadJob> retry(String audioKey) => throw UnimplementedError();
  @override
  Future<void> delete(String audioKey) async {}
}

void main() {
  test(
    'cancel stops an active chapter download and marks it cancelled',
    () async {
      final preparer = _PendingChapterPreparer();
      final downloads = _RecordingDownloads();
      final container = ProviderContainer(
        overrides: [
          reciterRepositoryProvider.overrideWithValue(_FakeRepository()),
          chapterAudioPreparerProvider.overrideWithValue(preparer),
          audioDownloadRepositoryProvider.overrideWithValue(downloads),
        ],
      );
      addTearDown(container.dispose);
      await container.read(reciterCatalogControllerProvider.future);
      await container.read(reciterCatalogControllerProvider.notifier).select(4);
      final running = container
          .read(reciterCatalogControllerProvider.notifier)
          .prepareChapter(surahNumber: 67, downloadAudio: true);
      await preparer.started.future;
      await container
          .read(reciterCatalogControllerProvider.notifier)
          .cancelPrepare();
      expect(downloads.cancelled, contains('chapter:4:67'));
      preparer.finish();
      await expectLater(running, throwsA(isA<ChapterAudioDownloadException>()));
      expect(
        container
            .read(reciterCatalogControllerProvider)
            .value
            ?.preparationStatus,
        ChapterPreparationStatus.cancelled,
      );
    },
  );
  test(
    'cancelled Surah preparation stops before downloading word audio',
    () async {
      final sync = _FakeQuranAudioSync();
      final catalog = _FakeWordAudioCatalog(const [
        QuranWordAudioSource(
          surahNumber: 67,
          ayahNumber: 1,
          wordPosition: 1,
          remotePath: 'wbw/one.mp3',
        ),
      ]);
      var cancel = false;
      final preparer = QuranAudioSyncChapterPreparer(sync, catalog);
      await expectLater(
        preparer.prepare(
          reciterId: 7,
          surahNumber: 67,
          downloadAudio: true,
          isCancelled: () => cancel,
          onProgress: (progress) {
            if (progress.stage == ChapterAudioPreparationStage.words)
              cancel = true;
          },
        ),
        throwsA(
          isA<ChapterAudioDownloadException>().having(
            (error) => error.status,
            'status',
            DownloadJobStatus.cancelled,
          ),
        ),
      );
      expect(sync.wordCalls, isEmpty);
    },
  );
  test(
    'rejects selecting an id that is not in the chapter-reciter catalog',
    () async {
      final repository = _FakeRepository();
      final preparer = _FakeChapterAudioPreparer();
      final container = ProviderContainer(
        overrides: [
          reciterRepositoryProvider.overrideWithValue(repository),
          chapterAudioPreparerProvider.overrideWithValue(preparer),
        ],
      );
      addTearDown(container.dispose);

      await container.read(reciterCatalogControllerProvider.future);

      await expectLater(
        container.read(reciterCatalogControllerProvider.notifier).select(99),
        throwsArgumentError,
      );
    },
  );

  test('prepares current Surah with selected chapter-reciter id', () async {
    final repository = _FakeRepository();
    final preparer = _FakeChapterAudioPreparer();
    final container = ProviderContainer(
      overrides: [
        reciterRepositoryProvider.overrideWithValue(repository),
        chapterAudioPreparerProvider.overrideWithValue(preparer),
      ],
    );
    addTearDown(container.dispose);

    await container.read(reciterCatalogControllerProvider.future);
    await container.read(reciterCatalogControllerProvider.notifier).select(4);
    final result = await container
        .read(reciterCatalogControllerProvider.notifier)
        .prepareChapter(surahNumber: 67, downloadAudio: true);

    expect(preparer.calls, [(4, 67, true)]);
    expect(result.localPath, '/tmp/67.mp3');
  });
  test(
    'offline Surah preparation downloads chapter and every available word audio',
    () async {
      final sync = _FakeQuranAudioSync();
      final catalog = _FakeWordAudioCatalog(const [
        QuranWordAudioSource(
          surahNumber: 67,
          ayahNumber: 1,
          wordPosition: 1,
          remotePath: 'wbw/067001001.mp3',
        ),
        QuranWordAudioSource(
          surahNumber: 67,
          ayahNumber: 1,
          wordPosition: 2,
          remotePath: 'wbw/067001002.mp3',
        ),
      ]);
      final preparer = QuranAudioSyncChapterPreparer(sync, catalog);

      final result = await preparer.prepare(
        reciterId: 7,
        surahNumber: 67,
        downloadAudio: true,
      );

      expect(result.localPath, '/offline/67.mp3');
      expect(sync.chapterCalls, [(7, 67, true)]);
      expect(sync.wordCalls, [
        (67, 1, 1, 'wbw/067001001.mp3'),
        (67, 1, 2, 'wbw/067001002.mp3'),
      ]);
    },
  );

  test(
    'offline preparation keeps chapter success when word audio is partial',
    () async {
      final sync = _FakeQuranAudioSync(failingWordPositions: {2});
      final catalog = _FakeWordAudioCatalog(const [
        QuranWordAudioSource(
          surahNumber: 67,
          ayahNumber: 1,
          wordPosition: 1,
          remotePath: 'wbw/067001001.mp3',
        ),
        QuranWordAudioSource(
          surahNumber: 67,
          ayahNumber: 1,
          wordPosition: 2,
          remotePath: 'wbw/067001002.mp3',
        ),
      ]);
      final preparer = QuranAudioSyncChapterPreparer(sync, catalog);
      final progress = <ChapterAudioPreparationProgress>[];

      final result = await preparer.prepare(
        reciterId: 7,
        surahNumber: 67,
        downloadAudio: true,
        onProgress: progress.add,
      );

      expect(result.localPath, '/offline/67.mp3');
      expect(progress, isNotEmpty);
      expect(progress.last.stage, ChapterAudioPreparationStage.complete);
      expect(progress.last.totalWordFiles, 2);
      expect(progress.last.downloadedWordFiles, 1);
      expect(progress.last.failedWordFiles, 1);
    },
  );

  test('stream preparation does not download word audio', () async {
    final sync = _FakeQuranAudioSync();
    final catalog = _FakeWordAudioCatalog(const [
      QuranWordAudioSource(
        surahNumber: 67,
        ayahNumber: 1,
        wordPosition: 1,
        remotePath: 'wbw/067001001.mp3',
      ),
    ]);
    final preparer = QuranAudioSyncChapterPreparer(sync, catalog);

    await preparer.prepare(reciterId: 7, surahNumber: 67, downloadAudio: false);

    expect(sync.chapterCalls, [(7, 67, false)]);
    expect(sync.wordCalls, isEmpty);
    expect(catalog.calls, isEmpty);
  });

  test(
    'controller selects the default reciter from its catalog source',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final bundle = _MapAssetBundle({
        'assets/audio/reciters_v1.json': jsonEncode({
          'schema_version': 1,
          'source_name': 'Quran Foundation Content API v4',
          'source_version': 'test',
          'generated_at_utc': '2026-09-13T00:00:00.000Z',
          'reciters': [
            {
              'id': 7,
              'name': 'Bundled Seven',
              'style': {'name': 'Murattal', 'language_name': 'English'},
              'qirat': {'name': 'Hafs', 'language_name': 'English'},
            },
          ],
        }),
      });
      final container = ProviderContainer(
        overrides: [
          reciterCatalogSourceProvider.overrideWithValue(
            BundledReciterCatalogSource(bundle: bundle),
          ),
          userDatabaseProvider.overrideWithValue(database),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        reciterCatalogControllerProvider.future,
      );

      expect(state.reciters.single.id, 7);
      expect(state.reciters.single.name, 'Bundled Seven');
      expect(state.selectedReciterId, 7);
      expect(await database.getSetting('selected_reciter_id'), '7');
    },
  );

  test(
    'an existing reciter selection is not replaced by the fresh default',
    () async {
      final repository = _FakeRepository(initialSelectedReciterId: 4);
      final container = ProviderContainer(
        overrides: [reciterRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        reciterCatalogControllerProvider.future,
      );

      expect(state.selectedReciterId, 4);
      expect(repository.selected, isEmpty);
    },
  );
}

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) throw FlutterError('Missing fake asset: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

class _FakeWordAudioCatalog implements SurahWordAudioCatalog {
  _FakeWordAudioCatalog(this.items);

  final List<QuranWordAudioSource> items;
  final List<int> calls = [];

  @override
  Future<List<QuranWordAudioSource>> listForSurah(int surahNumber) async {
    calls.add(surahNumber);
    return items;
  }
}

class _FakeQuranAudioSync implements QuranAudioSync {
  _FakeQuranAudioSync({this.failingWordPositions = const {}});

  final Set<int> failingWordPositions;
  final List<(int, int, bool)> chapterCalls = [];
  final List<(int, int, int, String)> wordCalls = [];

  @override
  Future<ChapterAudioSyncResult> syncChapter({
    required int reciterId,
    required int surahNumber,
    bool downloadAudio = true,
  }) async {
    chapterCalls.add((reciterId, surahNumber, downloadAudio));
    return ChapterAudioSyncResult(
      reciterId: reciterId,
      surahNumber: surahNumber,
      remoteUrl: 'https://example.test/$surahNumber.mp3',
      localPath: downloadAudio ? '/offline/$surahNumber.mp3' : null,
      format: 'mp3',
      fileSize: 10,
      ayahTimingCount: 7,
    );
  }

  @override
  Future<String?> cacheWordAudio({
    required int surahNumber,
    required int ayahNumber,
    required int wordPosition,
    required String relativeAudioPath,
  }) async {
    wordCalls.add((surahNumber, ayahNumber, wordPosition, relativeAudioPath));
    if (failingWordPositions.contains(wordPosition)) return null;
    return '/offline/words/$surahNumber/$ayahNumber/$wordPosition.mp3';
  }
}
