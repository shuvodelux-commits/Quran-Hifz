import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/data/user_database_prayer_location_store.dart';

void main() {
  test('downloaded location configuration survives store recreation', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await UserDatabasePrayerLocationStore(database).save(
      const PrayerLocation(name: 'Dhaka', latitude: 23.71, longitude: 90.41),
    );
    final restored = await UserDatabasePrayerLocationStore(database).load();
    expect(restored?.name, 'Dhaka');
    expect(restored?.latitude, 23.71);
    expect(restored?.longitude, 90.41);
    expect(restored?.utcOffsetMinutes, 360);
  });
}
