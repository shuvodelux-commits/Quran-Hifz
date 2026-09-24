import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/ayah_card.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/tafsir/application/tafsir_providers.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_entry.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_repository.dart';

void main() {
  testWidgets('ayah Tafsir action opens installed source with attribution', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          defaultRepeatCountProvider.overrideWith((ref) => 5),
          defaultPlaybackSpeedProvider.overrideWith((ref) => 1.0),
          tafsirRepositoryProvider.overrideWithValue(
            _FixtureTafsirRepository(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AyahCard(
              ayah: QuranAyah(
                surahNumber: 1,
                ayahNumber: 1,
                arabicText: 'بِسْمِ اللَّهِ',
                pageNumber: 1,
                juzNumber: 1,
                words: [QuranWord(position: 1, arabic: 'بِسْمِ')],
              ),
              showTranslation: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tafsir'));
    await tester.pumpAndSettle();

    expect(find.text('Fixture Tafsir'), findsOneWidget);
    expect(find.text('Verified fixture tafsir text'), findsOneWidget);
    await tester.tap(find.byTooltip('Open full tafsir'));
    await tester.pumpAndSettle();
    expect(find.text('Fixture attribution'), findsOneWidget);
  });
}

class _FixtureTafsirRepository implements TafsirRepository {
  @override
  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async => [];
  @override
  Future<List<TafsirSource>> listInstalledSources() async => const [
    TafsirSource(
      sourceId: 'bn.fixture',
      name: 'Fixture Tafsir',
      language: 'bn',
      version: '1',
      attribution: 'Fixture attribution',
    ),
  ];

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return const TafsirEntry(
      sourceId: 'bn.fixture',
      sourceName: 'Fixture Tafsir',
      language: 'bn',
      version: '1',
      surahNumber: 1,
      ayahNumber: 1,
      text: 'Verified fixture tafsir text',
      attribution: 'Fixture attribution',
    );
  }
}
