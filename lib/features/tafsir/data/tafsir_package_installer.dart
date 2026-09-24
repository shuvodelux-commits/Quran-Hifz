import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../../../core/database/user_database.dart';
import '../../../core/storage/storage_capacity.dart';
import '../domain/tafsir_entry.dart';
import '../domain/tafsir_package_manifest.dart';

class TafsirTransportResponse {
  const TafsirTransportResponse({
    required this.statusCode,
    required this.contentLength,
    required this.bytes,
  });

  final int statusCode;
  final int? contentLength;
  final Stream<List<int>> bytes;
}

abstract class TafsirPackageTransport {
  Future<TafsirTransportResponse> open(Uri uri);
  void close();
}

class DartIoTafsirPackageTransport implements TafsirPackageTransport {
  DartIoTafsirPackageTransport({HttpClient? client})
    : _client = client ?? HttpClient();

  final HttpClient _client;

  @override
  Future<TafsirTransportResponse> open(Uri uri) async {
    final request = await _client.getUrl(uri);
    final response = await request.close();
    return TafsirTransportResponse(
      statusCode: response.statusCode,
      contentLength: response.contentLength >= 0
          ? response.contentLength
          : null,
      bytes: response,
    );
  }

  @override
  void close() => _client.close(force: true);
}

class TafsirPackageValidationException implements Exception {
  TafsirPackageValidationException(this.message);
  final String message;

  @override
  String toString() => 'TafsirPackageValidationException: $message';
}

class TafsirPackageStorageException implements Exception {
  TafsirPackageStorageException(this.message);
  final String message;

  @override
  String toString() => 'TafsirPackageStorageException: $message';
}

class TafsirPackageInstaller {
  TafsirPackageInstaller({
    required UserDatabase database,
    required Future<Directory> Function() rootDirectory,
    required TafsirPackageTransport transport,
    required StorageCapacity storageCapacity,
    required Future<Map<int, int>> Function() canonicalAyahBounds,
  }) : _database = database,
       _rootDirectory = rootDirectory,
       _transport = transport,
       _storageCapacity = storageCapacity,
       _canonicalAyahBounds = canonicalAyahBounds;

  final UserDatabase _database;
  final Future<Directory> Function() _rootDirectory;
  final TafsirPackageTransport _transport;
  final StorageCapacity _storageCapacity;
  final Future<Map<int, int>> Function() _canonicalAyahBounds;

  Future<TafsirSource> install(TafsirPackageManifest manifest) async {
    final root = await _rootDirectory();
    final directory = Directory(p.join(root.path, 'tafsir', manifest.sourceId));
    await directory.create(recursive: true);

    final freeBytes = await _storageCapacity.freeBytesFor(directory.path);
    if (freeBytes != null && freeBytes < manifest.sizeBytes) {
      throw TafsirPackageStorageException(
        'Not enough free storage for ${manifest.name}.',
      );
    }

    final partFile = File(
      p.join(directory.path, '${manifest.version}.sqlite.part'),
    );
    final finalFile = File(
      p.join(directory.path, '${manifest.version}.sqlite'),
    );
    final backupFile = File('${finalFile.path}.bak');
    if (await partFile.exists()) await partFile.delete();

    final response = await _transport.open(manifest.downloadUrl);
    if (response.statusCode != HttpStatus.ok) {
      throw TafsirPackageValidationException(
        'Package server returned HTTP ${response.statusCode}.',
      );
    }
    if (response.contentLength != null &&
        response.contentLength != manifest.sizeBytes) {
      throw TafsirPackageValidationException(
        'Package size metadata does not match manifest.',
      );
    }

    var received = 0;
    final sink = partFile.openWrite(mode: FileMode.write);
    try {
      await for (final chunk in response.bytes) {
        if (received + chunk.length > manifest.sizeBytes) {
          throw TafsirPackageValidationException(
            'Package is larger than its manifest size.',
          );
        }
        sink.add(chunk);
        received += chunk.length;
      }
      await sink.flush();
    } catch (error, stackTrace) {
      await sink.close();
      if (await partFile.exists()) await partFile.delete();
      Error.throwWithStackTrace(error, stackTrace);
    }
    await sink.close();

    try {
      if (received != manifest.sizeBytes ||
          await partFile.length() != manifest.sizeBytes) {
        throw TafsirPackageValidationException(
          'Package download is incomplete.',
        );
      }

      final digest = await sha256.bind(partFile.openRead()).first;
      if (digest.toString().toLowerCase() != manifest.sha256.toLowerCase()) {
        throw TafsirPackageValidationException(
          'Package SHA-256 does not match manifest.',
        );
      }

      await _validateSqlitePackage(partFile.path, manifest);

      final previous = await _database.getInstalledTafsirPackage(
        manifest.sourceId,
      );
      var backedUp = false;
      if (await backupFile.exists()) await backupFile.delete();
      if (await finalFile.exists()) {
        await finalFile.rename(backupFile.path);
        backedUp = true;
      }

      try {
        await partFile.rename(finalFile.path);
        await _database.upsertInstalledTafsirPackage(
          sourceId: manifest.sourceId,
          name: manifest.name,
          language: manifest.language,
          version: manifest.version,
          localPath: finalFile.path,
          sha256: manifest.sha256.toLowerCase(),
          attribution: manifest.attribution,
          license: manifest.license,
        );
        if (backedUp && await backupFile.exists()) await backupFile.delete();
      } catch (_) {
        if (await finalFile.exists()) await finalFile.delete();
        if (backedUp && await backupFile.exists()) {
          await backupFile.rename(finalFile.path);
        }
        rethrow;
      }

      if (previous != null && previous.localPath != finalFile.path) {
        final oldFile = File(previous.localPath);
        if (await oldFile.exists()) {
          try {
            await oldFile.delete();
          } on FileSystemException {
            // The new verified package is already authoritative in the registry.
            // A stale old-version file is safe to clean up on a later maintenance pass.
          }
        }
      }

      return TafsirSource(
        sourceId: manifest.sourceId,
        name: manifest.name,
        language: manifest.language,
        version: manifest.version,
        localPath: finalFile.path,
        attribution: manifest.attribution,
        license: manifest.license,
      );
    } finally {
      if (await partFile.exists()) await partFile.delete();
    }
  }

  Future<void> _validateSqlitePackage(
    String path,
    TafsirPackageManifest manifest,
  ) async {
    final db = sqlite3.open(path, mode: OpenMode.readOnly);
    try {
      final quickCheck = db.select('PRAGMA quick_check');
      if (quickCheck.isEmpty || quickCheck.first.values.first != 'ok') {
        throw TafsirPackageValidationException(
          'SQLite integrity check failed.',
        );
      }

      final tables = db.select(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name IN ('tafsir_metadata', 'tafsir_entries')",
      );
      final names = tables.map((row) => row['name'] as String).toSet();
      if (!names.containsAll({'tafsir_metadata', 'tafsir_entries'})) {
        throw TafsirPackageValidationException(
          'Required tafsir tables are missing.',
        );
      }

      final metadataRows = db.select(
        'SELECT metadata_key, metadata_value FROM tafsir_metadata',
      );
      final metadata = <String, String>{
        for (final row in metadataRows)
          row['metadata_key']! as String: row['metadata_value']! as String,
      };
      if (metadata['source_id'] != manifest.sourceId ||
          metadata['version'] != manifest.version ||
          metadata['language'] != manifest.language) {
        throw TafsirPackageValidationException(
          'Package metadata does not match manifest identity.',
        );
      }

      final bounds = await _canonicalAyahBounds();
      if (bounds.isEmpty) {
        throw TafsirPackageValidationException(
          'Canonical Quran ayah bounds are unavailable.',
        );
      }
      final entries = db.select(
        'SELECT surah_number, ayah_number, text FROM tafsir_entries '
        'ORDER BY surah_number, ayah_number',
      );
      if (entries.isEmpty) {
        throw TafsirPackageValidationException(
          'Tafsir package contains no entries.',
        );
      }
      for (final row in entries) {
        final surah = row['surah_number']! as int;
        final ayah = row['ayah_number']! as int;
        final text = row['text']! as String;
        final maxAyah = bounds[surah];
        if (maxAyah == null ||
            ayah < 1 ||
            ayah > maxAyah ||
            text.trim().isEmpty) {
          throw TafsirPackageValidationException(
            'Package contains an invalid Quran reference.',
          );
        }
      }
    } on TafsirPackageValidationException {
      rethrow;
    } catch (error) {
      throw TafsirPackageValidationException(
        'Package schema could not be validated: $error',
      );
    } finally {
      db.close();
    }
  }

  void dispose() => _transport.close();
}
