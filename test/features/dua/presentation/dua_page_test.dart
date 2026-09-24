import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/features/dua/application/dua_providers.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua_repository.dart';
import 'package:quran_hifz/features/dua/domain/dua.dart';
import 'package:quran_hifz/features/dua/domain/dua_favorites_repository.dart';
import 'package:quran_hifz/features/dua/domain/dua_repository.dart';
import 'package:quran_hifz/features/dua/presentation/dua_page.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('default Dua feed is Favorite Duas with add-favorite guidance', (
    tester,
  ) async {
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository(),
    );

    expect(find.text('Favorite Duas'), findsOneWidget);
    expect(find.text('Daily Duas'), findsNothing);
    expect(find.text('Add favorite duas to show them here.'), findsOneWidget);
    expect(find.byKey(const ValueKey('dua-favorites-filter')), findsNothing);
    expect(find.byKey(const ValueKey('dua-custom-filter')), findsOneWidget);
    expect(find.byKey(const ValueKey('custom-dua-add')), findsOneWidget);
  });

  testWidgets('Bangla default feed shows localized Favorite guidance', (
    tester,
  ) async {
    await _pump(
      tester,
      language: AppLanguage.bangla,
      favorites: _MemoryFavoritesRepository(),
    );

    expect(find.text('ফেভারিট দোয়া'), findsOneWidget);
    expect(find.text('ফেভারিটে দোয়া যোগ করুন—এখানে দেখাবে।'), findsOneWidget);
  });

  testWidgets('verified favorite appears immediately in default feed', (
    tester,
  ) async {
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository({'wake'}),
    );

    expect(find.text('Upon waking'), findsOneWidget);
    expect(find.text('Before sleeping'), findsNothing);
  });

  testWidgets('Add Dua opens the five-field custom form', (tester) async {
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository(),
    );

    await tester.tap(find.byKey(const ValueKey('custom-dua-add')));
    await tester.pumpAndSettle();

    for (final key in const [
      ValueKey('custom-dua-title'),
      ValueKey('custom-dua-arabic'),
      ValueKey('custom-dua-transliteration'),
      ValueKey('custom-dua-meaning'),
      ValueKey('custom-dua-reference'),
    ]) {
      expect(find.byKey(key), findsOneWidget);
    }
  });

  testWidgets('Custom Duas mode lists custom entries independent of favorite', (
    tester,
  ) async {
    final custom = _MemoryCustomDuaRepository([
      _custom(
        id: 'custom:one',
        title: 'Waking personal dua',
        meaning: 'Travel protection',
      ),
    ]);
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository(),
      customRepository: custom,
    );

    await tester.tap(find.byKey(const ValueKey('dua-custom-filter')));
    await tester.pumpAndSettle();

    expect(find.text('Custom Duas'), findsWidgets);
    expect(find.text('Waking personal dua'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('dua-custom-filter')));
    await tester.pumpAndSettle();

    expect(find.text('Favorite Duas'), findsOneWidget);
    expect(find.text('Waking personal dua'), findsNothing);
  });

  testWidgets('global search includes verified and custom entries', (
    tester,
  ) async {
    final custom = _MemoryCustomDuaRepository([
      _custom(
        id: 'custom:one',
        title: 'Personal note',
        meaning: 'Travel protection',
      ),
    ]);
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository(),
      customRepository: custom,
    );

    await tester.enterText(
      find.byKey(const ValueKey('dua-search-field')),
      'travel',
    );
    await tester.pumpAndSettle();

    expect(find.text('Travel dua'), findsOneWidget);
    expect(find.text('Personal note'), findsOneWidget);
  });

  testWidgets('verified category search excludes custom entries', (
    tester,
  ) async {
    final custom = _MemoryCustomDuaRepository([
      _custom(
        id: 'custom:one',
        title: 'Waking personal dua',
        meaning: 'Upon waking',
      ),
    ]);
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository(),
      customRepository: custom,
    );

    await tester.tap(find.byKey(const ValueKey('dua-category-daily')));
    await tester.enterText(
      find.byKey(const ValueKey('dua-search-field')),
      'waking',
    );
    await tester.pumpAndSettle();

    expect(find.text('Upon waking'), findsOneWidget);
    expect(find.text('Waking personal dua'), findsNothing);
  });

  testWidgets('Custom mode search excludes verified entries', (tester) async {
    final custom = _MemoryCustomDuaRepository([
      _custom(
        id: 'custom:one',
        title: 'Waking personal dua',
        meaning: 'Personal waking meaning',
      ),
    ]);
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository(),
      customRepository: custom,
    );

    await tester.tap(find.byKey(const ValueKey('dua-custom-filter')));
    await tester.enterText(
      find.byKey(const ValueKey('dua-search-field')),
      'waking',
    );
    await tester.pumpAndSettle();

    expect(find.text('Waking personal dua'), findsOneWidget);
    expect(find.text('Upon waking'), findsNothing);
  });

  testWidgets('category chip still filters verified results', (tester) async {
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

  testWidgets('search empty state clears back to Favorite default', (
    tester,
  ) async {
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: _MemoryFavoritesRepository(),
    );

    await tester.enterText(
      find.byKey(const ValueKey('dua-search-field')),
      'not-present',
    );
    await tester.pumpAndSettle();

    expect(find.text('No duas found'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Favorite Duas'), findsOneWidget);
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

    expect(find.text('ফেভারিট দোয়া'), findsOneWidget);
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

      await tester.tap(find.byKey(const ValueKey('dua-custom-filter')));
      await tester.pumpAndSettle();

      final chip = tester.widget<FilterChip>(
        find.byKey(const ValueKey('dua-custom-filter')),
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
  _MemoryCustomDuaRepository? customRepository,
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
        customDuaRepositoryProvider.overrideWithValue(
          customRepository ?? _MemoryCustomDuaRepository(),
        ),
        customDuaIdGeneratorProvider.overrideWithValue(
          () => 'custom:generated',
        ),
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

CustomDua _custom({
  required String id,
  required String title,
  required String meaning,
}) => CustomDua(
  id: id,
  title: title,
  arabic: 'اللهم بارك لي',
  transliteration: 'Allahumma barik li',
  meaning: meaning,
  reference: 'My notebook',
  createdAt: DateTime.utc(2026, 9, 24),
  updatedAt: DateTime.utc(2026, 9, 24),
);

class _MemoryFavoritesRepository implements DuaFavoritesRepository {
  _MemoryFavoritesRepository([Set<String>? initial]) : value = {...?initial};

  Set<String> value;

  @override
  Future<Set<String>> load() async => Set.unmodifiable(value);

  @override
  Future<void> save(Set<String> ids) async {
    value = {...ids};
  }
}

class _MemoryCustomDuaRepository implements CustomDuaRepository {
  _MemoryCustomDuaRepository([List<CustomDua>? initial])
    : _items = {for (final dua in initial ?? const <CustomDua>[]) dua.id: dua};

  final Map<String, CustomDua> _items;

  @override
  Future<void> delete(String id) async {
    _items.remove(id);
  }

  @override
  Future<CustomDua?> getById(String id) async => _items[id];

  @override
  Future<void> insert(CustomDua dua) async {
    _items[dua.id] = dua;
  }

  @override
  Future<List<CustomDua>> listAll() async => _items.values.toList();

  @override
  Future<void> update(CustomDua dua) async {
    _items[dua.id] = dua;
  }
}
