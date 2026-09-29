import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/home/data/bangla_calendar.dart';

void main() {
  test('Bangla date follows the revised Bangladesh calendar', () {
    expect(banglaCalendarDate(DateTime(2025, 3, 30)), '১৬ চৈত্র ১৪৩১');
    expect(banglaCalendarDate(DateTime(2025, 4, 14)), '১ বৈশাখ ১৪৩২');
    expect(banglaCalendarDate(DateTime(2026, 9, 14)), '৩০ ভাদ্র ১৪৩৩');
  });

  test('Falgun gains a day when its Gregorian year is leap', () {
    expect(banglaCalendarDate(DateTime(2024, 3, 14)), '৩০ ফাল্গুন ১৪৩০');
    expect(banglaCalendarDate(DateTime(2024, 3, 15)), '১ চৈত্র ১৪৩০');
  });

  test('Bangla range compacts a shared year and adds Bangabda', () {
    expect(banglaCalendarDate(DateTime(2026, 10, 11)), '২৬ আশ্বিন ১৪৩৩');
    expect(
      banglaCalendarRange(DateTime(2026, 9, 12), DateTime(2026, 10, 11)),
      '২৮ ভাদ্র – ২৬ আশ্বিন ১৪৩৩ বঙ্গাব্দ',
    );
    expect(
      banglaCalendarRange(
        DateTime(2026, 9, 12),
        DateTime(2026, 10, 11),
        english: true,
      ),
      '28 Bhadro – 26 Ashwin 1433',
    );
  });

  test('Bangla range keeps both years across Bangla year rollover', () {
    expect(
      banglaCalendarRange(DateTime(2027, 4, 13), DateTime(2027, 4, 14)),
      '৩০ চৈত্র ১৪৩৩ – ১ বৈশাখ ১৪৩৪ বঙ্গাব্দ',
    );
  });
}
