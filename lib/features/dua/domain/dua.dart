enum DuaSourceType { quran, hadith }

enum HadithGrade { sahih, hasan }

class DuaSource {
  const DuaSource({
    required this.type,
    this.surahNumber,
    this.ayahStart,
    this.ayahEnd,
    this.collection,
    this.reference,
    this.grade,
    this.gradingAuthority,
  });

  final DuaSourceType type;
  final int? surahNumber;
  final int? ayahStart;
  final int? ayahEnd;
  final String? collection;
  final String? reference;
  final HadithGrade? grade;
  final String? gradingAuthority;
}

class DuaCategory {
  const DuaCategory({
    required this.id,
    required this.banglaLabel,
    required this.englishLabel,
  });

  final String id;
  final String banglaLabel;
  final String englishLabel;
}

class Dua {
  const Dua({
    required this.id,
    required this.titleBangla,
    required this.titleEnglish,
    required this.arabic,
    required this.banglaPronunciation,
    required this.banglaMeaning,
    required this.englishTransliteration,
    required this.englishMeaning,
    required this.categoryIds,
    required this.tagsBangla,
    required this.tagsEnglish,
    required this.sources,
    this.dailyOrder,
    this.noteBangla,
    this.noteEnglish,
  });

  final String id;
  final String titleBangla;
  final String titleEnglish;
  final String arabic;
  final String banglaPronunciation;
  final String banglaMeaning;
  final String englishTransliteration;
  final String englishMeaning;
  final List<String> categoryIds;
  final List<String> tagsBangla;
  final List<String> tagsEnglish;
  final List<DuaSource> sources;
  final int? dailyOrder;
  final String? noteBangla;
  final String? noteEnglish;
}
