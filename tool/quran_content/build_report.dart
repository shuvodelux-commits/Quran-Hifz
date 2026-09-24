import 'quran_integrity_validator.dart';

Map<String, Object> buildQuranPackageManifest({
  required int schemaVersion,
  required String contentVersion,
  required String databaseSha256,
}) {
  return {
    'schema_version': schemaVersion,
    'content_version': contentVersion,
    'database_sha256': databaseSha256,
  };
}

Map<String, Object> buildQuranReportDocument({
  required int schemaVersion,
  required String contentVersion,
  required String databaseSha256,
  required int databaseSizeBytes,
  required Map<String, Map<String, Object>> sources,
  required int translationResourceId,
  required String translationLanguage,
  required QuranIntegrityReport integrity,
}) {
  return {
    'schema_version': schemaVersion,
    'content_version': contentVersion,
    'database_sha256': databaseSha256,
    'database_size_bytes': databaseSizeBytes,
    'sources': sources,
    'translation_resource_id': translationResourceId,
    'translation_language': translationLanguage,
    'integrity': integrity.toJson(),
  };
}
