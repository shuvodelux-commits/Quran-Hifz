import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  const restoredHifzTables = <String>[
    'hifz_progress_entries',
    'hifz_review_history_rows',
    'hifz_session_checkpoints',
    'hifz_plans',
    'reading_page_visits',
    'daily_goals',
  ];

  test('fresh database creates the restored Hifz schema', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await db.getSetting('open-schema');

    for (final table in restoredHifzTables) {
      expect(
        await _tableExists(db, table),
        isTrue,
        reason: 'fresh database must contain $table',
      );
    }
  });

  test('v12 upgrade restores Hifz tables and preserves package data', () async {
    final temp = await Directory.systemTemp.createTemp('quran_hifz_v12_');
    final file = File('${temp.path}/user_data.sqlite');

    final seed = UserDatabase.forTesting(NativeDatabase(file));
    await seed.saveSetting('sentinel', 'keep-me');
    await seed
        .into(seed.installedTafsirPackages)
        .insert(
          InstalledTafsirPackagesCompanion.insert(
            sourceId: 'bn.zakaria',
            name: 'Tafsir Zakaria',
            language: 'bn',
            version: '1.1.1',
            localPath: '/tmp/tafsir.sqlite',
            sha256: List.filled(64, 'a').join(),
            installedAt: DateTime.utc(2026, 9, 27),
          ),
        );
    await seed
        .into(seed.installedTranslationPackages)
        .insert(
          InstalledTranslationPackagesCompanion.insert(
            sourceId: 'bn.sahih',
            resourceId: 77,
            name: 'Sahih International Bangla',
            language: 'bn',
            version: '1',
            localPath: '/tmp/translation.sqlite',
            recordCount: 6236,
            installedAt: DateTime.utc(2026, 9, 27),
          ),
        );
    await seed.close();

    final legacy = sqlite3.open(file.path);
    legacy.execute('PRAGMA user_version = 12;');
    legacy.close();

    final db = UserDatabase.forTesting(NativeDatabase(file));
    addTearDown(() async {
      await db.close();
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    expect(await db.getSetting('sentinel'), 'keep-me');
    expect(await db.select(db.installedTafsirPackages).get(), hasLength(1));
    expect(await db.select(db.installedTranslationPackages).get(), hasLength(1));

    for (final table in restoredHifzTables) {
      expect(
        await _tableExists(db, table),
        isTrue,
        reason: 'v12 upgrade must recreate $table',
      );
    }

    await db.customStatement(
      "INSERT INTO hifz_plans "
      "(profile_key, title, start_surah, start_ayah, end_surah, end_ayah, "
      "start_page, preset_id, created_at, updated_at) "
      "VALUES ('default', 'Al-Fatihah 1-3', 1, 1, 1, 3, 1, "
      "'new-memorization', 0, 0)",
    );
    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM hifz_plans')
        .getSingle();
    expect(count.read<int>('c'), 1);
  });

  test('v12 upgrade tolerates an already-present Hifz table', () async {
    final temp = await Directory.systemTemp.createTemp('quran_hifz_v12_dev_');
    final file = File('${temp.path}/user_data.sqlite');

    final seed = UserDatabase.forTesting(NativeDatabase(file));
    await seed.saveSetting('sentinel', 'keep-me');
    await seed.close();

    final legacy = sqlite3.open(file.path);
    legacy.execute('DROP TABLE IF EXISTS hifz_plans;');
    legacy.execute('''
      CREATE TABLE hifz_plans (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_key TEXT NOT NULL,
        title TEXT NOT NULL,
        start_surah INTEGER NOT NULL,
        start_ayah INTEGER NOT NULL,
        end_surah INTEGER NOT NULL,
        end_ayah INTEGER NOT NULL,
        start_page INTEGER NOT NULL,
        preset_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');
    legacy.execute('PRAGMA user_version = 12;');
    legacy.close();

    final db = UserDatabase.forTesting(NativeDatabase(file));
    addTearDown(() async {
      await db.close();
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    expect(await db.getSetting('sentinel'), 'keep-me');
    expect(await _tableExists(db, 'hifz_plans'), isTrue);
    expect(await _tableExists(db, 'hifz_progress_entries'), isTrue);
  });

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

  test('v10 cleanup still reaches the restored Hifz schema', () async {
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
      legacy.execute('DROP TABLE IF EXISTS ' + statement.split(' ')[2]);
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

    for (final table in restoredHifzTables) {
      expect(
        await _tableExists(db, table),
        isTrue,
        reason: 'current schema must restore $table',
      );
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

Future<bool> _tableExists(UserDatabase db, String table) async {
  final row = await db
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
        variables: [Variable.withString(table)],
      )
      .getSingleOrNull();
  return row != null;
}
