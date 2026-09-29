import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/home/data/hijri_calendar_month.dart';

void main() {
  test('parseHijriDate accepts canonical PrayerSchedule format', () {
    expect(
      parseHijriDate('13 Rabi al-Thani 1448 AH'),
      const HijriDateParts(day: 13, month: 'Rabi al-Thani', year: 1448),
    );
  });

  test(
    'parseHijriDate trims harmless whitespace but rejects malformed or unknown month names',
    () {
      expect(
        parseHijriDate('  13   Rabi al-Thani   1448 AH  '),
        const HijriDateParts(day: 13, month: 'Rabi al-Thani', year: 1448),
      );
      expect(parseHijriDate('bad value'), isNull);
      expect(parseHijriDate('13 Unknown 1448 AH'), isNull);
      expect(parseHijriDate('0 Muharram 1448 AH'), isNull);
      expect(parseHijriDate('31 Muharram 1448 AH'), isNull);
      expect(parseHijriDate('1 Muharram 0 AH'), isNull);
    },
  );

  test('nextHijriMonth rolls Dhu al-Hijjah into Muharram of next year', () {
    expect(
      nextHijriMonth(const HijriMonthKey(month: 'Dhu al-Hijjah', year: 1448)),
      const HijriMonthKey(month: 'Muharram', year: 1449),
    );
  });

  test(
    'previousHijriMonth rolls Muharram into Dhu al-Hijjah of previous year',
    () {
      expect(
        previousHijriMonth(const HijriMonthKey(month: 'Muharram', year: 1449)),
        const HijriMonthKey(month: 'Dhu al-Hijjah', year: 1448),
      );
    },
  );

  test('hijriMonthDelta handles positive negative and cross-year jumps', () {
    const rabi = HijriMonthKey(month: 'Rabi al-Thani', year: 1448);
    const ramadan = HijriMonthKey(month: 'Ramadan', year: 1448);
    const muharramNext = HijriMonthKey(month: 'Muharram', year: 1449);

    expect(hijriMonthDelta(rabi, ramadan), 5);
    expect(hijriMonthDelta(ramadan, rabi), -5);
    expect(hijriMonthDelta(rabi, muharramNext), 9);
    expect(hijriMonthDelta(rabi, rabi), 0);
  });
}
