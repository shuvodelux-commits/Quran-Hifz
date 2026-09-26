import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/database/quran_content_database.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../data/drift_quran_repository.dart';
import '../data/drift_word_audio_catalog.dart';
import '../data/user_database_reading_location_store.dart';
import '../domain/quran_repository.dart';
import '../domain/quran_script.dart';
import '../domain/word_audio_source.dart';
import 'reader_controller.dart';

/// Internal resource id assigned by the canonical importer to the primary
/// Bangla translation shipped in V1.
final quranTranslationResourceIdProvider = Provider<int>((ref) => 1);

/// Release composition is intentionally Drift-only. Tests that need fixtures
/// can override this provider explicitly, but production never falls back to
/// DemoQuranRepository.
final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return DriftQuranRepository(ref.watch(quranContentDatabaseProvider));
});

final indoPakQuranTextAvailableProvider = FutureProvider<bool>((ref) async {
  final database = ref.watch(quranContentDatabaseProvider);
  final ayahColumns = await database
      .customSelect('PRAGMA table_info(ayahs)')
      .get();
  final wordColumns = await database
      .customSelect('PRAGMA table_info(quran_words)')
      .get();
  final ayahNames = ayahColumns.map((row) => row.read<String>('name')).toSet();
  final wordNames = wordColumns.map((row) => row.read<String>('name')).toSet();
  if (!ayahNames.contains('arabic_text_indopak') ||
      !wordNames.contains('arabic_indopak')) {
    return false;
  }

  final ayahCount = await database
      .customSelect(
        "SELECT COUNT(*) AS c FROM ayahs WHERE TRIM(COALESCE(arabic_text_indopak, '')) <> ''",
      )
      .getSingle();
  final wordCount = await database
      .customSelect(
        "SELECT COUNT(*) AS c FROM quran_words WHERE TRIM(COALESCE(arabic_indopak, '')) <> ''",
      )
      .getSingle();
  return ayahCount.read<int>('c') > 0 && wordCount.read<int>('c') > 0;
});

final tajweedQuranTextAvailableProvider = FutureProvider<bool>((ref) async {
  final database = ref.watch(quranContentDatabaseProvider);
  final ayahColumns = await database
      .customSelect('PRAGMA table_info(ayahs)')
      .get();
  final wordColumns = await database
      .customSelect('PRAGMA table_info(quran_words)')
      .get();
  final ayahNames = ayahColumns.map((row) => row.read<String>('name')).toSet();
  final wordNames = wordColumns.map((row) => row.read<String>('name')).toSet();
  if (!ayahNames.contains('arabic_text_tajweed') ||
      !wordNames.contains('arabic_tajweed')) {
    return false;
  }

  final ayahCount = await database
      .customSelect(
        "SELECT COUNT(*) AS c FROM ayahs WHERE TRIM(COALESCE(arabic_text_tajweed, '')) <> ''",
      )
      .getSingle();
  final wordCount = await database
      .customSelect(
        "SELECT COUNT(*) AS c FROM quran_words WHERE TRIM(COALESCE(arabic_tajweed, '')) <> ''",
      )
      .getSingle();
  return ayahCount.read<int>('c') > 0 && wordCount.read<int>('c') > 0;
});

final effectiveQuranTajweedColorsProvider = Provider<bool>((ref) {
  final available = ref.watch(tajweedQuranTextAvailableProvider).value ?? false;
  final font = ref.watch(quranFontProvider);
  return ref.watch(showTajweedColorsProvider) &&
      available &&
      font.script == QuranScriptPreference.uthmaniMadani;
});

final surahWordAudioCatalogProvider = Provider<SurahWordAudioCatalog>((ref) {
  return DriftSurahWordAudioCatalog(ref.watch(quranContentDatabaseProvider));
});

final quranSurahListProvider = FutureProvider((ref) {
  return ref.watch(quranRepositoryProvider).listSurahs();
});

final quranJuzListProvider = FutureProvider((ref) async {
  final items = await ref.watch(quranRepositoryProvider).listJuzs();
  if (items.length != 30) {
    throw StateError('Canonical Quran must contain exactly 30 Juz.');
  }
  return items;
});

final driftQuranRepositoryProvider =
    Provider.family<QuranRepository, QuranContentDatabase>((ref, database) {
      return DriftQuranRepository(database);
    });

final readingLocationStoreProvider = Provider<ReadingLocationStore>((ref) {
  return UserDatabaseReadingLocationStore(ref.watch(userDatabaseProvider));
});
