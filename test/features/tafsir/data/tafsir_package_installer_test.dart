import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/core/storage/storage_capacity.dart';
import 'package:quran_hifz/features/tafsir/data/tafsir_package_installer.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_package_manifest.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory temp;
  late UserDatabase userDatabase;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('quran_hifz_tafsir_');
    userDatabase = UserDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await userDatabase.close();
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  TafsirPackageInstaller _installer(Uint8List bytes, {required int freeBytes}) {
    return TafsirPackageInstaller(
      database: userDatabase,
      rootDirectory: () async => temp,
      transport: _MemoryTransport(bytes),
      storageCapacity: _FixedStorageCapacity(freeBytes),
      canonicalAyahBounds: () async => const {1: 7, 2: 286},
    );
  }

  test(
    'valid package is verified before atomic install and registry write',
    () async {
      final bytes = await _buildPackage(
        temp,
        sourceId: 'bn.test',
        version: '1',
        entries: const [(2, 255, 'Test tafsir text')],
      );
      final manifest = _manifest(bytes, sourceId: 'bn.test', version: '1');
      final installer = _installer(bytes, freeBytes: bytes.length * 2);

      final installed = await installer.install(manifest);

      expect(await File(installed.localPath).exists(), isTrue);
      expect(installed.sourceId, 'bn.test');
      final registry = await userDatabase.getInstalledTafsirPackage('bn.test');
      expect(registry, isNotNull);
      expect(registry!.sha256, manifest.sha256);
    },
  );

  test('checksum mismatch leaves no installed package', () async {
    final bytes = await _buildPackage(
      temp,
      sourceId: 'bn.test',
      version: '1',
      entries: const [(2, 255, 'Test tafsir text')],
    );
    final manifest = _manifest(
      bytes,
      sha256Override: List.filled(64, '0').join(),
    );
    final installer = _installer(bytes, freeBytes: bytes.length * 2);

    await expectLater(
      installer.install(manifest),
      throwsA(isA<TafsirPackageValidationException>()),
    );
    expect(await userDatabase.getInstalledTafsirPackage('bn.test'), isNull);
  });

  test('package metadata must match manifest identity', () async {
    final bytes = await _buildPackage(
      temp,
      sourceId: 'bn.other',
      version: '1',
      entries: const [(2, 255, 'Test tafsir text')],
    );
    final manifest = _manifest(bytes, sourceId: 'bn.test', version: '1');
    final installer = _installer(bytes, freeBytes: bytes.length * 2);

    await expectLater(
      installer.install(manifest),
      throwsA(isA<TafsirPackageValidationException>()),
    );
  });

  test('package verse keys must exist within canonical Surah bounds', () async {
    final bytes = await _buildPackage(
      temp,
      sourceId: 'bn.test',
      version: '1',
      entries: const [(2, 999, 'Invalid ayah')],
    );
    final manifest = _manifest(bytes);
    final installer = _installer(bytes, freeBytes: bytes.length * 2);

    await expectLater(
      installer.install(manifest),
      throwsA(isA<TafsirPackageValidationException>()),
    );
  });

  test(
    'insufficient storage is rejected before writing package bytes',
    () async {
      final bytes = await _buildPackage(
        temp,
        sourceId: 'bn.test',
        version: '1',
        entries: const [(2, 255, 'Test tafsir text')],
      );
      final manifest = _manifest(bytes);
      final installer = _installer(bytes, freeBytes: bytes.length - 1);

      await expectLater(
        installer.install(manifest),
        throwsA(isA<TafsirPackageStorageException>()),
      );
    },
  );

  test(
    'stream failure removes partial file and leaves registry untouched',
    () async {
      final bytes = await _buildPackage(
        temp,
        sourceId: 'bn.test',
        version: '1',
        entries: const [(2, 255, 'Test tafsir text')],
      );
      final manifest = _manifest(bytes);
      final installer = TafsirPackageInstaller(
        database: userDatabase,
        rootDirectory: () async => temp,
        transport: _FailingTransport(),
        storageCapacity: _FixedStorageCapacity(bytes.length * 2),
        canonicalAyahBounds: () async => const {1: 7, 2: 286},
      );

      await expectLater(installer.install(manifest), throwsA(anything));

      expect(await userDatabase.getInstalledTafsirPackage('bn.test'), isNull);
      final partials = temp
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.part'));
      expect(partials, isEmpty);
    },
  );
}

TafsirPackageManifest _manifest(
  Uint8List bytes, {
  String sourceId = 'bn.test',
  String version = '1',
  String? sha256Override,
}) {
  return TafsirPackageManifest(
    sourceId: sourceId,
    name: 'Test Tafsir',
    language: 'bn',
    version: version,
    downloadUrl: Uri.parse('https://example.test/tafsir.sqlite'),
    sha256: sha256Override ?? sha256.convert(bytes).toString(),
    sizeBytes: bytes.length,
    attribution: 'Test attribution',
    license: 'Test license',
  );
}

Future<Uint8List> _buildPackage(
  Directory temp, {
  required String sourceId,
  required String version,
  required List<(int, int, String)> entries,
}) async {
  final path =
      '${temp.path}/fixture-${DateTime.now().microsecondsSinceEpoch}.sqlite';
  final db = sqlite3.open(path);
  db.execute('''
    CREATE TABLE tafsir_metadata (
      metadata_key TEXT PRIMARY KEY,
      metadata_value TEXT NOT NULL
    );
    CREATE TABLE tafsir_entries (
      surah_number INTEGER NOT NULL,
      ayah_number INTEGER NOT NULL,
      text TEXT NOT NULL,
      PRIMARY KEY (surah_number, ayah_number)
    );
  ''');
  db.execute('INSERT INTO tafsir_metadata VALUES (?, ?)', [
    'source_id',
    sourceId,
  ]);
  db.execute('INSERT INTO tafsir_metadata VALUES (?, ?)', ['version', version]);
  db.execute('INSERT INTO tafsir_metadata VALUES (?, ?)', ['language', 'bn']);
  for (final (surah, ayah, text) in entries) {
    db.execute('INSERT INTO tafsir_entries VALUES (?, ?, ?)', [
      surah,
      ayah,
      text,
    ]);
  }
  db.close();
  final bytes = await File(path).readAsBytes();
  await File(path).delete();
  return bytes;
}

class _MemoryTransport implements TafsirPackageTransport {
  _MemoryTransport(this.bytes);

  final Uint8List bytes;

  @override
  Future<TafsirTransportResponse> open(Uri uri) async {
    return TafsirTransportResponse(
      statusCode: HttpStatus.ok,
      contentLength: bytes.length,
      bytes: Stream.value(bytes),
    );
  }

  @override
  void close() {}
}

class _FixedStorageCapacity implements StorageCapacity {
  _FixedStorageCapacity(this.bytes);

  final int bytes;

  @override
  Future<int?> freeBytesFor(String path) async => bytes;
}

class _FailingTransport implements TafsirPackageTransport {
  @override
  Future<TafsirTransportResponse> open(Uri uri) async {
    return TafsirTransportResponse(
      statusCode: HttpStatus.ok,
      contentLength: null,
      bytes: Stream<List<int>>.error(FileSystemException('network failed')),
    );
  }

  @override
  void close() {}
}
