import '../domain/hifz_progress.dart';
import '../../quran/domain/quran_surah.dart';

class HifzStartRange {
  const HifzStartRange({
    required this.startAyah,
    required this.endAyah,
  });

  final int startAyah;
  final int endAyah;
}

abstract final class HifzStartDefaults {
  static HifzStartRange forSurah({
    required QuranSurahSummary surah,
    required List<HifzProgress> progress,
  }) {
    if (surah.ayahCount <= 0) {
      throw ArgumentError.value(
        surah.ayahCount,
        'surah.ayahCount',
        'Surah must contain at least one ayah.',
      );
    }

    final started = <int>{
      for (final item in progress)
        if (item.ayah.surahNumber == surah.number &&
            item.ayah.ayahNumber >= 1 &&
            item.ayah.ayahNumber <= surah.ayahCount &&
            item.status != HifzStatus.notStarted)
          item.ayah.ayahNumber,
    };

    var start = 1;
    while (start <= surah.ayahCount && started.contains(start)) {
      start++;
    }
    if (start > surah.ayahCount) start = surah.ayahCount;

    final proposedEnd = start + 4;
    final end = proposedEnd > surah.ayahCount ? surah.ayahCount : proposedEnd;
    return HifzStartRange(startAyah: start, endAyah: end);
  }
}
