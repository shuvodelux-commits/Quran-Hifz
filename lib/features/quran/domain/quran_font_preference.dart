import 'quran_script.dart';

/// Quran faces shared by the regular reader and the Hifz reader.
enum QuranFontPreference {
  pdmsSaleem(
    'PDMS Saleem Quran',
    'PDMS Saleem Quran',
    QuranScriptPreference.indoPak,
  ),
  indopakNastaleeq(
    'Indopak Nastaleeq',
    'Indopak Nastaleeq',
    QuranScriptPreference.indoPak,
  ),
  digitalKhatt(
    'DigitalKhatt IndoPak',
    'Quran DigitalKhatt IndoPak',
    QuranScriptPreference.indoPak,
  ),
  alQalam(
    'Al Qalam Quran Majeed',
    'AlQalamQuranMajeed',
    QuranScriptPreference.indoPak,
  ),
  muhammadi(
    'Muhammadi Quran',
    'Muhammadi Quranic',
    QuranScriptPreference.indoPak,
  ),
  kfgqpcHafs(
    'KFGQPC Hafs',
    'KFGQPC Hafs Uthmanic',
    QuranScriptPreference.uthmaniMadani,
  ),
  notoNaskhArabic(
    'Noto Naskh Arabic',
    'Noto Naskh Arabic',
    QuranScriptPreference.uthmaniMadani,
  );

  const QuranFontPreference(this.label, this.fontFamily, this.script);

  static const defaultGlobal = QuranFontPreference.indopakNastaleeq;
  static const defaultHifz = QuranFontPreference.notoNaskhArabic;

  final String label;
  final String fontFamily;
  final QuranScriptPreference script;
}
