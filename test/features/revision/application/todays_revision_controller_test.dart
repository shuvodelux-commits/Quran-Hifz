import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_hifz/core/time/calendar_day.dart';
import 'package:quran_hifz/core/time/clock.dart';
import 'package:quran_hifz/features/revision/domain/revision_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_progress.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/revision/application/todays_revision_controller.dart';
import 'package:quran_hifz/features/revision/domain/revision_item.dart';

void main() {
  test('today query includes the final microsecond of the day', () async {
    final repository = _CutoffRecordingRepository();
    final now = DateTime.utc(2026, 9, 4, 12);
    final container = ProviderContainer(
      overrides: [
        revisionRepositoryProvider.overrideWithValue(repository),
        appClockProvider.overrideWithValue(_FakeClock(now)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(todaysRevisionControllerProvider.future);

    expect(repository.cutoff, calendarDayEnd(now));
  });

  test('groups only contiguous due ayahs inside the same Surah', () {
    final due = [_item(55, 1), _item(67, 1), _item(67, 2), _item(67, 4)];

    final groups = groupContiguousRevisionItems(due);

    expect(groups, hasLength(3));
    expect(
      groups
          .map(
            (group) =>
                '${group.surahNumber}:${group.startAyah}-${group.endAyah}',
          )
          .toList(),
      ['55:1-1', '67:1-2', '67:4-4'],
    );
    expect(groups[1].ayahCount, 2);
  });
}

RevisionItem _item(int surah, int ayah) {
  return RevisionItem(
    ayah: AyahRef(surahNumber: surah, ayahNumber: ayah),
    status: HifzStatus.needsRevision,
    strengthScore: 50,
    revisionIntervalIndex: 0,
    nextReviewAt: DateTime.utc(2026, 9, 4),
  );
}

class _CutoffRecordingRepository implements RevisionRepository {
  DateTime? cutoff;

  @override
  Future<List<RevisionItem>> loadDue({
    required String profileKey,
    required DateTime onOrBefore,
  }) async {
    cutoff = onOrBefore;
    return const [];
  }

  @override
  Future<HifzProgress?> loadProgress({
    required String profileKey,
    required AyahRef ayah,
  }) async => null;

  @override
  Future<void> recordReview({
    required String profileKey,
    required HifzProgress updatedProgress,
    required RevisionHistoryEntry historyEntry,
  }) async {}
}

class _FakeClock implements AppClock {
  const _FakeClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
