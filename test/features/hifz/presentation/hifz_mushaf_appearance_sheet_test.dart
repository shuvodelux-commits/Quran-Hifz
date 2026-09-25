import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reading_mode.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_mushaf_appearance_sheet.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

void main() {
  testWidgets('QPC shows common palettes and P1 through P6', (tester) async {
    final repository = _MemoryPreferencesRepository()
      ..value = const AppPreferences.defaults().copyWith(
        hifzMushafVariant: HifzMushafVariant.qpcV4Tajweed,
      );

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    for (final label in const [
      'Light',
      'Sepia',
      'Dark',
      'Black',
      'P1',
      'P2',
      'P3',
      'P4',
      'P5',
      'P6',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('Digital exposes only common palettes', (tester) async {
    final repository = _MemoryPreferencesRepository()
      ..value = const AppPreferences.defaults().copyWith(
        hifzMushafVariant: HifzMushafVariant.digitalKhattV2,
      );

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    for (final label in const ['Light', 'Sepia', 'Dark', 'Black']) {
      expect(find.text(label), findsOneWidget);
    }
    for (final label in const ['P1', 'P2', 'P3', 'P4', 'P5', 'P6']) {
      expect(find.text(label), findsNothing);
    }
  });

  testWidgets(
    'Digital visually normalizes saved P6 to Light without overwriting it',
    (tester) async {
      final repository = _MemoryPreferencesRepository()
        ..value = const AppPreferences.defaults().copyWith(
          hifzMushafVariant: HifzMushafVariant.digitalKhattV2,
          hifzMushafPalette: HifzMushafPalette.p6,
        );

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      final light = tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('hifz-mushaf-palette-light')),
      );
      expect(light.selected, isTrue);
      expect(repository.value.hifzMushafPalette, HifzMushafPalette.p6);

      await tester.tap(find.text('Sepia'));
      await tester.pumpAndSettle();

      expect(repository.value.hifzMushafPalette, HifzMushafPalette.sepia);
    },
  );
}

Widget _app(_MemoryPreferencesRepository repository) {
  return ProviderScope(
    overrides: [appPreferencesRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: Scaffold(body: HifzMushafAppearanceSheet())),
  );
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
