import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/home/data/mosque_prayer_times_repository.dart';

void main() {
  test(
    'saves edited mosque Azan and Jamaat times across repository reloads',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = MosquePrayerTimesRepository(database);

      await repository.saveAzan('Fajr', 4 * 60 + 25);
      await repository.saveJamaat('Fajr', 5 * 60);

      final reloaded = await MosquePrayerTimesRepository(database).load();
      expect(
        reloaded['Fajr'],
        const MosquePrayerTime(azanMinutes: 265, jamaatMinutes: 300),
      );
    },
  );

  test('overlapping field edits preserve both saved values', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = MosquePrayerTimesRepository(database);

    await Future.wait([
      repository.saveAzan('Fajr', 265),
      repository.saveJamaat('Fajr', 300),
    ]);

    expect(
      (await repository.load())['Fajr'],
      const MosquePrayerTime(azanMinutes: 265, jamaatMinutes: 300),
    );
  });

  test('malformed stored data does not prevent a later edit', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.saveSetting('mosque_prayer_times_v1', '{not-json');
    final repository = MosquePrayerTimesRepository(database);

    await repository.saveJamaat('Isha', 20 * 60 + 15);

    expect((await repository.load())['Isha']?.jamaatMinutes, 1215);
  });
}
