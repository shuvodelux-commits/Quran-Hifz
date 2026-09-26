import 'package:flutter/material.dart';

import '../../domain/quran_word.dart';

class BismillahV4Glyph extends StatelessWidget {
  const BismillahV4Glyph({
    super.key,
    this.fontSize = 64,
    this.textAlign = TextAlign.center,
    this.useTajweedColors = true,
  });

  static const glyphs = 'ﱁﱂﱃﱄ';
  static const fontFamily = 'QPC V4 Tajweed P1';
  static const wordGlyphs = <String>['ﱁ', 'ﱂ', 'ﱃ', 'ﱄ'];

  final double fontSize;
  final TextAlign textAlign;
  final bool useTajweedColors;

  @override
  Widget build(BuildContext context) {
    final glyph = ExcludeSemantics(
      child: Text(
        glyphs,
        textDirection: TextDirection.rtl,
        textAlign: textAlign,
        maxLines: 1,
        style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, height: 1),
      ),
    );
    return Semantics(
      label: 'بسم الله الرحمن الرحيم',
      child: useTajweedColors
          ? glyph
          : ColorFiltered(
              key: const ValueKey('bismillah-monochrome'),
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
              child: glyph,
            ),
    );
  }
}

class BismillahV4WordRow extends StatelessWidget {
  const BismillahV4WordRow({
    super.key,
    required this.words,
    required this.fontSize,
    this.activeWordPosition,
    this.wordKeyFor,
    this.onTap,
    this.onLongPress,
    this.useTajweedColors = true,
  });

  final List<QuranWord> words;
  final double fontSize;
  final int? activeWordPosition;
  final Key Function(QuranWord word)? wordKeyFor;
  final ValueChanged<QuranWord>? onTap;
  final ValueChanged<QuranWord>? onLongPress;
  final bool useTajweedColors;

  @override
  Widget build(BuildContext context) {
    if (words.length != BismillahV4Glyph.wordGlyphs.length) {
      return BismillahV4Glyph(
        fontSize: fontSize,
        useTajweedColors: useTajweedColors,
      );
    }

    final highlight = Theme.of(context).colorScheme.primaryContainer;
    final row = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          for (var index = 0; index < words.length; index++)
            _BismillahWordGlyph(
              key:
                  wordKeyFor?.call(words[index]) ??
                  ValueKey('bismillah-word-${words[index].position}'),
              word: words[index],
              glyph: BismillahV4Glyph.wordGlyphs[index],
              fontSize: fontSize,
              highlighted: words[index].position == activeWordPosition,
              highlightColor: highlight,
              useTajweedColors: useTajweedColors,
              onTap: onTap,
              onLongPress: onLongPress,
            ),
        ],
      ),
    );
    return useTajweedColors
        ? row
        : KeyedSubtree(key: const ValueKey('bismillah-monochrome'), child: row);
  }
}

class _BismillahWordGlyph extends StatelessWidget {
  const _BismillahWordGlyph({
    super.key,
    required this.word,
    required this.glyph,
    required this.fontSize,
    required this.highlighted,
    required this.highlightColor,
    required this.useTajweedColors,
    this.onTap,
    this.onLongPress,
  });

  final QuranWord word;
  final String glyph;
  final double fontSize;
  final bool highlighted;
  final Color highlightColor;
  final bool useTajweedColors;
  final ValueChanged<QuranWord>? onTap;
  final ValueChanged<QuranWord>? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: word.arabic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(word),
        onLongPress: onLongPress == null ? null : () => onLongPress!(word),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: highlighted ? highlightColor : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: ExcludeSemantics(
            child: useTajweedColors
                ? Text(
                    glyph,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: BismillahV4Glyph.fontFamily,
                      fontSize: fontSize,
                      height: 1,
                    ),
                  )
                : ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                    child: Text(
                      glyph,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: BismillahV4Glyph.fontFamily,
                        fontSize: fontSize,
                        height: 1,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
