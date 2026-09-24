import '../domain/quran_ayah.dart';
import '../domain/quran_juz.dart';
import '../domain/quran_page_window.dart';
import '../domain/quran_repository.dart';
import '../domain/quran_surah.dart';
import '../domain/quran_word.dart';

/// Development-only content used until the verified bundled database is
/// generated. Production release gates forbid shipping this repository.
class DemoQuranRepository implements QuranRepository {
  static const _ayahs = [
    QuranAyah(
      surahNumber: 1,
      ayahNumber: 1,
      arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      pageNumber: 1,
      juzNumber: 1,
      translation: 'পরম করুণাময়, অতি দয়ালু আল্লাহর নামে।',
      shortTafsir:
          'Demo tafsir placeholder. Replace with a licensed, verified tafsir source.',
      words: [
        QuranWord(
          position: 1,
          arabic: 'بِسْمِ',
          transliteration: 'Bismi',
          banglaMeaning: 'নামে',
          root: 'س م و',
          grammar: 'Demo metadata',
        ),
        QuranWord(
          position: 2,
          arabic: 'اللَّهِ',
          transliteration: 'Allahi',
          banglaMeaning: 'আল্লাহর',
        ),
        QuranWord(
          position: 3,
          arabic: 'الرَّحْمَٰنِ',
          transliteration: 'Ar-Rahmani',
          banglaMeaning: 'পরম করুণাময়',
        ),
        QuranWord(
          position: 4,
          arabic: 'الرَّحِيمِ',
          transliteration: 'Ar-Raheemi',
          banglaMeaning: 'অতি দয়ালু',
        ),
      ],
    ),
    QuranAyah(
      surahNumber: 1,
      ayahNumber: 2,
      arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      pageNumber: 1,
      juzNumber: 1,
      translation: 'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি সকল জগতের প্রতিপালক।',
      shortTafsir:
          'Demo tafsir placeholder. Replace with a licensed, verified tafsir source.',
      words: [
        QuranWord(
          position: 1,
          arabic: 'الْحَمْدُ',
          banglaMeaning: 'সমস্ত প্রশংসা',
        ),
        QuranWord(
          position: 2,
          arabic: 'لِلَّهِ',
          banglaMeaning: 'আল্লাহর জন্য',
        ),
        QuranWord(position: 3, arabic: 'رَبِّ', banglaMeaning: 'প্রতিপালক'),
        QuranWord(
          position: 4,
          arabic: 'الْعَالَمِينَ',
          banglaMeaning: 'সকল জগতের',
        ),
      ],
    ),
  ];

  @override
  Future<List<QuranSurahSummary>> listSurahs() async {
    return const [
      QuranSurahSummary(
        number: 1,
        nameArabic: 'الفاتحة',
        nameEnglish: 'Al-Fatihah',
        ayahCount: 2,
        pageStart: 1,
        pageEnd: 1,
        juzStart: 1,
      ),
    ];
  }

  @override
  Future<List<QuranJuzSummary>> listJuzs() async => const [];

  @override
  Future<QuranAyah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
    required int translationResourceId,
  }) async {
    for (final ayah in _ayahs) {
      if (ayah.surahNumber == surahNumber && ayah.ayahNumber == ayahNumber) {
        return ayah;
      }
    }
    return null;
  }

  @override
  Future<QuranPageWindow> loadPageWindow({
    required int page,
    required int translationResourceId,
  }) async {
    return QuranPageWindow(
      page: page,
      previousPage: page > 1 ? page - 1 : null,
      nextPage: page < 604 ? page + 1 : null,
      ayahs: page == 1 ? _ayahs : const [],
    );
  }
}
