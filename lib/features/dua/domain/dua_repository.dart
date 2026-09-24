import 'dua.dart';

abstract interface class DuaRepository {
  Future<List<Dua>> loadAll();

  Future<List<DuaCategory>> loadCategories();
}
