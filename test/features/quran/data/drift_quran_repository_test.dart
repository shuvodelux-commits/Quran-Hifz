import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/quran_content_database.dart';
import 'package:quran_hifz/features/quran/data/drift_quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_line.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  late QuranContentDatabase database;
  late DriftQuranRepository repository;

  setUp(() async {
    database = QuranContentDatabase.forTesting(NativeDatabase.memory());
    await database.customStatement('PRAGMA user_version = 1');
    repository = DriftQuranRepository(database);
    await _seed(database);
  });

  tearDown(() => database.close());

  test('listSurahs returns lightweight summaries in Quran order', () async {
    final surahs = await repository.listSurahs();

    expect(surahs.map((s) => s.number), [1, 2]);
    expect(surahs.first.ayahCount, 2);
    expect(surahs.first.nameEnglish, 'Fixture One');
  });

  test('listJuzs derives ordered first and last canonical ayahs', () async {
    final juzs = await repository.listJuzs();

    expect(juzs.map((juz) => juz.number), [1, 2]);
    expect(juzs.first.firstTarget.key, 'ayah:1:1');
    expect(juzs.first.lastTarget.key, 'ayah:2:1');
    expect(juzs.last.firstTarget.key, 'ayah:2:2');
    expect(juzs.last.lastTarget.key, 'ayah:2:2');
    expect(juzs.last.firstPage, 3);
  });

  test(
    'loadPageWindow returns ayahs words and translation in canonical order',
    () async {
      final window = await repository.loadPageWindow(
        page: 1,
        translationResourceId: 77,
      );

      expect(window.page, 1);
      expect(window.ayahs.map((a) => a.key), ['1:1', '1:2']);
      expect(window.ayahs.first.words.map((w) => w.position), [1, 2]);
      expect(window.ayahs.first.words.map((w) => w.arabic), ['A', 'B']);
      expect(window.ayahs.first.translation, 'T 1:1');
      expect(window.ayahs.last.translation, 'T 1:2');
    },
  );

  test('QuranPageWindow freezes a caller supplied line list', () {
    final suppliedLines = <QuranMushafLine>[
      QuranMushafLine(
        lineNumber: 1,
        type: QuranMushafLineType.surahName,
        centered: true,
        surahNumber: 1,
      ),
    ];
    final window = QuranPageWindow(
      page: 1,
      ayahs: const [],
      previousPage: null,
      nextPage: 2,
      lines: suppliedLines,
    );

    suppliedLines.clear();

    expect(window.lines, hasLength(1));
    expect(() => window.lines.clear(), throwsUnsupportedError);
  });

  test(
    'loadPageWindow expands ordered fixed line boundaries from canonical words',
    () async {
      await _createMushafLines(database);
      await _insertMushafLine(
        database,
        page: 1,
        line: 1,
        type: 'ayah',
        centered: false,
        surahNumber: 1,
        firstWordLocation: '1:1:1',
        lastWordLocation: '1:1:2',
      );
      await _insertMushafLine(
        database,
        page: 1,
        line: 2,
        type: 'surah_name',
        centered: true,
        surahNumber: 2,
      );
      await _insertMushafLine(
        database,
        page: 1,
        line: 3,
        type: 'ayah',
        centered: false,
        surahNumber: 1,
        firstWordLocation: '1:2:1',
        lastWordLocation: '1:2:1',
      );
      await _insertMushafLine(
        database,
        page: 1,
        line: 4,
        type: 'basmallah',
        centered: true,
        surahNumber: 2,
      );
      await _insertMushafLine(
        database,
        page: 1,
        line: 5,
        type: 'ayah',
        centered: false,
        surahNumber: 1,
        firstWordLocation: '1:2:2',
        lastWordLocation: '1:2:2',
      );
      await _insertMushafLine(
        database,
        page: 1,
        line: 6,
        type: 'ayah',
        centered: false,
        surahNumber: 1,
        firstWordLocation: '1:1:1',
        lastWordLocation: '1:2:2',
      );

      final window = await repository.loadPageWindow(
        page: 1,
        translationResourceId: 77,
      );

      expect(window.lines.map((line) => line.type), [
        QuranMushafLineType.ayah,
        QuranMushafLineType.surahName,
        QuranMushafLineType.ayah,
        QuranMushafLineType.bismillah,
        QuranMushafLineType.ayah,
        QuranMushafLineType.ayah,
      ]);
      expect(
        window.lines.first.wordLocations.map((location) => location.toString()),
        ['1:1:1', '1:1:2'],
      );
      expect(
        window.lines[2].wordLocations.map((location) => location.toString()),
        ['1:2:1'],
      );
      expect(
        window.lines[4].wordLocations.map((location) => location.toString()),
        ['1:2:2'],
      );
      expect(window.lines[1].surahNumber, 2);
      expect(window.lines[1].centered, isTrue);
      expect(window.lines[1].wordLocations, isEmpty);
      expect(window.lines[3].surahNumber, 2);
      expect(window.lines[3].centered, isTrue);
      expect(window.lines[3].wordLocations, isEmpty);
      expect(
        window.lines.last.wordLocations.map((location) => location.toString()),
        ['1:1:1', '1:1:2', '1:2:1', '1:2:2'],
      );
    },
  );

  test(
    'loadPageWindow keeps legacy content packages readable without lines',
    () async {
      await database.customStatement('DROP TABLE IF EXISTS mushaf_lines');

      final window = await repository.loadPageWindow(
        page: 1,
        translationResourceId: 77,
      );

      expect(window.ayahs, isNotEmpty);
      expect(window.lines, isEmpty);
    },
  );

  test(
    'loadPageWindow keeps Quran ayahs when a valid line crosses page data',
    () async {
      await _createMushafLines(database);
      await _insertMushafLine(
        database,
        page: 1,
        line: 1,
        type: 'ayah',
        centered: false,
        surahNumber: 2,
        firstWordLocation: '2:1:1',
        lastWordLocation: '2:1:1',
      );

      final window = await repository.loadPageWindow(
        page: 1,
        translationResourceId: 77,
      );

      expect(window.ayahs.map((ayah) => ayah.key), ['1:1', '1:2']);
      expect(window.lines, isEmpty);
    },
  );

  test('loadPageWindow rejects an unresolved fixed line boundary', () async {
    await _createMushafLines(database);
    await _insertMushafLine(
      database,
      page: 1,
      line: 1,
      type: 'ayah',
      centered: false,
      surahNumber: 1,
      firstWordLocation: '1:1:99',
      lastWordLocation: '1:1:99',
    );

    await expectLater(
      repository.loadPageWindow(page: 1, translationResourceId: 77),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Unresolved Mushaf line 1:1 boundaries'),
        ),
      ),
    );
  });

  test('loadAyah returns exactly one ayah with ordered words', () async {
    final ayah = await repository.loadAyah(
      surahNumber: 1,
      ayahNumber: 1,
      translationResourceId: 77,
    );

    expect(ayah, isNotNull);
    expect(ayah!.key, '1:1');
    expect(ayah.words.map((word) => word.position), [1, 2]);
    expect(ayah.translation, 'T 1:1');
  });

  test('loadAyah returns null instead of crossing a Surah boundary', () async {
    final ayah = await repository.loadAyah(
      surahNumber: 1,
      ayahNumber: 3,
      translationResourceId: 77,
    );

    expect(ayah, isNull);
  });

  test('loadPageWindow does not pull ayahs from another page', () async {
    final window = await repository.loadPageWindow(
      page: 1,
      translationResourceId: 77,
    );

    expect(window.ayahs.every((ayah) => ayah.pageNumber == 1), isTrue);
    expect(window.ayahs.map((a) => a.key), isNot(contains('2:1')));
  });

  test(
    'loadPageWindow reads IndoPak columns when the content package has them',
    () async {
      await database.customStatement(
        "UPDATE ayahs SET arabic_text_indopak = 'IP-AYAH' "
        'WHERE surah_number = 1 AND ayah_number = 1',
      );
      await database.customStatement(
        "UPDATE quran_words SET arabic_indopak = 'IP-A' "
        'WHERE surah_number = 1 AND ayah_number = 1 AND position = 1',
      );
      repository = DriftQuranRepository(database);

      final window = await repository.loadPageWindow(
        page: 1,
        translationResourceId: 77,
      );

      expect(window.ayahs.first.arabicTextIndopak, 'IP-AYAH');
      expect(window.ayahs.first.words.first.arabicIndopak, 'IP-A');
    },
  );

  test('loadPageWindow reads verified Tajweed columns when present', () async {
    await database.customStatement(
      "UPDATE ayahs SET arabic_text_tajweed = '<tajweed class=ghn>A</tajweed>B' "
      'WHERE surah_number = 1 AND ayah_number = 1',
    );
    await database.customStatement(
      "UPDATE quran_words SET arabic_tajweed = '<tajweed class=ghn>A</tajweed>' "
      'WHERE surah_number = 1 AND ayah_number = 1 AND position = 1',
    );
    repository = DriftQuranRepository(database);

    final window = await repository.loadPageWindow(
      page: 1,
      translationResourceId: 77,
    );

    expect(window.ayahs.first.arabicTajweedMarkup, contains('tajweed'));
    expect(window.ayahs.first.words.first.arabicTajweedMarkup, contains('ghn'));
  });

  test(
    'file-backed schema-v1 content reopens read-only without line data',
    () async {
      await database.close();
      final directory = await Directory.systemTemp.createTemp(
        'quran-content-schema-v1-',
      );
      final path = '${directory.path}/quran_content.sqlite';
      _createSchemaV1Content(path);
      final externalDatabase = QuranContentDatabase.forPath(path);
      addTearDown(() async {
        await externalDatabase.close();
        await directory.delete(recursive: true);
      });
      final externalRepository = DriftQuranRepository(externalDatabase);

      final window = await externalRepository.loadPageWindow(
        page: 1,
        translationResourceId: 77,
      );

      expect(window.ayahs.map((ayah) => ayah.key), ['1:1']);
      expect(window.ayahs.single.words.map((word) => word.position), [1]);
      expect(window.lines, isEmpty);
      final version = await externalDatabase
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.read<int>('user_version'), 1);
    },
  );

  test('new Quran content databases are created at schema version 2', () async {
    await database.close();
    final freshDatabase = QuranContentDatabase.forTesting(
      NativeDatabase.memory(),
    );
    addTearDown(freshDatabase.close);

    final version = await freshDatabase
        .customSelect('PRAGMA user_version')
        .getSingle();
    final mushafTable = await freshDatabase
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'mushaf_lines'",
        )
        .get();

    expect(version.read<int>('user_version'), 2);
    expect(mushafTable, hasLength(1));
  });
}

void _createSchemaV1Content(String path) {
  final database = sqlite3.sqlite3.open(path);
  try {
    database.execute('PRAGMA user_version = 1');
    database.execute('''
CREATE TABLE ayahs (
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  verse_key TEXT NOT NULL,
  arabic_text TEXT NOT NULL,
  page_number INTEGER NOT NULL,
  juz_number INTEGER NOT NULL,
  hizb_number INTEGER,
  rub_number INTEGER
)
''');
    database.execute('''
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
)
''');
    database.execute('''
CREATE TABLE translations (
  resource_id INTEGER NOT NULL,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  language TEXT NOT NULL,
  text TEXT NOT NULL
)
''');
    database.execute(
      'INSERT INTO ayahs (surah_number, ayah_number, verse_key, arabic_text, page_number, juz_number) VALUES (?, ?, ?, ?, ?, ?)',
      [1, 1, '1:1', 'A', 1, 1],
    );
    database.execute(
      'INSERT INTO quran_words (surah_number, ayah_number, position, arabic) VALUES (?, ?, ?, ?)',
      [1, 1, 1, 'A'],
    );
    database.execute('INSERT INTO translations VALUES (?, ?, ?, ?, ?)', [
      77,
      1,
      1,
      'bn',
      'T 1:1',
    ]);
  } finally {
    database.close();
  }
}

Future<void> _createMushafLines(QuranContentDatabase database) async {
  await database.customStatement('DROP TABLE IF EXISTS mushaf_lines');
  await database.customStatement(
    'CREATE TABLE mushaf_lines (page_number INTEGER NOT NULL, line_number INTEGER NOT NULL, line_type TEXT NOT NULL, is_centered INTEGER NOT NULL, surah_number INTEGER, first_word_location TEXT, last_word_location TEXT, PRIMARY KEY (page_number, line_number))',
  );
}

Future<void> _insertMushafLine(
  QuranContentDatabase database, {
  required int page,
  required int line,
  required String type,
  required bool centered,
  int? surahNumber,
  String? firstWordLocation,
  String? lastWordLocation,
}) async {
  await database.customStatement(
    'INSERT INTO mushaf_lines VALUES (?, ?, ?, ?, ?, ?, ?)',
    [
      page,
      line,
      type,
      centered ? 1 : 0,
      surahNumber,
      firstWordLocation,
      lastWordLocation,
    ],
  );
}

Future<void> _seed(QuranContentDatabase db) async {
  await db.batch((batch) {
    batch.insertAll(db.surahs, [
      SurahsCompanion.insert(
        number: const Value(1),
        nameArabic: 'Fixture Arabic 1',
        nameEnglish: 'Fixture One',
        ayahCount: 2,
        pageStart: 1,
        pageEnd: 1,
        juzStart: 1,
      ),
      SurahsCompanion.insert(
        number: const Value(2),
        nameArabic: 'Fixture Arabic 2',
        nameEnglish: 'Fixture Two',
        ayahCount: 2,
        pageStart: 2,
        pageEnd: 3,
        juzStart: 1,
      ),
    ]);

    batch.insertAll(db.ayahs, [
      AyahsCompanion.insert(
        surahNumber: 1,
        ayahNumber: 1,
        verseKey: '1:1',
        arabicText: 'AB',
        arabicTextIndopak: 'AB',
        pageNumber: 1,
        juzNumber: 1,
      ),
      AyahsCompanion.insert(
        surahNumber: 2,
        ayahNumber: 2,
        verseKey: '2:2',
        arabicText: 'E',
        arabicTextIndopak: 'E',
        pageNumber: 3,
        juzNumber: 2,
      ),
      AyahsCompanion.insert(
        surahNumber: 1,
        ayahNumber: 2,
        verseKey: '1:2',
        arabicText: 'C',
        arabicTextIndopak: 'C',
        pageNumber: 1,
        juzNumber: 1,
      ),
      AyahsCompanion.insert(
        surahNumber: 2,
        ayahNumber: 1,
        verseKey: '2:1',
        arabicText: 'D',
        arabicTextIndopak: 'D',
        pageNumber: 2,
        juzNumber: 1,
      ),
    ]);

    batch.insertAll(db.quranWords, [
      QuranWordsCompanion.insert(
        surahNumber: 1,
        ayahNumber: 1,
        position: 2,
        arabic: 'B',
        arabicIndopak: 'B',
      ),
      QuranWordsCompanion.insert(
        surahNumber: 1,
        ayahNumber: 1,
        position: 1,
        arabic: 'A',
        arabicIndopak: 'A',
      ),
      QuranWordsCompanion.insert(
        surahNumber: 1,
        ayahNumber: 2,
        position: 1,
        arabic: 'C',
        arabicIndopak: 'C',
      ),
      QuranWordsCompanion.insert(
        surahNumber: 1,
        ayahNumber: 2,
        position: 2,
        arabic: 'D',
        arabicIndopak: 'D',
      ),
      QuranWordsCompanion.insert(
        surahNumber: 2,
        ayahNumber: 1,
        position: 1,
        arabic: 'D',
        arabicIndopak: 'D',
      ),
      QuranWordsCompanion.insert(
        surahNumber: 2,
        ayahNumber: 2,
        position: 1,
        arabic: 'E',
        arabicIndopak: 'E',
      ),
    ]);

    batch.insertAll(db.translations, [
      TranslationsCompanion.insert(
        resourceId: 77,
        surahNumber: 1,
        ayahNumber: 1,
        language: 'bn',
        textValue: 'T 1:1',
      ),
      TranslationsCompanion.insert(
        resourceId: 77,
        surahNumber: 1,
        ayahNumber: 2,
        language: 'bn',
        textValue: 'T 1:2',
      ),
    ]);
  });
}
