import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/application/hifz_flow_composer.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';

void main() {
  final ayahs = [
    QuranAyah(
      surahNumber: 55,
      ayahNumber: 1,
      words: List.generate(
        4,
        (index) => QuranWord(position: index + 1, arabic: 'word$index'),
      ),
    ),
    QuranAyah(
      surahNumber: 55,
      ayahNumber: 2,
      words: List.generate(
        3,
        (index) => QuranWord(position: index + 1, arabic: 'next$index'),
      ),
    ),
  ];

  test('packs compact rows and caps justification gaps', () {
    final rows = HifzFlowComposer.compose(
      ayahs: ayahs,
      availableWidth: 300,
      minimumGap: 4,
      maximumGap: 12,
      measureWord: (_, __) => 60,
      measureMarker: (_) => 30,
    );

    expect(rows, hasLength(2));
    expect(rows.first.gap, inInclusiveRange(4, 12));
    expect(rows.last.gap, 4);
    expect(
      rows.expand((row) => row.tokens).where((token) => token.isMarker),
      hasLength(ayahs.length),
    );
  });

  test('moves an ayah final word with a marker instead of orphaning it', () {
    final rows = HifzFlowComposer.compose(
      ayahs: [ayahs.first],
      availableWidth: 220,
      minimumGap: 4,
      maximumGap: 12,
      measureWord: (_, __) => 60,
      measureMarker: (_) => 30,
    );

    expect(rows, hasLength(2));
    expect(rows.last.tokens, hasLength(2));
    expect(rows.last.tokens.first.word, isNotNull);
    expect(rows.last.tokens.last.isMarker, isTrue);
  });

  test('large unused width never produces exaggerated word spacing', () {
    final rows = HifzFlowComposer.compose(
      ayahs: [ayahs.first],
      availableWidth: 800,
      minimumGap: 4,
      maximumGap: 12,
      measureWord: (_, __) => 60,
      measureMarker: (_) => 30,
    );

    expect(rows.single.gap, 4);
    expect(rows.single.isTerminal, isTrue);
  });
}
