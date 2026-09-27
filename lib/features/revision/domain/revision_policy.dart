import '../../hifz/domain/hifz_progress.dart';
import '../../hifz/domain/memorization_result.dart';

class RevisionPolicy {
  const RevisionPolicy();

  static const intervalDays = <int>[1, 2, 4, 7, 14, 30, 60];

  HifzProgress apply({
    required HifzProgress current,
    required MemorizationResult result,
    required DateTime reviewedAt,
  }) {
    final previousIndex = current.revisionIntervalIndex;
    final boundedIndex = previousIndex
        .clamp(0, intervalDays.length - 1)
        .toInt();

    final newIndex = switch (result) {
      MemorizationResult.perfect =>
        previousIndex < 0
            ? 0
            : (boundedIndex + 1).clamp(0, intervalDays.length - 1).toInt(),
      MemorizationResult.smallMistake => boundedIndex,
      MemorizationResult.difficult =>
        (boundedIndex - 1).clamp(0, intervalDays.length - 1).toInt(),
      MemorizationResult.forgot => 0,
    };

    final strength = _nextStrength(current.strengthScore, result);
    final status = _nextStatus(strength, result);
    final nextReview = _calendarDatePlusDays(
      reviewedAt,
      intervalDays[newIndex],
    );

    return HifzProgress(
      ayah: current.ayah,
      status: status,
      strengthScore: strength,
      reviewCount: current.reviewCount + 1,
      mistakeCount:
          current.mistakeCount + (result == MemorizationResult.perfect ? 0 : 1),
      revisionIntervalIndex: newIndex,
      startedAt: current.startedAt ?? reviewedAt,
      memorizedAt:
          current.memorizedAt ??
          (result == MemorizationResult.perfect ? reviewedAt : null),
      lastReviewedAt: reviewedAt,
      nextReviewAt: nextReview,
    );
  }

  int _nextStrength(int current, MemorizationResult result) {
    final bounded = current.clamp(0, 100).toInt();
    return switch (result) {
      MemorizationResult.perfect =>
        (bounded < 50 ? 60 : bounded + 10).clamp(0, 100).toInt(),
      MemorizationResult.smallMistake => (bounded - 5).clamp(0, 100).toInt(),
      MemorizationResult.difficult => (bounded - 15).clamp(0, 100).toInt(),
      MemorizationResult.forgot => (bounded - 30).clamp(0, 100).toInt(),
    };
  }

  HifzStatus _nextStatus(int strength, MemorizationResult result) {
    if (result == MemorizationResult.forgot) return HifzStatus.learning;
    if (result == MemorizationResult.difficult) {
      return HifzStatus.needsRevision;
    }
    if (strength >= 80) return HifzStatus.strong;
    if (strength >= 51) return HifzStatus.memorized;
    return HifzStatus.needsRevision;
  }

  DateTime _calendarDatePlusDays(DateTime value, int days) {
    if (value.isUtc) {
      return DateTime.utc(value.year, value.month, value.day + days);
    }
    return DateTime(value.year, value.month, value.day + days);
  }
}
