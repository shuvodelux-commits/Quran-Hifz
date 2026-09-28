import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/time/clock.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_progress.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/domain/memorization_result.dart';
import 'package:quran_hifz/features/revision/application/revision_scheduler.dart';
import 'package:quran_hifz/features/revision/domain/revision_item.dart';
import 'package:quran_hifz/features/revision/domain/revision_repository.dart';

void main() {
  const ayah = AyahRef(surahNumber: 67, ayahNumber: 1);
  final now = DateTime.utc(2026, 9, 4, 18, 30);

  final cases = <_PolicyCase>[
    _PolicyCase(
      result: MemorizationResult.perfect,
      expectedIntervalIndex: 3,
      expectedNextReview: DateTime.utc(2026, 9, 11),
      expectedStrength: 80,
      expectedStatus: HifzStatus.strong,
    ),
    _PolicyCase(
      result: MemorizationResult.smallMistake,
      expectedIntervalIndex: 2,
      expectedNextReview: DateTime.utc(2026, 9, 8),
      expectedStrength: 65,
      expectedStatus: HifzStatus.memorized,
    ),
    _PolicyCase(
      result: MemorizationResult.difficult,
      expectedIntervalIndex: 1,
      expectedNextReview: DateTime.utc(2026, 9, 6),
      expectedStrength: 55,
      expectedStatus: HifzStatus.needsRevision,
    ),
    _PolicyCase(
      result: MemorizationResult.forgot,
      expectedIntervalIndex: 0,
      expectedNextReview: DateTime.utc(2026, 9, 5),
      expectedStrength: 40,
      expectedStatus: HifzStatus.learning,
    ),
  ];

  for (final item in cases) {
    test('${item.result.name} applies exact deterministic policy', () async {
      final repository = _FakeRevisionRepository(
        initial: HifzProgress(
          ayah: ayah,
          status: HifzStatus.memorized,
          strengthScore: 70,
          reviewCount: 2,
          mistakeCount: 1,
          revisionIntervalIndex: 2,
          memorizedAt: DateTime.utc(2026, 8, 20),
          nextReviewAt: DateTime.utc(2026, 9, 1),
        ),
      );
      final scheduler = RevisionScheduler(
        repository: repository,
        clock: _FakeClock(now),
      );

      final updated = await scheduler.recordResult(
        profileKey: 'default',
        ayah: ayah,
        result: item.result,
      );

      expect(updated.revisionIntervalIndex, item.expectedIntervalIndex);
      expect(updated.nextReviewAt, item.expectedNextReview);
      expect(updated.strengthScore, item.expectedStrength);
      expect(updated.status, item.expectedStatus);
      expect(updated.reviewCount, 3);
      expect(
        updated.mistakeCount,
        item.result == MemorizationResult.perfect ? 1 : 2,
      );
      expect(updated.lastReviewedAt, now);
      expect(repository.history.single.result, item.result);
      expect(repository.history.single.previousIntervalIndex, 2);
      expect(
        repository.history.single.newIntervalIndex,
        item.expectedIntervalIndex,
      );
    });
  }

  test('first Perfect result promotes Learning to Memorized', () async {
    final repository = _FakeRevisionRepository(
      initial: const HifzProgress(
        ayah: ayah,
        status: HifzStatus.learning,
        strengthScore: 0,
        reviewCount: 0,
        mistakeCount: 0,
      ),
    );
    final scheduler = RevisionScheduler(
      repository: repository,
      clock: _FakeClock(now),
    );

    final updated = await scheduler.recordResult(
      profileKey: 'default',
      ayah: ayah,
      result: MemorizationResult.perfect,
    );

    expect(updated.status, HifzStatus.memorized);
    expect(updated.strengthScore, 60);
    expect(updated.revisionIntervalIndex, 0);
    expect(updated.nextReviewAt, DateTime.utc(2026, 9, 5));
    expect(updated.memorizedAt, now);
  });

  test('calendar-day scheduling crosses year boundary correctly', () async {
    final decemberNow = DateTime.utc(2026, 12, 31, 23, 45);
    final repository = _FakeRevisionRepository(
      initial: const HifzProgress(
        ayah: ayah,
        status: HifzStatus.memorized,
        strengthScore: 60,
        reviewCount: 1,
        mistakeCount: 0,
        revisionIntervalIndex: 0,
      ),
    );
    final scheduler = RevisionScheduler(
      repository: repository,
      clock: _FakeClock(decemberNow),
    );

    final updated = await scheduler.recordResult(
      profileKey: 'default',
      ayah: ayah,
      result: MemorizationResult.perfect,
    );

    expect(updated.revisionIntervalIndex, 1);
    expect(updated.nextReviewAt, DateTime.utc(2027, 1, 2));
  });

  test('overdue date does not change interval math', () async {
    final repository = _FakeRevisionRepository(
      initial: HifzProgress(
        ayah: ayah,
        status: HifzStatus.memorized,
        strengthScore: 70,
        reviewCount: 4,
        mistakeCount: 0,
        revisionIntervalIndex: 4,
        nextReviewAt: DateTime.utc(2026, 7, 1),
      ),
    );
    final scheduler = RevisionScheduler(
      repository: repository,
      clock: _FakeClock(now),
    );

    final updated = await scheduler.recordResult(
      profileKey: 'default',
      ayah: ayah,
      result: MemorizationResult.perfect,
    );

    expect(updated.revisionIntervalIndex, 5);
    expect(updated.nextReviewAt, DateTime.utc(2026, 10, 4));
  });
}

class _PolicyCase {
  _PolicyCase({
    required this.result,
    required this.expectedIntervalIndex,
    required this.expectedNextReview,
    required this.expectedStrength,
    required this.expectedStatus,
  });

  final MemorizationResult result;
  final int expectedIntervalIndex;
  final DateTime expectedNextReview;
  final int expectedStrength;
  final HifzStatus expectedStatus;
}

class _FakeRevisionRepository implements RevisionRepository {
  _FakeRevisionRepository({required HifzProgress initial}) : progress = initial;

  HifzProgress progress;
  final List<RevisionHistoryEntry> history = [];

  @override
  Future<HifzProgress?> loadProgress({
    required String profileKey,
    required AyahRef ayah,
  }) async {
    return progress.ayah == ayah ? progress : null;
  }

  @override
  Future<void> recordReview({
    required String profileKey,
    required HifzProgress updatedProgress,
    required RevisionHistoryEntry historyEntry,
  }) async {
    progress = updatedProgress;
    history.add(historyEntry);
  }

  @override
  Future<List<RevisionItem>> loadDue({
    required String profileKey,
    required DateTime onOrBefore,
  }) async {
    return const [];
  }
}

class _FakeClock implements AppClock {
  const _FakeClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
