import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

const expectedQpcWordCount = 77432;
const expectedQpcEndCount = 6236;
const expectedQpcTotalCount = 83668;
const expectedMushafPageCount = 604;
const expectedMushafLinesPerPage = 15;
const allowedMushafLineTypes = <String>{'ayah', 'basmallah', 'surah_name'};

class MushafLayoutValidationResult {
  const MushafLayoutValidationResult({
    required this.name,
    required this.fontName,
    required this.pageCount,
    required this.linesPerPage,
    required this.lineTypes,
  });

  final String name;
  final String? fontName;
  final int pageCount;
  final int linesPerPage;
  final Set<String> lineTypes;
}

class QpcV4ScriptValidationResult {
  const QpcV4ScriptValidationResult({
    required this.wordCount,
    required this.endCount,
    required this.totalCount,
    required this.pageCount,
  });

  final int wordCount;
  final int endCount;
  final int totalCount;
  final int pageCount;
}

class QcfV2AssetValidationResult {
  const QcfV2AssetValidationResult({
    required this.pageCount,
    required this.tokenCount,
  });

  final int pageCount;
  final int tokenCount;
}

class Page440TransitionValidationResult {
  const Page440TransitionValidationResult({
    required this.surahNumber,
    required this.surahLine,
    required this.bismillahLine,
    required this.firstAyahLine,
  });

  final int surahNumber;
  final int surahLine;
  final int bismillahLine;
  final int firstAyahLine;
}

class MushafAssetValidationResult {
  const MushafAssetValidationResult({
    required this.qcfV4Layout,
    required this.qcfV4Script,
    required this.qcfV2,
    required this.page440,
  });

  final MushafLayoutValidationResult qcfV4Layout;
  final QpcV4ScriptValidationResult qcfV4Script;
  final QcfV2AssetValidationResult? qcfV2;
  final Page440TransitionValidationResult page440;
}

Future<MushafLayoutValidationResult> validateLayout(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    throw FormatException('Mushaf layout not found: ' + path);
  }
  final db = sqlite3.open(path, mode: OpenMode.readOnly);
  try {
    final infoRows = db.select(
      'SELECT name, number_of_pages, lines_per_page, font_name FROM info LIMIT 1',
    );
    if (infoRows.isEmpty) {
      throw const FormatException('Mushaf layout info row is missing.');
    }
    final info = infoRows.first;
    final declaredPages = _asInt(info['number_of_pages'], 'number_of_pages');
    final linesPerPage = _asInt(info['lines_per_page'], 'lines_per_page');
    if (declaredPages != expectedMushafPageCount) {
      throw FormatException(
        'Mushaf layout declares ' +
            declaredPages.toString() +
            ' pages; expected 604.',
      );
    }
    if (linesPerPage != expectedMushafLinesPerPage) {
      throw FormatException(
        'Mushaf layout declares ' +
            linesPerPage.toString() +
            ' lines per page; expected 15.',
      );
    }

    final pageStats = db.select('''
      SELECT
        COUNT(DISTINCT page_number) AS page_count,
        MIN(page_number) AS min_page,
        MAX(page_number) AS max_page
      FROM pages
    ''').first;
    final pageCount = _asInt(pageStats['page_count'], 'page_count');
    final minPage = _asInt(pageStats['min_page'], 'min_page');
    final maxPage = _asInt(pageStats['max_page'], 'max_page');
    if (pageCount != expectedMushafPageCount ||
        minPage != 1 ||
        maxPage != expectedMushafPageCount) {
      throw const FormatException(
        'Mushaf layout must contain every page from 1 through 604.',
      );
    }

    final lineTypeRows = db.select(
      'SELECT DISTINCT line_type FROM pages ORDER BY line_type',
    );
    final lineTypes = <String>{
      for (final row in lineTypeRows)
        if (row['line_type'] != null) row['line_type'].toString(),
    };
    if (lineTypes.isEmpty ||
        lineTypes.any((type) => !allowedMushafLineTypes.contains(type))) {
      throw FormatException(
        'Mushaf layout contains unsupported line types: ' +
            lineTypes.join(', '),
      );
    }

    final invalidLine = db.select('''
      SELECT page_number, line_number
      FROM pages
      WHERE line_number < 1 OR line_number > 15
      LIMIT 1
    ''');
    if (invalidLine.isNotEmpty) {
      throw const FormatException('Mushaf line_number must be in 1..15.');
    }

    final invalidAyahRange = db.select('''
      SELECT page_number, line_number
      FROM pages
      WHERE line_type = 'ayah'
        AND (
          first_word_id IS NULL OR
          last_word_id IS NULL OR
          first_word_id > last_word_id
        )
      LIMIT 1
    ''');
    if (invalidAyahRange.isNotEmpty) {
      throw const FormatException(
        'Mushaf ayah line has an invalid word range.',
      );
    }

    return MushafLayoutValidationResult(
      name: info['name']?.toString() ?? '',
      fontName: info['font_name']?.toString(),
      pageCount: pageCount,
      linesPerPage: linesPerPage,
      lineTypes: Set.unmodifiable(lineTypes),
    );
  } on SqliteException catch (error) {
    throw FormatException('Invalid Mushaf layout database: ' + error.message);
  } finally {
    db.close();
  }
}

Future<QpcV4ScriptValidationResult> validateQpcV4Script(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    throw FormatException('QPC V4 script database not found: ' + path);
  }
  final db = sqlite3.open(path, mode: OpenMode.readOnly);
  try {
    final stats = db.select('''
      SELECT
        SUM(CASE WHEN char_type = 'word' THEN 1 ELSE 0 END) AS word_count,
        SUM(CASE WHEN char_type = 'end' THEN 1 ELSE 0 END) AS end_count,
        COUNT(*) AS total_count,
        COUNT(DISTINCT page_number) AS page_count
      FROM words
    ''').first;
    final result = QpcV4ScriptValidationResult(
      wordCount: _asInt(stats['word_count'], 'word_count'),
      endCount: _asInt(stats['end_count'], 'end_count'),
      totalCount: _asInt(stats['total_count'], 'total_count'),
      pageCount: _asInt(stats['page_count'], 'page_count'),
    );
    if (result.wordCount != expectedQpcWordCount ||
        result.endCount != expectedQpcEndCount ||
        result.totalCount != expectedQpcTotalCount ||
        result.pageCount != expectedMushafPageCount) {
      throw const FormatException('QPC V4 script integrity check failed.');
    }

    final indexStats = db.select('''
      SELECT
        MIN(word_index) AS min_index,
        MAX(word_index) AS max_index,
        COUNT(DISTINCT word_index) AS distinct_count
      FROM words
    ''').first;
    if (_asInt(indexStats['min_index'], 'min_index') != 1 ||
        _asInt(indexStats['max_index'], 'max_index') != expectedQpcTotalCount ||
        _asInt(indexStats['distinct_count'], 'distinct_count') !=
            expectedQpcTotalCount) {
      throw const FormatException(
        'QPC V4 local word_index sequence is not contiguous.',
      );
    }
    return result;
  } on SqliteException catch (error) {
    throw FormatException('Invalid QPC V4 script database: ' + error.message);
  } finally {
    db.close();
  }
}

Future<MushafAssetValidationResult> validateMushafAssets({
  required String qcfV4LayoutPath,
  required String qcfV4ScriptPath,
  String? qcfV2LayoutPath,
  String? qcfV2ScriptPath,
}) async {
  final qcfV4Layout = await validateLayout(qcfV4LayoutPath);
  final qcfV4Script = await validateQpcV4Script(qcfV4ScriptPath);
  _validateQpcLayoutRanges(
    layoutPath: qcfV4LayoutPath,
    scriptPath: qcfV4ScriptPath,
  );
  final page440 = await validatePage440Transition(layoutPath: qcfV4LayoutPath);

  QcfV2AssetValidationResult? qcfV2;
  final hasQcfV2Layout =
      qcfV2LayoutPath != null && File(qcfV2LayoutPath).existsSync();
  final hasQcfV2Script =
      qcfV2ScriptPath != null && File(qcfV2ScriptPath).existsSync();
  if (hasQcfV2Layout != hasQcfV2Script) {
    throw const FormatException(
      'QCF V2 validation requires both layout and script assets.',
    );
  }
  if (hasQcfV2Layout && hasQcfV2Script) {
    qcfV2 = validateQcfV2Assets(
      layoutPath: qcfV2LayoutPath,
      scriptPath: qcfV2ScriptPath,
    );
  }

  return MushafAssetValidationResult(
    qcfV4Layout: qcfV4Layout,
    qcfV4Script: qcfV4Script,
    qcfV2: qcfV2,
    page440: page440,
  );
}

Future<Page440TransitionValidationResult> validatePage440Transition({
  required String layoutPath,
}) async {
  final db = sqlite3.open(layoutPath, mode: OpenMode.readOnly);
  try {
    final rows = db.select('''
      SELECT line_number, line_type, surah_number
      FROM pages
      WHERE page_number = 440
      ORDER BY line_number
    ''');
    if (rows.length != 15) {
      throw const FormatException('QCF V4 page 440 must contain 15 lines.');
    }

    final surahRows = rows
        .where((row) => row['line_type']?.toString() == 'surah_name')
        .toList();
    final bismillahRows = rows
        .where((row) => row['line_type']?.toString() == 'basmallah')
        .toList();
    if (surahRows.length != 1 || bismillahRows.length != 1) {
      throw const FormatException(
        'QCF V4 page 440 must contain one Surah row and one Bismillah row.',
      );
    }

    final surah = surahRows.single;
    final bismillah = bismillahRows.single;
    final surahLine = _asInt(surah['line_number'], 'surah_line');
    final bismillahLine = _asInt(bismillah['line_number'], 'bismillah_line');
    final surahNumber = _asInt(surah['surah_number'], 'surah_number');

    final ayahRows = rows
        .where(
          (row) =>
              row['line_type']?.toString() == 'ayah' &&
              _asInt(row['line_number'], 'line_number') > bismillahLine,
        )
        .toList();
    if (ayahRows.isEmpty) {
      throw const FormatException(
        'QCF V4 page 440 is missing the first Ya-Sin ayah line.',
      );
    }
    final firstAyahLine = _asInt(
      ayahRows.first['line_number'],
      'first_ayah_line',
    );

    if (surahNumber != 36 ||
        surahLine != 4 ||
        bismillahLine != 5 ||
        firstAyahLine != 6) {
      throw const FormatException(
        'QCF V4 page 440 Ya-Sin transition structure is invalid.',
      );
    }

    return Page440TransitionValidationResult(
      surahNumber: surahNumber,
      surahLine: surahLine,
      bismillahLine: bismillahLine,
      firstAyahLine: firstAyahLine,
    );
  } finally {
    db.close();
  }
}

QcfV2AssetValidationResult validateQcfV2Assets({
  required String layoutPath,
  required String scriptPath,
}) {
  final layout = sqlite3.open(layoutPath, mode: OpenMode.readOnly);
  final script = sqlite3.open(scriptPath, mode: OpenMode.readOnly);
  try {
    final metadata = <String, String>{
      for (final row in script.select('SELECT key, value FROM metadata'))
        row['key'].toString(): row['value'].toString(),
    };
    if (metadata['mushaf_id'] != '1' ||
        metadata['script_kind'] != 'qcf_v2' ||
        metadata['page_count'] != '604') {
      throw const FormatException('QCF V2 metadata validation failed.');
    }

    final pageStats = layout.select('''
      SELECT COUNT(DISTINCT page_number) AS page_count,
             MIN(page_number) AS min_page,
             MAX(page_number) AS max_page
      FROM pages
    ''').single;
    final pageCount = _asInt(pageStats['page_count'], 'page_count');
    if (pageCount != 604 ||
        _asInt(pageStats['min_page'], 'min_page') != 1 ||
        _asInt(pageStats['max_page'], 'max_page') != 604) {
      throw const FormatException('QCF V2 layout must contain pages 1..604.');
    }

    final tokenCount = int.tryParse(metadata['token_count'] ?? '');
    if (tokenCount == null || tokenCount <= 0) {
      throw const FormatException('QCF V2 token_count metadata is invalid.');
    }
    final scriptStats = script.select('''
      SELECT COUNT(*) AS count,
             MIN(word_index) AS min_index,
             MAX(word_index) AS max_index
      FROM words
    ''').single;
    if (_asInt(scriptStats['count'], 'count') != tokenCount ||
        _asInt(scriptStats['min_index'], 'min_index') != 1 ||
        _asInt(scriptStats['max_index'], 'max_index') != tokenCount) {
      throw const FormatException('QCF V2 script indexes are invalid.');
    }

    var expectedFirst = 1;
    final ranges = layout.select('''
      SELECT first_word_id, last_word_id
      FROM pages
      WHERE line_type = 'ayah'
      ORDER BY first_word_id, last_word_id
    ''');
    for (final row in ranges) {
      final first = _asInt(row['first_word_id'], 'first_word_id');
      final last = _asInt(row['last_word_id'], 'last_word_id');
      if (first != expectedFirst || last < first) {
        throw const FormatException('QCF V2 layout word ranges are invalid.');
      }
      expectedFirst = last + 1;
    }
    if (expectedFirst - 1 != tokenCount) {
      throw const FormatException('QCF V2 layout does not cover all tokens.');
    }

    return QcfV2AssetValidationResult(
      pageCount: pageCount,
      tokenCount: tokenCount,
    );
  } finally {
    layout.close();
    script.close();
  }
}

void _validateQpcLayoutRanges({
  required String layoutPath,
  required String scriptPath,
}) {
  final layout = sqlite3.open(layoutPath, mode: OpenMode.readOnly);
  final script = sqlite3.open(scriptPath, mode: OpenMode.readOnly);
  try {
    final rows = layout.select('''
      SELECT page_number, line_number, first_word_id, last_word_id
      FROM pages
      WHERE line_type = 'ayah'
      ORDER BY page_number, line_number
    ''');
    final exists = script.prepare(
      'SELECT 1 FROM words WHERE word_index = ? LIMIT 1',
    );
    try {
      for (final row in rows) {
        final first = _asInt(row['first_word_id'], 'first_word_id');
        final last = _asInt(row['last_word_id'], 'last_word_id');
        for (var wordIndex = first; wordIndex <= last; wordIndex++) {
          if (exists.select([wordIndex]).isEmpty) {
            throw FormatException(
              'QPC layout references missing word_index ' +
                  wordIndex.toString() +
                  ' on page ' +
                  row['page_number'].toString() +
                  ', line ' +
                  row['line_number'].toString() +
                  '.',
            );
          }
        }
      }
    } finally {
      exists.close();
    }
  } finally {
    layout.close();
    script.close();
  }
}

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final qcfV4Layout =
      options['qcf-v4-layout'] ??
      'assets/mushaf/layouts/qpc-v4-tajweed-15-lines.sqlite';
  final qcfV4Script =
      options['qcf-v4-script'] ?? 'assets/mushaf/scripts/qpc-v4-words.sqlite';
  final qcfV2Layout =
      options['qcf-v2-layout'] ??
      'assets/mushaf/layouts/qcf-v2-15-lines.sqlite';
  final qcfV2Script =
      options['qcf-v2-script'] ?? 'assets/mushaf/scripts/qcf-v2-words.sqlite';

  final result = await validateMushafAssets(
    qcfV4LayoutPath: qcfV4Layout,
    qcfV4ScriptPath: qcfV4Script,
    qcfV2LayoutPath: qcfV2Layout,
    qcfV2ScriptPath: qcfV2Script,
  );
  stdout.writeln(
    'QCF V4 layout: ' +
        result.qcfV4Layout.pageCount.toString() +
        ' pages / ' +
        result.qcfV4Layout.linesPerPage.toString() +
        ' lines',
  );
  stdout.writeln(
    'QCF V4 script: ' +
        result.qcfV4Script.wordCount.toString() +
        ' word + ' +
        result.qcfV4Script.endCount.toString() +
        ' end = ' +
        result.qcfV4Script.totalCount.toString() +
        ' tokens / ' +
        result.qcfV4Script.pageCount.toString() +
        ' pages',
  );
  stdout.writeln(
    'Page 440: Surah ' +
        result.page440.surahNumber.toString() +
        ', lines ' +
        result.page440.surahLine.toString() +
        '/' +
        result.page440.bismillahLine.toString() +
        '/' +
        result.page440.firstAyahLine.toString(),
  );
  if (result.qcfV2 == null) {
    stdout.writeln('QCF V2 assets: not generated locally; validation skipped.');
  } else {
    stdout.writeln(
      'QCF V2: ' +
          result.qcfV2!.pageCount.toString() +
          ' pages / ' +
          result.qcfV2!.tokenCount.toString() +
          ' tokens',
    );
  }
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var index = 0; index < args.length; index++) {
    final argument = args[index];
    if (!argument.startsWith('--')) {
      throw FormatException('Unexpected argument "' + argument + '".');
    }
    if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
      throw FormatException('Missing value for "' + argument + '".');
    }
    result[argument.substring(2)] = args[++index];
  }
  return result;
}

int _asInt(Object? value, String name) {
  if (value is int) return value;
  final parsed = int.tryParse(value?.toString() ?? '');
  if (parsed == null) {
    throw FormatException(name + ' must be an integer.');
  }
  return parsed;
}
