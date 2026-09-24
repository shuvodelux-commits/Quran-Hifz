import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/dua/application/dua_providers.dart';
import 'package:quran_hifz/features/dua/domain/dua.dart';
import 'package:quran_hifz/features/dua/domain/dua_favorites_repository.dart';
import 'package:quran_hifz/features/dua/domain/dua_repository.dart';

void main() {
  final repository = _FakeDuaRepository(
    categories: const [
      DuaCategory(id: 'daily', banglaLabel: 'দৈনন্দিন', englishLabel: 'Daily'),
      DuaCategory(id: 'sleep', banglaLabel: 'ঘুম', englishLabel: 'Sleep'),
    ],
    duas: [
      _dua(
        id: 'morning',
        title: 'Morning remembrance',
        categories: const ['daily'],
        tags: const ['morning'],
        order: 10,
      ),
      _dua(
        id: 'night',
        title: 'Before sleep',
        categories: const ['sleep'],
        tags: const ['night'],
        order: 90,
      ),
      _dua(
        id: 'travel',
        title: 'Travel',
        categories: const ['daily'],
        tags: const ['journey'],
      ),
    ],
  );

  test('catalog provider can be overridden with a fake repository', () async {
    final favorites = _MemoryFavoritesRepository();
    final container = ProviderContainer(
      overrides: [
        duaRepositoryProvider.overrideWithValue(repository),
        duaFavoritesRepositoryProvider.overrideWithValue(favorites),
      ],
    );
    addTearDown(container.dispose);

    final catalog = await container.read(duaCatalogProvider.future);
    final categories = await container.read(duaCategoriesProvider.future);

    expect(catalog.map((dua) => dua.id), ['morning', 'night', 'travel']);
    expect(categories.map((category) => category.id), ['daily', 'sleep']);
  });

  test('favorite toggle persists and refreshes provider state', () async {
    final favorites = _MemoryFavoritesRepository();
    final container = ProviderContainer(
      overrides: [
        duaRepositoryProvider.overrideWithValue(repository),
        duaFavoritesRepositoryProvider.overrideWithValue(favorites),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(duaFavoriteIdsProvider.future), isEmpty);

    await container.read(duaFavoriteIdsProvider.notifier).toggle('morning');

    expect(container.read(duaFavoriteIdsProvider).value, {'morning'});
    expect(await favorites.load(), {'morning'});

    await container.read(duaFavoriteIdsProvider.notifier).toggle('morning');

    expect(container.read(duaFavoriteIdsProvider).value, isEmpty);
    expect(await favorites.load(), isEmpty);
  });

  test('query category and favorites-only filters compose', () async {
    final favorites = _MemoryFavoritesRepository({'morning', 'missing-id'});
    final container = ProviderContainer(
      overrides: [
        duaRepositoryProvider.overrideWithValue(repository),
        duaFavoritesRepositoryProvider.overrideWithValue(favorites),
      ],
    );
    addTearDown(container.dispose);
    await container.read(duaFavoriteIdsProvider.future);

    container.read(duaQueryProvider.notifier).setQuery('morning');
    container.read(duaCategoryProvider.notifier).select('daily');
    container.read(duaFavoritesOnlyProvider.notifier).setEnabled(true);

    final filtered = await container.read(filteredDuasProvider.future);

    expect(filtered.map((dua) => dua.id), ['morning']);
  });

  test('orphan favorite ids never become fake catalog rows', () async {
    final favorites = _MemoryFavoritesRepository({'missing-id'});
    final container = ProviderContainer(
      overrides: [
        duaRepositoryProvider.overrideWithValue(repository),
        duaFavoritesRepositoryProvider.overrideWithValue(favorites),
      ],
    );
    addTearDown(container.dispose);
    await container.read(duaFavoriteIdsProvider.future);

    container.read(duaFavoritesOnlyProvider.notifier).setEnabled(true);

    expect(await container.read(filteredDuasProvider.future), isEmpty);
  });

  test('daily provider follows explicit daily order', () async {
    final container = ProviderContainer(
      overrides: [
        duaRepositoryProvider.overrideWithValue(repository),
        duaFavoritesRepositoryProvider.overrideWithValue(
          _MemoryFavoritesRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final daily = await container.read(dailyDuasProvider.future);

    expect(daily.map((dua) => dua.id), ['morning', 'night']);
  });
}

Dua _dua({
  required String id,
  required String title,
  required List<String> categories,
  required List<String> tags,
  int? order,
}) {
  return Dua(
    id: id,
    titleBangla: title,
    titleEnglish: title,
    arabic: 'رَبَّنَا',
    banglaPronunciation: 'রব্বানা',
    banglaMeaning: title,
    englishTransliteration: 'Rabbana',
    englishMeaning: title,
    categoryIds: categories,
    tagsBangla: tags,
    tagsEnglish: tags,
    sources: const [
      DuaSource(
        type: DuaSourceType.hadith,
        collection: 'Sahih al-Bukhari',
        reference: '1',
        grade: HadithGrade.sahih,
      ),
    ],
    dailyOrder: order,
  );
}

class _FakeDuaRepository implements DuaRepository {
  const _FakeDuaRepository({required this.categories, required this.duas});

  final List<DuaCategory> categories;
  final List<Dua> duas;

  @override
  Future<List<Dua>> loadAll() async => duas;

  @override
  Future<List<DuaCategory>> loadCategories() async => categories;
}

class _MemoryFavoritesRepository implements DuaFavoritesRepository {
  _MemoryFavoritesRepository([Set<String>? initial]) : value = {...?initial};

  Set<String> value;

  @override
  Future<Set<String>> load() async => Set.unmodifiable(value);

  @override
  Future<void> save(Set<String> ids) async {
    value = {...ids};
  }
}
