import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reading_mode.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_reading_mode_selector.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

void main() {
  testWidgets('offers Regular and Mushaf without replacing layout mode', (
    tester,
  ) async {
    final repository = _MemoryPreferencesRepository();

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('Regular'), findsOneWidget);
    expect(find.text('Mushaf'), findsOneWidget);
    expect(repository.value.hifzLayoutMode, HifzLayoutMode.freeFlow);
  });

  testWidgets('Mushaf selection exposes the two approved variant labels', (
    tester,
  ) async {
    final repository = _MemoryPreferencesRepository();

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mushaf'));
    await tester.pumpAndSettle();

    expect(repository.value.hifzReadingMode, HifzReadingMode.mushaf);
    expect(find.text('QPC V4 Tajweed (Preview)'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('hifz-mushaf-variant-selector')),
    );
    await tester.pumpAndSettle();

    expect(find.text('QPC V4 Tajweed (Preview)'), findsWidgets);
    expect(find.text('Digital Khatt V2'), findsOneWidget);
  });
}

Widget _app(_MemoryPreferencesRepository repository) {
  return ProviderScope(
    overrides: [appPreferencesRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: Scaffold(body: HifzReadingModeSelector())),
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
