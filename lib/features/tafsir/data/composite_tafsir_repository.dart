import '../domain/tafsir_catalog.dart';
import '../domain/tafsir_entry.dart';
import '../domain/tafsir_repository.dart';

class CompositeTafsirRepository
    implements TafsirRepository, TafsirAvailableSources {
  CompositeTafsirRepository({
    required TafsirRepository bundled,
    required TafsirRepository downloaded,
    TafsirRepository? remote,
  }) : _bundled = bundled,
       _downloaded = downloaded,
       _remote = remote;

  final TafsirRepository _bundled;
  final TafsirRepository _downloaded;
  final TafsirRepository? _remote;

  @override
  Future<List<TafsirSource>> listInstalledSources() =>
      _listSources(includeRemote: false);

  @override
  Future<List<TafsirSource>> listAvailableSources() =>
      _listSources(includeRemote: true);

  Future<List<TafsirSource>> listSources() => listAvailableSources();

  Future<List<TafsirSource>> _listSources({required bool includeRemote}) async {
    final bundled = await _safeSources(_bundled);
    final downloaded = await _safeSources(_downloaded);
    final remote = !includeRemote || _remote == null
        ? const <TafsirSource>[]
        : await _safeSources(_remote);

    final byId = <String, TafsirSource>{};

    for (final source in bundled) {
      byId[source.sourceId] = source;
    }

    for (final source in downloaded) {
      final existing = byId[source.sourceId];
      if (source.sourceId == primaryBanglaTafsirSourceId &&
          existing != null &&
          existing.kind == TafsirSourceKind.bundled) {
        final newer =
            _compareDottedVersions(source.version, existing.version) > 0;
        if (newer && await _isReadablePrimary(_downloaded)) {
          byId[source.sourceId] = source;
        }
        continue;
      }
      byId[source.sourceId] = source;
    }

    for (final source in remote) {
      byId.putIfAbsent(source.sourceId, () => source);
    }

    final values = byId.values.toList(growable: false);
    values.sort((a, b) {
      if (a.sourceId == primaryBanglaTafsirSourceId) return -1;
      if (b.sourceId == primaryBanglaTafsirSourceId) return 1;
      final language = a.language.compareTo(b.language);
      if (language != 0) return language;
      return a.name.compareTo(b.name);
    });
    return List.unmodifiable(values);
  }

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (sourceId == primaryBanglaTafsirSourceId) {
      final preferred = await _preferredPrimaryRepository();
      if (identical(preferred, _downloaded)) {
        try {
          final entry = await _downloaded.readAyah(
            sourceId: sourceId,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
          );
          if (entry != null) return entry;
        } catch (_) {
          // A bundled primary source is always the local fallback.
        }
      }
      return _bundled.readAyah(
        sourceId: sourceId,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      );
    }

    for (final repository in [
      _downloaded,
      if (_remote != null) _remote,
      _bundled,
    ]) {
      final sources = await _safeSources(repository);
      if (!sources.any((source) => source.sourceId == sourceId)) continue;
      return repository.readAyah(
        sourceId: sourceId,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      );
    }
    return null;
  }

  @override
  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async {
    if (sourceId == primaryBanglaTafsirSourceId) {
      final preferred = await _preferredPrimaryRepository();
      if (identical(preferred, _downloaded)) {
        try {
          final entries = await _downloaded.readSurah(
            sourceId: sourceId,
            surahNumber: surahNumber,
          );
          if (entries.isNotEmpty) return entries;
        } catch (_) {
          // A bundled primary source is always the local fallback.
        }
      }
      return _bundled.readSurah(sourceId: sourceId, surahNumber: surahNumber);
    }

    for (final repository in [
      _downloaded,
      if (_remote != null) _remote,
      _bundled,
    ]) {
      final sources = await _safeSources(repository);
      if (!sources.any((source) => source.sourceId == sourceId)) continue;
      return repository.readSurah(sourceId: sourceId, surahNumber: surahNumber);
    }
    return const [];
  }

  Future<TafsirRepository> _preferredPrimaryRepository() async {
    final bundledSources = await _safeSources(_bundled);
    final downloadedSources = await _safeSources(_downloaded);
    final bundled = _byId(bundledSources, primaryBanglaTafsirSourceId);
    final downloaded = _byId(downloadedSources, primaryBanglaTafsirSourceId);
    if (bundled == null || downloaded == null) return _bundled;
    if (_compareDottedVersions(downloaded.version, bundled.version) <= 0) {
      return _bundled;
    }
    return await _isReadablePrimary(_downloaded) ? _downloaded : _bundled;
  }

  Future<bool> _isReadablePrimary(TafsirRepository repository) async {
    try {
      return await repository.readAyah(
            sourceId: primaryBanglaTafsirSourceId,
            surahNumber: 1,
            ayahNumber: 1,
          ) !=
          null;
    } catch (_) {
      return false;
    }
  }
}

Future<List<TafsirSource>> _safeSources(TafsirRepository repository) async {
  try {
    return await repository.listInstalledSources();
  } catch (_) {
    return const [];
  }
}

TafsirSource? _byId(List<TafsirSource> sources, String sourceId) {
  for (final source in sources) {
    if (source.sourceId == sourceId) return source;
  }
  return null;
}

int _compareDottedVersions(String left, String right) {
  final leftParts = _parseDottedVersion(left);
  final rightParts = _parseDottedVersion(right);
  if (leftParts == null || rightParts == null) return 0;
  final length = leftParts.length > rightParts.length
      ? leftParts.length
      : rightParts.length;
  for (var index = 0; index < length; index++) {
    final l = index < leftParts.length ? leftParts[index] : 0;
    final r = index < rightParts.length ? rightParts[index] : 0;
    if (l != r) return l.compareTo(r);
  }
  return 0;
}

List<int>? _parseDottedVersion(String value) {
  final parts = value.split('.');
  if (parts.isEmpty) return null;
  final parsed = <int>[];
  for (final part in parts) {
    final number = int.tryParse(part);
    if (number == null || number < 0) return null;
    parsed.add(number);
  }
  return parsed;
}
