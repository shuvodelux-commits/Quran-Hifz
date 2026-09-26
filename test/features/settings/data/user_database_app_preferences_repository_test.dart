import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/settings/data/user_database_app_preferences_repository.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test('round trips normal Quran and app preferences', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    await repository.save(
      const AppPreferences.defaults().copyWith(
        theme: AppThemePreference.green,
        quranFont: QuranFontPreference.kfgqpcHafs,
        arabicFontSize: 34,
        arabicLineHeight: 1.7,
        banglaLineHeight: 1.6,
        banglaFontSize: 20,
        tapToShowTranslation: false,
        tapToShowBanglaWordMeaning: false,
        showTajweedColors: false,
        defaultRepeatCount: 5,
        defaultPlaybackSpeed: 0.75,
        repeatPause: const Duration(milliseconds: 800),
        autoNextAyah: false,
        highlightActiveWord: false,
        language: AppLanguage.english,
        asrSchool: AsrSchool.standard,
        prayerCityId: 'dhaka',
      ),
    );

    final restored = await repository.load();
    expect(restored.theme, AppThemePreference.green);
    expect(restored.quranFont, QuranFontPreference.kfgqpcHafs);
    expect(restored.quranScript, QuranScriptPreference.uthmaniMadani);
    expect(restored.arabicFontSize, 34);
    expect(restored.arabicLineHeight, 1.7);
    expect(restored.banglaLineHeight, 1.6);
    expect(restored.banglaFontSize, 20);
    expect(restored.tapToShowTranslation, isFalse);
    expect(restored.tapToShowBanglaWordMeaning, isFalse);
    expect(restored.showTajweedColors, isFalse);
    expect(restored.defaultRepeatCount, 5);
    expect(restored.defaultPlaybackSpeed, 0.75);
    expect(restored.repeatPause, const Duration(milliseconds: 800));
    expect(restored.autoNextAyah, isFalse);
    expect(restored.highlightActiveWord, isFalse);
    expect(restored.language, AppLanguage.english);
    expect(restored.asrSchool, AsrSchool.standard);
    expect(restored.prayerCityId, 'dhaka');
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
    expect(restored.quranFont, QuranFontPreference.indopakNastaleeq);
    expect(restored.quranScript, QuranScriptPreference.indoPak);
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
    expect(restored.quranFont, QuranFontPreference.notoNaskhArabic);
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
}
