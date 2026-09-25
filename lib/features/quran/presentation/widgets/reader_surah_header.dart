import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale_text.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../settings/domain/app_preferences.dart';
import '../../domain/quran_surah.dart';
import '../surah_localized_text.dart';

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
    final palette = Theme.of(context).extension<AppPalette>();
    final headerColor = palette?.quranHeader ?? colors.primary;
    final gold = palette?.goldAccent ?? colors.tertiary;
    final onHeader = colors.onPrimary;
    final bn = language == AppLanguage.bangla;
    final revelation = (surah.revelationPlace?.trim().isNotEmpty ?? false)
        ? surah.revelationPlace!.trim()
        : appText(language, 'অজানা', 'Unknown');

    return Padding(
      key: const ValueKey('reader-surah-header'),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: const ValueKey('reader-surah-info-card'),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: onHeader,
                      height: 1.45,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetadataLine(
                          label: bn ? 'সূরা' : 'Surah',
                          value: localizedSurahName(surah, language),
                          accent: gold,
                        ),
                        _MetadataLine(
                          label: 'English',
                          value: surah.nameEnglish,
                          accent: gold,
                        ),
                        _MetadataLine(
                          label: bn ? 'আয়াত' : 'Verses',
                          value: localDigits('${surah.ayahCount}', language),
                          accent: gold,
                        ),
                        _MetadataLine(
                          label: bn ? 'নাজিল' : 'Revealed in',
                          value: revelation,
                          accent: gold,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 82,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          'سورة ${surah.nameArabic}',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: onHeader,
                            fontFamily: 'AlQalamQuranMajeed',
                            fontSize: 40,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Tooltip(
                message: 'Play Surah',
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: FilledButton.tonal(
                    key: const ValueKey('play-surah'),
                    onPressed: onPlay,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
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
                      minimumSize: const Size.fromHeight(44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(appText(language, 'তাফসির', 'Tafsir')),
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
                      minimumSize: const Size.fromHeight(44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(appText(language, 'ডাউনলোড', 'Download')),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: base.copyWith(color: accent, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
