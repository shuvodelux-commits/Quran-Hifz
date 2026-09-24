import 'package:drift/drift.dart';

import '../../../core/database/user_database.dart';
import '../../../core/time/calendar_day.dart';
import '../../hifz/domain/hifz_progress.dart';
import '../domain/progress_repository.dart';
import '../domain/progress_summary.dart';

class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._database, {this.profileKey = 'default'});

  final UserDatabase _database;
  final String profileKey;

  @override
  Future<ProgressSummary> loadSummary(DateTime day) async {
    final normalizedDay = calendarDayStart(day);
    final start7 = calendarDayStart(day, offsetDays: -6);
    final start30 = calendarDayStart(day, offsetDays: -29);
    final end = calendarDayEnd(day);

    final hifzRows = await (_database.select(
      _database.hifzProgressEntries,
    )..where((row) => row.profileKey.equals(profileKey))).get();

    final historyRows =
        await (_database.select(_database.hifzReviewHistoryRows)..where(
              (row) =>
                  row.profileKey.equals(profileKey) &
                  row.reviewedAt.isBiggerOrEqualValue(start30) &
                  row.reviewedAt.isSmallerOrEqualValue(end),
            ))
            .get();

    final readingRows =
        await (_database.select(_database.readingPageVisits)..where(
              (row) =>
                  row.profileKey.equals(profileKey) &
                  row.readAt.isBiggerOrEqualValue(start30) &
                  row.readAt.isSmallerOrEqualValue(end),
            ))
            .get();

    final goal =
        await (_database.select(_database.dailyGoals)
              ..where(
                (row) =>
                    row.profileKey.equals(profileKey) &
                    row.dayKey.isSmallerOrEqualValue(
                      calendarDayKey(normalizedDay),
                    ),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.dayKey)])
              ..limit(1))
            .getSingleOrNull();

    final status = _statusSummary(hifzRows);
    final revisionDue = hifzRows.where((row) {
      final due = row.nextReviewAt;
      return due != null && !due.isAfter(end);
    }).length;

    return ProgressSummary(
      day: normalizedDay,
      hifz: status,
      revisionDue: revisionDue,
      today: _periodSummary(
        hifzRows: hifzRows,
        historyRows: historyRows,
        readingRows: readingRows,
        start: normalizedDay,
        end: end,
      ),
      trailing7Days: _periodSummary(
        hifzRows: hifzRows,
        historyRows: historyRows,
        readingRows: readingRows,
        start: start7,
        end: end,
      ),
      trailing30Days: _periodSummary(
        hifzRows: hifzRows,
        historyRows: historyRows,
        readingRows: readingRows,
        start: start30,
        end: end,
      ),
      goals: goal == null
          ? const DailyGoalSummary.empty()
          : DailyGoalSummary(
              newHifzAyahsTarget: goal.newHifzAyahsTarget,
              revisionAyahsTarget: goal.revisionAyahsTarget,
              readingPagesTarget: goal.readingPagesTarget,
            ),
    );
  }

  HifzStatusSummary _statusSummary(List<HifzProgressRow> rows) {
    var learning = 0;
    var memorized = 0;
    var needsRevision = 0;
    var strong = 0;

    for (final row in rows) {
      switch (_statusFromName(row.status)) {
        case HifzStatus.notStarted:
          break;
        case HifzStatus.learning:
          learning++;
        case HifzStatus.memorized:
          memorized++;
        case HifzStatus.needsRevision:
          needsRevision++;
        case HifzStatus.strong:
          strong++;
      }
    }

    return HifzStatusSummary(
      learning: learning,
      memorized: memorized,
      needsRevision: needsRevision,
      strong: strong,
    );
  }

  ProgressPeriodSummary _periodSummary({
    required List<HifzProgressRow> hifzRows,
    required List<HifzReviewHistoryRow> historyRows,
    required List<ReadingPageVisitRow> readingRows,
    required DateTime start,
    required DateTime end,
  }) {
    final newHifz = hifzRows.where((row) {
      final memorizedAt = row.memorizedAt;
      return memorizedAt != null &&
          !memorizedAt.isBefore(start) &&
          !memorizedAt.isAfter(end);
    }).length;

    final revision = historyRows.where((row) {
      return row.previousIntervalIndex >= 0 &&
          !row.reviewedAt.isBefore(start) &&
          !row.reviewedAt.isAfter(end);
    }).length;

    final pages = readingRows.where((row) {
      return !row.readAt.isBefore(start) && !row.readAt.isAfter(end);
    }).length;

    return ProgressPeriodSummary(
      newHifzAyahs: newHifz,
      revisionAyahs: revision,
      readingPages: pages,
    );
  }

  HifzStatus _statusFromName(String value) {
    return HifzStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw StateError('Unknown Hifz status: $value'),
    );
  }
}
