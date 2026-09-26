import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/quran/domain/quran_script.dart';

void main() {
  test('IndoPak Nastaleeq is the default regular Quran font', () {
    expect(
      QuranFontPreference.defaultGlobal,
      QuranFontPreference.indopakNastaleeq,
    );
    expect(
      QuranFontPreference.defaultGlobal.script,
      QuranScriptPreference.indoPak,
    );
  });

  test('Quran font catalog keeps the supported mappings', () {
    final expected =
        <
          QuranFontPreference,
          ({String label, String fontFamily, QuranScriptPreference script})
        >{
          QuranFontPreference.pdmsSaleem: (
            label: 'PDMS Saleem Quran',
            fontFamily: 'PDMS Saleem Quran',
            script: QuranScriptPreference.indoPak,
          ),
          QuranFontPreference.indopakNastaleeq: (
            label: 'Indopak Nastaleeq',
            fontFamily: 'Indopak Nastaleeq',
            script: QuranScriptPreference.indoPak,
          ),
          QuranFontPreference.digitalKhatt: (
            label: 'DigitalKhatt IndoPak',
            fontFamily: 'Quran DigitalKhatt IndoPak',
            script: QuranScriptPreference.indoPak,
          ),
          QuranFontPreference.alQalam: (
            label: 'Al Qalam Quran Majeed',
            fontFamily: 'AlQalamQuranMajeed',
            script: QuranScriptPreference.indoPak,
          ),
          QuranFontPreference.muhammadi: (
            label: 'Muhammadi Quran',
            fontFamily: 'Muhammadi Quranic',
            script: QuranScriptPreference.indoPak,
          ),
          QuranFontPreference.kfgqpcHafs: (
            label: 'KFGQPC Hafs',
            fontFamily: 'KFGQPC Hafs Uthmanic',
            script: QuranScriptPreference.uthmaniMadani,
          ),
          QuranFontPreference.notoNaskhArabic: (
            label: 'Noto Naskh Arabic',
            fontFamily: 'Noto Naskh Arabic',
            script: QuranScriptPreference.uthmaniMadani,
          ),
        };

    expect(QuranFontPreference.values, orderedEquals(expected.keys));
    for (final font in QuranFontPreference.values) {
      final mapping = expected[font]!;
      expect(font.label, mapping.label);
      expect(font.fontFamily, mapping.fontFamily);
      expect(font.script, mapping.script);
    }
  });
}
