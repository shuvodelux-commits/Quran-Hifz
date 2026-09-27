import 'package:drift/drift.dart';

import '../../../core/database/user_database.dart';
import '../../hifz/domain/hifz_progress.dart';
import '../../hifz/domain/hifz_session.dart';
import '../domain/revision_item.dart';
import '../domain/revision_repository.dart';

class DriftRevisionRepository implements RevisionRepository {
  DriftRevisionRepository(this._database);

  final UserDatabase _database;

  @override
  Future<HifzProgress?> loadProgress({
    required String profileKey,
    required AyahRef ayah,
  }) async {
    final row =
        await (_database.select(_database.hifzProgressEntries)..where(
              (entry) =>
                  entry.profileKey.equals(profileKey) &
                  entry.surahNumber.equals(ayah.surahNumber) &
                  entry.ayahNumber.equals(ayah.ayahNumber),
            ))
            .getSingleOrNull();
    return row == null ? null : _progressFromRow(row);
  }

  @override
  Future<void> recordReview({
    required String profileKey,
    required HifzProgress updatedProgress,
    required RevisionHistoryEntry historyEntry,
  }) async {
    await _database.transaction(() async {
      await _database
          .into(_database.hifzProgressEntries)
          .insertOnConflictUpdate(
            HifzProgressEntriesCompanion(
              profileKey: Value(profileKey),
              surahNumber: Value(updatedProgress.ayah.surahNumber),
              ayahNumber: Value(updatedProgress.ayah.ayahNumber),
              status: Value(updatedProgress.status.name),
              strengthScore: Value(updatedProgress.strengthScore),
              reviewCount: Value(updatedProgress.reviewCount),
              mistakeCount: Value(updatedProgress.mistakeCount),
              revisionIntervalIndex: Value(
                updatedProgress.revisionIntervalIndex,
              ),
              startedAt: Value(updatedProgress.startedAt),
              memorizedAt: Value(updatedProgress.memorizedAt),
              lastReviewedAt: Value(updatedProgress.lastReviewedAt),
              nextReviewAt: Value(updatedProgress.nextReviewAt),
            ),
          );

      await _database
          .into(_database.hifzReviewHistoryRows)
          .insert(
            HifzReviewHistoryRowsCompanion.insert(
              profileKey: profileKey,
              surahNumber: historyEntry.ayah.surahNumber,
              ayahNumber: historyEntry.ayah.ayahNumber,
              reviewedAt: historyEntry.reviewedAt,
              result: historyEntry.result.name,
              previousStatus: historyEntry.previousStatus.name,
              newStatus: historyEntry.newStatus.name,
              previousIntervalIndex: historyEntry.previousIntervalIndex,
              newIntervalIndex: historyEntry.newIntervalIndex,
              previousStrengthScore: historyEntry.previousStrengthScore,
              newStrengthScore: historyEntry.newStrengthScore,
              nextReviewAt: historyEntry.nextReviewAt,
            ),
          );
    });
  }

  @override
  Future<List<RevisionItem>> loadDue({
    required String profileKey,
    required DateTime onOrBefore,
  }) async {
    final rows =
        await (_database.select(_database.hifzProgressEntries)
              ..where(
                (row) =>
                    row.profileKey.equals(profileKey) &
                    row.nextReviewAt.isNotNull() &
                    row.nextReviewAt.isSmallerOrEqualValue(onOrBefore),
              )
              ..orderBy([
                (row) => OrderingTerm.asc(row.surahNumber),
                (row) => OrderingTerm.asc(row.ayahNumber),
              ]))
            .get();

    return rows
        .where((row) => row.nextReviewAt != null)
        .map(
          (row) => RevisionItem(
            ayah: AyahRef(
              surahNumber: row.surahNumber,
              ayahNumber: row.ayahNumber,
            ),
            status: _statusFromName(row.status),
            strengthScore: row.strengthScore,
            revisionIntervalIndex: row.revisionIntervalIndex,
            nextReviewAt: row.nextReviewAt!,
          ),
        )
        .toList(growable: false);
  }

  HifzProgress _progressFromRow(HifzProgressRow row) {
    return HifzProgress(
      ayah: AyahRef(surahNumber: row.surahNumber, ayahNumber: row.ayahNumber),
      status: _statusFromName(row.status),
      strengthScore: row.strengthScore,
      reviewCount: row.reviewCount,
      mistakeCount: row.mistakeCount,
      revisionIntervalIndex: row.revisionIntervalIndex,
      startedAt: row.startedAt,
      memorizedAt: row.memorizedAt,
      lastReviewedAt: row.lastReviewedAt,
      nextReviewAt: row.nextReviewAt,
    );
  }

  HifzStatus _statusFromName(String value) {
    return HifzStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw StateError('Unknown Hifz status: $value'),
    );
  }
}
