import '../domain/bookmark.dart';
import '../domain/note.dart';
import '../domain/study_repository.dart';

class StudyState {
  const StudyState({this.bookmark, this.note});

  final Bookmark? bookmark;
  final Note? note;

  bool get isBookmarked => bookmark != null;
}

class StudyController {
  StudyController(this._repository, {this.profileKey = 'default'});

  final StudyRepository _repository;
  final String profileKey;

  Future<StudyState> load(StudyTarget target) async {
    final values = await Future.wait<Object?>([
      _repository.loadBookmark(profileKey: profileKey, target: target),
      _repository.loadNote(profileKey: profileKey, target: target),
    ]);
    return StudyState(
      bookmark: values[0] as Bookmark?,
      note: values[1] as Note?,
    );
  }

  Future<StudyState> toggleBookmark(
    StudyTarget target, {
    String category = 'General',
  }) async {
    final existing = await _repository.loadBookmark(
      profileKey: profileKey,
      target: target,
    );
    if (existing == null) {
      await _repository.saveBookmark(
        profileKey: profileKey,
        target: target,
        category: category,
      );
    } else {
      await _repository.deleteBookmark(profileKey: profileKey, target: target);
    }
    return load(target);
  }

  Future<StudyState> saveBookmarkName(
    StudyTarget target,
    String name, {
    DateTime? now,
  }) async {
    final normalized = name.trim();
    await _repository.saveBookmark(
      profileKey: profileKey,
      target: target,
      category: normalized.isEmpty
          ? _defaultBookmarkName(now ?? DateTime.now())
          : normalized,
    );
    return load(target);
  }

  Future<StudyState> saveNote(StudyTarget target, String text) async {
    await _repository.saveNote(
      profileKey: profileKey,
      target: target,
      text: text,
    );
    return load(target);
  }

  Future<StudyState> deleteNote(StudyTarget target) async {
    await _repository.deleteNote(profileKey: profileKey, target: target);
    return load(target);
  }
}

String _defaultBookmarkName(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)} '
      '${two(value.hour)}:${two(value.minute)}';
}
