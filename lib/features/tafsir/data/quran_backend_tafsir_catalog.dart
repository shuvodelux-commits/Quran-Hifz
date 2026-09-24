import '../../../core/network/quran_backend_client.dart';
import '../domain/tafsir_catalog.dart';
import '../domain/tafsir_package_manifest.dart';

class QuranBackendTafsirCatalog implements TafsirCatalog {
  QuranBackendTafsirCatalog(this._client);

  final QuranBackendClient _client;

  @override
  Future<TafsirPackageManifest> fetchPrimaryBanglaManifest() async {
    final json = await _client.getZakariaTafsirManifest();
    final manifest = TafsirPackageManifest.fromJson(json);
    if (manifest.sourceId != primaryBanglaTafsirSourceId ||
        manifest.language != 'bn') {
      throw const FormatException('Unexpected primary Bangla tafsir identity.');
    }
    return manifest;
  }
}
