import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

/// A canonical, non-marker QUL word prepared for the existing database builder.
class QulMaterializedWord {
  const QulMaterializedWord({
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

/// A normalized Mushaf line in the SQLite input contract read by QulMushafSource.
class QulMaterializedLine {
  const QulMaterializedLine({
    required this.pageNumber,
    required this.lineNumber,
    required this.lineType,
    required this.isCentered,
    required this.surahNumber,
    this.firstWordId,
    this.lastWordId,
  });

  final int pageNumber;
  final int lineNumber;
  final String lineType;
  final bool isCentered;
  final int surahNumber;
  final int? firstWordId;
  final int? lastWordId;
}

class QulMaterializedSources {
  const QulMaterializedSources({required this.words, required this.lines});

  final List<QulMaterializedWord> words;
  final List<QulMaterializedLine> lines;
}

class CanonicalSegmentation {
  const CanonicalSegmentation({
    required this.wordCountsByVerse,
    required this.joinedWordLocations,
  });

  final Map<String, int> wordCountsByVerse;
  final Set<String> joinedWordLocations;
}

/// Reads the app's verified word source so QUL's occasional split tokens can
/// be folded back into the stable `surah:ayah:position` contract.
CanonicalSegmentation canonicalSegmentationFromJson(Map<String, dynamic> json) {
  final rawWords = json['words'];
  if (rawWords is! List) {
    throw const FormatException('Canonical source is missing words.');
  }
  final counts = <String, int>{};
  final joined = <String>{};
  for (final rawWord in rawWords) {
    if (rawWord is! Map) {
      throw const FormatException('Canonical word must be an object.');
    }
    final word = Map<String, dynamic>.from(rawWord);
    final surah = _requiredInt(word, 'surah_number');
    final ayah = _requiredInt(word, 'ayah_number');
    final position = _requiredInt(word, 'position');
    final arabic = _requiredString(word, 'arabic');
    final verseKey = '$surah:$ayah';
    final expectedPosition = (counts[verseKey] ?? 0) + 1;
    if (position != expectedPosition) {
      throw FormatException(
        'Canonical word $verseKey:$position is not in stable order.',
      );
    }
    counts[verseKey] = position;
    final lexicalText = arabic.replaceAll(RegExp('[۞۩]'), '').trim();
    if (RegExp(r'\s').hasMatch(lexicalText)) {
      joined.add('$verseKey:$position');
    }
  }
  return CanonicalSegmentation(
    wordCountsByVerse: Map.unmodifiable(counts),
    joinedWordLocations: Set.unmodifiable(joined),
  );
}

/// Converts official QUL chapter/verses response objects to the two SQLite
/// contracts consumed by [QulMushafSource]. The numbered record appended by QUL
/// to each ayah is recognized explicitly and never retained as Quran text.
QulMaterializedSources materializeQulMushafResponses(
  Iterable<Map<String, dynamic>> responses, {
  Map<String, int> canonicalWordCountsByVerse = const {},
  Set<String> joinedCanonicalLocations = const {},
}) {
  final words = <_PositionedWord>[];
  final seenVerseKeys = <String>{};
  final seenIds = <int>{};
  final seenApiLocations = <String>{};
  final seenLocations = <String>{};
  final firstWordBySurah = <int, _PositionedWord>{};

  for (final response in responses) {
    final verses = _requiredObjectList(response, 'verses');
    for (final verse in verses) {
      final verseKey = _requiredString(verse, 'verse_key');
      final identity = _parseVerseKey(verseKey);
      if (!seenVerseKeys.add(verseKey)) {
        throw FormatException('Duplicate QUL verse $verseKey.');
      }
      final apiWords = [..._requiredObjectList(verse, 'words')]
        ..sort(
          (a, b) => _requiredInt(
            a,
            'position',
          ).compareTo(_requiredInt(b, 'position')),
        );
      if (apiWords.length < 2) {
        throw FormatException(
          'QUL verse $verseKey must contain Quran text and a final ayah marker.',
        );
      }
      final marker = apiWords.removeLast();
      _validateMarker(marker, identity.surah, identity.ayah, verseKey);

      for (var index = 0; index < apiWords.length; index++) {
        final apiWord = apiWords[index];
        final id = _requiredInt(apiWord, 'id');
        final location = _requiredString(apiWord, 'location');
        final position = _requiredInt(apiWord, 'position');
        final parsedLocation = _parseWordLocation(location);
        if (parsedLocation.surah != identity.surah ||
            parsedLocation.ayah != identity.ayah ||
            parsedLocation.position != position ||
            position != index + 1) {
          throw FormatException(
            'QUL word $location does not match ordered verse $verseKey.',
          );
        }
        if (!seenIds.add(id)) {
          throw FormatException('Duplicate QUL word ID $id.');
        }
        if (!seenApiLocations.add(location)) {
          throw FormatException('Duplicate QUL API word location $location.');
        }
      }

      final groups = _canonicalWordGroups(
        verseKey,
        apiWords,
        canonicalWordCountsByVerse[verseKey] ?? apiWords.length,
        joinedCanonicalLocations,
      );
      for (var index = 0; index < groups.length; index++) {
        final group = groups[index];
        final position = index + 1;
        final location = '$verseKey:$position';
        if (!seenLocations.add(location)) {
          throw FormatException('Duplicate canonical word location $location.');
        }
        final firstApiWord = group.first;
        final id = _requiredInt(firstApiWord, 'id');
        final page = _requiredInt(firstApiWord, 'page_number');
        final line = _requiredInt(firstApiWord, 'line_number');
        if (page < 1 || page > 604 || line < 1) {
          throw FormatException('Invalid QUL Mushaf position $page:$line.');
        }
        if (group.any(
          (part) =>
              _requiredInt(part, 'page_number') != page ||
              _requiredInt(part, 'line_number') != line,
        )) {
          throw FormatException(
            'Joined canonical word $location crosses a Mushaf line.',
          );
        }
        final word = _PositionedWord(
          word: QulMaterializedWord(
            id: id,
            location: location,
            surah: identity.surah,
            ayah: identity.ayah,
            position: position,
            text: group
                .map((part) => _requiredString(part, 'text_indopak_nastaleeq'))
                .join(' '),
          ),
          pageNumber: page,
          physicalLineNumber: line,
        );
        words.add(word);
        firstWordBySurah.putIfAbsent(identity.surah, () => word);
      }
    }
  }

  if (words.isEmpty)
    throw const FormatException('QUL response contains no Quran words.');
  final lines = _materializeLines(words, firstWordBySurah);
  return QulMaterializedSources(
    words: List.unmodifiable(words.map((word) => word.word).toList()),
    lines: List.unmodifiable(lines),
  );
}

List<List<Map<String, dynamic>>> _canonicalWordGroups(
  String verseKey,
  List<Map<String, dynamic>> apiWords,
  int expectedCount,
  Set<String> joinedCanonicalLocations,
) {
  if (apiWords.length == expectedCount) {
    return [
      for (final word in apiWords) [word],
    ];
  }
  final joinedPositions = joinedCanonicalLocations
      .where((location) => location.startsWith('$verseKey:'))
      .map((location) => _parseWordLocation(location).position)
      .toList();
  if (apiWords.length != expectedCount + 1 || joinedPositions.length != 1) {
    throw FormatException(
      'QUL verse $verseKey has ${apiWords.length} text words but canonical source expects $expectedCount.',
    );
  }
  final joinedPosition = joinedPositions.single;
  if (joinedPosition < 1 || joinedPosition > expectedCount) {
    throw FormatException(
      'Invalid joined canonical location $verseKey:$joinedPosition.',
    );
  }
  final groups = <List<Map<String, dynamic>>>[];
  var apiIndex = 0;
  for (var position = 1; position <= expectedCount; position++) {
    final partCount = position == joinedPosition ? 2 : 1;
    groups.add(apiWords.sublist(apiIndex, apiIndex + partCount));
    apiIndex += partCount;
  }
  return groups;
}

void writeQulMaterializedSqlite(
  QulMaterializedSources sources, {
  required String scriptPath,
  required String layoutPath,
}) {
  _writeSqliteAtomically(scriptPath, (database) {
    database.execute('''
      CREATE TABLE words (
        id INTEGER NOT NULL PRIMARY KEY,
        location TEXT NOT NULL UNIQUE,
        surah INTEGER NOT NULL,
        ayah INTEGER NOT NULL,
        word INTEGER NOT NULL,
        text TEXT NOT NULL
      )
    ''');
    for (final word in sources.words) {
      database.execute(
        'INSERT INTO words (id, location, surah, ayah, word, text) VALUES (?, ?, ?, ?, ?, ?)',
        [
          word.id,
          word.location,
          word.surah,
          word.ayah,
          word.position,
          word.text,
        ],
      );
    }
  });
  _writeSqliteAtomically(layoutPath, (database) {
    database.execute('''
      CREATE TABLE pages (
        page_number INTEGER NOT NULL,
        line_number INTEGER NOT NULL,
        line_type TEXT NOT NULL,
        is_centered INTEGER NOT NULL,
        first_word_id INTEGER,
        last_word_id INTEGER,
        surah_number INTEGER,
        PRIMARY KEY (page_number, line_number)
      )
    ''');
    for (final line in sources.lines) {
      database.execute(
        'INSERT INTO pages '
        '(page_number, line_number, line_type, is_centered, first_word_id, last_word_id, surah_number) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)',
        [
          line.pageNumber,
          line.lineNumber,
          line.lineType,
          line.isCentered ? 1 : 0,
          line.firstWordId,
          line.lastWordId,
          line.surahNumber,
        ],
      );
    }
  });
}

List<QulMaterializedLine> _materializeLines(
  List<_PositionedWord> words,
  Map<int, _PositionedWord> firstWordBySurah,
) {
  final occupied = <_PhysicalPosition, List<_PositionedWord>>{};
  for (final word in words) {
    occupied.putIfAbsent(word.position, () => []).add(word);
  }
  final metadataBefore = <_PhysicalPosition, List<_MetadataLine>>{};
  for (final entry in firstWordBySurah.entries) {
    final surah = entry.key;
    final first = entry.value;
    final types = <String>[
      'surah_name',
      if (surah >= 2 && surah != 9) 'basmallah',
    ];
    metadataBefore[first.position] = [
      for (final type in types) _MetadataLine(type, surah),
    ];
  }

  final positions = occupied.keys.toList()
    ..sort((a, b) {
      final page = a.pageNumber.compareTo(b.pageNumber);
      return page != 0 ? page : a.lineNumber.compareTo(b.lineNumber);
    });
  final normalizedLineNumbers = <int, int>{};
  final result = <QulMaterializedLine>[];
  for (final physical in positions) {
    for (final metadataLine in metadataBefore[physical] ?? const []) {
      final normalized = (normalizedLineNumbers[physical.pageNumber] ?? 0) + 1;
      normalizedLineNumbers[physical.pageNumber] = normalized;
      result.add(
        QulMaterializedLine(
          pageNumber: physical.pageNumber,
          lineNumber: normalized,
          lineType: metadataLine.type,
          isCentered: true,
          surahNumber: metadataLine.surahNumber,
        ),
      );
    }
    final normalized = (normalizedLineNumbers[physical.pageNumber] ?? 0) + 1;
    normalizedLineNumbers[physical.pageNumber] = normalized;
    final wordsOnLine = occupied[physical]!
      ..sort((a, b) => a.word.id.compareTo(b.word.id));
    result.add(
      QulMaterializedLine(
        pageNumber: physical.pageNumber,
        lineNumber: normalized,
        lineType: 'ayah',
        isCentered: false,
        surahNumber: wordsOnLine.first.word.surah,
        firstWordId: wordsOnLine.first.word.id,
        lastWordId: wordsOnLine.last.word.id,
      ),
    );
  }
  return result;
}

void _validateMarker(
  Map<String, dynamic> marker,
  int surah,
  int ayah,
  String verseKey,
) {
  final location = _requiredString(marker, 'location');
  final identity = _parseWordLocation(location);
  if (identity.surah != surah ||
      identity.ayah != ayah ||
      marker['text'] != _arabicIndicDigits(ayah)) {
    throw FormatException(
      'QUL verse $verseKey must end with its numbered ayah marker.',
    );
  }
}

String _arabicIndicDigits(int value) => value
    .toString()
    .runes
    .map((rune) => String.fromCharCode(0x0660 + rune - 0x30))
    .join();

void _writeSqliteAtomically(String path, void Function(Database) write) {
  final target = File(path);
  final staged = File('$path.tmp');
  if (staged.existsSync()) staged.deleteSync();
  target.parent.createSync(recursive: true);
  final database = sqlite3.open(staged.path);
  try {
    database.execute('BEGIN IMMEDIATE;');
    write(database);
    database.execute('COMMIT;');
  } catch (_) {
    database.execute('ROLLBACK;');
    rethrow;
  } finally {
    database.close();
  }
  if (target.existsSync()) target.deleteSync();
  staged.renameSync(target.path);
}

class _PositionedWord {
  const _PositionedWord({
    required this.word,
    required this.pageNumber,
    required this.physicalLineNumber,
  });

  final QulMaterializedWord word;
  final int pageNumber;
  final int physicalLineNumber;

  _PhysicalPosition get position =>
      _PhysicalPosition(pageNumber, physicalLineNumber);
}

class _PhysicalPosition {
  const _PhysicalPosition(this.pageNumber, this.lineNumber);

  final int pageNumber;
  final int lineNumber;

  @override
  bool operator ==(Object other) =>
      other is _PhysicalPosition &&
      other.pageNumber == pageNumber &&
      other.lineNumber == lineNumber;

  @override
  int get hashCode => Object.hash(pageNumber, lineNumber);
}

class _MetadataLine {
  const _MetadataLine(this.type, this.surahNumber);

  final String type;
  final int surahNumber;
}

class _VerseIdentity {
  const _VerseIdentity(this.surah, this.ayah);

  final int surah;
  final int ayah;
}

class _WordIdentity extends _VerseIdentity {
  const _WordIdentity(super.surah, super.ayah, this.position);

  final int position;
}

_VerseIdentity _parseVerseKey(String key) {
  final match = RegExp(r'^(\d+):(\d+)$').firstMatch(key);
  if (match == null) throw FormatException('Invalid QUL verse key $key.');
  return _VerseIdentity(int.parse(match.group(1)!), int.parse(match.group(2)!));
}

_WordIdentity _parseWordLocation(String location) {
  final match = RegExp(r'^(\d+):(\d+):(\d+)$').firstMatch(location);
  if (match == null)
    throw FormatException('Invalid QUL word location $location.');
  return _WordIdentity(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

List<Map<String, dynamic>> _requiredObjectList(
  Map<String, dynamic> value,
  String field,
) {
  final raw = value[field];
  if (raw is! List) throw FormatException('Expected QUL $field list.');
  return raw
      .map((entry) {
        if (entry is! Map) throw FormatException('Expected QUL $field object.');
        return Map<String, dynamic>.from(entry);
      })
      .toList(growable: false);
}

String _requiredString(Map<String, dynamic> value, String field) {
  final result = value[field];
  if (result is! String || result.trim().isEmpty) {
    throw FormatException('Expected non-empty QUL $field.');
  }
  return result;
}

int _requiredInt(Map<String, dynamic> value, String field) {
  final result = value[field];
  if (result is! int) throw FormatException('Expected integer QUL $field.');
  return result;
}
