import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:quran_hifz/features/hifz/data/qpc_v4_page_font_repository.dart';

void main() {
  const validWoff2Bytes = <int>[0x77, 0x4f, 0x46, 0x32, 1, 2, 3, 4];

  late Directory tempDir;
  late List<Uri> requests;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('qpc-v4-font-cache-');
    requests = <Uri>[];
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  File cached(int page) =>
      File(p.join(tempDir.path, 'mushaf', 'qpc-v4', 'p$page.woff2'));

  QpcV4PageFontRepository repository({http.Client? client}) {
    return QpcV4PageFontRepository(
      client:
          client ??
          MockClient((request) async {
            requests.add(request.url);
            return http.Response.bytes(validWoff2Bytes, 200);
          }),
      supportDirectory: () async => tempDir,
    );
  }

  test('returns an existing valid cached WOFF2 without HTTP', () async {
    final file = cached(2);
    file.parent.createSync(recursive: true);
    await file.writeAsBytes(validWoff2Bytes);

    final uri = await repository().ensurePageFont(2);

    expect(uri.toFilePath(), file.path);
    expect(requests, isEmpty);
  });

  test('deduplicates concurrent downloads for the same page', () async {
    final subject = repository();

    final results = await Future.wait([
      subject.ensurePageFont(2),
      subject.ensurePageFont(2),
    ]);

    expect(results[0], results[1]);
    expect(
      requests.where((uri) => uri.path.endsWith('/p2.woff2')),
      hasLength(1),
    );
  });

  test(
    'rejects corrupt cache and atomically replaces it with valid WOFF2',
    () async {
      final file = cached(2);
      file.parent.createSync(recursive: true);
      await file.writeAsBytes([1, 2, 3]);

      final uri = await repository().ensurePageFont(2);

      expect(await File.fromUri(uri).readAsBytes(), validWoff2Bytes);
      expect(
        await tempDir
            .list(recursive: true)
            .where((entry) => entry.path.endsWith('.part'))
            .toList(),
        isEmpty,
      );
    },
  );

  test('failed download does not publish partial bytes', () async {
    final subject = repository(
      client: MockClient((request) async {
        requests.add(request.url);
        return http.Response.bytes([1, 2, 3], 200);
      }),
    );

    await expectLater(
      subject.ensurePageFont(2),
      throwsA(isA<FormatException>()),
    );

    expect(cached(2).existsSync(), isFalse);
    expect(
      await tempDir
          .list(recursive: true)
          .where((entry) => entry.path.endsWith('.part'))
          .toList(),
      isEmpty,
    );
  });

  test('rejects pages outside 1 through 604', () async {
    final subject = repository();

    await expectLater(() => subject.ensurePageFont(0), throwsRangeError);
    await expectLater(() => subject.ensurePageFont(605), throwsRangeError);
    expect(requests, isEmpty);
  });

  test('prefetch neighbor failures do not fail the current page', () async {
    final subject = repository(
      client: MockClient((request) async {
        requests.add(request.url);
        final page = int.parse(
          RegExp(r'p(\d+)\.woff2').firstMatch(request.url.path)!.group(1)!,
        );
        if (page == 2) return http.Response.bytes(validWoff2Bytes, 200);
        return http.Response('offline', 503);
      }),
    );

    await subject.ensurePageFont(2);
    await subject.prefetchNeighbors(2);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(await subject.isCached(2), isTrue);
  });
}
