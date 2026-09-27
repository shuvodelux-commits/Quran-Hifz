import '../../hifz/domain/hifz_progress.dart';
import '../../hifz/domain/hifz_session.dart';
import 'revision_item.dart';

abstract interface class RevisionRepository {
  Future<HifzProgress?> loadProgress({
    required String profileKey,
    required AyahRef ayah,
  });

  Future<void> recordReview({
    required String profileKey,
    required HifzProgress updatedProgress,
    required RevisionHistoryEntry historyEntry,
  });

  Future<List<RevisionItem>> loadDue({
    required String profileKey,
    required DateTime onOrBefore,
  });
}
