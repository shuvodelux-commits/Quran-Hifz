import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';

void main() {
  test('next prayer advances to tomorrow Fajr after Isha', () {
    final day = DateTime(2026, 9, 14);
    final nextDay = DateTime(2026, 9, 15, 4, 28);
    final schedule = PrayerSchedule(
      location: 'Dhaka',
      latitude: 23.81,
      longitude: 90.41,
      hijriDate: '3 Rabi al-Thani 1448 AH',
      tomorrowHijriDate: '4 Rabi al-Thani 1448 AH',
      sunrise: DateTime(2026, 9, 14, 5, 44),
      sunset: DateTime(2026, 9, 14, 18, 3),
      times: {
        'Fajr': DateTime(2026, 9, 14, 4, 28),
        'Dhuhr': DateTime(2026, 9, 14, 11, 54),
        'Asr': DateTime(2026, 9, 14, 16, 20),
        'Maghrib': DateTime(2026, 9, 14, 18, 3),
        'Isha': DateTime(2026, 9, 14, 19, 19),
      },
      tomorrowFajr: nextDay,
    );

    expect(
      schedule.nextPrayer(day.add(const Duration(hours: 13)))?.name,
      'Asr',
    );
    expect(
      schedule.nextPrayer(day.add(const Duration(hours: 21)))?.time,
      nextDay,
    );
    expect(
      schedule.hijriDateAt(day.add(const Duration(hours: 17))),
      '3 Rabi al-Thani 1448 AH',
    );
    expect(
      schedule.hijriDateAt(day.add(const Duration(hours: 19))),
      '4 Rabi al-Thani 1448 AH',
    );
  });
}
