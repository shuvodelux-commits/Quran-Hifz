import '../../study/domain/bookmark.dart';

class QuranJuzSummary {
  const QuranJuzSummary({
    required this.number,
    required this.firstTarget,
    required this.lastTarget,
    required this.firstPage,
    required this.lastPage,
    required this.startSurahNumber,
    required this.endSurahNumber,
  });

  final int number;
  final StudyTarget firstTarget;
  final StudyTarget lastTarget;
  final int firstPage;
  final int lastPage;
  final int startSurahNumber;
  final int endSurahNumber;
}
