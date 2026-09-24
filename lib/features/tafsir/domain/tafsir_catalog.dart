import 'tafsir_package_manifest.dart';

const primaryBanglaTafsirSourceId = 'bn.abubakar_zakaria.quranenc';
const primaryBanglaTafsirName = 'তাফসীরে আবু বকর যাকারিয়া';

abstract class TafsirCatalog {
  Future<TafsirPackageManifest> fetchPrimaryBanglaManifest();
}
