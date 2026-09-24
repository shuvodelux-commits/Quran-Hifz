import '../../../core/database/user_database.dart';

class PrayerTrackerRepository {
  const PrayerTrackerRepository(this._database);

  final UserDatabase _database;

  Future<Set<String>> load(String dayKey) async {
    final raw = await _database.getSetting('salat_tracker_$dayKey');
    if (raw == null || raw.isEmpty) return <String>{};
    return raw.split(',').toSet();
  }

  Future<Set<String>> toggle(String dayKey, String prayer) async {
    const valid = {'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'};
    if (!valid.contains(prayer)) throw ArgumentError.value(prayer, 'prayer');
    final selected = await load(dayKey);
    if (!selected.add(prayer)) selected.remove(prayer);
    await _database.saveSetting('salat_tracker_$dayKey', selected.join(','));
    return selected;
  }
}
