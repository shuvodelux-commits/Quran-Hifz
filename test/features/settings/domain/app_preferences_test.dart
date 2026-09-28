import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reader_mode.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test('defaults are suitable for Quran reading and repetition', () {
    const preferences = AppPreferences.defaults();

    expect(preferences.theme, AppThemePreference.light);
    expect(preferences.quranFont, QuranFontPreference.qpcHafs);
    expect(preferences.quranScript, QuranScriptPreference.uthmaniMadani);
    expect(preferences.arabicFontSize, 27);
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
    expect(preferences.language, AppLanguage.bangla);
    expect(preferences.asrSchool, AsrSchool.hanafi);
    expect(preferences.hifzMushafVariant, QuranMushafVariant.qcfV4Tajweed);
    expect(preferences.hifzFontSize, 32);
    expect(preferences.hifzLineHeight, 1.35);
    expect(preferences.hifzShowTajweedColors, isTrue);
    expect(preferences.hifzReaderMode, HifzReaderMode.page);
    expect(preferences.hifzContinuousAutoScrollEnabled, isFalse);
    expect(preferences.hifzAutoScrollSpeed, 0.35);
  });

  test(
    'copyWith changes reading settings without resetting unrelated values',
    () {
      const original = AppPreferences.defaults();
      final changed = original.copyWith(
        quranFont: QuranFontPreference.qpcHafs,
        defaultRepeatCount: 10,
        arabicLineHeight: 2.0,
        banglaLineHeight: 1.8,
        banglaFontSize: 19,
        showTajweedColors: false,
      );

      expect(changed.quranFont, QuranFontPreference.qpcHafs);
      expect(changed.quranScript, QuranScriptPreference.uthmaniMadani);
      expect(changed.defaultRepeatCount, 10);
      expect(changed.arabicLineHeight, 2.0);
      expect(changed.banglaLineHeight, 1.8);
      expect(changed.banglaFontSize, 19);
      expect(changed.showTajweedColors, isFalse);
      expect(changed.defaultPlaybackSpeed, original.defaultPlaybackSpeed);
      expect(changed.arabicFontSize, original.arabicFontSize);
      expect(changed.autoNextAyah, original.autoNextAyah);
    },
  );

  test('legacy script selection still derives a compatible Quran font', () {
    const original = AppPreferences.defaults();

    final uthmani = original.copyWith(
      quranScript: QuranScriptPreference.uthmaniMadani,
    );
    expect(uthmani.quranFont, QuranFontPreference.qpcHafs);
    expect(uthmani.quranScript, QuranScriptPreference.uthmaniMadani);

    final indoPak = uthmani.copyWith(
      quranScript: QuranScriptPreference.indoPak,
    );
    expect(indoPak.quranFont, QuranFontPreference.indoPak);
    expect(indoPak.quranScript, QuranScriptPreference.indoPak);
  });

  test('normal Quran and Hifz appearance copy independently', () {
    const original = AppPreferences.defaults();
    final hifzChanged = original.copyWith(
      hifzMushafVariant: QuranMushafVariant.qcfV2,
      hifzFontSize: 48,
      hifzLineHeight: 1.8,
      hifzShowTajweedColors: false,
      hifzReaderMode: HifzReaderMode.continuous,
      hifzContinuousAutoScrollEnabled: true,
      hifzAutoScrollSpeed: 0.173,
    );
    expect(hifzChanged.quranFont, QuranFontPreference.qpcHafs);
    expect(hifzChanged.hifzMushafVariant, QuranMushafVariant.qcfV2);
    expect(hifzChanged.hifzFontSize, 48);
    expect(hifzChanged.hifzLineHeight, 1.8);
    expect(hifzChanged.hifzShowTajweedColors, isFalse);
    expect(hifzChanged.hifzReaderMode, HifzReaderMode.continuous);
    expect(hifzChanged.hifzContinuousAutoScrollEnabled, isTrue);
    expect(hifzChanged.hifzAutoScrollSpeed, 0.173);

    final quranChanged = hifzChanged.copyWith(
      quranFont: QuranFontPreference.indoPak,
    );
    expect(quranChanged.quranFont, QuranFontPreference.indoPak);
    expect(quranChanged.hifzMushafVariant, QuranMushafVariant.qcfV2);
    expect(quranChanged.hifzFontSize, 48);
    expect(quranChanged.hifzReaderMode, HifzReaderMode.continuous);
    expect(quranChanged.hifzAutoScrollSpeed, 0.173);
  });

}
