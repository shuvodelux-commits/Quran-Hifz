import 'progress_summary.dart';

abstract interface class ProgressRepository {
  Future<ProgressSummary> loadSummary(DateTime day);
}
