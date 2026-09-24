import '../../quran/domain/quran_ayah.dart';
import '../../quran/domain/quran_surah.dart';
import 'bookmark.dart';

class BookmarkDisplayItem {
  const BookmarkDisplayItem({required this.bookmark, this.surah, this.ayah});

  final Bookmark bookmark;
  final QuranSurahSummary? surah;
  final QuranAyah? ayah;

  bool get isAvailable => surah != null && ayah != null;
}
