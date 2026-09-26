import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../../../core/database/user_database.dart';
import '../../../core/network/quran_backend_client.dart';
import '../../tafsir/data/tafsir_text_normalizer.dart';
import '../domain/quran_translation_source.dart';

class QuranTranslationPackageValidationException implements Exception {
  QuranTranslationPackageValidationException(this.message);

  final String message;

  @override
  String toString() => 'QuranTranslationPackageValidationException: $message';
}

class QuranFoundationTranslationInstaller {
  QuranFoundationTranslationInstaller({
    required UserDatabase database,
    required QuranContentResourceBackendClient client,
    required Future<Directory> Function() rootDirectory,
    required Future<Map<int, int>> Function() canonicalAyahBounds,
  }) : _database = database,
       _client = client,
       _rootDirectory = rootDirectory,
       _canonicalAyahBounds = canonicalAyahBounds;

  final UserDatabase _database;
  final QuranContentResourceBackendClient _client;
  final Future<Directory> Function() _rootDirectory;
  final Future<Map<int, int>> Function() _canonicalAyahBounds;

  Future<QuranTranslationSource> install(QuranTranslationSource source) async {
    final resourceId = source.resourceId;
    if (resourceId == null || resourceId <= 0) {
      throw QuranTranslationPackageValidationException(
        'Translation source has no valid Quran Foundation resource id.',
      );
    }

    final snapshot = await _client.getContentSnapshot(
      group: 'translations',
      resourceId: resourceId,
    );
    if (snapshot['resource_group'] != 'translations' ||
        snapshot['resource_id'] != resourceId) {
      throw QuranTranslationPackageValidationException(
        'Translation snapshot identity does not match the selected source.',
      );
    }
    final rawRecords = snapshot['records'];
    if (rawRecords is! List) {
      throw QuranTranslationPackageValidationException(
        'Translation snapshot has no records.',
      );
    }

    final bounds = await _canonicalAyahBounds();
    final expectedKeys = <String>{
      for (final entry in bounds.entries)
        for (var ayah = 1; ayah <= entry.value; ayah++) '${entry.key}:$ayah',
    };
    final entries = <String, String>{};
    for (final raw in rawRecords) {
      if (raw is! Map) {
        throw QuranTranslationPackageValidationException(
          'Translation snapshot contains an invalid record.',
        );
      }
      final row = Map<String, dynamic>.from(raw);
      if (row['resource_id'] != resourceId ||
          row['verse_key'] is! String ||
          row['text'] is! String) {
        throw QuranTranslationPackageValidationException(
          'Translation snapshot record identity is invalid.',
        );
      }
      final verseKey = row['verse_key'] as String;
      if (!expectedKeys.contains(verseKey) || entries.containsKey(verseKey)) {
        throw QuranTranslationPackageValidationException(
          'Translation snapshot contains duplicate or unexpected ayahs.',
        );
      }
      final text = plainTafsirText(row['text'] as String).trim();
      if (text.isEmpty) {
        throw QuranTranslationPackageValidationException(
          'Translation snapshot contains an empty ayah.',
        );
      }
      entries[verseKey] = text;
    }
    if (entries.length != expectedKeys.length ||
        !entries.keys.toSet().containsAll(expectedKeys)) {
      throw QuranTranslationPackageValidationException(
        'Translation snapshot is incomplete.',
      );
    }

    final root = await _rootDirectory();
    final directory = Directory(p.join(root.path, 'translations'));
    await directory.create(recursive: true);
    final finalFile = File(p.join(directory.path, 'qf-$resourceId.sqlite'));
    final partFile = File('${finalFile.path}.part');
    if (await partFile.exists()) await partFile.delete();

    final sqlite = sqlite3.open(partFile.path);
    try {
      sqlite.execute('''
        CREATE TABLE translation_entries (
          surah_number INTEGER NOT NULL,
          ayah_number INTEGER NOT NULL,
          text TEXT NOT NULL,
          PRIMARY KEY (surah_number, ayah_number)
        )
      ''');
      sqlite.execute('BEGIN');
      try {
        final statement = sqlite.prepare(
          'INSERT INTO translation_entries '
          '(surah_number, ayah_number, text) VALUES (?, ?, ?)',
        );
        try {
          final keys = entries.keys.toList()
            ..sort((a, b) {
              final ap = a.split(':').map(int.parse).toList();
              final bp = b.split(':').map(int.parse).toList();
              final surah = ap[0].compareTo(bp[0]);
              return surah != 0 ? surah : ap[1].compareTo(bp[1]);
            });
          for (final key in keys) {
            final parts = key.split(':');
            statement.execute([
              int.parse(parts[0]),
              int.parse(parts[1]),
              entries[key]!,
            ]);
          }
        } finally {
          statement.dispose();
        }
        sqlite.execute('COMMIT');
      } catch (_) {
        sqlite.execute('ROLLBACK');
        rethrow;
      }
    } finally {
      sqlite.close();
    }

    if (await finalFile.exists()) await finalFile.delete();
    await partFile.rename(finalFile.path);
    try {
      await _database.upsertInstalledTranslationPackage(
        sourceId: source.sourceId,
        resourceId: resourceId,
        name: source.name,
        language: source.language,
        version: source.version,
        localPath: finalFile.path,
        author: source.author,
        recordCount: entries.length,
      );
    } catch (_) {
      if (await finalFile.exists()) await finalFile.delete();
      rethrow;
    }

    return QuranTranslationSource(
      sourceId: source.sourceId,
      resourceId: resourceId,
      name: source.name,
      language: source.language,
      version: source.version,
      author: source.author,
      localPath: finalFile.path,
      kind: QuranTranslationSourceKind.downloaded,
      availableOffline: true,
    );
  }
}
