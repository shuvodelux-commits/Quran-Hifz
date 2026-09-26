import 'quran_mushaf_variant.dart';

enum QuranMushafPalette { light, sepia, dark, black, p1, p2, p3, p4, p5, p6 }

extension QuranMushafPaletteRules on QuranMushafPalette {
  bool supports(QuranMushafVariant variant) {
    if (variant == QuranMushafVariant.qcfV4Tajweed) return true;
    return switch (this) {
      QuranMushafPalette.light ||
      QuranMushafPalette.sepia ||
      QuranMushafPalette.dark ||
      QuranMushafPalette.black => true,
      QuranMushafPalette.p1 ||
      QuranMushafPalette.p2 ||
      QuranMushafPalette.p3 ||
      QuranMushafPalette.p4 ||
      QuranMushafPalette.p5 ||
      QuranMushafPalette.p6 => false,
    };
  }
}

QuranMushafPalette effectiveQuranMushafPalette(
  QuranMushafVariant variant,
  QuranMushafPalette palette,
) {
  return palette.supports(variant) ? palette : QuranMushafPalette.light;
}
