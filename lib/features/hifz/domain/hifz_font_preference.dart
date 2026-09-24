import '../../quran/domain/quran_script.dart';
import '../../quran/domain/quran_font_preference.dart';

/// The small, Hifz-only font catalog.
///
/// The normal Quran reader intentionally keeps its broader font catalog. Hifz
/// uses only Quran Foundation-oriented faces so that resizing does not change
/// the visual character of the Mushaf unexpectedly.
enum HifzFontPreference {
  qcfV2(
    'QCF V2 · Pixel-perfect Madani',
    'QCF V2',
    QuranScriptPreference.uthmaniMadani,
    true,
  ),
  qpcHafs(
    'QPC Hafs · Uthmanic',
    'KFGQPC Hafs Uthmanic',
    QuranScriptPreference.uthmaniMadani,
    false,
  ),
  indopak(
    'Quran Foundation IndoPak',
    'Quran Foundation IndoPak',
    QuranScriptPreference.indoPak,
    false,
  );

  const HifzFontPreference(
    this.label,
    this.fontFamily,
    this.script,
    this.isGlyphBased,
  );

  static const defaultHifz = HifzFontPreference.qcfV2;

  final String label;
  final String fontFamily;
  final QuranScriptPreference script;
  final bool isGlyphBased;

  /// Bridge for the current renderer. QCF V2 keeps a distinct Uthmanic
  /// renderer family here; page-glyph data can replace this bridge without
  /// changing the Hifz settings contract.
  QuranFontPreference get rendererFont => switch (this) {
    HifzFontPreference.qcfV2 => QuranFontPreference.notoNaskhArabic,
    HifzFontPreference.qpcHafs => QuranFontPreference.kfgqpcHafs,
    HifzFontPreference.indopak => QuranFontPreference.indopakNastaleeq,
  };

  static HifzFontPreference fromRendererFont(QuranFontPreference font) =>
      switch (font) {
        QuranFontPreference.indopakNastaleeq ||
        QuranFontPreference.digitalKhatt ||
        QuranFontPreference.alQalam ||
        QuranFontPreference.muhammadi ||
        QuranFontPreference.pdmsSaleem => HifzFontPreference.indopak,
        QuranFontPreference.kfgqpcHafs ||
        QuranFontPreference.notoNaskhArabic => HifzFontPreference.qpcHafs,
      };
}
