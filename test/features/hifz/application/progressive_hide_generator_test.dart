import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/application/progressive_hide_generator.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';

void main() {
  const words = [
    QuranWord(position: 1, arabic: 'ONE'),
    QuranWord(position: 2, arabic: 'TWO'),
    QuranWord(position: 3, arabic: 'THREE'),
    QuranWord(position: 4, arabic: 'FOUR'),
    QuranWord(position: 5, arabic: 'FIVE'),
    QuranWord(position: 6, arabic: 'SIX'),
    QuranWord(position: 7, arabic: 'SEVEN'),
    QuranWord(position: 8, arabic: 'EIGHT'),
  ];

  test('same seed and config return the same deterministic mask', () {
    const generator = ProgressiveHideGenerator(seed: 67);

    final first = generator.maskFor(
      words,
      round: 2,
      difficulty: ProgressiveHideDifficulty.easy,
    );
    final second = generator.maskFor(
      words,
      round: 2,
      difficulty: ProgressiveHideDifficulty.easy,
    );

    expect(second, first);
  });

  test('later rounds only hide more words and eventually hide all', () {
    const generator = ProgressiveHideGenerator(seed: 67);

    final round0 = generator.maskFor(
      words,
      round: 0,
      difficulty: ProgressiveHideDifficulty.easy,
    );
    final round1 = generator.maskFor(
      words,
      round: 1,
      difficulty: ProgressiveHideDifficulty.easy,
    );
    final round2 = generator.maskFor(
      words,
      round: 2,
      difficulty: ProgressiveHideDifficulty.easy,
    );
    final finalRound = generator.maskFor(
      words,
      round: 4,
      difficulty: ProgressiveHideDifficulty.easy,
    );

    expect(round0, everyElement(isTrue));
    expect(round1.where((visible) => visible).length, lessThan(words.length));
    expect(
      round2.asMap().entries.every(
        (entry) => !entry.value || round1[entry.key],
      ),
      isTrue,
      reason: 'a later round must never reveal a word hidden earlier',
    );
    expect(finalRound, everyElement(isFalse));
  });

  test('generator never changes canonical word objects or Arabic strings', () {
    const generator = ProgressiveHideGenerator(seed: 99);
    final identities = words.map(identityHashCode).toList();
    final arabic = words.map((word) => word.arabic).toList();

    generator.maskFor(
      words,
      round: 1,
      difficulty: ProgressiveHideDifficulty.hard,
    );

    expect(words.map(identityHashCode).toList(), identities);
    expect(words.map((word) => word.arabic).toList(), arabic);
  });

  test('negative round is rejected', () {
    const generator = ProgressiveHideGenerator();

    expect(
      () => generator.maskFor(
        words,
        round: -1,
        difficulty: ProgressiveHideDifficulty.medium,
      ),
      throwsArgumentError,
    );
  });
}
