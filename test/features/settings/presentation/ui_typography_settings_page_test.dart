import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';
import 'package:quran_hifz/features/settings/presentation/ui_typography_settings_page.dart';

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  AppPreferences value = const AppPreferences.defaults().copyWith(
    language: AppLanguage.english,
  );
  int saves = 0;

  @override
  Future<AppPreferences> load() async => value;

  @override
  Future<void> save(AppPreferences preferences) async {
    saves++;
    value = preferences;
  }
}

void main() {
  Future<void> openPage(
    WidgetTester tester,
    _MemoryPreferencesRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const UiTypographySettingsPage(),
                  ),
                ),
                child: const Text('Open settings'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(find.text('Font settings'), findsOneWidget);
  }

  testWidgets('preview is live while Cancel leaves saved text unchanged', (
    tester,
  ) async {
    final repository = _MemoryPreferencesRepository();
    await openPage(tester, repository);

    final sample = find.textContaining('Choose a comfortable text size');
    final normalTextSize = tester.widget<Text>(sample).style!.fontSize;

    tester
        .widget<Slider>(find.byKey(const ValueKey('ui-font-scale-slider')))
        .onChanged!(1.25);
    tester
        .widget<Slider>(find.byKey(const ValueKey('ui-line-height-slider')))
        .onChanged!(1.2);
    await tester.pump();

    final previewText = tester.widget<Text>(sample);
    expect(previewText.style!.fontSize, greaterThan(normalTextSize!));
    expect(repository.saves, 0);

    await tester.tap(find.byKey(const ValueKey('ui-typography-cancel')));
    await tester.pumpAndSettle();
    expect(repository.value.uiFontScale, 1.0);
    expect(repository.value.uiLineHeightScale, 1.0);
    expect(repository.saves, 0);
  });

  testWidgets('Save persists UI preferences but not Quran/Hifz typography', (
    tester,
  ) async {
    final repository = _MemoryPreferencesRepository();
    await openPage(tester, repository);

    tester
        .widget<Slider>(find.byKey(const ValueKey('ui-font-scale-slider')))
        .onChanged!(1.25);
    tester
        .widget<Slider>(find.byKey(const ValueKey('ui-line-height-slider')))
        .onChanged!(1.2);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ui-follow-system-font')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('ui-typography-save')));
    await tester.pumpAndSettle();

    expect(repository.saves, 1);
    expect(repository.value.uiFontScale, 1.25);
    expect(repository.value.uiLineHeightScale, 1.2);
    expect(repository.value.followSystemTextSize, isTrue);
    expect(repository.value.arabicFontSize, 27);
    expect(repository.value.banglaFontSize, 18);
    expect(repository.value.hifzFontSize, 32);
  });

  testWidgets('Reset changes preview only until Save', (tester) async {
    final repository = _MemoryPreferencesRepository()
      ..value = const AppPreferences.defaults().copyWith(
        language: AppLanguage.english,
        uiFontScale: 1.30,
        uiLineHeightScale: 1.25,
        followSystemTextSize: true,
      );
    await openPage(tester, repository);

    await tester.tap(find.byKey(const ValueKey('ui-typography-reset')));
    await tester.pump();
    expect(
      tester.widget<Slider>(
        find.byKey(const ValueKey('ui-font-scale-slider')),
      ).value,
      1.0,
    );
    expect(repository.value.uiFontScale, 1.30);
    expect(repository.saves, 0);
  });

  testWidgets('font preview supports a compact 320dp phone', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _MemoryPreferencesRepository();
    await openPage(tester, repository);
    tester
        .widget<Slider>(find.byKey(const ValueKey('ui-font-scale-slider')))
        .onChanged!(1.5);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('ui-typography-save')), findsOneWidget);
  });
}
