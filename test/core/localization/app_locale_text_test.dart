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

  test(
    'Gregorian ranges compact shared years and preserve cross-year identity',
    () {
      expect(
        localGregorianDateRange(
          DateTime(2026, 9, 12),
          DateTime(2026, 10, 11),
          AppLanguage.bangla,
        ),
        '১২ সেপ্টেম্বর – ১১ অক্টোবর ২০২৬',
      );
      expect(
        localGregorianDateRange(
          DateTime(2026, 9, 12),
          DateTime(2026, 10, 11),
          AppLanguage.english,
        ),
        '12 September – 11 October 2026',
      );
      expect(
        localGregorianDateRange(
          DateTime(2026, 12, 31),
          DateTime(2027, 1, 2),
          AppLanguage.english,
        ),
        '31 December 2026 – 2 January 2027',
      );
    },
  );

  test('Hijri month names localize independently of full dates', () {
    expect(
      localHijriMonthName('Rabi al-Thani', AppLanguage.bangla),
      'রবিউস সানি',
    );
    expect(
      localHijriMonthName('Rabi al-Thani', AppLanguage.english),
      'Rabi al-Thani',
    );
    expect(localHijriMonthName('Unknown', AppLanguage.bangla), 'Unknown');
  });
}
