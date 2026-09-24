import 'dart:convert';

import '../../../core/database/user_database.dart';
import 'prayer_schedule.dart';

class UserDatabasePrayerLocationStore implements PrayerLocationStore {
  UserDatabasePrayerLocationStore(this._database);

  static const settingKey = 'offline_prayer_location_v1';
  final UserDatabase _database;

  @override
  Future<PrayerLocation?> load() async {
    final raw = await _database.getSetting(settingKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final value = jsonDecode(raw) as Map<String, dynamic>;
      final name = value['name'] as String;
      final latitude = (value['latitude'] as num).toDouble();
      final longitude = (value['longitude'] as num).toDouble();
      final offset = value['utcOffsetMinutes'] as int;
      if (name.isEmpty ||
          latitude.abs() > 90 ||
          longitude.abs() > 180 ||
          offset.abs() > 14 * 60)
        return null;
      return PrayerLocation(
        name: name,
        latitude: latitude,
        longitude: longitude,
        utcOffsetMinutes: offset,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(PrayerLocation location) => _database.saveSetting(
    settingKey,
    jsonEncode({
      'name': location.name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'utcOffsetMinutes': location.utcOffsetMinutes,
      'method': 1,
    }),
  );
}
