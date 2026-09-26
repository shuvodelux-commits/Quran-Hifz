import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/quran/domain/quran_script.dart';

void main() {
  test('catalog exposes exactly the four approved Quran font choices', () {
    expect(QuranFontPreference.values, [
      QuranFontPreference.qpcHafs,
      QuranFontPreference.indoPak,
      QuranFontPreference.qcfV2,
      QuranFontPreference.qcfV4Tajweed,
    ]);
    expect(QuranFontPreference.defaultGlobal, QuranFontPreference.qpcHafs);
    expect(QuranFontPreference.defaultHifz, QuranFontPreference.qpcHafs);
  });

  test('font choices map to the correct script renderer and Mushaf id', () {
    final expected = <
      QuranFontPreference,
      ({
        String label,
        QuranScriptPreference script,
        QuranFontRenderKind renderKind,
        int mushafId,
        String? fontFamily,
      })
    >{
      QuranFontPreference.qpcHafs: (
        label: 'QPC Hafs / Uthmani',
        script: QuranScriptPreference.uthmaniMadani,
        renderKind: QuranFontRenderKind.adaptiveUnicode,
        mushafId: 5,
        fontFamily: 'QPC Hafs',
      ),
      QuranFontPreference.indoPak: (
        label: 'IndoPak Nastaleeq',
        script: QuranScriptPreference.indoPak,
        renderKind: QuranFontRenderKind.adaptiveUnicode,
        mushafId: 3,
        fontFamily: 'IndoPak Nastaleeq',
      ),
      QuranFontPreference.qcfV2: (
        label: 'QCF V2 Madani',
        script: QuranScriptPreference.uthmaniMadani,
        renderKind: QuranFontRenderKind.strictQcfV2,
        mushafId: 1,
        fontFamily: null,
      ),
      QuranFontPreference.qcfV4Tajweed: (
        label: 'QCF V4 Tajweed',
        script: QuranScriptPreference.uthmaniMadani,
        renderKind: QuranFontRenderKind.strictQcfV4Tajweed,
        mushafId: 19,
        fontFamily: null,
      ),
    };

    for (final font in QuranFontPreference.values) {
      final mapping = expected[font]!;
      expect(font.label, mapping.label);
      expect(font.script, mapping.script);
      expect(font.renderKind, mapping.renderKind);
      expect(font.mushafId, mapping.mushafId);
      expect(font.fontFamily, mapping.fontFamily);
    }
  });
}
