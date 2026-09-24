import 'quran_script.dart';
import 'quran_word.dart';

class QuranAyah {
  const QuranAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.words,
    String? translation,
    String? banglaTranslation,
    this.arabicText = '',
    this.arabicTextIndopak,
    this.arabicTajweedMarkup,
    this.pageNumber = 1,
    this.juzNumber = 1,
    this.audioUrl,
    this.shortTafsir,
  }) : translation = translation ?? banglaTranslation;

  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String? arabicTextIndopak;
  final String? arabicTajweedMarkup;
  final int pageNumber;
  final int juzNumber;
  final List<QuranWord> words;
  final String? translation;
  final String? audioUrl;
  final String? shortTafsir;

  String get key => '$surahNumber:$ayahNumber';

  String arabicTextFor(QuranScriptPreference script) => switch (script) {
    QuranScriptPreference.uthmaniMadani => arabicText,
    QuranScriptPreference.indoPak =>
      arabicTextIndopak == null || arabicTextIndopak!.trim().isEmpty
          ? arabicText
          : arabicTextIndopak!,
  };

  /// Compatibility getter for the v0.2 reader. The canonical reader uses
  /// [translation] directly and can switch resources/languages.
  String get banglaTranslation => translation ?? '';
}
