import 'dart:convert';
import 'dart:io';

typedef QulResponseFetcher = Future<String> Function(Uri uri);

const qulChapterVersesEndpoint = 'https://qul.tarteel.ai/api/v1';

/// Fetches all 114 public QUL chapter payloads without credentials.
Future<List<Map<String, dynamic>>> fetchQulMushafResponses(
  QulResponseFetcher fetch, {
  int chapterCount = 114,
}) async {
  final responses = <Map<String, dynamic>>[];
  for (var chapter = 1; chapter <= chapterCount; chapter++) {
    final body = await fetch(qulChapterVersesUri(chapter));
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw FormatException('QUL chapter $chapter response is not an object.');
    }
    responses.add(Map<String, dynamic>.from(decoded));
  }
  return List.unmodifiable(responses);
}

Uri qulChapterVersesUri(int chapter) {
  if (chapter < 1 || chapter > 114) {
    throw RangeError.range(chapter, 1, 114, 'chapter');
  }
  return Uri.https('qul.tarteel.ai', '/api/v1/chapters/$chapter/verses.json', {
    'words': 'true',
    'mushaf': '3',
    'fields': 'text_indopak_nastaleeq',
    'word_fields': 'text_indopak_nastaleeq,location',
    'per_page': '286',
    'page': '1',
  });
}

Future<String> getPublicQulResponse(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'QUL request failed with HTTP ${response.statusCode}.',
        uri: uri,
      );
    }
    return body;
  } finally {
    client.close(force: true);
  }
}
