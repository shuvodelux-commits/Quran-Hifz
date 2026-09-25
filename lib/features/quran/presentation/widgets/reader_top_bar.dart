import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale_text.dart';
import '../../../settings/domain/app_preferences.dart';
import '../../domain/quran_surah.dart';
import '../surah_localized_text.dart';

class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({
    super.key,
    required this.current,
    required this.language,
    required this.onBack,
    required this.onBookmarks,
    required this.onSettings,
    required this.onChooseSurah,
    this.contextLabel,
  });

  final QuranSurahSummary current;
  final AppLanguage language;
  final VoidCallback onBack;
  final VoidCallback onBookmarks;
  final VoidCallback onSettings;
  final VoidCallback onChooseSurah;
  final String? contextLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label =
        '${localDigits('${current.number}', language)}. '
        '${localizedSurahName(current, language)}';

    return Material(
      key: const ValueKey('reader-top-bar'),
      color: colors.surfaceContainerLow,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.outlineVariant)),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: appText(language, 'পেছনে', 'Back'),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: InkWell(
                key: const ValueKey('reader-surah-title'),
                onTap: onChooseSurah,
                borderRadius: BorderRadius.circular(10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 19,
                          ),
                        ],
                      ),
                      if (contextLabel != null)
                        Text(
                          contextLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Bookmarks',
              onPressed: onBookmarks,
              icon: const Icon(Icons.menu_book_outlined),
            ),
            IconButton(
              tooltip: 'Reader settings',
              onPressed: onSettings,
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
