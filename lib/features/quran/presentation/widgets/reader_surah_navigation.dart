import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale_text.dart';
import '../../../settings/domain/app_preferences.dart';
import '../../domain/quran_surah.dart';
import '../surah_localized_text.dart';

class ReaderSurahNavigation extends StatelessWidget {
  const ReaderSurahNavigation({
    super.key,
    required this.previous,
    required this.current,
    required this.next,
    required this.language,
    required this.onSelected,
    this.centerLabel,
  });

  final QuranSurahSummary? previous;
  final QuranSurahSummary current;
  final QuranSurahSummary? next;
  final AppLanguage language;
  final ValueChanged<QuranSurahSummary> onSelected;
  final String? centerLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('reader-surah-navigation'),
      height: 44,
      color: colors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Expanded(
            child: _Neighbor(
              surah: previous,
              language: language,
              tooltip: 'Previous Surah',
              icon: Icons.chevron_left_rounded,
              iconAfter: false,
              onSelected: onSelected,
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => onSelected(current),
              style: TextButton.styleFrom(
                foregroundColor: colors.onPrimary,
                minimumSize: const Size.fromHeight(40),
                padding: const EdgeInsets.symmetric(horizontal: 2),
              ),
              child: Text(
                centerLabel ?? _label(current, language),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: _Neighbor(
              surah: next,
              language: language,
              tooltip: 'Next Surah',
              icon: Icons.chevron_right_rounded,
              iconAfter: true,
              onSelected: onSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _Neighbor extends StatelessWidget {
  const _Neighbor({
    required this.surah,
    required this.language,
    required this.tooltip,
    required this.icon,
    required this.iconAfter,
    required this.onSelected,
  });

  final QuranSurahSummary? surah;
  final AppLanguage language;
  final String tooltip;
  final IconData icon;
  final bool iconAfter;
  final ValueChanged<QuranSurahSummary> onSelected;

  @override
  Widget build(BuildContext context) {
    final item = surah;
    if (item == null) return const SizedBox(height: 40);
    final children = <Widget>[
      Icon(icon, size: 18),
      Expanded(
        child: Text(
          _label(item, language),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    ];
    return Tooltip(
      message: tooltip,
      child: TextButton(
        onPressed: () => onSelected(item),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(40),
          padding: const EdgeInsets.symmetric(horizontal: 2),
        ),
        child: Row(children: iconAfter ? children.reversed.toList() : children),
      ),
    );
  }
}

String _label(QuranSurahSummary surah, AppLanguage language) {
  final name = localizedSurahName(surah, language);
  return '${localDigits('${surah.number}', language)}. $name';
}
