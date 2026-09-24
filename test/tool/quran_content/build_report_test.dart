import 'package:flutter_test/flutter_test.dart';

import '../../../tool/quran_content/build_report.dart';
import '../../../tool/quran_content/quran_integrity_validator.dart';

void main() {
  test('build report embeds the canonical integrity result', () {
    const integrity = QuranIntegrityReport(
      surahCount: 114,
      ayahCount: 6236,
      wordCount: 10,
      translationCount: 6236,
      errors: [],
    );

    final report = buildQuranReportDocument(
      schemaVersion: 1,
      contentVersion: '2026.09.04',
      databaseSha256: 'database-hash',
      databaseSizeBytes: 1234,
      sources: const {
        'quran': {'name': 'quran', 'version': 'v1', 'sha256': 'quran-hash'},
      },
      translationResourceId: 1,
      translationLanguage: 'bn',
      integrity: integrity,
    );

    expect(report['integrity'], integrity.toJson());
    expect((report['integrity'] as Map<String, Object>)['valid'], isTrue);
    expect((report['integrity'] as Map<String, Object>)['ayah_count'], 6236);
  });

  test('package manifest contains installer verification identity', () {
    final manifest = buildQuranPackageManifest(
      schemaVersion: 1,
      contentVersion: '2026.09.12',
      databaseSha256:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    );

    expect(manifest, {
      'schema_version': 1,
      'content_version': '2026.09.12',
      'database_sha256':
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    });
  });
}
