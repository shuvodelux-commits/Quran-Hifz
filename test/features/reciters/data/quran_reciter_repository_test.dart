import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/reciters/data/quran_reciter_repository.dart';
import 'package:quran_hifz/features/reciters/domain/chapter_reciter.dart';
import 'package:quran_hifz/features/reciters/domain/reciter_catalog_source.dart';
import 'package:quran_hifz/features/reciters/domain/reciter_settings_store.dart';

class _FakeSource implements ReciterCatalogSource {
  _FakeSource(this.rows, {this.error});

  final List<Map<String, dynamic>> rows;
  final Object? error;

  @override
  Future<List<Map<String, dynamic>>> fetchChapterReciters() async {
    if (error != null) throw error!;
    return rows;
  }
}

class _MemorySettings implements ReciterSettingsStore {
  final Map<String, String> values = {};

  @override
  Future<String?> get(String key) async => values[key];

  @override
  Future<void> set(String key, String value) async {
    values[key] = value;
  }
}

Map<String, dynamic> _row(int id, String name) => {
  'id': id,
  'name': name,
  'style': {'name': 'Murattal', 'language_name': 'English'},
  'qirat': {'name': 'Hafs', 'language_name': 'English'},
};

void main() {
  test('refreshes remote catalog and caches validated rows', () async {
    final settings = _MemorySettings();
    final repository = QuranReciterRepository(
      source: _FakeSource([_row(2, 'B'), _row(1, 'A')]),
      settings: settings,
    );

    final result = await repository.loadCatalog();

    expect(result.map((item) => item.id).toList(), [1, 2]);
    final cached =
        jsonDecode(settings.values[QuranReciterRepository.catalogCacheKey]!)
            as List<dynamic>;
    expect(cached.length, 2);
  });

  test('falls back to cached catalog when remote refresh fails', () async {
    final settings = _MemorySettings();
    settings.values[QuranReciterRepository.catalogCacheKey] = jsonEncode([
      const ChapterReciter(
        id: 9,
        name: 'Cached',
        styleName: 'Murattal',
        styleLanguageName: 'English',
        qiratName: 'Hafs',
        qiratLanguageName: 'English',
      ).toJson(),
    ]);

    final repository = QuranReciterRepository(
      source: _FakeSource(const [], error: StateError('offline')),
      settings: settings,
    );

    final result = await repository.loadCatalog();
    expect(result.single.id, 9);
    expect(result.single.name, 'Cached');
  });

  test('rejects duplicate chapter-reciter ids', () async {
    final repository = QuranReciterRepository(
      source: _FakeSource([_row(3, 'First'), _row(3, 'Duplicate')]),
      settings: _MemorySettings(),
    );

    await expectLater(repository.loadCatalog(), throwsFormatException);
  });

  test('selected chapter-reciter id keeps compatibility key', () async {
    final settings = _MemorySettings();
    final repository = QuranReciterRepository(
      source: _FakeSource([_row(5, 'Five')]),
      settings: settings,
    );

    await repository.selectReciter(5);

    expect(settings.values[QuranReciterRepository.selectedReciterKey], '5');
    expect(await repository.loadSelectedReciterId(), 5);
  });
}
