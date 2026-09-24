import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/hifz/presentation/hifz_appearance_sheet.dart';
import '../../../../lib/features/quran/domain/quran_font_preference.dart';
import '../../../../lib/features/settings/application/app_preferences_controller.dart';
import '../../../../lib/features/settings/domain/app_preferences.dart';
import '../../../../lib/features/settings/domain/app_preferences_repository.dart';

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  AppPreferences value = const AppPreferences.defaults();

  @override
  Future<AppPreferences> load() async => value;

  @override
  Future<void> save(AppPreferences preferences) async => value = preferences;
}

void main() {
  testWidgets(
    'shows Free Flow controls while downloaded Mushaf is unavailable',
    (tester) async {
      final repository = _MemoryPreferencesRepository()
        ..value = const AppPreferences.defaults().copyWith(
          hifzLayoutMode: HifzLayoutMode.fixedMushaf,
        );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(home: Scaffold(body: HifzAppearanceSheet())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Free Flow'), findsNothing);
      expect(find.text('Fixed Mushaf'), findsNothing);
      expect(find.byType(Slider), findsNWidgets(2));
      expect(
        find.byKey(const ValueKey('hifz-auto-scroll-enabled')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('hifz-auto-scroll-speed')),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows only the approved Hifz font choices', (tester) async {
    final repository = _MemoryPreferencesRepository()
      ..value = const AppPreferences.defaults().copyWith(
        hifzQuranFont: QuranFontPreference.notoNaskhArabic,
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: Scaffold(body: HifzAppearanceSheet())),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('hifz-appearance-font-qpcHafs')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('hifz-appearance-font-qpcHafs')),
    );
    await tester.pumpAndSettle();
    expect(find.text('QCF V2 · Pixel-perfect Madani'), findsOneWidget);
    expect(find.text('QPC Hafs · Uthmanic'), findsWidgets);
    expect(find.text('Quran Foundation IndoPak'), findsOneWidget);
    expect(find.text('PDMS Saleem Quran'), findsNothing);
    expect(find.text('Muhammadi Quran'), findsNothing);
  });

  testWidgets('keeps the selected large font size without a screen clamp', (
    tester,
  ) async {
    final repository = _MemoryPreferencesRepository()
      ..value = const AppPreferences.defaults().copyWith(hifzFontSize: 56);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: Scaffold(body: HifzAppearanceSheet())),
      ),
    );
    await tester.pumpAndSettle();

    final preview = tester.widget<Text>(
      find.byKey(const ValueKey('hifz-appearance-preview')),
    );
    expect(preview.style?.fontSize, 56);
    expect(find.text('Maximum for this screen'), findsNothing);
  });
}
