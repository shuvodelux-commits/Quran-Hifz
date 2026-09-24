import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/domain/playback_requests.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/quran/application/reader_audio_actions.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_juz.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/domain/reader_scope.dart';
import 'package:quran_hifz/features/study/domain/bookmark.dart';

QuranAyah _ayah(int number) => QuranAyah(
  surahNumber: 67,
  ayahNumber: number,
  words: [
    QuranWord(
      position: 1,
      arabic: 'word-$number',
      audioUrl: 'wbw/067_${number.toString().padLeft(3, '0')}_001.mp3',
    ),
  ],
);

class _FakeRepository implements QuranRepository {
  _FakeRepository(this.ayahs, {this.surahs = const []});

  @override
  Future<List<QuranJuzSummary>> listJuzs() async => const [];

  final Map<String, QuranAyah> ayahs;
  final List<QuranSurahSummary> surahs;

  @override
  Future<QuranAyah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
    required int translationResourceId,
  }) async => ayahs['$surahNumber:$ayahNumber'];

  @override
  Future<QuranPageWindow> loadPageWindow({
    required int page,
    required int translationResourceId,
  }) => throw UnimplementedError();

  @override
  Future<List<QuranSurahSummary>> listSurahs() async => surahs;
}

class _FakeResolver implements ReaderPlaybackRequestResolver {
  @override
  Future<AyahPlaybackRequest> resolveAyah(
    QuranAyah ayah, {
    required int repeatCount,
    required Duration pauseBetweenRepeats,
    required double speed,
  }) async => AyahPlaybackRequest(
    source: 'chapter-${ayah.surahNumber}.mp3',
    ayahKey: ayah.key,
    repeatCount: repeatCount,
    pauseBetweenRepeats: pauseBetweenRepeats,
    speed: speed,
  );

  @override
  Future<WordPlaybackRequest> resolveWord(
    QuranAyah ayah,
    QuranWord word,
  ) async => WordPlaybackRequest(
    source: word.audioUrl!,
    wordKey: '${ayah.key}:${word.position}',
    ayahKey: ayah.key,
    wordPosition: word.position,
  );
}

class _DelayedWordResolver extends _FakeResolver {
  final firstWord = Completer<WordPlaybackRequest>();

  @override
  Future<WordPlaybackRequest> resolveWord(QuranAyah ayah, QuranWord word) {
    if (word.position == 1) return firstWord.future;
    return super.resolveWord(ayah, word);
  }
}

class _FakeAudioPort implements ReaderAudioPort {
  final playedAyahs = <AyahPlaybackRequest>[];
  final playedWords = <WordPlaybackRequest>[];
  Completer<void>? blockNextAyah;
  QuranAudioState currentState = const QuranAudioState.initial();

  @override
  Future<void> playAyah(AyahPlaybackRequest request) async {
    playedAyahs.add(request);
    final blocker = blockNextAyah;
    blockNextAyah = null;
    if (blocker != null) await blocker.future;
    currentState = QuranAudioState(
      mode: QuranAudioMode.ayah,
      status: QuranAudioStatus.completed,
      speed: request.speed,
      repeatIndex: request.repeatCount,
      repeatTotal: request.repeatCount,
      ayahKey: request.ayahKey,
    );
  }

  @override
  Future<void> playWord(WordPlaybackRequest request) async {
    playedWords.add(request);
  }

  @override
  QuranAudioState readState() => currentState;

  @override
  Future<void> stop() async {}
}

void main() {
  test(
    'adjacent ayah crosses Surahs only when the reader scope allows it',
    () async {
      const first = QuranSurahSummary(
        number: 1,
        nameArabic: 'One',
        nameEnglish: 'One',
        ayahCount: 1,
        pageStart: 1,
        pageEnd: 1,
        juzStart: 1,
      );
      const second = QuranSurahSummary(
        number: 2,
        nameArabic: 'Two',
        nameEnglish: 'Two',
        ayahCount: 2,
        pageStart: 1,
        pageEnd: 2,
        juzStart: 1,
      );
      const oneOne = QuranAyah(
        surahNumber: 1,
        ayahNumber: 1,
        pageNumber: 1,
        juzNumber: 1,
        words: [],
      );
      const twoOne = QuranAyah(
        surahNumber: 2,
        ayahNumber: 1,
        pageNumber: 1,
        juzNumber: 1,
        words: [],
      );
      final actions = ReaderAudioActions(
        repository: _FakeRepository(
          {'1:1': oneOne, '2:1': twoOne},
          surahs: const [first, second],
        ),
        resolver: _FakeResolver(),
        audio: _FakeAudioPort(),
        translationResourceId: 1,
      );

      final inJuz = await actions.adjacentAyah(
        oneOne,
        forward: true,
        scope: JuzReaderScope(
          juz: QuranJuzSummary(
            number: 1,
            firstTarget: const StudyTarget.ayah(surahNumber: 1, ayahNumber: 1),
            lastTarget: const StudyTarget.ayah(surahNumber: 2, ayahNumber: 1),
            firstPage: 1,
            lastPage: 1,
            startSurahNumber: 1,
            endSurahNumber: 2,
          ),
        ),
      );
      final inSurah = await actions.adjacentAyah(
        oneOne,
        forward: true,
        scope: const SurahReaderScope(surah: first),
      );

      expect(inJuz?.key, '2:1');
      expect(inSurah, isNull);
    },
  );

  test('repeats an ayah then advances within the same Surah', () async {
    final audio = _FakeAudioPort();
    final actions = ReaderAudioActions(
      repository: _FakeRepository({'67:1': _ayah(1), '67:2': _ayah(2)}),
      resolver: _FakeResolver(),
      audio: audio,
      translationResourceId: 1,
    );

    await actions.playAyah(
      _ayah(1),
      repeatCount: 5,
      speed: 0.75,
      pauseBetweenRepeats: const Duration(seconds: 1),
      autoNext: true,
    );

    expect(audio.playedAyahs.map((item) => item.ayahKey).toList(), [
      '67:1',
      '67:2',
    ]);
    expect(audio.playedAyahs.first.repeatCount, 5);
    expect(audio.playedAyahs.first.speed, 0.75);
  });

  test(
    'does not cross into another Surah when the next ayah is absent',
    () async {
      final audio = _FakeAudioPort();
      final actions = ReaderAudioActions(
        repository: _FakeRepository({'67:30': _ayah(30)}),
        resolver: _FakeResolver(),
        audio: audio,
        translationResourceId: 1,
      );

      await actions.playAyah(
        _ayah(30),
        repeatCount: 1,
        speed: 1,
        pauseBetweenRepeats: Duration.zero,
        autoNext: true,
      );

      expect(audio.playedAyahs.single.ayahKey, '67:30');
    },
  );

  test('word tap invalidates a pending reader auto-next sequence', () async {
    final blocker = Completer<void>();
    final audio = _FakeAudioPort()..blockNextAyah = blocker;
    final actions = ReaderAudioActions(
      repository: _FakeRepository({'67:1': _ayah(1), '67:2': _ayah(2)}),
      resolver: _FakeResolver(),
      audio: audio,
      translationResourceId: 1,
    );

    final playback = actions.playAyah(
      _ayah(1),
      repeatCount: 1,
      speed: 1,
      pauseBetweenRepeats: Duration.zero,
      autoNext: true,
    );
    await Future<void>.delayed(Duration.zero);

    await actions.playWord(_ayah(1), _ayah(1).words.first);
    blocker.complete();
    await playback;

    expect(audio.playedAyahs.map((item) => item.ayahKey).toList(), ['67:1']);
    expect(audio.playedWords.single.ayahKey, '67:1');
    expect(audio.playedWords.single.wordPosition, 1);
  });

  test(
    'a slow first word request cannot replace the newer tapped word',
    () async {
      const ayah = QuranAyah(
        surahNumber: 67,
        ayahNumber: 1,
        words: [
          QuranWord(position: 1, arabic: 'first', audioUrl: 'first.mp3'),
          QuranWord(position: 2, arabic: 'second', audioUrl: 'second.mp3'),
        ],
      );
      final resolver = _DelayedWordResolver();
      final audio = _FakeAudioPort();
      final actions = ReaderAudioActions(
        repository: _FakeRepository({ayah.key: ayah}),
        resolver: resolver,
        audio: audio,
        translationResourceId: 1,
      );

      final first = actions.playWord(ayah, ayah.words.first);
      final second = actions.playWord(ayah, ayah.words.last);
      await second;
      resolver.firstWord.complete(
        const WordPlaybackRequest(
          source: 'first.mp3',
          wordKey: '67:1:1',
          ayahKey: '67:1',
          wordPosition: 1,
        ),
      );
      await first;

      expect(audio.playedWords.map((request) => request.wordPosition), [2]);
    },
  );
}
