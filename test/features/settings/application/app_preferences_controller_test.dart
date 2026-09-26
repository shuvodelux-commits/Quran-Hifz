import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reading_mode.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

class _MemoryRepository implements AppPreferencesRepository {
  AppPreferences value = const AppPreferences.defaults();
  final writes = <String>[];

  @override
  Future<AppPreferences> load() async => value;

  @override
  Future<void> save(AppPreferences preferences) async {
    value = preferences;
    writes.add('save');
  }
}

void main() {
  test('Hifz layout defaults to free flow and persists fixed Mushaf', () async {
    final repository = _MemoryRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    expect(container.read(hifzLayoutModeProvider), HifzLayoutMode.freeFlow);

    await container
        .read(appPreferencesControllerProvider.notifier)
        .setHifzLayoutMode(HifzLayoutMode.fixedMushaf);

    expect(container.read(hifzLayoutModeProvider), HifzLayoutMode.fixedMushaf);
    expect(repository.value.hifzLayoutMode, HifzLayoutMode.fixedMushaf);
  });

  test('persists Hifz reading mode and Mushaf variant', () async {
    final repository = _MemoryRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    await controller.setHifzReadingMode(HifzReadingMode.mushaf);
    await controller.setHifzMushafVariant(HifzMushafVariant.qpcV4Tajweed);
    await controller.setHifzMushafPalette(HifzMushafPalette.p6);

    expect(container.read(hifzReadingModeProvider), HifzReadingMode.mushaf);
    expect(
      container.read(hifzMushafVariantProvider),
      HifzMushafVariant.qpcV4Tajweed,
    );
    expect(container.read(hifzMushafPaletteProvider), HifzMushafPalette.p6);
    expect(repository.value.hifzReadingMode, HifzReadingMode.mushaf);
  });

  test(
    'effective Digital Khatt palette normalizes without overwriting saved P6',
    () async {
      final repository = _MemoryRepository()
        ..value = const AppPreferences.defaults().copyWith(
          hifzMushafPalette: HifzMushafPalette.p6,
        );
      final container = ProviderContainer(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appPreferencesControllerProvider.future);
      await container
          .read(appPreferencesControllerProvider.notifier)
          .setHifzMushafVariant(HifzMushafVariant.digitalKhattV2);

      expect(
        container.read(effectiveHifzMushafPaletteProvider),
        HifzMushafPalette.light,
      );
      expect(container.read(hifzMushafPaletteProvider), HifzMushafPalette.p6);
      expect(repository.value.hifzMushafPalette, HifzMushafPalette.p6);
    },
  );

  test('changing Tajweed preference preserves Quran typography', () async {
    final repository = _MemoryRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setShowTajweedColors(false);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.showTajweedColors, isFalse);
    expect(state.quranScript, QuranScriptPreference.uthmaniMadani);
    expect(state.arabicLineHeight, 1.2);
  });

  test('changing repeat count preserves unrelated preferences', () async {
    final repository = _MemoryRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setDefaultRepeatCount(10);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.defaultRepeatCount, 10);
    expect(state.defaultPlaybackSpeed, 1.0);
    expect(state.showTranslation, isTrue);
    expect(repository.writes, ['save']);
  });

  test('rejects unsupported repeat and speed values', () async {
    final repository = _MemoryRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    expect(
      () => container
          .read(appPreferencesControllerProvider.notifier)
          .setDefaultRepeatCount(0),
      throwsArgumentError,
    );
    expect(
      () => container
          .read(appPreferencesControllerProvider.notifier)
          .setDefaultPlaybackSpeed(0),
      throwsArgumentError,
    );
  });

  test('changing Quran typography preserves playback preferences', () async {
    final repository = _MemoryRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );
    await controller.setQuranScript(QuranScriptPreference.indoPak);
    await controller.setArabicLineHeight(2.0);
    await controller.setBanglaLineHeight(1.8);
    await controller.setBanglaFontSize(19);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.quranScript, QuranScriptPreference.indoPak);
    expect(state.arabicLineHeight, 2.0);
    expect(state.banglaLineHeight, 1.8);
    expect(state.banglaFontSize, 19);
    expect(state.defaultRepeatCount, 1);
    expect(state.defaultPlaybackSpeed, 1.0);
  });

  test('global font selection derives its compatible script', () async {
    final repository = _MemoryRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setQuranFont(QuranFontPreference.qcfV4Tajweed);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.quranFont, QuranFontPreference.qcfV4Tajweed);
    expect(state.quranScript, QuranScriptPreference.uthmaniMadani);
    expect(repository.value.quranFont, QuranFontPreference.qcfV4Tajweed);
  });

  test('Hifz typography rejects values outside its supported ranges', () async {
    final repository = _MemoryRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    expect(() => controller.setHifzFontSize(19.9), throwsArgumentError);
    expect(() => controller.setHifzFontSize(56.1), throwsArgumentError);
    expect(() => controller.setHifzLineHeight(1.19), throwsArgumentError);
    expect(() => controller.setHifzLineHeight(2.41), throwsArgumentError);
  });

  test('Hifz typography rejects non-finite values', () async {
    final repository = _MemoryRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    for (final value in <double>[
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(() => controller.setHifzFontSize(value), throwsArgumentError);
      expect(() => controller.setHifzLineHeight(value), throwsArgumentError);
    }
  });

  test('global and Hifz typography changes do not alter one another', () async {
    final repository = _MemoryRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );
    await controller.setQuranFont(QuranFontPreference.indoPak);
    await controller.setArabicFontSize(36);
    await controller.setArabicLineHeight(1.8);
    final afterGlobal = container.read(appPreferencesControllerProvider).value!;
    expect(afterGlobal.hifzQuranFont, QuranFontPreference.qpcHafs);
    expect(afterGlobal.hifzFontSize, 32);
    expect(afterGlobal.hifzLineHeight, 1.35);

    await controller.setHifzQuranFont(QuranFontPreference.qcfV2);
    await controller.setHifzFontSize(40);
    await controller.setHifzLineHeight(2);
    final afterHifz = container.read(appPreferencesControllerProvider).value!;
    expect(afterHifz.quranFont, QuranFontPreference.indoPak);
    expect(afterHifz.quranScript, QuranScriptPreference.indoPak);
    expect(afterHifz.arabicFontSize, 36);
    expect(afterHifz.arabicLineHeight, 1.8);
    expect(afterHifz.hifzQuranFont, QuranFontPreference.qcfV2);
    expect(afterHifz.hifzFontSize, 40);
    expect(afterHifz.hifzLineHeight, 2);
    expect(repository.value, same(afterHifz));
  });

  test('serializes concurrent global and Hifz typography updates', () async {
    final repository = _DelayedRepository();
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );
    await Future.wait([
      controller.setQuranFont(QuranFontPreference.indoPak),
      controller.setArabicFontSize(34),
      controller.setArabicLineHeight(1.7),
      controller.setHifzQuranFont(QuranFontPreference.qcfV2),
      controller.setHifzFontSize(42),
      controller.setHifzLineHeight(1.9),
    ]);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.quranFont, QuranFontPreference.indoPak);
    expect(state.quranScript, QuranScriptPreference.indoPak);
    expect(state.arabicFontSize, 34);
    expect(state.arabicLineHeight, 1.7);
    expect(state.hifzQuranFont, QuranFontPreference.qcfV2);
    expect(state.hifzFontSize, 42);
    expect(state.hifzLineHeight, 1.9);
    expect(repository.value.quranFont, QuranFontPreference.indoPak);
    expect(repository.value.hifzQuranFont, QuranFontPreference.qcfV2);
  });

  test('recovers queued updates after a save failure', () async {
    final repository = _DelayedRepository(failSaveCount: 1);
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );
    await expectLater(
      controller.setQuranFont(QuranFontPreference.indoPak),
      throwsStateError,
    );
    await controller.setHifzQuranFont(QuranFontPreference.qcfV2);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.quranFont, QuranFontPreference.qpcHafs);
    expect(state.hifzQuranFont, QuranFontPreference.qcfV2);
    expect(repository.value.hifzQuranFont, QuranFontPreference.qcfV2);
  });
}

class _DelayedRepository extends _MemoryRepository {
  _DelayedRepository({this.failSaveCount = 0});

  int failSaveCount;

  @override
  Future<void> save(AppPreferences preferences) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (failSaveCount > 0) {
      failSaveCount--;
      throw StateError('save failed');
    }
    await super.save(preferences);
  }
}
