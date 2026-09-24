enum QuranSearchResultType { surah, ayah }

class QuranSearchResult {
  const QuranSearchResult({
    required this.type,
    required this.surahNumber,
    required this.pageNumber,
    required this.title,
    this.ayahNumber,
    this.verseKey,
    this.subtitle,
    this.matchText,
  });

  final QuranSearchResultType type;
  final int surahNumber;
  final int? ayahNumber;
  final int pageNumber;
  final String? verseKey;
  final String title;
  final String? subtitle;
  final String? matchText;
}
