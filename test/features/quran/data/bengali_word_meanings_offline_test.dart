import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/quran/data/bengali_word_meanings.dart';

void main() {
  test(
    'a complete Surah remains available without HTTP after repository restart',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final client = MockClient((request) async {
        final page = int.parse(request.url.queryParameters['page']!);
        final verse = page == 1 ? '1:1' : '1:2';
        return http.Response(
          jsonEncode({
            'verses': [
              {
                'verse_key': verse,
                'words': [
                  {
                    'position': 1,
                    'char_type_name': 'word',
                    'translation': {'text': page == 1 ? 'নামে' : 'প্রশংসা'},
                  },
                ],
              },
            ],
            'pagination': {'next_page': page == 1 ? 2 : null, 'total_pages': 2},
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final meanings = QuranComBengaliWordMeanings(client, database: database);
      await meanings.downloadSurah(1, 2);
      expect(await meanings.isSurahDownloaded(1), isTrue);

      final offline = QuranComBengaliWordMeanings(
        MockClient((_) async => throw StateError('network used')),
        database: database,
      );
      expect(await offline.meaningFor('1:1', 1), 'নামে');
      expect(await offline.meaningFor('1:2', 1), 'প্রশংসা');
    },
  );
}
