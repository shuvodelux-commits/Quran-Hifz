import 'package:sqlite3/common.dart';

import '../../lib/features/quran/domain/canonical_quran_counts.dart';

enum QuranIntegrityCode {
  surahCount,
  ayahCount,
  surahAyahCount,
  surahMetadataAyahCount,
  duplicateVerseKey,
  verseKeyMismatch,
  emptyArabicText,
  duplicateWordPosition,
  ayahMissingWords,
  wordMissingAyah,
  translationMissingAyah,
  primaryTranslationCoverage,
  emptyPrimaryTranslation,
  primaryTranslationLanguage,
  invalidPage,
  invalidJuz,
  indoPakCoverage,
  indoPakDiacritics,
  tajweedCoverage,
  mushafPageCoverage,
  mushafLineOrder,
  mushafBoundary,
}

class QuranIntegrityIssue {
  const QuranIntegrityIssue({
    required this.code,
    required this.message,
    this.count = 1,
  });

  final QuranIntegrityCode code;
  final String message;
  final int count;

  Map<String, Object> toJson() => {
    'code': code.name,
    'message': message,
    'count': count,
  };

  @override
  String toString() => '${code.name}: $message';
}

class QuranIntegrityReport {
  const QuranIntegrityReport({
    required this.surahCount,
    required this.ayahCount,
    required this.wordCount,
    required this.translationCount,
    required this.errors,
  });

  final int surahCount;
  final int ayahCount;
  final int wordCount;
  final int translationCount;
  final List<QuranIntegrityIssue> errors;

  bool get isValid => errors.isEmpty;

  bool hasCode(QuranIntegrityCode code) {
    return errors.any((issue) => issue.code == code);
  }

  Map<String, Object> toJson() => {
    'valid': isValid,
    'surah_count': surahCount,
    'ayah_count': ayahCount,
    'word_count': wordCount,
    'translation_count': translationCount,
    'errors': errors.map((issue) => issue.toJson()).toList(),
  };
}

class QuranIntegrityExpectations {
  const QuranIntegrityExpectations({
    required this.expectedSurahCount,
    required this.expectedAyahCount,
    required this.expectedAyahCountsBySurah,
    this.minimumPage = 1,
    this.maximumPage = 604,
    this.minimumJuz = 1,
    this.maximumJuz = 30,
    this.primaryTranslationResourceId = 1,
    this.primaryTranslationLanguage = 'bn',
    this.requireIndoPakText = false,
    this.requireIndoPakDiacritics = false,
    this.requireTajweedText = false,
    this.requireMushafLayout = false,
    this.expectedMushafPageCount = 604,
  });

  static const production = QuranIntegrityExpectations(
    expectedSurahCount: 114,
    expectedAyahCount: 6236,
    expectedAyahCountsBySurah: canonicalAyahCounts,
    requireIndoPakText: true,
    requireIndoPakDiacritics: true,
    requireTajweedText: true,
    requireMushafLayout: true,
  );

  final int expectedSurahCount;
  final int expectedAyahCount;
  final Map<int, int> expectedAyahCountsBySurah;
  final int minimumPage;
  final int maximumPage;
  final int minimumJuz;
  final int maximumJuz;
  final int primaryTranslationResourceId;
  final String primaryTranslationLanguage;
  final bool requireIndoPakText;
  final bool requireIndoPakDiacritics;
  final bool requireTajweedText;
  final bool requireMushafLayout;
  final int expectedMushafPageCount;
}

QuranIntegrityReport validateQuranDatabase(
  CommonDatabase database, {
  QuranIntegrityExpectations expectations =
      QuranIntegrityExpectations.production,
}) {
  final errors = <QuranIntegrityIssue>[];
  final surahCount = _count(database, 'surahs');
  final ayahCount = _count(database, 'ayahs');
  final wordCount = _count(database, 'quran_words');
  final translationCount = _count(database, 'translations');

  if (surahCount != expectations.expectedSurahCount) {
    errors.add(
      QuranIntegrityIssue(
        code: QuranIntegrityCode.surahCount,
        message:
            'Expected ${expectations.expectedSurahCount} Surahs, found $surahCount.',
      ),
    );
  }

  if (ayahCount != expectations.expectedAyahCount) {
    errors.add(
      QuranIntegrityIssue(
        code: QuranIntegrityCode.ayahCount,
        message:
            'Expected ${expectations.expectedAyahCount} ayahs, found $ayahCount.',
      ),
    );
  }

  final actualBySurah = <int, int>{};
  for (final row in database.select(
    'SELECT surah_number, COUNT(*) AS c '
    'FROM ayahs GROUP BY surah_number ORDER BY surah_number',
  )) {
    actualBySurah[row['surah_number'] as int] = row['c'] as int;
  }
  for (final entry in expectations.expectedAyahCountsBySurah.entries) {
    final actual = actualBySurah[entry.key] ?? 0;
    if (actual != entry.value) {
      errors.add(
        QuranIntegrityIssue(
          code: QuranIntegrityCode.surahAyahCount,
          message:
              'Surah ${entry.key} expected ${entry.value} ayahs, found $actual.',
        ),
      );
    }
  }

  final metadataBySurah = <int, int>{};
  for (final row in database.select(
    'SELECT number, ayah_count FROM surahs ORDER BY number',
  )) {
    metadataBySurah[row['number'] as int] = row['ayah_count'] as int;
  }
  for (final entry in expectations.expectedAyahCountsBySurah.entries) {
    final actual = metadataBySurah[entry.key];
    if (actual != entry.value) {
      errors.add(
        QuranIntegrityIssue(
          code: QuranIntegrityCode.surahMetadataAyahCount,
          message:
              'Surah ${entry.key} metadata expected ayah_count ${entry.value}, '
              'found ${actual ?? 'missing'}.',
        ),
      );
    }
  }

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.duplicateVerseKey,
    sql:
        'SELECT COUNT(*) AS c FROM ('
        'SELECT verse_key FROM ayahs GROUP BY verse_key HAVING COUNT(*) > 1)',
    message: 'Duplicate verse_key values found.',
  );

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.verseKeyMismatch,
    sql:
        "SELECT COUNT(*) AS c FROM ayahs "
        "WHERE verse_key != CAST(surah_number AS TEXT) || ':' || CAST(ayah_number AS TEXT)",
    message: 'verse_key does not match surah_number:ayah_number.',
  );

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.emptyArabicText,
    sql: "SELECT COUNT(*) AS c FROM ayahs WHERE TRIM(arabic_text) = ''",
    message: 'Ayahs with empty Arabic text found.',
  );

  if (expectations.requireIndoPakText) {
    _validateSupplementalArabicCoverage(
      database,
      errors,
      code: QuranIntegrityCode.indoPakCoverage,
      ayahColumn: 'arabic_text_indopak',
      wordColumn: 'arabic_indopak',
      label: 'IndoPak',
    );
  }

  if (expectations.requireIndoPakDiacritics) {
    _validateIndoPakDiacritics(database, errors);
  }

  if (expectations.requireTajweedText) {
    _validateSupplementalArabicCoverage(
      database,
      errors,
      code: QuranIntegrityCode.tajweedCoverage,
      ayahColumn: 'arabic_text_tajweed',
      wordColumn: 'arabic_tajweed',
      label: 'Uthmani Tajweed',
    );
  }

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.duplicateWordPosition,
    sql:
        'SELECT COUNT(*) AS c FROM ('
        'SELECT surah_number, ayah_number, position FROM quran_words '
        'GROUP BY surah_number, ayah_number, position HAVING COUNT(*) > 1)',
    message: 'Duplicate word positions found inside ayahs.',
  );

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.ayahMissingWords,
    sql:
        'SELECT COUNT(*) AS c FROM ayahs a '
        'WHERE NOT EXISTS ('
        'SELECT 1 FROM quran_words w '
        'WHERE w.surah_number = a.surah_number '
        'AND w.ayah_number = a.ayah_number)',
    message: 'Canonical ayahs without word rows found.',
  );

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.wordMissingAyah,
    sql:
        'SELECT COUNT(*) AS c FROM quran_words w '
        'LEFT JOIN ayahs a ON a.surah_number = w.surah_number '
        'AND a.ayah_number = w.ayah_number '
        'WHERE a.verse_key IS NULL',
    message: 'Word rows reference missing ayahs.',
  );

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.translationMissingAyah,
    sql:
        'SELECT COUNT(*) AS c FROM translations t '
        'LEFT JOIN ayahs a ON a.surah_number = t.surah_number '
        'AND a.ayah_number = t.ayah_number '
        'WHERE a.verse_key IS NULL',
    message: 'Translation rows reference missing ayahs.',
  );

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.primaryTranslationCoverage,
    sql:
        'SELECT COUNT(*) AS c FROM ayahs a '
        'WHERE (SELECT COUNT(*) FROM translations t '
        'WHERE t.resource_id = ${expectations.primaryTranslationResourceId} '
        'AND t.surah_number = a.surah_number '
        'AND t.ayah_number = a.ayah_number) != 1',
    message: 'Ayahs without exactly one primary Bangla translation found.',
  );

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.emptyPrimaryTranslation,
    sql:
        'SELECT COUNT(*) AS c FROM translations '
        'WHERE resource_id = ${expectations.primaryTranslationResourceId} '
        "AND TRIM(text) = ''",
    message: 'Empty primary Bangla translation rows found.',
  );

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.primaryTranslationLanguage,
    sql:
        'SELECT COUNT(*) AS c FROM translations '
        'WHERE resource_id = ${expectations.primaryTranslationResourceId} '
        "AND LOWER(TRIM(language)) != LOWER('${expectations.primaryTranslationLanguage}')",
    message: 'Primary translation rows are not marked as Bangla.',
  );

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.invalidPage,
    sql:
        'SELECT COUNT(*) AS c FROM ayahs WHERE page_number < '
        '${expectations.minimumPage} OR page_number > ${expectations.maximumPage}',
    message:
        'Ayah page_number is outside ${expectations.minimumPage}-${expectations.maximumPage}.',
  );

  _addGroupedCountIssue(
    database,
    errors,
    code: QuranIntegrityCode.invalidJuz,
    sql:
        'SELECT COUNT(*) AS c FROM ayahs WHERE juz_number < '
        '${expectations.minimumJuz} OR juz_number > ${expectations.maximumJuz}',
    message:
        'Ayah juz_number is outside ${expectations.minimumJuz}-${expectations.maximumJuz}.',
  );

  if (expectations.requireMushafLayout) {
    _validateMushafLayout(
      database,
      errors,
      expectations.expectedMushafPageCount,
    );
  }

  return QuranIntegrityReport(
    surahCount: surahCount,
    ayahCount: ayahCount,
    wordCount: wordCount,
    translationCount: translationCount,
    errors: List.unmodifiable(errors),
  );
}

void _validateMushafLayout(
  CommonDatabase database,
  List<QuranIntegrityIssue> errors,
  int expectedPageCount,
) {
  if (!_tableExists(database, 'mushaf_lines')) {
    errors.add(
      const QuranIntegrityIssue(
        code: QuranIntegrityCode.mushafPageCoverage,
        message: 'Mushaf layout table is missing from the canonical package.',
      ),
    );
    return;
  }
  final pageNumbers = database
      .select(
        'SELECT DISTINCT page_number FROM mushaf_lines ORDER BY page_number',
      )
      .map((row) => row['page_number'] as int)
      .toList(growable: false);
  final expectedPages = List<int>.generate(
    expectedPageCount,
    (index) => index + 1,
  );
  if (pageNumbers.length != expectedPageCount ||
      !pageNumbers.every((page) => page >= 1 && page <= expectedPageCount) ||
      !pageNumbers.toSet().containsAll(expectedPages)) {
    errors.add(
      QuranIntegrityIssue(
        code: QuranIntegrityCode.mushafPageCoverage,
        message:
            'Expected layout coverage for pages 1-$expectedPageCount, found ${pageNumbers.length} pages.',
        count: pageNumbers.length,
      ),
    );
  }

  final lineRows = database.select(
    'SELECT page_number, line_number FROM mushaf_lines '
    'ORDER BY page_number, line_number',
  );
  final linesByPage = <int, List<int>>{};
  for (final row in lineRows) {
    linesByPage
        .putIfAbsent(row['page_number'] as int, () => [])
        .add(row['line_number'] as int);
  }
  final invalidLinePages = linesByPage.values.where((lines) {
    if (lines.isEmpty) return true;
    for (var index = 0; index < lines.length; index++) {
      if (lines[index] != index + 1) return true;
    }
    return false;
  }).length;
  if (invalidLinePages > 0) {
    errors.add(
      QuranIntegrityIssue(
        code: QuranIntegrityCode.mushafLineOrder,
        message:
            'Mushaf line numbers must be unique and contiguous from 1 on every page.',
        count: invalidLinePages,
      ),
    );
  }

  final invalidBoundaries =
      database.select('''
    SELECT COUNT(*) AS c FROM mushaf_lines m
    WHERE
      (m.line_type = 'ayah' AND (
        m.first_word_location IS NULL OR m.last_word_location IS NULL OR
        NOT EXISTS (
          SELECT 1 FROM quran_words w WHERE
          m.first_word_location = CAST(w.surah_number AS TEXT) || ':' ||
          CAST(w.ayah_number AS TEXT) || ':' || CAST(w.position AS TEXT)
        ) OR NOT EXISTS (
          SELECT 1 FROM quran_words w WHERE
          m.last_word_location = CAST(w.surah_number AS TEXT) || ':' ||
          CAST(w.ayah_number AS TEXT) || ':' || CAST(w.position AS TEXT)
        )
      )) OR
      (m.line_type IN ('surah_name', 'basmallah') AND (
        m.first_word_location IS NOT NULL OR m.last_word_location IS NOT NULL OR
        m.surah_number IS NULL OR m.surah_number NOT BETWEEN 1 AND 114
      )) OR
      m.line_type NOT IN ('ayah', 'surah_name', 'basmallah')
  ''').single['c']
          as int;
  if (invalidBoundaries > 0) {
    errors.add(
      QuranIntegrityIssue(
        code: QuranIntegrityCode.mushafBoundary,
        message: 'Mushaf line semantics or word boundaries are invalid.',
        count: invalidBoundaries,
      ),
    );
  }
}

void _validateIndoPakDiacritics(
  CommonDatabase database,
  List<QuranIntegrityIssue> errors,
) {
  final ayahColumns = _columnNames(database, 'ayahs');
  final wordColumns = _columnNames(database, 'quran_words');
  if (!ayahColumns.contains('arabic_text_indopak') ||
      !wordColumns.contains('arabic_indopak')) {
    errors.add(
      const QuranIntegrityIssue(
        code: QuranIntegrityCode.indoPakDiacritics,
        message: 'IndoPak columns are missing for diacritic verification.',
      ),
    );
    return;
  }
  final sukun =
      database.select('''
    SELECT COUNT(*) AS c FROM (
      SELECT arabic_text_indopak AS text FROM ayahs
      UNION ALL SELECT arabic_indopak AS text FROM quran_words
    ) WHERE instr(COALESCE(text, ''), char(1618)) > 0
      OR instr(COALESCE(text, ''), char(1761)) > 0
  ''').single['c']
          as int;
  final tanween =
      database.select('''
    SELECT COUNT(*) AS c FROM (
      SELECT arabic_text_indopak AS text FROM ayahs
      UNION ALL SELECT arabic_indopak AS text FROM quran_words
    ) WHERE instr(COALESCE(text, ''), char(1611)) > 0
  ''').single['c']
          as int;
  if (sukun > 0 && tanween > 0) return;
  errors.add(
    QuranIntegrityIssue(
      code: QuranIntegrityCode.indoPakDiacritics,
      message:
          'IndoPak corpus must retain sukun (U+0652 or U+06E1) and tanween (U+064B).',
      count: (sukun == 0 ? 1 : 0) + (tanween == 0 ? 1 : 0),
    ),
  );
}

void _validateSupplementalArabicCoverage(
  CommonDatabase database,
  List<QuranIntegrityIssue> errors, {
  required QuranIntegrityCode code,
  required String ayahColumn,
  required String wordColumn,
  required String label,
}) {
  final ayahColumns = _columnNames(database, 'ayahs');
  final wordColumns = _columnNames(database, 'quran_words');
  if (!ayahColumns.contains(ayahColumn) || !wordColumns.contains(wordColumn)) {
    errors.add(
      QuranIntegrityIssue(
        code: code,
        message: '$label columns are missing from the canonical package.',
      ),
    );
    return;
  }

  final missingAyahs =
      database
              .select(
                "SELECT COUNT(*) AS c FROM ayahs "
                "WHERE TRIM(COALESCE($ayahColumn, '')) = ''",
              )
              .single['c']
          as int;
  final missingWords =
      database
              .select(
                "SELECT COUNT(*) AS c FROM quran_words "
                "WHERE TRIM(COALESCE($wordColumn, '')) = ''",
              )
              .single['c']
          as int;
  final missing = missingAyahs + missingWords;
  if (missing == 0) return;

  errors.add(
    QuranIntegrityIssue(
      code: code,
      message:
          '$label coverage is incomplete: '
          '$missingAyahs ayah rows and $missingWords word rows are empty.',
      count: missing,
    ),
  );
}

Set<String> _columnNames(CommonDatabase database, String table) {
  return database
      .select('PRAGMA table_info($table)')
      .map((row) => row['name'] as String)
      .toSet();
}

bool _tableExists(CommonDatabase database, String table) {
  return database.select(
    "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
    [table],
  ).isNotEmpty;
}

int _count(CommonDatabase database, String table) {
  final row = database.select('SELECT COUNT(*) AS c FROM $table').single;
  return row['c'] as int;
}

void _addGroupedCountIssue(
  CommonDatabase database,
  List<QuranIntegrityIssue> errors, {
  required QuranIntegrityCode code,
  required String sql,
  required String message,
}) {
  final row = database.select(sql).single;
  final count = row['c'] as int;
  if (count <= 0) return;

  errors.add(
    QuranIntegrityIssue(
      code: code,
      message: '$message Count: $count.',
      count: count,
    ),
  );
}
