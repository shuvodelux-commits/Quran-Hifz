import 'package:drift/drift.dart';

import '../../../core/database/user_database.dart';
import '../domain/bookmark.dart';
import '../domain/note.dart';
import '../domain/study_repository.dart';

class DriftStudyRepository implements StudyRepository {
  DriftStudyRepository(this._database);

  final UserDatabase _database;

  @override
  Future<List<Bookmark>> listBookmarks({required String profileKey}) async {
    final rows =
        await (_database.select(_database.studyBookmarks)
              ..where((row) => row.profileKey.equals(profileKey))
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();

    return rows
        .map(
          (row) => Bookmark(
            target: _targetFromRow(
              type: row.targetType,
              surahNumber: row.surahNumber,
              ayahNumber: row.ayahNumber,
              wordPosition: row.wordPosition,
            ),
            category: row.category,
            createdAt: row.createdAt,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Bookmark?> loadBookmark({
    required String profileKey,
    required StudyTarget target,
  }) async {
    final row =
        await (_database.select(_database.studyBookmarks)..where(
              (row) =>
                  row.profileKey.equals(profileKey) &
                  row.targetKey.equals(target.key),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return Bookmark(
      target: _targetFromRow(
        type: row.targetType,
        surahNumber: row.surahNumber,
        ayahNumber: row.ayahNumber,
        wordPosition: row.wordPosition,
      ),
      category: row.category,
      createdAt: row.createdAt,
    );
  }

  @override
  Future<Note?> loadNote({
    required String profileKey,
    required StudyTarget target,
  }) async {
    final row =
        await (_database.select(_database.studyNotes)..where(
              (row) =>
                  row.profileKey.equals(profileKey) &
                  row.targetKey.equals(target.key),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return Note(
      target: _targetFromRow(
        type: row.targetType,
        surahNumber: row.surahNumber,
        ayahNumber: row.ayahNumber,
        wordPosition: row.wordPosition,
      ),
      text: row.noteText,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> saveBookmark({
    required String profileKey,
    required StudyTarget target,
    required String category,
  }) async {
    final normalizedCategory = category.trim();
    if (normalizedCategory.isEmpty) {
      throw ArgumentError.value(category, 'category', 'must not be blank');
    }
    await _database
        .into(_database.studyBookmarks)
        .insertOnConflictUpdate(
          StudyBookmarksCompanion.insert(
            profileKey: profileKey,
            targetKey: target.key,
            targetType: target.type.name,
            surahNumber: target.surahNumber,
            ayahNumber: target.ayahNumber,
            wordPosition: Value(target.wordPosition),
            category: normalizedCategory,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> deleteBookmark({
    required String profileKey,
    required StudyTarget target,
  }) async {
    await (_database.delete(_database.studyBookmarks)..where(
          (row) =>
              row.profileKey.equals(profileKey) &
              row.targetKey.equals(target.key),
        ))
        .go();
  }

  @override
  Future<void> saveNote({
    required String profileKey,
    required StudyTarget target,
    required String text,
  }) async {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(text, 'text', 'must not be blank');
    }
    await _database
        .into(_database.studyNotes)
        .insertOnConflictUpdate(
          StudyNotesCompanion.insert(
            profileKey: profileKey,
            targetKey: target.key,
            targetType: target.type.name,
            surahNumber: target.surahNumber,
            ayahNumber: target.ayahNumber,
            wordPosition: Value(target.wordPosition),
            noteText: normalized,
            updatedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> deleteNote({
    required String profileKey,
    required StudyTarget target,
  }) async {
    await (_database.delete(_database.studyNotes)..where(
          (row) =>
              row.profileKey.equals(profileKey) &
              row.targetKey.equals(target.key),
        ))
        .go();
  }

  StudyTarget _targetFromRow({
    required String type,
    required int surahNumber,
    required int ayahNumber,
    required int? wordPosition,
  }) {
    return switch (StudyTargetType.values.byName(type)) {
      StudyTargetType.ayah => StudyTarget.ayah(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      ),
      StudyTargetType.word => StudyTarget.word(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        wordPosition:
            wordPosition ??
            (throw StateError('Stored word study target has no position.')),
      ),
    };
  }
}
