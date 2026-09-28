class HifzPreset {
  const HifzPreset({
    required this.id,
    required this.ayahRepeatCount,
    required this.combinedRepeatCount,
    required this.finalRangeRepeatCount,
    required this.pauseBetweenRepeats,
    required this.progressiveCombination,
  });

  final String id;
  final int ayahRepeatCount;
  final int combinedRepeatCount;
  final int finalRangeRepeatCount;
  final Duration pauseBetweenRepeats;
  final bool progressiveCombination;
}

abstract final class HifzPresets {
  static const _progressivePrefix = 'progressive_v1';

  static HifzPreset progressive({
    int ayahRepeatCount = 5,
    int combinedRepeatCount = 3,
    int finalRangeRepeatCount = 3,
    Duration pauseBetweenRepeats = const Duration(seconds: 1),
  }) {
    if (ayahRepeatCount <= 0 || combinedRepeatCount <= 0) {
      throw ArgumentError('Hifz repeat counts must be positive.');
    }
    if (finalRangeRepeatCount < 0) {
      throw ArgumentError('Final range repeat count cannot be negative.');
    }

    final pauseMs = pauseBetweenRepeats.inMilliseconds;
    return HifzPreset(
      id:
          '$_progressivePrefix:$ayahRepeatCount:$combinedRepeatCount:'
          '$finalRangeRepeatCount:$pauseMs',
      ayahRepeatCount: ayahRepeatCount,
      combinedRepeatCount: combinedRepeatCount,
      finalRangeRepeatCount: finalRangeRepeatCount,
      pauseBetweenRepeats: pauseBetweenRepeats,
      progressiveCombination: true,
    );
  }

  static HifzPreset fromId(String id) {
    if (id == newMemorization.id) return newMemorization;
    if (id.startsWith('$_progressivePrefix:')) {
      final parts = id.split(':');
      if (parts.length == 5) {
        final ayah = int.tryParse(parts[1]);
        final combined = int.tryParse(parts[2]);
        final finalRange = int.tryParse(parts[3]);
        final pauseMs = int.tryParse(parts[4]);
        if (ayah != null &&
            combined != null &&
            finalRange != null &&
            pauseMs != null) {
          return progressive(
            ayahRepeatCount: ayah,
            combinedRepeatCount: combined,
            finalRangeRepeatCount: finalRange,
            pauseBetweenRepeats: Duration(milliseconds: pauseMs),
          );
        }
      }
    }
    throw ArgumentError.value(id, 'id', 'Unknown Hifz preset');
  }

  /// Backward-compatible preset used by checkpoints created before custom
  /// progressive Hifz controls were introduced.
  static const newMemorization = HifzPreset(
    id: 'new_memorization',
    ayahRepeatCount: 5,
    combinedRepeatCount: 3,
    finalRangeRepeatCount: 0,
    pauseBetweenRepeats: Duration(seconds: 1),
    progressiveCombination: true,
  );
}
