import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/core/localization/app_locale_text.dart';
import 'package:quran_hifz/features/home/application/bangladesh_hijri_date_providers.dart';
import 'package:quran_hifz/features/home/data/bangladesh_hijri_date.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/presentation/home_page.dart';
import 'package:quran_hifz/features/home/presentation/prayer_calendar_page.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('current month opens on today so calendar matches home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = [
      for (var day = 1; day <= DateTime(now.year, now.month + 1, 0).day; day++)
        _scheduleFor(DateTime(now.year, now.month, day)),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bangladeshHijriDateRepositoryProvider.overrideWithValue(
            _FakeHijriRepository(),
          ),
          appLanguageProvider.overrideWithValue(AppLanguage.bangla),
          asrSchoolProvider.overrideWithValue(AsrSchool.hanafi),
          prayerScheduleProvider.overrideWith(
            (ref) async => _scheduleFor(today),
          ),
          prayerScheduleRepositoryProvider.overrideWithValue(
            _CalendarRepository(days),
          ),
        ],
        child: const MaterialApp(home: PrayerCalendarPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining(localGregorianDate(today, AppLanguage.bangla)),
      findsOneWidget,
    );
    expect(find.text('০৫:৫৩–০৬:০৮'), findsOneWidget);
    expect(find.text('নফল সালাতের সময়'), findsWidgets);
    expect(find.text('দুহা'), findsWidgets);
    expect(find.text('তাহাজ্জুদ'), findsWidgets);
  });

  testWidgets(
    'calendar selector starts compact and expands to the full month',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final days = [
        for (
          var day = 1;
          day <= DateTime(now.year, now.month + 1, 0).day;
          day++
        )
          _scheduleFor(DateTime(now.year, now.month, day)),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bangladeshHijriDateRepositoryProvider.overrideWithValue(
              _FakeHijriRepository(),
            ),
            appLanguageProvider.overrideWithValue(AppLanguage.bangla),
            asrSchoolProvider.overrideWithValue(AsrSchool.hanafi),
            prayerScheduleProvider.overrideWith(
              (ref) async => _scheduleFor(today),
            ),
            prayerScheduleRepositoryProvider.overrideWithValue(
              _CalendarRepository(days),
            ),
          ],
          child: const MaterialApp(home: PrayerCalendarPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('calendar-week-strip')), findsOneWidget);
      expect(find.byKey(const ValueKey('calendar-date-strip')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('calendar-expand-handle')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('calendar-month-grid')), findsNothing);

      await tester.drag(
        find.byKey(const ValueKey('calendar-date-strip')),
        const Offset(-180, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('calendar-expand-handle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('calendar-week-strip')), findsNothing);
      expect(find.byKey(const ValueKey('calendar-month-grid')), findsOneWidget);
      expect(find.byType(DropdownButton<int>), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey('calendar-expand-handle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('calendar-week-strip')), findsOneWidget);
      expect(find.byKey(const ValueKey('calendar-month-grid')), findsNothing);
    },
  );

  testWidgets('prohibited-time chips follow the selected theme color', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final schedule = _scheduleFor(today);
    final theme = appTheme(
      AppThemePreference.green,
      language: AppLanguage.english,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bangladeshHijriDateRepositoryProvider.overrideWithValue(
            _FakeHijriRepository(),
          ),
          appLanguageProvider.overrideWithValue(AppLanguage.english),
          asrSchoolProvider.overrideWithValue(AsrSchool.hanafi),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
          prayerScheduleRepositoryProvider.overrideWithValue(
            _CalendarRepository([schedule]),
          ),
        ],
        child: MaterialApp(theme: theme, home: const PrayerCalendarPage()),
      ),
    );
    await tester.pumpAndSettle();

    final chipContainers = tester.widgetList<Container>(
      find.ancestor(of: find.text('Morning'), matching: find.byType(Container)),
    );
    final chip = chipContainers.firstWhere(
      (container) =>
          container.decoration is BoxDecoration &&
          (container.decoration! as BoxDecoration).borderRadius ==
              BorderRadius.circular(10),
    );
    expect(
      (chip.decoration! as BoxDecoration).color,
      theme.colorScheme.primaryContainer,
    );
  });
}

class _FakeHijriRepository extends BangladeshHijriDateRepository {
  @override
  Future<Map<int, ResolvedHijriDate>> convertMonth(int year, int month) async {
    final count = DateTime(year, month + 1, 0).day;
    return {
      for (var day = 1; day <= count; day++)
        day: const ResolvedHijriDate(
          day: 19,
          month: 3,
          year: 1448,
          monthName: 'Rabi al-Awwal',
          source: HijriDateSource.hjcosa,
        ),
    };
  }
}

class _CalendarRepository extends PrayerScheduleRepository {
  const _CalendarRepository(this.days);

  final List<PrayerSchedule> days;

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
    return days;
  }
}

PrayerSchedule _scheduleFor(DateTime day) {
  final isToday = DateUtils.isSameDay(day, DateTime.now());
  final sunsetMinute = isToday ? 8 : 23;
  return PrayerSchedule(
    location: 'Natore, Bangladesh',
    latitude: 24.42,
    longitude: 88.99,
    hijriDate: '19 Rabi al-Awwal 1448 AH',
    sunrise: DateTime(day.year, day.month, day.day, 5, 45),
    sunset: DateTime(day.year, day.month, day.day, 18, sunsetMinute),
    times: {
      'Fajr': DateTime(day.year, day.month, day.day, 4, 27),
      'Dhuhr': DateTime(day.year, day.month, day.day, 12, 5),
      'Asr': DateTime(day.year, day.month, day.day, 15, 23),
      'Maghrib': DateTime(day.year, day.month, day.day, 18, sunsetMinute),
      'Isha': DateTime(day.year, day.month, day.day, 19, 40),
    },
    tomorrowFajr: DateTime(day.year, day.month, day.day + 1, 4, 27),
  );
}
