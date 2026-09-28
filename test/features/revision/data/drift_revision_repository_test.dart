import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/hifz/data/drift_hifz_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_progress.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/domain/memorization_result.dart';
import 'package:quran_hifz/features/revision/data/drift_revision_repository.dart';
import 'package:quran_hifz/features/revision/domain/revision_item.dart';

void main() {
  test('history insert failure rolls back Hifz progress update', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final hifz = DriftHifzRepository(db);
    final revision = DriftRevisionRepository(db);
    const ayah = AyahRef(surahNumber: 67, ayahNumber: 1);
    final original = HifzProgress(
      ayah: ayah,
      status: HifzStatus.memorized,
      strengthScore: 70,
      reviewCount: 2,
      mistakeCount: 0,
      revisionIntervalIndex: 2,
      nextReviewAt: DateTime.utc(2026, 9, 4),
    );
    await hifz.saveProgress(profileKey: 'default', progress: original);

    final historyTable = db.hifzReviewHistoryRows.actualTableName;
    await db.customStatement('''
      CREATE TRIGGER fail_hifz_review_history
      BEFORE INSERT ON $historyTable
      BEGIN
        SELECT RAISE(ABORT, 'forced history failure');
      END;
    ''');

    final updated = original.copyWith(
      strengthScore: 80,
      reviewCount: 3,
      revisionIntervalIndex: 3,
      nextReviewAt: DateTime.utc(2026, 9, 11),
    );
    final history = RevisionHistoryEntry(
      ayah: ayah,
      reviewedAt: DateTime.utc(2026, 9, 4),
      result: MemorizationResult.perfect,
      previousStatus: HifzStatus.memorized,
      newStatus: HifzStatus.strong,
      previousIntervalIndex: 2,
      newIntervalIndex: 3,
      previousStrengthScore: 70,
      newStrengthScore: 80,
      nextReviewAt: DateTime.utc(2026, 9, 11),
    );

    await expectLater(
      revision.recordReview(
        profileKey: 'default',
        updatedProgress: updated.copyWith(status: HifzStatus.strong),
        historyEntry: history,
      ),
      throwsA(anything),
    );

    final after = await hifz.loadProgress(profileKey: 'default', ayah: ayah);
    expect(after?.status, HifzStatus.memorized);
    expect(after?.strengthScore, 70);
    expect(after?.reviewCount, 2);
    expect(after?.revisionIntervalIndex, 2);
  });

  test('loadDue returns only due ayahs ordered by Surah and ayah', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final hifz = DriftHifzRepository(db);
    final revision = DriftRevisionRepository(db);

    for (final entry in [
      (const AyahRef(surahNumber: 67, ayahNumber: 3), DateTime.utc(2026, 9, 4)),
      (const AyahRef(surahNumber: 67, ayahNumber: 1), DateTime.utc(2026, 9, 3)),
      (
        const AyahRef(surahNumber: 67, ayahNumber: 2),
        DateTime.utc(2026, 9, 10),
      ),
      (const AyahRef(surahNumber: 55, ayahNumber: 1), DateTime.utc(2026, 9, 4)),
    ]) {
      await hifz.saveProgress(
        profileKey: 'default',
        progress: HifzProgress(
          ayah: entry.$1,
          status: HifzStatus.needsRevision,
          strengthScore: 50,
          reviewCount: 1,
          mistakeCount: 0,
          nextReviewAt: entry.$2,
        ),
      );
    }

    final due = await revision.loadDue(
      profileKey: 'default',
      onOrBefore: DateTime.utc(2026, 9, 4, 23, 59, 59),
    );

    expect(due.map((item) => item.ayah.verseKey).toList(), [
      '55:1',
      '67:1',
      '67:3',
    ]);
  });
}
