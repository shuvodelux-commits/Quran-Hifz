import 'custom_dua.dart';

abstract interface class CustomDuaRepository {
  Future<List<CustomDua>> listAll();
  Future<CustomDua?> getById(String id);
  Future<void> insert(CustomDua dua);
  Future<void> update(CustomDua dua);
  Future<void> delete(String id);
}
