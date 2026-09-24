import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/study/application/study_controller.dart';
import 'package:quran_hifz/features/study/domain/bookmark.dart';
import 'package:quran_hifz/features/study/domain/note.dart';
import 'package:quran_hifz/features/study/domain/study_repository.dart';
import 'package:quran_hifz/features/study/presentation/word_details_sheet.dart';

void main() {
  testWidgets('shows available word metadata and omits absent fields', (
    tester,
  ) async {
    final controller = StudyController(_MemoryStudyRepository());
    const target = StudyTarget.word(
      surahNumber: 1,
      ayahNumber: 1,
      wordPosition: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WordDetailsSheet(
            target: target,
            word: const QuranWord(
              position: 1,
              arabic: 'ARABIC_WORD',
              transliteration: 'transliteration',
              banglaMeaning: 'বাংলা অর্থ',
              root: 'ROOT',
              grammar: 'GRAMMAR',
            ),
            controller: controller,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ARABIC_WORD'), findsOneWidget);
    expect(find.text('transliteration'), findsOneWidget);
    expect(find.text('বাংলা অর্থ'), findsOneWidget);
    expect(find.text('ROOT'), findsOneWidget);
    expect(find.text('GRAMMAR'), findsOneWidget);
    expect(find.text('English'), findsNothing);
    expect(find.text('Lemma'), findsNothing);
  });

  testWidgets('bookmark and note actions persist through controller', (
    tester,
  ) async {
    final repository = _MemoryStudyRepository();
    final controller = StudyController(repository);
    const target = StudyTarget.word(
      surahNumber: 1,
      ayahNumber: 1,
      wordPosition: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WordDetailsSheet(
            target: target,
            word: const QuranWord(position: 2, arabic: 'WORD'),
            controller: controller,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bookmark'));
    await tester.pumpAndSettle();
    expect(repository.bookmark?.target, target);

    await tester.enterText(find.byType(TextField), 'My note');
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();
    expect(repository.note?.text, 'My note');
  });
}

class _MemoryStudyRepository implements StudyRepository {
  @override
  Future<List<Bookmark>> listBookmarks({required String profileKey}) async =>
      const [];

  Bookmark? bookmark;
  Note? note;

  @override
  Future<Bookmark?> loadBookmark({
    required String profileKey,
    required StudyTarget target,
  }) async => bookmark?.target == target ? bookmark : null;

  @override
  Future<Note?> loadNote({
    required String profileKey,
    required StudyTarget target,
  }) async => note?.target == target ? note : null;

  @override
  Future<void> saveBookmark({
    required String profileKey,
    required StudyTarget target,
    required String category,
  }) async {
    bookmark = Bookmark(target: target, category: category);
  }

  @override
  Future<void> deleteBookmark({
    required String profileKey,
    required StudyTarget target,
  }) async {
    if (bookmark?.target == target) bookmark = null;
  }

  @override
  Future<void> saveNote({
    required String profileKey,
    required StudyTarget target,
    required String text,
  }) async {
    note = Note(target: target, text: text);
  }

  @override
  Future<void> deleteNote({
    required String profileKey,
    required StudyTarget target,
  }) async {
    if (note?.target == target) note = null;
  }
}
