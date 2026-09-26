import 'quran_script.dart';

enum QuranFontRenderKind { adaptiveUnicode, strictQcfV2, strictQcfV4Tajweed }

/// Quran body-font choices available to the Quran reader.
///
/// Adaptive Unicode options own a static Flutter font family. Strict QCF
/// options use page-specific Quran Foundation fonts and therefore do not.
enum QuranFontPreference {
  qpcHafs(
    'QPC Hafs / Uthmani',
    'QPC Hafs',
    QuranScriptPreference.uthmaniMadani,
    QuranFontRenderKind.adaptiveUnicode,
    5,
  ),
  indoPak(
    'IndoPak Nastaleeq',
    'IndoPak Nastaleeq',
    QuranScriptPreference.indoPak,
    QuranFontRenderKind.adaptiveUnicode,
    3,
  ),
  qcfV2(
    'QCF V2 Madani',
    null,
    QuranScriptPreference.uthmaniMadani,
    QuranFontRenderKind.strictQcfV2,
    1,
  ),
  qcfV4Tajweed(
    'QCF V4 Tajweed',
    null,
    QuranScriptPreference.uthmaniMadani,
    QuranFontRenderKind.strictQcfV4Tajweed,
    19,
  );

  const QuranFontPreference(
    this.label,
    this.fontFamily,
    this.script,
    this.renderKind,
    this.mushafId,
  );

  static const defaultGlobal = QuranFontPreference.qpcHafs;
  final String label;
  final String? fontFamily;
  final QuranScriptPreference script;
  final QuranFontRenderKind renderKind;
  final int mushafId;

  bool get isAdaptive => renderKind == QuranFontRenderKind.adaptiveUnicode;
  bool get isStrict => !isAdaptive;
}
