import 'quran_script.dart';

class QuranWord {
  const QuranWord({
    required this.position,
    required this.arabic,
    this.arabicIndopak,
    this.arabicTajweedMarkup,
    this.transliteration,
    this.banglaMeaning,
    this.englishMeaning,
    this.root,
    this.lemma,
    this.grammar,
    this.audioUrl,
  });

  final int position;

  /// Verified Uthmani/Madani (QPC Hafs) Unicode form.
  final String arabic;

  /// Verified IndoPak form when the packaged Quran database contains it.
  /// Legacy content packages leave this null and the renderer falls back to
  /// [arabic] instead of inventing an alternate spelling.
  final String? arabicIndopak;

  /// Verified Quran Foundation Uthmani Tajweed markup for this word.
  /// The string contains `<tajweed class=...>` spans and is rendered only
  /// when Uthmani/Madani + Tajweed colors are enabled.
  final String? arabicTajweedMarkup;

  final String? transliteration;
  final String? banglaMeaning;
  final String? englishMeaning;
  final String? root;
  final String? lemma;
  final String? grammar;

  /// Remote word-audio path or absolute URL supplied by the verified content
  /// source. Resolution/caching belongs to the audio layer.
  final String? audioUrl;

  String arabicFor(QuranScriptPreference script) => switch (script) {
    QuranScriptPreference.uthmaniMadani => arabic,
    QuranScriptPreference.indoPak =>
      arabicIndopak == null || arabicIndopak!.trim().isEmpty
          ? arabic
          : arabicIndopak!,
  };
}
