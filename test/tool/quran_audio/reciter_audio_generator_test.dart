import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/quran_audio/fetch_verified_reciter_audio.dart';
import '../../../tool/quran_content/source_fetcher.dart';

void main() {
  group('verified reciter audio generator', () {
    test(
      'fetches reciter catalog once and all 114 Surahs for requested ids',
      () async {
        final client = _FakeQuranFoundationClient(
          reciters: [_reciter(10, 'Ten'), _reciter(7, 'Seven')],
        );

        final catalog = await fetchVerifiedReciterAudioCatalog(
          client: client,
          reciterIds: const [7, 10],
          sourceVersion: 'content-api-v4-production-test',
          generatedAtUtc: DateTime.utc(2026, 9, 13),
        );

        expect(client.reciterFetchCount, 1);
        expect(client.chapterRequests, hasLength(228));
        expect(catalog.reciterIndex['reciters'], hasLength(2));
        expect(catalog.chaptersByReciter[7], hasLength(114));
        expect(catalog.chaptersByReciter[10], hasLength(114));
      },
    );

    test(
      'rejects a requested reciter id missing from the verified catalog',
      () async {
        final client = _FakeQuranFoundationClient(
          reciters: [_reciter(7, 'Seven')],
        );

        await expectLater(
          fetchVerifiedReciterAudioCatalog(
            client: client,
            reciterIds: const [99],
            sourceVersion: 'test',
            generatedAtUtc: DateTime.utc(2026, 9, 13),
          ),
          throwsStateError,
        );

        expect(client.chapterRequests, isEmpty);
      },
    );

    test(
      'writes generated targets while preserving hand-maintained audio assets',
      () async {
        final client = _FakeQuranFoundationClient(
          reciters: [_reciter(7, 'Seven')],
        );
        final catalog = await fetchVerifiedReciterAudioCatalog(
          client: client,
          reciterIds: const [7],
          sourceVersion: 'test',
          generatedAtUtc: DateTime.utc(2026, 9, 13),
        );
        final root = await Directory.systemTemp.createTemp(
          'reciter-audio-test-',
        );
        addTearDown(() => root.delete(recursive: true));
        final output = Directory('${root.path}/audio');
        await output.create(recursive: true);
        await File('${output.path}/stale.txt').writeAsString('stale');
        await File(
          '${output.path}/reciters_v1.json',
        ).writeAsString('old-index');
        final oldChapters = Directory('${output.path}/chapters_v1');
        await oldChapters.create(recursive: true);
        await File('${oldChapters.path}/old.json').writeAsString('old-chapter');

        await writeVerifiedReciterAudioCatalog(
          outputDirectory: output,
          catalog: catalog,
        );

        expect(await File('${output.path}/stale.txt').readAsString(), 'stale');
        expect(
          File('${output.path}/chapters_v1/old.json').existsSync(),
          isFalse,
        );
        final index =
            jsonDecode(
                  await File('${output.path}/reciters_v1.json').readAsString(),
                )
                as Map<String, dynamic>;
        expect(index['schema_version'], 1);
        expect(
          Directory('${output.path}/chapters_v1').listSync(),
          hasLength(114),
        );
        expect(
          File('${output.path}/chapters_v1/7-67.json').existsSync(),
          isTrue,
        );
      },
    );

    test(
      'rejects duplicate or invalid requested reciter ids before fetching',
      () async {
        final client = _FakeQuranFoundationClient(
          reciters: [_reciter(7, 'Seven')],
        );

        await expectLater(
          fetchVerifiedReciterAudioCatalog(
            client: client,
            reciterIds: const [7, 7],
            sourceVersion: 'test',
            generatedAtUtc: DateTime.utc(2026, 9, 13),
          ),
          throwsArgumentError,
        );
        await expectLater(
          fetchVerifiedReciterAudioCatalog(
            client: client,
            reciterIds: const [0],
            sourceVersion: 'test',
            generatedAtUtc: DateTime.utc(2026, 9, 13),
          ),
          throwsArgumentError,
        );

        expect(client.reciterFetchCount, 0);
      },
    );
  });
}

Map<String, dynamic> _reciter(int id, String name) => {
  'id': id,
  'name': name,
  'style': {'name': 'Murattal', 'language_name': 'English'},
  'qirat': {'name': 'Hafs', 'language_name': 'English'},
};

class _FakeQuranFoundationClient extends QuranFoundationClient {
  _FakeQuranFoundationClient({required this.reciters})
    : super(
        transport: _UnusedTransport(),
        clientId: 'client',
        accessToken: 'token',
        apiBase: Uri.parse('https://api.example'),
        authBase: Uri.parse('https://auth.example'),
      );

  final List<Map<String, dynamic>> reciters;
  int reciterFetchCount = 0;
  final chapterRequests = <(int, int, bool)>[];

  @override
  Future<List<Map<String, dynamic>>> fetchChapterReciters({
    String language = 'en',
  }) async {
    reciterFetchCount++;
    return reciters;
  }

  @override
  Future<Map<String, dynamic>> fetchChapterAudio({
    required int reciterId,
    required int surahNumber,
    bool segments = true,
  }) async {
    chapterRequests.add((reciterId, surahNumber, segments));
    return {
      'audio_file': {
        'id': reciterId * 1000 + surahNumber,
        'chapter_id': surahNumber,
        'file_size': 1000 + surahNumber,
        'format': 'mp3',
        'audio_url':
            'https://download.quranicaudio.com/test/$reciterId/$surahNumber.mp3',
        'timestamps': [
          {
            'verse_key': '$surahNumber:1',
            'timestamp_from': 0,
            'timestamp_to': 1000,
            'duration': 1000,
            'segments': [
              [1, 0, 500],
            ],
          },
        ],
      },
    };
  }
}

class _UnusedTransport implements JsonTransport {
  @override
  Future<JsonHttpResponse> send({
    required String method,
    required Uri uri,
    Map<String, String> headers = const {},
    Map<String, String>? formFields,
    String? basicUsername,
    String? basicPassword,
  }) {
    throw StateError('Network transport must not be used by this fake.');
  }
}
