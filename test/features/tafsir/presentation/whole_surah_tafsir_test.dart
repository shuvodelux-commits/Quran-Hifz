import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/tafsir/application/tafsir_providers.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_entry.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_repository.dart';
import 'package:quran_hifz/features/tafsir/presentation/tafsir_reader_page.dart';

class _Repository implements TafsirRepository {
  @override
  Future<List<TafsirSource>> listInstalledSources() async => const [
    TafsirSource(sourceId: 'test', name: 'Test', language: 'bn', version: '1'),
  ];

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async => null;

  @override
  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async => [
    for (var number = 1; number <= 2; number++)
      TafsirEntry(
        sourceId: sourceId,
        sourceName: 'Test',
        language: 'bn',
        version: '1',
        surahNumber: surahNumber,
        ayahNumber: number,
        text: 'Tafsir for ayah $number',
      ),
  ];
}

void main() {
  testWidgets('whole-Surah action displays all available Ayah Tafsir entries', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tafsirRepositoryProvider.overrideWithValue(_Repository())],
        child: const MaterialApp(
          home: TafsirReaderPage(
            surahNumber: 1,
            ayahNumber: 1,
            wholeSurah: true,
            ayahCount: 2,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tafsir for ayah 1'), findsOneWidget);
    expect(find.text('Tafsir for ayah 2'), findsOneWidget);
  });
}
