import 'package:flutter/material.dart';

import '../../application/tajweed_markup_parser.dart';
import '../quran_reading_colors.dart';

class QuranTajweedText extends StatelessWidget {
  const QuranTajweedText({
    super.key,
    required this.plainText,
    required this.markup,
    required this.useTajweedColors,
    this.textAlign,
    this.textDirection = TextDirection.rtl,
  });

  final String plainText;
  final String? markup;
  final bool useTajweedColors;
  final TextAlign? textAlign;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    final source = markup;
    if (!useTajweedColors || source == null || source.trim().isEmpty) {
      return Text(
        plainText,
        textAlign: textAlign,
        textDirection: textDirection,
      );
    }

    final segments = parseTajweedMarkup(source);
    if (segments.isEmpty) {
      return Text(
        plainText,
        textAlign: textAlign,
        textDirection: textDirection,
      );
    }

    final brightness = Theme.of(context).brightness;
    return Text.rich(
      TextSpan(
        children: [
          for (final segment in segments)
            TextSpan(
              text: segment.text,
              style: TextStyle(
                color: QuranReadingColors.tajweedColor(
                  segment.rule,
                  brightness,
                ),
              ),
            ),
        ],
      ),
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }
}
