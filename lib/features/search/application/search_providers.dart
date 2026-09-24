import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../quran/application/quran_providers.dart';
import '../data/drift_quran_search_repository.dart';
import '../domain/quran_search_repository.dart';
import '../domain/quran_search_result.dart';

final quranSearchRepositoryProvider = Provider<QuranSearchRepository>((ref) {
  return DriftQuranSearchRepository(ref.watch(quranContentDatabaseProvider));
});

final quranSearchProvider = FutureProvider.autoDispose
    .family<List<QuranSearchResult>, String>((ref, query) {
      return ref
          .watch(quranSearchRepositoryProvider)
          .search(
            query,
            translationResourceId: ref.watch(
              quranTranslationResourceIdProvider,
            ),
          );
    });
