import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/quran/application/reader_state.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_juz.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';

void main() {
  test('opening a page loads only current and adjacent windows', () async {
    final repository = _RecordingRepository();
    final location = _RecordingLocationStore();
    final container = ProviderContainer(
      overrides: [
        quranRepositoryProvider.overrideWithValue(repository),
        readingLocationStoreProvider.overrideWithValue(location),
      ],
    );
    addTearDown(container.dispose);

    await container.read(readerControllerProvider.future);
    await container.read(readerControllerProvider.notifier).openPage(200);

    expect(repository.requestedPages.toSet(), containsAll({199, 200, 201}));
    expect(
      repository.requestedPages
          .where((page) => page >= 199 && page <= 201)
          .toSet(),
      {199, 200, 201},
    );
    final state = container.read(readerControllerProvider).requireValue;
    expect(state.loadedPages.toSet(), {199, 200, 201});
    expect(state.currentPage, 200);
  });

  test('adjacent navigation reuses prefetched windows', () async {
    final repository = _RecordingRepository();
    final container = ProviderContainer(
      overrides: [
        quranRepositoryProvider.overrideWithValue(repository),
        readingLocationStoreProvider.overrideWithValue(
          _RecordingLocationStore(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(readerControllerProvider.future);
    expect(repository.requestedPages, [1, 2]);

    await container.read(readerControllerProvider.notifier).openPage(2);

    expect(repository.requestedPages, [1, 2, 3]);
    expect(container.read(readerControllerProvider).requireValue.loadedPages, [
      1,
      2,
      3,
    ]);
  });

  test(
    'reader state owns content windows but not presentation preferences',
    () {
      const state = ReaderState(
        currentPage: 1,
        windows: <int, QuranPageWindow>{},
        translationResourceId: 1,
      );

      expect(state.currentPage, 1);
      expect(state.translationResourceId, 1);
      expect(state.loadedPages, isEmpty);
    },
  );

  test('page navigation persists current reading location', () async {
    final repository = _RecordingRepository();
    final location = _RecordingLocationStore();
    final container = ProviderContainer(
      overrides: [
        quranRepositoryProvider.overrideWithValue(repository),
        readingLocationStoreProvider.overrideWithValue(location),
      ],
    );
    addTearDown(container.dispose);

    await container.read(readerControllerProvider.future);
    await container.read(readerControllerProvider.notifier).openPage(42);

    expect(location.saved.last.page, 42);
    expect(location.saved.last.surahNumber, 2);
    expect(location.saved.last.ayahNumber, 42);
  });

  test('long Surah navigation never requests a whole Surah', () async {
    final repository = _RecordingRepository();
    final container = ProviderContainer(
      overrides: [
        quranRepositoryProvider.overrideWithValue(repository),
        readingLocationStoreProvider.overrideWithValue(
          _RecordingLocationStore(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(readerControllerProvider.future);
    for (final page in [2, 3, 4, 5]) {
      await container.read(readerControllerProvider.notifier).openPage(page);
    }

    expect(repository.listSurahsCalls, 0);
    expect(
      repository.requestedPages.every((page) => page >= 1 && page <= 6),
      isTrue,
    );
  });

  test(
    'continuous reader appends the next page without changing current page',
    () async {
      final repository = _RecordingRepository();
      final container = ProviderContainer(
        overrides: [
          quranRepositoryProvider.overrideWithValue(repository),
          readingLocationStoreProvider.overrideWithValue(
            _RecordingLocationStore(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(readerControllerProvider.future);
      final before = container.read(readerControllerProvider).requireValue;
      expect(before.currentPage, 1);
      expect(before.loadedPages, [1, 2]);

      await container.read(readerControllerProvider.notifier).loadNextWindow();

      final after = container.read(readerControllerProvider).requireValue;
      expect(after.currentPage, 1);
      expect(after.loadedPages, [1, 2, 3]);
      expect(repository.requestedPages, [1, 2, 3]);
    },
  );

  test(
    'continuous reader prepends the previous page without changing current page',
    () async {
      final repository = _RecordingRepository();
      final container = ProviderContainer(
        overrides: [
          quranRepositoryProvider.overrideWithValue(repository),
          readingLocationStoreProvider.overrideWithValue(
            _RecordingLocationStore(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(readerControllerProvider.future);
      await container.read(readerControllerProvider.notifier).openPage(200);
      final before = container.read(readerControllerProvider).requireValue;
      expect(before.currentPage, 200);
      expect(before.loadedPages, [199, 200, 201]);

      await container
          .read(readerControllerProvider.notifier)
          .loadPreviousWindow();

      final after = container.read(readerControllerProvider).requireValue;
      expect(after.currentPage, 200);
      expect(after.loadedPages, [198, 199, 200, 201]);
      expect(repository.requestedPages, contains(198));
    },
  );

  test('scoped page bounds prevent prefetch and lazy-load escape', () async {
    final repository = _RecordingRepository();
    final container = ProviderContainer(
      overrides: [
        quranRepositoryProvider.overrideWithValue(repository),
        readingLocationStoreProvider.overrideWithValue(
          _RecordingLocationStore(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(readerControllerProvider.future);
    repository.requestedPages.clear();
    await container
        .read(readerControllerProvider.notifier)
        .openPage(20, firstPage: 20, lastPage: 21);
    await container
        .read(readerControllerProvider.notifier)
        .loadPreviousWindow();
    await container.read(readerControllerProvider.notifier).loadNextWindow();

    final state = container.read(readerControllerProvider).requireValue;
    expect(repository.requestedPages.toSet(), {20, 21});
    expect(state.firstPage, 20);
    expect(state.lastPage, 21);
  });
}

class _RecordingRepository implements QuranRepository {
  final List<int> requestedPages = [];
  int listSurahsCalls = 0;

  @override
  Future<List<QuranJuzSummary>> listJuzs() async => const [];

  @override
  Future<List<QuranSurahSummary>> listSurahs() async {
    listSurahsCalls++;
    return const [];
  }

  @override
  Future<QuranAyah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
    required int translationResourceId,
  }) async => null;

  @override
  Future<QuranPageWindow> loadPageWindow({
    required int page,
    required int translationResourceId,
  }) async {
    requestedPages.add(page);
    return QuranPageWindow(
      page: page,
      previousPage: page > 1 ? page - 1 : null,
      nextPage: page < 604 ? page + 1 : null,
      ayahs: [
        QuranAyah(
          surahNumber: page == 1 ? 1 : 2,
          ayahNumber: page,
          arabicText: 'fixture$page',
          pageNumber: page,
          juzNumber: 1,
          translation: 'translation$page',
          words: const [QuranWord(position: 1, arabic: 'word')],
        ),
      ],
    );
  }
}

class _RecordingLocationStore implements ReadingLocationStore {
  final List<ReadingLocation> saved = [];

  @override
  Future<ReadingLocation?> load() async => null;

  @override
  Future<void> save(ReadingLocation location) async {
    saved.add(location);
  }
}
