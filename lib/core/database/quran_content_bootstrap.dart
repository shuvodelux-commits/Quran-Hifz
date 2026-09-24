import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'quran_content_database.dart';
import 'quran_content_installer.dart';

typedef QuranManifestLoader = Future<String> Function();
typedef QuranPackageInstall =
    Future<QuranContentInstallResult> Function(
      QuranContentPackageManifest manifest,
    );
typedef QuranDatabaseOpener = QuranContentDatabase Function(String path);

class QuranContentBootstrap {
  QuranContentBootstrap({
    required QuranManifestLoader manifestLoader,
    required QuranPackageInstall install,
    required QuranDatabaseOpener openDatabase,
  }) : _manifestLoader = manifestLoader,
       _install = install,
       _openDatabase = openDatabase;

  factory QuranContentBootstrap.fromBundle({
    String manifestAssetPath = 'assets/database/quran_content_manifest.json',
    String databaseAssetPath = 'assets/database/quran_content.sqlite',
  }) {
    return QuranContentBootstrap(
      manifestLoader: () => rootBundle.loadString(manifestAssetPath),
      install: (manifest) => QuranContentInstaller.fromBundle(
        manifest: manifest,
        assetPath: databaseAssetPath,
      ).ensureInstalled(),
      openDatabase: QuranContentDatabase.forPath,
    );
  }

  final QuranManifestLoader _manifestLoader;
  final QuranPackageInstall _install;
  final QuranDatabaseOpener _openDatabase;

  Future<QuranContentDatabase> openDatabase() async {
    final rawManifest = await _manifestLoader();
    final decoded = jsonDecode(rawManifest);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid Quran content package manifest');
    }

    final manifest = QuranContentPackageManifest.fromJson(decoded);
    final installed = await _install(manifest);
    return _openDatabase(installed.databasePath);
  }
}
