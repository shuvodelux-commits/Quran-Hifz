import '../../../core/database/user_database.dart';
import '../../audio/domain/audio_timing.dart';
import '../../audio/domain/playback_requests.dart';
import '../../audio/domain/quran_audio_state.dart';
import '../../quran/data/quran_audio_sync_service.dart';
import '../domain/hifz_audio_port.dart';
import '../domain/hifz_session.dart';
import '../domain/hifz_step.dart';

const selectedReciterSettingKey = 'selected_reciter_id';

typedef HifzDelay = Future<void> Function(Duration duration);
typedef HifzFallbackWordPositionsLoader =
    Future<List<int>> Function(AyahRef ayah);

class HifzAudioUnavailableException implements Exception {
  const HifzAudioUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class HifzPlaybackRequestResolver {
  Future<AyahPlaybackRequest> resolve(
    AyahRef ayah, {
    required int repeatCount,
    required Duration pauseBetweenRepeats,
  });
}

class DriftHifzPlaybackRequestResolver implements HifzPlaybackRequestResolver {
  DriftHifzPlaybackRequestResolver({
    required UserDatabase database,
    required QuranAudioSync syncService,
    HifzFallbackWordPositionsLoader? fallbackWordPositionsLoader,
  }) : _database = database,
       _syncService = syncService,
       _fallbackWordPositionsLoader = fallbackWordPositionsLoader;

  final UserDatabase _database;
  final QuranAudioSync _syncService;
  final HifzFallbackWordPositionsLoader? _fallbackWordPositionsLoader;
  final Set<String> _wordTimingRefreshAttemptedChapters = <String>{};

  @override
  Future<AyahPlaybackRequest> resolve(
    AyahRef ayah, {
    required int repeatCount,
    required Duration pauseBetweenRepeats,
  }) async {
    final rawReciterId = await _database.getSetting(selectedReciterSettingKey);
    final reciterId = int.tryParse(rawReciterId ?? '');
    if (reciterId == null || reciterId <= 0) {
      throw const HifzAudioUnavailableException(
        'Select a reciter before starting Hifz playback.',
      );
    }

    final audioKey = 'chapter:$reciterId:${ayah.surahNumber}';
    var audio = await _database.getAudio(audioKey);
    var timing = await _database.getAyahTiming(
      reciterId: reciterId,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
    );
    var hasWordTiming =
        timing != null &&
        (await _database.getWordTimings(
          reciterId: reciterId,
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
        )).isNotEmpty;
    final refreshKey = '$reciterId:${ayah.surahNumber}';
    final shouldRefreshWordTiming =
        timing != null &&
        !hasWordTiming &&
        _wordTimingRefreshAttemptedChapters.add(refreshKey);

    if (audio == null ||
        audio.remoteUrl.isEmpty ||
        timing == null ||
        shouldRefreshWordTiming) {
      await _syncService.syncChapter(
        reciterId: reciterId,
        surahNumber: ayah.surahNumber,
        downloadAudio: false,
      );
      audio = await _database.getAudio(audioKey);
      timing = await _database.getAyahTiming(
        reciterId: reciterId,
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
      );
      hasWordTiming =
          timing != null &&
          (await _database.getWordTimings(
            reciterId: reciterId,
            surahNumber: ayah.surahNumber,
            ayahNumber: ayah.ayahNumber,
          )).isNotEmpty;
      if (!hasWordTiming) {
        _wordTimingRefreshAttemptedChapters.add(refreshKey);
      }
    }

    if (audio == null || audio.remoteUrl.isEmpty) {
      throw HifzAudioUnavailableException(
        'Audio metadata is unavailable for Surah ${ayah.surahNumber}.',
      );
    }
    if (timing == null || timing.endMs <= timing.startMs) {
      throw HifzAudioUnavailableException(
        'Verified ayah timing is unavailable for ${ayah.verseKey}.',
      );
    }

    final fallbackWordPositions =
        !hasWordTiming && _fallbackWordPositionsLoader != null
        ? await _fallbackWordPositionsLoader(ayah)
        : const <int>[];

    return AyahPlaybackRequest(
      source: audio.remoteUrl,
      audioKey: audioKey,
      ayahKey: ayah.verseKey,
      repeatCount: repeatCount,
      pauseBetweenRepeats: pauseBetweenRepeats,
      speed: 1.0,
      timingKey: AudioTimingKey(
        reciterId: reciterId,
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
      ),
      fallbackWordPositions: fallbackWordPositions,
    );
  }
}

class QuranAudioHifzPort implements HifzAudioPort {
  QuranAudioHifzPort({
    required Future<void> Function(AyahPlaybackRequest request) playAyah,
    required Future<void> Function() pause,
    required void Function() resume,
    required Future<void> Function() stop,
    required QuranAudioState Function() readState,
    required HifzPlaybackRequestResolver resolver,
    required HifzDelay delay,
  }) : _playAyah = playAyah,
       _pause = pause,
       _resume = resume,
       _stop = stop,
       _readState = readState,
       _resolver = resolver,
       _delay = delay;

  final Future<void> Function(AyahPlaybackRequest request) _playAyah;
  final Future<void> Function() _pause;
  final void Function() _resume;
  final Future<void> Function() _stop;
  final QuranAudioState Function() _readState;
  final HifzPlaybackRequestResolver _resolver;
  final HifzDelay _delay;

  int _programToken = 0;

  @override
  Future<void> playStep(
    HifzStep step, {
    HifzStepProgressCallback? onProgress,
  }) async {
    final token = ++_programToken;

    if (step is AyahStep) {
      onProgress?.call(
        HifzStepProgress(repeatIndex: 0, repeatTotal: step.repeatCount),
      );
      await _playSingleAyah(
        step.ayah,
        repeatCount: step.repeatCount,
        pauseBetweenRepeats: step.pauseBetweenRepeats,
        token: token,
      );
      if (!_isCurrent(token)) return;
      onProgress?.call(
        HifzStepProgress(
          repeatIndex: step.repeatCount,
          repeatTotal: step.repeatCount,
        ),
      );
      return;
    }

    if (step is RangeStep) {
      for (var repeat = 1; repeat <= step.repeatCount; repeat++) {
        if (!_isCurrent(token)) return;
        onProgress?.call(
          HifzStepProgress(repeatIndex: repeat, repeatTotal: step.repeatCount),
        );

        for (
          var ayahNumber = step.start.ayahNumber;
          ayahNumber <= step.end.ayahNumber;
          ayahNumber++
        ) {
          if (!_isCurrent(token)) return;
          await _playSingleAyah(
            AyahRef(
              surahNumber: step.start.surahNumber,
              ayahNumber: ayahNumber,
            ),
            repeatCount: 1,
            pauseBetweenRepeats: Duration.zero,
            token: token,
          );
        }

        if (repeat < step.repeatCount &&
            step.pauseBetweenRepeats > Duration.zero) {
          await _delay(step.pauseBetweenRepeats);
          if (!_isCurrent(token)) return;
        }
      }
      return;
    }

    throw StateError('Unsupported Hifz step: ${step.runtimeType}');
  }

  Future<void> _playSingleAyah(
    AyahRef ayah, {
    required int repeatCount,
    required Duration pauseBetweenRepeats,
    required int token,
  }) async {
    final request = await _resolver.resolve(
      ayah,
      repeatCount: repeatCount,
      pauseBetweenRepeats: pauseBetweenRepeats,
    );
    if (!_isCurrent(token)) return;

    await _playAyah(request);
    if (!_isCurrent(token)) return;

    final audioState = _readState();
    if (audioState.status == QuranAudioStatus.error) {
      final error = audioState.error;
      if (error is Exception) throw error;
      throw StateError('Quran audio playback failed: $error');
    }
    if (audioState.status == QuranAudioStatus.idle) {
      throw const HifzPlaybackStoppedException();
    }
    if (audioState.status != QuranAudioStatus.completed) {
      throw StateError(
        'Quran audio did not complete ${ayah.verseKey}: '
        '${audioState.status.name}',
      );
    }
  }

  @override
  Future<void> pause() => _pause();

  @override
  Future<void> resume() async => _resume();

  @override
  Future<void> stop() async {
    _programToken++;
    await _stop();
  }

  bool _isCurrent(int token) => token == _programToken;
}
