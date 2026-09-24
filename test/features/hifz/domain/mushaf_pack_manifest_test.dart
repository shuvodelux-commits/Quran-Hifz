import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/mushaf_pack_manifest.dart';

void main() {
  Map<String, Object?> validJson() => <String, Object?>{
    'id': 'indopak-15-line',
    'name': 'IndoPak 15 Line',
    'script': 'IndoPak Nastaleeq',
    'version': '1.0.0',
    'page_count': 604,
    'size_bytes': 120000000,
    'sha256': 'a' * 64,
    'download_url': 'https://cdn.example.org/indopak-15-line.zip',
    'attribution': 'Rendered from a licensed source.',
    'license': 'CC BY 4.0',
    'page_file_pattern': 'pages/{page}.webp',
    'coordinates_file': 'coordinates/words.json',
  };

  test('parses a complete licensed HTTPS manifest', () {
    final manifest = MushafPackManifest.fromJson(validJson());

    expect(manifest.id, 'indopak-15-line');
    expect(manifest.pageCount, 604);
    expect(manifest.downloadUrl.scheme, 'https');
    expect(manifest.pagePath(7), 'pages/7.webp');
    expect(manifest.coordinatesFile, 'coordinates/words.json');
  });

  group('rejects invalid manifest fields', () {
    test('non-HTTPS download URL', () {
      final json = validJson()..['download_url'] = 'http://example.org/a.zip';
      expect(() => MushafPackManifest.fromJson(json), throwsFormatException);
    });

    test('checksum that is not 64 hexadecimal characters', () {
      final json = validJson()..['sha256'] = 'not-a-checksum';
      expect(() => MushafPackManifest.fromJson(json), throwsFormatException);
    });

    test('page counts outside 1 through 604', () {
      for (final count in <int>[0, 605]) {
        final json = validJson()..['page_count'] = count;
        expect(() => MushafPackManifest.fromJson(json), throwsFormatException);
      }
    });

    test('empty attribution or license', () {
      for (final field in <String>['attribution', 'license']) {
        final json = validJson()..[field] = '   ';
        expect(() => MushafPackManifest.fromJson(json), throwsFormatException);
      }
    });

    test('unsafe or unusable page patterns', () {
      for (final pattern in <String>[
        '../pages/{page}.webp',
        '/pages/{page}.webp',
        r'pages\{page}.webp',
        'pages/page.webp',
        'pages/{page}.png',
      ]) {
        final json = validJson()..['page_file_pattern'] = pattern;
        expect(() => MushafPackManifest.fromJson(json), throwsFormatException);
      }
    });

    test('unsafe optional coordinate path', () {
      final json = validJson()..['coordinates_file'] = '../words.json';
      expect(() => MushafPackManifest.fromJson(json), throwsFormatException);
    });
  });
}
