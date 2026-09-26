import 'dart:convert';

import '../../../core/database/user_database.dart';
import '../domain/quran_translation_source.dart';

abstract interface class QuranTranslationSelectionStore {
  Future<List<String>> read();
  Future<void> write(List<String> sourceIds);
}

class UserDatabaseQuranTranslationSelectionStore
    implements QuranTranslationSelectionStore {
  UserDatabaseQuranTranslationSelectionStore(this._database);

  static const settingKey = 'quran_translation_sources_v1';

  final UserDatabase _database;

  @override
  Future<List<String>> read() async {
    final raw = await _database.getSetting(settingKey);
    if (raw == null || raw.trim().isEmpty) {
      return const [bundledPrimaryTranslationSourceId];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [bundledPrimaryTranslationSourceId];
      }
      final values = <String>[];
      for (final item in decoded) {
        if (item is! String || item.trim().isEmpty || values.contains(item)) {
          continue;
        }
        values.add(item);
      }
      return values.isEmpty
          ? const [bundledPrimaryTranslationSourceId]
          : List.unmodifiable(values);
    } on FormatException {
      return const [bundledPrimaryTranslationSourceId];
    }
  }

  @override
  Future<void> write(List<String> sourceIds) async {
    final normalized = <String>[];
    for (final sourceId in sourceIds) {
      final value = sourceId.trim();
      if (value.isNotEmpty && !normalized.contains(value)) {
        normalized.add(value);
      }
    }
    if (normalized.isEmpty) {
      throw ArgumentError.value(sourceIds, 'sourceIds', 'must not be empty');
    }
    await _database.saveSetting(settingKey, jsonEncode(normalized));
  }
}
