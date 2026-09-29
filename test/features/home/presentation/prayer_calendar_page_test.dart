import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/core/localization/app_locale_text.dart';
import 'package:quran_hifz/features/home/data/bangla_calendar.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/presentation/home_page.dart';
import 'package:quran_hifz/features/home/presentation/prayer_calendar_page.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('calendar opens on current Hijri month and selects today', (
    tester,
  ) async {
    final fixture = _Fixture.current();
    await _pumpCalendar(tester, fixture: fixture);
    await tester.pumpAndSettle();

    expect(find.text('দিনপঞ্জিকা'), findsOneWidget);
    expect(find.text('রবিউস সানি ১৪৪৮'), findsOneWidget);
    expect(
      find.text(
        localGregorianDateRange(
          fixture.currentFirst,
          fixture.currentLast,
          AppLanguage.bangla,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.text(banglaCalendarRange(fixture.currentFirst, fixture.currentLast)),
      findsOneWidget,
    );

    final selected = tester.widget<Container>(
      find.byKey(
        ValueKey(
          'calendar-day-${fixture.today.year}-${fixture.today.month}-${fixture.today.day}',
        ),
      ),
    );
    expect(
      (selected.decoration! as BoxDecoration).color,
      appTheme(
        AppThemePreference.light,
        accent: AppAccentPreference.sky,
        language: AppLanguage.bangla,
      ).colorScheme.primaryContainer,
    );
    expect(find.text('১৮ রবিউস সানি ১৪৪৮ হি.'), findsOneWidget);
  });

  testWidgets('tapping a grid date updates all selected-date information', (
    tester,
  ) async {
    final fixture = _Fixture.current();
    await _pumpCalendar(tester, fixture: fixture);
    await tester.pumpAndSettle();

    final target = fixture.currentFirst.add(const Duration(days: 12));
    await tester.tap(
      find.byKey(
        ValueKey('calendar-day-${target.year}-${target.month}-${target.day}'),
      ),
    );
    await tester.pump();

    expect(find.text('১৩ রবিউস সানি ১৪৪৮ হি.'), findsOneWidget);
    expect(find.text('০৪:১৩'), findsWidgets);
    expect(find.text('আইয়ামে বীয — ১ম দিন'), findsWidgets);
    expect(find.text(banglaCalendarDate(target)), findsOneWidget);
  });

  testWidgets('previous and next arrows navigate by Hijri month', (
    tester,
  ) async {
    final fixture = _Fixture.current();
    await _pumpCalendar(tester, fixture: fixture);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calendar-next-month')));
    await tester.pumpAndSettle();
    expect(find.text('জমাদিউল আউয়াল ১৪৪৮'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-previous-month')));
    await tester.pumpAndSettle();
    expect(find.text('রবিউস সানি ১৪৪৮'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-previous-month')));
    await tester.pumpAndSettle();
    expect(find.text('রবিউল আউয়াল ১৪৪৮'), findsOneWidget);
  });

  testWidgets('month title opens compact Hijri month and year picker', (
    tester,
  ) async {
    final fixture = _Fixture.current();
    await _pumpCalendar(tester, fixture: fixture);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calendar-month-title')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('calendar-month-picker')), findsOneWidget);
    expect(find.text('মুহাররম'), findsOneWidget);
    expect(find.text('রমজান'), findsOneWidget);
    expect(find.text('১৪৪৮'), findsWidgets);
  });

  testWidgets('rapid next then previous ignores stale month completion', (
    tester,
  ) async {
    final fixture = _Fixture.current();
    final repository = _DelayedCalendarRepository(fixture.schedules);
    await _pumpCalendar(tester, fixture: fixture, repository: repository);
    await tester.pumpAndSettle();

    repository.delaySubsequentLoads = true;
    await tester.tap(find.byKey(const ValueKey('calendar-next-month')));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.tap(find.byKey(const ValueKey('calendar-previous-month')));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(find.text('রবিউস সানি ১৪৪৮'), findsOneWidget);
  });

  testWidgets('English title and no-location state remain localized', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWithValue(AppLanguage.english),
          asrSchoolProvider.overrideWithValue(AsrSchool.hanafi),
          prayerScheduleProvider.overrideWith(
            (ref) => Future<PrayerSchedule>.error(StateError('no location')),
          ),
        ],
        child: MaterialApp(
          theme: appTheme(
            AppThemePreference.light,
            language: AppLanguage.english,
          ),
          home: const PrayerCalendarPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Enable a location to use the calendar.'), findsOneWidget);
  });

  testWidgets('English loaded calendar stays clean at 360px', (tester) async {
    final fixture = _Fixture.current();
    await _pumpCalendar(
      tester,
      fixture: fixture,
      language: AppLanguage.english,
    );
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Rabi al-Thani 1448'), findsOneWidget);
    expect(find.text('Monthly reminders'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark calendar selected state is Graphite', (tester) async {
    final fixture = _Fixture.current();
    final theme = appTheme(AppThemePreference.dark);
    await _pumpCalendar(tester, fixture: fixture, theme: theme);
    await tester.pumpAndSettle();

    final selected = tester.widget<Container>(
      find.byKey(
        ValueKey(
          'calendar-day-${fixture.today.year}-${fixture.today.month}-${fixture.today.day}',
        ),
      ),
    );
    expect(
      (selected.decoration! as BoxDecoration).color,
      theme.colorScheme.primaryContainer,
    );
    expect(theme.colorScheme.primary, const Color(0xFF68777B));
  });

  testWidgets('normal phone shows core day information without scrolling', (
    tester,
  ) async {
    final fixture = _Fixture.current();
    await _pumpCalendar(
      tester,
      fixture: fixture,
      viewport: const Size(360, 600),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('calendar-month-grid')).hitTestable(),
      findsOneWidget,
    );
    expect(find.text('সেহরির শেষ').hitTestable(), findsOneWidget);
    expect(find.text('ইফতার').hitTestable(), findsOneWidget);
    for (final prayer in ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'ইশা']) {
      expect(find.text(prayer).hitTestable(), findsOneWidget);
    }
    expect(find.text('নিষিদ্ধ সময়').hitTestable(), findsOneWidget);
  });

  testWidgets('full calendar fits a narrow phone at enlarged text scale', (
    tester,
  ) async {
    final fixture = _Fixture.current();
    await _pumpCalendar(
      tester,
      fixture: fixture,
      textScaler: const TextScaler.linear(1.3),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('calendar-month-grid')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('calendar-selected-details')),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('নিষিদ্ধ সময়'), findsOneWidget);
  });

  test('share text includes three dates and all five prayers', () {
    final fixture = _Fixture.current();
    final schedule = fixture.todaySchedule;
    final text = calendarShareText(
      day: fixture.today,
      schedule: schedule,
      language: AppLanguage.bangla,
    );

    expect(text, contains('১৮ রবিউস সানি ১৪৪৮ হি.'));
    expect(
      text,
      contains(localGregorianDate(fixture.today, AppLanguage.bangla)),
    );
    expect(text, contains(banglaCalendarDate(fixture.today)));
    for (final prayer in ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'ইশা']) {
      expect(text, contains(prayer));
    }
  });
}

Future<void> _pumpCalendar(
  WidgetTester tester, {
  required _Fixture fixture,
  PrayerScheduleRepository? repository,
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
  Size viewport = const Size(360, 780),
  AppLanguage language = AppLanguage.bangla,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appLanguageProvider.overrideWithValue(language),
        asrSchoolProvider.overrideWithValue(AsrSchool.hanafi),
        prayerScheduleProvider.overrideWith(
          (ref) async => fixture.todaySchedule,
        ),
        prayerScheduleRepositoryProvider.overrideWithValue(
          repository ?? _CalendarRepository(fixture.schedules),
        ),
      ],
      child: MaterialApp(
        theme:
            theme ??
            appTheme(
              AppThemePreference.light,
              accent: AppAccentPreference.sky,
              language: language,
            ),
        home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: const PrayerCalendarPage(),
        ),
      ),
    ),
  );
}

class _Fixture {
  _Fixture({
    required this.today,
    required this.currentFirst,
    required this.schedules,
  });

  factory _Fixture.current() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentFirst = today.subtract(const Duration(days: 17));
    final previousFirst = currentFirst.subtract(const Duration(days: 30));
    final nextFirst = currentFirst.add(const Duration(days: 30));
    final afterNextFirst = nextFirst.add(const Duration(days: 30));

    final schedules = <PrayerSchedule>[
      ..._hijriMonth(previousFirst, 'Rabi al-Awwal', 1448),
      ..._hijriMonth(currentFirst, 'Rabi al-Thani', 1448),
      ..._hijriMonth(nextFirst, 'Jumada al-Ula', 1448),
      _schedule(
        afterNextFirst,
        hijriDay: 1,
        hijriMonth: 'Jumada al-Akhirah',
        hijriYear: 1448,
      ),
    ];

    return _Fixture(
      today: today,
      currentFirst: currentFirst,
      schedules: schedules,
    );
  }

  final DateTime today;
  final DateTime currentFirst;
  final List<PrayerSchedule> schedules;

  DateTime get currentLast => currentFirst.add(const Duration(days: 29));

  PrayerSchedule get todaySchedule => schedules.firstWhere(
    (schedule) => DateUtils.isSameDay(schedule.sunrise, today),
  );
}

List<PrayerSchedule> _hijriMonth(DateTime first, String month, int year) => [
  for (var day = 1; day <= 30; day++)
    _schedule(
      first.add(Duration(days: day - 1)),
      hijriDay: day,
      hijriMonth: month,
      hijriYear: year,
    ),
];

PrayerSchedule _schedule(
  DateTime date, {
  required int hijriDay,
  required String hijriMonth,
  required int hijriYear,
}) {
  return PrayerSchedule(
    location: 'Natore, Bangladesh',
    latitude: 24.42,
    longitude: 88.99,
    hijriDate: '$hijriDay $hijriMonth $hijriYear AH',
    sunrise: DateTime(date.year, date.month, date.day, 5, 45),
    sunset: DateTime(date.year, date.month, date.day, 17, 52),
    times: {
      'Fajr': DateTime(date.year, date.month, date.day, 4, hijriDay),
      'Dhuhr': DateTime(date.year, date.month, date.day, 12, 7),
      'Asr': DateTime(date.year, date.month, date.day, 15, 36),
      'Maghrib': DateTime(date.year, date.month, date.day, 17, 52),
      'Isha': DateTime(date.year, date.month, date.day, 19, 12),
    },
    tomorrowFajr: DateTime(date.year, date.month, date.day + 1, 4, 30),
  );
}

class _CalendarRepository extends PrayerScheduleRepository {
  const _CalendarRepository(this.schedules);

  final List<PrayerSchedule> schedules;

  @override
  Future<List<PrayerSchedule>> loadMonth({
    required int year,
    required int month,
    required String location,
    required double latitude,
    required double longitude,
    int utcOffsetMinutes = 360,
    AsrSchool school = AsrSchool.hanafi,
  }) async {
    return [
      for (final schedule in schedules)
        if (schedule.sunrise.year == year && schedule.sunrise.month == month)
          schedule,
    ];
  }
}

class _DelayedCalendarRepository extends _CalendarRepository {
  _DelayedCalendarRepository(super.schedules);

  bool delaySubsequentLoads = false;

  @override
  Future<List<PrayerSchedule>> loadMonth({
    required int year,
    required int month,
    required String location,
    required double latitude,
    required double longitude,
    int utcOffsetMinutes = 360,
    AsrSchool school = AsrSchool.hanafi,
  }) async {
    if (delaySubsequentLoads) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    return super.loadMonth(
      year: year,
      month: month,
      location: location,
      latitude: latitude,
      longitude: longitude,
      utcOffsetMinutes: utcOffsetMinutes,
      school: school,
    );
  }
}
