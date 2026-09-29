import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reader_mode.dart';
import 'package:quran_hifz/features/settings/data/user_database_app_preferences_repository.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test('round trips normal Quran and app preferences', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    await repository.save(
      const AppPreferences.defaults().copyWith(
        theme: AppThemePreference.dark,
        accent: AppAccentPreference.lavender,
        quranFont: QuranFontPreference.qpcHafs,
        arabicFontSize: 34,
        arabicLineHeight: 1.7,
        banglaLineHeight: 1.6,
        banglaFontSize: 20,
        tapToShowTranslation: false,
        tapToShowBanglaWordMeaning: false,
        showPlaybackBanglaWordMeaning: false,
        showTajweedColors: false,
        defaultRepeatCount: 5,
        defaultPlaybackSpeed: 0.75,
        repeatPause: const Duration(milliseconds: 800),
        autoNextAyah: false,
        highlightActiveWord: false,
        language: AppLanguage.english,
        asrSchool: AsrSchool.standard,
        prayerCityId: 'dhaka',
        hifzMushafVariant: QuranMushafVariant.qcfV2,
        hifzFontSize: 46,
        hifzLineHeight: 1.75,
        hifzShowTajweedColors: false,
        hifzReaderMode: HifzReaderMode.continuous,
        hifzContinuousAutoScrollEnabled: true,
        hifzAutoScrollSpeed: 0.173,
      ),
    );

    final restored = await repository.load();
    expect(restored.theme, AppThemePreference.dark);
    expect(restored.accent, AppAccentPreference.lavender);
    expect(restored.quranFont, QuranFontPreference.qpcHafs);
    expect(restored.quranScript, QuranScriptPreference.uthmaniMadani);
    expect(restored.arabicFontSize, 34);
    expect(restored.arabicLineHeight, 1.7);
    expect(restored.banglaLineHeight, 1.6);
    expect(restored.banglaFontSize, 20);
    expect(restored.tapToShowTranslation, isFalse);
    expect(restored.tapToShowBanglaWordMeaning, isFalse);
    expect(restored.showPlaybackBanglaWordMeaning, isFalse);
    expect(restored.showTajweedColors, isFalse);
    expect(restored.defaultRepeatCount, 5);
    expect(restored.defaultPlaybackSpeed, 0.75);
    expect(restored.repeatPause, const Duration(milliseconds: 800));
    expect(restored.autoNextAyah, isFalse);
    expect(restored.highlightActiveWord, isFalse);
    expect(restored.language, AppLanguage.english);
    expect(restored.asrSchool, AsrSchool.standard);
    expect(restored.prayerCityId, 'dhaka');
    expect(restored.hifzMushafVariant, QuranMushafVariant.qcfV2);
    expect(restored.hifzFontSize, 46);
    expect(restored.hifzLineHeight, 1.75);
    expect(restored.hifzShowTajweedColors, isFalse);
    expect(restored.hifzReaderMode, HifzReaderMode.continuous);
    expect(restored.hifzContinuousAutoScrollEnabled, isTrue);
    expect(restored.hifzAutoScrollSpeed, 0.173);
  });

  test('legacy theme names migrate to appearance and accent', () async {
    for (final entry in <String, (AppThemePreference, AppAccentPreference)>{
      'light': (AppThemePreference.light, AppAccentPreference.sky),
      'green': (AppThemePreference.light, AppAccentPreference.mint),
      'women': (AppThemePreference.light, AppAccentPreference.rose),
      'dark': (AppThemePreference.dark, AppAccentPreference.graphite),
    }.entries) {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      final repository = UserDatabaseAppPreferencesRepository(database);
      await database.saveSetting(
        UserDatabaseAppPreferencesRepository.themeKey,
        entry.key,
      );

      final restored = await repository.load();
      expect(restored.theme, entry.value.$1, reason: entry.key);
      expect(restored.accent, entry.value.$2, reason: entry.key);
      await database.close();
    }
  });

  test('unknown Quran font falls back safely', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.quranFontKey,
      'not-a-font',
    );

    final restored = await repository.load();
    expect(restored.quranFont, QuranFontPreference.qpcHafs);
    expect(restored.quranScript, QuranScriptPreference.uthmaniMadani);
  });

  test('legacy Quran script is honored when no font is persisted', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.quranScriptKey,
      QuranScriptPreference.uthmaniMadani.name,
    );

    final restored = await repository.load();
    expect(restored.quranFont, QuranFontPreference.qpcHafs);
    expect(restored.quranScript, QuranScriptPreference.uthmaniMadani);
  });

  test('malformed numeric preferences fall back to defaults', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    for (final entry in {
      UserDatabaseAppPreferencesRepository.arabicFontSizeKey: 'nan',
      UserDatabaseAppPreferencesRepository.arabicLineHeightKey: '99',
      UserDatabaseAppPreferencesRepository.banglaLineHeightKey: '-1',
      UserDatabaseAppPreferencesRepository.banglaFontSizeKey: '99',
      UserDatabaseAppPreferencesRepository.repeatCountKey: '999',
      UserDatabaseAppPreferencesRepository.playbackSpeedKey: '99',
      UserDatabaseAppPreferencesRepository.repeatPauseMsKey: '-1',
    }.entries) {
      await database.saveSetting(entry.key, entry.value);
    }

    final restored = await repository.load();
    const defaults = AppPreferences.defaults();
    expect(restored.arabicFontSize, defaults.arabicFontSize);
    expect(restored.arabicLineHeight, defaults.arabicLineHeight);
    expect(restored.banglaLineHeight, defaults.banglaLineHeight);
    expect(restored.banglaFontSize, defaults.banglaFontSize);
    expect(restored.defaultRepeatCount, defaults.defaultRepeatCount);
    expect(restored.defaultPlaybackSpeed, defaults.defaultPlaybackSpeed);
    expect(restored.repeatPause, defaults.repeatPause);
  });

  test('null prayer city round trips as no manual city', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    await repository.save(const AppPreferences.defaults());
    final restored = await repository.load();

    expect(restored.prayerCityId, isNull);
  });

  test(
    'legacy global QCF font normalizes without overriding Hifz skin',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = UserDatabaseAppPreferencesRepository(database);

      await database.saveSetting(
        UserDatabaseAppPreferencesRepository.quranFontKey,
        'qcfV2',
      );
      await database.saveSetting(
        UserDatabaseAppPreferencesRepository.hifzMushafVariantKey,
        QuranMushafVariant.qcfV4Tajweed.name,
      );

      final restored = await repository.load();
      expect(restored.quranFont, QuranFontPreference.qpcHafs);
      expect(restored.hifzMushafVariant, QuranMushafVariant.qcfV4Tajweed);
    },
  );

  test('malformed Hifz appearance falls back to safe defaults', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzMushafVariantKey,
      'not-a-mushaf',
    );
    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzFontSizeKey,
      '100',
    );
    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzLineHeightKey,
      '0.2',
    );

    final restored = await repository.load();
    const defaults = AppPreferences.defaults();
    expect(restored.hifzMushafVariant, defaults.hifzMushafVariant);
    expect(restored.hifzFontSize, defaults.hifzFontSize);
    expect(restored.hifzLineHeight, defaults.hifzLineHeight);
  });

  test('malformed Hifz reader behavior falls back to safe defaults', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzReaderModeKey,
      'not-a-mode',
    );
    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzContinuousAutoScrollKey,
      'not-a-bool',
    );
    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzAutoScrollSpeedKey,
      'NaN',
    );

    final restored = await repository.load();
    const defaults = AppPreferences.defaults();
    expect(restored.hifzReaderMode, HifzReaderMode.page);
    expect(
      restored.hifzContinuousAutoScrollEnabled,
      defaults.hifzContinuousAutoScrollEnabled,
    );
    expect(restored.hifzAutoScrollSpeed, 0.35);
  });
}
