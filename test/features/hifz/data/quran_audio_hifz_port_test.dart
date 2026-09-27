import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/audio/domain/playback_requests.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/hifz/data/quran_audio_hifz_port.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_audio_port.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_step.dart';
import 'package:quran_hifz/features/quran/data/quran_audio_sync_service.dart';

void main() {
  test('resolver lazily syncs missing chapter metadata and timing', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.saveSetting(selectedReciterSettingKey, '7');
    final sync = _FakeAudioSync(database);
    final resolver = DriftHifzPlaybackRequestResolver(
      database: database,
      syncService: sync,
    );

    final request = await resolver.resolve(
      const AyahRef(surahNumber: 67, ayahNumber: 1),
      repeatCount: 3,
      pauseBetweenRepeats: const Duration(seconds: 1),
    );

    expect(sync.chapterCalls, [(reciterId: 7, surahNumber: 67)]);
    expect(request.source, 'https://example.test/67.mp3');
    expect(request.audioKey, 'chapter:7:67');
    expect(request.speed, 1.0);
    expect(request.timingKey, isNotNull);
  });

  test(
    'resolver fails when sync still cannot provide verified timing',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await database.saveSetting(selectedReciterSettingKey, '7');
      final sync = _FakeAudioSync(database, includeTiming: false);
      final resolver = DriftHifzPlaybackRequestResolver(
        database: database,
        syncService: sync,
      );

      await expectLater(
        resolver.resolve(
          const AyahRef(surahNumber: 67, ayahNumber: 1),
          repeatCount: 1,
          pauseBetweenRepeats: Duration.zero,
        ),
        throwsA(isA<HifzAudioUnavailableException>()),
      );
    },
  );

  test('ayah step exposes repeat progress and plays each repetition', () async {
    final played = <String>[];
    final progress = <HifzStepProgress>[];
    var state = const QuranAudioState.initial();
    final resolver = _FakeResolver();
    final port = QuranAudioHifzPort(
      playAyah: (request) async {
        played.add(request.ayahKey);
        state = QuranAudioState(
          mode: QuranAudioMode.ayah,
          status: QuranAudioStatus.completed,
          speed: 1,
          repeatIndex: 1,
          repeatTotal: 1,
          ayahKey: request.ayahKey,
        );
      },
      pause: () async {},
      resume: () {},
      stop: () async {},
      readState: () => state,
      resolver: resolver,
      delay: (_) async {},
    );

    await port.playStep(
      const AyahStep(
        ayah: AyahRef(surahNumber: 67, ayahNumber: 1),
        repeatCount: 3,
        pauseBetweenRepeats: Duration.zero,
      ),
      onProgress: progress.add,
    );

    expect(played, ['67:1']);
    expect(progress.map((item) => item.repeatIndex), [0, 3]);
    expect(progress.map((item) => item.repeatTotal), everyElement(3));
    expect(resolver.repeatCounts, [3]);
  });

  test('range step repeats the whole ayah range in canonical order', () async {
    final played = <String>[];
    final delays = <Duration>[];
    final progress = <HifzStepProgress>[];
    var state = const QuranAudioState.initial();
    final resolver = _FakeResolver();
    final port = QuranAudioHifzPort(
      playAyah: (request) async {
        played.add(request.ayahKey);
        state = QuranAudioState(
          mode: QuranAudioMode.ayah,
          status: QuranAudioStatus.completed,
          speed: 1,
          repeatIndex: 1,
          repeatTotal: 1,
          ayahKey: request.ayahKey,
        );
      },
      pause: () async {},
      resume: () {},
      stop: () async {},
      readState: () => state,
      resolver: resolver,
      delay: (duration) async => delays.add(duration),
    );

    await port.playStep(
      const RangeStep(
        start: AyahRef(surahNumber: 67, ayahNumber: 1),
        end: AyahRef(surahNumber: 67, ayahNumber: 2),
        repeatCount: 3,
        pauseBetweenRepeats: Duration(seconds: 1),
      ),
      onProgress: progress.add,
    );

    expect(played, ['67:1', '67:2', '67:1', '67:2', '67:1', '67:2']);
    expect(delays, const [Duration(seconds: 1), Duration(seconds: 1)]);
    expect(progress.map((item) => item.repeatIndex), [1, 2, 3]);
    expect(resolver.repeatCounts, everyElement(1));
    expect(resolver.pauseDurations, everyElement(Duration.zero));
  });

  test(
    'notification-panel stop is surfaced as intentional Hifz stop',
    () async {
      var state = const QuranAudioState.initial();
      final port = QuranAudioHifzPort(
        playAyah: (request) async {
          state = const QuranAudioState.initial();
        },
        pause: () async {},
        resume: () {},
        stop: () async {},
        readState: () => state,
        resolver: _FakeResolver(),
        delay: (_) async {},
      );

      await expectLater(
        port.playStep(
          const AyahStep(
            ayah: AyahRef(surahNumber: 67, ayahNumber: 1),
            repeatCount: 1,
            pauseBetweenRepeats: Duration.zero,
          ),
        ),
        throwsA(isA<HifzPlaybackStoppedException>()),
      );
    },
  );
}

class _FakeResolver implements HifzPlaybackRequestResolver {
  final List<int> repeatCounts = [];
  final List<Duration> pauseDurations = [];

  @override
  Future<AyahPlaybackRequest> resolve(
    AyahRef ayah, {
    required int repeatCount,
    required Duration pauseBetweenRepeats,
  }) async {
    repeatCounts.add(repeatCount);
    pauseDurations.add(pauseBetweenRepeats);
    return AyahPlaybackRequest(
      source: 'fixture://${ayah.verseKey}',
      ayahKey: ayah.verseKey,
      repeatCount: repeatCount,
      pauseBetweenRepeats: pauseBetweenRepeats,
    );
  }
}

class _FakeAudioSync implements QuranAudioSync {
  _FakeAudioSync(this.database, {this.includeTiming = true});

  final UserDatabase database;
  final bool includeTiming;
  final chapterCalls = <({int reciterId, int surahNumber})>[];

  @override
  Future<ChapterAudioSyncResult> syncChapter({
    required int reciterId,
    required int surahNumber,
    bool downloadAudio = true,
  }) async {
    chapterCalls.add((reciterId: reciterId, surahNumber: surahNumber));
    await database.registerAudioSource(
      audioKey: 'chapter:$reciterId:$surahNumber',
      audioType: 'chapter',
      remoteUrl: 'https://example.test/$surahNumber.mp3',
      reciterId: reciterId,
      surahNumber: surahNumber,
      format: 'mp3',
    );
    if (includeTiming) {
      await database.replaceTimings(
        reciterId: reciterId,
        surahNumber: surahNumber,
        timestamps: const [
          {
            'verse_key': '67:1',
            'timestamp_from': 100,
            'timestamp_to': 900,
            'segments': <List<int>>[],
          },
        ],
      );
    }
    return ChapterAudioSyncResult(
      reciterId: reciterId,
      surahNumber: surahNumber,
      remoteUrl: 'https://example.test/$surahNumber.mp3',
      localPath: null,
      format: 'mp3',
      fileSize: null,
      ayahTimingCount: includeTiming ? 1 : 0,
    );
  }

  @override
  Future<String?> cacheWordAudio({
    required int surahNumber,
    required int ayahNumber,
    required int wordPosition,
    required String relativeAudioPath,
  }) async => null;
}
