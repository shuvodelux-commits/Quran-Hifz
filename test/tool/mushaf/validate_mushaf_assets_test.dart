import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../tool/mushaf/validate_mushaf_assets.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('mushaf-validator-test-');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('accepts a 604 page 15 line layout with known line types', () async {
    final path = _createLayout(tempDir, 'valid.sqlite', lastPage: 604);

    final result = await validateLayout(path);

    expect(result.pageCount, 604);
    expect(result.linesPerPage, 15);
    expect(
      result.lineTypes,
      containsAll(<String>['ayah', 'basmallah', 'surah_name']),
    );
  });

  test('rejects a layout missing page 604', () async {
    final path = _createLayout(tempDir, 'missing-page.sqlite', lastPage: 603);

    await expectLater(
      () => validateLayout(path),
      throwsA(isA<FormatException>()),
    );
  });

  test('production validator needs only the surviving QCF V4 bundle', () async {
    final result = await validateMushafAssets(
      qcfV4LayoutPath: 'assets/mushaf/layouts/qpc-v4-tajweed-15-lines.sqlite',
      qcfV4ScriptPath: 'assets/mushaf/scripts/qpc-v4-words.sqlite',
    );

    expect(result.qcfV4Layout.pageCount, 604);
    expect(result.qcfV4Script.pageCount, 604);
    expect(result.qcfV2, isNull);
  });

  test('production QCF V4 page 440 preserves Ya-Sin transition', () async {
    final result = await validatePage440Transition(
      layoutPath: 'assets/mushaf/layouts/qpc-v4-tajweed-15-lines.sqlite',
    );

    expect(result.surahNumber, 36);
    expect(result.surahLine, 4);
    expect(result.bismillahLine, 5);
    expect(result.firstAyahLine, 6);
  });

  test('rejects an incomplete QPC V4 script database', () async {
    final path = tempDir.uri.resolve('incomplete-script.sqlite').toFilePath();
    final db = sqlite3.open(path);
    try {
      db.execute('''
        CREATE TABLE words (
          word_index INTEGER PRIMARY KEY,
          ayah_key TEXT,
          word_position INTEGER,
          char_type TEXT NOT NULL,
          page_number INTEGER NOT NULL,
          line_number INTEGER,
          display TEXT NOT NULL,
          unicode_fallback TEXT
        );
        INSERT INTO words VALUES (1, '1:1', 1, 'word', 1, 2, 'A', 'ا');
      ''');
    } finally {
      db.close();
    }

    await expectLater(
      () => validateQpcV4Script(path),
      throwsA(isA<FormatException>()),
    );
  });
}

String _createLayout(Directory tempDir, String name, {required int lastPage}) {
  final path = tempDir.uri.resolve(name).toFilePath();
  final db = sqlite3.open(path);
  try {
    db.execute('''
      CREATE TABLE info (
        name TEXT,
        number_of_pages INTEGER,
        lines_per_page INTEGER,
        font_name TEXT
      );
      CREATE TABLE pages (
        page_number INTEGER,
        line_number INTEGER,
        line_type TEXT,
        is_centered INTEGER,
        first_word_id INTEGER,
        last_word_id INTEGER,
        surah_number INTEGER
      );
      INSERT INTO info VALUES ('Fixture', 604, 15, 'FixtureFont');
    ''');
    final insert = db.prepare('INSERT INTO pages VALUES (?, ?, ?, ?, ?, ?, ?)');
    try {
      for (var page = 1; page <= lastPage; page++) {
        final type = switch (page) {
          1 => 'surah_name',
          2 => 'basmallah',
          _ => 'ayah',
        };
        insert.execute([
          page,
          1,
          type,
          type == 'ayah' ? 0 : 1,
          type == 'ayah' ? page : null,
          type == 'ayah' ? page : null,
          type == 'surah_name' ? 1 : null,
        ]);
      }
    } finally {
      insert.close();
    }
  } finally {
    db.close();
  }
  return path;
}
