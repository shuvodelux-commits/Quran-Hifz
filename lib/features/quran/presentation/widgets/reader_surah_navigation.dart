import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale_text.dart';
import '../../../settings/domain/app_preferences.dart';
import '../../domain/quran_surah.dart';
import '../surah_localized_text.dart';

class ReaderSurahNavigation extends StatelessWidget {
  const ReaderSurahNavigation({
    super.key,
    required this.surahs,
    required this.current,
    required this.language,
    required this.onSelected,
  });

  final List<QuranSurahSummary> surahs;
  final QuranSurahSummary current;
  final AppLanguage language;
  final ValueChanged<QuranSurahSummary> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      key: const ValueKey('reader-surah-navigation'),
      color: colors.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 520),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            itemCount: surahs.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: colors.outlineVariant),
            itemBuilder: (context, index) {
              final surah = surahs[index];
              final selected = surah.number == current.number;
              return ListTile(
                key: ValueKey('reader-surah-choice-${surah.number}'),
                minTileHeight: 48,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                selected: selected,
                selectedColor: colors.primary,
                selectedTileColor: colors.primaryContainer.withValues(
                  alpha: 0.65,
                ),
                leading: SizedBox(
                  width: 34,
                  child: Text(
                    localDigits('${surah.number}', language),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
                title: Text(
                  _label(surah, language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: selected
                    ? Icon(Icons.check_rounded, color: colors.primary)
                    : null,
                onTap: () => onSelected(surah),
              );
            },
          ),
        ),
      ),
    );
  }
}

String _label(QuranSurahSummary surah, AppLanguage language) {
  final name = localizedSurahName(surah, language);
  return '${localDigits('${surah.number}', language)}. $name';
}
