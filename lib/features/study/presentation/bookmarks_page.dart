import 'package:flutter/material.dart';

import '../../quran/domain/reader_scope.dart';
import '../../quran/presentation/quran_reader_page.dart';
import '../domain/bookmark_display_item.dart';
import 'bookmarks_view.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bookmarks')),
    body: BookmarksView(onOpen: (item) => _open(context, item)),
  );

  void _open(BuildContext context, BookmarkDisplayItem item) {
    final surah = item.surah;
    final ayah = item.ayah;
    if (surah == null || ayah == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuranReaderPage(
          scope: SurahReaderScope(
            surah: surah,
            startAyahNumber: ayah.ayahNumber,
          ),
          initialAyahNumber: ayah.ayahNumber,
        ),
      ),
    );
  }
}
