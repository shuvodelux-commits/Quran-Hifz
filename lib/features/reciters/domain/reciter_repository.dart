import 'chapter_reciter.dart';

abstract class ReciterRepository {
  Future<List<ChapterReciter>> loadCatalog();
  Future<int?> loadSelectedReciterId();
  Future<void> selectReciter(int id);
  Future<void> clearSelectedReciter();
}
