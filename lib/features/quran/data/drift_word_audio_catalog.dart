import 'package:drift/drift.dart';

import '../../../core/database/quran_content_database.dart';
import '../domain/word_audio_source.dart';

class DriftSurahWordAudioCatalog implements SurahWordAudioCatalog {
  DriftSurahWordAudioCatalog(this._database);

  final QuranContentDatabase _database;

  @override
  Future<List<QuranWordAudioSource>> listForSurah(int surahNumber) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError.value(surahNumber, 'surahNumber');
    }

    final rows = await _database
        .customSelect(
          '''
SELECT
  surah_number,
  ayah_number,
  position,
  audio_remote_path
FROM quran_words
WHERE surah_number = ?
  AND audio_remote_path IS NOT NULL
  AND TRIM(audio_remote_path) <> ''
ORDER BY ayah_number ASC, position ASC
''',
          variables: [Variable.withInt(surahNumber)],
          readsFrom: {_database.quranWords},
        )
        .get();

    return rows
        .map(
          (row) => QuranWordAudioSource(
            surahNumber: row.read<int>('surah_number'),
            ayahNumber: row.read<int>('ayah_number'),
            wordPosition: row.read<int>('position'),
            remotePath: row.read<String>('audio_remote_path'),
          ),
        )
        .toList(growable: false);
  }
}
