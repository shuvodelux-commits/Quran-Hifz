abstract interface class DuaFavoritesRepository {
  Future<Set<String>> load();

  Future<void> save(Set<String> ids);
}
