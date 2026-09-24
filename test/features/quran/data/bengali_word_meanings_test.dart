import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_hifz/features/quran/data/bengali_word_meanings.dart';

void main() {
  test('loads the Bengali gloss at the exact ayah word position', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v4/verses/by_key/1:1');
      expect(request.url.queryParameters['language'], 'bn');
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'verse': {
              'verse_key': '1:1',
              'words': [
                {
                  'position': 1,
                  'char_type_name': 'word',
                  'translation': {'text': 'নামে'},
                },
                {
                  'position': 2,
                  'char_type_name': 'word',
                  'translation': {'text': 'আল্লাহর'},
                },
                {
                  'position': 3,
                  'char_type_name': 'end',
                  'translation': {'text': '(১)'},
                },
              ],
            },
          }),
        ),
        200,
      );
    });
    final meanings = QuranComBengaliWordMeanings(client);
    expect(await meanings.meaningFor('1:1', 2), 'আল্লাহর');
    expect(await meanings.meaningFor('1:1', 3), isNull);
  });

  test('rejects mismatched ayah data', () async {
    final meanings = QuranComBengaliWordMeanings(
      MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'verse': {'verse_key': '1:2', 'words': []},
            }),
          ),
          200,
        ),
      ),
    );
    expect(() => meanings.meaningFor('1:1', 1), throwsFormatException);
  });
}
