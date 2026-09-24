import 'custom_dua.dart';
import 'dua_search.dart';

List<CustomDua> filterCustomDuas({
  required List<CustomDua> duas,
  required String query,
}) {
  final normalized = normalizeDuaQuery(query);
  if (normalized.isEmpty) return List.unmodifiable(duas);

  return List.unmodifiable(
    duas.where((dua) {
      final fields = [
        dua.title,
        dua.arabic,
        dua.transliteration,
        dua.meaning,
        dua.reference,
      ];
      return fields
          .map(normalizeDuaQuery)
          .any((field) => field.contains(normalized));
    }),
  );
}
