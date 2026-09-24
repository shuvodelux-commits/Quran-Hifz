import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../quran/application/quran_providers.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/study_providers.dart';
import '../domain/bookmark.dart';
import '../domain/bookmark_display_item.dart';

final bookmarkDisplayItemsProvider =
    FutureProvider.autoDispose<List<BookmarkDisplayItem>>((ref) async {
      final bookmarks = await ref.watch(bookmarksProvider.future);
      return ref
          .watch(bookmarkDisplayRepositoryProvider)
          .loadItems(
            bookmarks,
            translationResourceId: ref.watch(
              quranTranslationResourceIdProvider,
            ),
          );
    });

enum _BookmarkSort { newest, oldest }

class BookmarksView extends ConsumerStatefulWidget {
  const BookmarksView({super.key, required this.onOpen});

  final ValueChanged<BookmarkDisplayItem> onOpen;

  @override
  ConsumerState<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends ConsumerState<BookmarksView> {
  var _sort = _BookmarkSort.newest;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final items = ref.watch(bookmarkDisplayItemsProvider);
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: FilledButton.icon(
          onPressed: _refresh,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(appText(language, 'আবার চেষ্টা করুন', 'Retry')),
        ),
      ),
      data: (source) {
        final sorted = [...source]
          ..sort((a, b) {
            final left =
                a.bookmark.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final right =
                b.bookmark.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return _sort == _BookmarkSort.newest
                ? right.compareTo(left)
                : left.compareTo(right);
          });
        if (sorted.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                appText(
                  language,
                  'কোনো বুকমার্ক নেই। আয়াত থেকে বুকমার্ক যোগ করুন।',
                  'No bookmarks yet. Add one from an ayah.',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
              child: Row(
                children: [
                  Text(
                    appText(language, 'বুকমার্কসমূহ', 'Bookmarks'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  PopupMenuButton<_BookmarkSort>(
                    key: const ValueKey('bookmark-sort'),
                    tooltip: appText(
                      language,
                      'তারিখ অনুযায়ী সাজান',
                      'Sort by date',
                    ),
                    initialValue: _sort,
                    onSelected: (value) => setState(() => _sort = value),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        key: const ValueKey('bookmark-sort-newest'),
                        value: _BookmarkSort.newest,
                        child: Text(
                          appText(language, 'নতুন আগে', 'Newest first'),
                        ),
                      ),
                      PopupMenuItem(
                        key: const ValueKey('bookmark-sort-oldest'),
                        value: _BookmarkSort.oldest,
                        child: Text(
                          appText(language, 'পুরোনো আগে', 'Oldest first'),
                        ),
                      ),
                    ],
                    child: Row(
                      children: [
                        Text(
                          appText(language, 'তারিখ অনুযায়ী', 'Sort by date'),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) => _BookmarkRow(
                    item: sorted[index],
                    language: language,
                    onOpen: widget.onOpen,
                    onRename: () => _rename(sorted[index], language),
                    onDelete: () => _delete(sorted[index], language),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _refresh() {
    ref.invalidate(bookmarksProvider);
    ref.invalidate(bookmarkDisplayItemsProvider);
  }

  Future<void> _rename(BookmarkDisplayItem item, AppLanguage language) async {
    var name = item.bookmark.category;
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          appText(language, 'বুকমার্কের নাম বদলান', 'Rename bookmark'),
        ),
        content: TextFormField(
          key: const ValueKey('bookmark-name-field'),
          initialValue: name,
          autofocus: true,
          onChanged: (value) => name = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(appText(language, 'বাতিল', 'Cancel')),
          ),
          FilledButton(
            key: const ValueKey('save-bookmark'),
            onPressed: () {
              if (name.trim().isNotEmpty) Navigator.pop(dialogContext, name);
            },
            child: Text(appText(language, 'সংরক্ষণ করুন', 'Save')),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    await ref
        .read(studyControllerProvider)
        .saveBookmarkName(item.bookmark.target, result);
    _refresh();
  }

  Future<void> _delete(BookmarkDisplayItem item, AppLanguage language) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appText(language, 'বুকমার্ক মুছবেন?', 'Delete bookmark?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(appText(language, 'বাতিল', 'Cancel')),
          ),
          FilledButton(
            key: const ValueKey('confirm-bookmark-delete'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(appText(language, 'মুছুন', 'Delete')),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await ref
        .read(studyControllerProvider)
        .toggleBookmark(item.bookmark.target);
    _refresh();
  }
}

class _BookmarkRow extends StatelessWidget {
  const _BookmarkRow({
    required this.item,
    required this.language,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final BookmarkDisplayItem item;
  final AppLanguage language;
  final ValueChanged<BookmarkDisplayItem> onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final target = item.bookmark.target;
    final reference = localDigits(
      '${target.surahNumber}:${target.ayahNumber}',
      language,
    );
    final word = target.type == StudyTargetType.word
        ? ' · ${appText(language, 'শব্দ', 'word')} ${localDigits('${target.wordPosition}', language)}'
        : '';
    return ListTile(
      key: ValueKey('bookmark-${target.surahNumber}:${target.ayahNumber}'),
      enabled: item.isAvailable,
      onTap: item.isAvailable ? () => onOpen(item) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: Icon(
        Icons.bookmark_border_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        item.bookmark.category,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '$reference$word',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
          if (item.ayah?.translation case final translation?) ...[
            const SizedBox(height: 6),
            Text(translation, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          if (item.bookmark.createdAt case final created?) ...[
            const SizedBox(height: 4),
            Text(
              _dateText(created),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      trailing: PopupMenuButton<_BookmarkAction>(
        key: ValueKey(
          'bookmark-menu-${target.surahNumber}:${target.ayahNumber}',
        ),
        onSelected: (action) =>
            action == _BookmarkAction.rename ? onRename() : onDelete(),
        itemBuilder: (_) => [
          PopupMenuItem(
            key: ValueKey(
              'bookmark-rename-${target.surahNumber}:${target.ayahNumber}',
            ),
            value: _BookmarkAction.rename,
            child: Text(appText(language, 'নাম বদলান', 'Rename')),
          ),
          PopupMenuItem(
            key: ValueKey(
              'bookmark-delete-${target.surahNumber}:${target.ayahNumber}',
            ),
            value: _BookmarkAction.delete,
            child: Text(appText(language, 'মুছুন', 'Delete')),
          ),
        ],
      ),
    );
  }
}

enum _BookmarkAction { rename, delete }

String _dateText(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
}
