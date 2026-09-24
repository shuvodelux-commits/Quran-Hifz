import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

typedef QuranAssetLoader = Future<List<int>> Function(String assetPath);
typedef SupportDirectoryResolver = Future<Directory> Function();

class QuranContentPackageManifest {
  const QuranContentPackageManifest({
    required this.contentVersion,
    required this.schemaVersion,
    required this.sha256,
  });

  final String contentVersion;
  final int schemaVersion;
  final String sha256;

  factory QuranContentPackageManifest.fromJson(Map<String, dynamic> json) {
    final contentVersion = json['content_version'] as String?;
    final schemaVersion = (json['schema_version'] as num?)?.toInt();
    final digest =
        json['database_sha256'] as String? ?? json['sha256'] as String?;

    if (contentVersion == null ||
        contentVersion.isEmpty ||
        schemaVersion == null ||
        schemaVersion <= 0 ||
        digest == null ||
        !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(digest)) {
      throw const FormatException('Invalid Quran content package manifest');
    }

    return QuranContentPackageManifest(
      contentVersion: contentVersion,
      schemaVersion: schemaVersion,
      sha256: digest.toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() => {
    'content_version': contentVersion,
    'schema_version': schemaVersion,
    'database_sha256': sha256,
  };
}

class QuranContentInstallResult {
  const QuranContentInstallResult({
    required this.databasePath,
    required this.contentVersion,
    required this.installedNow,
  });

  final String databasePath;
  final String contentVersion;
  final bool installedNow;
}

class QuranContentVerificationException implements Exception {
  const QuranContentVerificationException(this.message);

  final String message;

  @override
  String toString() => 'QuranContentVerificationException: $message';
}

class QuranContentInstaller {
  QuranContentInstaller({
    required this.manifest,
    required QuranAssetLoader assetLoader,
    required SupportDirectoryResolver supportDirectory,
    this.assetPath = 'assets/database/quran_content.sqlite',
    this.fileName = 'quran_content.sqlite',
  }) : _assetLoader = assetLoader,
       _supportDirectory = supportDirectory;

  factory QuranContentInstaller.fromBundle({
    required QuranContentPackageManifest manifest,
    String assetPath = 'assets/database/quran_content.sqlite',
  }) {
    return QuranContentInstaller(
      manifest: manifest,
      assetPath: assetPath,
      assetLoader: (path) async {
        final data = await rootBundle.load(path);
        return Uint8List.sublistView(data);
      },
      supportDirectory: getApplicationSupportDirectory,
    );
  }

  final QuranContentPackageManifest manifest;
  final QuranAssetLoader _assetLoader;
  final SupportDirectoryResolver _supportDirectory;
  final String assetPath;
  final String fileName;

  Future<QuranContentInstallResult> ensureInstalled() async {
    final support = await _supportDirectory();
    final directory = Directory(p.join(support.path, 'quran'));
    await directory.create(recursive: true);

    final finalFile = File(p.join(directory.path, fileName));
    final tempFile = File('${finalFile.path}.tmp');
    final backupFile = File('${finalFile.path}.bak');
    final manifestFile = File('${finalFile.path}.install.json');
    final manifestTempFile = File('${manifestFile.path}.tmp');

    await _deleteIfExists(tempFile);
    await _deleteIfExists(manifestTempFile);

    if (await _isCurrentInstallation(finalFile, manifestFile)) {
      return QuranContentInstallResult(
        databasePath: finalFile.path,
        contentVersion: manifest.contentVersion,
        installedNow: false,
      );
    }

    try {
      final bytes = await _assetLoader(assetPath);
      _verifyBytes(bytes);

      await tempFile.writeAsBytes(bytes, flush: true);
      _verifyDatabaseMetadata(tempFile);

      await manifestTempFile.writeAsString(
        jsonEncode(manifest.toJson()),
        flush: true,
      );

      await _replaceAtomically(
        finalFile: finalFile,
        tempFile: tempFile,
        backupFile: backupFile,
      );

      await _replaceSidecar(
        finalFile: manifestFile,
        tempFile: manifestTempFile,
      );

      return QuranContentInstallResult(
        databasePath: finalFile.path,
        contentVersion: manifest.contentVersion,
        installedNow: true,
      );
    } catch (_) {
      await _deleteIfExists(tempFile);
      await _deleteIfExists(manifestTempFile);
      rethrow;
    }
  }

  Future<bool> _isCurrentInstallation(
    File databaseFile,
    File manifestFile,
  ) async {
    if (!await databaseFile.exists() || !await manifestFile.exists()) {
      return false;
    }

    try {
      final decoded = jsonDecode(await manifestFile.readAsString());
      if (decoded is! Map<String, dynamic>) return false;
      final installed = QuranContentPackageManifest.fromJson(decoded);
      return installed.contentVersion == manifest.contentVersion &&
          installed.schemaVersion == manifest.schemaVersion &&
          installed.sha256.toLowerCase() == manifest.sha256.toLowerCase();
    } on Object {
      return false;
    }
  }

  void _verifyBytes(List<int> bytes) {
    final actual = sha256.convert(bytes).toString();
    if (actual.toLowerCase() != manifest.sha256.toLowerCase()) {
      throw QuranContentVerificationException(
        'Packaged database checksum mismatch: expected ${manifest.sha256}, got $actual',
      );
    }
  }

  void _verifyDatabaseMetadata(File file) {
    Database? database;
    try {
      database = sqlite3.open(file.path, mode: OpenMode.readOnly);
      final schemaVersion = database.userVersion;
      if (schemaVersion != manifest.schemaVersion) {
        throw QuranContentVerificationException(
          'Schema version mismatch: expected ${manifest.schemaVersion}, got $schemaVersion',
        );
      }

      final result = database.select(
        'SELECT metadata_value FROM quran_metadata WHERE metadata_key = ?',
        ['content_version'],
      );
      if (result.length != 1) {
        throw const QuranContentVerificationException(
          'Missing canonical content_version metadata',
        );
      }

      final contentVersion = result.first['metadata_value'] as String?;
      if (contentVersion != manifest.contentVersion) {
        throw QuranContentVerificationException(
          'Content version mismatch: expected ${manifest.contentVersion}, got $contentVersion',
        );
      }
    } on QuranContentVerificationException {
      rethrow;
    } on Object catch (error) {
      throw QuranContentVerificationException(
        'Packaged database could not be verified: $error',
      );
    } finally {
      database?.close();
    }
  }

  Future<void> _replaceAtomically({
    required File finalFile,
    required File tempFile,
    required File backupFile,
  }) async {
    await _deleteIfExists(backupFile);
    final hadFinal = await finalFile.exists();

    if (hadFinal) {
      await finalFile.rename(backupFile.path);
    }

    try {
      await tempFile.rename(finalFile.path);
      await _deleteIfExists(backupFile);
    } catch (_) {
      await _deleteIfExists(finalFile);
      if (hadFinal && await backupFile.exists()) {
        await backupFile.rename(finalFile.path);
      }
      rethrow;
    }
  }

  Future<void> _replaceSidecar({
    required File finalFile,
    required File tempFile,
  }) async {
    await _deleteIfExists(finalFile);
    await tempFile.rename(finalFile.path);
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
