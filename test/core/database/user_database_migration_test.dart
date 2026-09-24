import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('v1 to current migration preserves reading progress', () async {
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
      if (await temp.exists()) {
        await temp.delete(recursive: true);
      }
    });

    final progress = await (db.select(
      db.readingProgress,
    )..where((row) => row.profileKey.equals('default'))).getSingle();

    expect(progress.lastSurah, 67);
    expect(progress.lastAyah, 5);
    expect(progress.lastPage, 562);

    // Opening a v1 DB through the current migration path must create newer
    // tables without deleting the sentinel progress row.
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            settingKey: 'theme',
            settingValue: 'system',
          ),
        );
    final setting = await (db.select(
      db.appSettings,
    )..where((row) => row.settingKey.equals('theme'))).getSingle();
    expect(setting.settingValue, 'system');

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
        .into(db.hifzProgressEntries)
        .insert(
          HifzProgressEntriesCompanion.insert(
            profileKey: 'default',
            surahNumber: 67,
            ayahNumber: 1,
            status: 'learning',
          ),
        );
    final hifz =
        await (db.select(db.hifzProgressEntries)..where(
              (row) =>
                  row.profileKey.equals('default') &
                  row.surahNumber.equals(67) &
                  row.ayahNumber.equals(1),
            ))
            .getSingle();
    expect(hifz.status, 'learning');
    expect(hifz.revisionIntervalIndex, -1);

    await db
        .into(db.hifzSessionCheckpoints)
        .insert(
          HifzSessionCheckpointsCompanion.insert(
            profileKey: 'default',
            startSurah: 67,
            startAyah: 1,
            endSurah: 67,
            endAyah: 3,
            presetId: 'new_memorization',
            status: 'stopped',
            updatedAt: DateTime.utc(2026, 9, 4),
          ),
        );
    final checkpoint = await (db.select(
      db.hifzSessionCheckpoints,
    )..where((row) => row.profileKey.equals('default'))).getSingle();
    expect(checkpoint.nextStepIndex, 0);
    expect(checkpoint.status, 'stopped');

    await db
        .into(db.hifzReviewHistoryRows)
        .insert(
          HifzReviewHistoryRowsCompanion.insert(
            profileKey: 'default',
            surahNumber: 67,
            ayahNumber: 1,
            reviewedAt: DateTime.utc(2026, 9, 4),
            result: 'perfect',
            previousStatus: 'learning',
            newStatus: 'memorized',
            previousIntervalIndex: 0,
            newIntervalIndex: 1,
            previousStrengthScore: 0,
            newStrengthScore: 60,
            nextReviewAt: DateTime.utc(2026, 9, 6),
          ),
        );
    expect(await db.select(db.hifzReviewHistoryRows).get(), hasLength(1));

    await db.recordReadingPageVisit(
      profileKey: 'default',
      pageNumber: 42,
      readAt: DateTime.utc(2026, 9, 4),
    );
    expect(await db.select(db.readingPageVisits).get(), hasLength(1));

    await db.saveDailyGoal(
      profileKey: 'default',
      day: DateTime.utc(2026, 9, 4),
      newHifzAyahsTarget: 5,
      revisionAyahsTarget: 20,
      readingPagesTarget: 2,
    );
    expect(await db.select(db.dailyGoals).get(), hasLength(1));

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

    await db
        .into(db.hifzPlans)
        .insert(
          HifzPlansCompanion.insert(
            profileKey: 'default',
            title: 'Al-Mulk 1–5',
            startSurah: 67,
            startAyah: 1,
            endSurah: 67,
            endAyah: 5,
            startPage: 562,
            presetId: 'new_memorization',
            createdAt: DateTime.utc(2026, 9, 17),
            updatedAt: DateTime.utc(2026, 9, 17),
          ),
        );
    expect(await db.select(db.hifzPlans).get(), hasLength(1));

    final customCreated = DateTime.utc(2026, 9, 24, 11);
    await db.into(db.customDuas).insert(
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

    for (final indexName in const [
      'hifz_progress_due_idx',
      'hifz_review_date_idx',
      'reading_page_visit_date_idx',
      'daily_goal_effective_idx',
    ]) {
      final index = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' AND name = ?",
            variables: [Variable.withString(indexName)],
          )
          .getSingleOrNull();
      expect(index, isNotNull, reason: 'missing migration index $indexName');
    }
  });


  test('v9 to current migration adds custom duas without losing settings', () async {
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
    await db.into(db.customDuas).insert(
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
  });
}
