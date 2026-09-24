import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/study/application/study_providers.dart';
import 'package:quran_hifz/features/study/domain/bookmark.dart';
import 'package:quran_hifz/features/study/domain/bookmark_display_item.dart';
import 'package:quran_hifz/features/study/domain/bookmark_display_repository.dart';
import 'package:quran_hifz/features/study/domain/note.dart';
import 'package:quran_hifz/features/study/domain/study_repository.dart';
import 'package:quran_hifz/features/study/presentation/bookmarks_view.dart';

void main() {
  testWidgets(
    'bookmark view shows name reference translation and opens target',
    (tester) async {
      final study = _StudyRepository();
      BookmarkDisplayItem? opened;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepositoryProvider.overrideWithValue(study),
            bookmarkDisplayRepositoryProvider.overrideWithValue(
              _DisplayRepository(),
            ),
            appLanguageProvider.overrideWithValue(AppLanguage.bangla),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BookmarksView(onOpen: (item) => opened = item),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Morning review'), findsOneWidget);
      expect(find.text('২:২৫৫'), findsOneWidget);
      expect(find.textContaining('আল্লাহ'), findsOneWidget);
      expect(find.byKey(const ValueKey('bookmark-sort')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('bookmark-2:255')));
      expect(opened?.ayah?.key, '2:255');
    },
  );

  testWidgets('bookmark view renames and confirms deletion', (tester) async {
    final study = _StudyRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepositoryProvider.overrideWithValue(study),
          bookmarkDisplayRepositoryProvider.overrideWithValue(
            _DisplayRepository(),
          ),
          appLanguageProvider.overrideWithValue(AppLanguage.english),
        ],
        child: const MaterialApp(
          home: Scaffold(body: BookmarksView(onOpen: _ignore)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('bookmark-menu-2:255')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bookmark-rename-2:255')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('bookmark-name-field')),
      'Night review',
    );
    await tester.tap(find.byKey(const ValueKey('save-bookmark')));
    await tester.pumpAndSettle();
    expect(find.text('Night review'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bookmark-menu-2:255')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bookmark-delete-2:255')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-bookmark-delete')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bookmark-2:255')), findsNothing);
  });
}

void _ignore(BookmarkDisplayItem _) {}

class _StudyRepository implements StudyRepository {
  Bookmark? bookmark = Bookmark(
    target: const StudyTarget.ayah(surahNumber: 2, ayahNumber: 255),
    category: 'Morning review',
    createdAt: DateTime(2026, 9, 15, 8, 30),
  );

  @override
  Future<List<Bookmark>> listBookmarks({required String profileKey}) async => [
    if (bookmark != null) bookmark!,
  ];

  @override
  Future<Bookmark?> loadBookmark({
    required String profileKey,
    required StudyTarget target,
  }) async => bookmark?.target == target ? bookmark : null;

  @override
  Future<void> saveBookmark({
    required String profileKey,
    required StudyTarget target,
    required String category,
  }) async {
    bookmark = Bookmark(
      target: target,
      category: category,
      createdAt: bookmark?.createdAt,
    );
  }

  @override
  Future<void> deleteBookmark({
    required String profileKey,
    required StudyTarget target,
  }) async {
    bookmark = null;
  }

  @override
  Future<Note?> loadNote({
    required String profileKey,
    required StudyTarget target,
  }) async => null;
  @override
  Future<void> saveNote({
    required String profileKey,
    required StudyTarget target,
    required String text,
  }) async {}
  @override
  Future<void> deleteNote({
    required String profileKey,
    required StudyTarget target,
  }) async {}
}

class _DisplayRepository implements BookmarkDisplayRepository {
  @override
  Future<List<BookmarkDisplayItem>> loadItems(
    List<Bookmark> bookmarks, {
    required int translationResourceId,
  }) async => [
    for (final bookmark in bookmarks)
      BookmarkDisplayItem(
        bookmark: bookmark,
        surah: const QuranSurahSummary(
          number: 2,
          nameArabic: 'البقرة',
          nameEnglish: 'Al-Baqarah',
          nameBangla: 'আল-বাকারা',
          ayahCount: 286,
          pageStart: 2,
          pageEnd: 49,
          juzStart: 1,
        ),
        ayah: const QuranAyah(
          surahNumber: 2,
          ayahNumber: 255,
          pageNumber: 42,
          juzNumber: 3,
          translation: 'আল্লাহ, তিনি ছাড়া কোনো উপাস্য নেই।',
          words: [],
        ),
      ),
  ];
}
