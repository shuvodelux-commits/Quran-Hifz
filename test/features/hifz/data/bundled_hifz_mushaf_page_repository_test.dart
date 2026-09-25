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
    String? digitalScriptPath,
  }) {
    return BundledHifzMushafPageRepository.forFiles(
      qpcLayoutPath: qpcLayoutPath,
      qpcScriptPath: qpcScript,
      digitalKhattLayoutPath: digitalLayout,
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
        db.dispose();
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
    'Digital Khatt becomes available when an exact script is injected',
    () async {
      final scriptPath = tempDir.uri
          .resolve('digital-khatt-script.sqlite')
          .toFilePath();
      final db = sqlite3.open(scriptPath);
      try {
        db.execute('''
        CREATE TABLE words (
          word_index INTEGER PRIMARY KEY,
          ayah_key TEXT,
          word_position INTEGER,
          char_type TEXT NOT NULL,
          display TEXT NOT NULL
        );
        CREATE TABLE metadata (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        );
        INSERT INTO metadata VALUES ('script_kind', 'digital_khatt_v2');
      ''');
        final insert = db.prepare('INSERT INTO words VALUES (?, ?, ?, ?, ?)');
        try {
          for (var index = 1; index <= 36; index++) {
            insert.execute([
              index,
              '1:1',
              index,
              index == 5 ? 'end' : 'word',
              'glyph-$index',
            ]);
          }
        } finally {
          insert.dispose();
        }
      } finally {
        db.dispose();
      }

      final subject = repository(digitalScriptPath: scriptPath);
      expect(
        await subject.isVariantAvailable(HifzMushafVariant.digitalKhattV2),
        isTrue,
      );
      final page = await subject.loadPage(
        variant: HifzMushafVariant.digitalKhattV2,
        page: 1,
      );
      expect(page.page, 1);
      expect(page.tokens, hasLength(36));
    },
  );
}
