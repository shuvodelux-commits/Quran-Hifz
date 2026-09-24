import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/reciters/data/bundled_chapter_audio_source.dart';

void main() {
  test(
    'loads one chapter and returns a backend-compatible audio envelope',
    () async {
      final source = BundledChapterAudioSource(
        bundle: _MapAssetBundle({
          'assets/audio/chapters_v1/7-67.json': jsonEncode(
            _chapterDocument(reciterId: 7, surahNumber: 67),
          ),
        }),
      );

      final chapter = await source.loadChapterAudio(
        reciterId: 7,
        surahNumber: 67,
      );

      final audio = chapter['audio_file'] as Map<String, dynamic>;
      expect(audio['chapter_id'], 67);
      expect(audio['audio_url'], startsWith('https://'));
      expect(audio['timestamps'], hasLength(1));
    },
  );

  test('accepts ordered overlapping word segments', () async {
    final document = _chapterDocument(reciterId: 7, surahNumber: 3);
    document['timestamps'] = [
      {
        'verse_key': '3:175',
        'timestamp_from': 1000,
        'timestamp_to': 5000,
        'duration': 4000,
        'segments': [
          [1, 1000, 2200],
          [2, 2000, 3000],
          [3, 3000, 3600],
        ],
      },
    ];
    final source = BundledChapterAudioSource(
      bundle: _MapAssetBundle({
        'assets/audio/chapters_v1/7-3.json': jsonEncode(document),
      }),
    );

    final chapter = await source.loadChapterAudio(reciterId: 7, surahNumber: 3);

    final audio = chapter['audio_file'] as Map<String, dynamic>;
    final timestamps = audio['timestamps'] as List<dynamic>;
    final row = timestamps.single as Map<String, dynamic>;
    expect(row['segments'], [
      [1, 1000, 2200],
      [2, 2000, 3000],
      [3, 3000, 3600],
    ]);
  });

  test('rejects word segment start times that move backward', () async {
    final document = _chapterDocument(reciterId: 7, surahNumber: 3);
    document['timestamps'] = [
      {
        'verse_key': '3:175',
        'timestamp_from': 1000,
        'timestamp_to': 5000,
        'duration': 4000,
        'segments': [
          [1, 2000, 2600],
          [2, 1900, 2800],
        ],
      },
    ];
    final source = BundledChapterAudioSource(
      bundle: _MapAssetBundle({
        'assets/audio/chapters_v1/7-3.json': jsonEncode(document),
      }),
    );

    await expectLater(
      source.loadChapterAudio(reciterId: 7, surahNumber: 3),
      throwsFormatException,
    );
  });

  test(
    'accepts source word segments that overlap ayah timestamp bounds',
    () async {
      final document = _chapterDocument(reciterId: 7, surahNumber: 1);
      document['timestamps'] = [
        {
          'verse_key': '1:2',
          'timestamp_from': 6493,
          'timestamp_to': 12000,
          'duration': 5507,
          'segments': [
            [1, 6025, 7025],
            [2, 7025, 8000],
          ],
        },
      ];
      final source = BundledChapterAudioSource(
        bundle: _MapAssetBundle({
          'assets/audio/chapters_v1/7-1.json': jsonEncode(document),
        }),
      );

      final chapter = await source.loadChapterAudio(
        reciterId: 7,
        surahNumber: 1,
      );

      final audio = chapter['audio_file'] as Map<String, dynamic>;
      final timestamps = audio['timestamps'] as List<dynamic>;
      final row = timestamps.single as Map<String, dynamic>;
      expect(row['timestamp_from'], 6493);
      expect(row['segments'], [
        [1, 6025, 7025],
        [2, 7025, 8000],
      ]);
    },
  );

  test(
    'accepts overlapping ayah ranges when start offsets move forward',
    () async {
      final document = _chapterDocument(reciterId: 7, surahNumber: 37);
      document['timestamps'] = [
        {
          'verse_key': '37:151',
          'timestamp_from': 1227000,
          'timestamp_to': 1229790,
          'duration': 2790,
          'segments': const <List<int>>[],
        },
        {
          'verse_key': '37:152',
          'timestamp_from': 1228910,
          'timestamp_to': 1231800,
          'duration': 2890,
          'segments': const <List<int>>[],
        },
      ];
      final source = BundledChapterAudioSource(
        bundle: _MapAssetBundle({
          'assets/audio/chapters_v1/7-37.json': jsonEncode(document),
        }),
      );

      final chapter = await source.loadChapterAudio(
        reciterId: 7,
        surahNumber: 37,
      );

      final audio = chapter['audio_file'] as Map<String, dynamic>;
      final timestamps = audio['timestamps'] as List<dynamic>;
      expect(timestamps, hasLength(2));
      expect(
        (timestamps[1] as Map<String, dynamic>)['timestamp_from'],
        1228910,
      );
    },
  );

  test('rejects ayah timestamp starts that move backward', () async {
    final document = _chapterDocument(reciterId: 7, surahNumber: 37);
    document['timestamps'] = [
      {
        'verse_key': '37:151',
        'timestamp_from': 1229000,
        'timestamp_to': 1230000,
        'duration': 1000,
        'segments': const <List<int>>[],
      },
      {
        'verse_key': '37:152',
        'timestamp_from': 1228000,
        'timestamp_to': 1231000,
        'duration': 3000,
        'segments': const <List<int>>[],
      },
    ];
    final source = BundledChapterAudioSource(
      bundle: _MapAssetBundle({
        'assets/audio/chapters_v1/7-37.json': jsonEncode(document),
      }),
    );

    await expectLater(
      source.loadChapterAudio(reciterId: 7, surahNumber: 37),
      throwsFormatException,
    );
  });

  test('rejects malformed JSON', () async {
    final source = BundledChapterAudioSource(
      bundle: _MapAssetBundle({
        'assets/audio/chapters_v1/7-67.json': '{broken',
      }),
    );

    await expectLater(
      source.loadChapterAudio(reciterId: 7, surahNumber: 67),
      throwsFormatException,
    );
  });

  test('rejects unsupported schema version', () async {
    final document = _chapterDocument(reciterId: 7, surahNumber: 67)
      ..['schema_version'] = 2;
    final source = BundledChapterAudioSource(
      bundle: _MapAssetBundle({
        'assets/audio/chapters_v1/7-67.json': jsonEncode(document),
      }),
    );

    await expectLater(
      source.loadChapterAudio(reciterId: 7, surahNumber: 67),
      throwsFormatException,
    );
  });

  test('rejects reciter identity mismatch', () async {
    final source = BundledChapterAudioSource(
      bundle: _MapAssetBundle({
        'assets/audio/chapters_v1/7-67.json': jsonEncode(
          _chapterDocument(reciterId: 8, surahNumber: 67),
        ),
      }),
    );

    await expectLater(
      source.loadChapterAudio(reciterId: 7, surahNumber: 67),
      throwsFormatException,
    );
  });

  test('rejects Surah identity mismatch', () async {
    final source = BundledChapterAudioSource(
      bundle: _MapAssetBundle({
        'assets/audio/chapters_v1/7-67.json': jsonEncode(
          _chapterDocument(reciterId: 7, surahNumber: 68),
        ),
      }),
    );

    await expectLater(
      source.loadChapterAudio(reciterId: 7, surahNumber: 67),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _chapterDocument({
  required int reciterId,
  required int surahNumber,
}) => {
  'schema_version': 1,
  'reciter_id': reciterId,
  'surah_number': surahNumber,
  'audio_file_id': 457,
  'audio_url':
      'https://download.quranicaudio.com/test/$reciterId/$surahNumber.mp3',
  'format': 'mp3',
  'file_size': 710784,
  'timestamps': [
    {
      'verse_key': '$surahNumber:1',
      'timestamp_from': 0,
      'timestamp_to': 6493,
      'duration': 6493,
      'segments': [
        [1, 0, 500],
      ],
    },
  ],
};

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) {
      throw FlutterError('Missing fake asset: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.sublistView(bytes);
  }
}
