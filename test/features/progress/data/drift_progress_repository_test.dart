import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/hifz/data/drift_hifz_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_progress.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/progress/data/drift_progress_repository.dart';

void main() {
  test(
    'aggregates today, 7-day, 30-day, status, due and goal totals',
    () async {
      final db = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final hifz = DriftHifzRepository(db);
      final repository = DriftProgressRepository(db);
      final day = DateTime.utc(2026, 9, 4);

      await _saveHifz(
        hifz,
        const AyahRef(surahNumber: 67, ayahNumber: 1),
        HifzStatus.memorized,
        memorizedAt: DateTime.utc(2026, 9, 4, 9),
        nextReviewAt: DateTime.utc(2026, 9, 4),
      );
      await _saveHifz(
        hifz,
        const AyahRef(surahNumber: 67, ayahNumber: 2),
        HifzStatus.strong,
        memorizedAt: DateTime.utc(2026, 9, 2, 9),
        nextReviewAt: DateTime.utc(2026, 9, 5),
      );
      await _saveHifz(
        hifz,
        const AyahRef(surahNumber: 67, ayahNumber: 3),
        HifzStatus.learning,
      );
      await _saveHifz(
        hifz,
        const AyahRef(surahNumber: 67, ayahNumber: 4),
        HifzStatus.needsRevision,
        memorizedAt: DateTime.utc(2026, 8, 20, 9),
        nextReviewAt: DateTime.utc(2026, 9, 3),
      );

      await _insertReview(db, DateTime.utc(2026, 9, 4, 10), -1);
      await _insertReview(db, DateTime.utc(2026, 9, 4, 11), 0);
      await _insertReview(db, DateTime.utc(2026, 9, 1, 11), 1);
      await _insertReview(db, DateTime.utc(2026, 8, 10, 11), 2);
      await _insertReview(db, DateTime.utc(2026, 7, 1, 11), 3);

      await db.recordReadingPageVisit(
        profileKey: 'default',
        pageNumber: 1,
        readAt: DateTime.utc(2026, 9, 4, 8),
      );
      await db.recordReadingPageVisit(
        profileKey: 'default',
        pageNumber: 2,
        readAt: DateTime.utc(2026, 9, 4, 8, 30),
      );
      await db.recordReadingPageVisit(
        profileKey: 'default',
        pageNumber: 2,
        readAt: DateTime.utc(2026, 9, 4, 9),
      );
      await db.recordReadingPageVisit(
        profileKey: 'default',
        pageNumber: 3,
        readAt: DateTime.utc(2026, 9, 2, 9),
      );
      await db.recordReadingPageVisit(
        profileKey: 'default',
        pageNumber: 4,
        readAt: DateTime.utc(2026, 8, 10, 9),
      );
      await db.recordReadingPageVisit(
        profileKey: 'default',
        pageNumber: 5,
        readAt: DateTime.utc(2026, 7, 1, 9),
      );

      await db.saveDailyGoal(
        profileKey: 'default',
        day: day,
        newHifzAyahsTarget: 5,
        revisionAyahsTarget: 20,
        readingPagesTarget: 2,
      );

      final summary = await repository.loadSummary(day);

      expect(summary.hifz.learning, 1);
      expect(summary.hifz.memorized, 1);
      expect(summary.hifz.needsRevision, 1);
      expect(summary.hifz.strong, 1);
      expect(summary.revisionDue, 2);

      expect(summary.today.newHifzAyahs, 1);
      expect(summary.today.revisionAyahs, 1);
      expect(summary.today.readingPages, 2);

      expect(summary.trailing7Days.newHifzAyahs, 2);
      expect(summary.trailing7Days.revisionAyahs, 2);
      expect(summary.trailing7Days.readingPages, 3);

      expect(summary.trailing30Days.newHifzAyahs, 3);
      expect(summary.trailing30Days.revisionAyahs, 3);
      expect(summary.trailing30Days.readingPages, 4);

      expect(summary.goals.newHifzAyahsTarget, 5);
      expect(summary.goals.revisionAyahsTarget, 20);
      expect(summary.goals.readingPagesTarget, 2);
    },
  );

  test('latest prior daily goal remains active until changed', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftProgressRepository(db);

    await db.saveDailyGoal(
      profileKey: 'default',
      day: DateTime.utc(2026, 9, 1),
      newHifzAyahsTarget: 4,
      revisionAyahsTarget: 15,
      readingPagesTarget: 3,
    );

    final summary = await repository.loadSummary(DateTime.utc(2026, 9, 4));

    expect(summary.goals.newHifzAyahsTarget, 4);
    expect(summary.goals.revisionAyahsTarget, 15);
    expect(summary.goals.readingPagesTarget, 3);
  });
}

Future<void> _saveHifz(
  DriftHifzRepository repository,
  AyahRef ayah,
  HifzStatus status, {
  DateTime? memorizedAt,
  DateTime? nextReviewAt,
}) {
  return repository.saveProgress(
    profileKey: 'default',
    progress: HifzProgress(
      ayah: ayah,
      status: status,
      strengthScore: status == HifzStatus.strong ? 90 : 60,
      reviewCount: 1,
      mistakeCount: 0,
      revisionIntervalIndex: 0,
      memorizedAt: memorizedAt,
      nextReviewAt: nextReviewAt,
    ),
  );
}

Future<void> _insertReview(
  UserDatabase db,
  DateTime reviewedAt,
  int previousIntervalIndex,
) {
  return db
      .into(db.hifzReviewHistoryRows)
      .insert(
        HifzReviewHistoryRowsCompanion.insert(
          profileKey: 'default',
          surahNumber: 67,
          ayahNumber: previousIntervalIndex + 2,
          reviewedAt: reviewedAt,
          result: 'perfect',
          previousStatus: 'memorized',
          newStatus: 'memorized',
          previousIntervalIndex: previousIntervalIndex,
          newIntervalIndex: previousIntervalIndex < 0
              ? 0
              : previousIntervalIndex + 1,
          previousStrengthScore: 60,
          newStrengthScore: 70,
          nextReviewAt: DateTime.utc(2026, 9, 10),
        ),
      );
}
