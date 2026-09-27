import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/application/quran_audio_controller.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/hifz/application/hifz_plan_providers.dart';
import 'package:quran_hifz/features/hifz/application/hifz_session_controller.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_plan.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_progress.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_home_page.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_reader_page.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_surah_picker_sheet.dart';
import 'package:quran_hifz/features/quran/application/quran_mushaf_providers.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_juz.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_font_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

const _fatihah = QuranSurahSummary(
  number: 1,
  nameArabic: 'الفاتحة',
  nameEnglish: 'Al-Fatihah',
  nameBangla: 'আল-ফাতিহা',
  ayahCount: 7,
  pageStart: 7,
  pageEnd: 8,
  juzStart: 1,
);

void main() {
  testWidgets('empty Hifz home keeps Surah start primary and avoids retry noise', (
    tester,
  ) async {
    await tester.pumpWidget(
      _homeApp(plans: Stream.value(const [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('সূরা থেকে হিফজ শুরু করুন'), findsOneWidget);
    expect(find.text('এখনও কোনো সংরক্ষিত হিফজ পরিকল্পনা নেই।'), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-plans-retry')), findsNothing);
  });

  testWidgets('plan load error stays inline and never exposes raw SQLite text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _homeApp(
        plans: Stream<List<HifzPlan>>.error(
          StateError('no such table: hifz_plans'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('সূরা থেকে হিফজ শুরু করুন'), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-plans-retry')), findsOneWidget);
    expect(find.textContaining('no such table'), findsNothing);
  });

  testWidgets('saved plans are compact rows with progress and overflow action', (
    tester,
  ) async {
    final plan = HifzPlan(
      id: 1,
      profileKey: 'default',
      title: 'Al-Fatihah 1–5',
      start: const AyahRef(surahNumber: 1, ayahNumber: 1),
      end: const AyahRef(surahNumber: 1, ayahNumber: 5),
      startPage: 7,
      preset: HifzPresets.progressive(),
      createdAt: DateTime.utc(2026, 9, 27, 8),
      updatedAt: DateTime.utc(2026, 9, 27, 9),
    );
    final progressRepository = _MemoryHifzRepository()
      ..surahProgress = [
        _progress(1, HifzStatus.memorized),
        _progress(2, HifzStatus.learning),
      ];

    await tester.pumpWidget(
      _homeApp(
        plans: Stream.value([plan]),
        hifzRepository: progressRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('hifz-plan-1')), findsOneWidget);
    expect(find.text('Al-Fatihah 1–5'), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-plan-progress-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-plan-updated-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-plan-menu-1')), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('Surah selection creates plan with real ayah page then opens reader', (
    tester,
  ) async {
    final planRepository = _MemoryPlanRepository();

    await tester.pumpWidget(
      _homeApp(
        plans: Stream.value(const []),
        planRepository: planRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('সূরা থেকে হিফজ শুরু করুন'));
    await tester.pumpAndSettle();
    expect(find.byType(HifzSurahPickerSheet), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hifz-surah-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hifz-setup-start')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hifz-setup-start')));
    await tester.pumpAndSettle();

    expect(planRepository.createdStartPage, 7);
    expect(planRepository.createdStart, const AyahRef(surahNumber: 1, ayahNumber: 1));
    expect(planRepository.createdEnd, const AyahRef(surahNumber: 1, ayahNumber: 5));

    expect(find.byType(HifzReaderPage), findsOneWidget);
    final reader = tester.widget<HifzReaderPage>(find.byType(HifzReaderPage));
    expect(reader.initialPage, 7);
    expect(reader.config.start, const AyahRef(surahNumber: 1, ayahNumber: 1));
    expect(reader.config.end, const AyahRef(surahNumber: 1, ayahNumber: 5));

    await tester.tap(find.byKey(const ValueKey('hifz-reader-surah')));
    await tester.pumpAndSettle();
    expect(find.byType(HifzSurahPickerSheet), findsOneWidget);
  });
}

Widget _homeApp({
  required Stream<List<HifzPlan>> plans,
  _MemoryPlanRepository? planRepository,
  _MemoryHifzRepository? hifzRepository,
}) {
  final planRepo = planRepository ?? _MemoryPlanRepository();
  final progressRepo = hifzRepository ?? _MemoryHifzRepository();

  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWithValue(AppLanguage.bangla),
      appPreferencesRepositoryProvider.overrideWithValue(
        _MemoryPreferencesRepository(),
      ),
      quranRepositoryProvider.overrideWithValue(_FixtureQuranRepository()),
      hifzPlanRepositoryProvider.overrideWithValue(planRepo),
      hifzPlansProvider.overrideWith((ref) => plans),
      hifzRepositoryProvider.overrideWithValue(progressRepo),
      quranMushafPageRepositoryProvider.overrideWithValue(
        _FixtureMushafPageRepository(),
      ),
      quranPageFontRepositoryProvider.overrideWith(
        (ref, variant) => _UnavailablePageFontRepository(),
      ),
      quranAudioControllerProvider.overrideWith(_FixtureAudioController.new),
    ],
    child: const MaterialApp(home: HifzHomePage()),
  );
}

HifzProgress _progress(int ayah, HifzStatus status) => HifzProgress(
  ayah: AyahRef(surahNumber: 1, ayahNumber: ayah),
  status: status,
  strengthScore: 0,
  reviewCount: 0,
  mistakeCount: 0,
);

class _MemoryPlanRepository implements HifzPlanRepository {
  int? createdStartPage;
  AyahRef? createdStart;
  AyahRef? createdEnd;

  @override
  Stream<List<HifzPlan>> watchPlans(String profileKey) =>
      Stream.value(const []);

  @override
  Future<int> createPlan({
    required String profileKey,
    required String title,
    required AyahRef start,
    required AyahRef end,
    required int startPage,
    required HifzPreset preset,
  }) async {
    createdStartPage = startPage;
    createdStart = start;
    createdEnd = end;
    return 99;
  }

  @override
  Future<void> deletePlan(int id) async {}
}

class _MemoryHifzRepository implements HifzRepository {
  List<HifzProgress> surahProgress = const [];

  @override
  Future<List<HifzProgress>> loadSurahProgress({
    required String profileKey,
    required int surahNumber,
  }) async => surahProgress;

  @override
  Future<HifzProgress?> loadProgress({
    required String profileKey,
    required AyahRef ayah,
  }) async => null;

  @override
  Future<void> saveProgress({
    required String profileKey,
    required HifzProgress progress,
  }) async {}

  @override
  Future<void> markRangeLearning({
    required String profileKey,
    required AyahRef start,
    required AyahRef end,
  }) async {}

  @override
  Future<HifzSessionCheckpoint?> loadCheckpoint(String profileKey) async => null;

  @override
  Future<void> saveCheckpoint(HifzSessionCheckpoint checkpoint) async {}
}

class _FixtureQuranRepository implements QuranRepository {
  @override
  Future<List<QuranSurahSummary>> listSurahs() async => const [_fatihah];

  @override
  Future<List<QuranJuzSummary>> listJuzs() async => const [];

  @override
  Future<QuranAyah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
    required int translationResourceId,
  }) async {
    return QuranAyah(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      pageNumber: 7,
      words: const [],
    );
  }

  @override
  Future<QuranPageWindow> loadPageWindow({
    required int page,
    required int translationResourceId,
  }) async {
    return QuranPageWindow(
      page: page,
      ayahs: const [],
      previousPage: page <= 7 ? null : page - 1,
      nextPage: page >= 8 ? null : page + 1,
    );
  }
}

class _FixtureMushafPageRepository implements QuranMushafPageRepository {
  @override
  Future<bool> isVariantAvailable(QuranMushafVariant variant) async => true;

  @override
  Future<QcfMushafPage> loadPage({
    required QuranMushafVariant variant,
    required int page,
  }) async => QcfMushafPage(page: page, variant: variant, lines: const []);
}

class _UnavailablePageFontRepository implements QuranPageFontRepository {
  @override
  Future<Uri> ensurePageFont(int page) async {
    throw QuranPageFontUnavailableException(
      page: page,
      message: 'offline fixture',
    );
  }

  @override
  Future<bool> isCached(int page) async => false;

  @override
  Future<void> prefetchNeighbors(int page) async {}
}

class _FixtureAudioController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState.initial();
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
