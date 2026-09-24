import 'package:drift/drift.dart';

import '../../../core/database/user_database.dart';
import '../domain/custom_dua.dart';
import '../domain/custom_dua_repository.dart';

class DriftCustomDuaRepository implements CustomDuaRepository {
  DriftCustomDuaRepository(this._database);

  final UserDatabase _database;

  @override
  Future<List<CustomDua>> listAll() async {
    final rows =
        await (_database.select(_database.customDuas)
              ..orderBy([
                (row) => OrderingTerm.desc(row.updatedAt),
                (row) => OrderingTerm.asc(row.id),
              ]))
            .get();
    return List.unmodifiable(rows.map(_fromRow));
  }

  @override
  Future<CustomDua?> getById(String id) async {
    final row =
        await (_database.select(
              _database.customDuas,
            )..where((row) => row.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> insert(CustomDua dua) async {
    _validateId(dua.id);
    await _database.into(_database.customDuas).insert(_toCompanion(dua));
  }

  @override
  Future<void> update(CustomDua dua) async {
    _validateId(dua.id);
    final changed =
        await (_database.update(
              _database.customDuas,
            )..where((row) => row.id.equals(dua.id)))
            .write(_toCompanion(dua));
    if (changed != 1) {
      throw StateError('Custom Dua not found: ${dua.id}');
    }
  }

  @override
  Future<void> delete(String id) async {
    _validateId(id);
    await (_database.delete(
      _database.customDuas,
    )..where((row) => row.id.equals(id))).go();
  }

  CustomDuasCompanion _toCompanion(CustomDua dua) =>
      CustomDuasCompanion.insert(
        id: dua.id,
        title: dua.title,
        arabic: dua.arabic,
        transliteration: dua.transliteration,
        meaning: dua.meaning,
        reference: dua.reference,
        createdAt: dua.createdAt,
        updatedAt: dua.updatedAt,
      );

  CustomDua _fromRow(CustomDuaRow row) => CustomDua(
    id: row.id,
    title: row.title,
    arabic: row.arabic,
    transliteration: row.transliteration,
    meaning: row.meaning,
    reference: row.reference,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
  );

  void _validateId(String id) {
    if (!isCustomDuaId(id)) {
      throw ArgumentError.value(id, 'id', 'Custom Dua ID must use custom:');
    }
  }
}
