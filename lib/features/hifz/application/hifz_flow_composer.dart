import '../../quran/domain/quran_ayah.dart';
import '../../quran/domain/quran_word.dart';

class HifzFlowToken {
  const HifzFlowToken.word({
    required this.ayah,
    required QuranWord this.word,
    required this.width,
  }) : isMarker = false;

  const HifzFlowToken.marker({required this.ayah, required this.width})
    : word = null,
      isMarker = true;

  final QuranAyah ayah;
  final QuranWord? word;
  final double width;
  final bool isMarker;
}

class HifzFlowRow {
  const HifzFlowRow({
    required this.tokens,
    required this.gap,
    required this.isTerminal,
  });

  final List<HifzFlowToken> tokens;
  final double gap;
  final bool isTerminal;
}

abstract final class HifzFlowComposer {
  static List<HifzFlowRow> compose({
    required List<QuranAyah> ayahs,
    required double availableWidth,
    required double minimumGap,
    required double maximumGap,
    required double Function(QuranAyah ayah, QuranWord word) measureWord,
    required double Function(QuranAyah ayah) measureMarker,
  }) {
    assert(availableWidth > 0);
    assert(minimumGap >= 0);
    assert(maximumGap >= minimumGap);
    final packed = <List<HifzFlowToken>>[];
    var row = <HifzFlowToken>[];
    var used = 0.0;

    void flush() {
      if (row.isEmpty) return;
      packed.add(List.unmodifiable(row));
      row = <HifzFlowToken>[];
      used = 0;
    }

    void add(HifzFlowToken token) {
      final required = token.width + (row.isEmpty ? 0 : minimumGap);
      if (row.isNotEmpty && used + required > availableWidth) flush();
      used += token.width + (row.isEmpty ? 0 : minimumGap);
      row.add(token);
    }

    for (final ayah in ayahs) {
      for (final word in ayah.words) {
        add(
          HifzFlowToken.word(
            ayah: ayah,
            word: word,
            width: measureWord(ayah, word),
          ),
        );
      }
      final marker = HifzFlowToken.marker(
        ayah: ayah,
        width: measureMarker(ayah),
      );
      final required = marker.width + (row.isEmpty ? 0 : minimumGap);
      if (row.isNotEmpty && used + required > availableWidth) {
        final finalWord = row.removeLast();
        used -= finalWord.width + (row.isEmpty ? 0 : minimumGap);
        flush();
        add(finalWord);
      }
      add(marker);
    }
    flush();

    return List.generate(packed.length, (index) {
      final tokens = packed[index];
      final terminal = index == packed.length - 1;
      final naturalWidth = tokens.fold<double>(
        0,
        (sum, token) => sum + token.width,
      );
      final gap = terminal || tokens.length < 2
          ? minimumGap
          : ((availableWidth - naturalWidth) / (tokens.length - 1))
                .clamp(minimumGap, maximumGap)
                .toDouble();
      return HifzFlowRow(tokens: tokens, gap: gap, isTerminal: terminal);
    }, growable: false);
  }
}
