class QuranSourceBundle {
  const QuranSourceBundle({
    required this.sourceName,
    required this.sourceVersion,
    required this.contentVersion,
    required this.surahs,
    required this.ayahs,
  });

  factory QuranSourceBundle.fromJson(Map<String, dynamic> json) {
    return QuranSourceBundle(
      sourceName: _requiredString(json, 'source_name'),
      sourceVersion: _requiredString(json, 'source_version'),
      contentVersion: _requiredString(json, 'content_version'),
      surahs: _objectList(
        json,
        'surahs',
      ).map(SurahSourceRecord.fromJson).toList(growable: false),
      ayahs: _objectList(
        json,
        'ayahs',
      ).map(AyahSourceRecord.fromJson).toList(growable: false),
    );
  }

  final String sourceName;
  final String sourceVersion;
  final String contentVersion;
  final List<SurahSourceRecord> surahs;
  final List<AyahSourceRecord> ayahs;
}

class SurahSourceRecord {
  const SurahSourceRecord({
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

  factory SurahSourceRecord.fromJson(Map<String, dynamic> json) {
    return SurahSourceRecord(
      number: _requiredInt(json, 'number'),
      nameArabic: _requiredString(json, 'name_arabic'),
      nameEnglish: _requiredString(json, 'name_english'),
      nameBangla: _optionalString(json, 'name_bangla'),
      revelationPlace: _optionalString(json, 'revelation_place'),
      ayahCount: _requiredInt(json, 'ayah_count'),
      pageStart: _requiredInt(json, 'page_start'),
      pageEnd: _requiredInt(json, 'page_end'),
      juzStart: _requiredInt(json, 'juz_start'),
    );
  }

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

class AyahSourceRecord {
  const AyahSourceRecord({
    required this.surahNumber,
    required this.ayahNumber,
    required this.verseKey,
    required this.arabicText,
    required this.arabicTextIndopak,
    this.arabicTextTajweed,
    required this.pageNumber,
    required this.juzNumber,
    this.hizbNumber,
    this.rubNumber,
  });

  factory AyahSourceRecord.fromJson(Map<String, dynamic> json) {
    return AyahSourceRecord(
      surahNumber: _requiredInt(json, 'surah_number'),
      ayahNumber: _requiredInt(json, 'ayah_number'),
      verseKey: _requiredString(json, 'verse_key'),
      arabicText: _requiredString(json, 'arabic_text'),
      arabicTextIndopak: _requiredString(json, 'arabic_text_indopak'),
      arabicTextTajweed: _optionalString(json, 'arabic_text_tajweed'),
      pageNumber: _requiredInt(json, 'page_number'),
      juzNumber: _requiredInt(json, 'juz_number'),
      hizbNumber: _optionalInt(json, 'hizb_number'),
      rubNumber: _optionalInt(json, 'rub_number'),
    );
  }

  final int surahNumber;
  final int ayahNumber;
  final String verseKey;
  final String arabicText;
  final String arabicTextIndopak;
  final String? arabicTextTajweed;
  final int pageNumber;
  final int juzNumber;
  final int? hizbNumber;
  final int? rubNumber;
}

class WordSourceBundle {
  const WordSourceBundle({
    required this.sourceName,
    required this.sourceVersion,
    required this.words,
  });

  factory WordSourceBundle.fromJson(Map<String, dynamic> json) {
    return WordSourceBundle(
      sourceName: _requiredString(json, 'source_name'),
      sourceVersion: _requiredString(json, 'source_version'),
      words: _objectList(
        json,
        'words',
      ).map(WordSourceRecord.fromJson).toList(growable: false),
    );
  }

  final String sourceName;
  final String sourceVersion;
  final List<WordSourceRecord> words;
}

class WordSourceRecord {
  const WordSourceRecord({
    required this.surahNumber,
    required this.ayahNumber,
    required this.position,
    required this.arabic,
    required this.arabicIndopak,
    this.arabicTajweed,
    this.transliteration,
    this.banglaMeaning,
    this.englishMeaning,
    this.root,
    this.lemma,
    this.grammar,
    this.audioRemotePath,
  });

  factory WordSourceRecord.fromJson(Map<String, dynamic> json) {
    return WordSourceRecord(
      surahNumber: _requiredInt(json, 'surah_number'),
      ayahNumber: _requiredInt(json, 'ayah_number'),
      position: _requiredInt(json, 'position'),
      arabic: _requiredString(json, 'arabic'),
      arabicIndopak: _requiredString(json, 'arabic_indopak'),
      arabicTajweed: _optionalString(json, 'arabic_tajweed'),
      transliteration: _optionalString(json, 'transliteration'),
      banglaMeaning: _optionalString(json, 'bangla_meaning'),
      englishMeaning: _optionalString(json, 'english_meaning'),
      root: _optionalString(json, 'root'),
      lemma: _optionalString(json, 'lemma'),
      grammar: _optionalString(json, 'grammar'),
      audioRemotePath: _optionalString(json, 'audio_remote_path'),
    );
  }

  final int surahNumber;
  final int ayahNumber;
  final int position;
  final String arabic;
  final String arabicIndopak;
  final String? arabicTajweed;
  final String? transliteration;
  final String? banglaMeaning;
  final String? englishMeaning;
  final String? root;
  final String? lemma;
  final String? grammar;
  final String? audioRemotePath;
}

class MushafLineSourceRecord {
  const MushafLineSourceRecord({
    required this.pageNumber,
    required this.lineNumber,
    required this.lineType,
    required this.centered,
    required this.surahNumber,
    this.firstWordLocation,
    this.lastWordLocation,
  });

  final int pageNumber;
  final int lineNumber;
  final String lineType;
  final bool centered;
  final int? surahNumber;
  final String? firstWordLocation;
  final String? lastWordLocation;
}

class TranslationSourceBundle {
  const TranslationSourceBundle({
    required this.sourceName,
    required this.sourceVersion,
    required this.resourceId,
    required this.language,
    required this.translations,
  });

  factory TranslationSourceBundle.fromJson(Map<String, dynamic> json) {
    return TranslationSourceBundle(
      sourceName: _requiredString(json, 'source_name'),
      sourceVersion: _requiredString(json, 'source_version'),
      resourceId: _requiredInt(json, 'resource_id'),
      language: _requiredString(json, 'language'),
      translations: _objectList(
        json,
        'translations',
      ).map(TranslationSourceRecord.fromJson).toList(growable: false),
    );
  }

  final String sourceName;
  final String sourceVersion;
  final int resourceId;
  final String language;
  final List<TranslationSourceRecord> translations;
}

class TranslationSourceRecord {
  const TranslationSourceRecord({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });

  factory TranslationSourceRecord.fromJson(Map<String, dynamic> json) {
    return TranslationSourceRecord(
      surahNumber: _requiredInt(json, 'surah_number'),
      ayahNumber: _requiredInt(json, 'ayah_number'),
      text: _requiredString(json, 'text'),
    );
  }

  final int surahNumber;
  final int ayahNumber;
  final String text;
}

List<Map<String, dynamic>> _objectList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Expected "$key" to be a JSON array.');
  }
  return value
      .map((item) {
        if (item is! Map) {
          throw FormatException('Expected every "$key" item to be an object.');
        }
        return Map<String, dynamic>.from(item);
      })
      .toList(growable: false);
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty string "$key".');
  }
  return value;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Expected string or null "$key".');
  }
  return value;
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || !value.isFinite || value != value.truncateToDouble()) {
    throw FormatException('Expected integer "$key".');
  }
  return value.toInt();
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! num || !value.isFinite || value != value.truncateToDouble()) {
    throw FormatException('Expected integer or null "$key".');
  }
  return value.toInt();
}
