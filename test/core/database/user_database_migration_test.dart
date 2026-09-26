import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('v1 to current migration preserves normal user data', () async {
    final temp = await Directory.systemTemp.createTemp('quran_hifz_migration_');
    final file = File('${temp.path}/user_data.sqlite');

    final legacy = sqlite3.open(file.path);
    legacy.execute('''
      CREATE TABLE reading_progress (
        profile_key TEXT NOT NULL PRIMARY KEY,
        last_surah INTEGER NOT NULL,
        last_ayah INTEGER NOT NULL,
        last_page INTEGER NOT NULL,
        last_read_at INTEGER
      );
    ''');
    legacy.execute(
      'INSERT INTO reading_progress '
      '(profile_key, last_surah, last_ayah, last_page) '
      "VALUES ('default', 67, 5, 562);",
    );
    legacy.execute('PRAGMA user_version = 1;');
    legacy.close();

    final db = UserDatabase.forTesting(NativeDatabase(file));
    addTearDown(() async {
      await db.close();
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    final progress = await (db.select(
      db.readingProgress,
    )..where((row) => row.profileKey.equals('default'))).getSingle();
    expect(progress.lastSurah, 67);
    expect(progress.lastAyah, 5);
    expect(progress.lastPage, 562);

    await db.saveSetting('theme', 'green');
    expect(await db.getSetting('theme'), 'green');

    await db.upsertDownloadJob(
      audioKey: 'chapter:7:1',
      audioType: 'chapter',
      remoteUrl: 'https://example.test/001.mp3',
      relativePath: 'reciters/7/001.mp3',
      status: 'queued',
      downloadedBytes: 0,
    );
    expect((await db.getDownloadJob('chapter:7:1'))?.status, 'queued');

    await db
        .into(db.studyBookmarks)
        .insert(
          StudyBookmarksCompanion.insert(
            profileKey: 'default',
            targetKey: 'ayah:67:1',
            targetType: 'ayah',
            surahNumber: 67,
            ayahNumber: 1,
            category: 'General',
            createdAt: DateTime.utc(2026, 9, 4),
          ),
        );
    await db
        .into(db.studyNotes)
        .insert(
          StudyNotesCompanion.insert(
            profileKey: 'default',
            targetKey: 'ayah:67:1',
            targetType: 'ayah',
            surahNumber: 67,
            ayahNumber: 1,
            noteText: 'migration-safe note',
            updatedAt: DateTime.utc(2026, 9, 4),
          ),
        );
    expect(await db.select(db.studyBookmarks).get(), hasLength(1));
    expect(await db.select(db.studyNotes).get(), hasLength(1));

    await db
        .into(db.installedTafsirPackages)
        .insert(
          InstalledTafsirPackagesCompanion.insert(
            sourceId: 'bn.test',
            name: 'Test Tafsir',
            language: 'bn',
            version: '1',
            localPath: '/tmp/test.sqlite',
            sha256: List.filled(64, 'a').join(),
            installedAt: DateTime.utc(2026, 9, 5),
          ),
        );
    expect(await db.select(db.installedTafsirPackages).get(), hasLength(1));

    final customCreated = DateTime.utc(2026, 9, 24, 11);
    await db
        .into(db.customDuas)
        .insert(
          CustomDuasCompanion.insert(
            id: 'custom:v1-migration',
            title: 'Migrated custom dua',
            arabic: 'رَبِّ زِدْنِي عِلْمًا',
            transliteration: 'Rabbi zidni ilma',
            meaning: 'Increase me in knowledge',
            reference: 'Migration test',
            createdAt: customCreated,
            updatedAt: customCreated,
          ),
        );
    expect(await db.select(db.customDuas).get(), hasLength(1));
  });

  test('v10 to v11 removes Hifz data without touching normal data', () async {
    final temp = await Directory.systemTemp.createTemp('quran_hifz_v10_');
    final file = File('${temp.path}/user_data.sqlite');

    final seed = UserDatabase.forTesting(NativeDatabase(file));
    await seed.saveSetting('sentinel', 'keep-me');
    await seed.saveReadingProgress(
      profileKey: 'default',
      lastSurah: 2,
      lastAyah: 255,
      lastPage: 42,
      readAt: DateTime.utc(2026, 9, 26),
    );
    await seed.close();

    final legacy = sqlite3.open(file.path);
    for (final statement in const [
      'CREATE TABLE hifz_progress_entries (id INTEGER)',
      'CREATE TABLE hifz_review_history_rows (id INTEGER)',
      'CREATE TABLE hifz_session_checkpoints (id INTEGER)',
      'CREATE TABLE hifz_plans (id INTEGER)',
      'CREATE TABLE reading_page_visits (id INTEGER)',
      'CREATE TABLE daily_goals (id INTEGER)',
    ]) {
      legacy.execute(statement);
    }
    legacy.execute(
      "INSERT OR REPLACE INTO app_settings(setting_key, setting_value) "
      "VALUES ('hifz_layout_mode', 'fixedMushaf');",
    );
    legacy.execute(
      "INSERT OR REPLACE INTO app_settings(setting_key, setting_value) "
      "VALUES ('hifz_font_size', '40');",
    );
    legacy.execute('PRAGMA user_version = 10;');
    legacy.close();

    final db = UserDatabase.forTesting(NativeDatabase(file));
    addTearDown(() async {
      await db.close();
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    expect(await db.getSetting('sentinel'), 'keep-me');
    expect(await db.getSetting('hifz_layout_mode'), isNull);
    expect(await db.getSetting('hifz_font_size'), isNull);

    final progress = await db.getReadingProgress('default');
    expect(progress, isNotNull);
    expect(progress!.lastSurah, 2);
    expect(progress.lastAyah, 255);
    expect(progress.lastPage, 42);

    for (final table in const [
      'hifz_progress_entries',
      'hifz_review_history_rows',
      'hifz_session_checkpoints',
      'hifz_plans',
      'reading_page_visits',
      'daily_goals',
    ]) {
      final row = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
            variables: [Variable.withString(table)],
          )
          .getSingleOrNull();
      expect(row, isNull, reason: 'legacy table should be removed: $table');
    }
  });

  test(
    'v9 to current migration adds custom duas without losing settings',
    () async {
      final temp = await Directory.systemTemp.createTemp('quran_hifz_v9_');
      final file = File('${temp.path}/user_data.sqlite');

      final legacy = sqlite3.open(file.path);
      legacy.execute('''
      CREATE TABLE app_settings (
        setting_key TEXT NOT NULL PRIMARY KEY,
        setting_value TEXT NOT NULL
      );
    ''');
      legacy.execute(
        "INSERT INTO app_settings(setting_key, setting_value) "
        "VALUES ('sentinel', 'keep-me');",
      );
      legacy.execute('PRAGMA user_version = 9;');
      legacy.close();

      final db = UserDatabase.forTesting(NativeDatabase(file));
      addTearDown(() async {
        await db.close();
        if (await temp.exists()) await temp.delete(recursive: true);
      });

      expect(await db.getSetting('sentinel'), 'keep-me');

      final created = DateTime.utc(2026, 9, 24, 12);
      await db
          .into(db.customDuas)
          .insert(
            CustomDuasCompanion.insert(
              id: 'custom:migration',
              title: 'Morning',
              arabic: 'رَبِّ زِدْنِي عِلْمًا',
              transliteration: 'Rabbi zidni ilma',
              meaning: 'Increase me in knowledge',
              reference: 'User reference',
              createdAt: created,
              updatedAt: created,
            ),
          );

      final row = await db.select(db.customDuas).getSingle();
      expect(row.id, 'custom:migration');
      expect(row.title, 'Morning');
    },
  );
}
