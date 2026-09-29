import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/features/home/data/hijri_calendar_month.dart';
import 'package:quran_hifz/features/home/data/islamic_calendar_events.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/presentation/widgets/calendar/calendar_month_grid.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('grid is Sunday-first and returns the exact tapped day', (
    tester,
  ) async {
    final month = _month();
    HijriCalendarDay? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(
          AppThemePreference.light,
          accent: AppAccentPreference.mint,
          language: AppLanguage.bangla,
        ),
        home: Scaffold(
          body: CalendarMonthGrid(
            month: month,
            selectedDate: month.days.first.gregorianDate,
            language: AppLanguage.bangla,
            onSelected: (day) => selected = day,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('calendar-month-grid')), findsOneWidget);
    expect(find.text('রবি'), findsOneWidget);
    expect(find.text('শনি'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('calendar-leading-blank-0')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('calendar-day-2026-9-15')));
    expect(selected, same(month.days[1]));
  });

  testWidgets('selected cell and event dot use active accent tokens', (
    tester,
  ) async {
    final month = _month();
    final theme = appTheme(
      AppThemePreference.light,
      accent: AppAccentPreference.rose,
      language: AppLanguage.bangla,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: CalendarMonthGrid(
            month: month,
            selectedDate: month.days.first.gregorianDate,
            language: AppLanguage.bangla,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    final selected = tester.widget<Container>(
      find.byKey(const ValueKey('calendar-day-2026-9-14')),
    );
    expect(
      (selected.decoration! as BoxDecoration).color,
      theme.colorScheme.primaryContainer,
    );

    final dot = tester.widget<Container>(
      find.byKey(const ValueKey('calendar-event-dot-2026-9-15')),
    );
    expect((dot.decoration! as BoxDecoration).color, theme.colorScheme.primary);
    expect(
      find.byKey(const ValueKey('calendar-event-dot-2026-9-14')),
      findsNothing,
    );
  });

  testWidgets('dark grid uses Graphite tokens', (tester) async {
    final month = _month();
    final theme = appTheme(AppThemePreference.dark);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: CalendarMonthGrid(
            month: month,
            selectedDate: month.days.first.gregorianDate,
            language: AppLanguage.bangla,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    final selected = tester.widget<Container>(
      find.byKey(const ValueKey('calendar-day-2026-9-14')),
    );
    expect(
      (selected.decoration! as BoxDecoration).color,
      theme.colorScheme.primaryContainer,
    );

    final dot = tester.widget<Container>(
      find.byKey(const ValueKey('calendar-event-dot-2026-9-15')),
    );
    expect((dot.decoration! as BoxDecoration).color, const Color(0xFF68777B));
  });

  testWidgets('grid fits a 360px phone without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final month = _month();
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(AppThemePreference.light, language: AppLanguage.bangla),
        home: Scaffold(
          body: CalendarMonthGrid(
            month: month,
            selectedDate: month.days.first.gregorianDate,
            language: AppLanguage.bangla,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final first = tester.getSize(
      find.byKey(const ValueKey('calendar-day-2026-9-14')),
    );
    expect(first.height, 36);
  });
}

HijriCalendarMonth _month() {
  final first = _day(DateTime(2026, 9, 14), 1);
  final second = _day(
    DateTime(2026, 9, 15),
    2,
    events: const [
      IslamicCalendarEvent(
        id: 'event',
        titleBangla: 'আমল',
        titleEnglish: 'Reminder',
        subtitleBangla: 'বিবরণ',
        subtitleEnglish: 'Details',
        source: 'Source',
        gradeBangla: 'সহিহ',
        gradeEnglish: 'Sahih',
        monthWide: false,
      ),
    ],
  );
  return HijriCalendarMonth(
    key: const HijriMonthKey(month: 'Rabi al-Thani', year: 1448),
    days: [first, second, _day(DateTime(2026, 9, 16), 3)],
  );
}

HijriCalendarDay _day(
  DateTime date,
  int hijriDay, {
  List<IslamicCalendarEvent> events = const [],
}) {
  return HijriCalendarDay(
    gregorianDate: date,
    hijri: HijriDateParts(day: hijriDay, month: 'Rabi al-Thani', year: 1448),
    schedule: PrayerSchedule(
      location: 'Natore, Bangladesh',
      latitude: 24.42,
      longitude: 88.99,
      hijriDate: '$hijriDay Rabi al-Thani 1448 AH',
      sunrise: DateTime(date.year, date.month, date.day, 5, 45),
      sunset: DateTime(date.year, date.month, date.day, 17, 52),
      times: {
        'Fajr': DateTime(date.year, date.month, date.day, 4, 30),
        'Dhuhr': DateTime(date.year, date.month, date.day, 12, 7),
        'Asr': DateTime(date.year, date.month, date.day, 15, 36),
        'Maghrib': DateTime(date.year, date.month, date.day, 17, 52),
        'Isha': DateTime(date.year, date.month, date.day, 19, 12),
      },
      tomorrowFajr: DateTime(date.year, date.month, date.day + 1, 4, 30),
    ),
    events: events,
  );
}
