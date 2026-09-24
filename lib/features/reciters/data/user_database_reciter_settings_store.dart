import '../../../core/database/user_database.dart';
import '../domain/reciter_settings_store.dart';

class UserDatabaseReciterSettingsStore implements ReciterSettingsStore {
  UserDatabaseReciterSettingsStore(this._database);

  final UserDatabase _database;

  @override
  Future<String?> get(String key) => _database.getSetting(key);

  @override
  Future<void> set(String key, String value) =>
      _database.saveSetting(key, value);
}
