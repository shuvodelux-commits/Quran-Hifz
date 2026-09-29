import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/home/data/hijri_calendar_month.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

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

  test(
    'loader composes a 30-day Hijri month spanning two Gregorian months',
    () async {
      const target = HijriMonthKey(month: 'Rabi al-Thani', year: 1448);
      final schedules = _schedulesForHijriMonth(
        start: DateTime(2026, 9, 12),
        count: 30,
        target: target,
      );
      final repository = _FakePrayerScheduleRepository(
        _groupByGregorianMonth(schedules),
      );
      final loader = HijriCalendarMonthLoader(repository);

      final month = await loader.load(
        target: target,
        anchorDate: DateTime(2026, 9, 29),
        location: 'Natore',
        latitude: 24.42,
        longitude: 88.99,
        utcOffsetMinutes: 360,
        school: AsrSchool.hanafi,
      );

      expect(month.key, target);
      expect(month.days, hasLength(30));
      expect(month.days.first.gregorianDate, DateTime(2026, 9, 12));
      expect(month.days.last.gregorianDate, DateTime(2026, 10, 11));
      expect(month.days[12].events, isNotEmpty);
    },
  );

  test(
    'loader accepts a complete 29-day month only with next month day 1',
    () async {
      const target = HijriMonthKey(month: 'Jumada al-Ula', year: 1448);
      final schedules = _schedulesForHijriMonth(
        start: DateTime(2026, 10, 12),
        count: 29,
        target: target,
      );
      final repository = _FakePrayerScheduleRepository(
        _groupByGregorianMonth(schedules),
      );

      final month = await HijriCalendarMonthLoader(repository).load(
        target: target,
        anchorDate: DateTime(2026, 10, 20),
        location: 'Natore',
        latitude: 24.42,
        longitude: 88.99,
        utcOffsetMinutes: 360,
        school: AsrSchool.hanafi,
      );

      expect(month.days, hasLength(29));

      final withoutBoundary = schedules.sublist(0, schedules.length - 1);
      final incompleteRepository = _FakePrayerScheduleRepository(
        _groupByGregorianMonth(withoutBoundary),
      );
      expect(
        () => HijriCalendarMonthLoader(incompleteRepository).load(
          target: target,
          anchorDate: DateTime(2026, 10, 20),
          location: 'Natore',
          latitude: 24.42,
          longitude: 88.99,
          utcOffsetMinutes: 360,
          school: AsrSchool.hanafi,
        ),
        throwsStateError,
      );
    },
  );

  test(
    'loader de-duplicates overlapping Gregorian source rows by date',
    () async {
      const target = HijriMonthKey(month: 'Rabi al-Thani', year: 1448);
      final schedules = _schedulesForHijriMonth(
        start: DateTime(2026, 9, 12),
        count: 30,
        target: target,
      );
      final grouped = _groupByGregorianMonth(schedules);
      final octoberFirst = schedules.firstWhere(
        (schedule) =>
            schedule.sunrise.year == 2026 &&
            schedule.sunrise.month == 10 &&
            schedule.sunrise.day == 1,
      );
      grouped['2026-9'] = [...?grouped['2026-9'], octoberFirst];
      final repository = _FakePrayerScheduleRepository(grouped);

      final month = await HijriCalendarMonthLoader(repository).load(
        target: target,
        anchorDate: DateTime(2026, 9, 29),
        location: 'Natore',
        latitude: 24.42,
        longitude: 88.99,
        utcOffsetMinutes: 360,
        school: AsrSchool.hanafi,
      );

      expect(month.days, hasLength(30));
      expect(month.days.map((day) => day.gregorianDate).toSet(), hasLength(30));
    },
  );

  test('loader rejects a target missing Hijri day 1', () async {
    const target = HijriMonthKey(month: 'Rabi al-Thani', year: 1448);
    final schedules = _schedulesForHijriMonth(
      start: DateTime(2026, 9, 12),
      count: 30,
      target: target,
    )..removeAt(0);
    final repository = _FakePrayerScheduleRepository(
      _groupByGregorianMonth(schedules),
    );

    expect(
      () => HijriCalendarMonthLoader(repository).load(
        target: target,
        anchorDate: DateTime(2026, 9, 29),
        location: 'Natore',
        latitude: 24.42,
        longitude: 88.99,
        utcOffsetMinutes: 360,
        school: AsrSchool.hanafi,
      ),
      throwsStateError,
    );
  });

  test('loader rejects a gap or duplicate Hijri day', () async {
    const target = HijriMonthKey(month: 'Rabi al-Thani', year: 1448);
    final schedules = _schedulesForHijriMonth(
      start: DateTime(2026, 9, 12),
      count: 30,
      target: target,
    );
    final duplicateDate = DateTime(2026, 9, 24);
    final index = schedules.indexWhere(
      (schedule) =>
          schedule.sunrise.year == duplicateDate.year &&
          schedule.sunrise.month == duplicateDate.month &&
          schedule.sunrise.day == duplicateDate.day,
    );
    schedules[index] = _schedule(duplicateDate, '12 Rabi al-Thani 1448 AH');
    final repository = _FakePrayerScheduleRepository(
      _groupByGregorianMonth(schedules),
    );

    expect(
      () => HijriCalendarMonthLoader(repository).load(
        target: target,
        anchorDate: DateTime(2026, 9, 29),
        location: 'Natore',
        latitude: 24.42,
        longitude: 88.99,
        utcOffsetMinutes: 360,
        school: AsrSchool.hanafi,
      ),
      throwsStateError,
    );
  });

  test(
    'loader expands one Gregorian month when search window is incomplete',
    () async {
      const target = HijriMonthKey(month: 'Rajab', year: 1448);
      final schedules = _schedulesForHijriMonth(
        start: DateTime(2026, 12, 28),
        count: 30,
        target: target,
      );
      final repository = _FakePrayerScheduleRepository(
        _groupByGregorianMonth(schedules),
      );

      final month = await HijriCalendarMonthLoader(repository).load(
        target: target,
        anchorDate: DateTime(2026, 11, 1),
        location: 'Natore',
        latitude: 24.42,
        longitude: 88.99,
        utcOffsetMinutes: 360,
        school: AsrSchool.hanafi,
      );

      expect(month.days, hasLength(30));
      expect(repository.requests, contains('2027-1'));
    },
  );

  test('loader handles December to January Gregorian rollover', () async {
    const target = HijriMonthKey(month: 'Rajab', year: 1448);
    final schedules = _schedulesForHijriMonth(
      start: DateTime(2026, 12, 20),
      count: 30,
      target: target,
    );
    final repository = _FakePrayerScheduleRepository(
      _groupByGregorianMonth(schedules),
    );

    final month = await HijriCalendarMonthLoader(repository).load(
      target: target,
      anchorDate: DateTime(2027, 1, 2),
      location: 'Natore',
      latitude: 24.42,
      longitude: 88.99,
      utcOffsetMinutes: 360,
      school: AsrSchool.hanafi,
    );

    expect(month.days.first.gregorianDate, DateTime(2026, 12, 20));
    expect(month.days.last.gregorianDate, DateTime(2027, 1, 18));
    expect(repository.requests, containsAll(['2026-12', '2027-1']));
  });

  test('estimateAnchor uses lunar month delta only as a search estimate', () {
    final loader = HijriCalendarMonthLoader(
      _FakePrayerScheduleRepository(const {}),
    );
    final anchor = loader.estimateAnchor(
      from: const HijriMonthKey(month: 'Rabi al-Thani', year: 1448),
      fromAnchor: DateTime(2026, 9, 29),
      to: const HijriMonthKey(month: 'Ramadan', year: 1448),
    );

    expect(anchor.difference(DateTime(2026, 9, 29)).inDays, 148);
  });
}

List<PrayerSchedule> _schedulesForHijriMonth({
  required DateTime start,
  required int count,
  required HijriMonthKey target,
}) {
  final schedules = <PrayerSchedule>[
    for (var index = 0; index < count; index++)
      _schedule(
        start.add(Duration(days: index)),
        '${index + 1} ${target.month} ${target.year} AH',
      ),
  ];
  final next = nextHijriMonth(target);
  schedules.add(
    _schedule(
      start.add(Duration(days: count)),
      '1 ${next.month} ${next.year} AH',
    ),
  );
  return schedules;
}

Map<String, List<PrayerSchedule>> _groupByGregorianMonth(
  List<PrayerSchedule> schedules,
) {
  final grouped = <String, List<PrayerSchedule>>{};
  for (final schedule in schedules) {
    final day = schedule.sunrise;
    grouped
        .putIfAbsent('${day.year}-${day.month}', () => <PrayerSchedule>[])
        .add(schedule);
  }
  return grouped;
}

PrayerSchedule _schedule(DateTime day, String hijriDate) {
  return PrayerSchedule(
    location: 'Natore',
    latitude: 24.42,
    longitude: 88.99,
    hijriDate: hijriDate,
    sunrise: DateTime(day.year, day.month, day.day, 5, 45),
    sunset: DateTime(day.year, day.month, day.day, 17, 52),
    times: {
      'Fajr': DateTime(day.year, day.month, day.day, 4, 30),
      'Dhuhr': DateTime(day.year, day.month, day.day, 12, 5),
      'Asr': DateTime(day.year, day.month, day.day, 15, 30),
      'Maghrib': DateTime(day.year, day.month, day.day, 17, 52),
      'Isha': DateTime(day.year, day.month, day.day, 19, 10),
    },
  );
}

class _FakePrayerScheduleRepository extends PrayerScheduleRepository {
  _FakePrayerScheduleRepository(this.months);

  final Map<String, List<PrayerSchedule>> months;
  final List<String> requests = [];

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
    final key = '$year-$month';
    requests.add(key);
    return [...?months[key]];
  }
}
