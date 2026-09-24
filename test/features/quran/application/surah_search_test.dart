import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/application/surah_search.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';

void main() {
  const surahs = [
    QuranSurahSummary(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      nameBangla: 'আল-ফাতিহা',
      ayahCount: 7,
      pageStart: 1,
      pageEnd: 1,
      juzStart: 1,
    ),
    QuranSurahSummary(
      number: 2,
      nameArabic: 'البقرة',
      nameEnglish: 'Al-Baqarah',
      nameBangla: 'আল-বাকারা',
      ayahCount: 286,
      pageStart: 2,
      pageEnd: 49,
      juzStart: 1,
    ),
  ];

  test('normalizes punctuation, Bangla digits, and Latin case', () {
    expect(normalizeSurahQuery(" AL-FA'TIHAH "), 'alfatihah');
    expect(normalizeSurahQuery('০২'), '02');
  });

  test('finds an English alias independently of the interface language', () {
    expect(rankSurahMatches(surahs, 'baqar').single.number, 2);
  });

  test('ranks the requested shorthand al hah as Al-Fatihah', () {
    expect(rankSurahMatches(surahs, 'al hah').first.number, 1);
  });

  test('supports Bangla Arabic numeric and small typo queries', () {
    expect(rankSurahMatches(surahs, 'ফাতিহা').first.number, 1);
    expect(rankSurahMatches(surahs, 'الفاتحة').first.number, 1);
    expect(rankSurahMatches(surahs, '২').first.number, 2);
    expect(rankSurahMatches(surahs, 'fatiah').first.number, 1);
  });

  test('does not flood results for an unrelated short query', () {
    expect(rankSurahMatches(surahs, 'zz'), isEmpty);
  });
}
