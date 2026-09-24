import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'quran_audio_controller.dart';
import '../domain/quran_audio_state.dart';

export 'audio_dependencies.dart'
    show
        PlaybackDelay,
        audioPlayerAdapterProvider,
        audioSourceResolverProvider,
        playbackDelayProvider,
        timingRepositoryProvider;

final quranAudioControllerProvider =
    NotifierProvider<QuranAudioController, QuranAudioState>(
      QuranAudioController.new,
    );

final activeWordForAyahProvider = Provider.family<int?, String>((ref, ayahKey) {
  return ref.watch(
    quranAudioControllerProvider.select(
      (audio) =>
          (audio.mode == QuranAudioMode.ayah ||
                  audio.mode == QuranAudioMode.word) &&
              (audio.status == QuranAudioStatus.loading ||
                  audio.status == QuranAudioStatus.playing ||
                  audio.status == QuranAudioStatus.paused) &&
              audio.ayahKey == ayahKey
          ? audio.activeWordPosition
          : null,
    ),
  );
});

typedef QuranWordPlaybackTarget = ({String ayahKey, int wordPosition});

final isWordPlaybackActiveProvider =
    Provider.family<bool, QuranWordPlaybackTarget>((ref, target) {
      return ref.watch(activeWordForAyahProvider(target.ayahKey)) ==
          target.wordPosition;
    });

typedef ReaderPlaybackFollowTarget = ({String ayahKey, int? wordPosition});

final readerPlaybackFollowTargetProvider =
    Provider<ReaderPlaybackFollowTarget?>((ref) {
      return ref.watch(
        quranAudioControllerProvider.select((audio) {
          final ayahKey = audio.ayahKey;
          if (audio.mode != QuranAudioMode.ayah || ayahKey == null) return null;
          return (ayahKey: ayahKey, wordPosition: audio.activeWordPosition);
        }),
      );
    });

/// The ayah the reader should follow while ayah playback is active.
///
/// Word-tap playback also carries an ayah key, but it must not move the reader;
/// only sentence/ayah playback participates in automatic reader following.
final activeAyahPlaybackKeyProvider = Provider<String?>((ref) {
  return ref.watch(
    quranAudioControllerProvider.select(
      (audio) => audio.mode == QuranAudioMode.ayah ? audio.ayahKey : null,
    ),
  );
});

final isAyahPlaybackActiveProvider = Provider.family<bool, String>((
  ref,
  ayahKey,
) {
  return ref.watch(
    quranAudioControllerProvider.select(
      (audio) =>
          audio.mode == QuranAudioMode.ayah &&
          audio.ayahKey == ayahKey &&
          (audio.status == QuranAudioStatus.loading ||
              audio.status == QuranAudioStatus.playing ||
              audio.status == QuranAudioStatus.paused),
    ),
  );
});
