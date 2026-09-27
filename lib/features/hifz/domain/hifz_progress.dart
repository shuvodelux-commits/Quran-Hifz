import 'hifz_session.dart';

enum HifzStatus { notStarted, learning, memorized, needsRevision, strong }

class HifzProgress {
  const HifzProgress({
    required this.ayah,
    required this.status,
    required this.strengthScore,
    required this.reviewCount,
    required this.mistakeCount,
    this.revisionIntervalIndex = -1,
    this.startedAt,
    this.memorizedAt,
    this.lastReviewedAt,
    this.nextReviewAt,
  });

  final AyahRef ayah;
  final HifzStatus status;
  final int strengthScore;
  final int reviewCount;
  final int mistakeCount;
  final int revisionIntervalIndex;
  final DateTime? startedAt;
  final DateTime? memorizedAt;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;

  HifzProgress copyWith({
    HifzStatus? status,
    int? strengthScore,
    int? reviewCount,
    int? mistakeCount,
    int? revisionIntervalIndex,
    DateTime? startedAt,
    DateTime? memorizedAt,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
  }) {
    return HifzProgress(
      ayah: ayah,
      status: status ?? this.status,
      strengthScore: strengthScore ?? this.strengthScore,
      reviewCount: reviewCount ?? this.reviewCount,
      mistakeCount: mistakeCount ?? this.mistakeCount,
      revisionIntervalIndex:
          revisionIntervalIndex ?? this.revisionIntervalIndex,
      startedAt: startedAt ?? this.startedAt,
      memorizedAt: memorizedAt ?? this.memorizedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }
}
