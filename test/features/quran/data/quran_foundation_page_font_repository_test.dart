import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:quran_hifz/features/quran/data/quran_foundation_page_font_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_font_repository.dart';

void main() {
  const validWoff2 = <int>[0x77, 0x4f, 0x46, 0x32, 1, 2, 3, 4];

  late Directory tempDir;
  late List<Uri> requests;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('quran-foundation-fonts-');
    requests = <Uri>[];
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  QuranFoundationPageFontRepository repository(
    QuranFontPreference font, {
    http.Client? client,
  }) => QuranFoundationPageFontRepository(
    font: font,
    client:
        client ??
        MockClient((request) async {
          requests.add(request.url);
          return http.Response.bytes(validWoff2, 200);
        }),
    supportDirectory: () async => tempDir,
  );

  File cached(QuranFontPreference font, int page) => File(
    p.join(
      tempDir.path,
      'quran',
      'page-fonts',
      font == QuranFontPreference.qcfV2 ? 'qcf-v2' : 'qcf-v4-tajweed',
      'p$page.woff2',
    ),
  );

  test('maps strict QCF page fonts to Quran Foundation URLs', () {
    expect(
      quranFoundationPageFontUri(QuranFontPreference.qcfV2, 440).toString(),
      'https://verses.quran.foundation/fonts/quran/hafs/v2/woff2/p440.woff2',
    );
    expect(
      quranFoundationPageFontUri(
        QuranFontPreference.qcfV4Tajweed,
        440,
      ).toString(),
      'https://verses.quran.foundation/fonts/quran/hafs/v4/colrv1/woff2/p440.woff2',
    );
  });

  test('rejects adaptive fonts and pages outside 1 through 604', () {
    expect(
      () => quranFoundationPageFontUri(QuranFontPreference.qpcHafs, 1),
      throwsArgumentError,
    );
    expect(
      () => QuranFoundationPageFontRepository(
        font: QuranFontPreference.indoPak,
        supportDirectory: () async => tempDir,
      ),
      throwsArgumentError,
    );
    expect(
      () => quranFoundationPageFontUri(QuranFontPreference.qcfV2, 0),
      throwsRangeError,
    );
    expect(
      () => quranFoundationPageFontUri(QuranFontPreference.qcfV2, 605),
      throwsRangeError,
    );
  });

  test('V2 and V4 use separate cache roots and exact URLs', () async {
    final v2 = await repository(QuranFontPreference.qcfV2).ensurePageFont(440);
    final v4 = await repository(
      QuranFontPreference.qcfV4Tajweed,
    ).ensurePageFont(440);

    expect(v2.toFilePath(), cached(QuranFontPreference.qcfV2, 440).path);
    expect(v4.toFilePath(), cached(QuranFontPreference.qcfV4Tajweed, 440).path);
    expect(v2.toFilePath(), isNot(v4.toFilePath()));
    expect(requests.map((uri) => uri.toString()), [
      'https://verses.quran.foundation/fonts/quran/hafs/v2/woff2/p440.woff2',
      'https://verses.quran.foundation/fonts/quran/hafs/v4/colrv1/woff2/p440.woff2',
    ]);
  });

  test(
    'returns a valid cache without allowing HTTP failure to replace it',
    () async {
      final file = cached(QuranFontPreference.qcfV2, 2);
      file.parent.createSync(recursive: true);
      await file.writeAsBytes(validWoff2);

      final subject = repository(
        QuranFontPreference.qcfV2,
        client: MockClient((_) async => http.Response('offline', 503)),
      );

      final uri = await subject.ensurePageFont(2);

      expect(uri.toFilePath(), file.path);
      expect(await file.readAsBytes(), validWoff2);
    },
  );

  test('invalid WOFF2 never replaces an existing valid backup', () async {
    final finalFile = cached(QuranFontPreference.qcfV4Tajweed, 3);
    final backup = File('${finalFile.path}.bak');
    finalFile.parent.createSync(recursive: true);
    await backup.writeAsBytes(validWoff2);
    await finalFile.writeAsBytes([1, 2, 3]);

    final subject = repository(
      QuranFontPreference.qcfV4Tajweed,
      client: MockClient((_) async => http.Response.bytes([1, 2, 3], 200)),
    );

    final uri = await subject.ensurePageFont(3);

    expect(uri.toFilePath(), finalFile.path);
    expect(await finalFile.readAsBytes(), validWoff2);
    expect(backup.existsSync(), isFalse);
    expect(File('${finalFile.path}.part').existsSync(), isFalse);
  });

  test(
    'recovers a valid backup left by an interrupted atomic replacement',
    () async {
      final finalFile = cached(QuranFontPreference.qcfV2, 4);
      final backup = File('${finalFile.path}.bak');
      finalFile.parent.createSync(recursive: true);
      await backup.writeAsBytes(validWoff2);

      final subject = repository(
        QuranFontPreference.qcfV2,
        client: MockClient((_) async => throw const SocketException('offline')),
      );

      final uri = await subject.ensurePageFont(4);

      expect(uri.toFilePath(), finalFile.path);
      expect(await finalFile.readAsBytes(), validWoff2);
      expect(backup.existsSync(), isFalse);
    },
  );

  test(
    'offline uncached page throws typed error and leaves no part file',
    () async {
      final subject = repository(
        QuranFontPreference.qcfV2,
        client: MockClient((_) async => throw const SocketException('offline')),
      );

      await expectLater(
        subject.ensurePageFont(5),
        throwsA(isA<QuranPageFontUnavailableException>()),
      );

      final file = cached(QuranFontPreference.qcfV2, 5);
      expect(file.existsSync(), isFalse);
      expect(File('${file.path}.part').existsSync(), isFalse);
    },
  );

  test('HTTP failure is recognizable and leaves no corrupt cache', () async {
    final subject = repository(
      QuranFontPreference.qcfV4Tajweed,
      client: MockClient((request) async {
        requests.add(request.url);
        return http.Response('unavailable', 503);
      }),
    );

    await expectLater(
      subject.ensurePageFont(6),
      throwsA(isA<QuranPageFontUnavailableException>()),
    );

    expect(cached(QuranFontPreference.qcfV4Tajweed, 6).existsSync(), isFalse);
    expect(
      File(
        '${cached(QuranFontPreference.qcfV4Tajweed, 6).path}.part',
      ).existsSync(),
      isFalse,
    );
  });

  test(
    'deduplicates same-page downloads and prefetches valid neighbors',
    () async {
      final subject = repository(QuranFontPreference.qcfV2);

      final results = await Future.wait([
        subject.ensurePageFont(20),
        subject.ensurePageFont(20),
      ]);
      await subject.prefetchNeighbors(20);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(results[0], results[1]);
      expect(
        requests.where((uri) => uri.path.endsWith('/p20.woff2')),
        hasLength(1),
      );
      expect(requests.any((uri) => uri.path.endsWith('/p19.woff2')), isTrue);
      expect(requests.any((uri) => uri.path.endsWith('/p21.woff2')), isTrue);
    },
  );
}
