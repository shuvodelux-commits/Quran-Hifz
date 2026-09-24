import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/quran_content_installer.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('quran-installer-test-');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('no installed database copies verified asset atomically', () async {
    final package = await _fixturePackage(
      tempDir,
      contentVersion: 'fixture-v1',
    );
    var loadCount = 0;
    final installer = QuranContentInstaller(
      manifest: package.manifest,
      assetLoader: (_) async {
        loadCount++;
        return package.bytes;
      },
      supportDirectory: () async => tempDir,
    );

    final result = await installer.ensureInstalled();

    expect(result.contentVersion, 'fixture-v1');
    expect(File(result.databasePath).existsSync(), isTrue);
    expect(loadCount, 1);
    expect(
      sha256.convert(File(result.databasePath).readAsBytesSync()).toString(),
      package.manifest.sha256,
    );
    expect(File('${result.databasePath}.tmp').existsSync(), isFalse);
  });

  test('existing matching installation does not rewrite database', () async {
    final package = await _fixturePackage(
      tempDir,
      contentVersion: 'fixture-v1',
    );
    var loadCount = 0;
    final installer = QuranContentInstaller(
      manifest: package.manifest,
      assetLoader: (_) async {
        loadCount++;
        return package.bytes;
      },
      supportDirectory: () async => tempDir,
    );

    final first = await installer.ensureInstalled();
    final firstStat = File(first.databasePath).statSync();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final second = await installer.ensureInstalled();

    expect(second.databasePath, first.databasePath);
    expect(File(second.databasePath).statSync().modified, firstStat.modified);
    expect(loadCount, 1, reason: 'second open should trust matching sidecar');
  });

  test('interrupted replacement keeps previous verified database', () async {
    final v1 = await _fixturePackage(tempDir, contentVersion: 'fixture-v1');
    final installerV1 = QuranContentInstaller(
      manifest: v1.manifest,
      assetLoader: (_) async => v1.bytes,
      supportDirectory: () async => tempDir,
    );
    final installed = await installerV1.ensureInstalled();
    final original = File(installed.databasePath).readAsBytesSync();

    File(
      '${installed.databasePath}.tmp',
    ).writeAsBytesSync(utf8.encode('partial'));
    final v2 = await _fixturePackage(tempDir, contentVersion: 'fixture-v2');
    final installerV2 = QuranContentInstaller(
      manifest: v2.manifest,
      assetLoader: (_) async => throw const FileSystemException('interrupted'),
      supportDirectory: () async => tempDir,
    );

    await expectLater(
      installerV2.ensureInstalled(),
      throwsA(isA<FileSystemException>()),
    );

    expect(File(installed.databasePath).readAsBytesSync(), original);
    expect(File('${installed.databasePath}.tmp').existsSync(), isFalse);
  });

  test(
    'invalid replacement checksum keeps previous verified database',
    () async {
      final v1 = await _fixturePackage(tempDir, contentVersion: 'fixture-v1');
      final installerV1 = QuranContentInstaller(
        manifest: v1.manifest,
        assetLoader: (_) async => v1.bytes,
        supportDirectory: () async => tempDir,
      );
      final installed = await installerV1.ensureInstalled();
      final original = File(installed.databasePath).readAsBytesSync();

      final v2 = await _fixturePackage(tempDir, contentVersion: 'fixture-v2');
      final badManifest = QuranContentPackageManifest(
        contentVersion: 'fixture-v2',
        schemaVersion: 1,
        sha256: List.filled(64, '0').join(),
      );
      final installerV2 = QuranContentInstaller(
        manifest: badManifest,
        assetLoader: (_) async => v2.bytes,
        supportDirectory: () async => tempDir,
      );

      await expectLater(
        installerV2.ensureInstalled(),
        throwsA(isA<QuranContentVerificationException>()),
      );

      expect(File(installed.databasePath).readAsBytesSync(), original);
    },
  );

  test('replacement metadata version must match package manifest', () async {
    final v1 = await _fixturePackage(tempDir, contentVersion: 'fixture-v1');
    final installerV1 = QuranContentInstaller(
      manifest: v1.manifest,
      assetLoader: (_) async => v1.bytes,
      supportDirectory: () async => tempDir,
    );
    final installed = await installerV1.ensureInstalled();
    final original = File(installed.databasePath).readAsBytesSync();

    final mismatched = QuranContentPackageManifest(
      contentVersion: 'fixture-v2',
      schemaVersion: 1,
      sha256: v1.manifest.sha256,
    );
    final installerV2 = QuranContentInstaller(
      manifest: mismatched,
      assetLoader: (_) async => v1.bytes,
      supportDirectory: () async => tempDir,
    );

    await expectLater(
      installerV2.ensureInstalled(),
      throwsA(isA<QuranContentVerificationException>()),
    );

    expect(File(installed.databasePath).readAsBytesSync(), original);
  });
}

class _FixturePackage {
  const _FixturePackage(this.bytes, this.manifest);

  final List<int> bytes;
  final QuranContentPackageManifest manifest;
}

Future<_FixturePackage> _fixturePackage(
  Directory root, {
  required String contentVersion,
}) async {
  final file = File('${root.path}/source-$contentVersion.sqlite');
  final db = sqlite3.open(file.path);
  try {
    db.execute('PRAGMA user_version = 1');
    db.execute(
      'CREATE TABLE quran_metadata (metadata_key TEXT PRIMARY KEY, metadata_value TEXT NOT NULL)',
    );
    db.execute(
      'INSERT INTO quran_metadata(metadata_key, metadata_value) VALUES (?, ?)',
      ['content_version', contentVersion],
    );
  } finally {
    db.close();
  }

  final bytes = file.readAsBytesSync();
  return _FixturePackage(
    bytes,
    QuranContentPackageManifest(
      contentVersion: contentVersion,
      schemaVersion: 1,
      sha256: sha256.convert(bytes).toString(),
    ),
  );
}
