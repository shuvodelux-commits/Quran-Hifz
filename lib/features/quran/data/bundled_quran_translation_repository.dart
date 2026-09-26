import 'package:drift/drift.dart';

import '../../../core/database/quran_content_database.dart';
import '../domain/quran_translation_repository.dart';
import '../domain/quran_translation_source.dart';

class BundledQuranTranslationRepository implements QuranTranslationRepository {
  BundledQuranTranslationRepository(this._database);

  final QuranContentDatabase _database;

  @override
  Future<List<QuranTranslationSource>> listInstalledSources() async {
    return const [
      QuranTranslationSource(
        sourceId: bundledPrimaryTranslationSourceId,
        resourceId: 1,
        name: 'ড. আবু বকর মুহাম্মদ যাকারিয়া',
        language: 'bn',
        version: '1.1.1',
        author: 'Dr. Abu Bakr Muhammad Zakaria',
        kind: QuranTranslationSourceKind.bundled,
        availableOffline: true,
      ),
    ];
  }

  @override
  Future<QuranTranslationEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (sourceId != bundledPrimaryTranslationSourceId ||
        surahNumber < 1 ||
        ayahNumber < 1) {
      return null;
    }
    final row =
        await (_database.select(_database.translations)..where(
              (translation) =>
                  translation.resourceId.equals(1) &
                  translation.surahNumber.equals(surahNumber) &
                  translation.ayahNumber.equals(ayahNumber),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return QuranTranslationEntry(
      sourceId: bundledPrimaryTranslationSourceId,
      sourceName: 'ড. আবু বকর মুহাম্মদ যাকারিয়া',
      language: row.language,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      text: row.textValue,
    );
  }
}
