import 'quran_translation_source.dart';

abstract interface class QuranTranslationRepository {
  Future<List<QuranTranslationSource>> listInstalledSources();

  Future<QuranTranslationEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  });
}
