import 'dart:convert';

import 'package:hijri_core/hijri_core.dart' as hijri_core;
import 'package:http/http.dart' as http;

import '../../settings/domain/app_preferences.dart';

enum HijriDateSource { hjcosa, localFallback }

class ResolvedHijriDate {
  const ResolvedHijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthName,
    required this.source,
  });

  final int day;
  final int month;
  final int year;
  final String monthName;
  final HijriDateSource source;

  String get text => '$day $monthName $year AH';
  String get scopeKey => '$year-${month.toString().padLeft(2, '0')}';
}

class BangladeshHijriDateResolver {
  const BangladeshHijriDateResolver._();

  static int activeCorrection({
    required int correction,
    required String? correctionScope,
    required ResolvedHijriDate baseline,
  }) {
    if (correction < -1 || correction > 1) {
      throw ArgumentError.value(correction, 'correction');
    }
    return correction != 0 && correctionScope == baseline.scopeKey
        ? correction
        : 0;
  }

  static DateTime sourceDate({
    required DateTime now,
    required DateTime? maghrib,
    required HijriDayBoundary boundary,
    required int correction,
  }) {
    if (correction < -1 || correction > 1) {
      throw ArgumentError.value(correction, 'correction');
    }
    var civilDay = DateTime(now.year, now.month, now.day);
    if (boundary == HijriDayBoundary.maghrib &&
        maghrib != null &&
        !now.isBefore(maghrib)) {
      civilDay = civilDay.add(const Duration(days: 1));
    }
    return civilDay.add(Duration(days: -1 + correction));
  }
}

class BangladeshHijriDateRepository {
  BangladeshHijriDateRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<ResolvedHijriDate> convert(DateTime sourceDate) async {
    try {
      final day =
          '${sourceDate.day.toString().padLeft(2, '0')}-'
          '${sourceDate.month.toString().padLeft(2, '0')}-'
          '${sourceDate.year}';
      final uri = Uri.https('api.aladhan.com', '/v1/gToH/$day', {
        'calendarMethod': 'HJCoSA',
      });
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return _localFallback(sourceDate);
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic> || body['code'] != 200) {
        return _localFallback(sourceDate);
      }
      final data = body['data'];
      if (data is! Map<String, dynamic>) return _localFallback(sourceDate);
      return _parseHijri(data['hijri']) ?? _localFallback(sourceDate);
    } catch (_) {
      return _localFallback(sourceDate);
    }
  }

  Future<Map<int, ResolvedHijriDate>> convertMonth(int year, int month) async {
    final count = DateTime(year, month + 1, 0).day;
    try {
      final uri = Uri.https(
        'api.aladhan.com',
        '/v1/gToHCalendar/$month/$year',
        {'calendarMethod': 'HJCoSA'},
      );
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return _localMonth(year, month, count);
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic> || body['code'] != 200) {
        return _localMonth(year, month, count);
      }
      final data = body['data'];
      if (data is! List || data.length < count) {
        return _localMonth(year, month, count);
      }
      final result = <int, ResolvedHijriDate>{};
      for (var index = 0; index < count; index++) {
        final item = data[index];
        if (item is! Map<String, dynamic>)
          return _localMonth(year, month, count);
        final parsed = _parseHijri(item['hijri']);
        if (parsed == null) return _localMonth(year, month, count);
        result[index + 1] = parsed;
      }
      return result;
    } catch (_) {
      return _localMonth(year, month, count);
    }
  }

  ResolvedHijriDate? _parseHijri(Object? raw) {
    if (raw is! Map<String, dynamic> || raw['method'] != 'HJCoSA') return null;
    final month = raw['month'];
    if (month is! Map<String, dynamic>) return null;
    final parsedDay = int.tryParse('${raw['day']}');
    final parsedMonth = month['number'] is int
        ? month['number'] as int
        : int.tryParse('${month['number']}');
    final parsedYear = int.tryParse('${raw['year']}');
    final monthName = month['en']?.toString().trim();
    if (parsedDay == null ||
        parsedMonth == null ||
        parsedYear == null ||
        monthName == null ||
        monthName.isEmpty) {
      return null;
    }
    return ResolvedHijriDate(
      day: parsedDay,
      month: parsedMonth,
      year: parsedYear,
      monthName: monthName,
      source: HijriDateSource.hjcosa,
    );
  }

  Map<int, ResolvedHijriDate> _localMonth(int year, int month, int count) => {
    for (var day = 1; day <= count; day++)
      day: _localFallback(DateTime(year, month, day)),
  };

  ResolvedHijriDate _localFallback(DateTime sourceDate) {
    final local = hijri_core.toHijri(
      DateTime.utc(sourceDate.year, sourceDate.month, sourceDate.day),
    );
    if (local == null) {
      throw StateError(
        'Hijri date is unavailable for ${sourceDate.toIso8601String()}.',
      );
    }
    return ResolvedHijriDate(
      day: local.hd,
      month: local.hm,
      year: local.hy,
      monthName: _monthNames[local.hm - 1],
      source: HijriDateSource.localFallback,
    );
  }
}

const _monthNames = <String>[
  'Muharram',
  'Safar',
  'Rabi al-Awwal',
  'Rabi al-Thani',
  'Jumada al-Awwal',
  'Jumada al-Thani',
  'Rajab',
  'Sha’ban',
  'Ramadan',
  'Shawwal',
  'Dhul Qa’dah',
  'Dhul Hijjah',
];
