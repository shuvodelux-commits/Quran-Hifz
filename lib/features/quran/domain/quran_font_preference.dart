import 'quran_script.dart';

/// Adaptive Quran fonts available to the normal Quran reader.
///
/// Page-specific QCF Mushaf fonts are intentionally modelled separately by
/// QuranMushafVariant so Hifz appearance cannot change the normal reader.
enum QuranFontPreference {
  qpcHafs(
    'QPC Hafs / Uthmani',
    'QPC Hafs',
    QuranScriptPreference.uthmaniMadani,
  ),
  indoPak(
    'IndoPak Nastaleeq',
    'IndoPak Nastaleeq',
    QuranScriptPreference.indoPak,
  );

  const QuranFontPreference(this.label, this.fontFamily, this.script);

  static const defaultGlobal = QuranFontPreference.qpcHafs;

  final String label;
  final String fontFamily;
  final QuranScriptPreference script;
}
