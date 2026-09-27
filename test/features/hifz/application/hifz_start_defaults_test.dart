import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/application/hifz_start_defaults.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_progress.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';

const _fatihah = QuranSurahSummary(
  number: 1,
  nameArabic: 'الفاتحة',
  nameEnglish: 'Al-Fatihah',
  ayahCount: 7,
  pageStart: 1,
  pageEnd: 1,
  juzStart: 1,
);

HifzProgress _progress(int ayah, HifzStatus status) => HifzProgress(
  ayah: AyahRef(surahNumber: 1, ayahNumber: ayah),
  status: status,
  strengthScore: 0,
  reviewCount: 0,
  mistakeCount: 0,
);

void main() {
  test('new Surah starts at ayah 1 with a compact five-ayah range', () {
    final range = HifzStartDefaults.forSurah(
      surah: _fatihah,
      progress: const [],
    );

    expect(range.startAyah, 1);
    expect(range.endAyah, 5);
  });

  test('contiguous started progress advances to the next unfinished ayah', () {
    final range = HifzStartDefaults.forSurah(
      surah: _fatihah,
      progress: [
        _progress(1, HifzStatus.learning),
        _progress(2, HifzStatus.memorized),
        _progress(3, HifzStatus.strong),
      ],
    );

    expect(range.startAyah, 4);
    expect(range.endAyah, 7);
  });

  test('a progress gap keeps the first unfinished ayah as the start', () {
    final range = HifzStartDefaults.forSurah(
      surah: _fatihah,
      progress: [_progress(2, HifzStatus.memorized)],
    );

    expect(range.startAyah, 1);
    expect(range.endAyah, 5);
  });

  test('fully started Surah clamps the range to its final ayah', () {
    final range = HifzStartDefaults.forSurah(
      surah: _fatihah,
      progress: [
        for (var ayah = 1; ayah <= 7; ayah++)
          _progress(ayah, HifzStatus.memorized),
      ],
    );

    expect(range.startAyah, 7);
    expect(range.endAyah, 7);
  });
}
