import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/reciters/data/bundled_reciter_catalog_source.dart';

void main() {
  test('loads validated reciters from the bundled catalog', () async {
    final source = BundledReciterCatalogSource(
      bundle: _MapAssetBundle({
        BundledReciterCatalogSource.defaultAssetPath: jsonEncode({
          'schema_version': 1,
          'source_name': 'Quran Foundation Content API v4',
          'source_version': 'test',
          'generated_at_utc': '2026-09-13T00:00:00.000Z',
          'reciters': [
            {
              'id': 7,
              'name': 'Seven',
              'style': {'name': 'Murattal', 'language_name': 'English'},
              'qirat': {'name': 'Hafs', 'language_name': 'English'},
            },
          ],
        }),
      }),
    );

    final rows = await source.fetchChapterReciters();

    expect(rows.single['id'], 7);
    expect(rows.single['name'], 'Seven');
  });

  test('accepts nullable style and qirat language metadata', () async {
    final source = BundledReciterCatalogSource(
      bundle: _MapAssetBundle({
        BundledReciterCatalogSource.defaultAssetPath: jsonEncode({
          'schema_version': 1,
          'source_name': 'Quran Foundation Content API v4',
          'source_version': 'test',
          'generated_at_utc': '2026-09-13T00:00:00.000Z',
          'reciters': [
            {
              'id': 7,
              'name': 'Seven',
              'style': {'name': null, 'language_name': null},
              'qirat': {'name': null, 'language_name': null},
            },
          ],
        }),
      }),
    );

    final rows = await source.fetchChapterReciters();

    expect((rows.single['style'] as Map)['language_name'], isNull);
    expect((rows.single['qirat'] as Map)['language_name'], isNull);
  });

  test('rejects malformed JSON', () async {
    final source = BundledReciterCatalogSource(
      bundle: _MapAssetBundle({
        BundledReciterCatalogSource.defaultAssetPath: '{not-json',
      }),
    );

    await expectLater(source.fetchChapterReciters(), throwsFormatException);
  });

  test('rejects unsupported schema version', () async {
    final source = BundledReciterCatalogSource(
      bundle: _MapAssetBundle({
        BundledReciterCatalogSource.defaultAssetPath: jsonEncode({
          'schema_version': 2,
          'source_name': 'Quran Foundation Content API v4',
          'source_version': 'test',
          'generated_at_utc': '2026-09-13T00:00:00.000Z',
          'reciters': [],
        }),
      }),
    );

    await expectLater(source.fetchChapterReciters(), throwsFormatException);
  });

  test('rejects duplicate reciter ids', () async {
    Map<String, dynamic> row(String name) => {
      'id': 7,
      'name': name,
      'style': {'name': 'Murattal', 'language_name': 'English'},
      'qirat': {'name': 'Hafs', 'language_name': 'English'},
    };
    final source = BundledReciterCatalogSource(
      bundle: _MapAssetBundle({
        BundledReciterCatalogSource.defaultAssetPath: jsonEncode({
          'schema_version': 1,
          'source_name': 'Quran Foundation Content API v4',
          'source_version': 'test',
          'generated_at_utc': '2026-09-13T00:00:00.000Z',
          'reciters': [row('A'), row('B')],
        }),
      }),
    );

    await expectLater(source.fetchChapterReciters(), throwsFormatException);
  });
}

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) {
      throw FlutterError('Missing fake asset: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.sublistView(bytes);
  }
}
