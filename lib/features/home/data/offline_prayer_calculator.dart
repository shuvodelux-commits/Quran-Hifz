import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:hijri_core/hijri_core.dart' as hijri_core;

import '../../settings/domain/app_preferences.dart';
import 'prayer_schedule.dart';

/// Calculates the existing Karachi method from stored coordinates, without I/O.
class OfflinePrayerCalculator {
  const OfflinePrayerCalculator();

  PrayerSchedule calculate(
    DateTime day,
    PrayerLocation location,
    AsrSchool school,
  ) {
    final today = _times(day, location, school);
    final tomorrow = DateTime(day.year, day.month, day.day + 1);
    final next = _times(tomorrow, location, school);
    return PrayerSchedule(
      location: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
      utcOffsetMinutes: location.utcOffsetMinutes,
      hijriDate: _hijriText(day),
      tomorrowHijriDate: _hijriText(tomorrow),
      sunrise: _wallTime(today.sunrise, location.utcOffsetMinutes),
      sunset: _wallTime(today.sunset, location.utcOffsetMinutes),
      times: {
        'Fajr': _wallTime(today.fajr, location.utcOffsetMinutes),
        'Dhuhr': _wallTime(today.dhuhr, location.utcOffsetMinutes),
        'Asr': _wallTime(today.asr, location.utcOffsetMinutes),
        'Maghrib': _wallTime(today.maghrib, location.utcOffsetMinutes),
        'Isha': _wallTime(today.isha, location.utcOffsetMinutes),
      },
      tomorrowFajr: _wallTime(next.fajr, location.utcOffsetMinutes),
      tomorrowMaghrib: _wallTime(next.maghrib, location.utcOffsetMinutes),
    );
  }

  adhan.PrayerTimes _times(
    DateTime day,
    PrayerLocation location,
    AsrSchool school,
  ) {
    final parameters = adhan.CalculationMethodParameters.karachi()
      ..madhab = school == AsrSchool.hanafi
          ? adhan.Madhab.hanafi
          : adhan.Madhab.shafi;
    return adhan.PrayerTimes(
      coordinates: adhan.Coordinates(location.latitude, location.longitude),
      date: DateTime.utc(day.year, day.month, day.day),
      calculationParameters: parameters,
    );
  }

  DateTime _wallTime(DateTime utc, int offsetMinutes) {
    final wall = utc.toUtc().add(Duration(minutes: offsetMinutes));
    return DateTime(wall.year, wall.month, wall.day, wall.hour, wall.minute);
  }

  String _hijriText(DateTime date) {
    const names = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Shaban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qadah',
      'Dhu al-Hijjah',
    ];
    final official = hijri_core.toHijri(
      DateTime.utc(date.year, date.month, date.day),
    );
    if (official != null) {
      return '${official.hd} ${names[official.hm - 1]} ${official.hy} AH';
    }
    final a = (14 - date.month) ~/ 12;
    final y = date.year + 4800 - a;
    final m = date.month + 12 * a - 3;
    final jdn =
        date.day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
    final year = (30 * (jdn - 1948440) + 10646) ~/ 10631;
    var month = 1;
    while (month < 12 && _islamicJdn(year, month + 1, 1) <= jdn) {
      month++;
    }
    final day = jdn - _islamicJdn(year, month, 1) + 1;
    return '$day ${names[month - 1]} $year AH';
  }

  int _islamicJdn(int year, int month, int day) =>
      day +
      ((59 * (month - 1) + 1) ~/ 2) +
      (year - 1) * 354 +
      (3 + 11 * year) ~/ 30 +
      1948439;
}
