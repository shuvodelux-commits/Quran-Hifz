import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../../core/database/user_database.dart';
import '../domain/quran_translation_repository.dart';
import '../domain/quran_translation_source.dart';

class LocalQuranTranslationRepository implements QuranTranslationRepository {
  LocalQuranTranslationRepository(this._database);

  final UserDatabase _database;

  @override
  Future<List<QuranTranslationSource>> listInstalledSources() async {
    final records = await _database.listInstalledTranslationPackages();
    final sources = <QuranTranslationSource>[];
    for (final record in records) {
      if (!await File(record.localPath).exists()) continue;
      sources.add(
        QuranTranslationSource(
          sourceId: record.sourceId,
          resourceId: record.resourceId,
          name: record.name,
          language: record.language,
          version: record.version,
          author: record.author,
          localPath: record.localPath,
          kind: QuranTranslationSourceKind.downloaded,
          availableOffline: true,
        ),
      );
    }
    return List.unmodifiable(sources);
  }

  @override
  Future<QuranTranslationEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (surahNumber < 1 || ayahNumber < 1) return null;
    final record = await _database.getInstalledTranslationPackage(sourceId);
    if (record == null || !await File(record.localPath).exists()) return null;
    final sqlite = sqlite3.open(record.localPath, mode: OpenMode.readOnly);
    try {
      final rows = sqlite.select(
        'SELECT text FROM translation_entries '
        'WHERE surah_number = ? AND ayah_number = ? LIMIT 1',
        [surahNumber, ayahNumber],
      );
      if (rows.isEmpty) return null;
      return QuranTranslationEntry(
        sourceId: record.sourceId,
        sourceName: record.name,
        language: record.language,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        text: rows.first['text'] as String,
      );
    } finally {
      sqlite.close();
    }
  }
}
