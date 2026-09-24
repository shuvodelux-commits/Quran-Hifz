import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../tool/quran_content/materialize_qul_sources.dart';

void main() {
  test('derives canonical verse counts and joined word candidates', () {
    final segmentation = canonicalSegmentationFromJson({
      'words': [
        {
          'surah_number': 2,
          'ayah_number': 181,
          'position': 1,
          'arabic': 'فَمَنْ',
        },
        {
          'surah_number': 2,
          'ayah_number': 181,
          'position': 2,
          'arabic': 'بَعۡدَ مَا',
        },
        {
          'surah_number': 2,
          'ayah_number': 181,
          'position': 3,
          'arabic': 'سَمِعَهُۥ',
        },
        {
          'surah_number': 2,
          'ayah_number': 182,
          'position': 1,
          'arabic': '۞ فَمَنۡ',
        },
      ],
    });

    expect(segmentation.wordCountsByVerse, {'2:181': 3, '2:182': 1});
    expect(segmentation.joinedWordLocations, {'2:181:2'});
  });

  test(
    'materializes resource-59 words, strips only final numbered markers, and derives Bismillah gaps',
    () {
      final materialized = materializeQulMushafResponses([
        _chapterResponse([
          _verse(
            id: 1,
            key: '1:1',
            words: [
              _word(1, '1:1:1', 1, 2, 'بِسْمِ'),
              _marker(2, '1:1:2', 2, 1, 2),
            ],
          ),
        ]),
        _chapterResponse([
          _verse(
            id: 8,
            key: '2:1',
            words: [
              _word(37, '2:1:1', 1, 3, 'الٓمّٓ'),
              _marker(38, '2:1:2', 2, 2, 3),
            ],
          ),
        ]),
        _chapterResponse([
          _verse(
            id: 1234,
            key: '9:1',
            words: [
              _word(999, '9:1:1', 1, 2, 'بَرَاءَةٌ'),
              _marker(1000, '9:1:2', 2, 1, 2),
            ],
          ),
        ]),
      ]);

      expect(materialized.words.map((word) => word.location), [
        '1:1:1',
        '2:1:1',
        '9:1:1',
      ]);
      expect(
        materialized.words.singleWhere((word) => word.id == 37).text,
        'الٓمّٓ',
      );
      expect(
        materialized.lines
            .where((line) => line.pageNumber == 1)
            .map(
              (line) =>
                  '${line.lineNumber}:${line.lineType}:${line.surahNumber}',
            )
            .toList(),
        ['1:surah_name:1', '2:ayah:1'],
      );
      expect(
        materialized.lines
            .where((line) => line.pageNumber == 2)
            .map(
              (line) =>
                  '${line.lineNumber}:${line.lineType}:${line.surahNumber}',
            )
            .toList(),
        ['1:surah_name:2', '2:basmallah:2', '3:ayah:2'],
      );
      expect(
        materialized.lines
            .where((line) => line.pageNumber == 3)
            .map(
              (line) =>
                  '${line.lineNumber}:${line.lineType}:${line.surahNumber}',
            )
            .toList(),
        ['1:surah_name:9', '2:ayah:9'],
      );
    },
  );

  test('rejects a final API word that is not that ayah numbered marker', () {
    expect(
      () => materializeQulMushafResponses([
        _chapterResponse([
          _verse(
            id: 8,
            key: '2:1',
            words: [
              _word(37, '2:1:1', 1, 3, 'الٓمّٓ'),
              _word(38, '2:1:2', 2, 3, 'not-a-marker'),
            ],
          ),
        ]),
      ]),
      throwsFormatException,
    );
  });

  test(
    'inserts header and Bismillah before a Surah starting on physical line two',
    () {
      final materialized = materializeQulMushafResponses([
        _chapterResponse([
          _verse(
            id: 10120,
            key: '4:1',
            words: [
              _word(10121, '4:1:1', 1, 2, 'یٰۤاَیُّهَا'),
              _marker(10149, '4:1:2', 2, 4, 2),
            ],
          ),
        ]),
      ]);

      expect(
        materialized.lines
            .map(
              (line) =>
                  '${line.lineNumber}:${line.lineType}:${line.surahNumber}',
            )
            .toList(),
        ['1:surah_name:4', '2:basmallah:4', '3:ayah:4'],
      );
    },
  );

  test('merges a QUL split phrase into its canonical stable word location', () {
    final materialized = materializeQulMushafResponses(
      [
        _chapterResponse([
          _verse(
            id: 188,
            key: '2:181',
            words: [
              _word(2001, '2:181:1', 1, 5, 'فَمَنْ'),
              _word(2002, '2:181:2', 2, 5, 'بَعْدَ'),
              _word(2003, '2:181:3', 3, 5, 'مَا'),
              _word(2004, '2:181:4', 4, 5, 'سَمِعَهٗ'),
              _marker(2005, '2:181:5', 5, 2, 5),
            ],
          ),
        ]),
      ],
      canonicalWordCountsByVerse: const {'2:181': 3},
      joinedCanonicalLocations: const {'2:181:2'},
    );

    expect(
      materialized.words
          .map((word) => '${word.location}=${word.text}')
          .toList(),
      ['2:181:1=فَمَنْ', '2:181:2=بَعْدَ مَا', '2:181:3=سَمِعَهٗ'],
    );
  });

  test('writes importer-compatible script and layout SQLite inputs', () async {
    final directory = await Directory.systemTemp.createTemp(
      'qul-materializer-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final materialized = materializeQulMushafResponses([
      _chapterResponse([
        _verse(
          id: 8,
          key: '2:1',
          words: [
            _word(37, '2:1:1', 1, 3, 'الٓمّٓ'),
            _marker(38, '2:1:2', 2, 2, 3),
          ],
        ),
      ]),
    ]);
    final script = File('${directory.path}/indopak.sqlite');
    final layout = File('${directory.path}/layout.sqlite');

    writeQulMaterializedSqlite(
      materialized,
      scriptPath: script.path,
      layoutPath: layout.path,
    );

    final scriptDb = sqlite3.open(script.path, mode: OpenMode.readOnly);
    final layoutDb = sqlite3.open(layout.path, mode: OpenMode.readOnly);
    addTearDown(scriptDb.close);
    addTearDown(layoutDb.close);
    expect(scriptDb.select('SELECT id, location, text FROM words').single, {
      'id': 37,
      'location': '2:1:1',
      'text': 'الٓمّٓ',
    });
    expect(
      layoutDb
          .select(
            'SELECT line_number, line_type, first_word_id, last_word_id FROM pages ORDER BY line_number',
          )
          .map((row) => Map<String, Object?>.from(row))
          .toList(),
      [
        {
          'line_number': 1,
          'line_type': 'surah_name',
          'first_word_id': null,
          'last_word_id': null,
        },
        {
          'line_number': 2,
          'line_type': 'basmallah',
          'first_word_id': null,
          'last_word_id': null,
        },
        {
          'line_number': 3,
          'line_type': 'ayah',
          'first_word_id': 37,
          'last_word_id': 37,
        },
      ],
    );
  });
}

Map<String, dynamic> _chapterResponse(List<Map<String, dynamic>> verses) => {
  'verses': verses,
};

Map<String, dynamic> _verse({
  required int id,
  required String key,
  required List<Map<String, dynamic>> words,
}) => {'id': id, 'verse_key': key, 'words': words};

Map<String, dynamic> _word(
  int id,
  String location,
  int position,
  int line,
  String text,
) => {
  'id': id,
  'location': location,
  'position': position,
  'page_number': int.parse(location.split(':').first) == 1
      ? 1
      : int.parse(location.split(':').first) == 2
      ? 2
      : 3,
  'line_number': line,
  'text': text,
  'text_indopak_nastaleeq': text,
};

Map<String, dynamic> _marker(
  int id,
  String location,
  int position,
  int page,
  int line,
) => {
  'id': id,
  'location': location,
  'position': position,
  'page_number': page,
  'line_number': line,
  'text': _arabicIndic(int.parse(location.split(':')[1])),
  'text_indopak_nastaleeq': '۟',
};

String _arabicIndic(int value) => value
    .toString()
    .split('')
    .map((digit) => String.fromCharCode(0x0660 + int.parse(digit)))
    .join();
