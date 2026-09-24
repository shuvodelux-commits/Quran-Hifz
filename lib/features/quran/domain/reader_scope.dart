import 'quran_ayah.dart';
import 'quran_juz.dart';
import 'quran_surah.dart';

sealed class ReaderScope {
  const ReaderScope();

  int get firstPage;
  int get lastPage;
  int get initialSurahNumber;
  int get initialAyahNumber;
  bool contains(QuranAyah ayah);
}

class SurahReaderScope extends ReaderScope {
  const SurahReaderScope({required this.surah, this.startAyahNumber = 1});

  final QuranSurahSummary surah;
  final int startAyahNumber;

  @override
  int get firstPage => surah.pageStart;
  @override
  int get lastPage => surah.pageEnd;
  @override
  int get initialSurahNumber => surah.number;
  @override
  int get initialAyahNumber => startAyahNumber;
  @override
  bool contains(QuranAyah ayah) => ayah.surahNumber == surah.number;
}

class JuzReaderScope extends ReaderScope {
  const JuzReaderScope({required this.juz});

  final QuranJuzSummary juz;

  @override
  int get firstPage => juz.firstPage;
  @override
  int get lastPage => juz.lastPage;
  @override
  int get initialSurahNumber => juz.firstTarget.surahNumber;
  @override
  int get initialAyahNumber => juz.firstTarget.ayahNumber;
  @override
  bool contains(QuranAyah ayah) => ayah.juzNumber == juz.number;
}
