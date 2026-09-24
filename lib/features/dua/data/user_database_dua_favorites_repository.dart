import 'dart:convert';

import '../../../core/database/user_database.dart';
import '../domain/dua_favorites_repository.dart';

class UserDatabaseDuaFavoritesRepository implements DuaFavoritesRepository {
  UserDatabaseDuaFavoritesRepository(this._database);

  static const settingKey = 'dua_favorites_v1';

  final UserDatabase _database;

  @override
  Future<Set<String>> load() async {
    final raw = await _database.getSetting(settingKey);
    if (raw == null || raw.trim().isEmpty) return <String>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <String>{};
      return Set.unmodifiable(
        decoded
            .whereType<String>()
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty),
      );
    } on FormatException {
      return <String>{};
    }
  }

  @override
  Future<void> save(Set<String> ids) async {
    final sorted =
        ids.map((id) => id.trim()).where((id) => id.isNotEmpty).toSet().toList()
          ..sort();
    await _database.saveSetting(settingKey, jsonEncode(sorted));
  }
}
