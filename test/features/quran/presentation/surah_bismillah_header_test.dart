import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/domain/bismillah_text.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/surah_bismillah_header.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

void main() {
  testWidgets('shows Bismillah for a normal Surah', (tester) async {
    await tester.pumpWidget(_app(2));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('surah-bismillah-2')), findsOneWidget);
    expect(find.text(BismillahText.uthmani), findsOneWidget);
  });

  testWidgets('renders Bismillah inside a clean rounded surface card', (
    tester,
  ) async {
    await tester.pumpWidget(_app(2));
    await tester.pumpAndSettle();

    final card = tester.widget<Container>(
      find.byKey(const ValueKey('surah-bismillah-card-2')),
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(
      decoration.color,
      appTheme(AppThemePreference.light).colorScheme.surfaceContainerLow,
    );
    expect(decoration.borderRadius, BorderRadius.circular(11));
    expect(find.text(BismillahText.uthmani), findsOneWidget);
  });

  testWidgets('does not duplicate Al-Fatihah or add Bismillah to At-Tawbah', (
    tester,
  ) async {
    await tester.pumpWidget(_app(1));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('surah-bismillah-1')), findsNothing);

    await tester.pumpWidget(_app(9));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('surah-bismillah-9')), findsNothing);
  });

  testWidgets('IndoPak Bismillah uses the Quran font without synthetic bold', (
    tester,
  ) async {
    final preferences = _MemoryPreferencesRepository()
      ..value = const AppPreferences.defaults().copyWith(
        quranScript: QuranScriptPreference.indoPak,
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(preferences),
          tajweedQuranTextAvailableProvider.overrideWith((ref) async => false),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SurahBismillahHeader(surahNumber: 2)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final style = DefaultTextStyle.of(
      tester.element(find.text(BismillahText.indoPak)),
    ).style;
    expect(style.fontFamily, 'Indopak Nastaleeq');
    expect(style.fontWeight, FontWeight.w400);
  });
}

Widget _app(int surahNumber) => ProviderScope(
  overrides: [
    appPreferencesRepositoryProvider.overrideWithValue(
      _MemoryPreferencesRepository()
        ..value = const AppPreferences.defaults().copyWith(
          quranScript: QuranScriptPreference.uthmaniMadani,
        ),
    ),
    tajweedQuranTextAvailableProvider.overrideWith((ref) async => false),
  ],
  child: MaterialApp(
    theme: appTheme(AppThemePreference.light),
    home: Scaffold(body: SurahBismillahHeader(surahNumber: surahNumber)),
  ),
);

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  AppPreferences value = const AppPreferences.defaults();

  @override
  Future<AppPreferences> load() async => value;

  @override
  Future<void> save(AppPreferences preferences) async {
    value = preferences;
  }
}
