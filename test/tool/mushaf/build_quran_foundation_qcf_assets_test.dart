import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../tool/mushaf/build_quran_foundation_qcf_assets.dart';

void main() {
  test('QCF V2 requests Mushaf 1 code_v2 data with auth headers', () async {
    late http.Request seen;
    final client = MockClient((request) async {
      seen = request;
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'verses': [_verseFixture()],
            'pagination': {'next_page': null},
          }),
        ),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final verses = await fetchQcfV2Chapter(
      client: client,
      apiBase: Uri.parse('https://apis.quran.foundation'),
      clientId: 'fixture-client',
      accessToken: 'fixture-token',
      chapter: 36,
    );

    expect(verses, hasLength(1));
    expect(seen.headers['x-client-id'], 'fixture-client');
    expect(seen.headers['x-auth-token'], 'fixture-token');
    expect(seen.url.queryParameters['mushaf'], '1');
    expect(seen.url.queryParameters['words'], 'true');
    expect(
      seen.url.queryParameters['word_fields'],
      'code_v2,text_qpc_hafs,page_number,line_number',
    );
  });

  test('builds Surah and Bismillah rows from canonical line gaps', () {
    final rows = buildQcfRows([QcfVerseInput.fromJson(_verseFixture())]);
    final layout = buildQcfLayout(rows);

    expect(layout.map((row) => row.lineType), [
      'surah_name',
      'basmallah',
      'ayah',
    ]);
    expect(layout[0].surahNumber, 36);
    expect(layout[0].lineNumber, 4);
    expect(layout[1].lineNumber, 5);
    expect(layout[2].lineNumber, 6);
    expect(layout[2].firstWordId, 1);
    expect(layout[2].lastWordId, 2);
  });

  test('writer preserves the shared script and layout schema', () {
    final directory = Directory.systemTemp.createTempSync('qcf-v2-writer-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final scriptPath = '${directory.path}/script.sqlite';
    final layoutPath = '${directory.path}/layout.sqlite';
    final rows = buildQcfRows([QcfVerseInput.fromJson(_verseFixture())]);
    writeQcfDatabases(
      scriptPath: scriptPath,
      layoutPath: layoutPath,
      rows: rows,
      layout: buildQcfLayout(rows),
      sourceDescription: 'fixture',
      generatedAt: '2026-09-26T00:00:00Z',
    );

    final script = sqlite3.open(scriptPath, mode: OpenMode.readOnly);
    final layout = sqlite3.open(layoutPath, mode: OpenMode.readOnly);
    addTearDown(script.close);
    addTearDown(layout.close);

    expect(
      script
          .select('SELECT display FROM words ORDER BY word_index')
          .map((row) => row['display']),
      ['A', 'B'],
    );
    expect(
      layout
          .select('SELECT line_type FROM pages ORDER BY line_number')
          .map((row) => row['line_type']),
      ['surah_name', 'basmallah', 'ayah'],
    );
  });
  test('production validation requires every page 1 through 604', () {
    final rows = buildQcfRows([QcfVerseInput.fromJson(_verseFixture())]);
    expect(
      () => validateProductionQcfData(rows, buildQcfLayout(rows)),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _verseFixture() => {
  'verse_key': '36:1',
  'page_number': 440,
  'words': [
    {
      'id': 1,
      'position': 1,
      'char_type_name': 'word',
      'code_v2': 'A',
      'text_qpc_hafs': 'يس',
      'page_number': 440,
      'line_number': 6,
    },
    {
      'id': 2,
      'position': 2,
      'char_type_name': 'end',
      'code_v2': 'B',
      'text_qpc_hafs': '١',
      'page_number': 440,
      'line_number': 6,
    },
  ],
};
