import '../../../core/database/user_database.dart';
import '../../quran/domain/quran_font_preference.dart';
import '../../quran/domain/quran_mushaf_variant.dart';
import '../domain/app_preferences.dart';
import '../domain/app_preferences_repository.dart';

class UserDatabaseAppPreferencesRepository implements AppPreferencesRepository {
  UserDatabaseAppPreferencesRepository(this._database);

  static const themeKey = 'theme_mode';
  static const quranScriptKey = 'quran_script';
  static const quranFontKey = 'quran_font';
  static const arabicFontSizeKey = 'arabic_font_size';
  static const arabicLineHeightKey = 'arabic_line_height';
  static const hifzMushafVariantKey = 'hifz_mushaf_variant_v2';
  static const hifzFontSizeKey = 'hifz_font_size_v2';
  static const hifzLineHeightKey = 'hifz_line_height_v2';
  static const hifzShowTajweedColorsKey = 'hifz_tajweed_colors_v2';
  static const banglaLineHeightKey = 'bangla_line_height';
  static const banglaFontSizeKey = 'bangla_font_size';
  static const showTranslationKey = 'show_translation';
  static const tapToShowTranslationKey = 'tap_to_show_translation';
  static const tapToShowBanglaWordMeaningKey =
      'tap_to_show_bangla_word_meaning';
  static const showPlaybackBanglaWordMeaningKey =
      'show_playback_bangla_word_meaning';
  static const showTajweedColorsKey = 'show_tajweed_colors';
  static const repeatCountKey = 'default_repeat_count';
  static const playbackSpeedKey = 'default_playback_speed';
  static const repeatPauseMsKey = 'repeat_pause_ms';
  static const autoNextAyahKey = 'auto_next_ayah';
  static const highlightActiveWordKey = 'highlight_active_word';
  static const languageKey = 'app_language';
  static const asrSchoolKey = 'asr_school';
  static const prayerCityKey = 'prayer_city_id';

  final UserDatabase _database;

  @override
  Future<AppPreferences> load() async {
    const defaults = AppPreferences.defaults();

    final values = await Future.wait([
      _database.getSetting(themeKey),
      _database.getSetting(quranScriptKey),
      _database.getSetting(arabicFontSizeKey),
      _database.getSetting(arabicLineHeightKey),
      _database.getSetting(banglaLineHeightKey),
      _database.getSetting(showTranslationKey),
      _database.getSetting(showTajweedColorsKey),
      _database.getSetting(repeatCountKey),
      _database.getSetting(playbackSpeedKey),
      _database.getSetting(repeatPauseMsKey),
      _database.getSetting(autoNextAyahKey),
      _database.getSetting(highlightActiveWordKey),
      _database.getSetting(languageKey),
      _database.getSetting(asrSchoolKey),
      _database.getSetting(prayerCityKey),
      _database.getSetting(tapToShowTranslationKey),
      _database.getSetting(tapToShowBanglaWordMeaningKey),
      _database.getSetting(banglaFontSizeKey),
      _database.getSetting(quranFontKey),
      _database.getSetting(hifzMushafVariantKey),
      _database.getSetting(hifzFontSizeKey),
      _database.getSetting(hifzLineHeightKey),
      _database.getSetting(hifzShowTajweedColorsKey),
      _database.getSetting(showPlaybackBanglaWordMeaningKey),
    ]);

    final theme = switch (values[0]) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      'green' => AppThemePreference.green,
      'women' => AppThemePreference.women,
      _ => defaults.theme,
    };
    final legacyQuranScript = switch (values[1]) {
      'indoPak' => QuranScriptPreference.indoPak,
      'uthmaniMadani' => QuranScriptPreference.uthmaniMadani,
      _ => defaults.quranScript,
    };
    final quranFont = _fontFromName(
      values[18],
      fallback: values[18] == null
          ? (legacyQuranScript == QuranScriptPreference.indoPak
                ? QuranFontPreference.indoPak
                : QuranFontPreference.qpcHafs)
          : QuranFontPreference.defaultGlobal,
    );
    final fontSize = double.tryParse(values[2] ?? '');
    final arabicLineHeight = double.tryParse(values[3] ?? '');
    final banglaLineHeight = double.tryParse(values[4] ?? '');
    final repeatCount = int.tryParse(values[7] ?? '');
    final speed = double.tryParse(values[8] ?? '');
    final pauseMs = int.tryParse(values[9] ?? '');
    final banglaFontSize = double.tryParse(values[17] ?? '');
    final hifzFontSize = double.tryParse(values[20] ?? '');
    final hifzLineHeight = double.tryParse(values[21] ?? '');

    return AppPreferences(
      theme: theme,
      quranScript: quranFont.script,
      quranFont: quranFont,
      arabicFontSize: fontSize != null && fontSize >= 20 && fontSize <= 56
          ? fontSize
          : defaults.arabicFontSize,
      arabicLineHeight:
          arabicLineHeight != null &&
              arabicLineHeight >= AppPreferences.minArabicLineHeight &&
              arabicLineHeight <= AppPreferences.maxArabicLineHeight
          ? arabicLineHeight
          : defaults.arabicLineHeight,
      hifzMushafVariant: _mushafVariantFromName(
        values[19],
        defaults.hifzMushafVariant,
      ),
      hifzFontSize:
          _isFiniteInRange(
            hifzFontSize,
            AppPreferences.minHifzFontSize,
            AppPreferences.maxHifzFontSize,
          )
          ? hifzFontSize!
          : defaults.hifzFontSize,
      hifzLineHeight:
          _isFiniteInRange(
            hifzLineHeight,
            AppPreferences.minHifzLineHeight,
            AppPreferences.maxHifzLineHeight,
          )
          ? hifzLineHeight!
          : defaults.hifzLineHeight,
      hifzShowTajweedColors: _parseBool(
        values[22],
        defaults.hifzShowTajweedColors,
      ),
      banglaLineHeight:
          banglaLineHeight != null &&
              banglaLineHeight >= AppPreferences.minBanglaLineHeight &&
              banglaLineHeight <= AppPreferences.maxBanglaLineHeight
          ? banglaLineHeight
          : defaults.banglaLineHeight,
      banglaFontSize:
          banglaFontSize != null &&
              banglaFontSize >= AppPreferences.minBanglaFontSize &&
              banglaFontSize <= AppPreferences.maxBanglaFontSize
          ? banglaFontSize
          : defaults.banglaFontSize,
      showTranslation: _parseBool(values[5], defaults.showTranslation),
      tapToShowTranslation: _parseBool(
        values[15],
        defaults.tapToShowTranslation,
      ),
      tapToShowBanglaWordMeaning: _parseBool(
        values[16],
        defaults.tapToShowBanglaWordMeaning,
      ),
      showPlaybackBanglaWordMeaning: _parseBool(
        values[23],
        defaults.showPlaybackBanglaWordMeaning,
      ),
      showTajweedColors: _parseBool(values[6], defaults.showTajweedColors),
      defaultRepeatCount:
          repeatCount != null &&
              AppPreferences.supportedRepeatCounts.contains(repeatCount)
          ? repeatCount
          : defaults.defaultRepeatCount,
      defaultPlaybackSpeed:
          speed != null &&
              AppPreferences.supportedPlaybackSpeeds.contains(speed)
          ? speed
          : defaults.defaultPlaybackSpeed,
      repeatPause: Duration(
        milliseconds: pauseMs != null && pauseMs >= 0 && pauseMs <= 10000
            ? pauseMs
            : defaults.repeatPause.inMilliseconds,
      ),
      autoNextAyah: _parseBool(values[10], defaults.autoNextAyah),
      highlightActiveWord: _parseBool(values[11], defaults.highlightActiveWord),
      language: values[12] == 'english'
          ? AppLanguage.english
          : AppLanguage.bangla,
      asrSchool: values[13] == 'standard'
          ? AsrSchool.standard
          : AsrSchool.hanafi,
      prayerCityId: values[14]?.isNotEmpty == true ? values[14] : null,
    );
  }

  @override
  Future<void> save(AppPreferences preferences) async {
    await _database.transaction(() async {
      await _database.saveSetting(themeKey, preferences.theme.name);
      await _database.saveSetting(
        quranScriptKey,
        preferences.quranFont.script.name,
      );
      await _database.saveSetting(quranFontKey, preferences.quranFont.name);
      await _database.saveSetting(
        arabicFontSizeKey,
        preferences.arabicFontSize.toString(),
      );
      await _database.saveSetting(
        arabicLineHeightKey,
        preferences.arabicLineHeight.toString(),
      );
      await _database.saveSetting(
        hifzMushafVariantKey,
        preferences.hifzMushafVariant.name,
      );
      await _database.saveSetting(
        hifzFontSizeKey,
        preferences.hifzFontSize.toString(),
      );
      await _database.saveSetting(
        hifzLineHeightKey,
        preferences.hifzLineHeight.toString(),
      );
      await _database.saveSetting(
        hifzShowTajweedColorsKey,
        preferences.hifzShowTajweedColors.toString(),
      );
      await _database.saveSetting(
        banglaLineHeightKey,
        preferences.banglaLineHeight.toString(),
      );
      await _database.saveSetting(
        banglaFontSizeKey,
        preferences.banglaFontSize.toString(),
      );
      await _database.saveSetting(
        showTranslationKey,
        preferences.showTranslation.toString(),
      );
      await _database.saveSetting(
        tapToShowTranslationKey,
        preferences.tapToShowTranslation.toString(),
      );
      await _database.saveSetting(
        tapToShowBanglaWordMeaningKey,
        preferences.tapToShowBanglaWordMeaning.toString(),
      );
      await _database.saveSetting(
        showPlaybackBanglaWordMeaningKey,
        preferences.showPlaybackBanglaWordMeaning.toString(),
      );
      await _database.saveSetting(
        showTajweedColorsKey,
        preferences.showTajweedColors.toString(),
      );
      await _database.saveSetting(
        repeatCountKey,
        preferences.defaultRepeatCount.toString(),
      );
      await _database.saveSetting(
        playbackSpeedKey,
        preferences.defaultPlaybackSpeed.toString(),
      );
      await _database.saveSetting(
        repeatPauseMsKey,
        preferences.repeatPause.inMilliseconds.toString(),
      );
      await _database.saveSetting(
        autoNextAyahKey,
        preferences.autoNextAyah.toString(),
      );
      await _database.saveSetting(
        highlightActiveWordKey,
        preferences.highlightActiveWord.toString(),
      );
      await _database.saveSetting(languageKey, preferences.language.name);
      await _database.saveSetting(asrSchoolKey, preferences.asrSchool.name);
      await _database.saveSetting(
        prayerCityKey,
        preferences.prayerCityId ?? '',
      );
    });
  }

  bool _parseBool(String? raw, bool fallback) {
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    return fallback;
  }

  bool _isFiniteInRange(double? value, double minimum, double maximum) {
    return value != null &&
        value.isFinite &&
        value >= minimum &&
        value <= maximum;
  }

  QuranMushafVariant _mushafVariantFromName(
    String? raw,
    QuranMushafVariant fallback,
  ) {
    for (final variant in QuranMushafVariant.values) {
      if (variant.name == raw) return variant;
    }
    return fallback;
  }

  QuranFontPreference _fontFromName(
    String? raw, {
    required QuranFontPreference fallback,
  }) {
    for (final font in QuranFontPreference.values) {
      if (font.name == raw) return font;
    }
    return switch (raw) {
      'pdmsSaleem' ||
      'indopakNastaleeq' ||
      'digitalKhatt' ||
      'alQalam' ||
      'muhammadi' => QuranFontPreference.indoPak,
      'kfgqpcHafs' ||
      'notoNaskhArabic' ||
      'qcfV2' ||
      'qcfV4Tajweed' => QuranFontPreference.qpcHafs,
      _ => fallback,
    };
  }
}
