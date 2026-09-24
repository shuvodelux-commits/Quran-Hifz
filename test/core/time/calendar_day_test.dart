import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/time/calendar_day.dart';

void main() {
  test('UTC day end includes the final microsecond of the calendar day', () {
    final value = calendarDayEnd(DateTime.utc(2026, 9, 4, 12));

    expect(value, DateTime.utc(2026, 9, 4, 23, 59, 59, 999, 999));
  });

  test('day offsets use calendar dates across month boundaries', () {
    final value = calendarDayStart(DateTime.utc(2026, 9, 2), offsetDays: -6);

    expect(value, DateTime.utc(2026, 8, 27));
  });
}
