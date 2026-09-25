import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/tafsir/application/tafsir_providers.dart';
import 'package:quran_hifz/features/tafsir/data/tafsir_source_selection_store.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_catalog.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_entry.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_repository.dart';
import 'package:quran_hifz/features/tafsir/presentation/tafsir_reader_page.dart';

void main() {
  testWidgets('bundled Zakaria is readable immediately with no download CTA', (
    tester,
  ) async {
    final selection = _MemorySelectionStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tafsirRepositoryProvider.overrideWithValue(
            _MultipleSourcesRepository(),
          ),
          tafsirSourceSelectionStoreProvider.overrideWithValue(selection),
        ],
        child: const MaterialApp(
          home: TafsirReaderPage(surahNumber: 1, ayahNumber: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zakaria tafsir entry'), findsOneWidget);
    expect(find.text('Download tafsir'), findsNothing);
    expect(selection.value, primaryBanglaTafsirSourceId);
  });

  testWidgets('saved available source is restored', (tester) async {
    final selection = _MemorySelectionStore()..value = 'bn.other';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tafsirRepositoryProvider.overrideWithValue(
            _MultipleSourcesRepository(),
          ),
          tafsirSourceSelectionStoreProvider.overrideWithValue(selection),
        ],
        child: const MaterialApp(
          home: TafsirReaderPage(surahNumber: 1, ayahNumber: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Other entry'), findsOneWidget);
    expect(selection.value, 'bn.other');
  });

  testWidgets('missing saved source falls back to bundled Zakaria', (
    tester,
  ) async {
    final selection = _MemorySelectionStore()..value = 'bn.missing';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tafsirRepositoryProvider.overrideWithValue(
            _MultipleSourcesRepository(),
          ),
          tafsirSourceSelectionStoreProvider.overrideWithValue(selection),
        ],
        child: const MaterialApp(
          home: TafsirReaderPage(surahNumber: 1, ayahNumber: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zakaria tafsir entry'), findsOneWidget);
    expect(selection.value, primaryBanglaTafsirSourceId);
  });

  testWidgets('selected Quran Foundation source is marked online only', (
    tester,
  ) async {
    final selection = _MemorySelectionStore()..value = 'qf.169';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tafsirRepositoryProvider.overrideWithValue(
            _MultipleSourcesRepository(),
          ),
          tafsirSourceSelectionStoreProvider.overrideWithValue(selection),
        ],
        child: const MaterialApp(
          home: TafsirReaderPage(surahNumber: 1, ayahNumber: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Remote entry'), findsOneWidget);
    expect(find.text('Online source · internet required'), findsOneWidget);
  });

  testWidgets('changing Tafsir selector persists source id', (tester) async {
    final selection = _MemorySelectionStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tafsirRepositoryProvider.overrideWithValue(
            _MultipleSourcesRepository(),
          ),
          tafsirSourceSelectionStoreProvider.overrideWithValue(selection),
        ],
        child: const MaterialApp(
          home: TafsirReaderPage(surahNumber: 1, ayahNumber: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other Tafsir').last);
    await tester.pumpAndSettle();

    expect(selection.value, 'bn.other');
    expect(find.text('Other entry'), findsOneWidget);
  });
}

class _MemorySelectionStore implements TafsirSourceSelectionStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String sourceId) async {
    value = sourceId;
  }
}

class _MultipleSourcesRepository implements TafsirRepository {
  @override
  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async => [];

  @override
  Future<List<TafsirSource>> listInstalledSources() async => const [
    TafsirSource(
      sourceId: 'bn.other',
      name: 'Other Tafsir',
      language: 'bn',
      version: '1',
      kind: TafsirSourceKind.downloaded,
    ),
    TafsirSource(
      sourceId: primaryBanglaTafsirSourceId,
      name: primaryBanglaTafsirName,
      language: 'bn',
      version: '1.1.1',
      kind: TafsirSourceKind.bundled,
    ),
    TafsirSource(
      sourceId: 'qf.169',
      name: 'Remote Tafsir',
      language: 'en',
      version: 'quran-foundation-v4',
      kind: TafsirSourceKind.remote,
      availableOffline: false,
    ),
  ];

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (sourceId == 'qf.169') {
      return const TafsirEntry(
        sourceId: 'qf.169',
        sourceName: 'Remote Tafsir',
        language: 'en',
        version: 'quran-foundation-v4',
        surahNumber: 1,
        ayahNumber: 1,
        text: 'Remote entry',
      );
    }
    if (sourceId != primaryBanglaTafsirSourceId) {
      return const TafsirEntry(
        sourceId: 'bn.other',
        sourceName: 'Other Tafsir',
        language: 'bn',
        version: '1',
        surahNumber: 1,
        ayahNumber: 1,
        text: 'Other entry',
      );
    }
    return const TafsirEntry(
      sourceId: primaryBanglaTafsirSourceId,
      sourceName: primaryBanglaTafsirName,
      language: 'bn',
      version: '1.1.1',
      surahNumber: 1,
      ayahNumber: 1,
      text: 'Zakaria tafsir entry',
    );
  }
}
