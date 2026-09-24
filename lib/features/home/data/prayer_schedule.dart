import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../settings/domain/app_preferences.dart';
import 'offline_prayer_calculator.dart';

const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
const mosquePrayerNames = [...prayerNames, 'Juma'];

abstract class PrayerLocationStore {
  Future<PrayerLocation?> load();
  Future<void> save(PrayerLocation location);
}

class PrayerLocation {
  const PrayerLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.utcOffsetMinutes = 360,
  });
  final String name;
  final double latitude;
  final double longitude;
  final int utcOffsetMinutes;
}

class PrayerSchedule {
  const PrayerSchedule({
    required this.location,
    required this.latitude,
    required this.longitude,
    this.utcOffsetMinutes = 360,
    required this.hijriDate,
    this.tomorrowHijriDate,
    required this.sunrise,
    required this.sunset,
    required this.times,
    this.tomorrowFajr,
  });

  final String location;
  final double latitude;
  final double longitude;
  final int utcOffsetMinutes;
  final String hijriDate;
  final String? tomorrowHijriDate;
  final DateTime sunrise;
  final DateTime sunset;
  final Map<String, DateTime> times;
  final DateTime? tomorrowFajr;

  String hijriDateAt(DateTime now) =>
      !now.isBefore(sunset) ? (tomorrowHijriDate ?? hijriDate) : hijriDate;

  ({String name, DateTime time})? nextPrayer(DateTime now) {
    for (final name in prayerNames) {
      final time = times[name];
      if (time != null && time.isAfter(now)) return (name: name, time: time);
    }
    final next = tomorrowFajr;
    return next == null ? null : (name: 'Fajr', time: next);
  }
}

class PrayerScheduleRepository {
  const PrayerScheduleRepository({
    http.Client? client,
    PrayerLocationStore? locationStore,
    OfflinePrayerCalculator calculator = const OfflinePrayerCalculator(),
  }) : _client = client,
       _locationStore = locationStore,
       _calculator = calculator;

  final http.Client? _client;
  final PrayerLocationStore? _locationStore;
  final OfflinePrayerCalculator _calculator;

  String _school(AsrSchool school) => school == AsrSchool.hanafi ? '1' : '0';

  Future<http.Response> _get(Uri uri) =>
      _client == null ? http.get(uri) : _client.get(uri);

  Future<List<PrayerSchedule>> loadMonth({
    required int year,
    required int month,
    required String location,
    required double latitude,
    required double longitude,
    int utcOffsetMinutes = 360,
    AsrSchool school = AsrSchool.hanafi,
  }) async {
    if (_client == null) {
      final selected = PrayerLocation(
        name: location,
        latitude: latitude,
        longitude: longitude,
        utcOffsetMinutes: utcOffsetMinutes,
      );
      final count = DateTime(year, month + 1, 0).day;
      return [
        for (var day = 1; day <= count; day++)
          _calculator.calculate(DateTime(year, month, day), selected, school),
      ];
    }
    final uri = Uri.https('api.aladhan.com', '/v1/calendar/$year/$month', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'method': '1',
      'school': _school(school),
    });
    final response = await _get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200)
      throw StateError('Calendar is unavailable.');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['code'] != 200) throw StateError('Calendar is unavailable.');
    final days = body['data'] as List<dynamic>;
    return [
      for (var i = 0; i < days.length; i++)
        _scheduleFromData(
          DateTime(year, month, i + 1),
          days[i] as Map<String, dynamic>,
          location: location,
          latitude: latitude,
          longitude: longitude,
        ),
    ];
  }

  Future<PrayerSchedule> load(
    DateTime now, {
    AsrSchool school = AsrSchool.hanafi,
    PrayerLocation? selectedLocation,
  }) async {
    if (_client == null) {
      final location = selectedLocation ?? await _locationStore?.load();
      if (location == null) {
        throw StateError(
          'Select a location once to prepare offline prayer times.',
        );
      }
      return _calculator.calculate(now, location, school);
    }
    if (selectedLocation == null &&
        !await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Turn on location services to see local prayer times.');
    }
    var location = selectedLocation;
    if (location == null) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Allow location access to see local prayer times.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      location = PrayerLocation(
        name: await _placeName(position.latitude, position.longitude),
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
    final today = await _fetch(
      now,
      location.latitude,
      location.longitude,
      school,
    );
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    DateTime? tomorrowFajr;
    String? tomorrowHijriDate;
    try {
      final next = await _fetch(
        tomorrow,
        location.latitude,
        location.longitude,
        school,
      );
      tomorrowFajr = _time(
        tomorrow,
        next['timings'] as Map<String, dynamic>,
        'Fajr',
      );
      tomorrowHijriDate = _hijriText(next);
    } catch (_) {
      // Today's five times remain useful while a second request fails.
    }
    return _scheduleFromData(
      now,
      today,
      location: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
      tomorrowFajr: tomorrowFajr,
      tomorrowHijriDate: tomorrowHijriDate,
    );
  }

  /// Downloads the location's method-1 configuration once, then persists its
  /// coordinates. Daily and monthly reads never call this method.
  Future<PrayerLocation> configureLocation(
    PrayerLocation? selectedLocation, {
    AsrSchool school = AsrSchool.hanafi,
  }) async {
    var location = selectedLocation;
    if (location == null) {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Turn on location services to select your location.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Allow location access to select your location.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      location = PrayerLocation(
        name: await _placeName(position.latitude, position.longitude),
        latitude: position.latitude,
        longitude: position.longitude,
        utcOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );
    }
    await _fetch(DateTime.now(), location.latitude, location.longitude, school);
    await _locationStore?.save(location);
    return location;
  }

  PrayerSchedule _scheduleFromData(
    DateTime day,
    Map<String, dynamic> data, {
    required String location,
    required double latitude,
    required double longitude,
    DateTime? tomorrowFajr,
    String? tomorrowHijriDate,
  }) {
    final timings = data['timings'] as Map<String, dynamic>;
    return PrayerSchedule(
      location: location,
      latitude: latitude,
      longitude: longitude,
      hijriDate: _hijriText(data),
      tomorrowHijriDate: tomorrowHijriDate,
      sunrise: _time(day, timings, 'Sunrise'),
      sunset: _time(day, timings, 'Sunset'),
      times: {for (final name in prayerNames) name: _time(day, timings, name)},
      tomorrowFajr: tomorrowFajr,
    );
  }

  String _hijriText(Map<String, dynamic> data) {
    final date = data['date'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;
    final month = hijri['month'] as Map<String, dynamic>;
    return '${hijri['day']} ${month['en']} ${hijri['year']} AH';
  }

  Future<Map<String, dynamic>> _fetch(
    DateTime date,
    double latitude,
    double longitude,
    AsrSchool school,
  ) async {
    final day =
        '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    final uri = Uri.https('api.aladhan.com', '/v1/timings/$day', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      // Karachi calculation with Hanafi Asr; local mosque timetables can differ.
      'method': '1',
      'school': _school(school),
    });
    final response = await _get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200)
      throw StateError('Prayer times are unavailable.');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['code'] != 200) throw StateError('Prayer times are unavailable.');
    return body['data'] as Map<String, dynamic>;
  }

  Future<String> _placeName(double latitude, double longitude) async {
    try {
      final places = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (places.isNotEmpty) {
        final place = places.first;
        final city = place.locality?.trim();
        final country = place.country?.trim();
        if (city != null && city.isNotEmpty) {
          return country == null || country.isEmpty ? city : '$city, $country';
        }
      }
    } catch (_) {}
    return '${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°';
  }

  DateTime _time(DateTime day, Map<String, dynamic> timings, String name) {
    final parts = (timings[name] as String).split(' ').first.split(':');
    return DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
