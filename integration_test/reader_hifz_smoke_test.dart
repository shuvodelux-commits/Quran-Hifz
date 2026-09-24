import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_hifz/features/hifz/application/hifz_session_controller.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_audio_port.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_progress.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_step.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_page.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_juz.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/presentation/quran_reader_page.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/quran_word_view.dart';
import 'package:quran_hifz/features/reciters/application/reciter_catalog_controller.dart';
import 'package:quran_hifz/features/reciters/domain/chapter_reciter.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

import 'support/pump_until.dart';

const _fixtureSurah = QuranSurahSummary(
  number: 1,
  nameArabic: 'الفاتحة',
  nameEnglish: 'Al-Fatihah',
  nameBangla: 'আল-ফাতিহা',
  revelationPlace: 'Makkah',
  ayahCount: 7,
  pageStart: 1,
  pageEnd: 1,
  juzStart: 1,
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reader renders canonical word and translation fixture', (
    tester,
  ) async {
    addTearDown(() => disposeTestApp(tester));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranRepositoryProvider.overrideWithValue(_ReaderFixtureRepository()),
          readingLocationStoreProvider.overrideWithValue(_NoopLocationStore()),
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
        ],
        child: const MaterialApp(home: QuranReaderPage(surah: _fixtureSurah)),
      ),
    );
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('ayah-1:1')),
      description: 'reader fixture ayah 1:1',
    );

    expect(find.byKey(const ValueKey('ayah-1:1')), findsOneWidget);
    expect(find.byType(QuranWordView), findsWidgets);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Fixture Bangla translation'), findsOneWidget);
  });

  testWidgets('Hifz picker bounds ranges and completes a valid range', (
    tester,
  ) async {
    addTearDown(() => disposeTestApp(tester));

    final repository = _MemoryHifzRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hifzRepositoryProvider.overrideWithValue(repository),
          hifzAudioPortProvider.overrideWithValue(_NoopHifzAudioPort()),
          quranRepositoryProvider.overrideWithValue(_HifzFixtureRepository()),
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
          reciterCatalogControllerProvider.overrideWith(
            _SelectedReciterCatalogController.new,
          ),
        ],
        child: const MaterialApp(home: HifzPage()),
      ),
    );
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('hifz-tools')),
      description: 'Hifz reading controls',
    );
    await tester.tap(find.byKey(const ValueKey('hifz-tools')));
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('hifz-start-range')),
      description: 'Audio & Hifz setup sheet',
    );
    await tester.tap(find.byKey(const ValueKey('hifz-start-range')));
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('hifz-ayah-choice-7')),
      description: 'start ayah picker',
    );
    expect(find.byKey(const ValueKey('hifz-ayah-choice-8')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-7')));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('hifz-end-range')));
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('hifz-ayah-choice-7')),
      description: 'end ayah picker',
    );
    expect(find.byKey(const ValueKey('hifz-ayah-choice-1')), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('hifz-start-range')));
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('hifz-ayah-choice-1')),
      description: 'reset start ayah picker',
    );
    await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-1')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hifz-end-range')));
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('hifz-ayah-choice-1')),
      description: 'valid end ayah picker',
    );
    await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-1')));
    await tester.pump(const Duration(milliseconds: 300));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HifzPage)),
    );
    await tester.tap(find.byKey(const ValueKey('hifz-setup-play')));
    await tester.pump();
    await _waitForHifzCompletion(
      tester,
      container: container,
      repository: repository,
    );

    expect(find.byKey(const ValueKey('hifz-active-player')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-tools')), findsOneWidget);
    expect(repository.checkpoint?.status, HifzSessionStatus.completed);
  });
}

Future<void> _waitForHifzCompletion(
  WidgetTester tester, {
  required ProviderContainer container,
  required _MemoryHifzRepository repository,
  Duration timeout = const Duration(seconds: 20),
}) async {
  debugPrint('[E2E] waiting for completed Hifz provider state');
  final deadline = DateTime.now().add(timeout);

  while (true) {
    final state = container.read(hifzSessionControllerProvider);
    if (state.status == HifzSessionStatus.completed) {
      await tester.pump(const Duration(milliseconds: 250));
      debugPrint('[E2E] ready: completed Hifz provider state');
      return;
    }

    if (state.status == HifzSessionStatus.error) {
      throw TestFailure(
        'Hifz entered error state: ${state.error}\n'
        'step=${state.currentStepIndex}/${state.totalSteps}; '
        'checkpointStatus=${repository.checkpoint?.status.name}; '
        'checkpointStep=${repository.checkpoint?.nextStepIndex}',
      );
    }

    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure(
        'Timed out after ${timeout.inSeconds}s waiting for Hifz completion. '
        'status=${state.status.name}; '
        'step=${state.currentStepIndex}/${state.totalSteps}; '
        'checkpointStatus=${repository.checkpoint?.status.name}; '
        'checkpointStep=${repository.checkpoint?.nextStepIndex}',
      );
    }

    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  AppPreferences value = const AppPreferences.defaults();

  @override
  Future<AppPreferences> load() async => value;

  @override
  Future<void> save(AppPreferences preferences) async {
    value = preferences;
  }
}

class _NoopLocationStore implements ReadingLocationStore {
  @override
  Future<ReadingLocation?> load() async => null;

  @override
  Future<void> save(ReadingLocation location) async {}
}

class _ReaderFixtureRepository implements QuranRepository {
  @override
  Future<List<QuranJuzSummary>> listJuzs() async => const [];

  @override
  Future<List<QuranSurahSummary>> listSurahs() async => const [];

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
    return QuranPageWindow(
      page: 1,
      previousPage: null,
      nextPage: 2,
      ayahs: [
        QuranAyah(
          surahNumber: 1,
          ayahNumber: 1,
          arabicText: 'AB',
          pageNumber: 1,
          juzNumber: 1,
          translation: 'Fixture Bangla translation',
          words: [
            QuranWord(
              position: 1,
              arabic: 'A',
              banglaMeaning: 'Fixture meaning',
            ),
            QuranWord(position: 2, arabic: 'B'),
          ],
        ),
      ],
    );
  }
}

class _HifzFixtureRepository implements QuranRepository {
  @override
  Future<List<QuranJuzSummary>> listJuzs() async => const [];

  @override
  Future<List<QuranSurahSummary>> listSurahs() async => const [_fixtureSurah];

  @override
  Future<QuranAyah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
    required int translationResourceId,
  }) async {
    if (surahNumber != 1 || ayahNumber < 1 || ayahNumber > 7) return null;
    return _ayah(ayahNumber);
  }

  @override
  Future<QuranPageWindow> loadPageWindow({
    required int page,
    required int translationResourceId,
  }) async => QuranPageWindow(
    page: 1,
    previousPage: null,
    nextPage: null,
    ayahs: [for (var number = 1; number <= 7; number++) _ayah(number)],
  );

  QuranAyah _ayah(int number) => QuranAyah(
    surahNumber: 1,
    ayahNumber: number,
    pageNumber: 1,
    arabicText: 'كَلِمَة',
    words: const [QuranWord(position: 1, arabic: 'كَلِمَة')],
  );
}

class _SelectedReciterCatalogController extends ReciterCatalogController {
  @override
  Future<ReciterCatalogState> build() async => const ReciterCatalogState(
    reciters: [
      ChapterReciter(
        id: 7,
        name: 'Test reciter',
        styleName: null,
        styleLanguageName: null,
        qiratName: null,
        qiratLanguageName: null,
      ),
    ],
    selectedReciterId: 7,
  );
}

class _MemoryHifzRepository implements HifzRepository {
  HifzSessionCheckpoint? checkpoint;

  @override
  Future<HifzSessionCheckpoint?> loadCheckpoint(String profileKey) async {
    return checkpoint;
  }

  @override
  Future<HifzProgress?> loadProgress({
    required String profileKey,
    required AyahRef ayah,
  }) async => null;

  @override
  Future<void> markRangeLearning({
    required String profileKey,
    required AyahRef start,
    required AyahRef end,
  }) async {}

  @override
  Future<void> saveCheckpoint(HifzSessionCheckpoint value) async {
    checkpoint = value;
  }

  @override
  Future<void> saveProgress({
    required String profileKey,
    required HifzProgress progress,
  }) async {}
}

class _NoopHifzAudioPort implements HifzAudioPort {
  @override
  Future<void> pause() async {}

  @override
  Future<void> playStep(
    HifzStep step, {
    HifzStepProgressCallback? onProgress,
  }) async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}
}
