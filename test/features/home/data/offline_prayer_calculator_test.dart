import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/home/data/offline_prayer_calculator.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test(
    'Karachi prayer times and calendar dates calculate without a client',
    () {
      const location = PrayerLocation(
        name: 'Dhaka',
        latitude: 23.7115,
        longitude: 90.4111,
      );
      final calculator = OfflinePrayerCalculator();
      final hanafi = calculator.calculate(
        DateTime(2026, 9, 14),
        location,
        AsrSchool.hanafi,
      );
      final standard = calculator.calculate(
        DateTime(2026, 9, 14),
        location,
        AsrSchool.standard,
      );
      expect(hanafi.times['Fajr']!.hour, inInclusiveRange(3, 6));
      expect(hanafi.times['Asr']!.isAfter(standard.times['Asr']!), isTrue);
      expect(hanafi.sunrise.isBefore(hanafi.sunset), isTrue);
      expect(hanafi.tomorrowHijriDate, isNotEmpty);
      expect(hanafi.tomorrowFajr!.day, 15);
      // AlAdhan method 1/school 1 reference for Dhaka on 2026-09-14.
      expect(
        hanafi.times['Fajr']!.hour * 60 + hanafi.times['Fajr']!.minute,
        inInclusiveRange(263, 273),
      );
      expect(
        hanafi.times['Asr']!.hour * 60 + hanafi.times['Asr']!.minute,
        inInclusiveRange(975, 985),
      );
      expect(hanafi.hijriDate, '3 Rabi al-Thani 1448 AH');
    },
  );
}
