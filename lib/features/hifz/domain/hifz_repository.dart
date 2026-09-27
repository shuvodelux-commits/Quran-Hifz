import 'hifz_progress.dart';
import 'hifz_session.dart';

abstract class HifzRepository {
  Future<HifzProgress?> loadProgress({
    required String profileKey,
    required AyahRef ayah,
  });

  Future<List<HifzProgress>> loadSurahProgress({
    required String profileKey,
    required int surahNumber,
  });

  Future<void> saveProgress({
    required String profileKey,
    required HifzProgress progress,
  });

  Future<void> markRangeLearning({
    required String profileKey,
    required AyahRef start,
    required AyahRef end,
  });

  Future<HifzSessionCheckpoint?> loadCheckpoint(String profileKey);

  Future<void> saveCheckpoint(HifzSessionCheckpoint checkpoint);
}
