import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/quran_content/qul_api_client.dart';

void main() {
  test(
    'requests every QUL chapter with resource-59 Nastaleeq and Mushaf 3 fields',
    () async {
      final requested = <Uri>[];

      final responses = await fetchQulMushafResponses((uri) async {
        requested.add(uri);
        return jsonEncode({'verses': []});
      });

      expect(responses, hasLength(114));
      expect(requested, hasLength(114));
      expect(
        requested.first.toString(),
        'https://qul.tarteel.ai/api/v1/chapters/1/verses.json?words=true&mushaf=3&fields=text_indopak_nastaleeq&word_fields=text_indopak_nastaleeq%2Clocation&per_page=286&page=1',
      );
      expect(requested.last.path, '/api/v1/chapters/114/verses.json');
      expect(
        requested.every((uri) => uri.queryParameters['words'] == 'true'),
        isTrue,
      );
      expect(
        requested.every((uri) => uri.queryParameters['mushaf'] == '3'),
        isTrue,
      );
      expect(
        requested.every(
          (uri) =>
              uri.queryParameters['fields'] == 'text_indopak_nastaleeq' &&
              uri.queryParameters['word_fields'] ==
                  'text_indopak_nastaleeq,location',
        ),
        isTrue,
      );
    },
  );
}
