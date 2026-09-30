import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reader_mode.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_appearance_sheet.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

void main() {
  testWidgets('appearance sheet owns only Hifz Mushaf typography', (
    tester,
  ) async {
    final repository = _MemoryPreferencesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: HifzAppearanceSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('QCF V2 Madani'), findsOneWidget);
    expect(find.text('QCF V4 Tajweed'), findsOneWidget);
    expect(find.text('QPC Hafs / Uthmani'), findsNothing);
    expect(find.text('IndoPak Nastaleeq'), findsNothing);

    final sizeSlider = tester.widget<Slider>(
      find.byKey(const ValueKey('hifz-font-size-slider')),
    );
    expect(sizeSlider.min, 20);
    expect(sizeSlider.max, 56);
    sizeSlider.onChanged?.call(48);
    await tester.pumpAndSettle();

    expect(repository.value.hifzFontSize, 48);
    expect(repository.value.quranFont, QuranFontPreference.qpcHafs);

    await tester.tap(find.text('QCF V2 Madani'));
    await tester.pumpAndSettle();
    expect(repository.value.hifzMushafVariant, QuranMushafVariant.qcfV2);
    expect(repository.value.quranFont, QuranFontPreference.qpcHafs);

    await tester.tap(find.byKey(const ValueKey('hifz-appearance-reset')));
    await tester.pumpAndSettle();
    expect(
      repository.value.hifzMushafVariant,
      QuranMushafVariant.qcfV4Tajweed,
    );
    expect(repository.value.hifzFontSize, 32);
    expect(repository.value.hifzLineHeight, 1.35);
    expect(repository.value.hifzShowTajweedColors, isTrue);
  });


  testWidgets('continuous reading controls use precise persisted speed', (
    tester,
  ) async {
    final repository = _MemoryPreferencesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: HifzAppearanceSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('hifz-reader-mode-page')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('hifz-reader-mode-continuous')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('hifz-continuous-auto-scroll-switch')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('hifz-reader-mode-continuous')),
    );
    await tester.pumpAndSettle();
    expect(repository.value.hifzReaderMode, HifzReaderMode.continuous);

    final autoScroll = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('hifz-continuous-auto-scroll-switch')),
    );
    autoScroll.onChanged?.call(true);
    await tester.pumpAndSettle();
    expect(repository.value.hifzContinuousAutoScrollEnabled, isTrue);

    final speed = tester.widget<Slider>(
      find.byKey(const ValueKey('hifz-auto-scroll-speed-slider')),
    );
    expect(speed.min, 0);
    expect(speed.max, 1);
    expect(speed.divisions, isNull);
    speed.onChanged?.call(0.173);
    await tester.pumpAndSettle();
    expect(repository.value.hifzAutoScrollSpeed, 0.173);

    await tester.ensureVisible(
      find.byKey(const ValueKey('hifz-appearance-reset')),
    );
    await tester.tap(find.byKey(const ValueKey('hifz-appearance-reset')));
    await tester.pumpAndSettle();

    expect(repository.value.hifzReaderMode, HifzReaderMode.page);
    expect(repository.value.hifzContinuousAutoScrollEnabled, isFalse);
    expect(repository.value.hifzAutoScrollSpeed, 0.35);
  });

  testWidgets('appearance sheet stays scrollable with enlarged system text', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(body: HifzAppearanceSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
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
