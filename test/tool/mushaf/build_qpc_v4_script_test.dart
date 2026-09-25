import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../tool/mushaf/build_qpc_v4_script.dart';

void main() {
  final fixture = [
    QpcV4VerseInput(
      verseKey: '2:1',
      pageNumber: 2,
      words: const [
        QpcV4WordInput(
          id: 11,
          position: 1,
          charType: 'word',
          codeV2: 'A',
          pageNumber: 2,
          lineNumber: 3,
          textQpcHafs: 'ا',
        ),
        QpcV4WordInput(
          id: 12,
          position: 2,
          charType: 'end',
          codeV2: 'B',
          pageNumber: 2,
          lineNumber: 3,
          textQpcHafs: '١',
        ),
      ],
    ),
    QpcV4VerseInput(
      verseKey: '2:2',
      pageNumber: 2,
      words: const [
        QpcV4WordInput(
          id: 1195,
          position: 1,
          charType: 'word',
          codeV2: 'C',
          pageNumber: 2,
          lineNumber: 3,
          textQpcHafs: 'ب',
        ),
      ],
    ),
  ];

  test('assigns sequential local word indexes including end tokens', () {
    final rows = buildRows(fixture);

    expect(rows.map((row) => row.wordIndex), [1, 2, 3]);
    expect(rows.map((row) => row.remoteId), [11, 12, 1195]);
  });

  test('splits QUL multiword phrase without changing audio position', () {
    final rows = buildRows([
      const QpcV4VerseInput(
        verseKey: '2:181',
        pageNumber: 27,
        words: [
          QpcV4WordInput(
            id: 100,
            position: 3,
            charType: 'word',
            codeV2: 'ﳀﳁ',
            pageNumber: 27,
            lineNumber: 14,
            textQpcHafs: 'بَعۡدَ مَا',
          ),
          QpcV4WordInput(
            id: 101,
            position: 4,
            charType: 'word',
            codeV2: 'ﳂ',
            pageNumber: 27,
            lineNumber: 14,
            textQpcHafs: 'سَمِعَهُۥ',
          ),
        ],
      ),
    ]);

    expect(rows.map((row) => row.wordIndex), [1, 2, 3]);
    expect(rows.map((row) => row.display), ['ﳀ', 'ﳁ', 'ﳂ']);
    expect(rows.map((row) => row.unicodeFallback), [
      'بَعۡدَ',
      'مَا',
      'سَمِعَهُۥ',
    ]);
    expect(rows.map((row) => row.wordPosition), [3, 3, 4]);
  });

  test('preserves word and end token counts', () {
    final rows = buildRows(fixture);

    expect(rows.where((row) => row.charType == 'word'), hasLength(2));
    expect(rows.where((row) => row.charType == 'end'), hasLength(1));
  });

  test('bundled script database has no secondary indexes', () {
    final directory = Directory.systemTemp.createTempSync(
      'qpc-v4-writer-test-',
    );
    addTearDown(() => directory.deleteSync(recursive: true));
    final path = directory.uri.resolve('script.sqlite').toFilePath();

    writeQpcV4Database(
      outputPath: path,
      rows: buildRows(fixture),
      sourceDescription: 'fixture',
      generatedAt: '2026-09-25T00:00:00Z',
    );

    final db = sqlite3.open(path, mode: OpenMode.readOnly);
    addTearDown(db.close);
    expect(db.select('PRAGMA index_list(words)'), isEmpty);
  });
}
