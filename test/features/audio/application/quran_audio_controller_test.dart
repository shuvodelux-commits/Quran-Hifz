import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/audio/offline_audio_resolver.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/domain/playback_requests.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';

import '../../../fakes/fake_audio_player_adapter.dart';

void main() {
  test('playWord stops the previous playback program', () async {
    final fake = FakeAudioPlayerAdapter(autoComplete: false);
    final container = _container(fake);
    addTearDown(container.dispose);
    final controller = container.read(quranAudioControllerProvider.notifier);

    final ayahFuture = controller.playAyah(
      const AyahPlaybackRequest(
        source: 'surah-a.mp3',
        ayahKey: '1:1',
        repeatCount: 2,
      ),
    );
    await _flush();

    final wordFuture = controller.playWord(
      const WordPlaybackRequest(source: 'word-b.mp3', wordKey: '1:1:2'),
    );
    await _flush();

    expect(
      fake.loadedSources,
      containsAllInOrder(['surah-a.mp3', 'word-b.mp3']),
    );
    expect(fake.stopCalls, greaterThanOrEqualTo(2));

    fake.completeCurrent();
    await wordFuture;
    await ayahFuture;
    expect(
      container.read(quranAudioControllerProvider).mode,
      QuranAudioMode.word,
    );
  });

  test('starting ayah B during ayah A repeat invalidates A', () async {
    final fake = FakeAudioPlayerAdapter(autoComplete: false);
    final container = _container(fake);
    addTearDown(container.dispose);
    final controller = container.read(quranAudioControllerProvider.notifier);

    final first = controller.playAyah(
      const AyahPlaybackRequest(
        source: 'a.mp3',
        ayahKey: '2:1',
        repeatCount: 5,
      ),
    );
    await _flush();

    final second = controller.playAyah(
      const AyahPlaybackRequest(source: 'b.mp3', ayahKey: '2:2'),
    );
    await _flush();
    fake.completeCurrent();

    await second;
    await first;

    expect(fake.loadedSources.where((source) => source == 'a.mp3').length, 1);
    expect(fake.loadedSources.last, 'b.mp3');
    expect(container.read(quranAudioControllerProvider).ayahKey, '2:2');
  });

  test('repeat count N executes exactly N times', () async {
    final fake = FakeAudioPlayerAdapter(autoComplete: true);
    final container = _container(fake);
    addTearDown(container.dispose);

    await container
        .read(quranAudioControllerProvider.notifier)
        .playAyah(
          const AyahPlaybackRequest(
            source: 'repeat.mp3',
            ayahKey: '67:1',
            repeatCount: 5,
          ),
        );

    expect(fake.playCalls, 5);
    expect(fake.seekPositions.length, 5);
    final state = container.read(quranAudioControllerProvider);
    expect(state.status, QuranAudioStatus.completed);
    expect(state.repeatIndex, 5);
    expect(state.repeatTotal, 5);
  });

  test('stop during inter-repeat delay prevents restart', () async {
    final fake = FakeAudioPlayerAdapter(autoComplete: true);
    final delays = ControllableDelay();
    final container = _container(fake, delay: delays.call);
    addTearDown(container.dispose);
    final controller = container.read(quranAudioControllerProvider.notifier);

    final program = controller.playAyah(
      const AyahPlaybackRequest(
        source: 'repeat.mp3',
        ayahKey: '67:2',
        repeatCount: 2,
        pauseBetweenRepeats: Duration(seconds: 1),
      ),
    );
    await _waitUntil(() => delays.pendingCount == 1);

    await controller.stop();
    delays.releaseAll();
    await program;

    expect(fake.playCalls, 1);
    expect(
      container.read(quranAudioControllerProvider).status,
      QuranAudioStatus.idle,
    );
  });

  test('auto-next cannot execute from a stale session', () async {
    final fake = FakeAudioPlayerAdapter(autoComplete: false);
    final container = _container(fake);
    addTearDown(container.dispose);
    final controller = container.read(quranAudioControllerProvider.notifier);

    final first = controller.playAyah(
      const AyahPlaybackRequest(
        source: 'a.mp3',
        ayahKey: '1:1',
        autoNext: AyahPlaybackRequest(source: 'c.mp3', ayahKey: '1:2'),
      ),
    );
    await _flush();

    final replacement = controller.playAyah(
      const AyahPlaybackRequest(source: 'b.mp3', ayahKey: '2:1'),
    );
    await _flush();
    fake.completeCurrent();

    await replacement;
    await first;

    expect(fake.loadedSources, isNot(contains('c.mp3')));
    expect(fake.loadedSources.last, 'b.mp3');
  });

  test('speed update applies to the active player', () async {
    final fake = FakeAudioPlayerAdapter(autoComplete: false);
    final container = _container(fake);
    addTearDown(container.dispose);
    final controller = container.read(quranAudioControllerProvider.notifier);

    final word = controller.playWord(
      const WordPlaybackRequest(source: 'word.mp3', wordKey: '1:1:1'),
    );
    await _flush();

    await controller.setSpeed(0.75);

    expect(fake.speeds.last, 0.75);
    expect(container.read(quranAudioControllerProvider).speed, 0.75);

    await controller.stop();
    await word;
  });

  test('ayah playback publishes clip progress and clamps seeking', () async {
    final fake = FakeAudioPlayerAdapter(autoComplete: false);
    final container = _container(fake);
    addTearDown(container.dispose);
    final controller = container.read(quranAudioControllerProvider.notifier);

    final playback = controller.playAyah(
      const AyahPlaybackRequest(source: 'ayah.mp3', ayahKey: '2:255'),
    );
    await _flush();
    fake.emitDuration(const Duration(seconds: 12));
    fake.emitPosition(const Duration(seconds: 4));
    await _flush();

    var state = container.read(quranAudioControllerProvider);
    expect(state.position, const Duration(seconds: 4));
    expect(state.duration, const Duration(seconds: 12));

    await controller.seek(const Duration(seconds: 99));
    expect(fake.seekPositions.last, const Duration(seconds: 12));
    state = container.read(quranAudioControllerProvider);
    expect(state.position, const Duration(seconds: 12));

    await controller.stop();
    await playback;
  });

  test(
    'word playback exposes the tapped ayah word then clears highlight',
    () async {
      final fake = FakeAudioPlayerAdapter(autoComplete: false);
      final container = _container(fake);
      addTearDown(container.dispose);
      final controller = container.read(quranAudioControllerProvider.notifier);

      final playback = controller.playWord(
        const WordPlaybackRequest(
          source: 'word.mp3',
          wordKey: '1:1:2',
          ayahKey: '1:1',
          wordPosition: 2,
        ),
      );
      await _flush();

      var state = container.read(quranAudioControllerProvider);
      expect(state.ayahKey, '1:1');
      expect(state.activeWordPosition, 2);

      fake.completeCurrent();
      await playback;

      state = container.read(quranAudioControllerProvider);
      expect(state.activeWordPosition, isNull);
    },
  );

  test(
    'audioKey resolves a local source before loading remote fallback',
    () async {
      final fake = FakeAudioPlayerAdapter(autoComplete: true);
      final container = ProviderContainer(
        overrides: [
          audioPlayerAdapterProvider.overrideWithValue(fake),
          audioSourceResolverProvider.overrideWithValue(
            _FakeAudioSourceResolver('/local/quran/001.mp3'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(quranAudioControllerProvider.notifier)
          .playAyah(
            const AyahPlaybackRequest(
              source: 'https://example.test/001.mp3',
              audioKey: 'chapter:7:1',
              ayahKey: '1:1',
            ),
          );

      expect(fake.loadedSources.single, '/local/quran/001.mp3');
      expect(
        container.read(quranAudioControllerProvider).source,
        '/local/quran/001.mp3',
      );
    },
  );

  test(
    'playSurah loads the resolved chapter source and starts playback',
    () async {
      final fake = FakeAudioPlayerAdapter(autoComplete: true);
      final container = ProviderContainer(
        overrides: [
          audioPlayerAdapterProvider.overrideWithValue(fake),
          audioSourceResolverProvider.overrideWithValue(
            _FakeAudioSourceResolver('/offline/reciters/7/001.mp3'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(quranAudioControllerProvider.notifier)
          .playSurah(
            const SurahPlaybackRequest(
              source: 'https://download.quranicaudio.com/test/001.mp3',
              audioKey: 'chapter:7:1',
              surahNumber: 1,
            ),
          );

      expect(fake.loadedSources, ['/offline/reciters/7/001.mp3']);
      expect(fake.playCalls, 1);
      expect(fake.clips.single.start, isNull);
      expect(fake.clips.single.end, isNull);
      expect(fake.seekPositions.single, Duration.zero);
      final state = container.read(quranAudioControllerProvider);
      expect(state.mode, QuranAudioMode.surah);
      expect(state.status, QuranAudioStatus.completed);
    },
  );
}

ProviderContainer _container(
  FakeAudioPlayerAdapter fake, {
  PlaybackDelay? delay,
}) {
  return ProviderContainer(
    overrides: [
      audioPlayerAdapterProvider.overrideWithValue(fake),
      if (delay != null) playbackDelayProvider.overrideWithValue(delay),
    ],
  );
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

Future<void> _waitUntil(bool Function() condition) async {
  for (var i = 0; i < 50; i++) {
    if (condition()) return;
    await _flush();
  }
  fail('Condition was not reached');
}

class _FakeAudioSourceResolver implements AudioSourceResolver {
  const _FakeAudioSourceResolver(this.source);

  final String? source;

  @override
  Future<String?> resolve(String audioKey) async => source;
}
