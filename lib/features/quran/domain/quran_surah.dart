import 'quran_ayah.dart';

class QuranSurahSummary {
  const QuranSurahSummary({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.ayahCount,
    required this.pageStart,
    required this.pageEnd,
    required this.juzStart,
    this.nameBangla,
    this.revelationPlace,
  });

  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String? nameBangla;
  final String? revelationPlace;
  final int ayahCount;
  final int pageStart;
  final int pageEnd;
  final int juzStart;
}

/// Temporary compatibility model retained until the demo repository is
/// removed after canonical-reader acceptance tests pass.
class QuranSurah {
  const QuranSurah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.ayahs,
  });

  final int number;
  final String nameArabic;
  final String nameEnglish;
  final List<QuranAyah> ayahs;
}
