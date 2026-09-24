import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/quran/data/user_database_reading_location_store.dart';

void main() {
  test('keeps independent resume positions for each surah', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = UserDatabaseReadingLocationStore(database);

    await store.saveForSurah(
      const ReadingLocation(page: 20, surahNumber: 2, ayahNumber: 100),
    );
    await store.saveForSurah(
      const ReadingLocation(page: 300, surahNumber: 36, ayahNumber: 10),
    );

    final baqarah = await store.loadForSurah(2);
    final yasin = await store.loadForSurah(36);
    expect(baqarah?.page, 20);
    expect(baqarah?.ayahNumber, 100);
    expect(yasin?.page, 300);
    expect(await store.loadForSurah(55), isNull);
  });
}
