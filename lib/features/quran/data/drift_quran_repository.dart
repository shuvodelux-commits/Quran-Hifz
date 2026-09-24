import 'dart:collection';

import 'package:drift/drift.dart';

import '../../../core/database/quran_content_database.dart';
import '../domain/quran_ayah.dart';
import '../domain/quran_juz.dart';
import '../domain/quran_mushaf_line.dart';
import '../domain/quran_page_window.dart';
import '../domain/quran_repository.dart';
import '../domain/quran_surah.dart';
import '../domain/quran_word.dart';
import '../../study/domain/bookmark.dart';

class DriftQuranRepository implements QuranRepository {
  DriftQuranRepository(this._database);

  static const int firstPage = 1;
  static const int lastPage = 604;

  final QuranContentDatabase _database;
  Future<bool>? _dualScriptSupport;
  Future<bool>? _tajweedSupport;
  Future<bool>? _mushafLineSupport;

  @override
  Future<List<QuranSurahSummary>> listSurahs() async {
    final query = _database.select(_database.surahs)
      ..orderBy([(row) => OrderingTerm.asc(row.number)]);
    final rows = await query.get();

    return rows
        .map(
          (row) => QuranSurahSummary(
            number: row.number,
            nameArabic: row.nameArabic,
            nameEnglish: row.nameEnglish,
            nameBangla: row.nameBangla,
            revelationPlace: row.revelationPlace,
            ayahCount: row.ayahCount,
            pageStart: row.pageStart,
            pageEnd: row.pageEnd,
            juzStart: row.juzStart,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<QuranJuzSummary>> listJuzs() async {
    final rows = await _database
        .customSelect(
          '''
SELECT
  j.juz_number AS juz_number,
  MIN(j.page_number) AS first_page,
  MAX(j.page_number) AS last_page,
  (SELECT a.surah_number FROM ayahs a WHERE a.juz_number = j.juz_number
    ORDER BY a.surah_number, a.ayah_number LIMIT 1) AS first_surah,
  (SELECT a.ayah_number FROM ayahs a WHERE a.juz_number = j.juz_number
    ORDER BY a.surah_number, a.ayah_number LIMIT 1) AS first_ayah,
  (SELECT a.surah_number FROM ayahs a WHERE a.juz_number = j.juz_number
    ORDER BY a.surah_number DESC, a.ayah_number DESC LIMIT 1) AS last_surah,
  (SELECT a.ayah_number FROM ayahs a WHERE a.juz_number = j.juz_number
    ORDER BY a.surah_number DESC, a.ayah_number DESC LIMIT 1) AS last_ayah
FROM ayahs j
GROUP BY j.juz_number
ORDER BY j.juz_number
''',
          readsFrom: {_database.ayahs},
        )
        .get();

    return rows
        .map((row) {
          final firstSurah = row.read<int>('first_surah');
          final lastSurah = row.read<int>('last_surah');
          return QuranJuzSummary(
            number: row.read<int>('juz_number'),
            firstTarget: StudyTarget.ayah(
              surahNumber: firstSurah,
              ayahNumber: row.read<int>('first_ayah'),
            ),
            lastTarget: StudyTarget.ayah(
              surahNumber: lastSurah,
              ayahNumber: row.read<int>('last_ayah'),
            ),
            firstPage: row.read<int>('first_page'),
            lastPage: row.read<int>('last_page'),
            startSurahNumber: firstSurah,
            endSurahNumber: lastSurah,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<QuranAyah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
    required int translationResourceId,
  }) async {
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) {
      return null;
    }

    final hasDualScript = await _hasDualScriptColumns();
    final hasTajweed = await _hasTajweedColumns();
    final rows = await _database
        .customSelect(
          '''
SELECT
  a.surah_number AS surah_number,
  a.ayah_number AS ayah_number,
  a.arabic_text AS arabic_text,
  ${hasDualScript ? 'a.arabic_text_indopak' : 'NULL'} AS arabic_text_indopak,
  ${hasTajweed ? 'a.arabic_text_tajweed' : 'NULL'} AS arabic_text_tajweed,
  a.page_number AS page_number,
  a.juz_number AS juz_number,
  w.position AS word_position,
  w.arabic AS word_arabic,
  ${hasDualScript ? 'w.arabic_indopak' : 'NULL'} AS word_arabic_indopak,
  ${hasTajweed ? 'w.arabic_tajweed' : 'NULL'} AS word_arabic_tajweed,
  w.transliteration AS word_transliteration,
  w.bangla_meaning AS word_bangla_meaning,
  w.english_meaning AS word_english_meaning,
  w.root AS word_root,
  w.lemma AS word_lemma,
  w.grammar AS word_grammar,
  w.audio_remote_path AS word_audio_remote_path,
  t.text AS translation_text
FROM ayahs AS a
LEFT JOIN quran_words AS w
  ON w.surah_number = a.surah_number
 AND w.ayah_number = a.ayah_number
LEFT JOIN translations AS t
  ON t.surah_number = a.surah_number
 AND t.ayah_number = a.ayah_number
 AND t.resource_id = ?
WHERE a.surah_number = ? AND a.ayah_number = ?
ORDER BY w.position ASC
''',
          variables: [
            Variable.withInt(translationResourceId),
            Variable.withInt(surahNumber),
            Variable.withInt(ayahNumber),
          ],
          readsFrom: {
            _database.ayahs,
            _database.quranWords,
            _database.translations,
          },
        )
        .get();

    if (rows.isEmpty) return null;
    final first = rows.first;
    final builder = _AyahBuilder(
      surahNumber: first.read<int>('surah_number'),
      ayahNumber: first.read<int>('ayah_number'),
      arabicText: first.read<String>('arabic_text'),
      arabicTextIndopak: first.readNullable<String>('arabic_text_indopak'),
      arabicTajweedMarkup: first.readNullable<String>('arabic_text_tajweed'),
      pageNumber: first.read<int>('page_number'),
      juzNumber: first.read<int>('juz_number'),
      translation: first.readNullable<String>('translation_text'),
    );

    for (final row in rows) {
      final position = row.readNullable<int>('word_position');
      final arabic = row.readNullable<String>('word_arabic');
      if (position == null || arabic == null) continue;
      builder.words.add(
        QuranWord(
          position: position,
          arabic: arabic,
          arabicIndopak: row.readNullable<String>('word_arabic_indopak'),
          arabicTajweedMarkup: row.readNullable<String>('word_arabic_tajweed'),
          transliteration: row.readNullable<String>('word_transliteration'),
          banglaMeaning: row.readNullable<String>('word_bangla_meaning'),
          englishMeaning: row.readNullable<String>('word_english_meaning'),
          root: row.readNullable<String>('word_root'),
          lemma: row.readNullable<String>('word_lemma'),
          grammar: row.readNullable<String>('word_grammar'),
          audioUrl: row.readNullable<String>('word_audio_remote_path'),
        ),
      );
    }
    return builder.build();
  }

  @override
  Future<QuranPageWindow> loadPageWindow({
    required int page,
    required int translationResourceId,
  }) async {
    if (page < firstPage || page > lastPage) {
      throw RangeError.range(page, firstPage, lastPage, 'page');
    }

    final hasDualScript = await _hasDualScriptColumns();
    final hasTajweed = await _hasTajweedColumns();
    final rows = await _database
        .customSelect(
          '''
SELECT
  a.surah_number AS surah_number,
  a.ayah_number AS ayah_number,
  a.verse_key AS verse_key,
  a.arabic_text AS arabic_text,
  ${hasDualScript ? 'a.arabic_text_indopak' : 'NULL'} AS arabic_text_indopak,
  ${hasTajweed ? 'a.arabic_text_tajweed' : 'NULL'} AS arabic_text_tajweed,
  a.page_number AS page_number,
  a.juz_number AS juz_number,
  w.position AS word_position,
  w.arabic AS word_arabic,
  ${hasDualScript ? 'w.arabic_indopak' : 'NULL'} AS word_arabic_indopak,
  ${hasTajweed ? 'w.arabic_tajweed' : 'NULL'} AS word_arabic_tajweed,
  w.transliteration AS word_transliteration,
  w.bangla_meaning AS word_bangla_meaning,
  w.english_meaning AS word_english_meaning,
  w.root AS word_root,
  w.lemma AS word_lemma,
  w.grammar AS word_grammar,
  w.audio_remote_path AS word_audio_remote_path,
  t.text AS translation_text
FROM ayahs AS a
LEFT JOIN quran_words AS w
  ON w.surah_number = a.surah_number
 AND w.ayah_number = a.ayah_number
LEFT JOIN translations AS t
  ON t.surah_number = a.surah_number
 AND t.ayah_number = a.ayah_number
 AND t.resource_id = ?
WHERE a.page_number = ?
ORDER BY a.surah_number ASC, a.ayah_number ASC, w.position ASC
''',
          variables: [
            Variable.withInt(translationResourceId),
            Variable.withInt(page),
          ],
          readsFrom: {
            _database.ayahs,
            _database.quranWords,
            _database.translations,
          },
        )
        .get();

    final grouped = LinkedHashMap<String, _AyahBuilder>();
    for (final row in rows) {
      final surahNumber = row.read<int>('surah_number');
      final ayahNumber = row.read<int>('ayah_number');
      final key = '$surahNumber:$ayahNumber';

      final builder = grouped.putIfAbsent(
        key,
        () => _AyahBuilder(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          arabicText: row.read<String>('arabic_text'),
          arabicTextIndopak: row.readNullable<String>('arabic_text_indopak'),
          arabicTajweedMarkup: row.readNullable<String>('arabic_text_tajweed'),
          pageNumber: row.read<int>('page_number'),
          juzNumber: row.read<int>('juz_number'),
          translation: row.readNullable<String>('translation_text'),
        ),
      );

      final position = row.readNullable<int>('word_position');
      final arabic = row.readNullable<String>('word_arabic');
      if (position != null && arabic != null) {
        builder.words.add(
          QuranWord(
            position: position,
            arabic: arabic,
            arabicIndopak: row.readNullable<String>('word_arabic_indopak'),
            arabicTajweedMarkup: row.readNullable<String>(
              'word_arabic_tajweed',
            ),
            transliteration: row.readNullable<String>('word_transliteration'),
            banglaMeaning: row.readNullable<String>('word_bangla_meaning'),
            englishMeaning: row.readNullable<String>('word_english_meaning'),
            root: row.readNullable<String>('word_root'),
            lemma: row.readNullable<String>('word_lemma'),
            grammar: row.readNullable<String>('word_grammar'),
            audioUrl: row.readNullable<String>('word_audio_remote_path'),
          ),
        );
      }
    }

    final ayahs = grouped.values
        .map((builder) => builder.build())
        .toList(growable: false);
    final lines = await _loadMushafLines(page: page, ayahs: ayahs);

    return QuranPageWindow(
      page: page,
      ayahs: ayahs,
      previousPage: page > firstPage ? page - 1 : null,
      nextPage: page < lastPage ? page + 1 : null,
      lines: lines,
    );
  }

  Future<List<QuranMushafLine>> _loadMushafLines({
    required int page,
    required List<QuranAyah> ayahs,
  }) async {
    if (!await _hasMushafLinesTable()) return const [];

    final rows = await _database
        .customSelect(
          '''
SELECT
  line_number,
  line_type,
  is_centered,
  surah_number,
  first_word_location,
  last_word_location
FROM mushaf_lines
WHERE page_number = ?
ORDER BY line_number ASC
''',
          variables: [Variable.withInt(page)],
          readsFrom: {_database.mushafLines},
        )
        .get();
    if (rows.isEmpty) return const [];

    final pageLocations = <QuranWordLocation>[
      for (final ayah in ayahs)
        for (final word in ayah.words)
          QuranWordLocation(
            surahNumber: ayah.surahNumber,
            ayahNumber: ayah.ayahNumber,
            position: word.position,
          ),
    ];

    final lines = <QuranMushafLine>[];
    for (final row in rows) {
      try {
        lines.add(
          _mushafLineFromRow(row, page: page, pageLocations: pageLocations),
        );
      } on _UnresolvedMushafLineBoundary catch (error) {
        final firstExists = await _canonicalWordExists(error.first);
        final lastExists = error.first == error.last
            ? firstExists
            : await _canonicalWordExists(error.last);
        if (!firstExists || !lastExists) {
          throw StateError(error.message);
        }

        // Some verified layout lines cross the page assigned to their ayahs.
        // They cannot be rendered from this page window, but Quran content is
        // still complete and must remain readable without the optional line.
      }
    }
    return List<QuranMushafLine>.unmodifiable(lines);
  }

  QuranMushafLine _mushafLineFromRow(
    QueryRow row, {
    required int page,
    required List<QuranWordLocation> pageLocations,
  }) {
    final lineNumber = row.read<int>('line_number');
    final rawType = row.read<String>('line_type');
    final type = switch (rawType) {
      'ayah' => QuranMushafLineType.ayah,
      'surah_name' => QuranMushafLineType.surahName,
      'basmallah' => QuranMushafLineType.bismillah,
      _ => throw StateError(
        'Malformed Mushaf line $page:$lineNumber: unsupported type "$rawType".',
      ),
    };
    final centeredValue = row.read<int>('is_centered');
    if (centeredValue != 0 && centeredValue != 1) {
      throw StateError(
        'Malformed Mushaf line $page:$lineNumber: is_centered must be 0 or 1.',
      );
    }
    final first = row.readNullable<String>('first_word_location');
    final last = row.readNullable<String>('last_word_location');
    final surahNumber = row.readNullable<int>('surah_number');

    if (type != QuranMushafLineType.ayah) {
      if (first != null || last != null) {
        throw StateError(
          'Malformed Mushaf metadata line $page:$lineNumber: word boundaries must be null.',
        );
      }
      return QuranMushafLine(
        lineNumber: lineNumber,
        type: type,
        centered: centeredValue == 1,
        surahNumber: surahNumber,
      );
    }

    if (first == null || last == null) {
      throw StateError(
        'Malformed Mushaf ayah line $page:$lineNumber: both word boundaries are required.',
      );
    }
    final firstLocation = _parseMushafBoundary(
      first,
      page: page,
      lineNumber: lineNumber,
      boundary: 'first',
    );
    final lastLocation = _parseMushafBoundary(
      last,
      page: page,
      lineNumber: lineNumber,
      boundary: 'last',
    );
    final firstIndex = pageLocations.indexOf(firstLocation);
    final lastIndex = pageLocations.indexOf(lastLocation);
    if (firstIndex < 0 || lastIndex < 0) {
      throw _UnresolvedMushafLineBoundary(
        message:
            'Unresolved Mushaf line $page:$lineNumber boundaries: '
            '$first through $last are not canonical page words.',
        first: firstLocation,
        last: lastLocation,
      );
    }
    if (firstIndex > lastIndex) {
      throw StateError(
        'Malformed Mushaf line $page:$lineNumber: first boundary follows last boundary.',
      );
    }
    return QuranMushafLine(
      lineNumber: lineNumber,
      type: type,
      centered: centeredValue == 1,
      surahNumber: surahNumber,
      wordLocations: pageLocations.sublist(firstIndex, lastIndex + 1),
    );
  }

  Future<bool> _canonicalWordExists(QuranWordLocation location) async {
    final row = await _database
        .customSelect(
          '''
SELECT EXISTS(
  SELECT 1
  FROM quran_words
  WHERE surah_number = ? AND ayah_number = ? AND position = ?
) AS word_exists
''',
          variables: [
            Variable.withInt(location.surahNumber),
            Variable.withInt(location.ayahNumber),
            Variable.withInt(location.position),
          ],
          readsFrom: {_database.quranWords},
        )
        .getSingle();
    return row.read<int>('word_exists') == 1;
  }

  QuranWordLocation _parseMushafBoundary(
    String value, {
    required int page,
    required int lineNumber,
    required String boundary,
  }) {
    try {
      return QuranWordLocation.parse(value);
    } on FormatException catch (error) {
      throw StateError(
        'Malformed $boundary Mushaf boundary on line $page:$lineNumber: '
        '${error.message}',
      );
    }
  }

  Future<bool> _hasMushafLinesTable() {
    return _mushafLineSupport ??= _detectMushafLinesTable();
  }

  Future<bool> _detectMushafLinesTable() async {
    final row = await _database.customSelect('''
SELECT EXISTS(
  SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'mushaf_lines'
) AS has_mushaf_lines
''').getSingle();
    return row.read<int>('has_mushaf_lines') == 1;
  }

  Future<bool> _hasTajweedColumns() {
    return _tajweedSupport ??= _detectTajweedColumns();
  }

  Future<bool> _detectTajweedColumns() async {
    final ayahColumns = await _database
        .customSelect('PRAGMA table_info(ayahs)')
        .get();
    final wordColumns = await _database
        .customSelect('PRAGMA table_info(quran_words)')
        .get();
    final ayahNames = ayahColumns
        .map((row) => row.read<String>('name'))
        .toSet();
    final wordNames = wordColumns
        .map((row) => row.read<String>('name'))
        .toSet();
    return ayahNames.contains('arabic_text_tajweed') &&
        wordNames.contains('arabic_tajweed');
  }

  Future<bool> _hasDualScriptColumns() {
    return _dualScriptSupport ??= _detectDualScriptColumns();
  }

  Future<bool> _detectDualScriptColumns() async {
    final ayahColumns = await _database
        .customSelect('PRAGMA table_info(ayahs)')
        .get();
    final wordColumns = await _database
        .customSelect('PRAGMA table_info(quran_words)')
        .get();
    final ayahNames = ayahColumns
        .map((row) => row.read<String>('name'))
        .toSet();
    final wordNames = wordColumns
        .map((row) => row.read<String>('name'))
        .toSet();
    return ayahNames.contains('arabic_text_indopak') &&
        wordNames.contains('arabic_indopak');
  }
}

class _UnresolvedMushafLineBoundary implements Exception {
  const _UnresolvedMushafLineBoundary({
    required this.message,
    required this.first,
    required this.last,
  });

  final String message;
  final QuranWordLocation first;
  final QuranWordLocation last;
}

class _AyahBuilder {
  _AyahBuilder({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.arabicTextIndopak,
    required this.arabicTajweedMarkup,
    required this.pageNumber,
    required this.juzNumber,
    required this.translation,
  });

  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String? arabicTextIndopak;
  final String? arabicTajweedMarkup;
  final int pageNumber;
  final int juzNumber;
  final String? translation;
  final List<QuranWord> words = [];

  QuranAyah build() => QuranAyah(
    surahNumber: surahNumber,
    ayahNumber: ayahNumber,
    arabicText: arabicText,
    arabicTextIndopak: arabicTextIndopak,
    arabicTajweedMarkup: arabicTajweedMarkup,
    pageNumber: pageNumber,
    juzNumber: juzNumber,
    words: List.unmodifiable(words),
    translation: translation,
  );
}
