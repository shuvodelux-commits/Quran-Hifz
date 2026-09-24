import 'bookmark.dart';
import 'note.dart';

abstract interface class StudyRepository {
  Future<List<Bookmark>> listBookmarks({required String profileKey});

  Future<Bookmark?> loadBookmark({
    required String profileKey,
    required StudyTarget target,
  });

  Future<Note?> loadNote({
    required String profileKey,
    required StudyTarget target,
  });

  Future<void> saveBookmark({
    required String profileKey,
    required StudyTarget target,
    required String category,
  });

  Future<void> deleteBookmark({
    required String profileKey,
    required StudyTarget target,
  });

  Future<void> saveNote({
    required String profileKey,
    required StudyTarget target,
    required String text,
  });

  Future<void> deleteNote({
    required String profileKey,
    required StudyTarget target,
  });
}
