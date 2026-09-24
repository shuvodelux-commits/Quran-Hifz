import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quran_ayah.dart';
import '../domain/quran_repository.dart';
import 'quran_providers.dart';

/// Chooses a locally stored ayah for the calendar day. The date seed keeps
/// the selection stable across rebuilds while changing it on the next day.
Future<QuranAyah?> selectTodaysAyah({
  required QuranRepository repository,
  required DateTime date,
  required int translationResourceId,
}) async {
  final surahs = await repository.listSurahs();
  final ayahTotal = surahs.fold<int>(
    0,
    (total, surah) => total + surah.ayahCount,
  );
  if (ayahTotal == 0) return null;

  final day = DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(2024, 1, 1)).inDays;
  final selectedIndex = ((day * 1103515245 + 12345) & 0x7fffffff) % ayahTotal;
  var remaining = selectedIndex;
  for (final surah in surahs) {
    if (remaining < surah.ayahCount) {
      return repository.loadAyah(
        surahNumber: surah.number,
        ayahNumber: remaining + 1,
        translationResourceId: translationResourceId,
      );
    }
    remaining -= surah.ayahCount;
  }
  return null;
}

final todaysAyahProvider = FutureProvider<QuranAyah?>((ref) {
  return selectTodaysAyah(
    repository: ref.watch(quranRepositoryProvider),
    date: DateTime.now(),
    translationResourceId: ref.watch(quranTranslationResourceIdProvider),
  );
});
