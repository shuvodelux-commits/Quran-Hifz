enum QuranAudioMode { idle, word, ayah, surah }

enum QuranAudioStatus { idle, loading, playing, paused, completed, error }

const _unset = Object();

class QuranAudioState {
  const QuranAudioState({
    required this.mode,
    required this.status,
    required this.speed,
    required this.repeatIndex,
    required this.repeatTotal,
    this.ayahKey,
    this.wordKey,
    this.source,
    this.activeWordPosition,
    this.error,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  const QuranAudioState.initial()
    : mode = QuranAudioMode.idle,
      status = QuranAudioStatus.idle,
      speed = 1.0,
      repeatIndex = 0,
      repeatTotal = 0,
      ayahKey = null,
      wordKey = null,
      source = null,
      activeWordPosition = null,
      error = null,
      position = Duration.zero,
      duration = Duration.zero;

  final QuranAudioMode mode;
  final QuranAudioStatus status;
  final double speed;
  final int repeatIndex;
  final int repeatTotal;
  final String? ayahKey;
  final String? wordKey;
  final String? source;
  final int? activeWordPosition;
  final Object? error;
  final Duration position;
  final Duration duration;

  QuranAudioState copyWith({
    QuranAudioMode? mode,
    QuranAudioStatus? status,
    double? speed,
    int? repeatIndex,
    int? repeatTotal,
    Object? ayahKey = _unset,
    Object? wordKey = _unset,
    Object? source = _unset,
    Object? activeWordPosition = _unset,
    Object? error = _unset,
    Duration? position,
    Duration? duration,
  }) {
    return QuranAudioState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      speed: speed ?? this.speed,
      repeatIndex: repeatIndex ?? this.repeatIndex,
      repeatTotal: repeatTotal ?? this.repeatTotal,
      ayahKey: identical(ayahKey, _unset) ? this.ayahKey : ayahKey as String?,
      wordKey: identical(wordKey, _unset) ? this.wordKey : wordKey as String?,
      source: identical(source, _unset) ? this.source : source as String?,
      activeWordPosition: identical(activeWordPosition, _unset)
          ? this.activeWordPosition
          : activeWordPosition as int?,
      error: identical(error, _unset) ? this.error : error,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}
