import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../tool/quran_content/qul_mushaf_source.dart';

void main() {
  group('QulMushafSource', () {
    test(
      'normalizes QUL words and ayah line boundaries by stable location',
      () async {
        final fixture = await _QulFixture.create();
        addTearDown(fixture.dispose);
        fixture.addWord(10, '2:1:1', 2, 1, 'الٓمّٓ');
        fixture.addWord(11, '2:1:2', 2, 1, 'لَمۡ');
        fixture.addWord(12, '2:1:3', 2, 1, 'هُدًى\uE001');
        fixture.addLine(1, 1, 'ayah', 0, 10, 12, 2);

        final source = QulMushafSource.open(
          scriptPath: fixture.script.path,
          layoutPath: fixture.layout.path,
        );
        addTearDown(source.close);

        expect(source.indoPakWordText('2:1:1'), 'الٓمّٓ');
        expect(source.indoPakAyahText(2, 1), 'الٓمّٓ لَمۡ هُدًى');
        expect(source.lines.single.firstWordLocation, '2:1:1');
        expect(source.lines.single.lastWordLocation, '2:1:3');
        expect(source.lines.single.centered, isFalse);
        expect(source.indoPakWordText('2:1:2'), contains('\u06E1'));
        expect(source.indoPakWordText('2:1:3'), contains('\u064B'));
      },
    );

    test('rejects an ayah boundary whose global word ID is unknown', () async {
      final fixture = await _QulFixture.create();
      addTearDown(fixture.dispose);
      fixture.addWord(10, '2:1:1', 2, 1, 'الٓمّٓ');
      fixture.addLine(1, 1, 'ayah', 0, 10, 99, 2);

      expect(
        () => QulMushafSource.open(
          scriptPath: fixture.script.path,
          layoutPath: fixture.layout.path,
        ),
        throwsFormatException,
      );
    });

    test('rejects duplicate stable word locations', () async {
      final fixture = await _QulFixture.create();
      addTearDown(fixture.dispose);
      fixture.addWord(10, '2:1:1', 2, 1, 'الٓمّٓ');
      fixture.addWord(11, '2:1:1', 2, 1, 'لَمۡ');

      expect(
        () => QulMushafSource.open(
          scriptPath: fixture.script.path,
          layoutPath: fixture.layout.path,
        ),
        throwsFormatException,
      );
    });

    test('rejects a missing location in the QUL word record', () async {
      final fixture = await _QulFixture.create();
      addTearDown(fixture.dispose);
      fixture.addWord(10, '', 2, 1, 'الٓمّٓ');

      expect(
        () => QulMushafSource.open(
          scriptPath: fixture.script.path,
          layoutPath: fixture.layout.path,
        ),
        throwsFormatException,
      );
    });

    test(
      'rejects private-use code points outside a final ayah marker',
      () async {
        final fixture = await _QulFixture.create();
        addTearDown(fixture.dispose);
        fixture.addWord(10, '2:1:1', 2, 1, 'ال\uE001م');

        expect(
          () => QulMushafSource.open(
            scriptPath: fixture.script.path,
            layoutPath: fixture.layout.path,
          ),
          throwsFormatException,
        );
      },
    );

    test('preserves QUL IndoPak font shaping glyphs', () async {
      final fixture = await _QulFixture.create();
      addTearDown(fixture.dispose);
      fixture.addWord(10, '2:1:1', 2, 1, 'الْاَ\uF64Bبْیَضُ');
      fixture.addLine(1, 1, 'ayah', 0, 10, 10, 2);

      final source = QulMushafSource.open(
        scriptPath: fixture.script.path,
        layoutPath: fixture.layout.path,
      );
      addTearDown(source.close);

      expect(source.indoPakWordText('2:1:1'), 'الْاَ\uF64Bبْیَضُ');
    });

    test(
      'rejects a private-use marker on a non-final word of an ayah',
      () async {
        final fixture = await _QulFixture.create();
        addTearDown(fixture.dispose);
        fixture.addWord(10, '2:1:1', 2, 1, 'الٓمّٓ\uE001');
        fixture.addWord(11, '2:1:2', 2, 1, 'لَمۡ');

        expect(
          () => QulMushafSource.open(
            scriptPath: fixture.script.path,
            layoutPath: fixture.layout.path,
          ),
          throwsFormatException,
        );
      },
    );

    test(
      'rejects supplementary private-use code points even when trailing on a final word',
      () async {
        for (final codePoint in [0xF0000, 0xFFFFD, 0x100000, 0x10FFFD]) {
          final fixture = await _QulFixture.create();
          addTearDown(fixture.dispose);
          fixture.addWord(
            10,
            '2:1:1',
            2,
            1,
            'الٓمّٓ${String.fromCharCode(codePoint)}',
          );

          expect(
            () => QulMushafSource.open(
              scriptPath: fixture.script.path,
              layoutPath: fixture.layout.path,
            ),
            throwsFormatException,
            reason:
                'U+${codePoint.toRadixString(16).toUpperCase()} must reject.',
          );
        }
      },
    );

    test(
      'rejects a supplementary private-use code point on a non-final word',
      () async {
        final fixture = await _QulFixture.create();
        addTearDown(fixture.dispose);
        fixture.addWord(10, '2:1:1', 2, 1, 'الٓمّٓ\u{F0000}');
        fixture.addWord(11, '2:1:2', 2, 1, 'لَمۡ');

        expect(
          () => QulMushafSource.open(
            scriptPath: fixture.script.path,
            layoutPath: fixture.layout.path,
          ),
          throwsFormatException,
        );
      },
    );

    test(
      'closes the script database when opening the layout database fails',
      () async {
        final fixture = await _QulFixture.create();
        addTearDown(fixture.dispose);
        Database? scriptDatabase;

        expect(
          () => QulMushafSource.open(
            scriptPath: fixture.script.path,
            layoutPath: fixture.layout.path,
            databaseOpener: (path, {mode = OpenMode.readWriteCreate}) {
              if (path == fixture.layout.path) {
                throw StateError('layout cannot be opened');
              }
              final database = sqlite3.open(path, mode: mode);
              scriptDatabase = database;
              return database;
            },
          ),
          throwsStateError,
        );

        expect(() => scriptDatabase!.select('SELECT 1'), throwsStateError);
      },
    );

    test(
      'requires metadata lines to have null word boundaries and valid Surah',
      () async {
        final fixture = await _QulFixture.create();
        addTearDown(fixture.dispose);
        fixture.addWord(10, '2:1:1', 2, 1, 'الٓمّٓ');
        fixture.addLine(1, 1, 'surah_name', 1, 10, null, 2);

        expect(
          () => QulMushafSource.open(
            scriptPath: fixture.script.path,
            layoutPath: fixture.layout.path,
          ),
          throwsFormatException,
        );
      },
    );

    test('requires all 604 numbered pages for a production layout', () async {
      final fixture = await _QulFixture.create();
      addTearDown(fixture.dispose);
      fixture.addWord(10, '2:1:1', 2, 1, 'الٓمّٓ');
      fixture.addLine(1, 1, 'ayah', 0, 10, 10, 2);

      expect(
        () => QulMushafSource.open(
          scriptPath: fixture.script.path,
          layoutPath: fixture.layout.path,
          requireProductionPageSet: true,
        ),
        throwsFormatException,
      );
    });
  });
}

class _QulFixture {
  _QulFixture(this.directory, this.script, this.layout);

  final Directory directory;
  final File script;
  final File layout;

  static Future<_QulFixture> create() async {
    final directory = await Directory.systemTemp.createTemp('qul-source-test-');
    final script = File('${directory.path}/script.sqlite');
    final layout = File('${directory.path}/layout.sqlite');
    final scriptDb = sqlite3.open(script.path);
    final layoutDb = sqlite3.open(layout.path);
    try {
      scriptDb.execute('''
        CREATE TABLE words (
          id INTEGER NOT NULL,
          location TEXT NOT NULL,
          surah INTEGER NOT NULL,
          ayah INTEGER NOT NULL,
          word INTEGER NOT NULL,
          text TEXT NOT NULL
        )
      ''');
      layoutDb.execute('''
        CREATE TABLE pages (
          page_number INTEGER NOT NULL,
          line_number INTEGER NOT NULL,
          line_type TEXT NOT NULL,
          is_centered INTEGER NOT NULL,
          first_word_id INTEGER,
          last_word_id INTEGER,
          surah_number INTEGER
        )
      ''');
    } finally {
      scriptDb.close();
      layoutDb.close();
    }
    return _QulFixture(directory, script, layout);
  }

  void addWord(int id, String location, int surah, int ayah, String text) {
    final db = sqlite3.open(script.path);
    try {
      final segments = location.split(':');
      final position = segments.length == 3
          ? int.tryParse(segments.last) ?? 1
          : 1;
      db.execute(
        'INSERT INTO words (id, location, surah, ayah, word, text) VALUES (?, ?, ?, ?, ?, ?)',
        [id, location, surah, ayah, position, text],
      );
    } finally {
      db.close();
    }
  }

  void addLine(
    int page,
    int line,
    String type,
    int centered,
    int? firstWordId,
    int? lastWordId,
    int? surah,
  ) {
    final db = sqlite3.open(layout.path);
    try {
      db.execute('INSERT INTO pages VALUES (?, ?, ?, ?, ?, ?, ?)', [
        page,
        line,
        type,
        centered,
        firstWordId,
        lastWordId,
        surah,
      ]);
    } finally {
      db.close();
    }
  }

  void dispose() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }
}
