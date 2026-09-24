import 'dart:convert';

import '../domain/chapter_reciter.dart';
import '../domain/reciter_catalog_source.dart';
import '../domain/reciter_repository.dart';
import '../domain/reciter_settings_store.dart';

class QuranReciterRepository implements ReciterRepository {
  QuranReciterRepository({
    required ReciterCatalogSource source,
    required ReciterSettingsStore settings,
  }) : _source = source,
       _settings = settings;

  static const selectedReciterKey = 'selected_reciter_id';
  static const catalogCacheKey = 'chapter_reciter_catalog_json';

  final ReciterCatalogSource _source;
  final ReciterSettingsStore _settings;

  @override
  Future<List<ChapterReciter>> loadCatalog() async {
    try {
      final rows = await _source.fetchChapterReciters();
      final parsed = rows.map(ChapterReciter.fromJson).toList(growable: false)
        ..sort((a, b) => a.id.compareTo(b.id));
      _validateCatalog(parsed);

      await _settings.set(
        catalogCacheKey,
        jsonEncode(parsed.map((item) => item.toJson()).toList(growable: false)),
      );
      return parsed;
    } catch (error) {
      final cached = await _settings.get(catalogCacheKey);
      if (cached == null || cached.trim().isEmpty) rethrow;

      try {
        final decoded = jsonDecode(cached);
        if (decoded is! List) rethrow;
        final parsed =
            decoded
                .map(
                  (row) => ChapterReciter.fromJson(
                    Map<String, dynamic>.from(row as Map),
                  ),
                )
                .toList(growable: false)
              ..sort((a, b) => a.id.compareTo(b.id));
        _validateCatalog(parsed);
        return parsed;
      } catch (_) {
        throw error;
      }
    }
  }

  @override
  Future<int?> loadSelectedReciterId() async {
    final raw = await _settings.get(selectedReciterKey);
    if (raw == null) return null;
    final id = int.tryParse(raw);
    return id != null && id > 0 ? id : null;
  }

  @override
  Future<void> clearSelectedReciter() => _settings.set(selectedReciterKey, '');

  @override
  Future<void> selectReciter(int id) {
    if (id <= 0) throw ArgumentError.value(id, 'id');
    return _settings.set(selectedReciterKey, id.toString());
  }

  static void _validateCatalog(List<ChapterReciter> reciters) {
    if (reciters.isEmpty) {
      throw const FormatException('Chapter-reciter catalog is empty.');
    }
    final ids = <int>{};
    for (final reciter in reciters) {
      if (!ids.add(reciter.id)) {
        throw FormatException('Duplicate chapter-reciter id: ${reciter.id}.');
      }
    }
  }
}
