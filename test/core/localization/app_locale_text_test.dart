import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/localization/app_locale_text.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test('home clock and countdown use Bengali numerals in Bangla mode', () {
    expect(
      localClock(DateTime(2026, 9, 14, 18, 36), AppLanguage.bangla),
      '০৬:৩৬',
    );
    expect(
      localCountdown(
        const Duration(hours: 1, minutes: 24, seconds: 18),
        AppLanguage.bangla,
      ),
      '০১:২৪:১৮',
    );
    expect(
      localClock(DateTime(2026, 9, 14, 18, 36), AppLanguage.english),
      '06:36 PM',
    );
  });

  test('Friday Dhuhr is displayed as Jumuah only on Friday', () {
    final friday = DateTime(2026, 10, 2);
    final thursday = DateTime(2026, 10, 1);

    expect(
      localPrayerNameForDate('Dhuhr', AppLanguage.bangla, friday),
      'জুমুআ',
    );
    expect(
      localPrayerNameForDate('Dhuhr', AppLanguage.english, friday),
      "Jumu'ah",
    );
    expect(
      localPrayerNameForDate('Dhuhr', AppLanguage.bangla, thursday),
      'যোহর',
    );
    expect(localPrayerNameForDate('Asr', AppLanguage.bangla, friday), 'আসর');
  });

  test('Gregorian and Hijri dates localize without changing day identity', () {
    expect(
      localGregorianDate(DateTime(2026, 9, 14), AppLanguage.bangla),
      '১৪ সেপ্টেম্বর ২০২৬',
    );
    expect(
      localHijriDate('3 Rabi al-Thani 1448 AH', AppLanguage.bangla),
      '৩ রবিউস সানি ১৪৪৮ হি.',
    );
  });
}
