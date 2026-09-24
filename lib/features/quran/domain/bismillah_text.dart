import 'quran_script.dart';

/// Canonical Bismillah text used for standalone Surah headers.
///
/// Uthmani/IndoPak forms and Tajweed markup mirror Quran Foundation Content
/// API v4 verse 1:1. The ayah end marker is intentionally excluded because
/// this header is not an ayah-number rendering.
abstract final class BismillahText {
  static const uthmani = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ';
  static const indoPak = 'بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ';
  static const uthmaniTajweedMarkup =
      'بِسْمِ <tajweed class=ham_wasl>ٱ</tajweed>للَّهِ '
      '<tajweed class=ham_wasl>ٱ</tajweed>'
      '<tajweed class=laam_shamsiyah>ل</tajweed>'
      'رَّحْمَ<tajweed class=madda_normal>ـٰ</tajweed>نِ '
      '<tajweed class=ham_wasl>ٱ</tajweed>'
      '<tajweed class=laam_shamsiyah>ل</tajweed>'
      'رَّح<tajweed class=madda_permissible>ِي</tajweed>مِ';

  static String plainFor(QuranScriptPreference script) => switch (script) {
    QuranScriptPreference.uthmaniMadani => uthmani,
    QuranScriptPreference.indoPak => indoPak,
  };
}
