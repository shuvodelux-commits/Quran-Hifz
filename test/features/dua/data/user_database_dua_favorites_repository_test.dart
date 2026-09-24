import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/dua/data/user_database_dua_favorites_repository.dart';

void main() {
  test('missing favorites setting loads an empty set', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserDatabaseDuaFavoritesRepository(database);

    expect(await repository.load(), isEmpty);
  });

  test('save persists across repository recreation', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await UserDatabaseDuaFavoritesRepository(database).save({'sleep', 'wake'});

    final recreated = UserDatabaseDuaFavoritesRepository(database);
    expect(await recreated.load(), {'sleep', 'wake'});
  });

  test(
    'save collapses duplicates and stores deterministic sorted JSON',
    () async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = UserDatabaseDuaFavoritesRepository(database);

      await repository.save({'z-last', 'a-first', 'z-last'});

      final raw = await database.getSetting(
        UserDatabaseDuaFavoritesRepository.settingKey,
      );
      expect(jsonDecode(raw!), ['a-first', 'z-last']);
    },
  );

  test('malformed persisted JSON safely loads an empty set', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.saveSetting(
      UserDatabaseDuaFavoritesRepository.settingKey,
      '{not-json',
    );

    final repository = UserDatabaseDuaFavoritesRepository(database);

    expect(await repository.load(), isEmpty);
  });

  test('invalid persisted list values are ignored', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.saveSetting(
      UserDatabaseDuaFavoritesRepository.settingKey,
      jsonEncode(['wake', 42, '', '  ', 'sleep']),
    );

    final repository = UserDatabaseDuaFavoritesRepository(database);

    expect(await repository.load(), {'wake', 'sleep'});
  });
}
