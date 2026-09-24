import '../domain/custom_dua.dart';
import '../domain/custom_dua_repository.dart';
import '../domain/dua_favorites_repository.dart';

typedef CustomDuaIdGenerator = String Function();

class CustomDuaActions {
  CustomDuaActions({
    required CustomDuaRepository repository,
    required DuaFavoritesRepository favorites,
    required CustomDuaIdGenerator idGenerator,
    required DateTime Function() now,
  }) : _repository = repository,
       _favorites = favorites,
       _idGenerator = idGenerator,
       _now = now;

  final CustomDuaRepository _repository;
  final DuaFavoritesRepository _favorites;
  final CustomDuaIdGenerator _idGenerator;
  final DateTime Function() _now;

  String _requiredTrimmed(String value, String field) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(value, field, '$field is required');
    }
    return trimmed;
  }

  Future<String> _nextUniqueId() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final id = _idGenerator();
      if (!isCustomDuaId(id)) {
        throw StateError('Custom Dua ID generator returned an invalid ID.');
      }
      if (await _repository.getById(id) == null) return id;
    }
    throw StateError('Could not generate a unique custom Dua ID.');
  }

  Future<CustomDua> create({
    required String title,
    required String arabic,
    required String transliteration,
    required String meaning,
    required String reference,
  }) async {
    final now = _now();
    final dua = CustomDua(
      id: await _nextUniqueId(),
      title: _requiredTrimmed(title, 'title'),
      arabic: _requiredTrimmed(arabic, 'arabic'),
      transliteration: _requiredTrimmed(transliteration, 'transliteration'),
      meaning: _requiredTrimmed(meaning, 'meaning'),
      reference: _requiredTrimmed(reference, 'reference'),
      createdAt: now,
      updatedAt: now,
    );
    await _repository.insert(dua);
    return dua;
  }

  Future<CustomDua> update({
    required String id,
    required String title,
    required String arabic,
    required String transliteration,
    required String meaning,
    required String reference,
  }) async {
    final current = await _repository.getById(id);
    if (current == null) throw StateError('Custom Dua not found: $id');

    final edited = CustomDua(
      id: current.id,
      title: _requiredTrimmed(title, 'title'),
      arabic: _requiredTrimmed(arabic, 'arabic'),
      transliteration: _requiredTrimmed(transliteration, 'transliteration'),
      meaning: _requiredTrimmed(meaning, 'meaning'),
      reference: _requiredTrimmed(reference, 'reference'),
      createdAt: current.createdAt,
      updatedAt: _now(),
    );
    await _repository.update(edited);
    return edited;
  }

  Future<void> delete(String id) async {
    final before = await _favorites.load();
    final wasFavorite = before.contains(id);

    if (wasFavorite) {
      await _favorites.save({...before}..remove(id));
    }

    try {
      await _repository.delete(id);
    } catch (_) {
      if (wasFavorite) await _favorites.save(before);
      rethrow;
    }
  }
}
