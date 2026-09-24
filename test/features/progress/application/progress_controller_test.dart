import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/time/clock.dart';
import 'package:quran_hifz/features/progress/application/progress_controller.dart';
import 'package:quran_hifz/features/progress/domain/progress_repository.dart';
import 'package:quran_hifz/features/progress/domain/progress_summary.dart';

void main() {
  test(
    'controller requests summary for the injected current calendar day',
    () async {
      final repository = _RecordingProgressRepository();
      final container = ProviderContainer(
        overrides: [
          progressRepositoryProvider.overrideWithValue(repository),
          progressClockProvider.overrideWithValue(
            _FakeClock(DateTime.utc(2026, 9, 4, 22, 15)),
          ),
        ],
      );
      addTearDown(container.dispose);

      final summary = await container.read(progressControllerProvider.future);

      expect(repository.requestedDays, [DateTime.utc(2026, 9, 4)]);
      expect(summary.today.readingPages, 2);
    },
  );
}

class _RecordingProgressRepository implements ProgressRepository {
  final List<DateTime> requestedDays = [];

  @override
  Future<ProgressSummary> loadSummary(DateTime day) async {
    requestedDays.add(day);
    return ProgressSummary.empty(day).copyWith(
      today: const ProgressPeriodSummary(
        newHifzAyahs: 1,
        revisionAyahs: 3,
        readingPages: 2,
      ),
    );
  }
}

class _FakeClock implements AppClock {
  const _FakeClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
