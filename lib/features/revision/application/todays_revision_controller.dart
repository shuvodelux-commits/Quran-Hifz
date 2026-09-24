import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/time/calendar_day.dart';
import '../../../core/time/clock.dart';
import '../../hifz/domain/hifz_session.dart';
import '../../hifz/domain/memorization_result.dart';
import '../data/drift_revision_repository.dart';
import '../domain/revision_item.dart';
import '../domain/revision_repository.dart';
import 'revision_scheduler.dart';

final appClockProvider = Provider<AppClock>((ref) => const SystemAppClock());

final revisionRepositoryProvider = Provider<RevisionRepository>((ref) {
  return DriftRevisionRepository(ref.watch(userDatabaseProvider));
});

final revisionSchedulerProvider = Provider<RevisionScheduler>((ref) {
  return RevisionScheduler(
    repository: ref.watch(revisionRepositoryProvider),
    clock: ref.watch(appClockProvider),
  );
});

final todaysRevisionControllerProvider =
    AsyncNotifierProvider<TodaysRevisionController, List<RevisionGroup>>(
      TodaysRevisionController.new,
    );

class TodaysRevisionController extends AsyncNotifier<List<RevisionGroup>> {
  static const profileKey = 'default';

  @override
  Future<List<RevisionGroup>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> recordResult({
    required AyahRef ayah,
    required MemorizationResult result,
  }) async {
    await ref
        .read(revisionSchedulerProvider)
        .recordResult(profileKey: profileKey, ayah: ayah, result: result);
    state = AsyncData(await _load());
  }

  Future<List<RevisionGroup>> _load() async {
    final now = ref.read(appClockProvider).now();
    final cutoff = calendarDayEnd(now);
    final due = await ref
        .read(revisionRepositoryProvider)
        .loadDue(profileKey: profileKey, onOrBefore: cutoff);
    return groupContiguousRevisionItems(due);
  }
}

List<RevisionGroup> groupContiguousRevisionItems(List<RevisionItem> items) {
  if (items.isEmpty) return const [];

  final groups = <RevisionGroup>[];
  var current = <RevisionItem>[items.first];

  void flush() {
    final first = current.first;
    final last = current.last;
    groups.add(
      RevisionGroup(
        surahNumber: first.ayah.surahNumber,
        startAyah: first.ayah.ayahNumber,
        endAyah: last.ayah.ayahNumber,
        items: List<RevisionItem>.unmodifiable(current),
      ),
    );
  }

  for (final item in items.skip(1)) {
    final previous = current.last;
    final contiguous =
        item.ayah.surahNumber == previous.ayah.surahNumber &&
        item.ayah.ayahNumber == previous.ayah.ayahNumber + 1;
    if (contiguous) {
      current.add(item);
      continue;
    }

    flush();
    current = <RevisionItem>[item];
  }
  flush();
  return List<RevisionGroup>.unmodifiable(groups);
}
