import '../../settings/domain/app_preferences.dart';
import 'islamic_calendar_events.dart';
import 'prayer_schedule.dart';

const hijriMonthOrder = <String>[
  'Muharram',
  'Safar',
  'Rabi al-Awwal',
  'Rabi al-Thani',
  'Jumada al-Ula',
  'Jumada al-Akhirah',
  'Rajab',
  "Sha'ban",
  'Ramadan',
  'Shawwal',
  "Dhu al-Qi'dah",
  'Dhu al-Hijjah',
];

const _hijriMonthAliases = <String, String>{
  'Jumada al-Awwal': 'Jumada al-Ula',
  'Jumada al-Thani': 'Jumada al-Akhirah',
  'Shaban': "Sha'ban",
  'Dhu al-Qadah': "Dhu al-Qi'dah",
};

class HijriDateParts {
  const HijriDateParts({
    required this.day,
    required this.month,
    required this.year,
  });

  final int day;
  final String month;
  final int year;

  HijriMonthKey get monthKey => HijriMonthKey(month: month, year: year);

  @override
  bool operator ==(Object other) =>
      other is HijriDateParts &&
      other.day == day &&
      other.month == month &&
      other.year == year;

  @override
  int get hashCode => Object.hash(day, month, year);
}

class HijriMonthKey {
  const HijriMonthKey({required this.month, required this.year});

  final String month;
  final int year;

  @override
  bool operator ==(Object other) =>
      other is HijriMonthKey && other.month == month && other.year == year;

  @override
  int get hashCode => Object.hash(month, year);
}

class HijriCalendarDay {
  const HijriCalendarDay({
    required this.gregorianDate,
    required this.hijri,
    required this.schedule,
    required this.events,
  });

  final DateTime gregorianDate;
  final HijriDateParts hijri;
  final PrayerSchedule schedule;
  final List<IslamicCalendarEvent> events;
}

class HijriCalendarMonth {
  const HijriCalendarMonth({required this.key, required this.days});

  final HijriMonthKey key;
  final List<HijriCalendarDay> days;
}

HijriDateParts? parseHijriDate(String value) {
  final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  final match = RegExp(r'^(\d{1,2}) (.+) (\d+) AH$').firstMatch(normalized);
  if (match == null) return null;

  final day = int.tryParse(match.group(1)!);
  final rawMonth = match.group(2)!;
  final month = _hijriMonthAliases[rawMonth] ?? rawMonth;
  final year = int.tryParse(match.group(3)!);
  if (day == null ||
      day < 1 ||
      day > 30 ||
      year == null ||
      year < 1 ||
      !hijriMonthOrder.contains(month)) {
    return null;
  }

  return HijriDateParts(day: day, month: month, year: year);
}

HijriMonthKey nextHijriMonth(HijriMonthKey current) {
  final index = _monthIndex(current.month);
  if (index == hijriMonthOrder.length - 1) {
    return HijriMonthKey(month: hijriMonthOrder.first, year: current.year + 1);
  }
  return HijriMonthKey(month: hijriMonthOrder[index + 1], year: current.year);
}

HijriMonthKey previousHijriMonth(HijriMonthKey current) {
  final index = _monthIndex(current.month);
  if (index == 0) {
    return HijriMonthKey(month: hijriMonthOrder.last, year: current.year - 1);
  }
  return HijriMonthKey(month: hijriMonthOrder[index - 1], year: current.year);
}

int hijriMonthDelta(HijriMonthKey from, HijriMonthKey to) {
  final fromSerial = from.year * 12 + _monthIndex(from.month);
  final toSerial = to.year * 12 + _monthIndex(to.month);
  return toSerial - fromSerial;
}

class HijriCalendarMonthLoader {
  const HijriCalendarMonthLoader(this._repository);

  final PrayerScheduleRepository _repository;

  Future<HijriCalendarMonth> load({
    required HijriMonthKey target,
    required DateTime anchorDate,
    required String location,
    required double latitude,
    required double longitude,
    required int utcOffsetMinutes,
    required AsrSchool school,
  }) async {
    final anchorMonth = DateTime(anchorDate.year, anchorDate.month);
    var earliestMonth = DateTime(anchorMonth.year, anchorMonth.month - 1);
    var latestMonth = DateTime(anchorMonth.year, anchorMonth.month + 1);
    final schedulesByDate = <DateTime, PrayerSchedule>{};

    Future<void> fetchMonth(DateTime month) async {
      final schedules = await _repository.loadMonth(
        year: month.year,
        month: month.month,
        location: location,
        latitude: latitude,
        longitude: longitude,
        utcOffsetMinutes: utcOffsetMinutes,
        school: school,
      );
      for (final schedule in schedules) {
        schedulesByDate.putIfAbsent(_scheduleDate(schedule), () => schedule);
      }
    }

    await Future.wait([
      fetchMonth(earliestMonth),
      fetchMonth(anchorMonth),
      fetchMonth(latestMonth),
    ]);

    var expandedEarlier = false;
    var expandedLater = false;

    while (true) {
      final inspection = _inspect(target, schedulesByDate);
      switch (inspection) {
        case _MonthInspection.complete:
          return _compose(target, schedulesByDate);
        case _MonthInspection.needEarlier:
          if (expandedEarlier) {
            throw StateError('Hijri month is incomplete at its start.');
          }
          earliestMonth = DateTime(earliestMonth.year, earliestMonth.month - 1);
          expandedEarlier = true;
          await fetchMonth(earliestMonth);
        case _MonthInspection.needLater:
          if (expandedLater) {
            throw StateError('Hijri month is incomplete at its end.');
          }
          latestMonth = DateTime(latestMonth.year, latestMonth.month + 1);
          expandedLater = true;
          await fetchMonth(latestMonth);
      }
    }
  }

  DateTime estimateAnchor({
    required HijriMonthKey from,
    required DateTime fromAnchor,
    required HijriMonthKey to,
  }) {
    final days = (hijriMonthDelta(from, to) * 29.53059).round();
    final normalized = DateTime(
      fromAnchor.year,
      fromAnchor.month,
      fromAnchor.day,
    );
    return normalized.add(Duration(days: days));
  }

  _MonthInspection _inspect(
    HijriMonthKey target,
    Map<DateTime, PrayerSchedule> schedulesByDate,
  ) {
    final parsed = _targetRows(target, schedulesByDate);
    if (parsed.isEmpty) {
      throw StateError('Requested Hijri month is unavailable.');
    }
    if (parsed.first.hijri.day != 1) return _MonthInspection.needEarlier;

    for (var index = 1; index < parsed.length; index++) {
      if (parsed[index].hijri.day != parsed[index - 1].hijri.day + 1) {
        throw StateError('Hijri month contains a gap or duplicate day.');
      }
      if (parsed[index].gregorianDate
              .difference(parsed[index - 1].gregorianDate)
              .inDays !=
          1) {
        throw StateError('Hijri month Gregorian dates are not consecutive.');
      }
    }

    final last = parsed.last;
    if (last.hijri.day != 29 && last.hijri.day != 30) {
      return _MonthInspection.needLater;
    }

    final boundaryDate = last.gregorianDate.add(const Duration(days: 1));
    final boundarySchedule = schedulesByDate[boundaryDate];
    if (boundarySchedule == null) return _MonthInspection.needLater;
    final boundaryHijri = parseHijriDate(boundarySchedule.hijriDate);
    final expectedNext = nextHijriMonth(target);
    if (boundaryHijri == null ||
        boundaryHijri.day != 1 ||
        boundaryHijri.monthKey != expectedNext) {
      throw StateError('Hijri month boundary is invalid.');
    }

    return _MonthInspection.complete;
  }

  HijriCalendarMonth _compose(
    HijriMonthKey target,
    Map<DateTime, PrayerSchedule> schedulesByDate,
  ) {
    final rows = _targetRows(target, schedulesByDate);
    return HijriCalendarMonth(
      key: target,
      days: [
        for (final row in rows)
          HijriCalendarDay(
            gregorianDate: row.gregorianDate,
            hijri: row.hijri,
            schedule: row.schedule,
            events: islamicEventsFor(row.hijri),
          ),
      ],
    );
  }

  List<_ParsedSchedule> _targetRows(
    HijriMonthKey target,
    Map<DateTime, PrayerSchedule> schedulesByDate,
  ) {
    final rows = <_ParsedSchedule>[];
    for (final entry in schedulesByDate.entries) {
      final hijri = parseHijriDate(entry.value.hijriDate);
      if (hijri == null || hijri.monthKey != target) continue;
      rows.add(
        _ParsedSchedule(
          gregorianDate: entry.key,
          hijri: hijri,
          schedule: entry.value,
        ),
      );
    }
    rows.sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
    return rows;
  }
}

enum _MonthInspection { complete, needEarlier, needLater }

class _ParsedSchedule {
  const _ParsedSchedule({
    required this.gregorianDate,
    required this.hijri,
    required this.schedule,
  });

  final DateTime gregorianDate;
  final HijriDateParts hijri;
  final PrayerSchedule schedule;
}

DateTime _scheduleDate(PrayerSchedule schedule) {
  final value = schedule.sunrise;
  return DateTime(value.year, value.month, value.day);
}

int _monthIndex(String month) {
  final index = hijriMonthOrder.indexOf(month);
  if (index < 0) {
    throw ArgumentError.value(month, 'month', 'Unknown Hijri month');
  }
  return index;
}
