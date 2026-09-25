import '../../../core/network/quran_backend_client.dart';
import '../domain/tafsir_entry.dart';
import '../domain/tafsir_repository.dart';
import 'tafsir_text_normalizer.dart';

class RemoteQuranFoundationTafsirRepository implements TafsirRepository {
  RemoteQuranFoundationTafsirRepository(this._client);

  static const _version = 'quran-foundation-v4';

  final QuranTafsirBackendClient _client;

  @override
  Future<List<TafsirSource>> listInstalledSources() async {
    final rows = await _client.getTafsirResources(language: 'bn');
    return List.unmodifiable(rows.map(_sourceFromJson));
  }

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final resourceId = _resourceId(sourceId);
    if (resourceId == null ||
        surahNumber < 1 ||
        surahNumber > 114 ||
        ayahNumber < 1) {
      return null;
    }
    final row = await _client.getTafsirAyah(
      resourceId: resourceId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    if (row == null) return null;
    return _entryFromJson(
      sourceId: sourceId,
      expectedResourceId: resourceId,
      expectedSurahNumber: surahNumber,
      expectedAyahNumber: ayahNumber,
      row: row,
    );
  }

  @override
  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async {
    final resourceId = _resourceId(sourceId);
    if (resourceId == null || surahNumber < 1 || surahNumber > 114) {
      return const [];
    }
    final rows = await _client.getTafsirSurah(
      resourceId: resourceId,
      surahNumber: surahNumber,
    );
    final entries = <TafsirEntry>[];
    for (final row in rows) {
      final ayahNumber = _ayahNumber(row);
      entries.add(
        _entryFromJson(
          sourceId: sourceId,
          expectedResourceId: resourceId,
          expectedSurahNumber: surahNumber,
          expectedAyahNumber: ayahNumber,
          row: row,
        ),
      );
    }
    entries.sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));
    return List.unmodifiable(entries);
  }

  TafsirSource _sourceFromJson(Map<String, dynamic> row) {
    final id = row['id'];
    final rawName = row['name'];
    if (id is! int || id <= 0 || rawName is! String || rawName.trim().isEmpty) {
      throw const FormatException('Invalid Quran Foundation Tafsir resource.');
    }

    final translatedName = row['translated_name'];
    String? localizedName;
    if (translatedName is Map) {
      final value = translatedName['name'];
      if (value is String && value.trim().isNotEmpty) {
        localizedName = value.trim();
      }
    }

    final author = row['author_name'];
    final language = row['language_name'];

    return TafsirSource(
      sourceId: 'qf.$id',
      name: localizedName ?? rawName.trim(),
      language: language is String && language.trim().isNotEmpty
          ? language.trim()
          : 'unknown',
      version: _version,
      attribution: author is String && author.trim().isNotEmpty
          ? 'Quran Foundation · ${author.trim()}'
          : 'Quran Foundation Content API',
      kind: TafsirSourceKind.remote,
      availableOffline: false,
    );
  }

  TafsirEntry _entryFromJson({
    required String sourceId,
    required int expectedResourceId,
    required int expectedSurahNumber,
    required int expectedAyahNumber,
    required Map<String, dynamic> row,
  }) {
    final resourceId = row['resource_id'];
    final verseKey = row['verse_key'];
    final text = row['text'];
    if (resourceId != expectedResourceId ||
        verseKey is! String ||
        verseKey != '$expectedSurahNumber:$expectedAyahNumber' ||
        text is! String) {
      throw const FormatException('Invalid Quran Foundation Tafsir entry.');
    }

    final sourceName = row['resource_name'];
    final language = row['language_name'];
    return TafsirEntry(
      sourceId: sourceId,
      sourceName: sourceName is String && sourceName.trim().isNotEmpty
          ? sourceName.trim()
          : 'Quran Foundation Tafsir',
      language: language is String && language.trim().isNotEmpty
          ? language.trim()
          : 'unknown',
      version: _version,
      surahNumber: expectedSurahNumber,
      ayahNumber: expectedAyahNumber,
      text: plainTafsirText(text),
      attribution: 'Quran Foundation Content API',
    );
  }
}

int? _resourceId(String sourceId) {
  if (!sourceId.startsWith('qf.')) return null;
  final value = int.tryParse(sourceId.substring(3));
  return value != null && value > 0 ? value : null;
}

int _ayahNumber(Map<String, dynamic> row) {
  final direct = row['verse_number'];
  if (direct is int && direct > 0) return direct;

  final verseKey = row['verse_key'];
  if (verseKey is String) {
    final parts = verseKey.split(':');
    if (parts.length == 2) {
      final parsed = int.tryParse(parts[1]);
      if (parsed != null && parsed > 0) return parsed;
    }
  }
  throw const FormatException(
    'Quran Foundation Tafsir entry has no ayah number.',
  );
}
