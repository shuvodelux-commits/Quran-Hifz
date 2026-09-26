import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale_text.dart';
import '../../../settings/domain/app_preferences.dart';
import '../../domain/quran_surah.dart';
import '../surah_localized_text.dart';
import 'surah_name_v4_text.dart';

class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({
    super.key,
    required this.current,
    required this.language,
    required this.showTranslation,
    required this.onBack,
    required this.onToggleTranslation,
    required this.onBookmarks,
    required this.onSettings,
    required this.onChooseSurah,
  });

  final QuranSurahSummary current;
  final AppLanguage language;
  final bool showTranslation;
  final VoidCallback onBack;
  final VoidCallback onToggleTranslation;
  final VoidCallback onBookmarks;
  final VoidCallback onSettings;
  final VoidCallback onChooseSurah;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subtitle = localizedSurahName(current, language);

    return Material(
      key: const ValueKey('reader-top-bar'),
      color: colors.surface,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.outlineVariant)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _TopBarIconButton(
                tooltip: appText(language, 'পেছনে', 'Back'),
                onPressed: onBack,
                icon: Icons.arrow_back_rounded,
              ),
            ),
            Center(
              child: SizedBox(
                width: 116,
                child: InkWell(
                  key: const ValueKey('reader-surah-title'),
                  onTap: onChooseSurah,
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        key: const ValueKey('reader-top-surah-name'),
                        height: 35,
                        width: 110,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SurahNameV4Text(
                            surahNumber: current.number,
                            arabicName: current.nameArabic,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 33,
                              height: 1.05,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TopBarIconButton(
                    tooltip: showTranslation
                        ? 'Hide translation'
                        : 'Show translation',
                    onPressed: onToggleTranslation,
                    icon: showTranslation
                        ? Icons.translate_rounded
                        : Icons.translate_outlined,
                  ),
                  _TopBarIconButton(
                    tooltip: 'Bookmarks',
                    onPressed: onBookmarks,
                    icon: Icons.bookmark_border_rounded,
                  ),
                  _TopBarIconButton(
                    tooltip: 'Reader settings',
                    onPressed: onSettings,
                    icon: Icons.tune_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon),
      ),
    );
  }
}
