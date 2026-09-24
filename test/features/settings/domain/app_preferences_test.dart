import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test('defaults are suitable for Quran reading and repetition', () {
    const preferences = AppPreferences.defaults();

    expect(preferences.theme, AppThemePreference.light);
    expect(preferences.arabicFontSize, 27);
    expect(preferences.quranScript, QuranScriptPreference.indoPak);
    expect(preferences.arabicLineHeight, 1.2);
    expect(preferences.banglaLineHeight, 1.2);
    expect(preferences.banglaFontSize, 18);
    expect(preferences.showTranslation, isTrue);
    expect(preferences.tapToShowTranslation, isTrue);
    expect(preferences.tapToShowBanglaWordMeaning, isTrue);
    expect(preferences.showTajweedColors, isTrue);
    expect(preferences.defaultRepeatCount, 1);
    expect(preferences.defaultPlaybackSpeed, 1.0);
    expect(preferences.repeatPause, Duration.zero);
    expect(preferences.autoNextAyah, isTrue);
    expect(preferences.highlightActiveWord, isTrue);
    expect(preferences.hifzAutoScrollEnabled, isFalse);
    expect(preferences.hifzAutoScrollSpeed, HifzAutoScrollSpeed.medium);
    expect(preferences.language, AppLanguage.bangla);
    expect(preferences.asrSchool, AsrSchool.hanafi);
  });

  test('copyWith changes one field without resetting the others', () {
    const original = AppPreferences.defaults();
    final changed = original.copyWith(
      defaultRepeatCount: 10,
      quranScript: QuranScriptPreference.indoPak,
      arabicLineHeight: 2.0,
      banglaLineHeight: 1.8,
      banglaFontSize: 19,
      showTajweedColors: false,
      hifzAutoScrollEnabled: true,
      hifzAutoScrollSpeed: HifzAutoScrollSpeed.fast,
    );

    expect(changed.defaultRepeatCount, 10);
    expect(changed.quranScript, QuranScriptPreference.indoPak);
    expect(changed.arabicLineHeight, 2.0);
    expect(changed.banglaLineHeight, 1.8);
    expect(changed.banglaFontSize, 19);
    expect(changed.showTajweedColors, isFalse);
    expect(changed.hifzAutoScrollEnabled, isTrue);
    expect(changed.hifzAutoScrollSpeed, HifzAutoScrollSpeed.fast);
    expect(changed.defaultPlaybackSpeed, original.defaultPlaybackSpeed);
    expect(changed.arabicFontSize, original.arabicFontSize);
    expect(changed.autoNextAyah, original.autoNextAyah);
  });

  test('Hifz appearance defaults are independent and readable', () {
    const value = AppPreferences.defaults();

    expect(value.quranFont, QuranFontPreference.indopakNastaleeq);
    expect(value.hifzQuranFont, QuranFontPreference.notoNaskhArabic);
    expect(value.hifzFontSize, 32);
    expect(value.hifzLineHeight, 1.35);
  });

  test('copyWith keeps global and Hifz typography independent', () {
    const original = AppPreferences.defaults();
    final changed = original.copyWith(
      quranFont: QuranFontPreference.notoNaskhArabic,
      hifzFontSize: 40,
      hifzLineHeight: 2,
    );

    expect(changed.quranFont, QuranFontPreference.notoNaskhArabic);
    expect(changed.quranScript, QuranScriptPreference.uthmaniMadani);
    expect(changed.hifzQuranFont, QuranFontPreference.notoNaskhArabic);
    expect(changed.hifzFontSize, 40);
    expect(changed.hifzLineHeight, 2);
    expect(changed.arabicFontSize, original.arabicFontSize);
    expect(changed.arabicLineHeight, original.arabicLineHeight);
  });
}
