import '../../quran/domain/quran_word.dart';

enum ProgressiveHideDifficulty { easy, medium, hard }

class ProgressiveHideGenerator {
  const ProgressiveHideGenerator({this.seed = 0});

  final int seed;

  List<bool> maskFor(
    List<QuranWord> words, {
    required int round,
    required ProgressiveHideDifficulty difficulty,
  }) {
    if (round < 0) {
      throw ArgumentError.value(round, 'round', 'must not be negative');
    }
    if (words.isEmpty) return const [];
    if (round == 0) return List<bool>.filled(words.length, true);

    final roundsToHidden = switch (difficulty) {
      ProgressiveHideDifficulty.easy => 4,
      ProgressiveHideDifficulty.medium => 3,
      ProgressiveHideDifficulty.hard => 2,
    };

    if (round >= roundsToHidden) {
      return List<bool>.filled(words.length, false);
    }

    final visibleFraction = 1 - (round / roundsToHidden);
    var visibleCount = (words.length * visibleFraction).ceil();
    if (visibleCount >= words.length) visibleCount = words.length - 1;
    if (visibleCount < 0) visibleCount = 0;

    final ranked = List<int>.generate(words.length, (index) => index)
      ..sort((left, right) {
        final leftScore = _score(words[left].position);
        final rightScore = _score(words[right].position);
        final scoreOrder = leftScore.compareTo(rightScore);
        return scoreOrder != 0 ? scoreOrder : left.compareTo(right);
      });

    final visibleIndexes = ranked.take(visibleCount).toSet();
    return List<bool>.generate(
      words.length,
      (index) => visibleIndexes.contains(index),
      growable: false,
    );
  }

  int _score(int position) {
    var value = (position ^ seed) & 0x7fffffff;
    value = (value * 1103515245 + 12345) & 0x7fffffff;
    value ^= (value >> 11);
    value = (value * 2654435761) & 0x7fffffff;
    return value;
  }
}
