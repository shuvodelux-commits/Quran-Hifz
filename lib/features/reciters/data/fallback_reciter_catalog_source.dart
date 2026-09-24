import '../domain/reciter_catalog_source.dart';

class FallbackReciterCatalogSource implements ReciterCatalogSource {
  FallbackReciterCatalogSource({
    required ReciterCatalogSource primary,
    required ReciterCatalogSource fallback,
  }) : _primary = primary,
       _fallback = fallback;

  final ReciterCatalogSource _primary;
  final ReciterCatalogSource _fallback;

  @override
  Future<List<Map<String, dynamic>>> fetchChapterReciters() async {
    try {
      return await _primary.fetchChapterReciters();
    } catch (_) {
      return _fallback.fetchChapterReciters();
    }
  }
}
