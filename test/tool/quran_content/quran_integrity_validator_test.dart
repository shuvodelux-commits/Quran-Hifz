import 'package:flutter_test/flutter_test.dart';
import '../../../tool/quran_content/quran_integrity_validator.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('QuranIntegrityValidator', () {
    test('accepts a structurally valid tiny fixture with count overrides', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 2);
      _insertAyah(db, 1, 1, '1:1', 'بِسْمِ', page: 1, juz: 1);
      _insertAyah(db, 1, 2, '1:2', 'الْحَمْدُ', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'بِسْمِ');
      _insertWord(db, 1, 2, 1, 'الْحَمْدُ');
      _insertTranslation(db, 1, 1, 1, 'bn', 'অনুবাদ ১');
      _insertTranslation(db, 1, 1, 2, 'bn', 'অনুবাদ ২');

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 2,
          expectedAyahCountsBySurah: {1: 2},
        ),
      );

      expect(report.isValid, isTrue, reason: report.errors.join('\n'));
      expect(report.surahCount, 1);
      expect(report.ayahCount, 2);
      expect(report.wordCount, 2);
    });

    test('requires verified IndoPak and Tajweed coverage when enabled', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'بِسْمِ', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'بِسْمِ');
      _insertTranslation(db, 1, 1, 1, 'bn', 'অনুবাদ');

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
          requireIndoPakText: true,
          requireTajweedText: true,
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.indoPakCoverage), isTrue);
      expect(report.hasCode(QuranIntegrityCode.tajweedCoverage), isTrue);
    });

    test('rejects 113 Surahs and 6235 ayahs under production expectations', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);

      for (var surah = 1; surah <= 113; surah++) {
        _insertSurah(db, surah, ayahCount: 1);
      }
      for (var i = 1; i <= 6235; i++) {
        final surah = ((i - 1) % 113) + 1;
        final ayah = ((i - 1) ~/ 113) + 1;
        _insertAyah(db, surah, ayah, '$surah:$ayah', 'آية', page: 1, juz: 1);
      }

      final report = validateQuranDatabase(db);

      expect(report.hasCode(QuranIntegrityCode.surahCount), isTrue);
      expect(report.hasCode(QuranIntegrityCode.ayahCount), isTrue);
    });

    test('rejects incorrect Surah ayah_count metadata', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 99);
      _insertAyah(db, 1, 1, '1:1', 'أ', page: 1, juz: 1);

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.surahMetadataAyahCount), isTrue);
    });

    test('rejects duplicate verse keys', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 2);
      _insertAyah(db, 1, 1, '1:1', 'أ', page: 1, juz: 1);
      _insertAyah(db, 1, 2, '1:1', 'ب', page: 1, juz: 1);

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 2,
          expectedAyahCountsBySurah: {1: 2},
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.duplicateVerseKey), isTrue);
    });

    test('rejects empty Arabic text', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', '   ', page: 1, juz: 1);

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.emptyArabicText), isTrue);
    });

    test('rejects a canonical word-count mismatch when required', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'أ', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'أ');
      _insertTranslation(db, 1, 1, 1, 'bn', 'অনুবাদ');

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
          expectedWordCount: 2,
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.wordCount), isTrue);
    });

    test('rejects empty Bangla word meanings when required', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'أ', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'أ');
      _insertTranslation(db, 1, 1, 1, 'bn', 'অনুবাদ');

      final missing = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
          expectedWordCount: 1,
          requireBanglaWordMeanings: true,
        ),
      );
      expect(
        missing.hasCode(QuranIntegrityCode.banglaWordMeaningCoverage),
        isTrue,
      );

      db.execute(
        "UPDATE quran_words SET bangla_meaning = 'বাংলা অর্থ' "
        "WHERE surah_number = 1 AND ayah_number = 1 AND position = 1",
      );
      final complete = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
          expectedWordCount: 1,
          requireBanglaWordMeanings: true,
        ),
      );
      expect(
        complete.hasCode(QuranIntegrityCode.banglaWordMeaningCoverage),
        isFalse,
      );
    });

    test('rejects duplicate word positions inside an ayah', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'أ', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'أ');
      _insertWord(db, 1, 1, 1, 'ب');

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.duplicateWordPosition), isTrue);
    });

    test('rejects canonical ayahs without word coverage', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'أ', page: 1, juz: 1);
      _insertTranslation(db, 1, 1, 1, 'bn', 'অনুবাদ');

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.ayahMissingWords), isTrue);
    });

    test(
      'rejects missing or duplicate primary Bangla translation coverage',
      () {
        final db = sqlite3.openInMemory();
        addTearDown(db.close);
        _createLooseSchema(db);
        _insertSurah(db, 1, ayahCount: 2);
        _insertAyah(db, 1, 1, '1:1', 'أ', page: 1, juz: 1);
        _insertAyah(db, 1, 2, '1:2', 'ب', page: 1, juz: 1);
        _insertWord(db, 1, 1, 1, 'أ');
        _insertWord(db, 1, 2, 1, 'ب');
        _insertTranslation(db, 1, 1, 1, 'bn', 'এক');
        _insertTranslation(db, 1, 1, 1, 'bn', 'duplicate');

        final report = validateQuranDatabase(
          db,
          expectations: const QuranIntegrityExpectations(
            expectedSurahCount: 1,
            expectedAyahCount: 2,
            expectedAyahCountsBySurah: {1: 2},
          ),
        );

        expect(
          report.hasCode(QuranIntegrityCode.primaryTranslationCoverage),
          isTrue,
        );
        expect(
          report.errors
              .firstWhere(
                (issue) =>
                    issue.code == QuranIntegrityCode.primaryTranslationCoverage,
              )
              .count,
          2,
        );
      },
    );

    test('rejects empty or non-Bangla primary translation rows', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 2);
      _insertAyah(db, 1, 1, '1:1', 'أ', page: 1, juz: 1);
      _insertAyah(db, 1, 2, '1:2', 'ب', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'أ');
      _insertWord(db, 1, 2, 1, 'ب');
      _insertTranslation(db, 1, 1, 1, 'bn', '   ');
      _insertTranslation(db, 1, 1, 2, 'en', 'wrong language');

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 2,
          expectedAyahCountsBySurah: {1: 2},
        ),
      );

      expect(
        report.hasCode(QuranIntegrityCode.emptyPrimaryTranslation),
        isTrue,
      );
      expect(
        report.hasCode(QuranIntegrityCode.primaryTranslationLanguage),
        isTrue,
      );
    });

    test('rejects translation rows referencing a missing ayah', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'أ', page: 1, juz: 1);
      _insertTranslation(db, 1, 1, 2, 'bn', 'missing');

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.translationMissingAyah), isTrue);
    });

    test('rejects invalid page and Juz values', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'أ', page: 0, juz: 31);

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.invalidPage), isTrue);
      expect(report.hasCode(QuranIntegrityCode.invalidJuz), isTrue);
    });

    test('requires every expected Mushaf page to be represented', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'لَمۡ هُدًى', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'لَمۡ');
      _insertTranslation(db, 1, 1, 1, 'bn', 'অনুবাদ');
      _createMushafLines(db);
      _insertMushafLine(db, 1, 1, 'ayah', 0, 1, '1:1:1', '1:1:1');

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
          requireMushafLayout: true,
          expectedMushafPageCount: 2,
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.mushafPageCoverage), isTrue);
    });

    test('rejects gapped Mushaf line numbers within a page', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'لَمۡ', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'لَمۡ');
      _insertTranslation(db, 1, 1, 1, 'bn', 'অনুবাদ');
      _createMushafLines(db);
      _insertMushafLine(db, 1, 2, 'ayah', 0, 1, '1:1:1', '1:1:1');

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
          requireMushafLayout: true,
          expectedMushafPageCount: 1,
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.mushafLineOrder), isTrue);
    });

    test('rejects Mushaf ayah boundaries missing from canonical words', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'لَمۡ', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'لَمۡ');
      _insertTranslation(db, 1, 1, 1, 'bn', 'অনুবাদ');
      _createMushafLines(db);
      _insertMushafLine(db, 1, 1, 'ayah', 0, 1, '1:1:99', '1:1:99');

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
          requireMushafLayout: true,
          expectedMushafPageCount: 1,
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.mushafBoundary), isTrue);
    });

    test('requires IndoPak sukun and tanween to survive canonical import', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _addIndoPakColumns(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'لَمۡ هُدًى', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'لَمۡ');
      _insertTranslation(db, 1, 1, 1, 'bn', 'অনুবাদ');
      db.execute("UPDATE ayahs SET arabic_text_indopak = 'لَمۡ هُدًى'");
      db.execute("UPDATE quran_words SET arabic_indopak = 'لَمۡ'");

      final preserved = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
          requireIndoPakDiacritics: true,
        ),
      );
      expect(preserved.hasCode(QuranIntegrityCode.indoPakDiacritics), isFalse);

      db.execute("UPDATE ayahs SET arabic_text_indopak = 'لم هدى'");
      db.execute("UPDATE quran_words SET arabic_indopak = 'لم'");
      final stripped = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
          requireIndoPakDiacritics: true,
        ),
      );
      expect(stripped.hasCode(QuranIntegrityCode.indoPakDiacritics), isTrue);
    });

    test('accepts standard Arabic sukun with retained tanween', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      _createLooseSchema(db);
      _addIndoPakColumns(db);
      _insertSurah(db, 1, ayahCount: 1);
      _insertAyah(db, 1, 1, '1:1', 'لَمْ هُدًى', page: 1, juz: 1);
      _insertWord(db, 1, 1, 1, 'لَمْ');
      _insertTranslation(db, 1, 1, 1, 'bn', 'অনুবাদ');
      db.execute("UPDATE ayahs SET arabic_text_indopak = 'لَمْ هُدًى'");
      db.execute("UPDATE quran_words SET arabic_indopak = 'لَمْ'");

      final report = validateQuranDatabase(
        db,
        expectations: const QuranIntegrityExpectations(
          expectedSurahCount: 1,
          expectedAyahCount: 1,
          expectedAyahCountsBySurah: {1: 1},
          requireIndoPakDiacritics: true,
        ),
      );

      expect(report.hasCode(QuranIntegrityCode.indoPakDiacritics), isFalse);
    });
  });
}

void _createLooseSchema(Database db) {
  db.execute('''
    CREATE TABLE surahs (
      number INTEGER NOT NULL,
      name_arabic TEXT NOT NULL,
      name_english TEXT NOT NULL,
      name_bangla TEXT,
      revelation_place TEXT,
      ayah_count INTEGER NOT NULL,
      page_start INTEGER NOT NULL,
      page_end INTEGER NOT NULL,
      juz_start INTEGER NOT NULL
    );
    CREATE TABLE ayahs (
      surah_number INTEGER NOT NULL,
      ayah_number INTEGER NOT NULL,
      verse_key TEXT NOT NULL,
      arabic_text TEXT NOT NULL,
      page_number INTEGER NOT NULL,
      juz_number INTEGER NOT NULL,
      hizb_number INTEGER,
      rub_number INTEGER
    );
    CREATE TABLE quran_words (
      surah_number INTEGER NOT NULL,
      ayah_number INTEGER NOT NULL,
      position INTEGER NOT NULL,
      arabic TEXT NOT NULL,
      transliteration TEXT,
      bangla_meaning TEXT,
      english_meaning TEXT,
      root TEXT,
      lemma TEXT,
      grammar TEXT,
      audio_remote_path TEXT
    );
    CREATE TABLE translations (
      resource_id INTEGER NOT NULL,
      surah_number INTEGER NOT NULL,
      ayah_number INTEGER NOT NULL,
      language TEXT NOT NULL,
      text TEXT NOT NULL
    );
    CREATE TABLE quran_metadata (
      metadata_key TEXT NOT NULL,
      metadata_value TEXT NOT NULL
    );
  ''');
}

void _insertSurah(Database db, int number, {required int ayahCount}) {
  db.execute('INSERT INTO surahs VALUES (?, ?, ?, NULL, NULL, ?, 1, 1, 1)', [
    number,
    'سورة',
    'Surah $number',
    ayahCount,
  ]);
}

void _insertAyah(
  Database db,
  int surah,
  int ayah,
  String verseKey,
  String arabic, {
  required int page,
  required int juz,
}) {
  db.execute(
    'INSERT INTO ayahs '
    '(surah_number, ayah_number, verse_key, arabic_text, page_number, juz_number, hizb_number, rub_number) '
    'VALUES (?, ?, ?, ?, ?, ?, NULL, NULL)',
    [surah, ayah, verseKey, arabic, page, juz],
  );
}

void _insertWord(
  Database db,
  int surah,
  int ayah,
  int position,
  String arabic,
) {
  db.execute(
    'INSERT INTO quran_words '
    '(surah_number, ayah_number, position, arabic, transliteration, bangla_meaning, '
    'english_meaning, root, lemma, grammar, audio_remote_path) '
    'VALUES (?, ?, ?, ?, NULL, NULL, NULL, NULL, NULL, NULL, NULL)',
    [surah, ayah, position, arabic],
  );
}

void _insertTranslation(
  Database db,
  int resourceId,
  int surah,
  int ayah,
  String language,
  String text,
) {
  db.execute('INSERT INTO translations VALUES (?, ?, ?, ?, ?)', [
    resourceId,
    surah,
    ayah,
    language,
    text,
  ]);
}

void _createMushafLines(Database db) {
  db.execute('''
    CREATE TABLE mushaf_lines (
      page_number INTEGER NOT NULL,
      line_number INTEGER NOT NULL,
      line_type TEXT NOT NULL,
      is_centered INTEGER NOT NULL,
      surah_number INTEGER,
      first_word_location TEXT,
      last_word_location TEXT
    )
  ''');
}

void _insertMushafLine(
  Database db,
  int page,
  int line,
  String type,
  int centered,
  int? surah,
  String? first,
  String? last,
) {
  db.execute('INSERT INTO mushaf_lines VALUES (?, ?, ?, ?, ?, ?, ?)', [
    page,
    line,
    type,
    centered,
    surah,
    first,
    last,
  ]);
}

void _addIndoPakColumns(Database db) {
  db.execute('ALTER TABLE ayahs ADD COLUMN arabic_text_indopak TEXT');
  db.execute('ALTER TABLE quran_words ADD COLUMN arabic_indopak TEXT');
}
