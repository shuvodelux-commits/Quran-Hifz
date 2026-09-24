import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_font_preference.dart';

void main() {
  test('Hifz exposes only the approved Quran Foundation font modes', () {
    expect(
      HifzFontPreference.values,
      orderedEquals([
        HifzFontPreference.qcfV2,
        HifzFontPreference.qpcHafs,
        HifzFontPreference.indopak,
      ]),
    );
    expect(HifzFontPreference.defaultHifz, HifzFontPreference.qcfV2);
  });

  test('Hifz modes map to the correct Quran script and rendering family', () {
    expect(HifzFontPreference.qcfV2.script.name, 'uthmaniMadani');
    expect(HifzFontPreference.qcfV2.isGlyphBased, isTrue);
    expect(HifzFontPreference.qpcHafs.isGlyphBased, isFalse);
    expect(HifzFontPreference.indopak.script.name, 'indoPak');
  });
}
