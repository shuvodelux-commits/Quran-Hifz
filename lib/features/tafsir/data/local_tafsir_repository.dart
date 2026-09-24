import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../../core/database/user_database.dart';
import '../domain/tafsir_entry.dart';
import '../domain/tafsir_repository.dart';

class LocalTafsirRepository implements TafsirRepository {
  LocalTafsirRepository(this._database);

  final UserDatabase _database;

  @override
  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async {
    final record = await _database.getInstalledTafsirPackage(sourceId);
    if (record == null ||
        surahNumber < 1 ||
        surahNumber > 114 ||
        !await File(record.localPath).exists())
      return const [];
    final package = sqlite3.open(record.localPath, mode: OpenMode.readOnly);
    try {
      if (_hasSourceEntries(package)) {
        final rows = package.select(
          'SELECT ayah_number, translation, footnotes FROM source_entries '
          'WHERE surah_number = ? ORDER BY ayah_number',
          [surahNumber],
        );
        return [
          for (final row in rows)
            TafsirEntry(
              sourceId: record.sourceId,
              sourceName: record.name,
              language: record.language,
              version: record.version,
              surahNumber: surahNumber,
              ayahNumber: row['ayah_number'] as int,
              text: _combinedTafsirText(
                translation: row['translation'] as String,
                footnotes: row['footnotes'] as String,
              ),
              attribution: record.attribution,
              license: record.license,
            ),
        ];
      }

      final rows = package.select(
        'SELECT ayah_number, text FROM tafsir_entries '
        'WHERE surah_number = ? ORDER BY ayah_number',
        [surahNumber],
      );
      return [
        for (final row in rows)
          TafsirEntry(
            sourceId: record.sourceId,
            sourceName: record.name,
            language: record.language,
            version: record.version,
            surahNumber: surahNumber,
            ayahNumber: row['ayah_number'] as int,
            text: _plainTafsirText(row['text'] as String),
            attribution: record.attribution,
            license: record.license,
          ),
      ];
    } finally {
      package.close();
    }
  }

  @override
  Future<List<TafsirSource>> listInstalledSources() async {
    final records = await _database.listInstalledTafsirPackages();
    final sources = <TafsirSource>[];
    for (final record in records) {
      if (await File(record.localPath).exists()) {
        sources.add(_sourceFromRecord(record));
      }
    }
    return List.unmodifiable(sources);
  }

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final record = await _database.getInstalledTafsirPackage(sourceId);
    if (record == null || surahNumber < 1 || ayahNumber < 1) return null;
    final file = File(record.localPath);
    if (!await file.exists()) return null;

    final package = sqlite3.open(record.localPath, mode: OpenMode.readOnly);
    try {
      if (_hasSourceEntries(package)) {
        final rows = package.select(
          'SELECT translation, footnotes FROM source_entries '
          'WHERE surah_number = ? AND ayah_number = ? LIMIT 1',
          [surahNumber, ayahNumber],
        );
        if (rows.isEmpty) return null;
        return TafsirEntry(
          sourceId: record.sourceId,
          sourceName: record.name,
          language: record.language,
          version: record.version,
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          text: _combinedTafsirText(
            translation: rows.first['translation'] as String,
            footnotes: rows.first['footnotes'] as String,
          ),
          attribution: record.attribution,
          license: record.license,
        );
      }

      final rows = package.select(
        'SELECT text FROM tafsir_entries '
        'WHERE surah_number = ? AND ayah_number = ? LIMIT 1',
        [surahNumber, ayahNumber],
      );
      if (rows.isEmpty) return null;
      return TafsirEntry(
        sourceId: record.sourceId,
        sourceName: record.name,
        language: record.language,
        version: record.version,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        text: _plainTafsirText(rows.first['text']! as String),
        attribution: record.attribution,
        license: record.license,
      );
    } finally {
      package.close();
    }
  }

  TafsirSource _sourceFromRecord(InstalledTafsirPackageRecord record) {
    return TafsirSource(
      sourceId: record.sourceId,
      name: record.name,
      language: record.language,
      version: record.version,
      localPath: record.localPath,
      attribution: record.attribution,
      license: record.license,
    );
  }
}

bool _hasSourceEntries(Database package) {
  return package
      .select(
        "SELECT 1 FROM sqlite_master "
        "WHERE type = 'table' AND name = 'source_entries' LIMIT 1",
      )
      .isNotEmpty;
}

String _combinedTafsirText({
  required String translation,
  required String footnotes,
}) {
  final plainTranslation = _plainTafsirText(translation);
  final plainFootnotes = _plainTafsirText(footnotes);
  if (plainTranslation.isEmpty) return plainFootnotes;
  if (plainFootnotes.isEmpty) return plainTranslation;
  return '$plainTranslation\n\n$plainFootnotes';
}

String _plainTafsirText(String source) {
  final text = source
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(
        RegExp(r'</(?:p|div|li|h[1-6])\s*>', caseSensitive: false),
        '\n',
      )
      .replaceAll(RegExp(r'</?[a-z][^>]*>', caseSensitive: false), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");

  return text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('\n');
}
