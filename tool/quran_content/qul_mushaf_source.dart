import 'package:sqlite3/sqlite3.dart';

import 'models/source_records.dart';

typedef QulDatabaseOpener = Database Function(String path, {OpenMode mode});

/// Read-only, normalized view of QUL's IndoPak word script and PDMS layout.
class QulMushafSource {
  QulMushafSource._({
    required Map<String, String> wordsByLocation,
    required Map<String, String> ayahsByKey,
    required List<MushafLineSourceRecord> lines,
  }) : _wordsByLocation = Map.unmodifiable(wordsByLocation),
       _ayahsByKey = Map.unmodifiable(ayahsByKey),
       _lines = List.unmodifiable(lines);

  factory QulMushafSource.open({
    required String scriptPath,
    required String layoutPath,
    bool requireProductionPageSet = false,
    QulDatabaseOpener? databaseOpener,
  }) {
    final openDatabase = databaseOpener ?? sqlite3.open;
    final scriptDatabase = openDatabase(scriptPath, mode: OpenMode.readOnly);
    try {
      final layoutDatabase = openDatabase(layoutPath, mode: OpenMode.readOnly);
      try {
        final words = _readWords(scriptDatabase);
        final normalizedWords = _normalizeWords(words);
        final lines = _readLines(layoutDatabase, normalizedWords.byId);
        if (requireProductionPageSet) _validateProductionPageSet(lines);
        return QulMushafSource._(
          wordsByLocation: normalizedWords.byLocation,
          ayahsByKey: normalizedWords.ayahsByKey,
          lines: lines,
        );
      } finally {
        layoutDatabase.close();
      }
    } finally {
      scriptDatabase.close();
    }
  }

  final Map<String, String> _wordsByLocation;
  final Map<String, String> _ayahsByKey;
  final List<MushafLineSourceRecord> _lines;

  List<MushafLineSourceRecord> get lines => _lines;

  Iterable<String> get wordLocations => _wordsByLocation.keys;

  String indoPakAyahText(int surah, int ayah) {
    final text = _ayahsByKey['$surah:$ayah'];
    if (text == null) {
      throw StateError('QUL has no IndoPak text for $surah:$ayah.');
    }
    return text;
  }

  String indoPakWordText(String location) {
    final text = _wordsByLocation[location];
    if (text == null) {
      throw StateError('QUL has no IndoPak text for word $location.');
    }
    return text;
  }

  /// The source is fully materialized during [open], so no handles remain open.
  void close() {}
}

class _QulWord {
  const _QulWord({
    required this.id,
    required this.location,
    required this.surah,
    required this.ayah,
    required this.position,
    required this.text,
  });

  final int id;
  final String location;
  final int surah;
  final int ayah;
  final int position;
  final String text;
}

class _NormalizedWords {
  const _NormalizedWords({
    required this.byId,
    required this.byLocation,
    required this.ayahsByKey,
  });

  final Map<int, String> byId;
  final Map<String, String> byLocation;
  final Map<String, String> ayahsByKey;
}

List<_QulWord> _readWords(Database database) {
  _requireColumns(database, 'words', const [
    'id',
    'location',
    'surah',
    'ayah',
    'word',
    'text',
  ]);
  return database
      .select('SELECT id, location, surah, ayah, word, text FROM words')
      .map(
        (row) => _QulWord(
          id: _requiredInt(row['id'], 'words.id'),
          location: _requiredText(row['location'], 'words.location'),
          surah: _requiredInt(row['surah'], 'words.surah'),
          ayah: _requiredInt(row['ayah'], 'words.ayah'),
          position: _requiredInt(row['word'], 'words.word'),
          text: _requiredText(row['text'], 'words.text'),
        ),
      )
      .toList(growable: false);
}

_NormalizedWords _normalizeWords(List<_QulWord> words) {
  if (words.isEmpty) throw const FormatException('QUL words table is empty.');
  final byId = <int, _QulWord>{};
  final byLocation = <String, _QulWord>{};
  final byAyah = <String, List<_QulWord>>{};
  for (final word in words) {
    if (word.id <= 0 ||
        word.surah < 1 ||
        word.surah > 114 ||
        word.ayah <= 0 ||
        word.position <= 0) {
      throw FormatException('Invalid QUL word identity at ${word.location}.');
    }
    final expectedLocation = '${word.surah}:${word.ayah}:${word.position}';
    if (word.location != expectedLocation) {
      throw FormatException(
        'QUL word location ${word.location} does not match $expectedLocation.',
      );
    }
    if (byId.containsKey(word.id)) {
      throw FormatException('Duplicate QUL global word ID ${word.id}.');
    }
    if (byLocation.containsKey(word.location)) {
      throw FormatException('Duplicate QUL word location ${word.location}.');
    }
    byId[word.id] = word;
    byLocation[word.location] = word;
    byAyah.putIfAbsent('${word.surah}:${word.ayah}', () => []).add(word);
  }

  final normalizedById = <int, String>{};
  final normalizedByLocation = <String, String>{};
  final ayahsByKey = <String, String>{};
  for (final entry in byAyah.entries) {
    final ayahWords = entry.value
      ..sort((a, b) => a.position.compareTo(b.position));
    for (var index = 0; index < ayahWords.length; index++) {
      if (ayahWords[index].position != index + 1) {
        throw FormatException(
          'QUL ayah ${entry.key} has a missing word position.',
        );
      }
      final isFinalWord = index == ayahWords.length - 1;
      final normalized = _normalizeWordText(ayahWords[index].text, isFinalWord);
      normalizedById[ayahWords[index].id] = ayahWords[index].location;
      normalizedByLocation[ayahWords[index].location] = normalized;
    }
    ayahsByKey[entry.key] = ayahWords
        .map((word) => normalizedByLocation[word.location]!)
        .join(' ');
  }
  return _NormalizedWords(
    byId: normalizedById,
    byLocation: normalizedByLocation,
    ayahsByKey: ayahsByKey,
  );
}

String _normalizeWordText(String text, bool isFinalWord) {
  final runes = text.runes.toList(growable: false);
  final bmpPuaIndexes = <int>[];
  for (var index = 0; index < runes.length; index++) {
    final rune = runes[index];
    if (_isSupplementaryPrivateUse(rune)) {
      throw const FormatException(
        'QUL supplementary private-use code points are not permitted.',
      );
    }
    if (_isBmpPrivateUse(rune) && !_isQulIndoPakShapingGlyph(rune)) {
      bmpPuaIndexes.add(index);
    }
  }
  if (bmpPuaIndexes.isEmpty) return text;
  final isTrailingSingleMarker =
      isFinalWord &&
      bmpPuaIndexes.length == 1 &&
      bmpPuaIndexes.single == runes.length - 1;
  if (!isTrailingSingleMarker) {
    throw const FormatException(
      'QUL private-use code points are only allowed as one trailing final-word ayah marker.',
    );
  }
  final normalized = String.fromCharCodes(runes.take(runes.length - 1));
  if (normalized.trim().isEmpty) {
    throw const FormatException('QUL ayah marker cannot be a word by itself.');
  }
  return normalized;
}

bool _isBmpPrivateUse(int rune) => rune >= 0xE000 && rune <= 0xF8FF;

// Resource 59 encodes a small set of font shaping ligatures in this reserved
// block. They are Quran text glyphs supported by its bundled Nastaleeq font,
// not the separate numbered ayah-marker records removed during materializing.
bool _isQulIndoPakShapingGlyph(int rune) => rune >= 0xF600 && rune <= 0xF6FF;

bool _isSupplementaryPrivateUse(int rune) =>
    (rune >= 0xF0000 && rune <= 0xFFFFD) ||
    (rune >= 0x100000 && rune <= 0x10FFFD);

List<MushafLineSourceRecord> _readLines(
  Database database,
  Map<int, String> locationsById,
) {
  _requireColumns(database, 'pages', const [
    'page_number',
    'line_number',
    'line_type',
    'is_centered',
    'first_word_id',
    'last_word_id',
    'surah_number',
  ]);
  final lines = <MushafLineSourceRecord>[];
  for (final row in database.select(
    'SELECT page_number, line_number, line_type, is_centered, '
    'first_word_id, last_word_id, surah_number FROM pages '
    'ORDER BY page_number, line_number',
  )) {
    final page = _requiredInt(row['page_number'], 'pages.page_number');
    final line = _requiredInt(row['line_number'], 'pages.line_number');
    final type = _requiredText(row['line_type'], 'pages.line_type');
    final centered = _requiredInt(row['is_centered'], 'pages.is_centered');
    final first = _nullableInt(row['first_word_id'], 'pages.first_word_id');
    final last = _nullableInt(row['last_word_id'], 'pages.last_word_id');
    final surah = _nullableInt(row['surah_number'], 'pages.surah_number');
    if (page < 1 ||
        page > 604 ||
        line < 1 ||
        (centered != 0 && centered != 1)) {
      throw FormatException('Invalid QUL layout row $page:$line.');
    }
    if (type == 'ayah') {
      if (first == null || last == null || first > last) {
        throw FormatException(
          'Ayah layout line $page:$line has invalid boundaries.',
        );
      }
      final firstLocation = locationsById[first];
      final lastLocation = locationsById[last];
      if (firstLocation == null || lastLocation == null) {
        throw FormatException(
          'Ayah layout line $page:$line references an unknown QUL word ID.',
        );
      }
      lines.add(
        MushafLineSourceRecord(
          pageNumber: page,
          lineNumber: line,
          lineType: type,
          centered: centered == 1,
          surahNumber: surah,
          firstWordLocation: firstLocation,
          lastWordLocation: lastLocation,
        ),
      );
      continue;
    }
    if (type != 'surah_name' && type != 'basmallah') {
      throw FormatException('Unsupported QUL layout line type "$type".');
    }
    if (first != null ||
        last != null ||
        surah == null ||
        surah < 1 ||
        surah > 114) {
      throw FormatException(
        'Metadata layout line $page:$line has invalid semantics.',
      );
    }
    lines.add(
      MushafLineSourceRecord(
        pageNumber: page,
        lineNumber: line,
        lineType: type,
        centered: centered == 1,
        surahNumber: surah,
      ),
    );
  }
  if (lines.isEmpty) throw const FormatException('QUL pages table is empty.');
  return List.unmodifiable(lines);
}

void _validateProductionPageSet(List<MushafLineSourceRecord> lines) {
  final pages = lines.map((line) => line.pageNumber).toSet();
  if (pages.length != 604 ||
      !pages.containsAll(List<int>.generate(604, (index) => index + 1))) {
    throw const FormatException(
      'Production QUL layout must contain exactly pages 1 through 604.',
    );
  }
}

void _requireColumns(Database database, String table, List<String> required) {
  final columns = database
      .select('PRAGMA table_info($table)')
      .map((row) => row['name'] as String)
      .toSet();
  final missing = required
      .where((column) => !columns.contains(column))
      .toList();
  if (missing.isNotEmpty) {
    throw FormatException(
      'QUL table $table is missing columns: ${missing.join(', ')}.',
    );
  }
}

String _requiredText(Object? value, String column) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty $column.');
  }
  return value;
}

int _requiredInt(Object? value, String column) {
  if (value is! int) throw FormatException('Expected integer $column.');
  return value;
}

int? _nullableInt(Object? value, String column) {
  if (value == null) return null;
  return _requiredInt(value, column);
}
