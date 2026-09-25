import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:sqlite3/sqlite3.dart';

class QpcV4WordInput {
  const QpcV4WordInput({
    required this.id,
    required this.position,
    required this.charType,
    required this.codeV2,
    this.pageNumber,
    this.lineNumber,
    this.textQpcHafs,
  });

  final int id;
  final int position;
  final String charType;
  final String codeV2;
  final int? pageNumber;
  final int? lineNumber;
  final String? textQpcHafs;

  factory QpcV4WordInput.fromJson(Map<String, dynamic> json) {
    final codeV2 =
        _optionalString(json['code_v2']) ?? _optionalString(json['text']);
    if (codeV2 == null) {
      throw const FormatException('QPC V4 word is missing code_v2.');
    }
    return QpcV4WordInput(
      id: _requiredInt(json['id'], 'word.id'),
      position: _requiredInt(json['position'], 'word.position'),
      charType: _requiredString(json['char_type_name'], 'word.char_type_name'),
      codeV2: codeV2,
      pageNumber: _optionalInt(json['page_number']),
      lineNumber: _optionalInt(json['line_number']),
      textQpcHafs: _optionalString(json['text_qpc_hafs']),
    );
  }
}

class QpcV4VerseInput {
  const QpcV4VerseInput({
    required this.verseKey,
    required this.pageNumber,
    required this.words,
  });

  final String verseKey;
  final int pageNumber;
  final List<QpcV4WordInput> words;

  factory QpcV4VerseInput.fromJson(Map<String, dynamic> json) {
    final rawWords = json['words'];
    if (rawWords is! List) {
      throw const FormatException('QPC V4 verse is missing words.');
    }
    return QpcV4VerseInput(
      verseKey: _requiredString(json['verse_key'], 'verse.verse_key'),
      pageNumber: _requiredInt(json['page_number'], 'verse.page_number'),
      words: [
        for (final word in rawWords)
          if (word is Map<String, dynamic>)
            QpcV4WordInput.fromJson(word)
          else if (word is Map)
            QpcV4WordInput.fromJson(
              word.map((key, value) => MapEntry(key.toString(), value)),
            )
          else
            throw const FormatException('Unexpected QPC V4 word payload.'),
      ],
    );
  }
}

class QpcV4BuildRow {
  const QpcV4BuildRow({
    required this.wordIndex,
    required this.remoteId,
    required this.ayahKey,
    required this.wordPosition,
    required this.charType,
    required this.pageNumber,
    required this.lineNumber,
    required this.display,
    required this.unicodeFallback,
  });

  final int wordIndex;
  final int remoteId;
  final String ayahKey;
  final int? wordPosition;
  final String charType;
  final int pageNumber;
  final int? lineNumber;
  final String display;
  final String? unicodeFallback;
}

List<QpcV4BuildRow> buildRows(List<QpcV4VerseInput> verses) {
  var next = 1;
  final rows = <QpcV4BuildRow>[];
  for (final verse in verses) {
    for (final word in verse.words) {
      final isQulSplitPhrase =
          word.charType == 'word' && word.textQpcHafs == 'بَعۡدَ مَا';
      if (isQulSplitPhrase) {
        final glyphs = word.codeV2
            .replaceAll(RegExp(r'\s+'), '')
            .runes
            .map(String.fromCharCode)
            .toList(growable: false);
        const textParts = ['بَعۡدَ', 'مَا'];
        if (glyphs.length != textParts.length) {
          throw FormatException(
            'Expected two QPC V4 glyphs for QUL split phrase in ' +
                verse.verseKey +
                '.',
          );
        }
        for (var index = 0; index < glyphs.length; index++) {
          rows.add(
            QpcV4BuildRow(
              wordIndex: next++,
              remoteId: word.id,
              ayahKey: verse.verseKey,
              wordPosition: word.position,
              charType: word.charType,
              pageNumber: word.pageNumber ?? verse.pageNumber,
              lineNumber: word.lineNumber,
              display: glyphs[index],
              unicodeFallback: textParts[index],
            ),
          );
        }
        continue;
      }
      rows.add(
        QpcV4BuildRow(
          wordIndex: next++,
          remoteId: word.id,
          ayahKey: verse.verseKey,
          wordPosition: word.charType == 'word' ? word.position : null,
          charType: word.charType,
          pageNumber: word.pageNumber ?? verse.pageNumber,
          lineNumber: word.lineNumber,
          display: word.codeV2,
          unicodeFallback: word.textQpcHafs,
        ),
      );
    }
  }
  return rows;
}

Future<List<QpcV4VerseInput>> fetchQpcV4Verses({
  required http.Client client,
  required Uri apiBase,
}) async {
  final verses = <QpcV4VerseInput>[];
  for (var chapter = 1; chapter <= 114; chapter++) {
    final uri = apiBase
        .resolve('/api/v4/verses/by_chapter/' + chapter.toString())
        .replace(
          queryParameters: const {
            'words': 'true',
            'word_fields': 'code_v2,text_qpc_hafs',
            'mushaf': '19',
            'per_page': '300',
          },
        );
    final response = await client.get(uri);
    if (response.statusCode != 200) {
      throw HttpException(
        'Quran API chapter ' +
            chapter.toString() +
            ' returned HTTP ' +
            response.statusCode.toString() +
            '.',
        uri: uri,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw FormatException(
        'Unexpected Quran API response for chapter ' + chapter.toString() + '.',
      );
    }
    final rawVerses = decoded['verses'];
    if (rawVerses is! List || rawVerses.isEmpty) {
      throw FormatException(
        'Quran API returned no verses for chapter ' + chapter.toString() + '.',
      );
    }
    for (final rawVerse in rawVerses) {
      if (rawVerse is Map<String, dynamic>) {
        verses.add(QpcV4VerseInput.fromJson(rawVerse));
      } else if (rawVerse is Map) {
        verses.add(
          QpcV4VerseInput.fromJson(
            rawVerse.map((key, value) => MapEntry(key.toString(), value)),
          ),
        );
      } else {
        throw const FormatException('Unexpected Quran API verse payload.');
      }
    }
  }
  return verses;
}

void writeQpcV4Database({
  required String outputPath,
  required List<QpcV4BuildRow> rows,
  required String sourceDescription,
  required String generatedAt,
}) {
  final file = File(outputPath);
  file.parent.createSync(recursive: true);
  if (file.existsSync()) file.deleteSync();

  final db = sqlite3.open(file.path);
  try {
    db.execute('''
      CREATE TABLE words (
        word_index INTEGER PRIMARY KEY,
        ayah_key TEXT,
        word_position INTEGER,
        char_type TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        line_number INTEGER,
        display TEXT NOT NULL,
        unicode_fallback TEXT
      );
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    db.execute('BEGIN');
    final insert = db.prepare('''
      INSERT INTO words (
        word_index,
        ayah_key,
        word_position,
        char_type,
        page_number,
        line_number,
        display,
        unicode_fallback
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''');
    try {
      for (final row in rows) {
        insert.execute([
          row.wordIndex,
          row.ayahKey,
          row.wordPosition,
          row.charType,
          row.pageNumber,
          row.lineNumber,
          row.display,
          row.unicodeFallback,
        ]);
      }
    } finally {
      insert.close();
    }

    final wordCount = rows.where((row) => row.charType == 'word').length;
    final endCount = rows.where((row) => row.charType == 'end').length;
    final pages = rows.map((row) => row.pageNumber).toSet();
    final metadata = <String, String>{
      'source': sourceDescription,
      'source_sha256': sha256
          .convert(utf8.encode(sourceDescription))
          .toString(),
      'generated_at': generatedAt,
      'word_count': wordCount.toString(),
      'end_count': endCount.toString(),
      'total_count': rows.length.toString(),
      'page_count': pages.length.toString(),
    };
    final metadataInsert = db.prepare(
      'INSERT INTO metadata(key, value) VALUES (?, ?)',
    );
    try {
      for (final entry in metadata.entries) {
        metadataInsert.execute([entry.key, entry.value]);
      }
    } finally {
      metadataInsert.close();
    }
    db.execute('COMMIT');
    db.execute('VACUUM');
  } catch (_) {
    try {
      db.execute('ROLLBACK');
    } catch (_) {
      // No active transaction.
    }
    rethrow;
  } finally {
    db.close();
  }
}

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final outputPath =
      options['out'] ?? 'assets/mushaf/scripts/qpc-v4-words.sqlite';
  final apiBase = Uri.parse(options['api-base'] ?? 'https://api.quran.com');
  final generatedAt =
      options['generated-at'] ?? DateTime.now().toUtc().toIso8601String();
  const queryDescription =
      'words=true&word_fields=code_v2,text_qpc_hafs&mushaf=19&per_page=300';
  final cleanBase = apiBase.toString().replaceFirst(RegExp(r'/$'), '');
  final sourceDescription =
      cleanBase + '/api/v4/verses/by_chapter/{chapter}?' + queryDescription;

  final client = http.Client();
  try {
    final verses = await fetchQpcV4Verses(client: client, apiBase: apiBase);
    final rows = buildRows(verses);
    writeQpcV4Database(
      outputPath: outputPath,
      rows: rows,
      sourceDescription: sourceDescription,
      generatedAt: generatedAt,
    );
    final wordCount = rows.where((row) => row.charType == 'word').length;
    final endCount = rows.where((row) => row.charType == 'end').length;
    final pageCount = rows.map((row) => row.pageNumber).toSet().length;
    stdout.writeln('QPC V4 script database generated.');
    stdout.writeln('Words: ' + wordCount.toString());
    stdout.writeln('Ends: ' + endCount.toString());
    stdout.writeln('Total: ' + rows.length.toString());
    stdout.writeln('Pages: ' + pageCount.toString());
    stdout.writeln('Output: ' + outputPath);
  } finally {
    client.close();
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

String _requiredString(Object? value, String name) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    throw FormatException(name + ' is required.');
  }
  return text;
}

int _requiredInt(Object? value, String name) {
  final parsed = _optionalInt(value);
  if (parsed == null) throw FormatException(name + ' must be an integer.');
  return parsed;
}

int? _optionalInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String? _optionalString(Object? value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}
