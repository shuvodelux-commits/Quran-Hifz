import 'hifz_reading_mode.dart';

enum HifzMushafLineType { ayah, basmallah, surahName }

enum HifzMushafTokenType { word, end, pause, other }

class HifzMushafToken {
  const HifzMushafToken({
    required this.wordIndex,
    required this.type,
    required this.display,
    this.unicodeFallback,
    this.ayahKey,
    this.wordPosition,
  });

  final int wordIndex;
  final HifzMushafTokenType type;
  final String display;
  final String? unicodeFallback;
  final String? ayahKey;
  final int? wordPosition;
}

class HifzMushafLine {
  const HifzMushafLine({
    required this.lineNumber,
    required this.type,
    required this.isCentered,
    required this.tokens,
    this.surahNumber,
  });

  final int lineNumber;
  final HifzMushafLineType type;
  final bool isCentered;
  final int? surahNumber;
  final List<HifzMushafToken> tokens;
}

class HifzMushafPage {
  const HifzMushafPage({
    required this.page,
    required this.variant,
    required this.lines,
  });

  final int page;
  final QuranMushafVariant variant;
  final List<HifzMushafLine> lines;

  List<HifzMushafToken> get tokens => [
    for (final line in lines) ...line.tokens,
  ];
}
