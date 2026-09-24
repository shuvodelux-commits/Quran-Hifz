import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/tafsir/application/tafsir_providers.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_catalog.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_entry.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_repository.dart';
import 'package:quran_hifz/features/tafsir/presentation/tafsir_reader_page.dart';

void main() {
  testWidgets(
    'empty tafsir state offers Abu Bakar Zakaria as primary Bangla source',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tafsirRepositoryProvider.overrideWithValue(_EmptyRepository()),
          ],
          child: const MaterialApp(
            home: TafsirReaderPage(surahNumber: 1, ayahNumber: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(primaryBanglaTafsirName), findsOneWidget);
      expect(find.text('Download tafsir'), findsOneWidget);
    },
  );

  testWidgets('installed Abu Bakar Zakaria source is preferred by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tafsirRepositoryProvider.overrideWithValue(
            _MultipleSourcesRepository(),
          ),
        ],
        child: const MaterialApp(
          home: TafsirReaderPage(surahNumber: 1, ayahNumber: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zakaria tafsir entry'), findsOneWidget);
  });
}

class _EmptyRepository implements TafsirRepository {
  @override
  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async => [];
  @override
  Future<List<TafsirSource>> listInstalledSources() async => const [];

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async => null;
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
    ),
    TafsirSource(
      sourceId: primaryBanglaTafsirSourceId,
      name: primaryBanglaTafsirName,
      language: 'bn',
      version: '1.1.1',
    ),
  ];

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
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
