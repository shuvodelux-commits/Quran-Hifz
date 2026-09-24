import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_juz.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/presentation/quran_surah_list_page.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';
import 'package:quran_hifz/features/study/domain/bookmark.dart';

void main() {
  testWidgets('library has Surah Juz Bookmarks tabs and fuzzy search', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('কুরআন'), findsOneWidget);
    expect(find.text('আল-ফাতিহা'), findsOneWidget);
    expect(find.text('আল-বাকারা'), findsOneWidget);
    expect(find.text('سورة الفاتحة'), findsOneWidget);

    expect(find.text('সব'), findsNothing);
    expect(find.text('মাক্কী'), findsNothing);
    expect(find.byKey(const ValueKey('quran-tab-surah')), findsOneWidget);
    expect(find.byKey(const ValueKey('quran-tab-juz')), findsOneWidget);
    expect(find.byKey(const ValueKey('quran-tab-bookmarks')), findsOneWidget);

    await tester.tap(find.byTooltip('Search Quran'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'al hah');
    await tester.pumpAndSettle();
    expect(find.text('আল-ফাতিহা'), findsOneWidget);
    expect(find.text('আল-বাকারা'), findsNothing);
  });

  testWidgets('Juz tab opens a cross-Surah bounded reader', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quran-tab-juz')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('juz-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('ayah-1:1')), findsOneWidget);
    expect(find.byKey(const ValueKey('ayah-2:1')), findsOneWidget);
  });

  testWidgets('Surah library exposes the subtle numbered quick-scroll rail', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('number-quick-scroll-rail')),
      findsOneWidget,
    );
    expect(find.text('সূরা নম্বর বাছুন'), findsNothing);
  });

  testWidgets(
    'tapping a Surah pushes its Surah-scoped reader and Back returns to list',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('আল-ফাতিহা'));
      await tester.pumpAndSettle();

      expect(find.text('الفاتحة'), findsWidgets);
      expect(find.byKey(const ValueKey('ayah-1:1')), findsOneWidget);
      expect(find.byKey(const ValueKey('ayah-2:1')), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('কুরআন'), findsOneWidget);
      expect(find.text('আল-বাকারা'), findsOneWidget);
    },
  );
}

Widget _app() => ProviderScope(
  overrides: [
    quranRepositoryProvider.overrideWithValue(_Repository()),
    readingLocationStoreProvider.overrideWithValue(_NoopLocationStore()),
    appPreferencesRepositoryProvider.overrideWithValue(
      _MemoryPreferencesRepository(),
    ),
  ],
  child: const MaterialApp(home: QuranSurahListPage()),
);

class _Repository implements QuranRepository {
  @override
  Future<List<QuranJuzSummary>> listJuzs() async => List.generate(
    30,
    (index) => QuranJuzSummary(
      number: index + 1,
      firstTarget: StudyTarget.ayah(
        surahNumber: index == 0 ? 1 : 2,
        ayahNumber: 1,
      ),
      lastTarget: const StudyTarget.ayah(surahNumber: 2, ayahNumber: 1),
      firstPage: index == 0 ? 1 : 2,
      lastPage: index == 0 ? 1 : 2,
      startSurahNumber: index == 0 ? 1 : 2,
      endSurahNumber: 2,
    ),
  );

  @override
  Future<List<QuranSurahSummary>> listSurahs() async => const [
    QuranSurahSummary(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      nameBangla: null,
      revelationPlace: 'Makkah',
      ayahCount: 7,
      pageStart: 1,
      pageEnd: 1,
      juzStart: 1,
    ),
    QuranSurahSummary(
      number: 2,
      nameArabic: 'البقرة',
      nameEnglish: 'Al-Baqarah',
      nameBangla: null,
      revelationPlace: 'Madinah',
      ayahCount: 286,
      pageStart: 2,
      pageEnd: 49,
      juzStart: 1,
    ),
  ];

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
    if (page == 1) {
      return QuranPageWindow(
        page: 1,
        previousPage: null,
        nextPage: 2,
        ayahs: [
          QuranAyah(
            surahNumber: 1,
            ayahNumber: 1,
            arabicText: 'Selected Surah ayah',
            pageNumber: 1,
            juzNumber: 1,
            words: [],
          ),
          QuranAyah(
            surahNumber: 2,
            ayahNumber: 1,
            arabicText: 'Other Surah ayah',
            pageNumber: 1,
            juzNumber: 1,
            words: [],
          ),
        ],
      );
    }
    return QuranPageWindow(
      page: page,
      previousPage: page > 1 ? page - 1 : null,
      nextPage: page < 604 ? page + 1 : null,
      ayahs: const [],
    );
  }
}

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  AppPreferences value = const AppPreferences.defaults();
  @override
  Future<AppPreferences> load() async => value;
  @override
  Future<void> save(AppPreferences preferences) async => value = preferences;
}

class _NoopLocationStore implements ReadingLocationStore {
  @override
  Future<ReadingLocation?> load() async => null;
  @override
  Future<void> save(ReadingLocation location) async {}
}
