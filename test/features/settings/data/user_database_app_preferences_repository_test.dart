import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reading_mode.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/settings/data/user_database_app_preferences_repository.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test('persists green theme and separate tap reveal settings', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);
    await repository.save(
      const AppPreferences.defaults().copyWith(
        theme: AppThemePreference.green,
        tapToShowTranslation: true,
        tapToShowBanglaWordMeaning: false,
      ),
    );
    final restored = await repository.load();
    expect(restored.theme, AppThemePreference.green);
    expect(restored.tapToShowTranslation, isTrue);
    expect(restored.tapToShowBanglaWordMeaning, isFalse);
  });
  test('persists Tajweed and Quran typography preferences together', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    final preferences = const AppPreferences.defaults().copyWith(
      quranScript: QuranScriptPreference.indoPak,
      arabicLineHeight: 1.9,
      banglaLineHeight: 1.7,
      banglaFontSize: 18,
      showTajweedColors: false,
    );

    await repository.save(preferences);
    final restored = await repository.load();

    expect(restored.quranScript, QuranScriptPreference.indoPak);
    expect(restored.arabicLineHeight, 1.9);
    expect(restored.banglaLineHeight, 1.7);
    expect(restored.banglaFontSize, 18);
    expect(restored.showTajweedColors, isFalse);
  });

  test(
    'persists Asr school, Bangladesh city, language, and women theme',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = UserDatabaseAppPreferencesRepository(database);
      await repository.save(
        const AppPreferences.defaults().copyWith(
          asrSchool: AsrSchool.standard,
          prayerCityId: '44',
          language: AppLanguage.english,
          theme: AppThemePreference.women,
        ),
      );
      final restored = await repository.load();
      expect(restored.asrSchool, AsrSchool.standard);
      expect(restored.prayerCityId, '44');
      expect(restored.language, AppLanguage.english);
      expect(restored.theme, AppThemePreference.women);
      await repository.save(restored.copyWith(clearPrayerCity: true));
      expect((await repository.load()).prayerCityId, isNull);
    },
  );

  test('round trips independent global and Hifz typography', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    await repository.save(
      const AppPreferences.defaults().copyWith(
        quranFont: QuranFontPreference.notoNaskhArabic,
        quranScript: QuranScriptPreference.uthmaniMadani,
        hifzQuranFont: QuranFontPreference.alQalam,
        hifzLayoutMode: HifzLayoutMode.fixedMushaf,
        hifzFontSize: 40,
        hifzLineHeight: 2,
        hifzAutoScrollEnabled: true,
        hifzAutoScrollSpeed: HifzAutoScrollSpeed.fast,
      ),
    );

    final restored = await repository.load();
    expect(restored.quranFont, QuranFontPreference.notoNaskhArabic);
    expect(restored.quranScript, QuranScriptPreference.uthmaniMadani);
    expect(restored.hifzQuranFont, QuranFontPreference.alQalam);
    expect(restored.hifzLayoutMode, HifzLayoutMode.fixedMushaf);
    expect(restored.hifzFontSize, 40);
    expect(restored.hifzLineHeight, 2);
    expect(restored.hifzAutoScrollEnabled, isTrue);
    expect(restored.hifzAutoScrollSpeed, HifzAutoScrollSpeed.fast);
    expect(restored.arabicFontSize, 27);
    expect(restored.arabicLineHeight, 1.2);
  });

  test('round trips Mushaf mode and QPC palette', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    await repository.save(
      const AppPreferences.defaults().copyWith(
        hifzReadingMode: HifzReadingMode.mushaf,
        hifzMushafVariant: HifzMushafVariant.qpcV4Tajweed,
        hifzMushafPalette: HifzMushafPalette.p6,
      ),
    );

    final restored = await repository.load();
    expect(restored.hifzReadingMode, HifzReadingMode.mushaf);
    expect(restored.hifzMushafVariant, HifzMushafVariant.qpcV4Tajweed);
    expect(restored.hifzMushafPalette, HifzMushafPalette.p6);
  });

  test('unknown Mushaf preference values fail closed to defaults', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);

    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzReadingModeKey,
      'removed-mode',
    );
    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzMushafVariantKey,
      'removed-variant',
    );
    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzMushafPaletteKey,
      'removed-palette',
    );

    final restored = await repository.load();
    expect(restored.hifzReadingMode, HifzReadingMode.regular);
    expect(restored.hifzMushafVariant, HifzMushafVariant.qpcV4Tajweed);
    expect(restored.hifzMushafPalette, HifzMushafPalette.light);
  });

  test('migrates legacy quran script when no global font is saved', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);
    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.quranScriptKey,
      'uthmaniMadani',
    );

    final restored = await repository.load();
    expect(restored.quranFont, QuranFontPreference.notoNaskhArabic);
    expect(restored.quranScript, QuranScriptPreference.uthmaniMadani);
  });

  test('migrates legacy IndoPak script to the global IndoPak face', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);
    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.quranScriptKey,
      'indoPak',
    );

    final restored = await repository.load();
    expect(restored.quranFont, QuranFontPreference.indopakNastaleeq);
    expect(restored.quranScript, QuranScriptPreference.indoPak);
  });

  test(
    'unknown persisted global font falls back to Indopak Nastaleeq',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = UserDatabaseAppPreferencesRepository(database);
      await database.saveSetting(
        UserDatabaseAppPreferencesRepository.quranFontKey,
        'removed_font',
      );

      final restored = await repository.load();
      expect(restored.quranFont, QuranFontPreference.indopakNastaleeq);
      expect(restored.quranScript, QuranScriptPreference.indoPak);
    },
  );

  test('unknown persisted Hifz font falls back to PDMS', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);
    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzQuranFontKey,
      'removed_font',
    );

    final restored = await repository.load();
    expect(restored.hifzQuranFont, QuranFontPreference.notoNaskhArabic);
  });

  test('unknown persisted Hifz layout falls back to Free Flow', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseAppPreferencesRepository(database);
    await database.saveSetting(
      UserDatabaseAppPreferencesRepository.hifzLayoutModeKey,
      'removed_layout',
    );

    final restored = await repository.load();
    expect(restored.hifzLayoutMode, HifzLayoutMode.freeFlow);
  });

  test(
    'malformed, out-of-range, and non-finite Hifz numbers use defaults',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = UserDatabaseAppPreferencesRepository(database);
      for (final raw in <String>[
        'not-a-number',
        '19.9',
        '56.1',
        '1.19',
        '2.41',
        'NaN',
        'Infinity',
        '-Infinity',
      ]) {
        await database.saveSetting(
          UserDatabaseAppPreferencesRepository.hifzFontSizeKey,
          raw,
        );
        await database.saveSetting(
          UserDatabaseAppPreferencesRepository.hifzLineHeightKey,
          raw,
        );

        final restored = await repository.load();
        expect(restored.hifzFontSize, 32, reason: raw);
        expect(restored.hifzLineHeight, 1.35, reason: raw);
      }
    },
  );
}
