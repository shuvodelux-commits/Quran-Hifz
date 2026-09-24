import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/drift_bookmark_display_repository.dart';
import '../data/drift_study_repository.dart';
import '../domain/bookmark.dart';
import '../domain/bookmark_display_repository.dart';
import '../domain/study_repository.dart';
import 'study_controller.dart';

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  return DriftStudyRepository(ref.watch(userDatabaseProvider));
});

final studyControllerProvider = Provider<StudyController>((ref) {
  return StudyController(ref.watch(studyRepositoryProvider));
});

final bookmarksProvider = FutureProvider.autoDispose<List<Bookmark>>((ref) {
  return ref
      .watch(studyRepositoryProvider)
      .listBookmarks(profileKey: 'default');
});

final bookmarkDisplayRepositoryProvider = Provider<BookmarkDisplayRepository>((
  ref,
) {
  return DriftBookmarkDisplayRepository(
    ref.watch(quranContentDatabaseProvider),
  );
});
