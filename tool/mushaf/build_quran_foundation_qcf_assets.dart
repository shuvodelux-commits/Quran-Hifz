import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sqlite3/sqlite3.dart';

class QcfWordInput {
  const QcfWordInput({
    required this.id,
    required this.position,
    required this.charType,
    required this.codeV2,
    required this.textQpcHafs,
    required this.pageNumber,
    required this.lineNumber,
  });

  final int id;
  final int position;
  final String charType;
  final String codeV2;
  final String textQpcHafs;
  final int pageNumber;
  final int lineNumber;
  factory QcfWordInput.fromJson(Map<String, dynamic> json) {
    return QcfWordInput(
      id: _requiredInt(json['id'], 'word.id'),
      position: _requiredInt(json['position'], 'word.position'),
      charType: _requiredString(json['char_type_name'], 'word.char_type_name'),
      codeV2: _requiredString(json['code_v2'], 'word.code_v2'),
      textQpcHafs: _requiredString(json['text_qpc_hafs'], 'word.text_qpc_hafs'),
      pageNumber: _requiredInt(json['page_number'], 'word.page_number'),
      lineNumber: _requiredInt(json['line_number'], 'word.line_number'),
    );
  }
}

class QcfVerseInput {
  const QcfVerseInput({
    required this.verseKey,
    required this.pageNumber,
    required this.words,
  });
  final String verseKey;
  final int pageNumber;
  final List<QcfWordInput> words;

  int get surahNumber => int.parse(verseKey.split(':').first);
  int get ayahNumber => int.parse(verseKey.split(':').last);

  factory QcfVerseInput.fromJson(Map<String, dynamic> json) {
    final words = json['words'];
    if (words is! List || words.isEmpty) {
      throw const FormatException('QCF verse is missing words.');
    }
    return QcfVerseInput(
      verseKey: _requiredString(json['verse_key'], 'verse.verse_key'),
      pageNumber: _requiredInt(json['page_number'], 'verse.page_number'),
      words: [
        for (final word in words)
          QcfWordInput.fromJson(_stringMap(word, 'word')),
      ],
    );
  }
}

class QcfBuildRow {
  const QcfBuildRow({
    required this.wordIndex,
    required this.remoteId,
    required this.ayahKey,
    required this.surahNumber,
    required this.ayahNumber,
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
  final int surahNumber;
  final int ayahNumber;
  final int? wordPosition;
  final String charType;
  final int pageNumber;
  final int lineNumber;
  final String display;
  final String unicodeFallback;
}

class QcfLayoutRow {
  const QcfLayoutRow({
    required this.pageNumber,
    required this.lineNumber,
    required this.lineType,
    required this.isCentered,
    this.firstWordId,
    this.lastWordId,
    this.surahNumber,
  });

  final int pageNumber;
  final int lineNumber;
  final String lineType;
  final bool isCentered;
  final int? firstWordId;
  final int? lastWordId;
  final int? surahNumber;
}

Future<List<QcfVerseInput>> fetchQcfV2Chapter({
  required http.Client client,
  required Uri apiBase,
  required String clientId,
  required String accessToken,
  required int chapter,
}) async {
  if (chapter < 1 || chapter > 114) {
    throw RangeError.range(chapter, 1, 114, 'chapter');
  }
  final verses = <QcfVerseInput>[];
  var page = 1;
  while (true) {
    final uri = apiBase
        .resolve('/content/api/v4/verses/by_chapter/$chapter')
        .replace(
          queryParameters: {
            'words': 'true',
            'word_fields': 'code_v2,text_qpc_hafs,page_number,line_number',
            'mushaf': '1',
            'per_page': '300',
            'page': '$page',
          },
        );
    final response = await client.get(
      uri,
      headers: {'x-client-id': clientId, 'x-auth-token': accessToken},
    );
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Quran Foundation chapter $chapter returned HTTP '
        '${response.statusCode}.',
        uri: uri,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('QCF response must be an object.');
    }
    final rawVerses = decoded['verses'];
    if (rawVerses is! List || rawVerses.isEmpty) {
      throw FormatException('QCF chapter $chapter returned no verses.');
    }
    for (final raw in rawVerses) {
      verses.add(QcfVerseInput.fromJson(_stringMap(raw, 'verse')));
    }
    final pagination = decoded['pagination'];
    final nextPage = pagination is Map
        ? _optionalInt(pagination['next_page'])
        : null;
    if (nextPage == null) break;
    if (nextPage <= page) {
      throw const FormatException('QCF pagination did not advance.');
    }
    page = nextPage;
  }
  return List.unmodifiable(verses);
}

List<QcfBuildRow> buildQcfRows(List<QcfVerseInput> verses) {
  var next = 1;
  final rows = <QcfBuildRow>[];
  for (final verse in verses) {
    for (final word in verse.words) {
      if (word.pageNumber < 1 || word.pageNumber > 604) {
        throw FormatException('Invalid QCF page ${word.pageNumber}.');
      }
      if (word.lineNumber < 1 || word.lineNumber > 15) {
        throw FormatException('Invalid QCF line ${word.lineNumber}.');
      }
      rows.add(
        QcfBuildRow(
          wordIndex: next++,
          remoteId: word.id,
          ayahKey: verse.verseKey,
          surahNumber: verse.surahNumber,
          ayahNumber: verse.ayahNumber,
          wordPosition: word.charType == 'word' ? word.position : null,
          charType: word.charType,
          pageNumber: word.pageNumber,
          lineNumber: word.lineNumber,
          display: word.codeV2,
          unicodeFallback: word.textQpcHafs,
        ),
      );
    }
  }
  return List.unmodifiable(rows);
}

List<QcfLayoutRow> buildQcfLayout(List<QcfBuildRow> rows) {
  final byLine = <(int, int), List<QcfBuildRow>>{};
  for (final row in rows) {
    byLine.putIfAbsent((row.pageNumber, row.lineNumber), () => []).add(row);
  }
  final layout = <QcfLayoutRow>[];
  for (final entry in byLine.entries) {
    final lineRows = entry.value
      ..sort((a, b) => a.wordIndex.compareTo(b.wordIndex));
    layout.add(
      QcfLayoutRow(
        pageNumber: entry.key.$1,
        lineNumber: entry.key.$2,
        lineType: 'ayah',
        isCentered: false,
        firstWordId: lineRows.first.wordIndex,
        lastWordId: lineRows.last.wordIndex,
      ),
    );
  }

  final firstAyahRows = <int, QcfBuildRow>{};
  for (final row in rows) {
    if (row.ayahNumber != 1) continue;
    final current = firstAyahRows[row.surahNumber];
    if (current == null || row.wordIndex < current.wordIndex) {
      firstAyahRows[row.surahNumber] = row;
    }
  }
  final occupied = <(int, int)>{
    for (final row in layout) (row.pageNumber, row.lineNumber),
  };
  for (final entry in firstAyahRows.entries) {
    final surah = entry.key;
    final first = entry.value;
    final hasBismillah = surah != 1 && surah != 9;
    final surahLine = first.lineNumber - (hasBismillah ? 2 : 1);
    final bismillahLine = first.lineNumber - 1;
    if (surahLine < 1 ||
        occupied.contains((first.pageNumber, surahLine)) ||
        (hasBismillah &&
            occupied.contains((first.pageNumber, bismillahLine)))) {
      throw FormatException(
        'No canonical metadata gap before Surah $surah on page '
        '${first.pageNumber}.',
      );
    }
    layout.add(
      QcfLayoutRow(
        pageNumber: first.pageNumber,
        lineNumber: surahLine,
        lineType: 'surah_name',
        isCentered: true,
        surahNumber: surah,
      ),
    );
    occupied.add((first.pageNumber, surahLine));
    if (hasBismillah) {
      layout.add(
        QcfLayoutRow(
          pageNumber: first.pageNumber,
          lineNumber: bismillahLine,
          lineType: 'basmallah',
          isCentered: true,
          surahNumber: surah,
        ),
      );
      occupied.add((first.pageNumber, bismillahLine));
    }
  }
  layout.sort((a, b) {
    final pageOrder = a.pageNumber.compareTo(b.pageNumber);
    return pageOrder != 0 ? pageOrder : a.lineNumber.compareTo(b.lineNumber);
  });
  return List.unmodifiable(layout);
}

void validateProductionQcfData(
  List<QcfBuildRow> rows,
  List<QcfLayoutRow> layout,
) {
  if (rows.isEmpty || layout.isEmpty) {
    throw const FormatException('QCF output must not be empty.');
  }
  for (var index = 0; index < rows.length; index++) {
    if (rows[index].wordIndex != index + 1) {
      throw const FormatException('QCF word indexes must be contiguous.');
    }
  }
  final pages = layout.map((row) => row.pageNumber).toSet();
  if (pages.length != 604 ||
      !pages.containsAll(List<int>.generate(604, (index) => index + 1))) {
    throw const FormatException('QCF layout must contain pages 1 through 604.');
  }
  final covered = <int>{};
  for (final line in layout.where((row) => row.lineType == 'ayah')) {
    final first = line.firstWordId;
    final last = line.lastWordId;
    if (first == null || last == null || first > last) {
      throw const FormatException('Invalid QCF ayah line range.');
    }
    for (var index = first; index <= last; index++) {
      if (!covered.add(index)) {
        throw const FormatException('QCF word is referenced more than once.');
      }
    }
  }
  if (covered.length != rows.length ||
      !covered.containsAll(rows.map((row) => row.wordIndex))) {
    throw const FormatException('QCF layout does not cover every script row.');
  }
}

void writeQcfDatabases({
  required String scriptPath,
  required String layoutPath,
  required List<QcfBuildRow> rows,
  required List<QcfLayoutRow> layout,
  required String sourceDescription,
  required String generatedAt,
}) {
  _writeScript(
    path: scriptPath,
    rows: rows,
    sourceDescription: sourceDescription,
    generatedAt: generatedAt,
  );
  _writeLayout(path: layoutPath, rows: layout);
}

void _writeScript({
  required String path,
  required List<QcfBuildRow> rows,
  required String sourceDescription,
  required String generatedAt,
}) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  if (file.existsSync()) file.deleteSync();
  final db = sqlite3.open(path);
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
    final insert = db.prepare(
      'INSERT INTO words VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    );
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
    final metadata = db.prepare(
      'INSERT INTO metadata(key, value) VALUES (?, ?)',
    );
    try {
      for (final entry in {
        'mushaf_id': '1',
        'script_kind': 'qcf_v2',
        'source': sourceDescription,
        'generated_at': generatedAt,
        'token_count': '${rows.length}',
        'page_count': rows
            .map((row) => row.pageNumber)
            .toSet()
            .length
            .toString(),
      }.entries) {
        metadata.execute([entry.key, entry.value]);
      }
    } finally {
      metadata.close();
    }
  } finally {
    db.close();
  }
}

void _writeLayout({required String path, required List<QcfLayoutRow> rows}) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  if (file.existsSync()) file.deleteSync();
  final db = sqlite3.open(path);
  try {
    db.execute('''
      CREATE TABLE pages (
        page_number INTEGER,
        line_number INTEGER,
        line_type TEXT,
        is_centered INTEGER,
        first_word_id INTEGER,
        last_word_id INTEGER,
        surah_number INTEGER
      );
    ''');
    final insert = db.prepare('INSERT INTO pages VALUES (?, ?, ?, ?, ?, ?, ?)');
    try {
      for (final row in rows) {
        insert.execute([
          row.pageNumber,
          row.lineNumber,
          row.lineType,
          row.isCentered ? 1 : 0,
          row.firstWordId,
          row.lastWordId,
          row.surahNumber,
        ]);
      }
    } finally {
      insert.close();
    }
  } finally {
    db.close();
  }
}

Future<String> _accessToken({
  required http.Client client,
  required Uri authBase,
  required String clientId,
  required String clientSecret,
}) async {
  final basic = base64Encode(utf8.encode('$clientId:$clientSecret'));
  final response = await client.post(
    authBase.resolve('/oauth2/token'),
    headers: {
      HttpHeaders.authorizationHeader: 'Basic $basic',
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    },
    body: {'grant_type': 'client_credentials', 'scope': 'content'},
  );
  if (response.statusCode != HttpStatus.ok) {
    throw HttpException(
      'Quran Foundation token request failed with HTTP '
      '${response.statusCode}.',
    );
  }
  final decoded = jsonDecode(response.body);
  if (decoded is! Map) {
    throw const FormatException('Quran Foundation token response is invalid.');
  }
  return _requiredString(decoded['access_token'], 'access_token');
}

Future<void> main(List<String> args) async {
  final clientId = _requiredEnvironment('QF_CLIENT_ID');
  final client = http.Client();
  try {
    var token = Platform.environment['QF_ACCESS_TOKEN']?.trim();
    if (token == null || token.isEmpty) {
      final secret = _requiredEnvironment('QF_CLIENT_SECRET');
      token = await _accessToken(
        client: client,
        authBase: Uri.parse('https://oauth2.quran.foundation'),
        clientId: clientId,
        clientSecret: secret,
      );
    }
    final verses = <QcfVerseInput>[];
    for (var chapter = 1; chapter <= 114; chapter++) {
      verses.addAll(
        await fetchQcfV2Chapter(
          client: client,
          apiBase: Uri.parse('https://apis.quran.foundation'),
          clientId: clientId,
          accessToken: token,
          chapter: chapter,
        ),
      );
    }
    final rows = buildQcfRows(verses);
    final layout = buildQcfLayout(rows);
    validateProductionQcfData(rows, layout);
    const source =
        'Quran Foundation Content API v4, Mushaf 1, code_v2/text_qpc_hafs';
    writeQcfDatabases(
      scriptPath: 'assets/mushaf/scripts/qcf-v2-words.sqlite',
      layoutPath: 'assets/mushaf/layouts/qcf-v2-15-lines.sqlite',
      rows: rows,
      layout: layout,
      sourceDescription: source,
      generatedAt: DateTime.now().toUtc().toIso8601String(),
    );
    stdout.writeln('Generated verified QCF V2 assets for 604 pages.');
  } finally {
    client.close();
  }
}

String _requiredEnvironment(String name) {
  final value = Platform.environment[name]?.trim();
  if (value == null || value.isEmpty) {
    throw StateError('$name is required in the environment.');
  }
  return value;
}

Map<String, dynamic> _stringMap(Object? raw, String name) {
  if (raw is! Map) throw FormatException('$name must be an object.');
  return raw.map((key, value) => MapEntry(key.toString(), value));
}

String _requiredString(Object? value, String name) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    throw FormatException('$name is required.');
  }
  return text;
}

int _requiredInt(Object? value, String name) {
  final parsed = _optionalInt(value);
  if (parsed == null) throw FormatException('$name must be an integer.');
  return parsed;
}

int? _optionalInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
