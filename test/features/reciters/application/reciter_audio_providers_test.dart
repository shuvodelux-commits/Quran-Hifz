import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/network/quran_backend_client.dart';
import 'package:quran_hifz/core/network/quran_backend_providers.dart';
import 'package:quran_hifz/features/reciters/application/reciter_audio_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'catalog exposes every chapter reciter returned by the backend',
    () async {
      final client = _FakeQuranBackendClient();
      final container = ProviderContainer(
        overrides: [quranBackendClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);
      addTearDown(client.close);

      final rows = await container
          .read(reciterCatalogSourceProvider)
          .fetchChapterReciters();

      expect(rows.map((row) => row['id']), [3, 7]);
    },
  );

  test('chapter audio is fetched on demand for the chosen reciter', () async {
    final client = _FakeQuranBackendClient();
    final container = ProviderContainer(
      overrides: [quranBackendClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);
    addTearDown(client.close);

    final result = await container
        .read(chapterAudioSourceProvider)
        .loadChapterAudio(reciterId: 7, surahNumber: 67);

    expect(result['audio_file'], {
      'id': 7067,
      'chapter_id': 67,
      'file_size': 1234,
      'format': 'mp3',
      'audio_url': 'https://audio.example/7/67.mp3',
      'timestamps': <Object>[],
    });
  });

  test(
    'bundled reciter remains available when the backend is offline',
    () async {
      final client = _FakeQuranBackendClient(fail: true);
      final container = ProviderContainer(
        overrides: [quranBackendClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);
      addTearDown(client.close);

      final rows = await container
          .read(reciterCatalogSourceProvider)
          .fetchChapterReciters();

      expect(rows.map((row) => row['id']), [7]);
    },
  );

  test(
    'bundled chapter metadata remains usable when the backend is offline',
    () async {
      final client = _FakeQuranBackendClient(fail: true);
      final container = ProviderContainer(
        overrides: [quranBackendClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);
      addTearDown(client.close);

      final result = await container
          .read(chapterAudioSourceProvider)
          .loadChapterAudio(reciterId: 7, surahNumber: 67);

      expect((result['audio_file'] as Map)['id'], 1043);
    },
  );
}

class _FakeQuranBackendClient extends QuranBackendClient {
  _FakeQuranBackendClient({this.fail = false});

  final bool fail;

  @override
  Future<List<Map<String, dynamic>>> getChapterReciters() async {
    if (fail) throw StateError('Backend offline.');
    return [
      {
        'id': 3,
        'name': 'Abu Bakr al-Shatri',
        'style': {'name': 'Murattal', 'language_name': 'english'},
        'qirat': {'name': 'Hafs', 'language_name': 'english'},
      },
      {
        'id': 7,
        'name': 'Mishari Rashid al-Afasy',
        'style': {'name': 'Murattal', 'language_name': 'english'},
        'qirat': {'name': 'Hafs', 'language_name': 'english'},
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getChapterAudio({
    required int reciterId,
    required int surahNumber,
    bool segments = true,
  }) async {
    if (fail) throw StateError('Backend offline.');
    if (reciterId != 7 || surahNumber != 67 || !segments) {
      throw StateError('Unexpected chapter-audio request.');
    }
    return {
      'audio_file': {
        'id': 7067,
        'chapter_id': 67,
        'file_size': 1234,
        'format': 'mp3',
        'audio_url': 'https://audio.example/7/67.mp3',
        'timestamps': <Object>[],
      },
    };
  }
}
