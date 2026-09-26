import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale_text.dart';
import '../../../settings/domain/app_preferences.dart';
import '../../domain/quran_surah.dart';
import '../surah_localized_text.dart';
import 'surah_name_v4_text.dart';

class ReaderSurahHeader extends StatelessWidget {
  const ReaderSurahHeader({
    super.key,
    required this.surah,
    required this.language,
    required this.onPlay,
    required this.onTafsir,
    required this.onDownload,
  });

  final QuranSurahSummary surah;
  final AppLanguage language;
  final VoidCallback onPlay;
  final VoidCallback onTafsir;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      key: const ValueKey('reader-surah-header'),
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      color: colors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedSurahTitle(surah, language),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${localDigits('${surah.ayahCount}', language)} '
                        '${appText(language, 'আয়াত', 'Ayahs')}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 126,
                  height: 54,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: SurahNameV4Text(
                      surahNumber: surah.number,
                      arabicName: surah.nameArabic,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 34,
                        height: 1.15,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              localizedSurahDescription(surah, language),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Tooltip(
                  message: 'Play Surah',
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: FilledButton.tonal(
                      key: const ValueKey('play-surah'),
                      onPressed: onPlay,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        shape: const StadiumBorder(),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Tooltip(
                    message: 'Open Tafsir',
                    child: OutlinedButton.icon(
                      key: const ValueKey('open-surah-tafsir'),
                      onPressed: onTafsir,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        visualDensity: VisualDensity.compact,
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          appText(language, 'তাফসির', 'Tafsir'),
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Tooltip(
                    message: 'Downloads',
                    child: OutlinedButton.icon(
                      key: const ValueKey('open-surah-downloads'),
                      onPressed: onDownload,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          appText(language, 'ডাউনলোড', 'Download'),
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
