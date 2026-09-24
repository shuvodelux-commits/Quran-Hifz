import '../../quran/domain/quran_ayah.dart';
import '../../quran/domain/quran_mushaf_line.dart';
import '../../quran/domain/quran_page_window.dart';
import '../../quran/domain/quran_word.dart';

/// A canonical page word with the ayah data needed by the interactive view.
class HifzLineWord {
  const HifzLineWord({
    required this.location,
    required this.ayah,
    required this.word,
    required this.endsAyah,
  });

  final QuranWordLocation location;
  final QuranAyah ayah;
  final QuranWord word;
  final bool endsAyah;
}

/// Finds the largest size at or below [requestedSize] that fits a fixed line.
double fitRenderedFontSize({
  required double requestedSize,
  required bool Function(double size) fits,
}) {
  if (requestedSize <= 0 || fits(requestedSize)) return requestedSize;
  var low = 0.0;
  var high = requestedSize;
  for (var index = 0; index < 28; index++) {
    final candidate = (low + high) / 2;
    if (fits(candidate)) {
      low = candidate;
    } else {
      high = candidate;
    }
  }
  return low;
}

/// Resolves a stored fixed-line membership without changing its word order.
List<HifzLineWord> resolveMushafLine(
  QuranPageWindow window,
  QuranMushafLine line,
) {
  if (line.type != QuranMushafLineType.ayah) {
    throw ArgumentError.value(line, 'line', 'Only Quran lines contain words.');
  }
  final words = <String, ({QuranAyah ayah, QuranWord word})>{
    for (final ayah in window.ayahs)
      for (final word in ayah.words)
        '${ayah.key}:${word.position}': (ayah: ayah, word: word),
  };

  return List<HifzLineWord>.unmodifiable(
    line.wordLocations.map((location) {
      final match = words[location.toString()];
      if (match == null) {
        throw StateError(
          'Mushaf line ${line.lineNumber} references unavailable word '
          '${location}.',
        );
      }
      return HifzLineWord(
        location: location,
        ayah: match.ayah,
        word: match.word,
        endsAyah: match.word.position == match.ayah.words.last.position,
      );
    }),
  );
}
