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

class MushafAssetValidationResult {
  const MushafAssetValidationResult({
    required this.qpcLayout,
    required this.digitalKhattLayout,
    required this.qpcScript,
  });

  final MushafLayoutValidationResult qpcLayout;
  final MushafLayoutValidationResult digitalKhattLayout;
  final QpcV4ScriptValidationResult qpcScript;
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
  required String qpcLayoutPath,
  required String digitalKhattLayoutPath,
  required String qpcScriptPath,
}) async {
  final qpcLayout = await validateLayout(qpcLayoutPath);
  final digitalKhattLayout = await validateLayout(digitalKhattLayoutPath);
  final qpcScript = await validateQpcV4Script(qpcScriptPath);
  _validateQpcLayoutRanges(
    layoutPath: qpcLayoutPath,
    scriptPath: qpcScriptPath,
  );
  return MushafAssetValidationResult(
    qpcLayout: qpcLayout,
    digitalKhattLayout: digitalKhattLayout,
    qpcScript: qpcScript,
  );
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
  final qpcLayout =
      options['qpc-layout'] ??
      'assets/mushaf/layouts/qpc-v4-tajweed-15-lines.sqlite';
  final digitalLayout =
      options['digital-layout'] ??
      'assets/mushaf/layouts/digital-khatt-15-lines.sqlite';
  final qpcScript =
      options['qpc-script'] ?? 'assets/mushaf/scripts/qpc-v4-words.sqlite';

  final result = await validateMushafAssets(
    qpcLayoutPath: qpcLayout,
    digitalKhattLayoutPath: digitalLayout,
    qpcScriptPath: qpcScript,
  );
  stdout.writeln(
    'QPC V4 layout: ' +
        result.qpcLayout.pageCount.toString() +
        ' pages / ' +
        result.qpcLayout.linesPerPage.toString() +
        ' lines',
  );
  stdout.writeln(
    'Digital Khatt layout: ' +
        result.digitalKhattLayout.pageCount.toString() +
        ' pages / ' +
        result.digitalKhattLayout.linesPerPage.toString() +
        ' lines',
  );
  stdout.writeln(
    'QPC V4 script: ' +
        result.qpcScript.wordCount.toString() +
        ' word + ' +
        result.qpcScript.endCount.toString() +
        ' end = ' +
        result.qpcScript.totalCount.toString() +
        ' tokens / ' +
        result.qpcScript.pageCount.toString() +
        ' pages',
  );
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
