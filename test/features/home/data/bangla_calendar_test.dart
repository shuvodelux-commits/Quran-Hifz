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
}
