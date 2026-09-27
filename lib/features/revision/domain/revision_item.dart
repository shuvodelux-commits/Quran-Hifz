import '../../hifz/domain/hifz_progress.dart';
import '../../hifz/domain/hifz_session.dart';
import '../../hifz/domain/memorization_result.dart';

class RevisionHistoryEntry {
  const RevisionHistoryEntry({
    required this.ayah,
    required this.reviewedAt,
    required this.result,
    required this.previousStatus,
    required this.newStatus,
    required this.previousIntervalIndex,
    required this.newIntervalIndex,
    required this.previousStrengthScore,
    required this.newStrengthScore,
    required this.nextReviewAt,
  });

  final AyahRef ayah;
  final DateTime reviewedAt;
  final MemorizationResult result;
  final HifzStatus previousStatus;
  final HifzStatus newStatus;
  final int previousIntervalIndex;
  final int newIntervalIndex;
  final int previousStrengthScore;
  final int newStrengthScore;
  final DateTime nextReviewAt;
}

class RevisionItem {
  const RevisionItem({
    required this.ayah,
    required this.status,
    required this.strengthScore,
    required this.revisionIntervalIndex,
    required this.nextReviewAt,
  });

  final AyahRef ayah;
  final HifzStatus status;
  final int strengthScore;
  final int revisionIntervalIndex;
  final DateTime nextReviewAt;
}

class RevisionGroup {
  const RevisionGroup({
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
    required this.items,
  });

  final int surahNumber;
  final int startAyah;
  final int endAyah;
  final List<RevisionItem> items;

  int get ayahCount => items.length;
}
