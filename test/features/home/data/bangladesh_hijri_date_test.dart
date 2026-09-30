import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_hifz/features/home/data/bangladesh_hijri_date.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  group('BangladeshHijriDateResolver', () {
    final maghrib = DateTime(2026, 9, 30, 18);

    test('uses HJCoSA minus one civil day before Maghrib', () {
      final source = BangladeshHijriDateResolver.sourceDate(
        now: DateTime(2026, 9, 30, 17, 59),
        maghrib: maghrib,
        boundary: HijriDayBoundary.maghrib,
        correction: 0,
      );
      expect(source, DateTime(2026, 9, 29));
    });

    test('rolls at exact Maghrib in Maghrib mode', () {
      final source = BangladeshHijriDateResolver.sourceDate(
        now: maghrib,
        maghrib: maghrib,
        boundary: HijriDayBoundary.maghrib,
        correction: 0,
      );
      expect(source, DateTime(2026, 9, 30));
    });

    test('midnight mode does not roll at Maghrib', () {
      final source = BangladeshHijriDateResolver.sourceDate(
        now: DateTime(2026, 9, 30, 23, 59),
        maghrib: maghrib,
        boundary: HijriDayBoundary.midnight,
        correction: 0,
      );
      expect(source, DateTime(2026, 9, 29));
    });

    test('civil-day shifting crosses Gregorian year boundaries safely', () {
      final source = BangladeshHijriDateResolver.sourceDate(
        now: DateTime(2026, 1, 1, 12),
        maghrib: DateTime(2026, 1, 1, 18),
        boundary: HijriDayBoundary.midnight,
        correction: -1,
      );
      expect(source, DateTime(2025, 12, 30));
    });

    test('month-scoped correction expires when baseline month changes', () {
      const baseline = ResolvedHijriDate(
        day: 1,
        month: 5,
        year: 1448,
        monthName: 'Jumada al-Awwal',
        source: HijriDateSource.hjcosa,
      );
      expect(
        BangladeshHijriDateResolver.activeCorrection(
          correction: 1,
          correctionScope: '1448-05',
          baseline: baseline,
        ),
        1,
      );
      expect(
        BangladeshHijriDateResolver.activeCorrection(
          correction: 1,
          correctionScope: '1448-04',
          baseline: baseline,
        ),
        0,
      );
    });

    test('relative correction shifts around the Bangladesh default', () {
      final earlier = BangladeshHijriDateResolver.sourceDate(
        now: DateTime(2026, 9, 30, 12),
        maghrib: maghrib,
        boundary: HijriDayBoundary.midnight,
        correction: -1,
      );
      final later = BangladeshHijriDateResolver.sourceDate(
        now: DateTime(2026, 9, 30, 12),
        maghrib: maghrib,
        boundary: HijriDayBoundary.midnight,
        correction: 1,
      );
      expect(earlier, DateTime(2026, 9, 28));
      expect(later, DateTime(2026, 9, 30));
    });
  });

  test('HJCoSA repository requests the explicit AlAdhan calendar method', () async {
    late Uri requested;
    final client = MockClient((request) async {
      requested = request.url;
      return http.Response(
        jsonEncode({
          'code': 200,
          'data': {
            'hijri': {
              'day': '18',
              'month': {'number': 4, 'en': 'Rabi al-Thani'},
              'year': '1448',
              'method': 'HJCoSA',
            },
          },
        }),
        200,
      );
    });
    final repository = BangladeshHijriDateRepository(client: client);

    final result = await repository.convert(DateTime(2026, 9, 30));

    expect(requested.path, '/v1/gToH/30-09-2026');
    expect(requested.queryParameters['calendarMethod'], 'HJCoSA');
    expect(result.text, '18 Rabi al-Thani 1448 AH');
    expect(result.scopeKey, '1448-04');
    expect(result.source, HijriDateSource.hjcosa);
  });

  test('HJCoSA repository falls back to local Hijri conversion', () async {
    final repository = BangladeshHijriDateRepository(
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );

    final result = await repository.convert(DateTime(2026, 9, 30));

    expect(result.text, isNotEmpty);
    expect(result.source, HijriDateSource.localFallback);
  });
}
