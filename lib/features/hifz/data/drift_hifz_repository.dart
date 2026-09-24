import 'package:drift/drift.dart';

import '../../../core/database/user_database.dart';
import '../domain/hifz_preset.dart';
import '../domain/hifz_progress.dart';
import '../domain/hifz_repository.dart';
import '../domain/hifz_session.dart';

class DriftHifzRepository implements HifzRepository {
  DriftHifzRepository(this._database);

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
    if (row == null) return null;
    return _progressFromRow(row);
  }

  @override
  Future<void> saveProgress({
    required String profileKey,
    required HifzProgress progress,
  }) async {
    await _database
        .into(_database.hifzProgressEntries)
        .insertOnConflictUpdate(
          HifzProgressEntriesCompanion(
            profileKey: Value(profileKey),
            surahNumber: Value(progress.ayah.surahNumber),
            ayahNumber: Value(progress.ayah.ayahNumber),
            status: Value(progress.status.name),
            strengthScore: Value(progress.strengthScore),
            reviewCount: Value(progress.reviewCount),
            mistakeCount: Value(progress.mistakeCount),
            revisionIntervalIndex: Value(progress.revisionIntervalIndex),
            startedAt: Value(progress.startedAt),
            memorizedAt: Value(progress.memorizedAt),
            lastReviewedAt: Value(progress.lastReviewedAt),
            nextReviewAt: Value(progress.nextReviewAt),
          ),
        );
  }

  @override
  Future<void> markRangeLearning({
    required String profileKey,
    required AyahRef start,
    required AyahRef end,
  }) async {
    _validateRange(start, end);
    final now = DateTime.now();

    await _database.transaction(() async {
      for (
        var ayahNumber = start.ayahNumber;
        ayahNumber <= end.ayahNumber;
        ayahNumber++
      ) {
        final ayah = AyahRef(
          surahNumber: start.surahNumber,
          ayahNumber: ayahNumber,
        );
        final existing = await loadProgress(profileKey: profileKey, ayah: ayah);
        if (existing != null && existing.status != HifzStatus.notStarted) {
          continue;
        }

        await saveProgress(
          profileKey: profileKey,
          progress: HifzProgress(
            ayah: ayah,
            status: HifzStatus.learning,
            strengthScore: existing?.strengthScore ?? 0,
            reviewCount: existing?.reviewCount ?? 0,
            mistakeCount: existing?.mistakeCount ?? 0,
            revisionIntervalIndex: existing?.revisionIntervalIndex ?? -1,
            startedAt: existing?.startedAt ?? now,
            memorizedAt: existing?.memorizedAt,
            lastReviewedAt: existing?.lastReviewedAt,
            nextReviewAt: existing?.nextReviewAt,
          ),
        );
      }
    });
  }

  @override
  Future<HifzSessionCheckpoint?> loadCheckpoint(String profileKey) async {
    final row = await (_database.select(
      _database.hifzSessionCheckpoints,
    )..where((entry) => entry.profileKey.equals(profileKey))).getSingleOrNull();
    if (row == null) return null;

    return HifzSessionCheckpoint(
      profileKey: row.profileKey,
      config: HifzSessionConfig(
        start: AyahRef(surahNumber: row.startSurah, ayahNumber: row.startAyah),
        end: AyahRef(surahNumber: row.endSurah, ayahNumber: row.endAyah),
        preset: HifzPresets.fromId(row.presetId),
      ),
      nextStepIndex: row.nextStepIndex,
      status: _sessionStatusFromName(row.status),
      updatedAt: row.updatedAt.toUtc(),
    );
  }

  @override
  Future<void> saveCheckpoint(HifzSessionCheckpoint checkpoint) async {
    await _database
        .into(_database.hifzSessionCheckpoints)
        .insertOnConflictUpdate(
          HifzSessionCheckpointsCompanion(
            profileKey: Value(checkpoint.profileKey),
            startSurah: Value(checkpoint.config.start.surahNumber),
            startAyah: Value(checkpoint.config.start.ayahNumber),
            endSurah: Value(checkpoint.config.end.surahNumber),
            endAyah: Value(checkpoint.config.end.ayahNumber),
            presetId: Value(checkpoint.config.preset.id),
            nextStepIndex: Value(checkpoint.nextStepIndex),
            status: Value(checkpoint.status.name),
            updatedAt: Value(checkpoint.updatedAt),
          ),
        );
  }

  HifzProgress _progressFromRow(HifzProgressRow row) {
    return HifzProgress(
      ayah: AyahRef(surahNumber: row.surahNumber, ayahNumber: row.ayahNumber),
      status: _statusFromName(row.status),
      strengthScore: row.strengthScore,
      reviewCount: row.reviewCount,
      mistakeCount: row.mistakeCount,
      revisionIntervalIndex: row.revisionIntervalIndex,
      startedAt: row.startedAt?.toUtc(),
      memorizedAt: row.memorizedAt?.toUtc(),
      lastReviewedAt: row.lastReviewedAt?.toUtc(),
      nextReviewAt: row.nextReviewAt?.toUtc(),
    );
  }

  HifzStatus _statusFromName(String value) {
    return HifzStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw StateError('Unknown Hifz status: $value'),
    );
  }

  HifzSessionStatus _sessionStatusFromName(String value) {
    return HifzSessionStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw StateError('Unknown Hifz session status: $value'),
    );
  }

  void _validateRange(AyahRef start, AyahRef end) {
    if (start.surahNumber != end.surahNumber ||
        start.ayahNumber <= 0 ||
        end.ayahNumber < start.ayahNumber) {
      throw ArgumentError('Invalid same-Surah Hifz range.');
    }
  }
}
