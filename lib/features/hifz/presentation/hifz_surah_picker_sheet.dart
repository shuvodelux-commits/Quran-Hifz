import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../quran/domain/quran_surah.dart';
import '../../quran/presentation/surah_localized_text.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';

class HifzSurahPickerSheet extends ConsumerStatefulWidget {
  const HifzSurahPickerSheet({
    required this.surahs,
    this.selectedSurahNumber,
    super.key,
  });

  final List<QuranSurahSummary> surahs;
  final int? selectedSurahNumber;

  @override
  ConsumerState<HifzSurahPickerSheet> createState() =>
      _HifzSurahPickerSheetState();
}

class _HifzSurahPickerSheetState extends ConsumerState<HifzSurahPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final visible = widget.surahs.where(_matches).toList(growable: false);

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      appText(language, 'সূরা নির্বাচন করুন', 'Choose Surah'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                key: const ValueKey('hifz-surah-search'),
                decoration: InputDecoration(
                  hintText: appText(
                    language,
                    'নাম বা নম্বর দিয়ে সূরা খুঁজুন',
                    'Search Surah name or number',
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child: Text(
                        appText(
                          language,
                          'কোনো সূরা পাওয়া যায়নি।',
                          'No Surah found.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final surah = visible[index];
                        final selected =
                            surah.number == widget.selectedSurahNumber;
                        final ayahCountText = language == AppLanguage.bangla
                            ? localDigits(
                                  surah.ayahCount.toString(),
                                  language,
                                ) +
                                ' আয়াত'
                            : surah.ayahCount.toString() + ' ayahs';
                        return ListTile(
                          key: ValueKey(
                            'hifz-surah-' + surah.number.toString(),
                          ),
                          minTileHeight: 56,
                          selected: selected,
                          onTap: () => Navigator.of(context).pop(surah),
                          leading: SizedBox(
                            width: 34,
                            child: Center(
                              child: Text(
                                localDigits(
                                  surah.number.toString(),
                                  language,
                                ),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          ),
                          title: Text(
                            localizedSurahName(surah, language),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            surah.nameArabic,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(ayahCountText),
                              if (selected)
                                const Icon(Icons.check_rounded, size: 18),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matches(QuranSurahSummary surah) {
    final raw = _query.trim();
    if (raw.isEmpty) return true;
    final query = raw.toLowerCase();
    final bangla = localizedSurahName(
      surah,
      AppLanguage.bangla,
    ).toLowerCase();
    final explicitBangla = surah.nameBangla?.toLowerCase() ?? '';
    return surah.number.toString().contains(query) ||
        surah.nameEnglish.toLowerCase().contains(query) ||
        surah.nameArabic.contains(raw) ||
        bangla.contains(query) ||
        explicitBangla.contains(query);
  }
}
