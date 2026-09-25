import 'dart:convert';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

const digitalKhattV2ScriptKind = 'digital_khatt_v2';
const digitalKhattV2ScriptType = 'text_digital_khatt';
const digitalKhattV2FontFamily = 'digitalkhatt-v2';
const digitalKhattV2QulResourceId = '48';

class DigitalKhattSourceWord {
  const DigitalKhattSourceWord({required this.position, required this.text});

  final int position;
  final String text;

  factory DigitalKhattSourceWord.fromJson(Map<String, dynamic> json) {
    final position = _requiredInt(json['position'], 'word.position');
    final text = json['text'];
    if (text is! String || text.isEmpty) {
      throw const FormatException('Digital Khatt word text is required.');
    }
    return DigitalKhattSourceWord(position: position, text: text);
  }
}

class DigitalKhattSourceVerse {
  const DigitalKhattSourceVerse({required this.verseKey, required this.words});

  final String verseKey;
  final List<DigitalKhattSourceWord> words;

  factory DigitalKhattSourceVerse.fromJson(Map<String, dynamic> json) {
    final verseKey = _requiredVerseKey(json['verse_key']);
    final scriptType = json['script_type'];
    if (scriptType != null && scriptType != digitalKhattV2ScriptType) {
      throw FormatException(
        'Expected $digitalKhattV2ScriptType but found $scriptType.',
      );
    }
    final fontFamily = json['font_family'];
    if (fontFamily != null && fontFamily != digitalKhattV2FontFamily) {
      throw FormatException(
        'Expected $digitalKhattV2FontFamily but found $fontFamily.',
      );
    }
    final rawWords = json['words'];
    if (rawWords is! List || rawWords.isEmpty) {
      throw FormatException('Digital Khatt verse $verseKey has no words.');
    }
    final words = <DigitalKhattSourceWord>[
      for (final raw in rawWords)
        DigitalKhattSourceWord.fromJson(_stringMap(raw, 'word')),
    ]..sort((a, b) => a.position.compareTo(b.position));
    _validatePositions(words, verseKey);
    return DigitalKhattSourceVerse(
      verseKey: verseKey,
      words: List.unmodifiable(words),
    );
  }
}

class DigitalKhattBuildRow {
  const DigitalKhattBuildRow({
    required this.wordIndex,
    required this.ayahKey,
    required this.wordPosition,
    required this.charType,
    required this.display,
  });

  final int wordIndex;
  final String ayahKey;
  final int wordPosition;
  final String charType;
  final String display;
}

List<DigitalKhattBuildRow> importVerse({
  required String verseKey,
  required List<DigitalKhattSourceWord> words,
  int startWordIndex = 1,
}) {
  if (startWordIndex < 1) {
    throw RangeError.range(startWordIndex, 1, null, 'startWordIndex');
  }
  _requiredVerseKey(verseKey);
  if (words.isEmpty) {
    throw FormatException('Digital Khatt verse $verseKey has no words.');
  }
  final sorted = [...words]..sort((a, b) => a.position.compareTo(b.position));
  _validatePositions(sorted, verseKey);

  var next = startWordIndex;
  return [
    for (final word in sorted)
      DigitalKhattBuildRow(
        wordIndex: next++,
        ayahKey: verseKey,
        wordPosition: word.position,
        charType: _isAyahEnd(word.text) ? 'end' : 'word',
        display: word.text,
      ),
  ];
}

List<DigitalKhattBuildRow> importVerses(List<DigitalKhattSourceVerse> verses) {
  final sorted = [...verses]
    ..sort((a, b) => _compareVerseKeys(a.verseKey, b.verseKey));
  final rows = <DigitalKhattBuildRow>[];
  var next = 1;
  for (final verse in sorted) {
    final imported = importVerse(
      verseKey: verse.verseKey,
      words: verse.words,
      startWordIndex: next,
    );
    rows.addAll(imported);
    next += imported.length;
  }
  return rows;
}

List<DigitalKhattSourceVerse> parseQulDigitalKhattJson(String raw) {
  final decoded = jsonDecode(raw);
  final entries = <Object?>[];

  if (decoded is List) {
    entries.addAll(decoded);
  } else if (decoded is Map) {
    final normalized = decoded.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final verses = normalized['verses'];
    if (verses is List) {
      entries.addAll(verses);
    } else {
      for (final entry in normalized.entries) {
        if (entry.value is! Map) continue;
        final verse = Map<String, dynamic>.from(
          (entry.value as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        );
        verse.putIfAbsent('verse_key', () => entry.key);
        entries.add(verse);
      }
    }
  } else {
    throw const FormatException(
      'Digital Khatt JSON must be a verse map or list.',
    );
  }

  final parsed = <DigitalKhattSourceVerse>[
    for (final entry in entries)
      DigitalKhattSourceVerse.fromJson(_stringMap(entry, 'verse')),
  ];
  if (parsed.isEmpty) {
    throw const FormatException('Digital Khatt JSON contains no verses.');
  }
  parsed.sort((a, b) => _compareVerseKeys(a.verseKey, b.verseKey));
  return List.unmodifiable(parsed);
}

List<DigitalKhattSourceVerse> parseQulDigitalKhattSqlite(String inputPath) {
  final database = sqlite3.open(inputPath, mode: OpenMode.readOnly);
  try {
    final tables = database
        .select(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
          "ORDER BY name",
        )
        .map((row) => row['name']?.toString())
        .whereType<String>();

    for (final table in tables) {
      final quotedTable = _quoteIdentifier(table);
      final columns = database
          .select('PRAGMA table_info($quotedTable)')
          .map((row) => row['name']?.toString())
          .whereType<String>()
          .toSet();

      final verseColumn = _firstColumn(columns, const [
        'verse_key',
        'ayah_key',
      ]);
      final locationColumn = _firstColumn(columns, const [
        'location',
        'word_location',
      ]);
      final positionColumn = _firstColumn(columns, const [
        'position',
        'word_position',
      ]);
      final textColumn = _firstColumn(columns, const [
        'text',
        'display',
        'word_text',
      ]);

      if (textColumn == null ||
          (verseColumn == null && locationColumn == null) ||
          (positionColumn == null && locationColumn == null)) {
        continue;
      }

      final selected = <String>[
        if (verseColumn != null)
          '${_quoteIdentifier(verseColumn)} AS verse_key',
        if (locationColumn != null)
          '${_quoteIdentifier(locationColumn)} AS location',
        if (positionColumn != null)
          '${_quoteIdentifier(positionColumn)} AS position',
        '${_quoteIdentifier(textColumn)} AS text',
      ];
      final rows = database.select(
        'SELECT ${selected.join(', ')} FROM $quotedTable ORDER BY rowid',
      );
      if (rows.isEmpty) continue;

      final grouped = <String, List<DigitalKhattSourceWord>>{};
      var valid = true;
      for (final row in rows) {
        final location = row['location']?.toString();
        final verseKey =
            row['verse_key']?.toString() ?? _verseKeyFromLocation(location);
        final position =
            _optionalInt(row['position']) ?? _positionFromLocation(location);
        final text = row['text'];
        if (verseKey == null ||
            position == null ||
            position < 1 ||
            text is! String ||
            text.isEmpty) {
          valid = false;
          break;
        }
        _requiredVerseKey(verseKey);
        grouped
            .putIfAbsent(verseKey, () => <DigitalKhattSourceWord>[])
            .add(DigitalKhattSourceWord(position: position, text: text));
      }
      if (!valid || grouped.isEmpty) continue;

      final verses = <DigitalKhattSourceVerse>[
        for (final entry in grouped.entries)
          DigitalKhattSourceVerse(
            verseKey: entry.key,
            words: List.unmodifiable(
              [...entry.value]
                ..sort((a, b) => a.position.compareTo(b.position)),
            ),
          ),
      ];
      for (final verse in verses) {
        _validatePositions(verse.words, verse.verseKey);
      }
      verses.sort((a, b) => _compareVerseKeys(a.verseKey, b.verseKey));
      return List.unmodifiable(verses);
    }

    throw const FormatException(
      'Could not find a QUL Digital Khatt word-level table.',
    );
  } finally {
    database.close();
  }
}

void writeDigitalKhattDatabase({
  required String outputPath,
  required List<DigitalKhattBuildRow> rows,
  required String sourceDescription,
}) {
  if (rows.isEmpty) {
    throw const FormatException('Digital Khatt script has no rows.');
  }

  final file = File(outputPath);
  file.parent.createSync(recursive: true);
  if (file.existsSync()) file.deleteSync();

  final database = sqlite3.open(file.path);
  try {
    database.execute('''
      CREATE TABLE words (
        word_index INTEGER PRIMARY KEY,
        ayah_key TEXT NOT NULL,
        word_position INTEGER NOT NULL,
        char_type TEXT NOT NULL,
        display TEXT NOT NULL
      );
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
      CREATE INDEX words_ayah_key_idx ON words(ayah_key);
    ''');
    database.execute('BEGIN');

    final insert = database.prepare('INSERT INTO words VALUES (?, ?, ?, ?, ?)');
    try {
      for (final row in rows) {
        insert.execute([
          row.wordIndex,
          row.ayahKey,
          row.wordPosition,
          row.charType,
          row.display,
        ]);
      }
    } finally {
      insert.close();
    }

    final metadata = <String, String>{
      'script_kind': digitalKhattV2ScriptKind,
      'script_type': digitalKhattV2ScriptType,
      'font_family': digitalKhattV2FontFamily,
      'qul_resource_id': digitalKhattV2QulResourceId,
      'source': sourceDescription,
      'token_count': rows.length.toString(),
    };
    final insertMetadata = database.prepare(
      'INSERT INTO metadata(key, value) VALUES (?, ?)',
    );
    try {
      for (final entry in metadata.entries) {
        insertMetadata.execute([entry.key, entry.value]);
      }
    } finally {
      insertMetadata.close();
    }

    database.execute('COMMIT');
    database.execute('VACUUM');
  } catch (_) {
    try {
      database.execute('ROLLBACK');
    } catch (_) {
      // No active transaction.
    }
    rethrow;
  } finally {
    database.close();
  }
}

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final inputPath = options['input'];
  if (inputPath == null) {
    throw const FormatException('--input is required.');
  }
  final outputPath =
      options['out'] ?? 'assets/mushaf/scripts/digital-khatt-v2-words.sqlite';
  final input = File(inputPath);
  if (!input.existsSync()) {
    throw FormatException('Digital Khatt source not found: $inputPath');
  }
  final lowerInput = inputPath.toLowerCase();
  final List<DigitalKhattSourceVerse> verses;
  if (lowerInput.endsWith('.json')) {
    verses = parseQulDigitalKhattJson(await input.readAsString());
  } else if (lowerInput.endsWith('.sqlite') ||
      lowerInput.endsWith('.sqlite3') ||
      lowerInput.endsWith('.db')) {
    verses = parseQulDigitalKhattSqlite(inputPath);
  } else {
    throw const FormatException(
      'Digital Khatt input must be the exact QUL resource 48 '
      'JSON or SQLite export.',
    );
  }
  final rows = importVerses(verses);
  writeDigitalKhattDatabase(
    outputPath: outputPath,
    rows: rows,
    sourceDescription: 'QUL resource 48: $inputPath',
  );
  stdout.writeln('Digital Khatt V2 script database generated.');
  stdout.writeln('Verses: ${verses.length}');
  stdout.writeln('Tokens: ${rows.length}');
  stdout.writeln('Output: $outputPath');
}

bool _isAyahEnd(String text) {
  return text.runes.isNotEmpty && text.runes.first == 0x06dd;
}

void _validatePositions(List<DigitalKhattSourceWord> words, String verseKey) {
  var previous = 0;
  for (final word in words) {
    if (word.position <= 0 || word.position <= previous) {
      throw FormatException(
        'Digital Khatt word positions must increase in $verseKey.',
      );
    }
    previous = word.position;
  }
}

int _compareVerseKeys(String left, String right) {
  final a = _verseParts(left);
  final b = _verseParts(right);
  final surah = a.$1.compareTo(b.$1);
  return surah != 0 ? surah : a.$2.compareTo(b.$2);
}

String _requiredVerseKey(Object? value) {
  if (value is! String) {
    throw const FormatException('verse_key is required.');
  }
  _verseParts(value);
  return value;
}

(int, int) _verseParts(String key) {
  final parts = key.split(':');
  if (parts.length != 2) {
    throw FormatException('Invalid verse_key: $key');
  }
  final surah = int.tryParse(parts[0]);
  final ayah = int.tryParse(parts[1]);
  if (surah == null || ayah == null || surah < 1 || surah > 114 || ayah < 1) {
    throw FormatException('Invalid verse_key: $key');
  }
  return (surah, ayah);
}

Map<String, dynamic> _stringMap(Object? raw, String name) {
  if (raw is! Map) {
    throw FormatException('Digital Khatt $name must be an object.');
  }
  return raw.map((key, value) => MapEntry(key.toString(), value));
}

int _requiredInt(Object? value, String name) {
  final parsed = _optionalInt(value);
  if (parsed == null) throw FormatException('$name must be an integer.');
  return parsed;
}

int? _optionalInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String? _firstColumn(Set<String> columns, List<String> candidates) {
  for (final candidate in candidates) {
    if (columns.contains(candidate)) return candidate;
  }
  return null;
}

String _quoteIdentifier(String identifier) {
  return '"${identifier.replaceAll('"', '""')}"';
}

String? _verseKeyFromLocation(String? location) {
  if (location == null) return null;
  final parts = location.split(':');
  if (parts.length < 2) return null;
  return '${parts[0]}:${parts[1]}';
}

int? _positionFromLocation(String? location) {
  if (location == null) return null;
  final parts = location.split(':');
  if (parts.length < 3) return null;
  return int.tryParse(parts[2]);
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var index = 0; index < args.length; index++) {
    final argument = args[index];
    if (!argument.startsWith('--')) {
      throw FormatException('Unexpected argument "$argument".');
    }
    if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
      throw FormatException('Missing value for "$argument".');
    }
    result[argument.substring(2)] = args[++index];
  }
  return result;
}
