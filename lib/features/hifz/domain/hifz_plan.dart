import 'hifz_preset.dart';
import 'hifz_session.dart';

class HifzPlan {
  const HifzPlan({
    required this.id,
    required this.profileKey,
    required this.title,
    required this.start,
    required this.end,
    required this.startPage,
    required this.preset,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String profileKey;
  final String title;
  final AyahRef start;
  final AyahRef end;
  final int startPage;
  final HifzPreset preset;
  final DateTime createdAt;
  final DateTime updatedAt;

  HifzSessionConfig get sessionConfig =>
      HifzSessionConfig(start: start, end: end, preset: preset);
}

abstract class HifzPlanRepository {
  Stream<List<HifzPlan>> watchPlans(String profileKey);

  Future<int> createPlan({
    required String profileKey,
    required String title,
    required AyahRef start,
    required AyahRef end,
    required int startPage,
    required HifzPreset preset,
  });

  Future<void> deletePlan(int id);
}
