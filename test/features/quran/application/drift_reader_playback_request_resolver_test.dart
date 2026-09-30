import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/quran/application/reader_audio_actions.dart';
import 'package:quran_hifz/features/quran/data/quran_audio_sync_service.dart';
import 'package:quran_hifz/features/reciters/data/quran_reciter_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';

void main() {
  test(
    'ayah playback keeps fallback word positions when exact segments are missing',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await database.saveSetting(
        QuranReciterRepository.selectedReciterKey,
        '7',
      );
      final sync = _RecordingAudioSync(database: database);
      final resolver = DriftReaderPlaybackRequestResolver(
        database: database,
        syncService: sync,
      );
      const ayah = QuranAyah(
        surahNumber: 4,
        ayahNumber: 14,
        words: [
          QuranWord(position: 1, arabic: 'one'),
          QuranWord(position: 2, arabic: 'two'),
          QuranWord(position: 3, arabic: 'three'),
        ],
      );

      final request = await resolver.resolveAyah(
        ayah,
        repeatCount: 1,
        pauseBetweenRepeats: Duration.zero,
        speed: 1,
      );

      expect(request.ayahKey, '4:14');
      expect(request.fallbackWordPositions, [1, 2, 3]);
      expect(sync.chapterCalls, [(reciterId: 7, surahNumber: 4)]);
    },
  );

  test(
    'word playback starts remote playback and schedules offline cache',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final sync = _RecordingAudioSync();
      final resolver = DriftReaderPlaybackRequestResolver(
        database: database,
        syncService: sync,
      );
      const word = QuranWord(
        position: 2,
        arabic: 'بِسْمِ',
        audioUrl: 'wbw/001_001_002.mp3',
      );
      const ayah = QuranAyah(surahNumber: 1, ayahNumber: 1, words: [word]);

      final request = await resolver.resolveWord(ayah, word);
      await Future<void>.delayed(Duration.zero);

      expect(request.audioKey, 'word:1:1:2');
      expect(request.source, endsWith('wbw/001_001_002.mp3'));
      expect(sync.wordCacheCalls, [
        (
          surahNumber: 1,
          ayahNumber: 1,
          wordPosition: 2,
          relativeAudioPath: 'wbw/001_001_002.mp3',
        ),
      ]);
    },
  );
}

class _RecordingAudioSync implements QuranAudioSync {
  _RecordingAudioSync({this.database});

  final UserDatabase? database;
  final chapterCalls = <({int reciterId, int surahNumber})>[];
  final wordCacheCalls =
      <
        ({
          int surahNumber,
          int ayahNumber,
          int wordPosition,
          String relativeAudioPath,
        })
      >[];

  @override
  Future<String?> cacheWordAudio({
    required int surahNumber,
    required int ayahNumber,
    required int wordPosition,
    required String relativeAudioPath,
  }) async {
    wordCacheCalls.add((
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      wordPosition: wordPosition,
      relativeAudioPath: relativeAudioPath,
    ));
    return '/cache/word.mp3';
  }

  @override
  Future<ChapterAudioSyncResult> syncChapter({
    required int reciterId,
    required int surahNumber,
    bool downloadAudio = true,
  }) async {
    chapterCalls.add((reciterId: reciterId, surahNumber: surahNumber));
    final db = database;
    if (db == null) throw StateError('database is required for chapter sync');
    await db.registerAudioSource(
      audioKey: 'chapter:$reciterId:$surahNumber',
      audioType: 'chapter',
      remoteUrl: 'https://example.test/$surahNumber.mp3',
      reciterId: reciterId,
      surahNumber: surahNumber,
      format: 'mp3',
    );
    await db.replaceTimings(
      reciterId: reciterId,
      surahNumber: surahNumber,
      timestamps: [
        {
          'verse_key': '$surahNumber:14',
          'timestamp_from': 100,
          'timestamp_to': 900,
          'segments': <List<int>>[],
        },
      ],
    );
    return ChapterAudioSyncResult(
      reciterId: reciterId,
      surahNumber: surahNumber,
      remoteUrl: 'https://example.test/$surahNumber.mp3',
      localPath: null,
      format: 'mp3',
      fileSize: null,
      ayahTimingCount: 1,
    );
  }
}
