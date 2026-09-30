import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../domain/quran_ayah.dart';
import '../domain/quran_repository.dart';
import '../domain/quran_translation_repository.dart';
import '../domain/quran_translation_source.dart';
import 'quran_providers.dart';

/// Chooses a locally stored ayah for the calendar day. The date seed keeps
/// the selection stable across rebuilds while changing it on the next day.
Future<QuranAyah?> selectTodaysAyah({
  required QuranRepository repository,
  required DateTime date,
  required int translationResourceId,
}) async {
  final surahs = await repository.listSurahs();
  final ayahTotal = surahs.fold<int>(
    0,
    (total, surah) => total + surah.ayahCount,
  );
  if (ayahTotal == 0) return null;

  final day = DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(2024, 1, 1)).inDays;
  final selectedIndex = ((day * 1103515245 + 12345) & 0x7fffffff) % ayahTotal;
  var remaining = selectedIndex;
  for (final surah in surahs) {
    if (remaining < surah.ayahCount) {
      return repository.loadAyah(
        surahNumber: surah.number,
        ayahNumber: remaining + 1,
        translationResourceId: translationResourceId,
      );
    }
    remaining -= surah.ayahCount;
  }
  return null;
}

Future<QuranAyah?> localizeTodaysAyah({
  required QuranAyah? ayah,
  required QuranTranslationRepository translationRepository,
  required AppLanguage language,
}) async {
  if (ayah == null || language == AppLanguage.bangla) return ayah;

  final sources = await translationRepository.listInstalledSources();
  final englishSources = sources.where((source) {
    final language = source.language.toLowerCase().trim();
    return language == 'en' ||
        language.startsWith('en-') ||
        language.contains('english');
  }).toList();
  if (englishSources.isEmpty) {
    return _copyWithTranslation(ayah, null);
  }

  englishSources.sort((a, b) {
    int priority(QuranTranslationSource source) {
      final name = source.name.toLowerCase();
      if (name.contains('sahih international') ||
          name.contains('saheeh international')) {
        return 0;
      }
      return 1;
    }

    return priority(a).compareTo(priority(b));
  });

  final entry = await translationRepository.readAyah(
    sourceId: englishSources.first.sourceId,
    surahNumber: ayah.surahNumber,
    ayahNumber: ayah.ayahNumber,
  );
  return _copyWithTranslation(ayah, entry?.text);
}

QuranAyah _copyWithTranslation(QuranAyah ayah, String? translation) =>
    QuranAyah(
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      words: ayah.words,
      translation: translation,
      arabicText: ayah.arabicText,
      arabicTextIndopak: ayah.arabicTextIndopak,
      arabicTajweedMarkup: ayah.arabicTajweedMarkup,
      pageNumber: ayah.pageNumber,
      juzNumber: ayah.juzNumber,
      audioUrl: ayah.audioUrl,
      shortTafsir: ayah.shortTafsir,
    );

final todaysAyahProvider = FutureProvider<QuranAyah?>((ref) async {
  final ayah = await selectTodaysAyah(
    repository: ref.watch(quranRepositoryProvider),
    date: DateTime.now(),
    translationResourceId: ref.watch(quranTranslationResourceIdProvider),
  );
  return localizeTodaysAyah(
    ayah: ayah,
    translationRepository: ref.watch(quranTranslationRepositoryProvider),
    language: ref.watch(appLanguageProvider),
  );
});
