import 'package:drift/drift.dart';

import '../../../core/database/quran_content_database.dart';
import '../../quran/domain/quran_ayah.dart';
import '../../quran/domain/quran_surah.dart';
import '../domain/bookmark.dart';
import '../domain/bookmark_display_item.dart';
import '../domain/bookmark_display_repository.dart';

class DriftBookmarkDisplayRepository implements BookmarkDisplayRepository {
  DriftBookmarkDisplayRepository(this._database);

  final QuranContentDatabase _database;

  @override
  Future<List<BookmarkDisplayItem>> loadItems(
    List<Bookmark> bookmarks, {
    required int translationResourceId,
  }) async {
    if (bookmarks.isEmpty) return const [];
    final unique = <String, Bookmark>{};
    for (final bookmark in bookmarks) {
      unique['${bookmark.target.surahNumber}:${bookmark.target.ayahNumber}'] =
          bookmark;
    }
    final contexts = <String, ({QuranSurahSummary surah, QuranAyah ayah})>{};
    final targets = unique.values.toList(growable: false);
    for (var offset = 0; offset < targets.length; offset += 200) {
      final chunk = targets.sublist(
        offset,
        (offset + 200).clamp(0, targets.length),
      );
      final clauses = List.filled(
        chunk.length,
        '(a.surah_number = ? AND a.ayah_number = ?)',
      ).join(' OR ');
      final variables = <Variable<Object>>[
        Variable<int>(translationResourceId),
        for (final bookmark in chunk) ...[
          Variable<int>(bookmark.target.surahNumber),
          Variable<int>(bookmark.target.ayahNumber),
        ],
      ];
      final rows = await _database
          .customSelect(
            '''
SELECT
  a.surah_number AS surah_number,
  a.ayah_number AS ayah_number,
  a.arabic_text AS arabic_text,
  a.page_number AS page_number,
  a.juz_number AS juz_number,
  t.text AS translation_text,
  s.name_arabic AS name_arabic,
  s.name_english AS name_english,
  s.name_bangla AS name_bangla,
  s.revelation_place AS revelation_place,
  s.ayah_count AS ayah_count,
  s.page_start AS page_start,
  s.page_end AS page_end,
  s.juz_start AS juz_start
FROM ayahs a
JOIN surahs s ON s.number = a.surah_number
LEFT JOIN translations t
  ON t.surah_number = a.surah_number
 AND t.ayah_number = a.ayah_number
 AND t.resource_id = ?
WHERE $clauses
''',
            variables: variables,
            readsFrom: {
              _database.ayahs,
              _database.surahs,
              _database.translations,
            },
          )
          .get();
      for (final row in rows) {
        final surahNumber = row.read<int>('surah_number');
        final ayahNumber = row.read<int>('ayah_number');
        contexts['$surahNumber:$ayahNumber'] = (
          surah: QuranSurahSummary(
            number: surahNumber,
            nameArabic: row.read<String>('name_arabic'),
            nameEnglish: row.read<String>('name_english'),
            nameBangla: row.readNullable<String>('name_bangla'),
            revelationPlace: row.readNullable<String>('revelation_place'),
            ayahCount: row.read<int>('ayah_count'),
            pageStart: row.read<int>('page_start'),
            pageEnd: row.read<int>('page_end'),
            juzStart: row.read<int>('juz_start'),
          ),
          ayah: QuranAyah(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            arabicText: row.read<String>('arabic_text'),
            pageNumber: row.read<int>('page_number'),
            juzNumber: row.read<int>('juz_number'),
            translation: row.readNullable<String>('translation_text'),
            words: const [],
          ),
        );
      }
    }
    return [
      for (final bookmark in bookmarks)
        BookmarkDisplayItem(
          bookmark: bookmark,
          surah:
              contexts['${bookmark.target.surahNumber}:${bookmark.target.ayahNumber}']
                  ?.surah,
          ayah:
              contexts['${bookmark.target.surahNumber}:${bookmark.target.ayahNumber}']
                  ?.ayah,
        ),
    ];
  }
}
