import '../../../core/database/user_database.dart';
import '../application/reader_controller.dart';

class UserDatabaseReadingLocationStore
    implements ReadingLocationStore, SurahReadingLocationStore {
  UserDatabaseReadingLocationStore(this._database);

  static const String defaultProfile = 'default';

  final UserDatabase _database;

  @override
  Future<ReadingLocation?> load() async {
    final row = await _database.getReadingProgress(defaultProfile);
    if (row == null) return null;
    return ReadingLocation(
      page: row.lastPage,
      surahNumber: row.lastSurah,
      ayahNumber: row.lastAyah,
    );
  }

  @override
  Future<void> save(ReadingLocation location) {
    return _database.saveReadingProgress(
      profileKey: defaultProfile,
      lastSurah: location.surahNumber,
      lastAyah: location.ayahNumber,
      lastPage: location.page,
    );
  }

  @override
  Future<ReadingLocation?> loadForSurah(int surahNumber) async {
    final value = await _database.getSetting('reader.surah.$surahNumber');
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final page = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    if (page == null || ayah == null || page < 1 || ayah < 1) return null;
    return ReadingLocation(
      page: page,
      surahNumber: surahNumber,
      ayahNumber: ayah,
    );
  }

  @override
  Future<void> saveForSurah(ReadingLocation location) => _database.saveSetting(
    'reader.surah.${location.surahNumber}',
    '${location.page}:${location.ayahNumber}',
  );
}
