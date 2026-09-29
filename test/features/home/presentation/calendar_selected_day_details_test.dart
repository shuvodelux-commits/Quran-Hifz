import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/features/home/data/bangla_calendar.dart';
import 'package:quran_hifz/features/home/data/hijri_calendar_month.dart';
import 'package:quran_hifz/features/home/data/islamic_calendar_events.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/presentation/widgets/calendar/calendar_selected_day_details.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('selected day shows three date systems and all prayer data', (
    tester,
  ) async {
    final day = _day();
    var shares = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(
          AppThemePreference.light,
          accent: AppAccentPreference.sky,
          language: AppLanguage.bangla,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CalendarSelectedDayDetails(
              day: day,
              language: AppLanguage.bangla,
              onShare: () => shares++,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('calendar-selected-details')),
      findsOneWidget,
    );
    expect(find.text('১৮ রবিউস সানি ১৪৪৮ হি.'), findsOneWidget);
    expect(find.textContaining('২৯ সেপ্টেম্বর ২০২৬'), findsOneWidget);
    expect(find.text(banglaCalendarDate(day.gregorianDate)), findsOneWidget);
    expect(find.text('সেহরির শেষ'), findsOneWidget);
    expect(find.text('ইফতার'), findsOneWidget);
    expect(find.text('০৪:৩৮'), findsWidgets);
    expect(find.text('০৫:৫২'), findsWidgets);
    for (final label in ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'ইশা']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Natore, Bangladesh'), findsOneWidget);
    expect(find.text('নিষিদ্ধ সময়'), findsOneWidget);
    expect(find.text('০৫:৪৫–০৬:০০'), findsOneWidget);
    expect(find.text('১২:০২–১২:০৭'), findsOneWidget);
    expect(find.text('০৫:৩৭–০৫:৫২'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-share-day')));
    expect(shares, 1);
  });

  testWidgets('English prohibited ranges remain fully readable at 360px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(
          AppThemePreference.light,
          language: AppLanguage.english,
        ),
        home: Scaffold(
          body: CalendarSelectedDayDetails(
            day: _day(),
            language: AppLanguage.english,
            onShare: () {},
          ),
        ),
      ),
    );

    expect(find.text('Prohibited times'), findsOneWidget);
    for (final range in [
      '05:45 AM–06:00 AM',
      '12:02 PM–12:07 PM',
      '05:37 PM–05:52 PM',
    ]) {
      expect(find.text(range), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected-day event shows title description source and grade', (
    tester,
  ) async {
    final day = _day(
      events: const [
        IslamicCalendarEvent(
          id: 'event',
          titleBangla: 'আইয়ামে বীয — ১ম দিন',
          titleEnglish: 'Ayyam al-Bid — Day 1',
          subtitleBangla: 'নফল রোজার দিন।',
          subtitleEnglish: 'A recommended voluntary fasting day.',
          source: 'Jamiʿ at-Tirmidhi 761',
          gradeBangla: 'হাসান',
          gradeEnglish: 'Hasan',
          monthWide: false,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(AppThemePreference.light, language: AppLanguage.bangla),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CalendarSelectedDayDetails(
              day: day,
              language: AppLanguage.bangla,
              onShare: () {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('calendar-selected-event-section')),
      findsOneWidget,
    );
    expect(find.text('আইয়ামে বীয — ১ম দিন'), findsOneWidget);
    expect(find.text('নফল রোজার দিন।'), findsOneWidget);
    expect(find.text('Jamiʿ at-Tirmidhi 761 · হাসান'), findsOneWidget);
  });

  testWidgets('no selected-day event omits reminder section', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(AppThemePreference.light, language: AppLanguage.bangla),
        home: Scaffold(
          body: CalendarSelectedDayDetails(
            day: _day(),
            language: AppLanguage.bangla,
            onShare: () {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('calendar-selected-event-section')),
      findsNothing,
    );
  });
}

HijriCalendarDay _day({List<IslamicCalendarEvent> events = const []}) {
  final date = DateTime(2026, 9, 29);
  return HijriCalendarDay(
    gregorianDate: date,
    hijri: const HijriDateParts(day: 18, month: 'Rabi al-Thani', year: 1448),
    schedule: PrayerSchedule(
      location: 'Natore, Bangladesh',
      latitude: 24.42,
      longitude: 88.99,
      hijriDate: '18 Rabi al-Thani 1448 AH',
      sunrise: DateTime(2026, 9, 29, 5, 45),
      sunset: DateTime(2026, 9, 29, 17, 52),
      times: {
        'Fajr': DateTime(2026, 9, 29, 4, 38),
        'Dhuhr': DateTime(2026, 9, 29, 12, 7),
        'Asr': DateTime(2026, 9, 29, 15, 36),
        'Maghrib': DateTime(2026, 9, 29, 17, 52),
        'Isha': DateTime(2026, 9, 29, 19, 12),
      },
      tomorrowFajr: DateTime(2026, 9, 30, 4, 38),
    ),
    events: events,
  );
}
