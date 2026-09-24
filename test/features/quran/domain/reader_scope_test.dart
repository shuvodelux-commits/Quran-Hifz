import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_juz.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/domain/reader_scope.dart';
import 'package:quran_hifz/features/study/domain/bookmark.dart';

void main() {
  const first = QuranSurahSummary(
    number: 1,
    nameArabic: 'الفاتحة',
    nameEnglish: 'Al-Fatihah',
    ayahCount: 7,
    pageStart: 1,
    pageEnd: 1,
    juzStart: 1,
  );
  const juzOne = QuranJuzSummary(
    number: 1,
    firstTarget: StudyTarget.ayah(surahNumber: 1, ayahNumber: 1),
    lastTarget: StudyTarget.ayah(surahNumber: 2, ayahNumber: 141),
    firstPage: 1,
    lastPage: 21,
    startSurahNumber: 1,
    endSurahNumber: 2,
  );

  test('Surah scope rejects another Surah sharing the same page', () {
    const scope = SurahReaderScope(surah: first);
    expect(scope.contains(_ayah(surah: 1, juz: 1)), isTrue);
    expect(scope.contains(_ayah(surah: 2, juz: 1)), isFalse);
  });

  test('Juz scope contains cross-Surah ayahs only inside its Juz', () {
    const scope = JuzReaderScope(juz: juzOne);
    expect(scope.contains(_ayah(surah: 1, juz: 1)), isTrue);
    expect(scope.contains(_ayah(surah: 2, juz: 1)), isTrue);
    expect(scope.contains(_ayah(surah: 2, juz: 2)), isFalse);
  });
}

QuranAyah _ayah({required int surah, required int juz}) => QuranAyah(
  surahNumber: surah,
  ayahNumber: 1,
  pageNumber: 1,
  juzNumber: juz,
  words: const [],
);
