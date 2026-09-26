import '../domain/quran_translation_repository.dart';
import '../domain/quran_translation_source.dart';

class CompositeQuranTranslationRepository
    implements QuranTranslationRepository {
  CompositeQuranTranslationRepository({
    required QuranTranslationRepository bundled,
    required QuranTranslationRepository downloaded,
  }) : _bundled = bundled,
       _downloaded = downloaded;

  final QuranTranslationRepository _bundled;
  final QuranTranslationRepository _downloaded;

  @override
  Future<List<QuranTranslationSource>> listInstalledSources() async {
    final bundled = await _bundled.listInstalledSources();
    final downloaded = await _downloaded.listInstalledSources();
    final byId = <String, QuranTranslationSource>{};
    for (final source in [...bundled, ...downloaded]) {
      byId[source.sourceId] = source;
    }
    return List.unmodifiable(byId.values);
  }

  @override
  Future<QuranTranslationEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (sourceId == bundledPrimaryTranslationSourceId) {
      return _bundled.readAyah(
        sourceId: sourceId,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      );
    }
    return _downloaded.readAyah(
      sourceId: sourceId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
  }

  Future<List<QuranTranslationEntry>> readAyahTranslations({
    required List<String> sourceIds,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final entries = <QuranTranslationEntry>[];
    for (final sourceId in sourceIds) {
      final entry = await readAyah(
        sourceId: sourceId,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      );
      if (entry != null) entries.add(entry);
    }
    return List.unmodifiable(entries);
  }
}
