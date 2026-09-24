import 'bookmark.dart';
import 'bookmark_display_item.dart';

abstract interface class BookmarkDisplayRepository {
  Future<List<BookmarkDisplayItem>> loadItems(
    List<Bookmark> bookmarks, {
    required int translationResourceId,
  });
}
