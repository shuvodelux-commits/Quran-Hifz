import '../../quran/domain/quran_mushaf_variant.dart';

export '../../quran/domain/quran_mushaf_variant.dart';

enum HifzReadingMode { regular, mushaf }

enum HifzMushafPalette { light, sepia, dark, black, p1, p2, p3, p4, p5, p6 }

extension HifzMushafPaletteRules on HifzMushafPalette {
  bool supports(QuranMushafVariant variant) {
    if (variant == QuranMushafVariant.qcfV4Tajweed) return true;
    return switch (this) {
      HifzMushafPalette.light ||
      HifzMushafPalette.sepia ||
      HifzMushafPalette.dark ||
      HifzMushafPalette.black => true,
      HifzMushafPalette.p1 ||
      HifzMushafPalette.p2 ||
      HifzMushafPalette.p3 ||
      HifzMushafPalette.p4 ||
      HifzMushafPalette.p5 ||
      HifzMushafPalette.p6 => false,
    };
  }
}

HifzMushafPalette effectivePalette(
  QuranMushafVariant variant,
  HifzMushafPalette palette,
) {
  return palette.supports(variant) ? palette : HifzMushafPalette.light;
}
