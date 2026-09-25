import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/network/quran_backend_client.dart';
import 'package:quran_hifz/features/tafsir/data/remote_quran_foundation_tafsir_repository.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_entry.dart';

void main() {
  test('maps Quran Foundation resources to qf source ids', () async {
    final repository = RemoteQuranFoundationTafsirRepository(
      _FakeBackend(
        resources: const [
          {
            'id': 169,
            'name': 'Tafsir Ibn Kathir',
            'author_name': 'Hafiz Ibn Kathir',
            'language_name': 'english',
            'translated_name': {
              'name': 'তাফসীর ইবনে কাসীর',
              'language_name': 'bengali',
            },
          },
        ],
      ),
    );

    final sources = await repository.listInstalledSources();

    expect(sources, hasLength(1));
    expect(sources.single.sourceId, 'qf.169');
    expect(sources.single.name, 'তাফসীর ইবনে কাসীর');
    expect(sources.single.kind, TafsirSourceKind.remote);
    expect(sources.single.availableOffline, isFalse);
  });

  test('normalizes remote ayah HTML into TafsirEntry text', () async {
    final repository = RemoteQuranFoundationTafsirRepository(
      _FakeBackend(
        ayah: const {
          'resource_id': 169,
          'resource_name': 'Tafsir Ibn Kathir',
          'language_name': 'english',
          'verse_key': '2:255',
          'chapter_id': 2,
          'verse_number': 255,
          'text': '<p>First line</p><p>Second &amp; third</p>',
        },
      ),
    );

    final entry = await repository.readAyah(
      sourceId: 'qf.169',
      surahNumber: 2,
      ayahNumber: 255,
    );

    expect(entry, isNotNull);
    expect(entry!.sourceId, 'qf.169');
    expect(entry.text, 'First line\nSecond & third');
    expect(entry.ayahNumber, 255);
  });

  test('maps whole Surah remote rows in backend order', () async {
    final repository = RemoteQuranFoundationTafsirRepository(
      _FakeBackend(
        surah: const [
          {
            'resource_id': 169,
            'resource_name': 'Test Tafsir',
            'language_name': 'english',
            'verse_key': '2:1',
            'chapter_id': 2,
            'verse_number': 1,
            'text': '<b>One</b>',
          },
          {
            'resource_id': 169,
            'resource_name': 'Test Tafsir',
            'language_name': 'english',
            'verse_key': '2:2',
            'chapter_id': 2,
            'verse_number': 2,
            'text': 'Two',
          },
        ],
      ),
    );

    final entries = await repository.readSurah(
      sourceId: 'qf.169',
      surahNumber: 2,
    );

    expect(entries.map((entry) => entry.ayahNumber), [1, 2]);
    expect(entries.map((entry) => entry.text), ['One', 'Two']);
  });
}

class _FakeBackend implements QuranTafsirBackendClient {
  _FakeBackend({this.resources = const [], this.ayah, this.surah = const []});

  final List<Map<String, dynamic>> resources;
  final Map<String, dynamic>? ayah;
  final List<Map<String, dynamic>> surah;

  @override
  Future<List<Map<String, dynamic>>> getTafsirResources({
    String language = 'bn',
  }) async => resources;

  @override
  Future<Map<String, dynamic>?> getTafsirAyah({
    required int resourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async => ayah;

  @override
  Future<List<Map<String, dynamic>>> getTafsirSurah({
    required int resourceId,
    required int surahNumber,
  }) async => surah;
}
