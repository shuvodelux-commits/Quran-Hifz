import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/features/dua/application/dua_providers.dart';
import 'package:quran_hifz/features/dua/domain/dua.dart';
import 'package:quran_hifz/features/dua/domain/dua_favorites_repository.dart';
import 'package:quran_hifz/features/dua/domain/dua_repository.dart';
import 'package:quran_hifz/features/dua/presentation/dua_page.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('Bangla landing page shows daily duas in configured order', (
    tester,
  ) async {
    final favorites = _MemoryFavoritesRepository();
    await _pump(tester, language: AppLanguage.bangla, favorites: favorites);

    expect(find.text('দোয়া'), findsOneWidget);
    expect(find.byKey(const ValueKey('dua-search-field')), findsOneWidget);
    expect(find.text('দৈনিক দোয়া'), findsOneWidget);

    final wakeY = tester.getTopLeft(find.text('ঘুম থেকে ওঠা')).dy;
    final sleepY = tester.getTopLeft(find.text('ঘুমানোর আগে')).dy;
    expect(wakeY, lessThan(sleepY));
  });

  testWidgets('English search finds the whole catalog and empty state clears', (
    tester,
  ) async {
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository(),
    );

    await tester.enterText(
      find.byKey(const ValueKey('dua-search-field')),
      'Travel',
    );
    await tester.pumpAndSettle();

    expect(find.text('Travel dua'), findsOneWidget);
    expect(find.text('Upon waking'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('dua-search-field')),
      'not-present',
    );
    await tester.pumpAndSettle();

    expect(find.text('No duas found'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Daily Duas'), findsOneWidget);
  });

  testWidgets('category chip filters results', (tester) async {
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository(),
    );

    await tester.tap(find.byKey(const ValueKey('dua-category-sleep')));
    await tester.pumpAndSettle();

    expect(find.text('Before sleeping'), findsOneWidget);
    expect(find.text('Upon waking'), findsNothing);
  });

  testWidgets('favorite toggles immediately and Favorites filter persists it', (
    tester,
  ) async {
    final favorites = _MemoryFavoritesRepository();
    await _pump(tester, language: AppLanguage.english, favorites: favorites);

    await tester.tap(find.byKey(const ValueKey('dua-favorite-wake')));
    await tester.pumpAndSettle();
    expect(await favorites.load(), {'wake'});

    await tester.tap(find.byKey(const ValueKey('dua-favorites-filter')));
    await tester.pumpAndSettle();

    expect(find.text('Upon waking'), findsOneWidget);
    expect(find.text('Before sleeping'), findsNothing);
  });

  testWidgets('empty Favorites gives localized guidance', (tester) async {
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository(),
    );

    await tester.tap(find.byKey(const ValueKey('dua-favorites-filter')));
    await tester.pumpAndSettle();

    expect(find.text('No favorite duas yet'), findsOneWidget);
  });

  testWidgets('landing page renders at 360px with elevated text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pump(
      tester,
      language: AppLanguage.bangla,
      favorites: _MemoryFavoritesRepository(),
      textScaler: const TextScaler.linear(1.3),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('landing page follows every app theme', (tester) async {
    for (final theme in AppThemePreference.values) {
      await _pump(
        tester,
        key: ValueKey(theme),
        language: AppLanguage.english,
        theme: theme,
        favorites: _MemoryFavoritesRepository(),
      );

      final chip = tester.widget<FilterChip>(
        find.byKey(const ValueKey('dua-category-daily')),
      );
      expect(chip.selectedColor, appTheme(theme).colorScheme.primaryContainer);
      expect(tester.takeException(), isNull, reason: '$theme');
    }
  });
}

Future<void> _pump(
  WidgetTester tester, {
  Key? key,
  required AppLanguage language,
  required _MemoryFavoritesRepository favorites,
  AppThemePreference theme = AppThemePreference.light,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      key: key,
      overrides: [
        appLanguageProvider.overrideWithValue(language),
        duaRepositoryProvider.overrideWithValue(_FakeDuaRepository()),
        duaFavoritesRepositoryProvider.overrideWithValue(favorites),
      ],
      child: MaterialApp(
        theme: appTheme(theme, language: language),
        home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: const DuaPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeDuaRepository implements DuaRepository {
  @override
  Future<List<DuaCategory>> loadCategories() async => const [
    DuaCategory(id: 'daily', banglaLabel: 'দৈনন্দিন', englishLabel: 'Daily'),
    DuaCategory(id: 'sleep', banglaLabel: 'ঘুম', englishLabel: 'Sleep'),
    DuaCategory(id: 'travel', banglaLabel: 'সফর', englishLabel: 'Travel'),
  ];

  @override
  Future<List<Dua>> loadAll() async => [
    _dua(
      id: 'wake',
      titleBn: 'ঘুম থেকে ওঠা',
      titleEn: 'Upon waking',
      categories: const ['daily'],
      order: 10,
    ),
    _dua(
      id: 'sleep',
      titleBn: 'ঘুমানোর আগে',
      titleEn: 'Before sleeping',
      categories: const ['sleep'],
      order: 90,
    ),
    _dua(
      id: 'travel',
      titleBn: 'সফরের দোয়া',
      titleEn: 'Travel dua',
      categories: const ['travel'],
    ),
  ];
}

Dua _dua({
  required String id,
  required String titleBn,
  required String titleEn,
  required List<String> categories,
  int? order,
}) => Dua(
  id: id,
  titleBangla: titleBn,
  titleEnglish: titleEn,
  arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
  banglaPronunciation: 'রব্বানা আতিনা ফিদ্দুনইয়া হাসানাহ',
  banglaMeaning: 'হে আমাদের রব, আমাদের কল্যাণ দিন।',
  englishTransliteration: 'Rabbana atina fid-dunya hasanah',
  englishMeaning: 'Our Lord, grant us good.',
  categoryIds: categories,
  tagsBangla: const [],
  tagsEnglish: const [],
  sources: const [
    DuaSource(
      type: DuaSourceType.quran,
      surahNumber: 2,
      ayahStart: 201,
      ayahEnd: 201,
    ),
  ],
  dailyOrder: order,
);

class _MemoryFavoritesRepository implements DuaFavoritesRepository {
  Set<String> value = {};

  @override
  Future<Set<String>> load() async => Set.unmodifiable(value);

  @override
  Future<void> save(Set<String> ids) async {
    value = {...ids};
  }
}
