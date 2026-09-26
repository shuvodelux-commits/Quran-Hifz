import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/tafsir/data/composite_tafsir_repository.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_catalog.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_entry.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_repository.dart';

void main() {
  test('lists bundled Zakaria beside another downloaded source', () async {
    final repository = CompositeTafsirRepository(
      bundled: _FakeRepository(
        sources: const [_bundledZakaria],
        entries: {'$primaryBanglaTafsirSourceId:1:1': _bundledEntry},
      ),
      downloaded: _FakeRepository(
        sources: const [
          TafsirSource(
            sourceId: 'bn.other',
            name: 'Other',
            language: 'bn',
            version: '1',
            kind: TafsirSourceKind.downloaded,
          ),
        ],
      ),
    );

    final sources = await repository.listSources();

    expect(sources.map((source) => source.sourceId), [
      primaryBanglaTafsirSourceId,
      'bn.other',
    ]);
  });

  test('installed source listing never touches the remote catalog', () async {
    final remote = _FakeRepository(
      sources: const [
        TafsirSource(
          sourceId: 'qf.169',
          name: 'Remote',
          language: 'bn',
          version: 'quran-foundation-v4',
          kind: TafsirSourceKind.remote,
          availableOffline: false,
        ),
      ],
    );
    final repository = CompositeTafsirRepository(
      bundled: _FakeRepository(
        sources: const [_bundledZakaria],
        entries: {'$primaryBanglaTafsirSourceId:1:1': _bundledEntry},
      ),
      downloaded: _FakeRepository(),
      remote: remote,
    );

    final sources = await repository.listInstalledSources();

    expect(sources.map((source) => source.sourceId), [
      primaryBanglaTafsirSourceId,
    ]);
    expect(remote.listCalls, 0);
  });

  test('remote catalog failure does not remove bundled Zakaria', () async {
    final repository = CompositeTafsirRepository(
      bundled: _FakeRepository(
        sources: const [_bundledZakaria],
        entries: {'$primaryBanglaTafsirSourceId:1:1': _bundledEntry},
      ),
      downloaded: _FakeRepository(),
      remote: _FakeRepository(throwOnList: true),
    );

    final sources = await repository.listSources();

    expect(sources.map((source) => source.sourceId), [
      primaryBanglaTafsirSourceId,
    ]);
  });

  test('newer downloaded Zakaria wins without duplicate source', () async {
    final downloadedEntry = _entry(version: '1.2.0', text: 'downloaded');
    final repository = CompositeTafsirRepository(
      bundled: _FakeRepository(
        sources: const [_bundledZakaria],
        entries: {'$primaryBanglaTafsirSourceId:1:1': _bundledEntry},
      ),
      downloaded: _FakeRepository(
        sources: const [
          TafsirSource(
            sourceId: primaryBanglaTafsirSourceId,
            name: 'Downloaded Zakaria',
            language: 'bn',
            version: '1.2.0',
            kind: TafsirSourceKind.downloaded,
          ),
        ],
        entries: {'$primaryBanglaTafsirSourceId:1:1': downloadedEntry},
      ),
    );

    final sources = await repository.listSources();
    final entry = await repository.readAyah(
      sourceId: primaryBanglaTafsirSourceId,
      surahNumber: 1,
      ayahNumber: 1,
    );

    expect(
      sources.where((source) => source.sourceId == primaryBanglaTafsirSourceId),
      hasLength(1),
    );
    expect(sources.first.version, '1.2.0');
    expect(entry?.text, 'downloaded');
  });

  test('older downloaded Zakaria does not hide bundled source', () async {
    final repository = CompositeTafsirRepository(
      bundled: _FakeRepository(
        sources: const [_bundledZakaria],
        entries: {'$primaryBanglaTafsirSourceId:1:1': _bundledEntry},
      ),
      downloaded: _FakeRepository(
        sources: const [
          TafsirSource(
            sourceId: primaryBanglaTafsirSourceId,
            name: 'Old Zakaria',
            language: 'bn',
            version: '1.0.0',
            kind: TafsirSourceKind.downloaded,
          ),
        ],
        entries: {
          '$primaryBanglaTafsirSourceId:1:1': _entry(
            version: '1.0.0',
            text: 'old',
          ),
        },
      ),
    );

    final sources = await repository.listSources();
    final entry = await repository.readAyah(
      sourceId: primaryBanglaTafsirSourceId,
      surahNumber: 1,
      ayahNumber: 1,
    );

    expect(sources.first.kind, TafsirSourceKind.bundled);
    expect(entry?.text, 'bundled');
  });

  test('broken newer downloaded Zakaria falls back to bundled', () async {
    final repository = CompositeTafsirRepository(
      bundled: _FakeRepository(
        sources: const [_bundledZakaria],
        entries: {'$primaryBanglaTafsirSourceId:1:1': _bundledEntry},
      ),
      downloaded: _FakeRepository(
        sources: const [
          TafsirSource(
            sourceId: primaryBanglaTafsirSourceId,
            name: 'Broken Zakaria',
            language: 'bn',
            version: '9.0.0',
            kind: TafsirSourceKind.downloaded,
          ),
        ],
        throwOnRead: true,
      ),
    );

    final sources = await repository.listSources();
    final entry = await repository.readAyah(
      sourceId: primaryBanglaTafsirSourceId,
      surahNumber: 1,
      ayahNumber: 1,
    );

    expect(sources.first.kind, TafsirSourceKind.bundled);
    expect(entry?.text, 'bundled');
  });
}

const _bundledZakaria = TafsirSource(
  sourceId: primaryBanglaTafsirSourceId,
  name: 'Bundled Zakaria',
  language: 'bn',
  version: '1.1.1',
  kind: TafsirSourceKind.bundled,
);

const _bundledEntry = TafsirEntry(
  sourceId: primaryBanglaTafsirSourceId,
  sourceName: 'Bundled Zakaria',
  language: 'bn',
  version: '1.1.1',
  surahNumber: 1,
  ayahNumber: 1,
  text: 'bundled',
);

TafsirEntry _entry({required String version, required String text}) =>
    TafsirEntry(
      sourceId: primaryBanglaTafsirSourceId,
      sourceName: 'Zakaria',
      language: 'bn',
      version: version,
      surahNumber: 1,
      ayahNumber: 1,
      text: text,
    );

class _FakeRepository implements TafsirRepository {
  _FakeRepository({
    this.sources = const [],
    this.entries = const {},
    this.throwOnRead = false,
    this.throwOnList = false,
  });

  final List<TafsirSource> sources;
  final Map<String, TafsirEntry> entries;
  final bool throwOnRead;
  final bool throwOnList;
  int listCalls = 0;

  @override
  Future<List<TafsirSource>> listInstalledSources() async {
    listCalls++;
    if (throwOnList) throw StateError('remote unavailable');
    return sources;
  }

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (throwOnRead) throw StateError('corrupt package');
    return entries['$sourceId:$surahNumber:$ayahNumber'];
  }

  @override
  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async {
    if (throwOnRead) throw StateError('corrupt package');
    return entries.values
        .where(
          (entry) =>
              entry.sourceId == sourceId && entry.surahNumber == surahNumber,
        )
        .toList()
      ..sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));
  }
}
