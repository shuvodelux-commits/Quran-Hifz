import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/dua/application/custom_dua_actions.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua_repository.dart';
import 'package:quran_hifz/features/dua/domain/dua_favorites_repository.dart';

void main() {
  final now = DateTime.utc(2026, 9, 24, 18);

  test('create trims fields uses namespaced id and does not auto favorite', () async {
    final customRepo = _MemoryCustomRepository();
    final favorites = _MemoryFavoritesRepository();
    final actions = CustomDuaActions(
      repository: customRepo,
      favorites: favorites,
      idGenerator: () => 'custom:generated',
      now: () => now,
    );

    final created = await actions.create(
      title: '  My dua  ',
      arabic: '  اللهم اغفر لي  ',
      transliteration: '  Allahummaghfir li  ',
      meaning: '  Forgive me  ',
      reference: '  Personal note  ',
    );

    expect(created.id, 'custom:generated');
    expect(created.title, 'My dua');
    expect(created.arabic, 'اللهم اغفر لي');
    expect(created.transliteration, 'Allahummaghfir li');
    expect(created.meaning, 'Forgive me');
    expect(created.reference, 'Personal note');
    expect(created.createdAt, now);
    expect(created.updatedAt, now);
    expect(await customRepo.getById(created.id), created);
    expect(await favorites.load(), isEmpty);
  });

  test('create retries generated id collisions', () async {
    final customRepo = _MemoryCustomRepository();
    final favorites = _MemoryFavoritesRepository();
    await customRepo.insert(_custom(id: 'custom:existing', now: now));
    final ids = ['custom:existing', 'custom:new'];
    final actions = CustomDuaActions(
      repository: customRepo,
      favorites: favorites,
      idGenerator: () => ids.removeAt(0),
      now: () => now,
    );

    final created = await actions.create(
      title: 'Title',
      arabic: 'دعاء',
      transliteration: 'Dua',
      meaning: 'Meaning',
      reference: 'Reference',
    );

    expect(created.id, 'custom:new');
  });

  test('create rejects whitespace-only values for every required field', () async {
    Future<void> expectFieldFailure({
      required String title,
      required String arabic,
      required String transliteration,
      required String meaning,
      required String reference,
    }) async {
      final actions = CustomDuaActions(
        repository: _MemoryCustomRepository(),
        favorites: _MemoryFavoritesRepository(),
        idGenerator: () => 'custom:generated',
        now: () => now,
      );

      await expectLater(
        actions.create(
          title: title,
          arabic: arabic,
          transliteration: transliteration,
          meaning: meaning,
          reference: reference,
        ),
        throwsA(isA<ArgumentError>()),
      );
    }

    await expectFieldFailure(
      title: '   ',
      arabic: 'دعاء',
      transliteration: 'Dua',
      meaning: 'Meaning',
      reference: 'Reference',
    );
    await expectFieldFailure(
      title: 'Title',
      arabic: '   ',
      transliteration: 'Dua',
      meaning: 'Meaning',
      reference: 'Reference',
    );
    await expectFieldFailure(
      title: 'Title',
      arabic: 'دعاء',
      transliteration: '   ',
      meaning: 'Meaning',
      reference: 'Reference',
    );
    await expectFieldFailure(
      title: 'Title',
      arabic: 'دعاء',
      transliteration: 'Dua',
      meaning: '   ',
      reference: 'Reference',
    );
    await expectFieldFailure(
      title: 'Title',
      arabic: 'دعاء',
      transliteration: 'Dua',
      meaning: 'Meaning',
      reference: '   ',
    );
  });

  test('update preserves id created time and favorite membership', () async {
    final customRepo = _MemoryCustomRepository();
    final favorites = _MemoryFavoritesRepository({'custom:one'});
    final original = _custom(id: 'custom:one', now: now);
    await customRepo.insert(original);
    final later = now.add(const Duration(hours: 1));
    final actions = CustomDuaActions(
      repository: customRepo,
      favorites: favorites,
      idGenerator: () => 'custom:unused',
      now: () => later,
    );

    final edited = await actions.update(
      id: original.id,
      title: '  Edited  ',
      arabic: '  دعاء جديد  ',
      transliteration: '  New dua  ',
      meaning: '  New meaning  ',
      reference: '  New reference  ',
    );

    expect(edited.id, original.id);
    expect(edited.createdAt, original.createdAt);
    expect(edited.updatedAt, later);
    expect(edited.title, 'Edited');
    expect(await favorites.load(), {'custom:one'});
  });

  test('delete removes favorite before deleting custom row', () async {
    final customRepo = _MemoryCustomRepository();
    final favorites = _MemoryFavoritesRepository({
      'verified-one',
      'custom:one',
    });
    await customRepo.insert(_custom(id: 'custom:one', now: now));
    final actions = CustomDuaActions(
      repository: customRepo,
      favorites: favorites,
      idGenerator: () => 'custom:unused',
      now: () => now,
    );

    await actions.delete('custom:one');

    expect(await customRepo.getById('custom:one'), isNull);
    expect(await favorites.load(), {'verified-one'});
  });

  test('delete failure restores previous favorite membership', () async {
    final customRepo = _MemoryCustomRepository()
      ..deleteError = StateError('write failed');
    final favorites = _MemoryFavoritesRepository({'custom:one'});
    await customRepo.insert(_custom(id: 'custom:one', now: now));
    final actions = CustomDuaActions(
      repository: customRepo,
      favorites: favorites,
      idGenerator: () => 'custom:unused',
      now: () => now,
    );

    await expectLater(actions.delete('custom:one'), throwsStateError);

    expect(await favorites.load(), {'custom:one'});
    expect(await customRepo.getById('custom:one'), isNotNull);
  });
}

CustomDua _custom({required String id, required DateTime now}) => CustomDua(
  id: id,
  title: 'Title',
  arabic: 'دعاء',
  transliteration: 'Dua',
  meaning: 'Meaning',
  reference: 'Reference',
  createdAt: now,
  updatedAt: now,
);

class _MemoryCustomRepository implements CustomDuaRepository {
  final Map<String, CustomDua> _items = {};
  Object? deleteError;

  @override
  Future<void> delete(String id) async {
    if (deleteError case final error?) throw error;
    _items.remove(id);
  }

  @override
  Future<CustomDua?> getById(String id) async => _items[id];

  @override
  Future<void> insert(CustomDua dua) async {
    if (_items.containsKey(dua.id)) throw StateError('duplicate');
    _items[dua.id] = dua;
  }

  @override
  Future<List<CustomDua>> listAll() async => _items.values.toList();

  @override
  Future<void> update(CustomDua dua) async {
    if (!_items.containsKey(dua.id)) throw StateError('missing');
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
