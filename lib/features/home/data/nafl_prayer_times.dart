import 'prayer_schedule.dart';

class NaflPrayerTimes {
  const NaflPrayerTimes({
    required this.duhaStart,
    required this.duhaEnd,
    required this.zawalStart,
    required this.awwabinStart,
    required this.awwabinEnd,
    required this.tahajjudStart,
    required this.tahajjudEnd,
    required this.lastThirdStart,
    required this.nextSuhurEnd,
    required this.nextIftar,
  });

  final DateTime? duhaStart;
  final DateTime? duhaEnd;
  final DateTime? zawalStart;
  final DateTime? awwabinStart;
  final DateTime? awwabinEnd;
  final DateTime? tahajjudStart;
  final DateTime? tahajjudEnd;
  final DateTime? lastThirdStart;
  final DateTime? nextSuhurEnd;
  final DateTime? nextIftar;

  factory NaflPrayerTimes.fromSchedule(
    PrayerSchedule schedule, {
    required DateTime now,
    DateTime? nextFajr,
    DateTime? nextMaghrib,
  }) {
    final fajr = schedule.times['Fajr'];
    final dhuhr = schedule.times['Dhuhr'];
    final maghrib = schedule.times['Maghrib'];
    final isha = schedule.times['Isha'];
    final tomorrowFajr =
        nextFajr ??
        schedule.tomorrowFajr ??
        fajr?.add(const Duration(days: 1));
    final tomorrowMaghrib =
        nextMaghrib ??
        schedule.tomorrowMaghrib ??
        maghrib?.add(const Duration(days: 1));

    final duhaStart = schedule.sunrise.add(const Duration(minutes: 15));
    final duhaEnd = dhuhr?.subtract(const Duration(minutes: 10));
    final zawalStart = dhuhr?.subtract(const Duration(minutes: 5));

    return NaflPrayerTimes(
      duhaStart: duhaStart,
      duhaEnd: duhaEnd,
      zawalStart: zawalStart,
      awwabinStart: maghrib,
      awwabinEnd: isha,
      tahajjudStart: isha,
      tahajjudEnd: tomorrowFajr,
      lastThirdStart: _lastThirdStart(maghrib, tomorrowFajr),
      nextSuhurEnd: _nextOccurrence(now, fajr, tomorrowFajr),
      nextIftar: _nextOccurrence(now, maghrib, tomorrowMaghrib),
    );
  }

  Duration? iftarRemaining(DateTime now) {
    final target = nextIftar;
    if (target == null || !target.isAfter(now)) return null;
    return target.difference(now);
  }

  static DateTime? _lastThirdStart(DateTime? maghrib, DateTime? nextFajr) {
    if (maghrib == null || nextFajr == null || !nextFajr.isAfter(maghrib)) {
      return null;
    }
    final night = nextFajr.difference(maghrib);
    return nextFajr.subtract(Duration(seconds: night.inSeconds ~/ 3));
  }

  static DateTime? _nextOccurrence(
    DateTime now,
    DateTime? today,
    DateTime? tomorrow,
  ) {
    if (today != null && today.isAfter(now)) return today;
    if (tomorrow != null && tomorrow.isAfter(now)) return tomorrow;
    return null;
  }
}
