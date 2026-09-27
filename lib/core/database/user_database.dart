import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../time/calendar_day.dart';

part 'user_database.g.dart';

@DataClassName('AudioFileRecord')
class AudioFiles extends Table {
  TextColumn get audioKey => text()();
  TextColumn get audioType => text()();
  IntColumn get reciterId => integer().nullable()();
  IntColumn get surahNumber => integer().nullable()();
  IntColumn get ayahNumber => integer().nullable()();
  IntColumn get wordPosition => integer().nullable()();
  TextColumn get remoteUrl => text()();
  TextColumn get localPath => text().nullable()();
  TextColumn get format => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('remote'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {audioKey};
}

@DataClassName('AyahTimingRecord')
class AyahTimings extends Table {
  IntColumn get reciterId => integer()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get verseKey => text()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {reciterId, surahNumber, ayahNumber};
}

@DataClassName('WordTimingRecord')
class WordTimings extends Table {
  IntColumn get reciterId => integer()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  IntColumn get wordPosition => integer()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {
    reciterId,
    surahNumber,
    ayahNumber,
    wordPosition,
  };
}

@DataClassName('DownloadJobRecord')
class DownloadJobs extends Table {
  TextColumn get audioKey => text()();
  TextColumn get audioType => text()();
  TextColumn get remoteUrl => text()();
  TextColumn get relativePath => text()();
  TextColumn get status => text()();
  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();
  IntColumn get expectedBytes => integer().nullable()();
  IntColumn get reciterId => integer().nullable()();
  IntColumn get surahNumber => integer().nullable()();
  IntColumn get ayahNumber => integer().nullable()();
  IntColumn get wordPosition => integer().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get errorCode => text().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {audioKey};
}

@TableIndex(
  name: 'hifz_progress_due_idx',
  columns: {#profileKey, #nextReviewAt},
)
@DataClassName('HifzProgressRow')
class HifzProgressEntries extends Table {
  TextColumn get profileKey => text()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get status => text()();
  IntColumn get strengthScore => integer().withDefault(const Constant(0))();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  IntColumn get mistakeCount => integer().withDefault(const Constant(0))();
  IntColumn get revisionIntervalIndex =>
      integer().withDefault(const Constant(-1))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get memorizedAt => dateTime().nullable()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get nextReviewAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {profileKey, surahNumber, ayahNumber};
}

@TableIndex(name: 'hifz_review_date_idx', columns: {#profileKey, #reviewedAt})
@DataClassName('HifzReviewHistoryRow')
class HifzReviewHistoryRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileKey => text()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  DateTimeColumn get reviewedAt => dateTime()();
  TextColumn get result => text()();
  TextColumn get previousStatus => text()();
  TextColumn get newStatus => text()();
  IntColumn get previousIntervalIndex => integer()();
  IntColumn get newIntervalIndex => integer()();
  IntColumn get previousStrengthScore => integer()();
  IntColumn get newStrengthScore => integer()();
  DateTimeColumn get nextReviewAt => dateTime()();
}

@DataClassName('HifzSessionCheckpointRow')
class HifzSessionCheckpoints extends Table {
  TextColumn get profileKey => text()();
  IntColumn get startSurah => integer()();
  IntColumn get startAyah => integer()();
  IntColumn get endSurah => integer()();
  IntColumn get endAyah => integer()();
  TextColumn get presetId => text()();
  IntColumn get nextStepIndex => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {profileKey};
}

@TableIndex(name: 'hifz_plans_profile_idx', columns: {#profileKey, #updatedAt})
@DataClassName('HifzPlanRow')
class HifzPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileKey => text()();
  TextColumn get title => text()();
  IntColumn get startSurah => integer()();
  IntColumn get startAyah => integer()();
  IntColumn get endSurah => integer()();
  IntColumn get endAyah => integer()();
  IntColumn get startPage => integer()();
  TextColumn get presetId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('SyncStateRecord')
class SyncStates extends Table {
  TextColumn get syncKey => text()();
  TextColumn get syncToken => text().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {syncKey};
}

@TableIndex(
  name: 'reading_page_visit_date_idx',
  columns: {#profileKey, #readAt},
)
@DataClassName('ReadingPageVisitRow')
class ReadingPageVisits extends Table {
  TextColumn get profileKey => text()();
  TextColumn get dayKey => text()();
  IntColumn get pageNumber => integer()();
  DateTimeColumn get readAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {profileKey, dayKey, pageNumber};
}

@TableIndex(name: 'daily_goal_effective_idx', columns: {#profileKey, #dayKey})
@DataClassName('DailyGoalRow')
class DailyGoals extends Table {
  TextColumn get profileKey => text()();
  TextColumn get dayKey => text()();
  IntColumn get newHifzAyahsTarget =>
      integer().withDefault(const Constant(0))();
  IntColumn get revisionAyahsTarget =>
      integer().withDefault(const Constant(0))();
  IntColumn get readingPagesTarget =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {profileKey, dayKey};
}

@DataClassName('StudyBookmarkRow')
class StudyBookmarks extends Table {
  TextColumn get profileKey => text()();
  TextColumn get targetKey => text()();
  TextColumn get targetType => text()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  IntColumn get wordPosition => integer().nullable()();
  TextColumn get category => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {profileKey, targetKey};
}

@DataClassName('StudyNoteRow')
class StudyNotes extends Table {
  TextColumn get profileKey => text()();
  TextColumn get targetKey => text()();
  TextColumn get targetType => text()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  IntColumn get wordPosition => integer().nullable()();
  TextColumn get noteText => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {profileKey, targetKey};
}

@DataClassName('InstalledTafsirPackageRecord')
class InstalledTafsirPackages extends Table {
  TextColumn get sourceId => text()();
  TextColumn get name => text()();
  TextColumn get language => text()();
  TextColumn get version => text()();
  TextColumn get localPath => text()();
  TextColumn get sha256 => text()();
  TextColumn get attribution => text().nullable()();
  TextColumn get license => text().nullable()();
  DateTimeColumn get installedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {sourceId};
}

@DataClassName('InstalledTranslationPackageRecord')
class InstalledTranslationPackages extends Table {
  TextColumn get sourceId => text()();
  IntColumn get resourceId => integer()();
  TextColumn get name => text()();
  TextColumn get language => text()();
  TextColumn get version => text()();
  TextColumn get localPath => text()();
  TextColumn get author => text().nullable()();
  IntColumn get recordCount => integer()();
  DateTimeColumn get installedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {sourceId};
}

@DataClassName('ReadingProgressRecord')
class ReadingProgress extends Table {
  TextColumn get profileKey => text()();
  IntColumn get lastSurah => integer()();
  IntColumn get lastAyah => integer()();
  IntColumn get lastPage => integer()();
  DateTimeColumn get lastReadAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {profileKey};
}

@DataClassName('AppSettingRecord')
class AppSettings extends Table {
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();

  @override
  Set<Column<Object>> get primaryKey => {settingKey};
}

@DataClassName('CustomDuaRow')
class CustomDuas extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get arabic => text()();
  TextColumn get transliteration => text()();
  TextColumn get meaning => text()();
  TextColumn get reference => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    AudioFiles,
    AyahTimings,
    WordTimings,
    DownloadJobs,
    HifzProgressEntries,
    HifzReviewHistoryRows,
    HifzSessionCheckpoints,
    HifzPlans,
    SyncStates,
    ReadingPageVisits,
    DailyGoals,
    StudyBookmarks,
    StudyNotes,
    InstalledTafsirPackages,
    InstalledTranslationPackages,
    ReadingProgress,
    AppSettings,
    CustomDuas,
  ],
)
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.executor);

  UserDatabase.defaults()
    : super(
        driftDatabase(
          name: 'user_data',
          native: DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  UserDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(appSettings);
      }
      if (from < 3) {
        await migrator.createTable(downloadJobs);
      }
      if (from < 7) {
        await migrator.createTable(studyBookmarks);
        await migrator.createTable(studyNotes);
      }
      if (from < 8) {
        await migrator.createTable(installedTafsirPackages);
      }
      if (from < 10) {
        await migrator.createTable(customDuas);
      }
      if (from < 11) {
        for (final table in const [
          'hifz_progress_entries',
          'hifz_review_history_rows',
          'hifz_session_checkpoints',
          'hifz_plans',
          'reading_page_visits',
          'daily_goals',
        ]) {
          await customStatement('DROP TABLE IF EXISTS $table');
        }
        await customStatement(
          "DELETE FROM app_settings WHERE setting_key LIKE 'hifz_%'",
        );
      }
      if (from < 12) {
        await migrator.createTable(installedTranslationPackages);
      }
      if (from < 13) {
        await _restoreHifzSchema();
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  Future<void> _restoreHifzSchema() async {
    for (final statement in const <String>[
      '''CREATE TABLE IF NOT EXISTS hifz_progress_entries (
        profile_key TEXT NOT NULL, surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL, status TEXT NOT NULL,
        strength_score INTEGER NOT NULL DEFAULT 0,
        review_count INTEGER NOT NULL DEFAULT 0,
        mistake_count INTEGER NOT NULL DEFAULT 0,
        revision_interval_index INTEGER NOT NULL DEFAULT -1,
        started_at INTEGER, memorized_at INTEGER, last_reviewed_at INTEGER,
        next_review_at INTEGER,
        PRIMARY KEY (profile_key, surah_number, ayah_number)
      )''',
      '''CREATE TABLE IF NOT EXISTS hifz_review_history_rows (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_key TEXT NOT NULL, surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL, reviewed_at INTEGER NOT NULL,
        result TEXT NOT NULL, previous_status TEXT NOT NULL,
        new_status TEXT NOT NULL, previous_interval_index INTEGER NOT NULL,
        new_interval_index INTEGER NOT NULL,
        previous_strength_score INTEGER NOT NULL,
        new_strength_score INTEGER NOT NULL, next_review_at INTEGER NOT NULL
      )''',
      '''CREATE TABLE IF NOT EXISTS hifz_session_checkpoints (
        profile_key TEXT NOT NULL PRIMARY KEY,
        start_surah INTEGER NOT NULL, start_ayah INTEGER NOT NULL,
        end_surah INTEGER NOT NULL, end_ayah INTEGER NOT NULL,
        preset_id TEXT NOT NULL, next_step_index INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL, updated_at INTEGER NOT NULL
      )''',
      '''CREATE TABLE IF NOT EXISTS hifz_plans (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_key TEXT NOT NULL, title TEXT NOT NULL,
        start_surah INTEGER NOT NULL, start_ayah INTEGER NOT NULL,
        end_surah INTEGER NOT NULL, end_ayah INTEGER NOT NULL,
        start_page INTEGER NOT NULL, preset_id TEXT NOT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL
      )''',
      '''CREATE TABLE IF NOT EXISTS reading_page_visits (
        profile_key TEXT NOT NULL, day_key TEXT NOT NULL,
        page_number INTEGER NOT NULL, read_at INTEGER NOT NULL,
        PRIMARY KEY (profile_key, day_key, page_number)
      )''',
      '''CREATE TABLE IF NOT EXISTS daily_goals (
        profile_key TEXT NOT NULL, day_key TEXT NOT NULL,
        new_hifz_ayahs_target INTEGER NOT NULL DEFAULT 0,
        revision_ayahs_target INTEGER NOT NULL DEFAULT 0,
        reading_pages_target INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (profile_key, day_key)
      )''',
      'CREATE INDEX IF NOT EXISTS hifz_progress_due_idx ON hifz_progress_entries(profile_key, next_review_at)',
      'CREATE INDEX IF NOT EXISTS hifz_review_date_idx ON hifz_review_history_rows(profile_key, reviewed_at)',
      'CREATE INDEX IF NOT EXISTS hifz_plans_profile_idx ON hifz_plans(profile_key, updated_at)',
      'CREATE INDEX IF NOT EXISTS reading_page_visit_date_idx ON reading_page_visits(profile_key, read_at)',
      'CREATE INDEX IF NOT EXISTS daily_goal_effective_idx ON daily_goals(profile_key, day_key)',
    ]) {
      await customStatement(statement);
    }
  }

  Future<InstalledTafsirPackageRecord?> getInstalledTafsirPackage(
    String sourceId,
  ) {
    return (select(
      installedTafsirPackages,
    )..where((row) => row.sourceId.equals(sourceId))).getSingleOrNull();
  }

  Future<List<InstalledTafsirPackageRecord>> listInstalledTafsirPackages() {
    return (select(
      installedTafsirPackages,
    )..orderBy([(row) => OrderingTerm.asc(row.name)])).get();
  }

  Future<void> upsertInstalledTafsirPackage({
    required String sourceId,
    required String name,
    required String language,
    required String version,
    required String localPath,
    required String sha256,
    String? attribution,
    String? license,
    DateTime? installedAt,
  }) async {
    await into(installedTafsirPackages).insertOnConflictUpdate(
      InstalledTafsirPackagesCompanion.insert(
        sourceId: sourceId,
        name: name,
        language: language,
        version: version,
        localPath: localPath,
        sha256: sha256,
        attribution: Value(attribution),
        license: Value(license),
        installedAt: installedAt ?? DateTime.now(),
      ),
    );
  }

  Future<void> deleteInstalledTafsirPackage(String sourceId) {
    return (delete(
      installedTafsirPackages,
    )..where((row) => row.sourceId.equals(sourceId))).go();
  }

  Future<InstalledTranslationPackageRecord?> getInstalledTranslationPackage(
    String sourceId,
  ) {
    return (select(
      installedTranslationPackages,
    )..where((row) => row.sourceId.equals(sourceId))).getSingleOrNull();
  }

  Future<List<InstalledTranslationPackageRecord>>
  listInstalledTranslationPackages() {
    return (select(
      installedTranslationPackages,
    )..orderBy([(row) => OrderingTerm.asc(row.name)])).get();
  }

  Future<void> upsertInstalledTranslationPackage({
    required String sourceId,
    required int resourceId,
    required String name,
    required String language,
    required String version,
    required String localPath,
    required int recordCount,
    String? author,
    DateTime? installedAt,
  }) async {
    await into(installedTranslationPackages).insertOnConflictUpdate(
      InstalledTranslationPackagesCompanion.insert(
        sourceId: sourceId,
        resourceId: resourceId,
        name: name,
        language: language,
        version: version,
        localPath: localPath,
        author: Value(author),
        recordCount: recordCount,
        installedAt: installedAt ?? DateTime.now(),
      ),
    );
  }

  Future<void> deleteInstalledTranslationPackage(String sourceId) {
    return (delete(
      installedTranslationPackages,
    )..where((row) => row.sourceId.equals(sourceId))).go();
  }

  Future<ReadingProgressRecord?> getReadingProgress(String profileKey) {
    return (select(
      readingProgress,
    )..where((row) => row.profileKey.equals(profileKey))).getSingleOrNull();
  }

  Future<void> saveReadingProgress({
    required String profileKey,
    required int lastSurah,
    required int lastAyah,
    required int lastPage,
    DateTime? readAt,
  }) async {
    final timestamp = readAt ?? DateTime.now();
    await transaction(() async {
      await into(readingProgress).insertOnConflictUpdate(
        ReadingProgressCompanion.insert(
          profileKey: profileKey,
          lastSurah: lastSurah,
          lastAyah: lastAyah,
          lastPage: lastPage,
          lastReadAt: Value(timestamp),
        ),
      );
      await recordReadingPageVisit(
        profileKey: profileKey,
        pageNumber: lastPage,
        readAt: timestamp,
      );
    });
  }

  Future<void> recordReadingPageVisit({
    required String profileKey,
    required int pageNumber,
    required DateTime readAt,
  }) async {
    await into(readingPageVisits).insertOnConflictUpdate(
      ReadingPageVisitsCompanion.insert(
        profileKey: profileKey,
        dayKey: calendarDayKey(readAt),
        pageNumber: pageNumber,
        readAt: readAt,
      ),
    );
  }

  Future<void> saveDailyGoal({
    required String profileKey,
    required DateTime day,
    required int newHifzAyahsTarget,
    required int revisionAyahsTarget,
    required int readingPagesTarget,
  }) async {
    if (newHifzAyahsTarget < 0 ||
        revisionAyahsTarget < 0 ||
        readingPagesTarget < 0) {
      throw ArgumentError('Daily Quran goals must not be negative.');
    }

    await into(dailyGoals).insertOnConflictUpdate(
      DailyGoalsCompanion.insert(
        profileKey: profileKey,
        dayKey: calendarDayKey(day),
        newHifzAyahsTarget: Value(newHifzAyahsTarget),
        revisionAyahsTarget: Value(revisionAyahsTarget),
        readingPagesTarget: Value(readingPagesTarget),
      ),
    );
  }

  Future<String?> getSetting(String settingKey) async {
    final row =
        await (select(appSettings)
              ..where((setting) => setting.settingKey.equals(settingKey)))
            .getSingleOrNull();
    return row?.settingValue;
  }

  Future<void> saveSetting(String settingKey, String settingValue) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        settingKey: settingKey,
        settingValue: settingValue,
      ),
    );
  }

  Future<void> upsertAudioFile({
    required String audioKey,
    required String audioType,
    required String remoteUrl,
    int? reciterId,
    int? surahNumber,
    int? ayahNumber,
    int? wordPosition,
    String? localPath,
    String? format,
    int? fileSize,
    int downloadedBytes = 0,
    String status = 'remote',
  }) async {
    await into(audioFiles).insertOnConflictUpdate(
      AudioFilesCompanion(
        audioKey: Value(audioKey),
        audioType: Value(audioType),
        reciterId: Value(reciterId),
        surahNumber: Value(surahNumber),
        ayahNumber: Value(ayahNumber),
        wordPosition: Value(wordPosition),
        remoteUrl: Value(remoteUrl),
        localPath: Value(localPath),
        format: Value(format),
        fileSize: Value(fileSize),
        downloadedBytes: Value(downloadedBytes),
        status: Value(status),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<AudioFileRecord?> getAudio(String audioKey) {
    return (select(
      audioFiles,
    )..where((row) => row.audioKey.equals(audioKey))).getSingleOrNull();
  }

  Future<void> registerAudioSource({
    required String audioKey,
    required String audioType,
    required String remoteUrl,
    int? reciterId,
    int? surahNumber,
    int? ayahNumber,
    int? wordPosition,
    String? format,
    int? fileSize,
  }) async {
    final existing = await getAudio(audioKey);
    if (existing == null) {
      await upsertAudioFile(
        audioKey: audioKey,
        audioType: audioType,
        remoteUrl: remoteUrl,
        reciterId: reciterId,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        wordPosition: wordPosition,
        format: format,
        fileSize: fileSize,
      );
      return;
    }

    await (update(
      audioFiles,
    )..where((row) => row.audioKey.equals(audioKey))).write(
      AudioFilesCompanion(
        audioType: Value(audioType),
        reciterId: reciterId == null ? const Value.absent() : Value(reciterId),
        surahNumber: surahNumber == null
            ? const Value.absent()
            : Value(surahNumber),
        ayahNumber: ayahNumber == null
            ? const Value.absent()
            : Value(ayahNumber),
        wordPosition: wordPosition == null
            ? const Value.absent()
            : Value(wordPosition),
        remoteUrl: Value(remoteUrl),
        format: format == null ? const Value.absent() : Value(format),
        fileSize: fileSize == null ? const Value.absent() : Value(fileSize),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> markAudioDownloaded({
    required String audioKey,
    required String localPath,
    required int bytes,
  }) async {
    await (update(
      audioFiles,
    )..where((row) => row.audioKey.equals(audioKey))).write(
      AudioFilesCompanion(
        localPath: Value(localPath),
        downloadedBytes: Value(bytes),
        status: const Value('downloaded'),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> replaceTimings({
    required int reciterId,
    required int surahNumber,
    required List<Map<String, dynamic>> timestamps,
  }) async {
    await transaction(() async {
      await (delete(ayahTimings)..where(
            (row) =>
                row.reciterId.equals(reciterId) &
                row.surahNumber.equals(surahNumber),
          ))
          .go();
      await (delete(wordTimings)..where(
            (row) =>
                row.reciterId.equals(reciterId) &
                row.surahNumber.equals(surahNumber),
          ))
          .go();

      for (final item in timestamps) {
        final verseKey = item['verse_key'] as String?;
        if (verseKey == null) continue;

        final parts = verseKey.split(':');
        if (parts.length != 2) continue;

        final ayahNumber = int.tryParse(parts[1]);
        final startMs = (item['timestamp_from'] as num?)?.toInt();
        final endMs = (item['timestamp_to'] as num?)?.toInt();
        if (ayahNumber == null || startMs == null || endMs == null) continue;

        await into(ayahTimings).insertOnConflictUpdate(
          AyahTimingsCompanion.insert(
            reciterId: reciterId,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            verseKey: verseKey,
            startMs: startMs,
            endMs: endMs,
          ),
        );

        final rawSegments = item['segments'];
        if (rawSegments is! List) continue;

        for (final raw in rawSegments) {
          if (raw is! List || raw.length < 3) continue;
          final position = (raw[0] as num?)?.toInt();
          final wordStartMs = (raw[1] as num?)?.toInt();
          final wordEndMs = (raw[2] as num?)?.toInt();
          if (position == null || wordStartMs == null || wordEndMs == null) {
            continue;
          }

          await into(wordTimings).insertOnConflictUpdate(
            WordTimingsCompanion.insert(
              reciterId: reciterId,
              surahNumber: surahNumber,
              ayahNumber: ayahNumber,
              wordPosition: position,
              startMs: wordStartMs,
              endMs: wordEndMs,
            ),
          );
        }
      }
    });
  }

  Future<AyahTimingRecord?> getAyahTiming({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) {
    return (select(ayahTimings)..where(
          (row) =>
              row.reciterId.equals(reciterId) &
              row.surahNumber.equals(surahNumber) &
              row.ayahNumber.equals(ayahNumber),
        ))
        .getSingleOrNull();
  }

  Future<List<WordTimingRecord>> getWordTimings({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) {
    return (select(wordTimings)
          ..where(
            (row) =>
                row.reciterId.equals(reciterId) &
                row.surahNumber.equals(surahNumber) &
                row.ayahNumber.equals(ayahNumber),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.startMs)]))
        .get();
  }

  Future<void> upsertDownloadJob({
    required String audioKey,
    required String audioType,
    required String remoteUrl,
    required String relativePath,
    required String status,
    required int downloadedBytes,
    int? expectedBytes,
    int? reciterId,
    int? surahNumber,
    int? ayahNumber,
    int? wordPosition,
    String? format,
    String? localPath,
    String? errorCode,
  }) async {
    await into(downloadJobs).insertOnConflictUpdate(
      DownloadJobsCompanion(
        audioKey: Value(audioKey),
        audioType: Value(audioType),
        remoteUrl: Value(remoteUrl),
        relativePath: Value(relativePath),
        status: Value(status),
        downloadedBytes: Value(downloadedBytes),
        expectedBytes: Value(expectedBytes),
        reciterId: Value(reciterId),
        surahNumber: Value(surahNumber),
        ayahNumber: Value(ayahNumber),
        wordPosition: Value(wordPosition),
        format: Value(format),
        localPath: Value(localPath),
        errorCode: Value(errorCode),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<DownloadJobRecord?> getDownloadJob(String audioKey) {
    return (select(
      downloadJobs,
    )..where((row) => row.audioKey.equals(audioKey))).getSingleOrNull();
  }

  Future<List<DownloadJobRecord>> listDownloadJobs() {
    return (select(
      downloadJobs,
    )..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])).get();
  }

  Future<void> deleteDownloadJob(String audioKey) async {
    await (delete(
      downloadJobs,
    )..where((row) => row.audioKey.equals(audioKey))).go();
  }

  Future<void> deleteAudio(String audioKey) async {
    await (delete(
      audioFiles,
    )..where((row) => row.audioKey.equals(audioKey))).go();
  }
}
