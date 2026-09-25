import '../../../core/database/user_database.dart';

const selectedTafsirSourceSettingKey = 'selected_tafsir_source_v1';

abstract class TafsirSourceSelectionStore {
  Future<String?> read();
  Future<void> write(String sourceId);
}

class UserDatabaseTafsirSourceSelectionStore
    implements TafsirSourceSelectionStore {
  UserDatabaseTafsirSourceSelectionStore(this._database);

  final UserDatabase _database;

  @override
  Future<String?> read() =>
      _database.getSetting(selectedTafsirSourceSettingKey);

  @override
  Future<void> write(String sourceId) {
    final normalized = sourceId.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(sourceId, 'sourceId', 'must not be empty');
    }
    return _database.saveSetting(selectedTafsirSourceSettingKey, normalized);
  }
}
