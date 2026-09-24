class AudioTimingKey {
  const AudioTimingKey({
    required this.reciterId,
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int reciterId;
  final int surahNumber;
  final int ayahNumber;
}

class AyahAudioTiming {
  const AyahAudioTiming({required this.start, required this.end})
    : assert(end > start);

  final Duration start;
  final Duration end;
}

class WordAudioTiming {
  const WordAudioTiming({
    required this.wordPosition,
    required this.start,
    required this.end,
  }) : assert(end > start);

  final int wordPosition;
  final Duration start;
  final Duration end;
}

abstract class TimingRepository {
  Future<AyahAudioTiming?> getAyahTiming({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  });

  Future<List<WordAudioTiming>> getWordTimings({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  });
}

class AudioTimingUnavailableException implements Exception {
  const AudioTimingUnavailableException(this.key);

  final AudioTimingKey key;

  @override
  String toString() =>
      'No verified ayah timing for reciter ${key.reciterId}, '
      '${key.surahNumber}:${key.ayahNumber}; playback was not started.';
}
