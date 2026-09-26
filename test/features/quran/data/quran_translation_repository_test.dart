import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/quran_content_database.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/quran/data/bundled_quran_translation_repository.dart';
import 'package:quran_hifz/features/quran/data/composite_quran_translation_repository.dart';
import 'package:quran_hifz/features/quran/data/local_quran_translation_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_translation_source.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('bundled repository exposes Zakaria and reads canonical translation', () async {
    final contentDb = QuranContentDatabase.forTesting(NativeDatabase.memory());
    addTearDown(contentDb.close);
    await contentDb.into(contentDb.translations).insert(
      TranslationsCompanion.insert(
        resourceId: 1,
        surahNumber: 1,
        ayahNumber: 1,
        language: 'bn',
        textValue: 'বাংলা অনুবাদ',
      ),
    );

    final repository = BundledQuranTranslationRepository(contentDb);
    final sources = await repository.listInstalledSources();
    expect(sources.single.sourceId, bundledPrimaryTranslationSourceId);
    expect(sources.single.kind, QuranTranslationSourceKind.bundled);

    final entry = await repository.readAyah(
      sourceId: bundledPrimaryTranslationSourceId,
      surahNumber: 1,
      ayahNumber: 1,
    );
    expect(entry?.text, 'বাংলা অনুবাদ');
    expect(entry?.language, 'bn');
  });

  test('local repository reads a downloaded translation package', () async {
    final temp = await Directory.systemTemp.createTemp('local_translation_');
    addTearDown(() => temp.delete(recursive: true));
    final packagePath = '${temp.path}/sahih.sqlite';
    final sqlite = sqlite3.open(packagePath);
    sqlite.execute('''
      CREATE TABLE translation_entries (
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        text TEXT NOT NULL,
        PRIMARY KEY (surah_number, ayah_number)
      )
    ''');
    sqlite.execute(
      'INSERT INTO translation_entries VALUES (1, 1, ?)',
      ['In the Name of Allah'],
    );
    sqlite.close();

    final userDb = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(userDb.close);
    await userDb.upsertInstalledTranslationPackage(
      sourceId: 'qf.translation.20',
      resourceId: 20,
      name: 'Sahih International',
      language: 'english',
      version: 'quran-foundation-v4',
      localPath: packagePath,
      author: 'Saheeh International',
      recordCount: 1,
    );

    final repository = LocalQuranTranslationRepository(userDb);
    final sources = await repository.listInstalledSources();
    expect(sources.single.sourceId, 'qf.translation.20');
    expect(sources.single.kind, QuranTranslationSourceKind.downloaded);

    final entry = await repository.readAyah(
      sourceId: 'qf.translation.20',
      surahNumber: 1,
      ayahNumber: 1,
    );
    expect(entry?.text, 'In the Name of Allah');
    expect(entry?.sourceName, 'Sahih International');
  });

  test('composite preserves requested source order when reading multiple', () async {
    final contentDb = QuranContentDatabase.forTesting(NativeDatabase.memory());
    addTearDown(contentDb.close);
    await contentDb.into(contentDb.translations).insert(
      TranslationsCompanion.insert(
        resourceId: 1,
        surahNumber: 1,
        ayahNumber: 1,
        language: 'bn',
        textValue: 'বাংলা',
      ),
    );

    final temp = await Directory.systemTemp.createTemp('multi_translation_');
    addTearDown(() => temp.delete(recursive: true));
    final packagePath = '${temp.path}/english.sqlite';
    final sqlite = sqlite3.open(packagePath);
    sqlite.execute('''
      CREATE TABLE translation_entries (
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        text TEXT NOT NULL,
        PRIMARY KEY (surah_number, ayah_number)
      )
    ''');
    sqlite.execute(
      'INSERT INTO translation_entries VALUES (1, 1, ?)',
      ['English'],
    );
    sqlite.close();

    final userDb = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(userDb.close);
    await userDb.upsertInstalledTranslationPackage(
      sourceId: 'qf.translation.20',
      resourceId: 20,
      name: 'Sahih International',
      language: 'english',
      version: 'quran-foundation-v4',
      localPath: packagePath,
      recordCount: 1,
    );

    final repository = CompositeQuranTranslationRepository(
      bundled: BundledQuranTranslationRepository(contentDb),
      downloaded: LocalQuranTranslationRepository(userDb),
    );

    final entries = await repository.readAyahTranslations(
      sourceIds: const [
        'qf.translation.20',
        bundledPrimaryTranslationSourceId,
      ],
      surahNumber: 1,
      ayahNumber: 1,
    );

    expect(entries.map((entry) => entry.text), ['English', 'বাংলা']);
  });
}
