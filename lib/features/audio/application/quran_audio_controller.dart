import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player_adapter.dart';
import '../../../core/audio/offline_audio_resolver.dart';
import 'audio_dependencies.dart';
import 'timing_resolver.dart';
import '../domain/audio_timing.dart';
import '../domain/playback_requests.dart';
import '../domain/quran_audio_state.dart';

class QuranAudioController extends Notifier<QuranAudioState> {
  static const _timingResolver = TimingResolver();

  int _sessionToken = 0;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  int? _positionSubscriptionToken;

  AudioPlayerAdapter get _player => ref.read(audioPlayerAdapterProvider);
  PlaybackDelay get _delay => ref.read(playbackDelayProvider);
  TimingRepository get _timings => ref.read(timingRepositoryProvider);
  AudioSourceResolver get _sources => ref.read(audioSourceResolverProvider);

  @override
  QuranAudioState build() {
    final player = ref.read(audioPlayerAdapterProvider);
    ref.onDispose(() {
      ++_sessionToken;
      unawaited(_positionSubscription?.cancel());
      unawaited(_durationSubscription?.cancel());
      unawaited(player.stop());
    });
    return const QuranAudioState.initial();
  }

  Future<void> playWord(WordPlaybackRequest request) async {
    final token = ++_sessionToken;
    state = QuranAudioState(
      mode: QuranAudioMode.word,
      status: QuranAudioStatus.loading,
      speed: request.speed,
      repeatIndex: 0,
      repeatTotal: 1,
      ayahKey: request.ayahKey,
      wordKey: request.wordKey,
      activeWordPosition: request.wordPosition,
      source: request.source,
      position: Duration.zero,
      duration: Duration.zero,
    );

    try {
      await _player.stop();
      if (!_isCurrent(token)) return;
      await _cancelPositionTracking();
      if (!_isCurrent(token)) return;

      final source = await _resolveSource(request.audioKey, request.source);
      if (!_isCurrent(token)) return;
      state = state.copyWith(source: source);

      await _player.setSpeed(request.speed);
      if (!_isCurrent(token)) return;

      await _player.load(source);
      if (!_isCurrent(token)) return;
      await _player.setClip();
      if (!_isCurrent(token)) return;

      _player.play();
      if (!_isCurrent(token)) return;

      state = state.copyWith(status: QuranAudioStatus.playing);
      final terminal = await _player.waitForTerminal();
      if (!_isCurrent(token)) return;

      state = state.copyWith(
        status: terminal == AudioTerminalState.completed
            ? QuranAudioStatus.completed
            : QuranAudioStatus.idle,
        repeatIndex: terminal == AudioTerminalState.completed ? 1 : 0,
        activeWordPosition: null,
      );
    } catch (error) {
      _publishErrorIfCurrent(token, error);
    }
  }

  Future<void> playSurah(SurahPlaybackRequest request) async {
    final token = ++_sessionToken;
    state = QuranAudioState(
      mode: QuranAudioMode.surah,
      status: QuranAudioStatus.loading,
      speed: request.speed,
      repeatIndex: 0,
      repeatTotal: 1,
      source: request.source,
      position: Duration.zero,
      duration: Duration.zero,
    );

    try {
      await _player.stop();
      if (!_isCurrent(token)) return;
      await _cancelPositionTracking();
      if (!_isCurrent(token)) return;

      final source = await _resolveSource(request.audioKey, request.source);
      if (!_isCurrent(token)) return;
      state = state.copyWith(source: source);

      await _player.setSpeed(request.speed);
      if (!_isCurrent(token)) return;

      await _player.load(source);
      if (!_isCurrent(token)) return;
      await _player.setClip();
      if (!_isCurrent(token)) return;
      await _player.seek(Duration.zero);
      if (!_isCurrent(token)) return;

      _player.play();
      if (!_isCurrent(token)) return;
      state = state.copyWith(status: QuranAudioStatus.playing, repeatIndex: 1);

      final terminal = await _player.waitForTerminal();
      if (!_isCurrent(token)) return;
      state = state.copyWith(
        status: terminal == AudioTerminalState.completed
            ? QuranAudioStatus.completed
            : QuranAudioStatus.idle,
      );
    } catch (error) {
      _publishErrorIfCurrent(token, error);
    }
  }

  Future<void> playAyah(AyahPlaybackRequest request) async {
    final token = ++_sessionToken;
    await _playAyahProgram(request, token: token, stopBeforeLoad: true);
  }

  Future<void> _playAyahProgram(
    AyahPlaybackRequest request, {
    required int token,
    required bool stopBeforeLoad,
  }) async {
    state = QuranAudioState(
      mode: QuranAudioMode.ayah,
      status: QuranAudioStatus.loading,
      speed: request.speed,
      repeatIndex: 0,
      repeatTotal: request.repeatCount,
      ayahKey: request.ayahKey,
      source: request.source,
      position: Duration.zero,
      duration: Duration.zero,
    );

    try {
      if (stopBeforeLoad) {
        await _player.stop();
        if (!_isCurrent(token)) return;
        await _cancelPositionTracking();
        if (!_isCurrent(token)) return;
      }

      final timingBundle = await _resolveTimings(request, token);
      if (!_isCurrent(token)) return;
      if (request.timingKey != null && timingBundle.ayah == null) {
        _publishErrorIfCurrent(
          token,
          AudioTimingUnavailableException(request.timingKey!),
        );
        return;
      }

      final source = await _resolveSource(request.audioKey, request.source);
      if (!_isCurrent(token)) return;
      state = state.copyWith(source: source);

      await _player.setSpeed(request.speed);
      if (!_isCurrent(token)) return;

      await _player.load(source);
      if (!_isCurrent(token)) return;

      final ayahTiming = timingBundle.ayah;
      if (ayahTiming != null) {
        await _player.setClip(start: ayahTiming.start, end: ayahTiming.end);
      } else {
        await _player.setClip();
      }
      if (!_isCurrent(token)) return;

      for (var index = 0; index < request.repeatCount; index++) {
        if (!_isCurrent(token)) return;

        await _player.seek(ayahTiming == null ? request.start : Duration.zero);
        if (!_isCurrent(token)) return;

        await _startPositionTracking(
          token: token,
          ayahTiming: ayahTiming,
          wordTimings: timingBundle.words,
        );
        if (!_isCurrent(token)) return;

        _player.play();
        if (!_isCurrent(token)) return;

        state = state.copyWith(
          status: QuranAudioStatus.playing,
          repeatIndex: index + 1,
          activeWordPosition: null,
        );

        final terminal = await _player.waitForTerminal();
        await _cancelPositionTracking(token: token);
        if (!_isCurrent(token)) return;
        if (terminal != AudioTerminalState.completed) {
          state = state.copyWith(
            status: QuranAudioStatus.idle,
            activeWordPosition: null,
          );
          return;
        }

        state = state.copyWith(activeWordPosition: null);
        if (index < request.repeatCount - 1 &&
            request.pauseBetweenRepeats > Duration.zero) {
          await _delay(request.pauseBetweenRepeats);
          if (!_isCurrent(token)) return;
        }
      }

      if (!_isCurrent(token)) return;
      state = state.copyWith(
        status: QuranAudioStatus.completed,
        repeatIndex: request.repeatCount,
        activeWordPosition: null,
      );

      final next = request.autoNext;
      if (next != null && _isCurrent(token)) {
        final nextToken = ++_sessionToken;
        await _playAyahProgram(next, token: nextToken, stopBeforeLoad: true);
      }
    } catch (error) {
      await _cancelPositionTracking(token: token);
      _publishErrorIfCurrent(token, error);
    }
  }

  Future<_TimingBundle> _resolveTimings(
    AyahPlaybackRequest request,
    int token,
  ) async {
    final key = request.timingKey;
    if (key == null) return const _TimingBundle();

    final ayah = await _timings.getAyahTiming(
      reciterId: key.reciterId,
      surahNumber: key.surahNumber,
      ayahNumber: key.ayahNumber,
    );
    if (!_isCurrent(token) || ayah == null) {
      return _TimingBundle(ayah: ayah);
    }

    final words = await _timings.getWordTimings(
      reciterId: key.reciterId,
      surahNumber: key.surahNumber,
      ayahNumber: key.ayahNumber,
    );
    return _TimingBundle(ayah: ayah, words: words);
  }

  Future<void> _startPositionTracking({
    required int token,
    required AyahAudioTiming? ayahTiming,
    required List<WordAudioTiming> wordTimings,
  }) async {
    await _cancelPositionTracking();
    if (!_isCurrent(token)) return;

    _positionSubscriptionToken = token;
    _positionSubscription = _player.positionStream.listen((clipPosition) {
      if (!_isCurrent(token)) return;
      final duration = state.duration;
      final bounded = duration > Duration.zero && clipPosition > duration
          ? duration
          : clipPosition;
      int? active;
      if (ayahTiming != null && wordTimings.isNotEmpty) {
        active = _timingResolver.activeWordAt(
          ayahTiming.start + bounded,
          wordTimings,
        );
      }
      state = state.copyWith(position: bounded, activeWordPosition: active);
    });
    _durationSubscription = _player.durationStream.listen((duration) {
      if (!_isCurrent(token) || duration == null) return;
      state = state.copyWith(
        duration: duration,
        position: state.position > duration ? duration : state.position,
      );
    });
  }

  Future<void> _cancelPositionTracking({int? token}) async {
    if (token != null && _positionSubscriptionToken != token) return;
    final subscription = _positionSubscription;
    if (subscription == null) return;

    _positionSubscription = null;
    _positionSubscriptionToken = null;
    await subscription.cancel();
    final durationSubscription = _durationSubscription;
    _durationSubscription = null;
    await durationSubscription?.cancel();
  }

  Future<void> pause() async {
    final token = _sessionToken;
    await _player.pause();
    if (!_isCurrent(token)) return;
    state = state.copyWith(status: QuranAudioStatus.paused);
  }

  void resume() {
    if (state.status != QuranAudioStatus.paused) return;
    _player.play();
    state = state.copyWith(status: QuranAudioStatus.playing);
  }

  Future<void> seek(Duration requested) async {
    if (state.mode != QuranAudioMode.ayah || state.duration <= Duration.zero) {
      return;
    }
    final target = requested < Duration.zero
        ? Duration.zero
        : requested > state.duration
        ? state.duration
        : requested;
    await _player.seek(target);
    state = state.copyWith(position: target);
  }

  Future<void> stop() async {
    ++_sessionToken;
    final player = _player;
    final speed = state.speed;
    state = QuranAudioState(
      mode: QuranAudioMode.idle,
      status: QuranAudioStatus.idle,
      speed: speed,
      repeatIndex: 0,
      repeatTotal: 0,
    );
    await _cancelPositionTracking();
    await player.stop();
  }

  Future<void> setSpeed(double speed) async {
    if (speed <= 0) {
      throw ArgumentError.value(speed, 'speed', 'must be greater than zero');
    }
    final token = _sessionToken;
    await _player.setSpeed(speed);
    if (!_isCurrent(token)) return;
    state = state.copyWith(speed: speed);
  }

  Future<String> _resolveSource(String? audioKey, String fallback) async {
    if (audioKey == null) return fallback;
    final resolved = await _sources.resolve(audioKey);
    return resolved ?? fallback;
  }

  bool _isCurrent(int token) => token == _sessionToken;

  void _publishErrorIfCurrent(int token, Object error) {
    if (!_isCurrent(token)) return;
    state = state.copyWith(
      status: QuranAudioStatus.error,
      activeWordPosition: null,
      error: error,
    );
  }
}

class _TimingBundle {
  const _TimingBundle({this.ayah, this.words = const []});

  final AyahAudioTiming? ayah;
  final List<WordAudioTiming> words;
}
