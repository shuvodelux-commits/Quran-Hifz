import '../../quran/domain/quran_font_preference.dart';
import '../../quran/domain/quran_script.dart';

export '../../quran/domain/quran_script.dart';

enum AppThemePreference { light, green, dark, women }

enum AppLanguage { bangla, english }

enum AsrSchool { standard, hanafi }

class AppPreferences {
  static const supportedRepeatCounts = <int>[1, 2, 3, 5, 10, 20];
  static const supportedPlaybackSpeeds = <double>[0.5, 0.75, 1.0, 1.25];
  static const minArabicLineHeight = 1.2;
  static const maxArabicLineHeight = 2.5;
  static const minBanglaLineHeight = 1.2;
  static const maxBanglaLineHeight = 2.2;
  static const minBanglaFontSize = 12.0;
  static const maxBanglaFontSize = 28.0;

  const AppPreferences({
    required this.theme,
    required this.quranScript,
    required this.quranFont,
    required this.arabicFontSize,
    required this.arabicLineHeight,
    required this.banglaLineHeight,
    required this.banglaFontSize,
    required this.showTranslation,
    required this.tapToShowTranslation,
    required this.tapToShowBanglaWordMeaning,
    required this.showTajweedColors,
    required this.defaultRepeatCount,
    required this.defaultPlaybackSpeed,
    required this.repeatPause,
    required this.autoNextAyah,
    required this.highlightActiveWord,
    required this.language,
    required this.asrSchool,
    this.prayerCityId,
  });

  const AppPreferences.defaults()
    : theme = AppThemePreference.light,
      quranScript = QuranScriptPreference.indoPak,
      quranFont = QuranFontPreference.defaultGlobal,
      arabicFontSize = 27,
      arabicLineHeight = 1.2,
      banglaLineHeight = 1.2,
      banglaFontSize = 18,
      showTranslation = true,
      tapToShowTranslation = true,
      tapToShowBanglaWordMeaning = true,
      showTajweedColors = true,
      defaultRepeatCount = 1,
      defaultPlaybackSpeed = 1.0,
      repeatPause = Duration.zero,
      autoNextAyah = true,
      highlightActiveWord = true,
      language = AppLanguage.bangla,
      asrSchool = AsrSchool.hanafi,
      prayerCityId = null;

  final AppThemePreference theme;
  final QuranScriptPreference quranScript;
  final QuranFontPreference quranFont;
  final double arabicFontSize;
  final double arabicLineHeight;
  final double banglaLineHeight;
  final double banglaFontSize;
  final bool showTranslation;
  final bool tapToShowTranslation;
  final bool tapToShowBanglaWordMeaning;
  final bool showTajweedColors;
  final int defaultRepeatCount;
  final double defaultPlaybackSpeed;
  final Duration repeatPause;
  final bool autoNextAyah;
  final bool highlightActiveWord;
  final AppLanguage language;
  final AsrSchool asrSchool;
  final String? prayerCityId;

  AppPreferences copyWith({
    AppThemePreference? theme,
    QuranScriptPreference? quranScript,
    QuranFontPreference? quranFont,
    double? arabicFontSize,
    double? arabicLineHeight,
    double? banglaLineHeight,
    double? banglaFontSize,
    bool? showTranslation,
    bool? tapToShowTranslation,
    bool? tapToShowBanglaWordMeaning,
    bool? showTajweedColors,
    int? defaultRepeatCount,
    double? defaultPlaybackSpeed,
    Duration? repeatPause,
    bool? autoNextAyah,
    bool? highlightActiveWord,
    AppLanguage? language,
    AsrSchool? asrSchool,
    String? prayerCityId,
    bool clearPrayerCity = false,
  }) {
    final nextQuranFont =
        quranFont ??
        (quranScript == null
            ? this.quranFont
            : quranScript == QuranScriptPreference.indoPak
            ? QuranFontPreference.defaultGlobal
            : QuranFontPreference.notoNaskhArabic);
    return AppPreferences(
      theme: theme ?? this.theme,
      quranScript: nextQuranFont.script,
      quranFont: nextQuranFont,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      arabicLineHeight: arabicLineHeight ?? this.arabicLineHeight,
      banglaLineHeight: banglaLineHeight ?? this.banglaLineHeight,
      banglaFontSize: banglaFontSize ?? this.banglaFontSize,
      showTranslation: showTranslation ?? this.showTranslation,
      tapToShowTranslation: tapToShowTranslation ?? this.tapToShowTranslation,
      tapToShowBanglaWordMeaning:
          tapToShowBanglaWordMeaning ?? this.tapToShowBanglaWordMeaning,
      showTajweedColors: showTajweedColors ?? this.showTajweedColors,
      defaultRepeatCount: defaultRepeatCount ?? this.defaultRepeatCount,
      defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
      repeatPause: repeatPause ?? this.repeatPause,
      autoNextAyah: autoNextAyah ?? this.autoNextAyah,
      highlightActiveWord: highlightActiveWord ?? this.highlightActiveWord,
      language: language ?? this.language,
      asrSchool: asrSchool ?? this.asrSchool,
      prayerCityId: clearPrayerCity ? null : prayerCityId ?? this.prayerCityId,
    );
  }
}
