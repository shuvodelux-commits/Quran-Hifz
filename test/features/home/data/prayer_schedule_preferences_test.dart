import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:drift/native.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/home/data/user_database_prayer_location_store.dart';

void main() {
  test(
    'one location setup supports offline day and month after restart',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final store = UserDatabasePrayerLocationStore(database);
      var requests = 0;
      final client = MockClient((request) async {
        requests++;
        return http.Response(
          jsonEncode({
            'code': 200,
            'data': {
              'timings': {},
              'date': {'hijri': {}},
            },
          }),
          200,
        );
      });
      await PrayerScheduleRepository(
        client: client,
        locationStore: store,
      ).configureLocation(
        const PrayerLocation(
          name: 'Dhaka',
          latitude: 23.7115,
          longitude: 90.4111,
        ),
      );
      final offline = PrayerScheduleRepository(locationStore: store);
      final day = await offline.load(DateTime(2026, 9, 14));
      final month = await offline.loadMonth(
        year: 2026,
        month: 9,
        location: day.location,
        latitude: day.latitude,
        longitude: day.longitude,
      );
      expect(day.times['Fajr'], isNotNull);
      expect(month, hasLength(30));
      expect(requests, 1);
    },
  );
  test(
    'calendar uses Karachi method and the selected Asr shadow factor',
    () async {
      final seen = <Uri>[];
      final client = MockClient((request) async {
        seen.add(request.url);
        return http.Response(
          jsonEncode({
            'code': 200,
            'data': [
              {
                'timings': {
                  'Fajr': '04:15 (+06)',
                  'Sunrise': '05:30 (+06)',
                  'Dhuhr': '12:00 (+06)',
                  'Asr': '16:00 (+06)',
                  'Maghrib': '18:00 (+06)',
                  'Sunset': '18:00 (+06)',
                  'Isha': '19:20 (+06)',
                },
                'date': {
                  'hijri': {
                    'day': '1',
                    'year': '1448',
                    'month': {'en': 'Ramadan'},
                  },
                },
              },
            ],
          }),
          200,
        );
      });
      final repository = PrayerScheduleRepository(client: client);
      await repository.loadMonth(
        year: 2026,
        month: 9,
        location: 'Natore',
        latitude: 24.42,
        longitude: 88.99,
        school: AsrSchool.standard,
      );
      await repository.loadMonth(
        year: 2026,
        month: 9,
        location: 'Natore',
        latitude: 24.42,
        longitude: 88.99,
        school: AsrSchool.hanafi,
      );
      expect(seen.map((uri) => uri.queryParameters['method']), ['1', '1']);
      expect(seen.map((uri) => uri.queryParameters['school']), ['0', '1']);
    },
  );

  test('a selected Bangladesh city supplies coordinates without GPS', () async {
    final seen = <Uri>[];
    final client = MockClient((request) async {
      seen.add(request.url);
      return http.Response(
        jsonEncode({
          'code': 200,
          'data': {
            'timings': {
              'Fajr': '04:15 (+06)',
              'Sunrise': '05:30 (+06)',
              'Dhuhr': '12:00 (+06)',
              'Asr': '16:00 (+06)',
              'Maghrib': '18:00 (+06)',
              'Sunset': '18:00 (+06)',
              'Isha': '19:20 (+06)',
            },
            'date': {
              'hijri': {
                'day': '1',
                'year': '1448',
                'month': {'en': 'Ramadan'},
              },
            },
          },
        }),
        200,
      );
    });
    final schedule = await PrayerScheduleRepository(client: client).load(
      DateTime(2026, 9, 14),
      school: AsrSchool.standard,
      selectedLocation: const PrayerLocation(
        name: 'Natore',
        latitude: 24.42,
        longitude: 88.99,
      ),
    );
    expect(schedule.location, 'Natore');
    expect(seen, hasLength(2));
    expect(seen.first.queryParameters['latitude'], '24.42');
    expect(seen.first.queryParameters['school'], '0');
  });
}
