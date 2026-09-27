import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/domain/bismillah_text.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';
import 'package:quran_hifz/features/settings/presentation/settings_page.dart';

void main() {
  testWidgets('playback dropdowns expose exactly the supported values', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
          indoPakQuranTextAvailableProvider.overrideWith((ref) async => true),
          tajweedQuranTextAvailableProvider.overrideWith((ref) async => true),
        ],
        child: const MaterialApp(home: SettingsPage(currentSurahNumber: 1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('তাজবিদের রং'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('অডিও সেটিংস'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final repeatDropdown = find.byType(DropdownButtonFormField<int>);
    expect(repeatDropdown, findsOneWidget);
    await tester.ensureVisible(repeatDropdown);
    await tester.tap(repeatDropdown);
    await tester.pumpAndSettle();

    for (final count in AppPreferences.supportedRepeatCounts) {
      expect(find.text('$count×'), findsWidgets);
    }
    expect(find.text('4×'), findsNothing);

    await tester.tap(find.text('5×').last);
    await tester.pumpAndSettle();

    final speedDropdown = find.byType(DropdownButtonFormField<double>);
    expect(speedDropdown, findsOneWidget);
    await tester.ensureVisible(speedDropdown);
    await tester.tap(speedDropdown);
    await tester.pumpAndSettle();

    for (final speed in AppPreferences.supportedPlaybackSpeeds) {
      expect(find.text('${speed}×'), findsWidgets);
    }
    expect(find.text('2.0×'), findsNothing);
  });

  testWidgets('reading settings expose a Bangla font-size control', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
          indoPakQuranTextAvailableProvider.overrideWith((ref) async => true),
          tajweedQuranTextAvailableProvider.overrideWith((ref) async => true),
        ],
        child: const MaterialApp(home: SettingsPage(currentSurahNumber: 1)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.textContaining('বাংলা ফন্ট সাইজ'),
      find.byType(ListView),
      const Offset(0, -250),
    );

    expect(find.textContaining('বাংলা ফন্ট সাইজ'), findsOneWidget);
  });

  testWidgets(
    'IndoPak preview uses Quran typography without changing UI text',
    (tester) async {
      final preferences = _MemoryPreferencesRepository()
        ..value = const AppPreferences.defaults().copyWith(
          quranScript: QuranScriptPreference.indoPak,
        );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesRepositoryProvider.overrideWithValue(preferences),
            indoPakQuranTextAvailableProvider.overrideWith((ref) async => true),
            tajweedQuranTextAvailableProvider.overrideWith((ref) async => true),
          ],
          child: const MaterialApp(home: SettingsPage(currentSurahNumber: 1)),
        ),
      );
      await tester.pumpAndSettle();

      final preview = find.text(BismillahText.indoPak);
      await tester.ensureVisible(preview);
      final previewStyle = DefaultTextStyle.of(tester.element(preview)).style;
      expect(previewStyle.fontFamily, 'IndoPak Nastaleeq');
      expect(previewStyle.fontWeight, FontWeight.w400);
      expect(
        DefaultTextStyle.of(
          tester.element(find.text('সেটিংস')),
        ).style.fontFamily,
        isNot('IndoPak Nastaleeq'),
      );
    },
  );

  testWidgets('regular Quran settings expose every shared Quran face', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
          indoPakQuranTextAvailableProvider.overrideWith((ref) async => true),
          tajweedQuranTextAvailableProvider.overrideWith((ref) async => true),
        ],
        child: const MaterialApp(home: SettingsPage(currentSurahNumber: 1)),
      ),
    );
    await tester.pumpAndSettle();

    final fontDropdown = find.byType(
      DropdownButtonFormField<QuranFontPreference>,
    );
    expect(fontDropdown, findsOneWidget);
    await tester.tap(fontDropdown);
    await tester.pumpAndSettle();
    for (final font in QuranFontPreference.values) {
      expect(find.text(font.label), findsWidgets);
    }
    expect(find.text('QCF V2 Madani'), findsNothing);
    expect(find.text('QCF V4 Tajweed'), findsNothing);
  });

  testWidgets('font selection derives script and renders its selected face', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
          indoPakQuranTextAvailableProvider.overrideWith((ref) async => true),
          tajweedQuranTextAvailableProvider.overrideWith((ref) async => true),
        ],
        child: const MaterialApp(home: SettingsPage(currentSurahNumber: 1)),
      ),
    );
    await tester.pumpAndSettle();

    final fontDropdown = find.byType(
      DropdownButtonFormField<QuranFontPreference>,
    );
    await tester.tap(fontDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('QPC Hafs / Uthmani').last);
    await tester.pumpAndSettle();

    final uthmaniPreview = find.text(BismillahText.uthmani);
    final uthmaniContainer = ProviderScope.containerOf(
      tester.element(uthmaniPreview),
    );
    expect(
      uthmaniContainer.read(quranScriptPreferenceProvider),
      QuranScriptPreference.uthmaniMadani,
    );
    expect(
      DefaultTextStyle.of(tester.element(uthmaniPreview)).style.fontFamily,
      'QPC Hafs',
    );

    await tester.tap(fontDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('IndoPak Nastaleeq').last);
    await tester.pumpAndSettle();

    final indoPakPreview = find.text(BismillahText.indoPak);
    final indoPakContainer = ProviderScope.containerOf(
      tester.element(indoPakPreview),
    );
    expect(
      indoPakContainer.read(quranScriptPreferenceProvider),
      QuranScriptPreference.indoPak,
    );
    expect(
      DefaultTextStyle.of(tester.element(indoPakPreview)).style.fontFamily,
      'IndoPak Nastaleeq',
    );
  });
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
