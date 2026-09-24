import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale_text.dart';
import '../../../settings/domain/app_preferences.dart';

enum QuranLibraryTab { surah, juz, bookmarks }

class QuranLibraryTabs extends StatelessWidget {
  const QuranLibraryTabs({
    super.key,
    required this.selected,
    required this.language,
    required this.onSelected,
  });

  final QuranLibraryTab selected;
  final AppLanguage language;
  final ValueChanged<QuranLibraryTab> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Tab(
        key: const ValueKey('quran-tab-surah'),
        label: appText(language, 'সুরা', 'Surah'),
        selected: selected == QuranLibraryTab.surah,
        onTap: () => onSelected(QuranLibraryTab.surah),
      ),
      _Tab(
        key: const ValueKey('quran-tab-juz'),
        label: appText(language, 'পারা', 'Juz'),
        selected: selected == QuranLibraryTab.juz,
        onTap: () => onSelected(QuranLibraryTab.juz),
      ),
      _Tab(
        key: const ValueKey('quran-tab-bookmarks'),
        label: appText(language, 'বুকমার্ক', 'Bookmarks'),
        selected: selected == QuranLibraryTab.bookmarks,
        onTap: () => onSelected(QuranLibraryTab.bookmarks),
      ),
    ],
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? colors.primary
                    : Theme.of(context).dividerColor,
                width: selected ? 3 : 1,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? colors.primary : colors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
