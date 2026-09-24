import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/tafsir/data/local_tafsir_repository.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test(
    'reads tafsir only from an installed package and returns its source metadata',
    () async {
      final temp = await Directory.systemTemp.createTemp(
        'quran_hifz_tafsir_read_',
      );
      final path = '${temp.path}/tafsir.sqlite';
      final package = sqlite3.open(path);
      package.execute('''
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
      INSERT INTO tafsir_metadata VALUES ('source_id', 'bn.test');
      INSERT INTO tafsir_metadata VALUES ('version', '1');
      INSERT INTO tafsir_metadata VALUES ('language', 'bn');
      INSERT INTO tafsir_entries VALUES (
        1,
        1,
        '<b>সূরার নাম</b><br>প্রথম &amp; দ্বিতীয়'
      );
      INSERT INTO tafsir_entries VALUES (1, 2, 'Second ayah tafsir');
    ''');
      package.close();

      final userDb = UserDatabase.forTesting(NativeDatabase.memory());
      await userDb.upsertInstalledTafsirPackage(
        sourceId: 'bn.test',
        name: 'Test Tafsir',
        language: 'bn',
        version: '1',
        localPath: path,
        sha256: List.filled(64, 'a').join(),
        attribution: 'Attribution',
        license: 'License',
      );
      final repository = LocalTafsirRepository(userDb);

      final entry = await repository.readAyah(
        sourceId: 'bn.test',
        surahNumber: 1,
        ayahNumber: 1,
      );

      expect(entry, isNotNull);
      expect(entry!.text, 'সূরার নাম\nপ্রথম & দ্বিতীয়');
      expect(entry.sourceName, 'Test Tafsir');
      expect(entry.attribution, 'Attribution');
      final surah = await repository.readSurah(
        sourceId: 'bn.test',
        surahNumber: 1,
      );
      expect(surah.map((entry) => entry.ayahNumber), [1, 2]);
      expect(surah.first.text, 'সূরার নাম\nপ্রথম & দ্বিতীয়');

      await userDb.close();
      await temp.delete(recursive: true);
    },
  );

  test(
    'reads every source ayah with translation and optional tafsir footnote',
    () async {
      final temp = await Directory.systemTemp.createTemp(
        'quran_hifz_complete_tafsir_read_',
      );
      addTearDown(() => temp.delete(recursive: true));
      final path = '${temp.path}/tafsir.sqlite';
      final package = sqlite3.open(path);
      package.execute('''
      CREATE TABLE tafsir_entries (
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        text TEXT NOT NULL,
        PRIMARY KEY (surah_number, ayah_number)
      );
      CREATE TABLE source_entries (
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        translation TEXT NOT NULL,
        footnotes TEXT NOT NULL,
        PRIMARY KEY (surah_number, ayah_number)
      );
      INSERT INTO source_entries VALUES (1, 1, 'অনুবাদ ১', 'তাফসীর ১');
      INSERT INTO source_entries VALUES (1, 2, 'অনুবাদ ২', '');
      INSERT INTO tafsir_entries VALUES (1, 1, 'তাফসীর ১');
    ''');
      package.close();

      final userDb = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(userDb.close);
      await userDb.upsertInstalledTafsirPackage(
        sourceId: 'bn.complete',
        name: 'Complete Tafsir',
        language: 'bn',
        version: '1',
        localPath: path,
        sha256: List.filled(64, 'b').join(),
      );
      final repository = LocalTafsirRepository(userDb);

      final withFootnote = await repository.readAyah(
        sourceId: 'bn.complete',
        surahNumber: 1,
        ayahNumber: 1,
      );
      final translationOnly = await repository.readAyah(
        sourceId: 'bn.complete',
        surahNumber: 1,
        ayahNumber: 2,
      );
      final surah = await repository.readSurah(
        sourceId: 'bn.complete',
        surahNumber: 1,
      );

      expect(withFootnote?.text, 'অনুবাদ ১\n\nতাফসীর ১');
      expect(translationOnly?.text, 'অনুবাদ ২');
      expect(surah.map((entry) => entry.ayahNumber), [1, 2]);
      expect(surah.map((entry) => entry.text), [
        'অনুবাদ ১\n\nতাফসীর ১',
        'অনুবাদ ২',
      ]);
    },
  );
}
