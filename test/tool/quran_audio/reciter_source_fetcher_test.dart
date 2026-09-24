import 'package:flutter_test/flutter_test.dart';

import '../../../tool/quran_content/source_fetcher.dart';

void main() {
  group('Quran Foundation chapter audio source', () {
    test(
      'fetchChapterReciters uses authenticated v4 chapter-reciter endpoint',
      () async {
        final transport = _RecordingTransport((call) {
          expect(call.method, 'GET');
          expect(call.uri.path, '/content/api/v4/resources/chapter_reciters');
          expect(call.uri.queryParameters['language'], 'en');
          expect(call.headers['x-auth-token'], 'token');
          expect(call.headers['x-client-id'], 'client');
          return const JsonHttpResponse(
            statusCode: 200,
            body: {
              'reciters': [
                {
                  'id': 7,
                  'name': 'Seven',
                  'style': {'name': 'Murattal', 'language_name': 'English'},
                  'qirat': {'name': 'Hafs', 'language_name': 'English'},
                },
              ],
            },
          );
        });
        final client = _client(transport);

        final rows = await client.fetchChapterReciters();

        expect(rows.single['id'], 7);
        expect(transport.calls, hasLength(1));
      },
    );

    test('fetchChapterAudio requests one Surah with segments', () async {
      final transport = _RecordingTransport((call) {
        expect(call.method, 'GET');
        expect(call.uri.path, '/content/api/v4/chapter_recitations/7/67');
        expect(call.uri.queryParameters['segments'], 'true');
        expect(call.headers['x-auth-token'], 'token');
        expect(call.headers['x-client-id'], 'client');
        return const JsonHttpResponse(
          statusCode: 200,
          body: {
            'audio_file': {
              'id': 1,
              'chapter_id': 67,
              'file_size': 100,
              'format': 'mp3',
              'audio_url': 'https://download.quranicaudio.com/test/067.mp3',
              'timestamps': [],
            },
          },
        );
      });
      final client = _client(transport);

      final payload = await client.fetchChapterAudio(
        reciterId: 7,
        surahNumber: 67,
        segments: true,
      );

      expect((payload['audio_file'] as Map)['chapter_id'], 67);
      expect(transport.calls, hasLength(1));
    });
  });
}

QuranFoundationClient _client(JsonTransport transport) => QuranFoundationClient(
  transport: transport,
  clientId: 'client',
  accessToken: 'token',
  apiBase: Uri.parse('https://api.example'),
  authBase: Uri.parse('https://auth.example'),
);

class _RecordedCall {
  const _RecordedCall({
    required this.method,
    required this.uri,
    required this.headers,
  });

  final String method;
  final Uri uri;
  final Map<String, String> headers;
}

class _RecordingTransport implements JsonTransport {
  _RecordingTransport(this.handler);

  final JsonHttpResponse Function(_RecordedCall call) handler;
  final calls = <_RecordedCall>[];

  @override
  Future<JsonHttpResponse> send({
    required String method,
    required Uri uri,
    Map<String, String> headers = const {},
    Map<String, String>? formFields,
    String? basicUsername,
    String? basicPassword,
  }) async {
    final call = _RecordedCall(
      method: method,
      uri: uri,
      headers: Map<String, String>.from(headers),
    );
    calls.add(call);
    return handler(call);
  }
}
