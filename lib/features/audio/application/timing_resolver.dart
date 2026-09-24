import '../domain/audio_timing.dart';

class TimingResolver {
  const TimingResolver();

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
