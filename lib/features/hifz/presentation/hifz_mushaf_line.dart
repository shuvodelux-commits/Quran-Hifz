import 'package:flutter/material.dart';
import '../../quran/domain/quran_font_preference.dart';
import '../../quran/presentation/quran_text_style.dart';
import '../../quran/presentation/widgets/quran_word_view.dart';
import '../application/hifz_text_layout.dart';
import '../domain/hifz_session.dart';

/// Minimum and maximum inter-token gap used when justifying a canonical
/// Mushaf line to its target width. Shared with [HifzMushafSurface] so the
/// page's natural-width measurement and each line's rendered gap agree.
const double hifzLineMinimumGap = 4;
const double hifzLineMaximumGap = 16;

/// One precomputed Mushaf line, rendered responsively so that:
///  - "full" lines are gap-justified to fill [rowWidth] edge to edge, the
///    way a printed Mushaf line stretches margin to margin, and
///  - "centered" lines (short ayah endings, Surah openings, and every line
///    on the opening two pages) are centered within the same [rowWidth],
///    so short and long lines share one visual column.
/// At larger selected sizes it wraps vertically instead of shrinking text.
class HifzMushafLine extends StatelessWidget {
  const HifzMushafLine({
    super.key,
    required this.words,
    required this.centered,
    required this.font,
    required this.fontSize,
    required this.lineHeight,
    required this.rowWidth,
    required this.selectedAyahs,
    required this.activeAyahKey,
    this.onAyahSelected,
    this.onWordTap,
    this.onWordLongPress,
  });

  final List<HifzLineWord> words;
  final bool centered;
  final QuranFontPreference font;
  final double fontSize;
  final double lineHeight;

  /// The width this line's row should occupy: either the full available
  /// page width (the common case, so full lines stretch edge to edge) or a
  /// shared natural page width when the whole page has been scaled down to
  /// fit (see `hifz-page-uniform-fit` in [HifzMushafSurface]).
  final double rowWidth;
  final Set<AyahRef> selectedAyahs;
  final String? activeAyahKey;
  final ValueChanged<AyahRef>? onAyahSelected;
  final void Function(HifzLineWord lineWord)? onWordTap;
  final void Function(HifzLineWord lineWord)? onWordLongPress;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final tokens = <Widget>[];
    final tokenWidths = <double>[];
    for (final word in words) {
      tokens.add(
        HifzMushafWord(
          key: ValueKey('hifz-word-${word.ayah.key}:${word.word.position}'),
          lineWord: word,
          font: font,
          fontSize: fontSize,
          lineHeight: lineHeight,
          isActiveAyah: false,
          contentPadding: EdgeInsets.zero,
          onTap: onWordTap == null ? null : () => onWordTap!(word),
          onLongPress: onWordLongPress == null
              ? null
              : () => onWordLongPress!(word),
        ),
      );
      tokenWidths.add(_measureWord(word.word.arabicFor(font.script), scaler));

      if (word.endsAyah) {
        final reference = AyahRef(
          surahNumber: word.ayah.surahNumber,
          ayahNumber: word.ayah.ayahNumber,
        );
        tokens.add(
          HifzAyahMarker(
            ayahNumber: word.ayah.ayahNumber,
            ayahKey: word.ayah.key,
            fontSize: fontSize,
            selected: selectedAyahs.contains(reference),
            active: false,
            onTap: onAyahSelected == null
                ? null
                : () => onAyahSelected!(reference),
          ),
        );
        tokenWidths.add(scaler.scale(fontSize) * .92);
      }
    }

    final gap = _resolveGap(tokenWidths);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: rowWidth,
        child: Wrap(
          textDirection: TextDirection.rtl,
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: gap,
          runSpacing: scaler.scale(fontSize * (lineHeight - 1) * .3),
          children: tokens,
        ),
      ),
    );
  }

  double _resolveGap(List<double> tokenWidths) {
    if (centered || tokenWidths.length < 2) return hifzLineMinimumGap;
    final naturalContentWidth = tokenWidths.fold<double>(0, (a, b) => a + b);
    final available = rowWidth - naturalContentWidth;
    final perGap = available / (tokenWidths.length - 1);
    return perGap.clamp(hifzLineMinimumGap, hifzLineMaximumGap).toDouble();
  }

  double _measureWord(String text, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: QuranTextStyle.forScript(
          script: font.script,
          color: Colors.black,
          fontSize: fontSize,
          lineHeight: lineHeight,
          font: font,
        ),
      ),
      textDirection: TextDirection.rtl,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    return painter.width;
  }
}

class HifzMushafWord extends StatelessWidget {
  const HifzMushafWord({
    super.key,
    required this.lineWord,
    required this.font,
    required this.fontSize,
    required this.lineHeight,
    required this.isActiveAyah,
    this.contentPadding = EdgeInsets.zero,
    this.onTap,
    this.onLongPress,
  });

  final HifzLineWord lineWord;
  final QuranFontPreference font;
  final double fontSize;
  final double lineHeight;
  final bool isActiveAyah;
  final EdgeInsetsGeometry contentPadding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return QuranWordView(
      word: lineWord.word,
      isActive: isActiveAyah,
      playbackAyahKey: lineWord.ayah.key,
      onTap: onTap,
      onLongPress: onLongPress,
      typographyFont: font,
      typographyFontSize: fontSize,
      typographyLineHeight: lineHeight,
      contentPadding: contentPadding,
    );
  }
}

class HifzAyahMarker extends StatelessWidget {
  const HifzAyahMarker({
    super.key,
    required this.ayahNumber,
    required this.ayahKey,
    required this.fontSize,
    required this.selected,
    required this.active,
    this.onTap,
  });

  final int ayahNumber;
  final String ayahKey;
  final double fontSize;
  final bool selected;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = active || selected ? scheme.primary : scheme.onSurfaceVariant;
    final scaledSize = MediaQuery.textScalerOf(context).scale(fontSize);
    return Semantics(
      button: true,
      label: 'Select ayah $ayahNumber',
      child: InkWell(
        key: ValueKey('hifz-ayah-marker-$ayahKey'),
        onTap: onTap,
        child: SizedBox.square(
          dimension: scaledSize * .92,
          child: Center(
            child: Text(
              _arabicIndic(ayahNumber),
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: color,
                fontFamily: 'hafs',
                package: 'flutter_quran',
                fontSize: fontSize * .92,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _arabicIndic(int number) => number
    .toString()
    .split('')
    .map((digit) => String.fromCharCode(0x0660 + int.parse(digit)))
    .join();
