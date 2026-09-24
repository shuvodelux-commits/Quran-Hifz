import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/ayah_card.dart';
import 'package:quran_hifz/features/study/application/study_providers.dart';
import 'package:quran_hifz/features/study/domain/bookmark.dart';
import 'package:quran_hifz/features/study/domain/note.dart';
import 'package:quran_hifz/features/study/domain/study_repository.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';

void main() {
  testWidgets(
    'ayah bookmark action persists without a build-time study query',
    (tester) async {
      final repository = _CountingStudyRepository();
      const ayah = QuranAyah(
        surahNumber: 67,
        ayahNumber: 1,
        pageNumber: 562,
        words: [QuranWord(position: 1, arabic: 'WORD')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepositoryProvider.overrideWithValue(repository),
            arabicFontSizeProvider.overrideWithValue(31),
            highlightActiveWordProvider.overrideWithValue(true),
            defaultRepeatCountProvider.overrideWithValue(5),
            defaultPlaybackSpeedProvider.overrideWithValue(1.0),
          ],
          child: const MaterialApp(
            home: Scaffold(body: AyahCard(ayah: ayah, showTranslation: false)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(repository.loadCount, 0);

      await tester.tap(find.byTooltip('Bookmark ayah'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('bookmark-name-field')),
        'Morning review',
      );
      await tester.tap(find.byKey(const ValueKey('save-bookmark')));
      await tester.pumpAndSettle();

      expect(
        repository.bookmark?.target,
        const StudyTarget.ayah(surahNumber: 67, ayahNumber: 1),
      );
      expect(repository.bookmark?.category, 'Morning review');
    },
  );
}

class _CountingStudyRepository implements StudyRepository {
  @override
  Future<List<Bookmark>> listBookmarks({required String profileKey}) async =>
      const [];

  Bookmark? bookmark;
  Note? note;
  int loadCount = 0;

  @override
  Future<Bookmark?> loadBookmark({
    required String profileKey,
    required StudyTarget target,
  }) async {
    loadCount++;
    return bookmark?.target == target ? bookmark : null;
  }

  @override
  Future<Note?> loadNote({
    required String profileKey,
    required StudyTarget target,
  }) async {
    loadCount++;
    return note?.target == target ? note : null;
  }

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
