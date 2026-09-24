import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/audio/data/drift_timing_repository.dart';

void main() {
  test('returns verified ayah and word timings in playback order', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.replaceTimings(
      reciterId: 7,
      surahNumber: 1,
      timestamps: [
        {
          'verse_key': '1:1',
          'timestamp_from': 1000,
          'timestamp_to': 4000,
          'segments': [
            [2, 2000, 3000],
            [1, 1000, 1900],
          ],
        },
      ],
    );

    final repository = DriftTimingRepository(database);
    final ayah = await repository.getAyahTiming(
      reciterId: 7,
      surahNumber: 1,
      ayahNumber: 1,
    );
    final words = await repository.getWordTimings(
      reciterId: 7,
      surahNumber: 1,
      ayahNumber: 1,
    );

    expect(ayah?.start, const Duration(milliseconds: 1000));
    expect(ayah?.end, const Duration(milliseconds: 4000));
    expect(words.map((item) => item.wordPosition), [1, 2]);
  });
}
