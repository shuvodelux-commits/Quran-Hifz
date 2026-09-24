import 'quran_ayah.dart';
import 'quran_juz.dart';
import 'quran_page_window.dart';
import 'quran_surah.dart';

abstract class QuranRepository {
  Future<List<QuranSurahSummary>> listSurahs();

  Future<List<QuranJuzSummary>> listJuzs();

  Future<QuranAyah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
    required int translationResourceId,
  });

  Future<QuranPageWindow> loadPageWindow({
    required int page,
    required int translationResourceId,
  });
}
