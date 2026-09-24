import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/quran_content_bootstrap.dart';
import 'package:quran_hifz/core/database/quran_content_database.dart';
import 'package:quran_hifz/core/database/quran_content_installer.dart';

void main() {
  test(
    'bootstrap installs verified package then opens exact installed path',
    () async {
      const expectedPath = '/verified/quran_content.sqlite';
      QuranContentPackageManifest? installedManifest;
      String? openedPath;
      final database = QuranContentDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final bootstrap = QuranContentBootstrap(
        manifestLoader: () async => jsonEncode({
          'content_version': '2026.09.12',
          'schema_version': 1,
          'database_sha256':
              'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        }),
        install: (manifest) async {
          installedManifest = manifest;
          return const QuranContentInstallResult(
            databasePath: expectedPath,
            contentVersion: '2026.09.12',
            installedNow: true,
          );
        },
        openDatabase: (path) {
          openedPath = path;
          return database;
        },
      );

      final result = await bootstrap.openDatabase();

      expect(result, same(database));
      expect(openedPath, expectedPath);
      expect(installedManifest?.contentVersion, '2026.09.12');
      expect(installedManifest?.schemaVersion, 1);
    },
  );

  test(
    'bootstrap rejects malformed package manifest before installation',
    () async {
      var installCalled = false;
      final bootstrap = QuranContentBootstrap(
        manifestLoader: () async => '{"content_version":"bad"}',
        install: (_) async {
          installCalled = true;
          throw StateError('must not be reached');
        },
        openDatabase: (_) => throw StateError('must not be reached'),
      );

      await expectLater(bootstrap.openDatabase(), throwsFormatException);
      expect(installCalled, isFalse);
    },
  );
}
