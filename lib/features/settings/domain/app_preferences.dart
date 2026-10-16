import '../../quran/domain/quran_font_preference.dart';
import '../../quran/domain/quran_mushaf_variant.dart';
import '../../quran/domain/quran_script.dart';

export '../../quran/domain/quran_script.dart';

enum AppThemePreference { light, green, dark, women }

enum AppLanguage { bangla, english }

enum AsrSchool { standard, hanafi }

enum HijriDayBoundary { maghrib, midnight }

class AppPreferences {
  // UI typography is independent of Quran, translation and Hifz font sizes.
  static const minUiFontScale = 0.85;
  static const maxUiFontScale = 1.50;
  static const minUiLineHeightScale = 0.90;
  static const maxUiLineHeightScale = 1.50;
  static const supportedRepeatCounts = <int>[1, 2, 3, 5, 10, 20];
  static const supportedPlaybackSpeeds = <double>[0.5, 0.75, 1.0, 1.25];
  static const minArabicLineHeight = 1.2;
  static const maxArabicLineHeight = 2.5;
  static const minBanglaLineHeight = 1.2;
  static const maxBanglaLineHeight = 2.2;
  static const minBanglaFontSize = 12.0;
  static const maxBanglaFontSize = 28.0;
  static const minHifzFontSize = 20.0;
  static const maxHifzFontSize = 56.0;
  static const minHifzLineHeight = 1.20;
  static const maxHifzLineHeight = 2.40;

  const AppPreferences({
    required this.theme,
    this.uiFontScale = 1.0,
    this.uiLineHeightScale = 1.0,
    this.followSystemTextSize = false,
    required this.quranScript,
    required this.quranFont,
    required this.arabicFontSize,
    required this.arabicLineHeight,
    required this.hifzMushafVariant,
    required this.hifzFontSize,
    required this.hifzLineHeight,
    required this.hifzShowTajweedColors,
    required this.banglaLineHeight,
    required this.banglaFontSize,
    required this.showTranslation,
    required this.tapToShowTranslation,
    required this.tapToShowBanglaWordMeaning,
    this.showPlaybackBanglaWordMeaning = true,
    required this.showTajweedColors,
    required this.defaultRepeatCount,
    required this.defaultPlaybackSpeed,
    required this.repeatPause,
    required this.autoNextAyah,
    required this.highlightActiveWord,
    required this.language,
    required this.asrSchool,
    this.prayerCityId,
    this.hijriDayBoundary = HijriDayBoundary.maghrib,
    this.hijriDateCorrection = 0,
    this.hijriCorrectionScope,
  });

  const AppPreferences.defaults()
    : theme = AppThemePreference.light,
      uiFontScale = 1.0,
      uiLineHeightScale = 1.0,
      followSystemTextSize = false,
      quranScript = QuranScriptPreference.uthmaniMadani,
      quranFont = QuranFontPreference.defaultGlobal,
      arabicFontSize = 27,
      arabicLineHeight = 1.2,
      hifzMushafVariant = QuranMushafVariant.qcfV4Tajweed,
      hifzFontSize = 32,
      hifzLineHeight = 1.35,
      hifzShowTajweedColors = true,
      banglaLineHeight = 1.2,
      banglaFontSize = 18,
      showTranslation = true,
      tapToShowTranslation = true,
      tapToShowBanglaWordMeaning = true,
      showPlaybackBanglaWordMeaning = true,
      showTajweedColors = true,
      defaultRepeatCount = 1,
      defaultPlaybackSpeed = 1.0,
      repeatPause = Duration.zero,
      autoNextAyah = true,
      highlightActiveWord = true,
      language = AppLanguage.bangla,
      asrSchool = AsrSchool.hanafi,
      prayerCityId = null,
      hijriDayBoundary = HijriDayBoundary.maghrib,
      hijriDateCorrection = 0,
      hijriCorrectionScope = null;

  final AppThemePreference theme;
  final double uiFontScale;
  final double uiLineHeightScale;
  final bool followSystemTextSize;
  final QuranScriptPreference quranScript;
  final QuranFontPreference quranFont;
  final double arabicFontSize;
  final double arabicLineHeight;
  final QuranMushafVariant hifzMushafVariant;
  final double hifzFontSize;
  final double hifzLineHeight;
  final bool hifzShowTajweedColors;
  final double banglaLineHeight;
  final double banglaFontSize;
  final bool showTranslation;
  final bool tapToShowTranslation;
  final bool tapToShowBanglaWordMeaning;
  final bool showPlaybackBanglaWordMeaning;
  final bool showTajweedColors;
  final int defaultRepeatCount;
  final double defaultPlaybackSpeed;
  final Duration repeatPause;
  final bool autoNextAyah;
  final bool highlightActiveWord;
  final AppLanguage language;
  final AsrSchool asrSchool;
  final String? prayerCityId;
  final HijriDayBoundary hijriDayBoundary;
  final int hijriDateCorrection;
  final String? hijriCorrectionScope;

  AppPreferences copyWith({
    AppThemePreference? theme,
    double? uiFontScale,
    double? uiLineHeightScale,
    bool? followSystemTextSize,
    QuranScriptPreference? quranScript,
    QuranFontPreference? quranFont,
    double? arabicFontSize,
    double? arabicLineHeight,
    QuranMushafVariant? hifzMushafVariant,
    double? hifzFontSize,
    double? hifzLineHeight,
    bool? hifzShowTajweedColors,
    double? banglaLineHeight,
    double? banglaFontSize,
    bool? showTranslation,
    bool? tapToShowTranslation,
    bool? tapToShowBanglaWordMeaning,
    bool? showPlaybackBanglaWordMeaning,
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
    HijriDayBoundary? hijriDayBoundary,
    int? hijriDateCorrection,
    String? hijriCorrectionScope,
    bool clearHijriCorrectionScope = false,
  }) {
    final nextQuranFont =
        quranFont ??
        (quranScript == null
            ? this.quranFont
            : quranScript == QuranScriptPreference.indoPak
            ? QuranFontPreference.indoPak
            : QuranFontPreference.qpcHafs);
    return AppPreferences(
      theme: theme ?? this.theme,
      uiFontScale: uiFontScale ?? this.uiFontScale,
      uiLineHeightScale: uiLineHeightScale ?? this.uiLineHeightScale,
      followSystemTextSize:
          followSystemTextSize ?? this.followSystemTextSize,
      quranScript: nextQuranFont.script,
      quranFont: nextQuranFont,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      arabicLineHeight: arabicLineHeight ?? this.arabicLineHeight,
      hifzMushafVariant: hifzMushafVariant ?? this.hifzMushafVariant,
      hifzFontSize: hifzFontSize ?? this.hifzFontSize,
      hifzLineHeight: hifzLineHeight ?? this.hifzLineHeight,
      hifzShowTajweedColors:
          hifzShowTajweedColors ?? this.hifzShowTajweedColors,
      banglaLineHeight: banglaLineHeight ?? this.banglaLineHeight,
      banglaFontSize: banglaFontSize ?? this.banglaFontSize,
      showTranslation: showTranslation ?? this.showTranslation,
      tapToShowTranslation: tapToShowTranslation ?? this.tapToShowTranslation,
      tapToShowBanglaWordMeaning:
          tapToShowBanglaWordMeaning ?? this.tapToShowBanglaWordMeaning,
      showPlaybackBanglaWordMeaning:
          showPlaybackBanglaWordMeaning ?? this.showPlaybackBanglaWordMeaning,
      showTajweedColors: showTajweedColors ?? this.showTajweedColors,
      defaultRepeatCount: defaultRepeatCount ?? this.defaultRepeatCount,
      defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
      repeatPause: repeatPause ?? this.repeatPause,
      autoNextAyah: autoNextAyah ?? this.autoNextAyah,
      highlightActiveWord: highlightActiveWord ?? this.highlightActiveWord,
      language: language ?? this.language,
      asrSchool: asrSchool ?? this.asrSchool,
      prayerCityId: clearPrayerCity ? null : prayerCityId ?? this.prayerCityId,
      hijriDayBoundary: hijriDayBoundary ?? this.hijriDayBoundary,
      hijriDateCorrection: hijriDateCorrection ?? this.hijriDateCorrection,
      hijriCorrectionScope: clearHijriCorrectionScope
          ? null
          : hijriCorrectionScope ?? this.hijriCorrectionScope,
    );
  }
}
