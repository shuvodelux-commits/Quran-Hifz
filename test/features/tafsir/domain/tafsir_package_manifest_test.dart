import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_package_manifest.dart';

void main() {
  test('manifest rejects unsafe or incomplete package identity', () {
    expect(
      () => TafsirPackageManifest(
        sourceId: '',
        name: 'Tafsir',
        language: 'bn',
        version: '1',
        downloadUrl: Uri.parse('https://example.test/tafsir.sqlite'),
        sha256: List.filled(64, 'a').join(),
        sizeBytes: 10,
        attribution: 'source',
        license: 'license',
      ),
      throwsArgumentError,
    );
  });
}
