import '../../hifz/domain/hifz_progress.dart';
import '../../hifz/domain/hifz_session.dart';
import '../../hifz/domain/memorization_result.dart';
import '../../../core/time/clock.dart';
import '../domain/revision_item.dart';
import '../domain/revision_policy.dart';
import '../domain/revision_repository.dart';

class RevisionScheduler {
  RevisionScheduler({
    required RevisionRepository repository,
    required AppClock clock,
    RevisionPolicy policy = const RevisionPolicy(),
  }) : _repository = repository,
       _clock = clock,
       _policy = policy;

  final RevisionRepository _repository;
  final AppClock _clock;
  final RevisionPolicy _policy;

  Future<HifzProgress> recordResult({
    required String profileKey,
    required AyahRef ayah,
    required MemorizationResult result,
  }) async {
    final current = await _repository.loadProgress(
      profileKey: profileKey,
      ayah: ayah,
    );
    if (current == null) {
      throw StateError('Cannot review ${ayah.verseKey} before Hifz starts.');
    }

    final reviewedAt = _clock.now();
    final updated = _policy.apply(
      current: current,
      result: result,
      reviewedAt: reviewedAt,
    );
    final history = RevisionHistoryEntry(
      ayah: ayah,
      reviewedAt: reviewedAt,
      result: result,
      previousStatus: current.status,
      newStatus: updated.status,
      previousIntervalIndex: current.revisionIntervalIndex,
      newIntervalIndex: updated.revisionIntervalIndex,
      previousStrengthScore: current.strengthScore,
      newStrengthScore: updated.strengthScore,
      nextReviewAt: updated.nextReviewAt!,
    );

    await _repository.recordReview(
      profileKey: profileKey,
      updatedProgress: updated,
      historyEntry: history,
    );
    return updated;
  }
}
