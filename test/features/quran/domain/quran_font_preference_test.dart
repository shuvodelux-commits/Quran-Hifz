import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/quran/domain/quran_script.dart';

void main() {
  test('normal Quran catalog exposes only adaptive reading fonts', () {
    expect(QuranFontPreference.values, [
      QuranFontPreference.qpcHafs,
      QuranFontPreference.indoPak,
    ]);
    expect(QuranFontPreference.defaultGlobal, QuranFontPreference.qpcHafs);
  });

  test('normal Quran fonts keep their approved typography metadata', () {
    expect(QuranFontPreference.qpcHafs.label, 'QPC Hafs / Uthmani');
    expect(QuranFontPreference.qpcHafs.fontFamily, 'QPC Hafs');
    expect(
      QuranFontPreference.qpcHafs.script,
      QuranScriptPreference.uthmaniMadani,
    );
    expect(QuranFontPreference.indoPak.label, 'IndoPak Nastaleeq');
    expect(QuranFontPreference.indoPak.fontFamily, 'IndoPak Nastaleeq');
    expect(QuranFontPreference.indoPak.script, QuranScriptPreference.indoPak);
  });

  test('QCF variants form an independent Hifz Mushaf catalog', () {
    expect(QuranMushafVariant.values, [
      QuranMushafVariant.qcfV2,
      QuranMushafVariant.qcfV4Tajweed,
    ]);
    expect(QuranMushafVariant.qcfV2.label, 'QCF V2 Madani');
    expect(QuranMushafVariant.qcfV2.mushafId, 1);
    expect(QuranMushafVariant.qcfV4Tajweed.label, 'QCF V4 Tajweed');
    expect(QuranMushafVariant.qcfV4Tajweed.mushafId, 19);
  });
}
