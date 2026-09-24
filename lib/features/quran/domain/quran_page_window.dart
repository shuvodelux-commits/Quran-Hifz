import 'quran_ayah.dart';
import 'quran_mushaf_line.dart';

class QuranPageWindow {
  factory QuranPageWindow({
    required int page,
    required List<QuranAyah> ayahs,
    required int? previousPage,
    required int? nextPage,
    List<QuranMushafLine> lines = const [],
  }) => QuranPageWindow._(
    page: page,
    ayahs: ayahs,
    previousPage: previousPage,
    nextPage: nextPage,
    lines: List<QuranMushafLine>.unmodifiable(lines),
  );

  const QuranPageWindow._({
    required this.page,
    required this.ayahs,
    required this.previousPage,
    required this.nextPage,
    required this.lines,
  });

  final int page;
  final List<QuranAyah> ayahs;
  final int? previousPage;
  final int? nextPage;
  final List<QuranMushafLine> lines;

  bool get isEmpty => ayahs.isEmpty;
}
