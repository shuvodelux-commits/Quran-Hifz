import 'package:flutter_test/flutter_test.dart';

import '../../../tool/quran_audio/reciter_catalog_builder.dart';

Map<String, dynamic> _reciter(int id, String name) => {
  'id': id,
  'name': name,
  'style': <String, dynamic>{'name': 'Murattal', 'language_name': 'English'},
  'qirat': <String, dynamic>{'name': 'Hafs', 'language_name': 'English'},
};

Map<String, dynamic> _rawChapterAudio({
  required int chapter,
  String url = 'https://download.quranicaudio.com/test/001.mp3',
}) => {
  'audio_file': {
    'id': 457,
    'chapter_id': chapter,
    'file_size': 710784,
    'format': 'mp3',
    'audio_url': url,
    'timestamps': [
      {
        'verse_key': '$chapter:1',
        'timestamp_from': 0,
        'timestamp_to': 6493,
        'duration': -6493,
        'segments': [
          [1, 0, 500],
          [2, 500, 900],
        ],
      },
    ],
  },
};

Map<String, dynamic> _validChapterDocument(int reciterId, int chapter) =>
    buildChapterAudioDocument(
      reciterId: reciterId,
      surahNumber: chapter,
      raw: _rawChapterAudio(chapter: chapter),
    );

void main() {
  group('reciter index', () {
    test('accepts nullable metadata names but requires metadata objects', () {
      final nullableMetadata = _reciter(7, 'Seven');
      (nullableMetadata['style'] as Map<String, dynamic>)['name'] = null;
      (nullableMetadata['style'] as Map<String, dynamic>)['language_name'] =
          null;
      (nullableMetadata['qirat'] as Map<String, dynamic>)['name'] = null;
      (nullableMetadata['qirat'] as Map<String, dynamic>)['language_name'] =
          null;

      final index = buildReciterIndex(
        sourceVersion: 'test',
        generatedAtUtc: DateTime.utc(2026, 9, 13),
        reciters: [nullableMetadata],
      );
      final row =
          (index['reciters'] as List<dynamic>).single as Map<String, dynamic>;
      expect((row['style'] as Map<String, dynamic>)['name'], isNull);
      expect((row['style'] as Map<String, dynamic>)['language_name'], isNull);
      expect((row['qirat'] as Map<String, dynamic>)['name'], isNull);
      expect((row['qirat'] as Map<String, dynamic>)['language_name'], isNull);

      final missingStyle = _reciter(8, 'Eight')..remove('style');
      expect(
        () => buildReciterIndex(
          sourceVersion: 'test',
          generatedAtUtc: DateTime.utc(2026, 9, 13),
          reciters: [missingStyle],
        ),
        throwsFormatException,
      );
    });

    test('requires non-empty provenance and reciter coverage', () {
      expect(
        () => buildReciterIndex(
          sourceVersion: '   ',
          generatedAtUtc: DateTime.utc(2026, 9, 13),
          reciters: [_reciter(7, 'Seven')],
        ),
        throwsFormatException,
      );
      expect(
        () => buildReciterIndex(
          sourceVersion: 'test',
          generatedAtUtc: DateTime.utc(2026, 9, 13),
          reciters: const [],
        ),
        throwsFormatException,
      );
    });

    test('sorts reciters and rejects duplicate ids', () {
      final index = buildReciterIndex(
        sourceVersion: 'content-api-v4-production-test',
        generatedAtUtc: DateTime.utc(2026, 9, 13),
        reciters: [_reciter(10, 'Ten'), _reciter(7, 'Seven')],
      );

      final rows = index['reciters'] as List<dynamic>;
      expect(rows.map((row) => (row as Map)['id']).toList(), [7, 10]);
      expect(index['schema_version'], 1);

      expect(
        () => buildReciterIndex(
          sourceVersion: 'test',
          generatedAtUtc: DateTime.utc(2026, 9, 13),
          reciters: [_reciter(7, 'A'), _reciter(7, 'B')],
        ),
        throwsFormatException,
      );
    });
  });

  group('chapter audio normalization', () {
    test('accepts ordered word timing overlaps from production data', () {
      final raw = _rawChapterAudio(chapter: 3);
      final audioFile = raw['audio_file'] as Map<String, dynamic>;
      audioFile['timestamps'] = [
        {
          'verse_key': '3:175',
          'timestamp_from': 1000,
          'timestamp_to': 5000,
          'duration': -4000,
          'segments': [
            [1, 1000, 2200],
            [2, 2000, 3000],
            [3, 3000, 3600],
          ],
        },
      ];

      final document = buildChapterAudioDocument(
        reciterId: 7,
        surahNumber: 3,
        raw: raw,
      );

      final timestamps = document['timestamps'] as List<dynamic>;
      final row = timestamps.single as Map<String, dynamic>;
      expect(row['segments'], [
        [1, 1000, 2200],
        [2, 2000, 3000],
        [3, 3000, 3600],
      ]);
    });

    test('drops inconsistent source segment ordering for the verse', () {
      final raw = _rawChapterAudio(chapter: 2);
      final audioFile = raw['audio_file'] as Map<String, dynamic>;
      audioFile['timestamps'] = [
        {
          'verse_key': '2:14',
          'timestamp_from': 1000,
          'timestamp_to': 5000,
          'duration': -4000,
          'segments': [
            [1, 2000, 2600],
            [2, 1900, 2800],
            [3, 2800, 3400],
          ],
        },
      ];

      final document = buildChapterAudioDocument(
        reciterId: 7,
        surahNumber: 2,
        raw: raw,
      );

      final timestamps = document['timestamps'] as List<dynamic>;
      final row = timestamps.single as Map<String, dynamic>;
      expect(row['verse_key'], '2:14');
      expect(row['timestamp_from'], 1000);
      expect(row['timestamp_to'], 5000);
      expect(row['segments'], isEmpty);
    });

    test(
      'drops all word timing when a complete segment has reversed bounds',
      () {
        final raw = _rawChapterAudio(chapter: 6);
        final audioFile = raw['audio_file'] as Map<String, dynamic>;
        audioFile['timestamps'] = [
          {
            'verse_key': '6:38',
            'timestamp_from': 818000,
            'timestamp_to': 823000,
            'duration': -5000,
            'segments': [
              [9, 820900, 821300],
              [10, 821707, 821455],
              [11, 821800, 822200],
            ],
          },
        ];

        final document = buildChapterAudioDocument(
          reciterId: 7,
          surahNumber: 6,
          raw: raw,
        );

        final timestamps = document['timestamps'] as List<dynamic>;
        final row = timestamps.single as Map<String, dynamic>;
        expect(row['verse_key'], '6:38');
        expect(row['timestamp_from'], 818000);
        expect(row['timestamp_to'], 823000);
        expect(row['segments'], isEmpty);
      },
    );

    test(
      'drops all word timing when any source segment entry is incomplete',
      () {
        final raw = _rawChapterAudio(chapter: 3);
        final audioFile = raw['audio_file'] as Map<String, dynamic>;
        audioFile['timestamps'] = [
          {
            'verse_key': '3:8',
            'timestamp_from': 1000,
            'timestamp_to': 5000,
            'duration': -4000,
            'segments': [
              [1, 1000, 1800],
              <int>[],
              [0],
              [3, 2600, 3400],
            ],
          },
        ];

        final document = buildChapterAudioDocument(
          reciterId: 7,
          surahNumber: 3,
          raw: raw,
        );

        final timestamps = document['timestamps'] as List<dynamic>;
        final row = timestamps.single as Map<String, dynamic>;
        expect(row['segments'], isEmpty);
      },
    );

    test('drops all word timing when a source segment entry is not a list', () {
      final raw = _rawChapterAudio(chapter: 3);
      final audioFile = raw['audio_file'] as Map<String, dynamic>;
      audioFile['timestamps'] = [
        {
          'verse_key': '3:8',
          'timestamp_from': 1000,
          'timestamp_to': 5000,
          'duration': -4000,
          'segments': [
            [1, 1000, 1800],
            'broken',
          ],
        },
      ];

      final document = buildChapterAudioDocument(
        reciterId: 7,
        surahNumber: 3,
        raw: raw,
      );

      final timestamps = document['timestamps'] as List<dynamic>;
      final row = timestamps.single as Map<String, dynamic>;
      expect(row['segments'], isEmpty);
    });

    test(
      'drops all word timing when a segment contains non-integer values',
      () {
        final raw = _rawChapterAudio(chapter: 6);
        final audioFile = raw['audio_file'] as Map<String, dynamic>;
        audioFile['timestamps'] = [
          {
            'verse_key': '6:38',
            'timestamp_from': 818000,
            'timestamp_to': 823000,
            'duration': -5000,
            'segments': [
              [1, 818100, 818500],
              [2, 'bad', 819000],
            ],
          },
        ];

        final document = buildChapterAudioDocument(
          reciterId: 7,
          surahNumber: 6,
          raw: raw,
        );

        final timestamps = document['timestamps'] as List<dynamic>;
        final row = timestamps.single as Map<String, dynamic>;
        expect(row['segments'], isEmpty);
      },
    );

    test('accepts source word segments that overlap ayah timestamp bounds', () {
      final raw = _rawChapterAudio(chapter: 1);
      final audioFile = raw['audio_file'] as Map<String, dynamic>;
      audioFile['timestamps'] = [
        {
          'verse_key': '1:2',
          'timestamp_from': 6493,
          'timestamp_to': 12000,
          'duration': -5507,
          'segments': [
            [1, 6025, 7025],
            [2, 7025, 8000],
          ],
        },
      ];

      final document = buildChapterAudioDocument(
        reciterId: 7,
        surahNumber: 1,
        raw: raw,
      );

      final timestamps = document['timestamps'] as List<dynamic>;
      final row = timestamps.single as Map<String, dynamic>;
      expect(row['timestamp_from'], 6493);
      expect(row['timestamp_to'], 12000);
      expect(row['segments'], [
        [1, 6025, 7025],
        [2, 7025, 8000],
      ]);
    });

    test(
      'accepts overlapping ayah timestamp ranges when starts move forward',
      () {
        final raw = _rawChapterAudio(chapter: 37);
        final audioFile = raw['audio_file'] as Map<String, dynamic>;
        audioFile['timestamps'] = [
          {
            'verse_key': '37:151',
            'timestamp_from': 1227000,
            'timestamp_to': 1229790,
            'duration': -2790,
            'segments': const <List<int>>[],
          },
          {
            'verse_key': '37:152',
            'timestamp_from': 1228910,
            'timestamp_to': 1231800,
            'duration': -2890,
            'segments': const <List<int>>[],
          },
        ];

        final document = buildChapterAudioDocument(
          reciterId: 7,
          surahNumber: 37,
          raw: raw,
        );

        final timestamps = document['timestamps'] as List<dynamic>;
        expect(timestamps, hasLength(2));
        expect(
          (timestamps[1] as Map<String, dynamic>)['timestamp_from'],
          1228910,
        );
        expect(
          (timestamps[1] as Map<String, dynamic>)['timestamp_to'],
          1231800,
        );
      },
    );

    test('rejects ayah timestamp start offsets that move backward', () {
      final raw = _rawChapterAudio(chapter: 37);
      final audioFile = raw['audio_file'] as Map<String, dynamic>;
      audioFile['timestamps'] = [
        {
          'verse_key': '37:151',
          'timestamp_from': 1229000,
          'timestamp_to': 1230000,
          'duration': -1000,
          'segments': const <List<int>>[],
        },
        {
          'verse_key': '37:152',
          'timestamp_from': 1228000,
          'timestamp_to': 1231000,
          'duration': -3000,
          'segments': const <List<int>>[],
        },
      ];

      expect(
        () =>
            buildChapterAudioDocument(reciterId: 7, surahNumber: 37, raw: raw),
        throwsFormatException,
      );
    });

    test(
      'requires matching chapter and normalizes legacy negative duration',
      () {
        final document = buildChapterAudioDocument(
          reciterId: 7,
          surahNumber: 1,
          raw: _rawChapterAudio(chapter: 1),
        );

        expect(document['schema_version'], 1);
        expect(document['reciter_id'], 7);
        expect(document['surah_number'], 1);
        expect(
          document['audio_url'],
          'https://download.quranicaudio.com/test/001.mp3',
        );
        final timestamps = document['timestamps'] as List<dynamic>;
        expect((timestamps.single as Map)['duration'], 6493);
      },
    );

    test('rejects reserved placeholder https audio urls', () {
      expect(
        () => buildChapterAudioDocument(
          reciterId: 7,
          surahNumber: 1,
          raw: _rawChapterAudio(
            chapter: 1,
            url: 'https://example.invalid/001.mp3',
          ),
        ),
        throwsFormatException,
      );
    });

    test('rejects non-https audio urls', () {
      expect(
        () => buildChapterAudioDocument(
          reciterId: 7,
          surahNumber: 1,
          raw: _rawChapterAudio(
            chapter: 1,
            url: 'http://example.invalid/001.mp3',
          ),
        ),
        throwsFormatException,
      );
    });

    test('rejects non-positive audio identity and file size', () {
      final invalidId = _rawChapterAudio(chapter: 1);
      (invalidId['audio_file'] as Map<String, dynamic>)['id'] = 0;
      expect(
        () => buildChapterAudioDocument(
          reciterId: 7,
          surahNumber: 1,
          raw: invalidId,
        ),
        throwsFormatException,
      );

      final invalidSize = _rawChapterAudio(chapter: 1);
      (invalidSize['audio_file'] as Map<String, dynamic>)['file_size'] = 0;
      expect(
        () => buildChapterAudioDocument(
          reciterId: 7,
          surahNumber: 1,
          raw: invalidSize,
        ),
        throwsFormatException,
      );
    });

    test('rejects mismatched chapter metadata', () {
      expect(
        () => buildChapterAudioDocument(
          reciterId: 7,
          surahNumber: 2,
          raw: _rawChapterAudio(chapter: 1),
        ),
        throwsFormatException,
      );
    });
  });

  group('catalog coverage', () {
    test('requires all 114 chapter documents for every reciter', () {
      final index = buildReciterIndex(
        sourceVersion: 'test',
        generatedAtUtc: DateTime.utc(2026, 9, 13),
        reciters: [_reciter(7, 'Seven')],
      );

      expect(
        () => validateGeneratedAudioCatalog(
          reciterIndex: index,
          chaptersByReciter: {
            7: {1: _validChapterDocument(7, 1)},
          },
        ),
        throwsStateError,
      );
    });

    test('accepts exact 114-surah coverage', () {
      final index = buildReciterIndex(
        sourceVersion: 'test',
        generatedAtUtc: DateTime.utc(2026, 9, 13),
        reciters: [_reciter(7, 'Seven')],
      );
      final chapters = <int, Map<String, dynamic>>{
        for (var chapter = 1; chapter <= 114; chapter++)
          chapter: _validChapterDocument(7, chapter),
      };

      expect(
        () => validateGeneratedAudioCatalog(
          reciterIndex: index,
          chaptersByReciter: {7: chapters},
        ),
        returnsNormally,
      );
    });
  });
}
