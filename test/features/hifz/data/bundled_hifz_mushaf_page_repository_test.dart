import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/data/bundled_hifz_mushaf_page_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_mushaf_page.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_mushaf_page_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reading_mode.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  const qpcLayout = 'assets/mushaf/layouts/qpc-v4-tajweed-15-lines.sqlite';
  const qpcScript = 'assets/mushaf/scripts/qpc-v4-words.sqlite';
  const digitalLayout = 'assets/mushaf/layouts/digital-khatt-15-lines.sqlite';

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('mushaf-page-repo-test-');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  BundledHifzMushafPageRepository repository({
    String qpcLayoutPath = qpcLayout,
    String digitalLayoutPath = digitalLayout,
    String? digitalScriptPath,
  }) {
    return BundledHifzMushafPageRepository.forFiles(
      qpcLayoutPath: qpcLayoutPath,
      qpcScriptPath: qpcScript,
      digitalKhattLayoutPath: digitalLayoutPath,
      digitalKhattScriptPath: digitalScriptPath,
    );
  }

  test('loads QPC page 2 from layout and script ranges', () async {
    final page = await repository().loadPage(
      variant: HifzMushafVariant.qpcV4Tajweed,
      page: 2,
    );

    expect(page.page, 2);
    expect(page.lines.first.type, HifzMushafLineType.surahName);
    expect(page.lines[1].type, HifzMushafLineType.basmallah);
    expect(
      page.lines.where((line) => line.type == HifzMushafLineType.ayah),
      isNotEmpty,
    );
    expect(page.tokens, isNotEmpty);
    expect(page.tokens.every((token) => token.display.isNotEmpty), isTrue);
  });

  test('rejects pages outside 1 through 604', () async {
    final subject = repository();

    await expectLater(
      () => subject.loadPage(variant: HifzMushafVariant.qpcV4Tajweed, page: 0),
      throwsA(isA<RangeError>()),
    );
    await expectLater(
      () =>
          subject.loadPage(variant: HifzMushafVariant.qpcV4Tajweed, page: 605),
      throwsA(isA<RangeError>()),
    );
  });

  test(
    'fails closed when one line references a missing script token',
    () async {
      final broken = File(
        tempDir.uri.resolve('broken-layout.sqlite').toFilePath(),
      );
      File(qpcLayout).copySync(broken.path);

      final db = sqlite3.open(broken.path);
      try {
        db.execute(
          'UPDATE pages SET last_word_id = 90000 '
          "WHERE page_number = 2 AND line_type = 'ayah' "
          'AND line_number = 3',
        );
      } finally {
        db.close();
      }

      await expectLater(
        () => repository(
          qpcLayoutPath: broken.path,
        ).loadPage(variant: HifzMushafVariant.qpcV4Tajweed, page: 2),
        throwsA(isA<MushafDataIntegrityException>()),
      );
    },
  );

  test('resolves QPC ayah page from script data', () async {
    expect(
      await repository().pageForAyah(
        variant: HifzMushafVariant.qpcV4Tajweed,
        ayah: const AyahRef(surahNumber: 2, ayahNumber: 1),
      ),
      2,
    );
  });

  test(
    'Digital Khatt reports unavailable when exact script asset is absent',
    () async {
      expect(
        await repository().isVariantAvailable(HifzMushafVariant.digitalKhattV2),
        isFalse,
      );
    },
  );

  test(
    'Digital Khatt rejects a partial exact-looking script against full layout',
    () async {
      final scriptPath = _writeDigitalScriptFixture(
        tempDir: tempDir,
        tokenCountMetadata: 7,
      );

      final subject = repository(digitalScriptPath: scriptPath);
      expect(
        await subject.isVariantAvailable(HifzMushafVariant.digitalKhattV2),
        isFalse,
      );
    },
  );

  test(
    'Digital Khatt becomes available only when layout and exact script agree',
    () async {
      final layoutPath = _writeDigitalLayoutFixture(tempDir);
      final scriptPath = _writeDigitalScriptFixture(
        tempDir: tempDir,
        tokenCountMetadata: 7,
      );

      final subject = repository(
        digitalLayoutPath: layoutPath,
        digitalScriptPath: scriptPath,
      );
      expect(
        await subject.isVariantAvailable(HifzMushafVariant.digitalKhattV2),
        isTrue,
      );

      final page = await subject.loadPage(
        variant: HifzMushafVariant.digitalKhattV2,
        page: 1,
      );
      expect(page.page, 1);
      expect(page.tokens.map((token) => token.display).toList(), const [
        'أَوْ',
        'زِدْ',
        'عَلَيْهِ',
        'وَرَتِّلِ',
        'ٱلْقُرْءَانَ',
        'تَرْتِيلًا',
        '۝٤',
      ]);
    },
  );

  test('Digital Khatt rejects a changed canonical codepoint', () async {
    final layoutPath = _writeDigitalLayoutFixture(tempDir);
    final scriptPath = _writeDigitalScriptFixture(
      tempDir: tempDir,
      tokenCountMetadata: 7,
      firstDisplay: 'أَوْ',
    );

    expect(
      await repository(
        digitalLayoutPath: layoutPath,
        digitalScriptPath: scriptPath,
      ).isVariantAvailable(HifzMushafVariant.digitalKhattV2),
      isFalse,
    );
  });
}

String _writeDigitalLayoutFixture(Directory tempDir) {
  final path = tempDir.uri.resolve('digital-layout.sqlite').toFilePath();
  final db = sqlite3.open(path);
  try {
    db.execute('''
      CREATE TABLE pages (
        page_number INTEGER NOT NULL,
        line_number INTEGER NOT NULL,
        line_type TEXT NOT NULL,
        is_centered INTEGER NOT NULL,
        first_word_id INTEGER,
        last_word_id INTEGER,
        surah_number INTEGER
      );
      INSERT INTO pages VALUES (1, 1, 'ayah', 0, 1, 7, 73);
    ''');
  } finally {
    db.close();
  }
  return path;
}

String _writeDigitalScriptFixture({
  required Directory tempDir,
  required int tokenCountMetadata,
  String firstDisplay = 'أَوْ',
}) {
  final path = tempDir.uri.resolve('digital-script.sqlite').toFilePath();
  final db = sqlite3.open(path);
  try {
    db.execute('''
      CREATE TABLE words (
        word_index INTEGER PRIMARY KEY,
        ayah_key TEXT NOT NULL,
        word_position INTEGER NOT NULL,
        char_type TEXT NOT NULL,
        display TEXT NOT NULL
      );
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    final metadata = db.prepare(
      'INSERT INTO metadata(key, value) VALUES (?, ?)',
    );
    try {
      for (final entry in <String, String>{
        'script_kind': 'digital_khatt_v2',
        'script_type': 'text_digital_khatt',
        'font_family': 'digitalkhatt-v2',
        'qul_resource_id': '48',
        'token_count': '$tokenCountMetadata',
      }.entries) {
        metadata.execute([entry.key, entry.value]);
      }
    } finally {
      metadata.close();
    }

    final displays = <String>[
      firstDisplay,
      'زِدْ',
      'عَلَيْهِ',
      'وَرَتِّلِ',
      'ٱلْقُرْءَانَ',
      'تَرْتِيلًا',
      '۝٤',
    ];
    final insert = db.prepare('INSERT INTO words VALUES (?, ?, ?, ?, ?)');
    try {
      for (var index = 0; index < displays.length; index++) {
        insert.execute([
          index + 1,
          '73:4',
          index + 1,
          index == displays.length - 1 ? 'end' : 'word',
          displays[index],
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
