import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'quran_content_database.g.dart';

class Surahs extends Table {
  IntColumn get number => integer()();
  TextColumn get nameArabic => text()();
  TextColumn get nameEnglish => text()();
  TextColumn get nameBangla => text().nullable()();
  TextColumn get revelationPlace => text().nullable()();
  IntColumn get ayahCount => integer()();
  IntColumn get pageStart => integer()();
  IntColumn get pageEnd => integer()();
  IntColumn get juzStart => integer()();

  @override
  Set<Column<Object>> get primaryKey => {number};
}

@TableIndex(
  name: 'idx_ayah_page',
  columns: {#pageNumber, #surahNumber, #ayahNumber},
)
@TableIndex(
  name: 'idx_ayah_juz',
  columns: {#juzNumber, #surahNumber, #ayahNumber},
)
class Ayahs extends Table {
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get verseKey => text().unique()();
  TextColumn get arabicText => text()();
  TextColumn get arabicTextIndopak => text()();
  TextColumn get arabicTextTajweed => text().nullable()();
  IntColumn get pageNumber => integer()();
  IntColumn get juzNumber => integer()();
  IntColumn get hizbNumber => integer().nullable()();
  IntColumn get rubNumber => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {surahNumber, ayahNumber};
}

@TableIndex(
  name: 'idx_word_lookup',
  columns: {#surahNumber, #ayahNumber, #position},
)
@DataClassName('QuranWordRecord')
class QuranWords extends Table {
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  IntColumn get position => integer()();
  TextColumn get arabic => text()();
  TextColumn get arabicIndopak => text()();
  TextColumn get arabicTajweed => text().nullable()();
  TextColumn get transliteration => text().nullable()();
  TextColumn get banglaMeaning => text().nullable()();
  TextColumn get englishMeaning => text().nullable()();
  TextColumn get root => text().nullable()();
  TextColumn get lemma => text().nullable()();
  TextColumn get grammar => text().nullable()();
  TextColumn get audioRemotePath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {surahNumber, ayahNumber, position};
}

@TableIndex(
  name: 'idx_translation_lookup',
  columns: {#resourceId, #surahNumber, #ayahNumber},
)
@DataClassName('TranslationRecord')
class Translations extends Table {
  IntColumn get resourceId => integer()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get language => text()();
  TextColumn get textValue => text().named('text')();

  @override
  Set<Column<Object>> get primaryKey => {resourceId, surahNumber, ayahNumber};
}

@DataClassName('QuranMetadataRecord')
class QuranMetadata extends Table {
  TextColumn get metadataKey => text()();
  TextColumn get metadataValue => text()();

  @override
  Set<Column<Object>> get primaryKey => {metadataKey};
}

@TableIndex(name: 'idx_mushaf_line_page', columns: {#pageNumber, #lineNumber})
class MushafLines extends Table {
  IntColumn get pageNumber => integer()();
  IntColumn get lineNumber => integer()();
  TextColumn get lineType => text()();
  BoolColumn get isCentered => boolean()();
  IntColumn get surahNumber => integer().nullable()();
  TextColumn get firstWordLocation => text().nullable()();
  TextColumn get lastWordLocation => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {pageNumber, lineNumber};
}

@DriftDatabase(
  tables: [Surahs, Ayahs, QuranWords, Translations, QuranMetadata, MushafLines],
)
class QuranContentDatabase extends _$QuranContentDatabase {
  QuranContentDatabase(super.executor);

  QuranContentDatabase.forTesting(QueryExecutor executor) : super(executor);

  QuranContentDatabase.forPath(String path)
    : super(
        NativeDatabase.createInBackground(
          File(path),
          enableMigrations: false,
          setup: (database) {
            database.execute('PRAGMA query_only = ON');
          },
        ),
      );

  QuranContentDatabase.defaults()
    : super(
        driftDatabase(
          name: 'quran_content',
          native: DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (_, _, _) async {},
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
