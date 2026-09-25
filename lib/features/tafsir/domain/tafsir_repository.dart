import 'tafsir_entry.dart';

abstract class TafsirRepository {
  Future<List<TafsirSource>> listInstalledSources();

  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  });

  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async {
    final entries = <TafsirEntry>[];
    for (var ayah = 1; ayah <= 286; ayah++) {
      final entry = await readAyah(
        sourceId: sourceId,
        surahNumber: surahNumber,
        ayahNumber: ayah,
      );
      if (entry != null) entries.add(entry);
    }
    return entries;
  }
}

extension TafsirRepositorySources on TafsirRepository {
  Future<List<TafsirSource>> listSources() => listInstalledSources();
}
