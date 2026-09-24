import 'dua.dart';

String normalizeDuaQuery(String input) {
  const banglaDigits = '০১২৩৪৫৬৭৮৯';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final character = String.fromCharCode(rune);
    final digitIndex = banglaDigits.indexOf(character);
    buffer.write(digitIndex >= 0 ? digitIndex.toString() : character);
  }

  return buffer
      .toString()
      .toLowerCase()
      .replaceAll(
        RegExp(r'''[\s\-_.,!?;:'"()[\]{}\/\\|+*=~`@#%^&<>،؛؟۔।]+'''),
        ' ',
      )
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

List<Dua> filterDuas({
  required List<Dua> duas,
  required List<DuaCategory> categories,
  required String query,
  String? categoryId,
  Set<String>? favoriteIds,
  bool favoritesOnly = false,
}) {
  final normalizedQuery = normalizeDuaQuery(query);
  final categoryById = {
    for (final category in categories) category.id: category,
  };
  final favorites = favoriteIds ?? const <String>{};
  final candidates = <_RankedDua>[];

  for (var index = 0; index < duas.length; index++) {
    final dua = duas[index];
    if (categoryId != null && !dua.categoryIds.contains(categoryId)) {
      continue;
    }
    if (favoritesOnly && !favorites.contains(dua.id)) {
      continue;
    }

    final rank = normalizedQuery.isEmpty
        ? 0
        : _matchRank(dua, normalizedQuery, categoryById);
    if (rank == null) continue;
    candidates.add(_RankedDua(dua: dua, rank: rank, index: index));
  }

  if (normalizedQuery.isNotEmpty) {
    candidates.sort((a, b) {
      final rankComparison = a.rank.compareTo(b.rank);
      return rankComparison != 0 ? rankComparison : a.index.compareTo(b.index);
    });
  }
  return List.unmodifiable(candidates.map((entry) => entry.dua));
}

List<Dua> dailyDuas(List<Dua> duas) {
  final result = duas.where((dua) => dua.dailyOrder != null).toList();
  result.sort((a, b) {
    final orderComparison = a.dailyOrder!.compareTo(b.dailyOrder!);
    return orderComparison != 0 ? orderComparison : a.id.compareTo(b.id);
  });
  return List.unmodifiable(result);
}

int? _matchRank(Dua dua, String query, Map<String, DuaCategory> categoryById) {
  final titles = [
    normalizeDuaQuery(dua.titleBangla),
    normalizeDuaQuery(dua.titleEnglish),
  ];
  if (titles.any((value) => value == query)) return 0;
  if (titles.any((value) => value.startsWith(query))) return 1;
  if (titles.any((value) => _hasTokenPrefix(value, query))) return 2;

  final pronunciationFields = [
    ...titles,
    normalizeDuaQuery(dua.banglaPronunciation),
    normalizeDuaQuery(dua.englishTransliteration),
  ];
  if (pronunciationFields.any((value) => value.contains(query))) return 3;

  final broadFields = <String>[
    normalizeDuaQuery(dua.banglaMeaning),
    normalizeDuaQuery(dua.englishMeaning),
    ...dua.tagsBangla.map(normalizeDuaQuery),
    ...dua.tagsEnglish.map(normalizeDuaQuery),
    for (final categoryId in dua.categoryIds)
      if (categoryById[categoryId] case final category?) ...[
        normalizeDuaQuery(category.banglaLabel),
        normalizeDuaQuery(category.englishLabel),
      ],
    for (final source in dua.sources) _sourceText(source),
  ];
  if (broadFields.any((value) => value.contains(query))) return 4;
  return null;
}

bool _hasTokenPrefix(String value, String query) {
  if (value.isEmpty || query.isEmpty) return false;
  return value.split(' ').any((token) => token.startsWith(query));
}

String _sourceText(DuaSource source) {
  return normalizeDuaQuery(switch (source.type) {
    DuaSourceType.quran =>
      'quran ${source.surahNumber ?? ''} ${source.ayahStart ?? ''} ${source.ayahEnd ?? ''}',
    DuaSourceType.hadith =>
      '${source.collection ?? ''} ${source.reference ?? ''} ${source.grade?.name ?? ''} ${source.gradingAuthority ?? ''}',
  });
}

class _RankedDua {
  const _RankedDua({
    required this.dua,
    required this.rank,
    required this.index,
  });

  final Dua dua;
  final int rank;
  final int index;
}
