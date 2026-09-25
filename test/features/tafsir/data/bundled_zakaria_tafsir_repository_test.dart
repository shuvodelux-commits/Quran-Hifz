import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/tafsir/data/bundled_zakaria_tafsir_repository.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_catalog.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_entry.dart';

void main() {
  test('lists bundled Zakaria without any installed package', () async {
    final bundle = _bundle(
      entries: const [
        {'ayah_number': 1, 'translation': 'অনুবাদ', 'footnotes': 'তাফসীর'},
      ],
    );
    final repository = BundledZakariaTafsirRepository(bundle);

    final sources = await repository.listInstalledSources();

    expect(sources, hasLength(1));
    expect(sources.single.sourceId, primaryBanglaTafsirSourceId);
    expect(sources.single.kind, TafsirSourceKind.bundled);
    expect(sources.single.availableOffline, isTrue);
  });

  test(
    'combines translation and footnotes using shared normalization',
    () async {
      final repository = BundledZakariaTafsirRepository(
        _bundle(
          entries: const [
            {
              'ayah_number': 1,
              'translation': '<b>অনুবাদ</b><br>দ্বিতীয়',
              'footnotes': '<p>তাফসীর &amp; ব্যাখ্যা</p>',
            },
            {'ayah_number': 2, 'translation': 'শুধু অনুবাদ', 'footnotes': ''},
          ],
        ),
      );

      final first = await repository.readAyah(
        sourceId: primaryBanglaTafsirSourceId,
        surahNumber: 1,
        ayahNumber: 1,
      );
      final surah = await repository.readSurah(
        sourceId: primaryBanglaTafsirSourceId,
        surahNumber: 1,
      );

      expect(first?.text, 'অনুবাদ\nদ্বিতীয়\n\nতাফসীর & ব্যাখ্যা');
      expect(surah.map((entry) => entry.ayahNumber), [1, 2]);
      expect(surah[1].text, 'শুধু অনুবাদ');
    },
  );

  test('rejects a corrupt bundled Surah hash', () async {
    final assets = _assetMap(
      entries: const [
        {'ayah_number': 1, 'translation': 'অনুবাদ', 'footnotes': ''},
      ],
    );
    assets['assets/tafsir/zakaria/1.1.1/001.json.gz'] = Uint8List.fromList([
      1,
      2,
      3,
    ]);
    final repository = BundledZakariaTafsirRepository(
      _MemoryAssetBundle(assets),
    );

    expect(
      () => repository.readSurah(
        sourceId: primaryBanglaTafsirSourceId,
        surahNumber: 1,
      ),
      throwsA(isA<BundledTafsirIntegrityException>()),
    );
  });
}

AssetBundle _bundle({required List<Map<String, Object>> entries}) =>
    _MemoryAssetBundle(_assetMap(entries: entries));

Map<String, Uint8List> _assetMap({required List<Map<String, Object>> entries}) {
  const root = 'assets/tafsir/zakaria/1.1.1';
  final payload = utf8.encode(
    jsonEncode({
      'source_id': primaryBanglaTafsirSourceId,
      'version': '1.1.1',
      'surah_number': 1,
      'entries': entries,
    }),
  );
  final compressed = Uint8List.fromList(gzip.encode(payload));
  final manifest = utf8.encode(
    jsonEncode({
      'source_id': primaryBanglaTafsirSourceId,
      'name': 'তাফসীরে আবু বকর যাকারিয়া',
      'language': 'bn',
      'version': '1.1.1',
      'attribution': 'Attribution',
      'license': 'License',
      'total_entries': entries.length,
      'surah_count': 1,
      'surahs': {
        '1': {
          'asset': '001.json.gz',
          'ayah_count': entries.length,
          'sha256': sha256.convert(compressed).toString(),
          'size_bytes': compressed.length,
        },
      },
    }),
  );
  return {
    '$root/manifest.json': Uint8List.fromList(manifest),
    '$root/001.json.gz': compressed,
  };
}

class _MemoryAssetBundle extends CachingAssetBundle {
  _MemoryAssetBundle(this.assets);

  final Map<String, Uint8List> assets;

  @override
  Future<ByteData> load(String key) async {
    final bytes = assets[key];
    if (bytes == null) throw StateError('Missing asset: $key');
    return ByteData.sublistView(bytes);
  }
}
