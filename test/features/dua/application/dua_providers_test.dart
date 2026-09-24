import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/dua/application/dua_providers.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua_repository.dart';
import 'package:quran_hifz/features/dua/domain/dua.dart';
import 'package:quran_hifz/features/dua/domain/dua_entry.dart';
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
    final container = _container(
      repository: repository,
      favorites: _MemoryFavoritesRepository(),
    );
    addTearDown(container.dispose);

    final catalog = await container.read(duaCatalogProvider.future);
    final categories = await container.read(duaCategoriesProvider.future);

    expect(catalog.map((dua) => dua.id), ['morning', 'night', 'travel']);
    expect(categories.map((category) => category.id), ['daily', 'sleep']);
  });

  test('favorite toggle persists and refreshes provider state', () async {
    final favorites = _MemoryFavoritesRepository();
    final container = _container(repository: repository, favorites: favorites);
    addTearDown(container.dispose);

    expect(await container.read(duaFavoriteIdsProvider.future), isEmpty);

    await container.read(duaFavoriteIdsProvider.notifier).toggle('morning');

    expect(container.read(duaFavoriteIdsProvider).value, {'morning'});
    expect(await favorites.load(), {'morning'});

    await container.read(duaFavoriteIdsProvider.notifier).toggle('morning');

    expect(container.read(duaFavoriteIdsProvider).value, isEmpty);
    expect(await favorites.load(), isEmpty);
  });

  test('default favorite entries resolve verified and custom ids', () async {
    final customRepo = _MemoryCustomRepository([
      _custom(id: 'custom:one', title: 'Personal'),
    ]);
    final container = _container(
      repository: repository,
      favorites: _MemoryFavoritesRepository({
        'morning',
        'custom:one',
        'missing-id',
      }),
      customRepo: customRepo,
    );
    addTearDown(container.dispose);

    final entries = await container.read(favoriteDuaEntriesProvider.future);

    expect(entries.map((entry) => entry.id), ['morning', 'custom:one']);
    expect(entries.first, isA<VerifiedDuaEntry>());
    expect(entries.last, isA<CustomDuaEntry>());
  });

  test('global search includes verified and custom entries', () async {
    final container = _container(
      repository: repository,
      favorites: _MemoryFavoritesRepository(),
      customRepo: _MemoryCustomRepository([
        _custom(id: 'custom:one', meaning: 'Travel protection'),
      ]),
    );
    addTearDown(container.dispose);

    container.read(duaQueryProvider.notifier).setQuery('travel');
    final entries = await container.read(visibleDuaEntriesProvider.future);

    expect(entries.map((entry) => entry.id), ['travel', 'custom:one']);
  });

  test('verified category search excludes custom entries', () async {
    final container = _container(
      repository: repository,
      favorites: _MemoryFavoritesRepository(),
      customRepo: _MemoryCustomRepository([
        _custom(id: 'custom:one', meaning: 'Morning protection'),
      ]),
    );
    addTearDown(container.dispose);

    container.read(duaCategoryProvider.notifier).select('daily');
    container.read(duaQueryProvider.notifier).setQuery('morning');

    final entries = await container.read(visibleDuaEntriesProvider.future);

    expect(entries, isNotEmpty);
    expect(entries.every((entry) => entry is VerifiedDuaEntry), isTrue);
    expect(entries.map((entry) => entry.id), ['morning']);
  });

  test('custom mode search excludes verified entries', () async {
    final container = _container(
      repository: repository,
      favorites: _MemoryFavoritesRepository(),
      customRepo: _MemoryCustomRepository([
        _custom(id: 'custom:one', meaning: 'Morning protection'),
      ]),
    );
    addTearDown(container.dispose);

    container.read(duaCustomOnlyProvider.notifier).setEnabled(true);
    container.read(duaQueryProvider.notifier).setQuery('morning');

    final entries = await container.read(visibleDuaEntriesProvider.future);

    expect(entries.map((entry) => entry.id), ['custom:one']);
    expect(entries.single, isA<CustomDuaEntry>());
  });

  test('custom controller create reloads state without auto favoriting', () async {
    final favorites = _MemoryFavoritesRepository();
    final customRepo = _MemoryCustomRepository();
    final container = _container(
      repository: repository,
      favorites: favorites,
      customRepo: customRepo,
      idGenerator: () => 'custom:created',
    );
    addTearDown(container.dispose);

    expect(await container.read(customDuasProvider.future), isEmpty);

    final created = await container.read(customDuasProvider.notifier).create(
      title: 'Mine',
      arabic: 'دعاء',
      transliteration: 'Dua',
      meaning: 'Meaning',
      reference: 'Reference',
    );

    expect(created.id, 'custom:created');
    expect(container.read(customDuasProvider).value?.map((dua) => dua.id), [
      'custom:created',
    ]);
    expect(await favorites.load(), isEmpty);
  });
}

ProviderContainer _container({
  required DuaRepository repository,
  required _MemoryFavoritesRepository favorites,
  _MemoryCustomRepository? customRepo,
  String Function()? idGenerator,
}) {
  final custom = customRepo ?? _MemoryCustomRepository();
  return ProviderContainer(
    overrides: [
      duaRepositoryProvider.overrideWithValue(repository),
      duaFavoritesRepositoryProvider.overrideWithValue(favorites),
      customDuaRepositoryProvider.overrideWithValue(custom),
      customDuaIdGeneratorProvider.overrideWithValue(
        idGenerator ?? () => 'custom:generated',
      ),
    ],
  );
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

CustomDua _custom({
  required String id,
  String title = 'Custom',
  String meaning = 'Meaning',
}) => CustomDua(
  id: id,
  title: title,
  arabic: 'دعاء',
  transliteration: 'Dua',
  meaning: meaning,
  reference: 'Reference',
  createdAt: DateTime.utc(2026, 9, 24),
  updatedAt: DateTime.utc(2026, 9, 24),
);

class _FakeDuaRepository implements DuaRepository {
  const _FakeDuaRepository({required this.categories, required this.duas});

  final List<DuaCategory> categories;
  final List<Dua> duas;

  @override
  Future<List<Dua>> loadAll() async => duas;

  @override
  Future<List<DuaCategory>> loadCategories() async => categories;
}

class _MemoryCustomRepository implements CustomDuaRepository {
  _MemoryCustomRepository([List<CustomDua>? initial])
    : _items = {for (final dua in initial ?? const <CustomDua>[]) dua.id: dua};

  final Map<String, CustomDua> _items;

  @override
  Future<void> delete(String id) async {
    _items.remove(id);
  }

  @override
  Future<CustomDua?> getById(String id) async => _items[id];

  @override
  Future<void> insert(CustomDua dua) async {
    _items[dua.id] = dua;
  }

  @override
  Future<List<CustomDua>> listAll() async => _items.values.toList();

  @override
  Future<void> update(CustomDua dua) async {
    _items[dua.id] = dua;
  }
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
