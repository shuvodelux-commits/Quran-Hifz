import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/home/data/nafl_prayer_times.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';

void main() {
  PrayerSchedule schedule() => PrayerSchedule(
    location: 'Dhaka, Bangladesh',
    latitude: 23.81,
    longitude: 90.41,
    hijriDate: '18 Rabi al-Thani 1448 AH',
    sunrise: DateTime(2026, 9, 30, 5, 56),
    sunset: DateTime(2026, 9, 30, 17, 53),
    times: {
      'Fajr': DateTime(2026, 9, 30, 4, 39),
      'Dhuhr': DateTime(2026, 9, 30, 12, 2),
      'Asr': DateTime(2026, 9, 30, 15, 31),
      'Maghrib': DateTime(2026, 9, 30, 17, 53),
      'Isha': DateTime(2026, 9, 30, 19, 7),
    },
    tomorrowFajr: DateTime(2026, 10, 1, 4, 39),
    tomorrowMaghrib: DateTime(2026, 10, 1, 17, 52),
  );

  test('derives the reference Nafl windows from prayer times', () {
    final value = NaflPrayerTimes.fromSchedule(
      schedule(),
      now: DateTime(2026, 9, 30, 15),
    );

    expect(value.duhaStart, DateTime(2026, 9, 30, 6, 11));
    expect(value.duhaEnd, DateTime(2026, 9, 30, 11, 52));
    expect(value.zawalStart, DateTime(2026, 9, 30, 11, 57));
    expect(value.awwabinStart, DateTime(2026, 9, 30, 17, 53));
    expect(value.awwabinEnd, DateTime(2026, 9, 30, 19, 7));
    expect(value.tahajjudStart, DateTime(2026, 9, 30, 19, 7));
    expect(value.tahajjudEnd, DateTime(2026, 10, 1, 4, 39));
    expect(value.lastThirdStart, DateTime(2026, 10, 1, 0, 3));
  });

  test('uses the next exact iftar after Maghrib', () {
    final value = NaflPrayerTimes.fromSchedule(
      schedule(),
      now: DateTime(2026, 9, 30, 18),
    );

    expect(value.nextIftar, DateTime(2026, 10, 1, 17, 52));
    expect(value.nextSuhurEnd, DateTime(2026, 10, 1, 4, 39));
  });

  test('uses today iftar while it is still ahead', () {
    final value = NaflPrayerTimes.fromSchedule(
      schedule(),
      now: DateTime(2026, 9, 30, 15),
    );

    expect(value.nextIftar, DateTime(2026, 9, 30, 17, 53));
    expect(
      value.iftarRemaining(DateTime(2026, 9, 30, 15)),
      const Duration(hours: 2, minutes: 53),
    );
  });
}
