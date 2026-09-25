import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../tool/mushaf/import_digital_khatt_script.dart';

void main() {
  test('preserves exact Digital Khatt V2 Unicode and creates end token', () {
    final rows = importVerse(
      verseKey: '73:4',
      words: const [
        DigitalKhattSourceWord(position: 1, text: 'أَوْ'),
        DigitalKhattSourceWord(position: 2, text: 'زِدْ'),
        DigitalKhattSourceWord(position: 3, text: 'عَلَيْهِ'),
        DigitalKhattSourceWord(position: 4, text: 'وَرَتِّلِ'),
        DigitalKhattSourceWord(position: 5, text: 'ٱلْقُرْءَانَ'),
        DigitalKhattSourceWord(position: 6, text: 'تَرْتِيلًا'),
        DigitalKhattSourceWord(position: 7, text: '۝٤'),
      ],
    );

    expect(rows.map((row) => row.display).toList(), const [
      'أَوْ',
      'زِدْ',
      'عَلَيْهِ',
      'وَرَتِّلِ',
      'ٱلْقُرْءَانَ',
      'تَرْتِيلًا',
      '۝٤',
    ]);
    expect(rows.first.display.codeUnits, 'أَوْ'.codeUnits);
    expect(rows.last.charType, 'end');
    expect(rows.last.wordPosition, 7);
  });

  test('assigns sequential local indexes without normalizing text', () {
    final rows = importVerses([
      const DigitalKhattSourceVerse(
        verseKey: '1:1',
        words: [
          DigitalKhattSourceWord(position: 1, text: 'بِسۡمِ'),
          DigitalKhattSourceWord(position: 2, text: 'ٱللَّهِ'),
          DigitalKhattSourceWord(position: 3, text: '۝١'),
        ],
      ),
      const DigitalKhattSourceVerse(
        verseKey: '1:2',
        words: [
          DigitalKhattSourceWord(position: 1, text: 'ٱلۡحَمۡدُ'),
          DigitalKhattSourceWord(position: 2, text: '۝٢'),
        ],
      ),
    ]);

    expect(rows.map((row) => row.wordIndex), [1, 2, 3, 4, 5]);
    expect(rows.map((row) => row.charType), [
      'word',
      'word',
      'end',
      'word',
      'end',
    ]);
    expect(rows[0].display.codeUnits, 'بِسۡمِ'.codeUnits);
  });

  test('parses QUL JSON word-by-word export without altering codepoints', () {
    const raw = r'''
{
  "73:4": {
    "verse_key": "73:4",
    "script_type": "text_digital_khatt",
    "font_family": "digitalkhatt-v2",
    "words": [
      {"position": 1, "text": "أَوْ", "location": "73:4:1"},
      {"position": 2, "text": "زِدْ", "location": "73:4:2"},
      {"position": 7, "text": "۝٤", "location": "73:4:7"}
    ]
  }
}
''';

    final verses = parseQulDigitalKhattJson(raw);
    expect(verses, hasLength(1));
    expect(verses.single.verseKey, '73:4');
    expect(verses.single.words.first.text.codeUnits, 'أَوْ'.codeUnits);
    expect(verses.single.words.last.text, '۝٤');
  });

  test('parses word-level QUL SQLite without altering codepoints', () {
    final directory = Directory.systemTemp.createTempSync(
      'digital-khatt-import-test-',
    );
    addTearDown(() {
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    });
    final path = directory.uri.resolve('resource-48.sqlite').toFilePath();
    final db = sqlite3.open(path);
    try {
      db.execute('''
        CREATE TABLE words (
          verse_key TEXT NOT NULL,
          position INTEGER NOT NULL,
          text TEXT NOT NULL
        );
      ''');
      final insert = db.prepare('INSERT INTO words VALUES (?, ?, ?)');
      try {
        insert.execute(['73:4', 1, 'أَوْ']);
        insert.execute(['73:4', 2, 'زِدْ']);
        insert.execute(['73:4', 7, '۝٤']);
      } finally {
        insert.close();
      }
    } finally {
      db.close();
    }

    final verses = parseQulDigitalKhattSqlite(path);

    expect(verses, hasLength(1));
    expect(verses.single.verseKey, '73:4');
    expect(verses.single.words.first.text.codeUnits, 'أَوْ'.codeUnits);
    expect(verses.single.words.last.text, '۝٤');
  });

  test('rejects a non-Digital-Khatt script type', () {
    const raw = r'''
{
  "73:4": {
    "verse_key": "73:4",
    "script_type": "text_uthmani",
    "words": [{"position": 1, "text": "أَوْ"}]
  }
}
''';

    expect(
      () => parseQulDigitalKhattJson(raw),
      throwsA(isA<FormatException>()),
    );
  });
}
