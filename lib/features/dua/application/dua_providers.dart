import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/bundled_dua_repository.dart';
import '../data/user_database_dua_favorites_repository.dart';
import '../domain/dua.dart';
import '../domain/dua_favorites_repository.dart';
import '../domain/dua_repository.dart';
import '../domain/dua_search.dart';

final duaRepositoryProvider = Provider<DuaRepository>((ref) {
  return BundledDuaRepository(bundle: rootBundle);
});

final duaCatalogProvider = FutureProvider<List<Dua>>((ref) {
  return ref.watch(duaRepositoryProvider).loadAll();
});

final duaCategoriesProvider = FutureProvider<List<DuaCategory>>((ref) {
  return ref.watch(duaRepositoryProvider).loadCategories();
});

final duaFavoritesRepositoryProvider = Provider<DuaFavoritesRepository>((ref) {
  return UserDatabaseDuaFavoritesRepository(ref.watch(userDatabaseProvider));
});

final duaFavoriteIdsProvider =
    AsyncNotifierProvider<DuaFavoriteIdsController, Set<String>>(
      DuaFavoriteIdsController.new,
    );

class DuaFavoriteIdsController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() {
    return ref.watch(duaFavoritesRepositoryProvider).load();
  }

  Future<void> toggle(String duaId) async {
    final id = duaId.trim();
    if (id.isEmpty) throw ArgumentError.value(duaId, 'duaId');

    final current =
        state.value ?? await ref.read(duaFavoritesRepositoryProvider).load();
    final next = {...current};
    if (!next.add(id)) {
      next.remove(id);
    }

    await ref.read(duaFavoritesRepositoryProvider).save(next);
    state = AsyncData(Set.unmodifiable(next));
  }
}

final duaQueryProvider = NotifierProvider<DuaQueryController, String>(
  DuaQueryController.new,
);

class DuaQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }
}

final duaCategoryProvider = NotifierProvider<DuaCategoryController, String?>(
  DuaCategoryController.new,
);

class DuaCategoryController extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) {
    state = categoryId;
  }
}

final duaFavoritesOnlyProvider =
    NotifierProvider<DuaFavoritesOnlyController, bool>(
      DuaFavoritesOnlyController.new,
    );

class DuaFavoritesOnlyController extends Notifier<bool> {
  @override
  bool build() => false;

  void setEnabled(bool value) {
    state = value;
  }

  void toggle() {
    state = !state;
  }
}

final filteredDuasProvider = FutureProvider<List<Dua>>((ref) async {
  final query = ref.watch(duaQueryProvider);
  final categoryId = ref.watch(duaCategoryProvider);
  final favoritesOnly = ref.watch(duaFavoritesOnlyProvider);
  final duas = await ref.watch(duaCatalogProvider.future);
  final categories = await ref.watch(duaCategoriesProvider.future);
  final favorites = await ref.watch(duaFavoriteIdsProvider.future);

  return filterDuas(
    duas: duas,
    categories: categories,
    query: query,
    categoryId: categoryId,
    favoriteIds: favorites,
    favoritesOnly: favoritesOnly,
  );
});

final dailyDuasProvider = FutureProvider<List<Dua>>((ref) async {
  return dailyDuas(await ref.watch(duaCatalogProvider.future));
});
