import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/time/calendar_day.dart';
import '../../../core/time/clock.dart';
import '../data/drift_progress_repository.dart';
import '../domain/progress_repository.dart';
import '../domain/progress_summary.dart';

final progressClockProvider = Provider<AppClock>(
  (ref) => const SystemAppClock(),
);

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return DriftProgressRepository(ref.watch(userDatabaseProvider));
});

final progressControllerProvider =
    AsyncNotifierProvider<ProgressController, ProgressSummary>(
      ProgressController.new,
    );

class ProgressController extends AsyncNotifier<ProgressSummary> {
  @override
  Future<ProgressSummary> build() {
    final day = calendarDayStart(ref.read(progressClockProvider).now());
    return ref.read(progressRepositoryProvider).loadSummary(day);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final day = calendarDayStart(ref.read(progressClockProvider).now());
      return ref.read(progressRepositoryProvider).loadSummary(day);
    });
  }
}
