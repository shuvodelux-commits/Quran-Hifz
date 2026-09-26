import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/core/network/quran_backend_client.dart';
import 'package:quran_hifz/features/quran/data/quran_foundation_translation_installer.dart';
import 'package:quran_hifz/features/quran/domain/quran_translation_source.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('installs a complete Quran Foundation translation snapshot offline', () async {
    final temp = await Directory.systemTemp.createTemp('translation_install_');
    addTearDown(() => temp.delete(recursive: true));
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final client = _FakeContentClient(
      snapshot: {
        'resource_group': 'translations',
        'resource_id': 20,
        'records': [
          {
            'resource_id': 20,
            'verse_key': '1:1',
            'text': '<p>In the Name of Allah</p>',
            'language_name': 'english',
          },
          {
            'resource_id': 20,
            'verse_key': '1:2',
            'text': 'All praise is for Allah',
            'language_name': 'english',
          },
        ],
      },
    );
    final installer = QuranFoundationTranslationInstaller(
      database: database,
      client: client,
      rootDirectory: () async => temp,
      canonicalAyahBounds: () async => {1: 2},
    );
    const source = QuranTranslationSource(
      sourceId: 'qf.translation.20',
      resourceId: 20,
      name: 'Sahih International',
      language: 'english',
      version: 'quran-foundation-v4',
      author: 'Saheeh International',
      kind: QuranTranslationSourceKind.remote,
      availableOffline: false,
    );

    final installed = await installer.install(source);

    expect(installed.kind, QuranTranslationSourceKind.downloaded);
    expect(installed.availableOffline, isTrue);
    expect(installed.localPath, isNotNull);
    final registry = await database.getInstalledTranslationPackage(
      source.sourceId,
    );
    expect(registry?.recordCount, 2);

    final sqlite = sqlite3.open(installed.localPath!, mode: OpenMode.readOnly);
    addTearDown(sqlite.close);
    final rows = sqlite.select(
      'SELECT surah_number, ayah_number, text FROM translation_entries '
      'ORDER BY surah_number, ayah_number',
    );
    expect(rows, hasLength(2));
    expect(rows.first['text'], 'In the Name of Allah');
    expect(rows.last['text'], 'All praise is for Allah');
  });

  test('rejects an incomplete translation snapshot', () async {
    final temp = await Directory.systemTemp.createTemp('translation_invalid_');
    addTearDown(() => temp.delete(recursive: true));
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final installer = QuranFoundationTranslationInstaller(
      database: database,
      client: _FakeContentClient(
        snapshot: {
          'resource_group': 'translations',
          'resource_id': 20,
          'records': [
            {
              'resource_id': 20,
              'verse_key': '1:1',
              'text': 'Only one ayah',
            },
          ],
        },
      ),
      rootDirectory: () async => temp,
      canonicalAyahBounds: () async => {1: 2},
    );

    await expectLater(
      installer.install(
        const QuranTranslationSource(
          sourceId: 'qf.translation.20',
          resourceId: 20,
          name: 'Sahih International',
          language: 'english',
          version: 'quran-foundation-v4',
          kind: QuranTranslationSourceKind.remote,
          availableOffline: false,
        ),
      ),
      throwsA(isA<QuranTranslationPackageValidationException>()),
    );
    expect(
      await database.getInstalledTranslationPackage('qf.translation.20'),
      isNull,
    );
  });
}

class _FakeContentClient implements QuranContentResourceBackendClient {
  _FakeContentClient({required this.snapshot});

  final Map<String, dynamic> snapshot;

  @override
  Future<Map<String, dynamic>> getContentSnapshot({
    required String group,
    required int resourceId,
  }) async => snapshot;

  @override
  Future<List<Map<String, dynamic>>> getTranslationResources({
    String language = 'en',
  }) async => const [];
}
