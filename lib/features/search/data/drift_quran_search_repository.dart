import 'package:drift/drift.dart';

import '../../../core/database/quran_content_database.dart';
import '../domain/quran_search_repository.dart';
import '../domain/quran_search_result.dart';

class DriftQuranSearchRepository implements QuranSearchRepository {
  DriftQuranSearchRepository(this._database);

  final QuranContentDatabase _database;

  static final RegExp _verseReference = RegExp(r'^(\d{1,3}):(\d{1,3})$');
  static final RegExp _surahNumber = RegExp(r'^\d{1,3}$');

  @override
  Future<List<QuranSearchResult>> search(
    String query, {
    required int translationResourceId,
    int limit = 50,
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty || limit <= 0) return const [];

    final reference = _verseReference.firstMatch(normalized);
    if (reference != null) {
      final surah = int.parse(reference.group(1)!);
      final ayah = int.parse(reference.group(2)!);
      final result = await _findExactAyah(surah, ayah, translationResourceId);
      return result == null ? const [] : [result];
    }

    if (_surahNumber.hasMatch(normalized)) {
      final number = int.parse(normalized);
      final result = await _findSurahByNumber(number);
      return result == null ? const [] : [result];
    }

    final results = <QuranSearchResult>[];
    results.addAll(await _findSurahsByName(normalized, limit));
    if (results.length < limit) {
      results.addAll(
        await _findTranslationMatches(
          normalized,
          translationResourceId,
          limit - results.length,
        ),
      );
    }
    return List.unmodifiable(results);
  }

  Future<QuranSearchResult?> _findExactAyah(
    int surahNumber,
    int ayahNumber,
    int translationResourceId,
  ) async {
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) return null;
    final row = await _database
        .customSelect(
          '''
SELECT
  a.surah_number,
  a.ayah_number,
  a.verse_key,
  a.arabic_text,
  a.page_number,
  t.text AS translation_text
FROM ayahs AS a
LEFT JOIN translations AS t
  ON t.surah_number = a.surah_number
 AND t.ayah_number = a.ayah_number
 AND t.resource_id = ?
WHERE a.surah_number = ? AND a.ayah_number = ?
LIMIT 1
''',
          variables: [
            Variable.withInt(translationResourceId),
            Variable.withInt(surahNumber),
            Variable.withInt(ayahNumber),
          ],
          readsFrom: {_database.ayahs, _database.translations},
        )
        .getSingleOrNull();
    if (row == null) return null;
    return QuranSearchResult(
      type: QuranSearchResultType.ayah,
      surahNumber: row.read<int>('surah_number'),
      ayahNumber: row.read<int>('ayah_number'),
      pageNumber: row.read<int>('page_number'),
      verseKey: row.read<String>('verse_key'),
      title: row.read<String>('arabic_text'),
      matchText: row.readNullable<String>('translation_text'),
    );
  }

  Future<QuranSearchResult?> _findSurahByNumber(int number) async {
    if (number < 1 || number > 114) return null;
    final row = await (_database.select(
      _database.surahs,
    )..where((surah) => surah.number.equals(number))).getSingleOrNull();
    if (row == null) return null;
    return _surahResult(row);
  }

  Future<List<QuranSearchResult>> _findSurahsByName(
    String query,
    int limit,
  ) async {
    final pattern = '%${_escapeLike(query)}%';
    final rows = await _database
        .customSelect(
          '''
SELECT number, name_arabic, name_english, name_bangla, page_start
FROM surahs
WHERE name_arabic LIKE ? ESCAPE '\\'
   OR name_english LIKE ? ESCAPE '\\' COLLATE NOCASE
   OR name_bangla LIKE ? ESCAPE '\\'
ORDER BY number ASC
LIMIT ?
''',
          variables: [
            Variable.withString(pattern),
            Variable.withString(pattern),
            Variable.withString(pattern),
            Variable.withInt(limit),
          ],
          readsFrom: {_database.surahs},
        )
        .get();
    return rows
        .map(
          (row) => QuranSearchResult(
            type: QuranSearchResultType.surah,
            surahNumber: row.read<int>('number'),
            pageNumber: row.read<int>('page_start'),
            title: row.read<String>('name_arabic'),
            subtitle: [
              row.read<String>('name_english'),
              row.readNullable<String>('name_bangla'),
            ].whereType<String>().join(' · '),
          ),
        )
        .toList(growable: false);
  }

  Future<List<QuranSearchResult>> _findTranslationMatches(
    String query,
    int translationResourceId,
    int limit,
  ) async {
    if (limit <= 0) return const [];
    final pattern = '%${_escapeLike(query)}%';
    final rows = await _database
        .customSelect(
          '''
SELECT
  a.surah_number,
  a.ayah_number,
  a.verse_key,
  a.arabic_text,
  a.page_number,
  t.text AS translation_text
FROM translations AS t
JOIN ayahs AS a
  ON a.surah_number = t.surah_number
 AND a.ayah_number = t.ayah_number
WHERE t.resource_id = ?
  AND t.text LIKE ? ESCAPE '\\'
ORDER BY a.surah_number ASC, a.ayah_number ASC
LIMIT ?
''',
          variables: [
            Variable.withInt(translationResourceId),
            Variable.withString(pattern),
            Variable.withInt(limit),
          ],
          readsFrom: {_database.translations, _database.ayahs},
        )
        .get();
    return rows
        .map(
          (row) => QuranSearchResult(
            type: QuranSearchResultType.ayah,
            surahNumber: row.read<int>('surah_number'),
            ayahNumber: row.read<int>('ayah_number'),
            pageNumber: row.read<int>('page_number'),
            verseKey: row.read<String>('verse_key'),
            title: row.read<String>('arabic_text'),
            matchText: row.read<String>('translation_text'),
          ),
        )
        .toList(growable: false);
  }

  QuranSearchResult _surahResult(Surah row) {
    return QuranSearchResult(
      type: QuranSearchResultType.surah,
      surahNumber: row.number,
      pageNumber: row.pageStart,
      title: row.nameArabic,
      subtitle: [
        row.nameEnglish,
        row.nameBangla,
      ].whereType<String>().join(' · '),
    );
  }

  String _escapeLike(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
  }
}
