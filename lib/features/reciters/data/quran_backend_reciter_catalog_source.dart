import '../../../core/network/quran_backend_client.dart';
import '../domain/reciter_catalog_source.dart';

class QuranBackendReciterCatalogSource implements ReciterCatalogSource {
  QuranBackendReciterCatalogSource(this._client);

  final QuranBackendClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchChapterReciters() =>
      _client.getChapterReciters();
}
