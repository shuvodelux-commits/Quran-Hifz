import 'quran_search_result.dart';

abstract class QuranSearchRepository {
  Future<List<QuranSearchResult>> search(
    String query, {
    required int translationResourceId,
    int limit = 50,
  });
}
