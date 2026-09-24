import 'app_preferences.dart';

abstract class AppPreferencesRepository {
  Future<AppPreferences> load();
  Future<void> save(AppPreferences preferences);
}
