import 'quran_mushaf_variant.dart';

enum QcfMushafLineType { ayah, basmallah, surahName }

enum QcfMushafTokenType { word, end, pause, other }

class QcfMushafToken {
  const QcfMushafToken({
    required this.wordIndex,
    required this.type,
    required this.display,
    this.unicodeFallback,
    this.ayahKey,
    this.wordPosition,
  });

  final int wordIndex;
  final QcfMushafTokenType type;
  final String display;
  final String? unicodeFallback;
  final String? ayahKey;
  final int? wordPosition;
}

class QcfMushafLine {
  const QcfMushafLine({
    required this.lineNumber,
    required this.type,
    required this.isCentered,
    required this.tokens,
    this.surahNumber,
  });

  final int lineNumber;
  final QcfMushafLineType type;
  final bool isCentered;
  final int? surahNumber;
  final List<QcfMushafToken> tokens;
}

class QcfMushafPage {
  const QcfMushafPage({
    required this.page,
    required this.variant,
    required this.lines,
  });

  final int page;
  final QuranMushafVariant variant;
  final List<QcfMushafLine> lines;

  List<QcfMushafToken> get tokens => [for (final line in lines) ...line.tokens];
}
