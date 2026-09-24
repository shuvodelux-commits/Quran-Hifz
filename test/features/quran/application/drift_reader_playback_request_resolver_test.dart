import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/quran/application/reader_audio_actions.dart';
import 'package:quran_hifz/features/quran/data/quran_audio_sync_service.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';

void main() {
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
  }) => throw UnimplementedError();
}
