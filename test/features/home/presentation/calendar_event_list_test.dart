import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/features/home/data/hijri_calendar_month.dart';
import 'package:quran_hifz/features/home/data/islamic_calendar_events.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/presentation/widgets/calendar/calendar_event_list.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets(
    'month event list sorts dated reminders and appends month-wide reminder',
    (tester) async {
      final month = HijriCalendarMonth(
        key: const HijriMonthKey(month: 'Shawwal', year: 1448),
        days: [_day(15), _day(13), _day(14)],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(
            AppThemePreference.light,
            language: AppLanguage.bangla,
          ),
          home: Scaffold(
            body: CalendarEventList(month: month, language: AppLanguage.bangla),
          ),
        ),
      );

      expect(find.text('এই মাসের আমল ও গুরুত্বপূর্ণ দিন'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
      expect(find.text('আইয়ামে বীয — ১ম দিন'), findsOneWidget);
      expect(find.text('আইয়ামে বীয — ২য় দিন'), findsOneWidget);
      expect(find.text('আইয়ামে বীয — ৩য় দিন'), findsOneWidget);
      expect(find.text('শাওয়ালের ছয় রোজা'), findsOneWidget);
      expect(find.textContaining('নির্দিষ্ট ছয়টি তারিখ'), findsOneWidget);

      final first = tester.getTopLeft(find.text('আইয়ামে বীয — ১ম দিন')).dy;
      final second = tester.getTopLeft(find.text('আইয়ামে বীয — ২য় দিন')).dy;
      final third = tester.getTopLeft(find.text('আইয়ামে বীয — ৩য় দিন')).dy;
      final monthWide = tester.getTopLeft(find.text('শাওয়ালের ছয় রোজা')).dy;
      expect(first, lessThan(second));
      expect(second, lessThan(third));
      expect(third, lessThan(monthWide));
    },
  );

  testWidgets('long Bangla event rows fit a 360px phone', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final month = HijriCalendarMonth(
      key: const HijriMonthKey(month: 'Ramadan', year: 1448),
      days: [_ramadanQadrDay()],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(AppThemePreference.light, language: AppLanguage.bangla),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CalendarEventList(
              month: month,
              language: AppLanguage.bangla,
            ),
          ),
        ),
      ),
    );

    expect(find.text('লাইলাতুল কদর অনুসন্ধানের বিজোড় রাত'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

HijriCalendarDay _day(int hijriDay) {
  final date = DateTime(2026, 10, hijriDay);
  final hijri = HijriDateParts(day: hijriDay, month: 'Shawwal', year: 1448);
  return HijriCalendarDay(
    gregorianDate: date,
    hijri: hijri,
    schedule: _schedule(date, '$hijriDay Shawwal 1448 AH'),
    events: islamicEventsFor(hijri),
  );
}

HijriCalendarDay _ramadanQadrDay() {
  final date = DateTime(2027, 3, 21);
  const hijri = HijriDateParts(day: 21, month: 'Ramadan', year: 1448);
  return HijriCalendarDay(
    gregorianDate: date,
    hijri: hijri,
    schedule: _schedule(date, '21 Ramadan 1448 AH'),
    events: islamicEventsFor(hijri),
  );
}

PrayerSchedule _schedule(DateTime date, String hijri) => PrayerSchedule(
  location: 'Natore, Bangladesh',
  latitude: 24.42,
  longitude: 88.99,
  hijriDate: hijri,
  sunrise: DateTime(date.year, date.month, date.day, 5, 45),
  sunset: DateTime(date.year, date.month, date.day, 17, 52),
  times: {
    'Fajr': DateTime(date.year, date.month, date.day, 4, 38),
    'Dhuhr': DateTime(date.year, date.month, date.day, 12, 7),
    'Asr': DateTime(date.year, date.month, date.day, 15, 36),
    'Maghrib': DateTime(date.year, date.month, date.day, 17, 52),
    'Isha': DateTime(date.year, date.month, date.day, 19, 12),
  },
);
