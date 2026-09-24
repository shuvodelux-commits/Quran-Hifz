import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/dua/data/drift_custom_dua_repository.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua.dart';

void main() {
  test('custom dua CRUD persists across database reopen', () async {
    final temp = await Directory.systemTemp.createTemp('custom_dua_repo_');
    final file = File('${temp.path}/user.sqlite');
    addTearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    final created = DateTime.utc(2026, 9, 24, 10);
    final firstDb = UserDatabase.forTesting(NativeDatabase(file));
    final first = DriftCustomDuaRepository(firstDb);
    final original = CustomDua(
      id: 'custom:one',
      title: 'My dua',
      arabic: 'اللهم اغفر لي',
      transliteration: 'Allahummaghfir li',
      meaning: 'O Allah, forgive me',
      reference: 'Personal note',
      createdAt: created,
      updatedAt: created,
    );

    await first.insert(original);
    await firstDb.close();

    final reopenedDb = UserDatabase.forTesting(NativeDatabase(file));
    addTearDown(reopenedDb.close);
    final reopened = DriftCustomDuaRepository(reopenedDb);

    expect(await reopened.getById('custom:one'), original);

    final edited = original.copyWith(
      title: 'Edited dua',
      updatedAt: created.add(const Duration(minutes: 5)),
    );
    await reopened.update(edited);
    final loaded = await reopened.getById('custom:one');
    expect(loaded?.title, 'Edited dua');
    expect(loaded?.createdAt, created);

    await reopened.delete('custom:one');
    expect(await reopened.getById('custom:one'), isNull);
  });

  test('list orders most recently updated first then stable id', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftCustomDuaRepository(db);
    final base = DateTime.utc(2026, 9, 24, 10);

    await repository.insert(_custom('custom:older', base));
    await repository.insert(_custom('custom:z', base.add(const Duration(minutes: 1))));
    await repository.insert(_custom('custom:a', base.add(const Duration(minutes: 1))));

    expect(
      (await repository.listAll()).map((dua) => dua.id),
      ['custom:a', 'custom:z', 'custom:older'],
    );
  });

  test('insert rejects ids outside the custom namespace', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftCustomDuaRepository(db);

    expect(
      () => repository.insert(_custom('verified-id', DateTime.utc(2026, 9, 24))),
      throwsA(isA<ArgumentError>()),
    );
  });
}

CustomDua _custom(String id, DateTime updatedAt) => CustomDua(
  id: id,
  title: id,
  arabic: 'دعاء',
  transliteration: 'Dua',
  meaning: 'Meaning',
  reference: 'Reference',
  createdAt: DateTime.utc(2026, 9, 24),
  updatedAt: updatedAt,
);
