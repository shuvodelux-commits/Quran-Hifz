import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../quran/domain/bismillah_policy.dart';
import '../../quran/domain/bismillah_text.dart';
import '../../quran/domain/quran_ayah.dart';
import '../../quran/domain/quran_font_preference.dart';
import '../../quran/domain/quran_mushaf_line.dart';
import '../../quran/domain/quran_page_window.dart';
import '../../quran/domain/quran_surah.dart';
import '../../quran/domain/quran_word.dart';
import '../../quran/presentation/quran_text_style.dart';
import '../../quran/presentation/widgets/surah_name_banner.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../application/hifz_appearance_controller.dart';
import '../application/hifz_flow_composer.dart';
import '../application/hifz_text_layout.dart';
import '../domain/hifz_session.dart';
import 'hifz_flow_line.dart';
import 'hifz_mushaf_line.dart';

class HifzMushafSurface extends ConsumerWidget {
  const HifzMushafSurface({
    super.key,
    required this.surah,
    required this.window,
    this.surahs = const [],
    this.scrollController,
    this.selectedStartAyah,
    this.selectedEndAyah,
    this.activeAyahKey,
    this.onAyahSelected,
    this.onWordTap,
    this.onWordLongPress,
    this.embeddedInScroll = false,
    this.showAllPageSurahs = false,
  });

  final QuranSurahSummary surah;
  final QuranPageWindow window;
  final List<QuranSurahSummary> surahs;
  final ScrollController? scrollController;
  final AyahRef? selectedStartAyah;
  final AyahRef? selectedEndAyah;
  final String? activeAyahKey;
  final ValueChanged<AyahRef>? onAyahSelected;
  final void Function(QuranAyah ayah, QuranWord word)? onWordTap;
  final void Function(QuranAyah ayah, QuranWord word)? onWordLongPress;
  final bool embeddedInScroll;
  final bool showAllPageSurahs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceOverride = ref.watch(hifzAppearanceOverrideProvider);
    final QuranFontPreference font =
        appearanceOverride.font ?? ref.watch(hifzQuranFontProvider);
    final double requestedSize =
        appearanceOverride.fontSize ?? ref.watch(hifzFontSizeProvider);
    final double lineHeight =
        appearanceOverride.lineHeight ?? ref.watch(hifzLineHeightProvider);
    final canonicalLines = showAllPageSurahs
        ? _canonicalLinesForPage(window)
        : _canonicalLinesForSurah(window, surah.number);
    final visibleAyahs = showAllPageSurahs
        ? window.ayahs
        : window.ayahs
              .where((ayah) => ayah.surahNumber == surah.number)
              .toList(growable: false);
    final mushaf = canonicalLines == null
        ? _ReadableHifzMushafFallback(
            ayahs: visibleAyahs,
            font: font,
            fontSize: requestedSize,
            lineHeight: lineHeight,
            selectedAyahs: _selectedAyahs(),
            activeAyahKey: activeAyahKey,
            onAyahSelected: onAyahSelected,
            onWordTap: onWordTap,
            onWordLongPress: onWordLongPress,
          )
        : _CanonicalHifzMushaf(
            window: window,
            lines: canonicalLines,
            surah: surah,
            surahs: surahs,
            font: font,
            fontSize: requestedSize,
            lineHeight: lineHeight,
            selectedAyahs: _selectedAyahs(),
            activeAyahKey: activeAyahKey,
            onAyahSelected: onAyahSelected,
            onWordTap: onWordTap,
            onWordLongPress: onWordLongPress,
          );
    return Semantics(
      label: 'Mushaf page ${window.page}',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
            child: embeddedInScroll
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SurahHeader(surah: surah),
                      const SizedBox(height: 8),
                      mushaf,
                      const SizedBox(height: 20),
                      _PageFooter(surah: surah, window: window),
                    ],
                  )
                : Column(
                    children: [
                      _SurahHeader(surah: surah),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            key: ValueKey('hifz-mushaf-scroll-${window.page}'),
                            controller: scrollController,
                            padding: const EdgeInsets.only(bottom: 64),
                            child: mushaf,
                          ),
                        ),
                      ),
                      _PageFooter(surah: surah, window: window),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Set<AyahRef> _selectedAyahs() {
    final start = selectedStartAyah;
    if (start == null) return const {};
    final end = selectedEndAyah ?? start;
    if (end.surahNumber != start.surahNumber) return {start, end};
    return {
      for (var ayah = start.ayahNumber; ayah <= end.ayahNumber; ayah++)
        AyahRef(surahNumber: start.surahNumber, ayahNumber: ayah),
    };
  }
}

List<QuranMushafLine>? _canonicalLinesForPage(QuranPageWindow window) {
  final lines = window.lines.toList(growable: false);
  if (lines.isEmpty ||
      lines.where((line) => line.type == QuranMushafLineType.ayah).isEmpty) {
    return null;
  }
  final expected = <QuranWordLocation>[
    for (final ayah in window.ayahs)
      for (final word in ayah.words)
        QuranWordLocation(
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
          position: word.position,
        ),
  ];
  final actual = <QuranWordLocation>[
    for (final line in lines)
      if (line.type == QuranMushafLineType.ayah) ...line.wordLocations,
  ];
  if (actual.length != expected.length) return null;
  for (var index = 0; index < expected.length; index++) {
    if (actual[index] != expected[index]) return null;
  }
  return lines;
}

List<QuranMushafLine>? _canonicalLinesForSurah(
  QuranPageWindow window,
  int surahNumber,
) {
  final lines = window.lines
      .where((line) => line.surahNumber == surahNumber)
      .toList(growable: false);
  if (lines.isEmpty ||
      lines.where((line) => line.type == QuranMushafLineType.ayah).isEmpty) {
    return null;
  }
  if (lines.where((line) => line.type == QuranMushafLineType.bismillah).length >
          1 ||
      lines.where((line) => line.type == QuranMushafLineType.surahName).length >
          1) {
    return null;
  }

  final expected = <QuranWordLocation>[
    for (final ayah in window.ayahs)
      if (ayah.surahNumber == surahNumber)
        for (final word in ayah.words)
          QuranWordLocation(
            surahNumber: ayah.surahNumber,
            ayahNumber: ayah.ayahNumber,
            position: word.position,
          ),
  ];
  final actual = <QuranWordLocation>[
    for (final line in lines)
      if (line.type == QuranMushafLineType.ayah) ...line.wordLocations,
  ];
  if (actual.length != expected.length) return null;
  for (var index = 0; index < expected.length; index++) {
    if (actual[index] != expected[index]) return null;
  }
  return lines;
}

/// Renders a page's precomputed Mushaf lines the way the printed page does:
/// "full" lines stretch edge to edge, short/centered lines share the same
/// column. Wide lines wrap vertically at the selected font size.
class _CanonicalHifzMushaf extends StatelessWidget {
  const _CanonicalHifzMushaf({
    required this.window,
    required this.lines,
    required this.surah,
    required this.surahs,
    required this.font,
    required this.fontSize,
    required this.lineHeight,
    required this.selectedAyahs,
    required this.activeAyahKey,
    this.onAyahSelected,
    this.onWordTap,
    this.onWordLongPress,
  });

  final QuranPageWindow window;
  final List<QuranMushafLine> lines;
  final QuranSurahSummary surah;
  final List<QuranSurahSummary> surahs;
  final QuranFontPreference font;
  final double fontSize;
  final double lineHeight;
  final Set<AyahRef> selectedAyahs;
  final String? activeAyahKey;
  final ValueChanged<AyahRef>? onAyahSelected;
  final void Function(QuranAyah ayah, QuranWord word)? onWordTap;
  final void Function(QuranAyah ayah, QuranWord word)? onWordLongPress;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 800.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final line in lines) _buildLine(line, availableWidth),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLine(QuranMushafLine line, double rowWidth) {
    switch (line.type) {
      case QuranMushafLineType.bismillah:
        return _StandaloneBismillah(
          surahNumber: line.surahNumber!,
          font: font,
          fontSize: fontSize,
          lineHeight: lineHeight,
        );
      case QuranMushafLineType.surahName:
        return Padding(
          key: ValueKey('hifz-surah-banner-${line.surahNumber}'),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: SurahNameBanner(
            nameArabic: _findSurah(line.surahNumber!).nameArabic,
          ),
        );
      case QuranMushafLineType.ayah:
        return Container(
          key: ValueKey('hifz-line-${line.lineNumber}'),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: HifzMushafLine(
            words: resolveMushafLine(window, line),
            centered: window.page <= 2 || line.centered,
            font: font,
            fontSize: fontSize,
            lineHeight: lineHeight,
            rowWidth: rowWidth,
            selectedAyahs: selectedAyahs,
            activeAyahKey: activeAyahKey,
            onAyahSelected: onAyahSelected,
            onWordTap: onWordTap == null
                ? null
                : (lineWord) => onWordTap!(lineWord.ayah, lineWord.word),
            onWordLongPress: onWordLongPress == null
                ? null
                : (lineWord) => onWordLongPress!(lineWord.ayah, lineWord.word),
          ),
        );
    }
  }

  QuranSurahSummary _findSurah(int number) {
    for (final item in surahs) {
      if (item.number == number) return item;
    }
    return surah;
  }
}

class _ReadableHifzMushafFallback extends StatelessWidget {
  const _ReadableHifzMushafFallback({
    required this.ayahs,
    required this.font,
    required this.fontSize,
    required this.lineHeight,
    required this.selectedAyahs,
    required this.activeAyahKey,
    this.onAyahSelected,
    this.onWordTap,
    this.onWordLongPress,
  });

  final List<QuranAyah> ayahs;
  final QuranFontPreference font;
  final double fontSize;
  final double lineHeight;
  final Set<AyahRef> selectedAyahs;
  final String? activeAyahKey;
  final ValueChanged<AyahRef>? onAyahSelected;
  final void Function(QuranAyah ayah, QuranWord word)? onWordTap;
  final void Function(QuranAyah ayah, QuranWord word)? onWordLongPress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 800.0;
        final scaler = MediaQuery.textScalerOf(context);
        final surahNumber = ayahs.isEmpty ? null : ayahs.first.surahNumber;
        final flowAyahs = surahNumber == 1
            ? ayahs
                  .where((ayah) => ayah.ayahNumber != 1)
                  .toList(growable: false)
            : ayahs;
        final rows = HifzFlowComposer.compose(
          ayahs: flowAyahs,
          availableWidth: width,
          minimumGap: 4,
          maximumGap: 12,
          measureWord: (_, word) =>
              _measureWord(word.arabicFor(font.script), scaler) + 2,
          measureMarker: (_) => scaler.scale(fontSize) * .92,
        );
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (surahNumber != null &&
                  ayahs.any((ayah) => ayah.ayahNumber == 1))
                _StandaloneBismillah(
                  surahNumber: surahNumber,
                  font: font,
                  fontSize: fontSize,
                  lineHeight: lineHeight,
                  child: surahNumber == 1
                      ? _buildInteractiveBismillah(
                          ayahs.firstWhere((ayah) => ayah.ayahNumber == 1),
                        )
                      : null,
                ),
              for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
                Container(
                  key: ValueKey('hifz-flow-line-$rowIndex'),
                  padding: EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: fontSize * (lineHeight - 1) * .12,
                  ),
                  child: HifzFlowLine(
                    row: rows[rowIndex],
                    rowIndex: rowIndex,
                    tokenBuilder: _buildToken,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _measureWord(String text, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: QuranTextStyle.forScript(
          script: font.script,
          color: Colors.black,
          fontSize: fontSize,
          lineHeight: lineHeight,
          font: font,
        ),
      ),
      textDirection: TextDirection.rtl,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  Widget _buildToken(HifzFlowToken token) {
    final ayah = token.ayah;
    if (token.isMarker) {
      final reference = AyahRef(
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
      );
      return HifzAyahMarker(
        ayahNumber: ayah.ayahNumber,
        ayahKey: ayah.key,
        fontSize: fontSize,
        selected: selectedAyahs.contains(reference),
        active: false,
        onTap: onAyahSelected == null ? null : () => onAyahSelected!(reference),
      );
    }
    final word = token.word!;
    return HifzMushafWord(
      key: ValueKey('hifz-word-${ayah.key}:${word.position}'),
      lineWord: HifzLineWord(
        location: QuranWordLocation(
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
          position: word.position,
        ),
        ayah: ayah,
        word: word,
        endsAyah: word.position == ayah.words.last.position,
      ),
      font: font,
      fontSize: fontSize,
      lineHeight: lineHeight,
      isActiveAyah: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 1),
      onTap: onWordTap == null ? null : () => onWordTap!(ayah, word),
      onLongPress: onWordLongPress == null
          ? null
          : () => onWordLongPress!(ayah, word),
    );
  }

  Widget _buildInteractiveBismillah(QuranAyah ayah) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: fontSize * (lineHeight - 1),
      textDirection: TextDirection.rtl,
      children: [
        for (var index = 0; index < ayah.words.length; index++)
          HifzMushafWord(
            key: ValueKey(
              'hifz-word-${ayah.key}:${ayah.words[index].position}',
            ),
            lineWord: HifzLineWord(
              location: QuranWordLocation(
                surahNumber: ayah.surahNumber,
                ayahNumber: ayah.ayahNumber,
                position: ayah.words[index].position,
              ),
              ayah: ayah,
              word: ayah.words[index],
              endsAyah: index == ayah.words.length - 1,
            ),
            font: font,
            fontSize: fontSize * .92,
            lineHeight: lineHeight,
            isActiveAyah: false,
            contentPadding: EdgeInsets.zero,
            onTap: onWordTap == null
                ? null
                : () => onWordTap!(ayah, ayah.words[index]),
            onLongPress: onWordLongPress == null
                ? null
                : () => onWordLongPress!(ayah, ayah.words[index]),
          ),
      ],
    );
  }
}

class _StandaloneBismillah extends StatelessWidget {
  const _StandaloneBismillah({
    required this.surahNumber,
    required this.font,
    required this.fontSize,
    required this.lineHeight,
    this.child,
  });
  final int surahNumber;
  final QuranFontPreference font;
  final double fontSize;
  final double lineHeight;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (surahNumber != 1 && !shouldShowStandaloneBismillah(surahNumber)) {
      return const SizedBox.shrink();
    }
    return Container(
      key: ValueKey('surah-bismillah-$surahNumber'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child:
            child ??
            Text(
              BismillahText.plainFor(font.script),
              textAlign: TextAlign.center,
              style: QuranTextStyle.forScript(
                script: font.script,
                color: Theme.of(context).colorScheme.onSurface,
                font: font,
                fontSize: fontSize * .92,
                lineHeight: lineHeight,
              ),
            ),
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah});
  final QuranSurahSummary surah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          SurahNameBanner(nameArabic: surah.nameArabic),
          const SizedBox(height: 3),
          Text(surah.nameEnglish, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// Footer info line under the reading canvas, in the familiar
/// "Surah · Juz · Page" order used by printed Mushafs.
class _PageFooter extends StatelessWidget {
  const _PageFooter({required this.surah, required this.window});

  final QuranSurahSummary surah;
  final QuranPageWindow window;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    final juz = _currentJuz();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 2,
        children: [
          Text(surah.nameEnglish, style: style),
          if (juz != null) ...[
            Text('  ·  ', style: style),
            Text('Juz $juz', style: style),
          ],
          Text('  ·  ', style: style),
          Text('Page ${window.page}', style: style),
        ],
      ),
    );
  }

  int? _currentJuz() {
    for (final ayah in window.ayahs) {
      if (ayah.surahNumber == surah.number) return ayah.juzNumber;
    }
    return window.ayahs.isEmpty ? null : window.ayahs.first.juzNumber;
  }
}
