import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reader_mode.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reader_mode.dart';
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
  ProviderContainer containerFor(_MemoryRepository repository) {
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('changing Tajweed preference preserves Quran typography', () async {
    final repository = _MemoryRepository();
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);

    await container
        .read(appPreferencesControllerProvider.notifier)
        .setShowTajweedColors(false);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.showTajweedColors, isFalse);
    expect(state.quranFont, QuranFontPreference.qpcHafs);
    expect(state.quranScript, QuranScriptPreference.uthmaniMadani);
    expect(state.arabicLineHeight, 1.2);
  });

  test('playback Bangla meaning preference updates independently', () async {
    final repository = _MemoryRepository();
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    await controller.setShowPlaybackBanglaWordMeaning(false);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.showPlaybackBanglaWordMeaning, isFalse);
    expect(state.highlightActiveWord, isTrue);
    expect(state.showTranslation, isTrue);
    expect(repository.value.showPlaybackBanglaWordMeaning, isFalse);
  });

  test('changing repeat count preserves unrelated preferences', () async {
    final repository = _MemoryRepository();
    final container = containerFor(repository);
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
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    expect(() => controller.setDefaultRepeatCount(0), throwsArgumentError);
    expect(() => controller.setDefaultPlaybackSpeed(0), throwsArgumentError);
  });

  test('changing Quran typography preserves playback preferences', () async {
    final repository = _MemoryRepository();
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    await controller.setQuranFont(QuranFontPreference.qpcHafs);
    await controller.setArabicLineHeight(2.0);
    await controller.setBanglaLineHeight(1.8);
    await controller.setBanglaFontSize(19);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.quranFont, QuranFontPreference.qpcHafs);
    expect(state.quranScript, QuranScriptPreference.uthmaniMadani);
    expect(state.arabicLineHeight, 2.0);
    expect(state.banglaLineHeight, 1.8);
    expect(state.banglaFontSize, 19);
    expect(state.defaultRepeatCount, 1);
    expect(state.defaultPlaybackSpeed, 1.0);
  });

  test('Hifz appearance updates never mutate normal Quran typography', () async {
    final repository = _MemoryRepository();
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    await controller.setHifzMushafVariant(QuranMushafVariant.qcfV2);
    await controller.setHifzFontSize(48);
    await controller.setHifzLineHeight(1.8);
    await controller.setHifzShowTajweedColors(false);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.quranFont, QuranFontPreference.qpcHafs);
    expect(state.hifzMushafVariant, QuranMushafVariant.qcfV2);
    expect(state.hifzFontSize, 48);
    expect(state.hifzLineHeight, 1.8);
    expect(state.hifzShowTajweedColors, isFalse);

    await controller.setQuranFont(QuranFontPreference.indoPak);
    final changed = container.read(appPreferencesControllerProvider).value!;
    expect(changed.quranFont, QuranFontPreference.indoPak);
    expect(changed.hifzMushafVariant, QuranMushafVariant.qcfV2);
    expect(changed.hifzFontSize, 48);
  });

  test('rejects invalid Hifz typography ranges', () async {
    final repository = _MemoryRepository();
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    expect(() => controller.setHifzFontSize(19), throwsArgumentError);
    expect(() => controller.setHifzFontSize(57), throwsArgumentError);
    expect(() => controller.setHifzLineHeight(1.19), throwsArgumentError);
    expect(() => controller.setHifzLineHeight(2.41), throwsArgumentError);
  });


  test('Hifz reader behavior preferences update independently', () async {
    final repository = _MemoryRepository();
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    await controller.setHifzReaderMode(HifzReaderMode.continuous);
    await controller.setHifzContinuousAutoScrollEnabled(true);
    await controller.setHifzAutoScrollSpeed(0.173);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.hifzReaderMode, HifzReaderMode.continuous);
    expect(state.hifzContinuousAutoScrollEnabled, isTrue);
    expect(state.hifzAutoScrollSpeed, 0.173);
    expect(state.quranFont, QuranFontPreference.qpcHafs);
    expect(state.hifzFontSize, 32);
  });

  test('rejects invalid Hifz auto-scroll speed values', () async {
    final repository = _MemoryRepository();
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    expect(() => controller.setHifzAutoScrollSpeed(double.nan), throwsArgumentError);
    expect(() => controller.setHifzAutoScrollSpeed(-0.01), throwsArgumentError);
    expect(() => controller.setHifzAutoScrollSpeed(1.01), throwsArgumentError);
  });


  test('Hifz reader behavior preferences update independently', () async {
    final repository = _MemoryRepository();
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    await controller.setHifzReaderMode(HifzReaderMode.continuous);
    await controller.setHifzContinuousAutoScrollEnabled(true);
    await controller.setHifzAutoScrollSpeed(0.173);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.hifzReaderMode, HifzReaderMode.continuous);
    expect(state.hifzContinuousAutoScrollEnabled, isTrue);
    expect(state.hifzAutoScrollSpeed, 0.173);
    expect(state.quranFont, QuranFontPreference.qpcHafs);
    expect(state.arabicFontSize, 27);
  });

  test('rejects invalid Hifz auto-scroll speed values', () async {
    final repository = _MemoryRepository();
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    expect(() => controller.setHifzAutoScrollSpeed(double.nan), throwsArgumentError);
    expect(() => controller.setHifzAutoScrollSpeed(-0.01), throwsArgumentError);
    expect(() => controller.setHifzAutoScrollSpeed(1.01), throwsArgumentError);
  });

  test('serializes concurrent preference updates', () async {
    final repository = _DelayedRepository();
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    await Future.wait([
      controller.setQuranFont(QuranFontPreference.qpcHafs),
      controller.setBanglaFontSize(20),
    ]);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.quranFont, QuranFontPreference.qpcHafs);
    expect(state.quranScript, QuranScriptPreference.uthmaniMadani);
    expect(state.banglaFontSize, 20);
    expect(repository.value.quranFont, QuranFontPreference.qpcHafs);
    expect(repository.value.banglaFontSize, 20);
  });

  test('recovers queued updates after a save failure', () async {
    final repository = _DelayedRepository(failSaveCount: 1);
    final container = containerFor(repository);
    await container.read(appPreferencesControllerProvider.future);
    final controller = container.read(
      appPreferencesControllerProvider.notifier,
    );

    await expectLater(
      controller.setQuranFont(QuranFontPreference.qpcHafs),
      throwsStateError,
    );
    await controller.setBanglaFontSize(20);

    final state = container.read(appPreferencesControllerProvider).value!;
    expect(state.quranFont, QuranFontPreference.qpcHafs);
    expect(state.banglaFontSize, 20);
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
