import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/home/data/hijri_calendar_month.dart';
import 'package:quran_hifz/features/home/data/islamic_calendar_events.dart';

void main() {
  test('Ayyam al-Bid appears on 13 14 and 15 with Hasan metadata', () {
    for (final day in [13, 14, 15]) {
      final events = islamicEventsFor(
        HijriDateParts(day: day, month: 'Rabi al-Thani', year: 1448),
      );

      expect(events, hasLength(1));
      expect(events.single.id, 'ayyam-al-bid-$day');
      expect(events.single.titleBangla, contains('আইয়ামে বীয'));
      expect(events.single.gradeBangla, 'হাসান');
      expect(events.single.gradeEnglish, 'Hasan');
      expect(events.single.source, 'Jamiʿ at-Tirmidhi 761');
      expect(events.single.monthWide, isFalse);
    }
  });

  test('Ashura appears on 10 Muharram with Sahih metadata', () {
    final events = islamicEventsFor(
      const HijriDateParts(day: 10, month: 'Muharram', year: 1448),
    );

    expect(events.map((event) => event.id), contains('ashura-fast'));
    final ashura = events.singleWhere((event) => event.id == 'ashura-fast');
    expect(ashura.titleBangla, contains('আশুরা'));
    expect(ashura.source, 'Sahih al-Bukhari 1892');
    expect(ashura.gradeBangla, 'সহিহ');
  });

  test('Arafah fasting appears on 9 Dhu al-Hijjah with Sahih metadata', () {
    final events = islamicEventsFor(
      const HijriDateParts(day: 9, month: 'Dhu al-Hijjah', year: 1448),
    );

    expect(events, hasLength(1));
    expect(events.single.id, 'arafah-fast');
    expect(events.single.titleBangla, contains('আরাফা'));
    expect(events.single.source, 'Sahih Muslim 1162a');
    expect(events.single.gradeEnglish, 'Sahih');
  });

  test('Ramadan odd nights expose Laylat al-Qadr reminder', () {
    for (final day in [21, 23, 25, 27, 29]) {
      final events = islamicEventsFor(
        HijriDateParts(day: day, month: 'Ramadan', year: 1448),
      );

      expect(events, hasLength(1));
      expect(events.single.id, 'laylat-al-qadr-$day');
      expect(events.single.titleBangla, contains('লাইলাতুল কদর'));
      expect(events.single.source, 'Sahih al-Bukhari 2017');
      expect(events.single.gradeBangla, 'সহিহ');
    }
  });

  test('Shawwal six-fast reminder is month-wide and never a day event', () {
    final reminder = islamicMonthRemindersFor(
      const HijriMonthKey(month: 'Shawwal', year: 1448),
    );

    expect(reminder, hasLength(1));
    expect(reminder.single.id, 'shawwal-six-fasts');
    expect(reminder.single.titleBangla, contains('শাওয়ালের ছয় রোজা'));
    expect(reminder.single.source, 'Sahih Muslim 1164b/1164c');
    expect(reminder.single.gradeBangla, 'সহিহ');
    expect(reminder.single.monthWide, isTrue);

    expect(
      islamicEventsFor(
        const HijriDateParts(day: 2, month: 'Shawwal', year: 1448),
      ),
      isEmpty,
    );
  });

  test('normal date has no date-specific event', () {
    expect(
      islamicEventsFor(
        const HijriDateParts(day: 18, month: 'Rabi al-Thani', year: 1448),
      ),
      isEmpty,
    );
  });

  test('Dhu al-Hijjah 11 to 13 show Tashriq instead of fasting prompt', () {
    for (final day in [11, 12, 13]) {
      final events = islamicEventsFor(
        HijriDateParts(day: day, month: 'Dhu al-Hijjah', year: 1448),
      );

      expect(events.map((event) => event.id), contains('tashriq-$day'));
      expect(events.any((event) => event.id == 'ayyam-al-bid-13'), isFalse);
      final tashriq = events.singleWhere((event) => event.id == 'tashriq-$day');
      expect(tashriq.source, 'Sahih Muslim 1141a');
      expect(tashriq.gradeEnglish, 'Sahih');
    }
  });
}
