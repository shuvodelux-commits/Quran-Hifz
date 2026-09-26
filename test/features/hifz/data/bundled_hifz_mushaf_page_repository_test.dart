import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/data/bundled_hifz_mushaf_page_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_mushaf_page.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_mushaf_page_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reading_mode.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  const qcfV4Layout = 'assets/mushaf/layouts/qpc-v4-tajweed-15-lines.sqlite';
  const qcfV4Script = 'assets/mushaf/scripts/qpc-v4-words.sqlite';

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('mushaf-page-repo-test-');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  BundledHifzMushafPageRepository repository({
    String qcfV4LayoutPath = qcfV4Layout,
    String qcfV2LayoutPath = '',
    String qcfV2ScriptPath = '',
  }) {
    return BundledHifzMushafPageRepository.forFiles(
      qcfV4LayoutPath: qcfV4LayoutPath,
      qcfV4ScriptPath: qcfV4Script,
      qcfV2LayoutPath: qcfV2LayoutPath,
      qcfV2ScriptPath: qcfV2ScriptPath,
    );
  }

  test('loads QPC page 2 from layout and script ranges', () async {
    final page = await repository().loadPage(
      variant: QuranMushafVariant.qcfV4Tajweed,
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
      () => subject.loadPage(variant: QuranMushafVariant.qcfV4Tajweed, page: 0),
      throwsA(isA<RangeError>()),
    );
    await expectLater(
      () =>
          subject.loadPage(variant: QuranMushafVariant.qcfV4Tajweed, page: 605),
      throwsA(isA<RangeError>()),
    );
  });

  test(
    'fails closed when one line references a missing script token',
    () async {
      final broken = File(
        tempDir.uri.resolve('broken-layout.sqlite').toFilePath(),
      );
      File(qcfV4Layout).copySync(broken.path);

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
          qcfV4LayoutPath: broken.path,
        ).loadPage(variant: QuranMushafVariant.qcfV4Tajweed, page: 2),
        throwsA(isA<MushafDataIntegrityException>()),
      );
    },
  );

  test('resolves QPC ayah page from script data', () async {
    expect(
      await repository().pageForAyah(
        variant: QuranMushafVariant.qcfV4Tajweed,
        ayah: const AyahRef(surahNumber: 2, ayahNumber: 1),
      ),
      2,
    );
  });

  test('QCF V2 reports unavailable until generated assets exist', () async {
    expect(
      await repository().isVariantAvailable(QuranMushafVariant.qcfV2),
      isFalse,
    );
  });

  test('QCF V4 page 440 keeps Surah and Bismillah structure', () async {
    final page = await repository().loadPage(
      variant: QuranMushafVariant.qcfV4Tajweed,
      page: 440,
    );

    expect(page.lines, hasLength(15));
    expect(
      page.lines.take(3).every((line) => line.type == HifzMushafLineType.ayah),
      isTrue,
    );
    expect(page.lines[3].type, HifzMushafLineType.surahName);
    expect(page.lines[3].surahNumber, 36);
    expect(page.lines[4].type, HifzMushafLineType.basmallah);
    expect(
      page.lines.skip(5).every((line) => line.type == HifzMushafLineType.ayah),
      isTrue,
    );
  });
}
