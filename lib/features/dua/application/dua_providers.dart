import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/bundled_dua_repository.dart';
import '../data/drift_custom_dua_repository.dart';
import '../data/user_database_dua_favorites_repository.dart';
import '../domain/custom_dua.dart';
import '../domain/custom_dua_repository.dart';
import '../domain/custom_dua_search.dart';
import '../domain/dua.dart';
import '../domain/dua_entry.dart';
import '../domain/dua_favorites_repository.dart';
import '../domain/dua_repository.dart';
import '../domain/dua_search.dart';
import 'custom_dua_actions.dart';

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

final customDuaRepositoryProvider = Provider<CustomDuaRepository>((ref) {
  return DriftCustomDuaRepository(ref.watch(userDatabaseProvider));
});

final customDuaIdGeneratorProvider = Provider<CustomDuaIdGenerator>((ref) {
  final random = Random.secure();
  return () {
    final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final entropy = random.nextInt(0x7fffffff).toRadixString(36);
    return '$customDuaIdPrefix$micros:$entropy';
  };
});

final customDuaActionsProvider = Provider<CustomDuaActions>((ref) {
  return CustomDuaActions(
    repository: ref.watch(customDuaRepositoryProvider),
    favorites: ref.watch(duaFavoritesRepositoryProvider),
    idGenerator: ref.watch(customDuaIdGeneratorProvider),
    now: DateTime.now,
  );
});

final customDuasProvider =
    AsyncNotifierProvider<CustomDuasController, List<CustomDua>>(
      CustomDuasController.new,
    );

class CustomDuasController extends AsyncNotifier<List<CustomDua>> {
  @override
  Future<List<CustomDua>> build() {
    return ref.watch(customDuaRepositoryProvider).listAll();
  }

  Future<List<CustomDua>> _reload() {
    return ref.read(customDuaRepositoryProvider).listAll();
  }

  Future<CustomDua> create({
    required String title,
    required String arabic,
    required String transliteration,
    required String meaning,
    required String reference,
  }) async {
    final saved = await ref
        .read(customDuaActionsProvider)
        .create(
          title: title,
          arabic: arabic,
          transliteration: transliteration,
          meaning: meaning,
          reference: reference,
        );
    state = AsyncData(await _reload());
    return saved;
  }

  Future<CustomDua> edit({
    required String id,
    required String title,
    required String arabic,
    required String transliteration,
    required String meaning,
    required String reference,
  }) async {
    final saved = await ref
        .read(customDuaActionsProvider)
        .update(
          id: id,
          title: title,
          arabic: arabic,
          transliteration: transliteration,
          meaning: meaning,
          reference: reference,
        );
    state = AsyncData(await _reload());
    return saved;
  }

  Future<void> delete(String id) async {
    await ref.read(customDuaActionsProvider).delete(id);
    state = AsyncData(await _reload());
    ref.invalidate(duaFavoriteIdsProvider);
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

final duaCustomOnlyProvider =
    NotifierProvider<DuaCustomOnlyController, bool>(
      DuaCustomOnlyController.new,
    );

class DuaCustomOnlyController extends Notifier<bool> {
  @override
  bool build() => false;

  void setEnabled(bool value) {
    state = value;
  }
}

final allDuaEntriesProvider = FutureProvider<List<DuaEntry>>((ref) async {
  final verified = await ref.watch(duaCatalogProvider.future);
  List<CustomDua> custom;
  try {
    custom = await ref.watch(customDuasProvider.future);
  } catch (_) {
    custom = const <CustomDua>[];
  }
  return List.unmodifiable([
    ...verified.map(VerifiedDuaEntry.new),
    ...custom.map(CustomDuaEntry.new),
  ]);
});

final favoriteDuaEntriesProvider = FutureProvider<List<DuaEntry>>((ref) async {
  final entries = await ref.watch(allDuaEntriesProvider.future);
  final favorites = await ref.watch(duaFavoriteIdsProvider.future);
  return List.unmodifiable(
    entries.where((entry) => favorites.contains(entry.id)),
  );
});

final visibleDuaEntriesProvider = FutureProvider<List<DuaEntry>>((ref) async {
  final query = ref.watch(duaQueryProvider);
  final categoryId = ref.watch(duaCategoryProvider);
  final customOnly = ref.watch(duaCustomOnlyProvider);

  if (customOnly) {
    final custom = await ref.watch(customDuasProvider.future);
    return filterCustomDuas(duas: custom, query: query)
        .map(CustomDuaEntry.new)
        .toList(growable: false);
  }

  final verified = await ref.watch(duaCatalogProvider.future);

  if (categoryId != null) {
    final categories = await ref.watch(duaCategoriesProvider.future);
    return filterDuas(
      duas: verified,
      categories: categories,
      query: query,
      categoryId: categoryId,
    ).map(VerifiedDuaEntry.new).toList(growable: false);
  }

  if (query.trim().isNotEmpty) {
    final categories = await ref.watch(duaCategoriesProvider.future);
    final verifiedMatches = filterDuas(
      duas: verified,
      categories: categories,
      query: query,
    ).map(VerifiedDuaEntry.new);
    List<CustomDuaEntry> customMatches;
    try {
      final custom = await ref.watch(customDuasProvider.future);
      customMatches = filterCustomDuas(
        duas: custom,
        query: query,
      ).map(CustomDuaEntry.new).toList(growable: false);
    } catch (_) {
      customMatches = const <CustomDuaEntry>[];
    }
    return List.unmodifiable([...verifiedMatches, ...customMatches]);
  }

  return ref.watch(favoriteDuaEntriesProvider.future);
});

// Compatibility providers retained until DuaPage migrates to the combined
// verified/custom entry model.
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
