import '../domain/audio_timing.dart';

class TimingResolver {
  const TimingResolver();

  List<WordAudioTiming> synthesizeWordTimings({
    required AyahAudioTiming ayahTiming,
    required List<int> wordPositions,
  }) {
    if (wordPositions.isEmpty ||
        wordPositions.any((position) => position <= 0)) {
      return const [];
    }

    final totalMicros = (ayahTiming.end - ayahTiming.start).inMicroseconds;
    if (totalMicros < wordPositions.length) return const [];

    final ayahStartMicros = ayahTiming.start.inMicroseconds;
    final count = wordPositions.length;
    return [
      for (var index = 0; index < count; index++)
        WordAudioTiming(
          wordPosition: wordPositions[index],
          start: Duration(
            microseconds: ayahStartMicros + (totalMicros * index ~/ count),
          ),
          end: Duration(
            microseconds:
                ayahStartMicros + (totalMicros * (index + 1) ~/ count),
          ),
        ),
    ];
  }

  int? activeWordAt(
    Duration absolutePosition,
    List<WordAudioTiming> sortedSegments,
  ) {
    if (sortedSegments.isEmpty) return null;

    var low = 0;
    var high = sortedSegments.length - 1;
    var candidate = -1;

    while (low <= high) {
      final middle = low + ((high - low) ~/ 2);
      final segment = sortedSegments[middle];
      if (segment.start <= absolutePosition) {
        candidate = middle;
        low = middle + 1;
      } else {
        high = middle - 1;
      }
    }

    if (candidate < 0) return null;
    final segment = sortedSegments[candidate];
    if (absolutePosition >= segment.end) return null;
    return segment.wordPosition;
  }
}
