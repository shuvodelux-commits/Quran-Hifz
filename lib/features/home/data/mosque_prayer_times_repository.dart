import 'dart:convert';

import '../../../core/database/user_database.dart';

class MosquePrayerTime {
  const MosquePrayerTime({this.azanMinutes, this.jamaatMinutes});

  final int? azanMinutes;
  final int? jamaatMinutes;

  @override
  bool operator ==(Object other) =>
      other is MosquePrayerTime &&
      other.azanMinutes == azanMinutes &&
      other.jamaatMinutes == jamaatMinutes;

  @override
  int get hashCode => Object.hash(azanMinutes, jamaatMinutes);
}

class MosquePrayerTimesRepository {
  const MosquePrayerTimesRepository(this._database);

  static const _settingKey = 'mosque_prayer_times_v1';
  final UserDatabase _database;

  Future<Map<String, MosquePrayerTime>> load() async {
    final raw = await _database.getSetting(_settingKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      final times = <String, MosquePrayerTime>{};
      for (final entry in decoded.entries) {
        final fields = entry.value;
        if (fields is! Map<String, dynamic>) continue;
        times[entry.key] = MosquePrayerTime(
          azanMinutes: _validMinutes(fields['azan']),
          jamaatMinutes: _validMinutes(fields['jamaat']),
        );
      }
      return times;
    } on FormatException {
      return {};
    }
  }

  Future<void> saveAzan(String prayer, int minutes) =>
      _saveField(prayer, minutes, isAzan: true);

  Future<void> saveJamaat(String prayer, int minutes) =>
      _saveField(prayer, minutes, isAzan: false);

  Future<void> _saveField(
    String prayer,
    int minutes, {
    required bool isAzan,
  }) async {
    if (minutes < 0 || minutes >= 24 * 60) {
      throw ArgumentError.value(minutes, 'minutes');
    }
    await _database.transaction(() async {
      final times = await load();
      final current = times[prayer] ?? const MosquePrayerTime();
      times[prayer] = MosquePrayerTime(
        azanMinutes: isAzan ? minutes : current.azanMinutes,
        jamaatMinutes: isAzan ? current.jamaatMinutes : minutes,
      );
      await _database.saveSetting(
        _settingKey,
        jsonEncode({
          for (final entry in times.entries)
            entry.key: {
              'azan': entry.value.azanMinutes,
              'jamaat': entry.value.jamaatMinutes,
            },
        }),
      );
    });
  }
}

int? _validMinutes(Object? value) =>
    value is int && value >= 0 && value < 24 * 60 ? value : null;
