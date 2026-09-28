import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/app_locale_text.dart';

import '../../../audio/application/audio_providers.dart';
import '../../../study/application/study_providers.dart';
import '../../../study/domain/bookmark.dart';
import '../../../study/presentation/word_details_sheet.dart';
import '../../../settings/application/app_preferences_controller.dart';
import '../../../settings/domain/app_preferences.dart';

import '../../application/quran_providers.dart';
import '../../domain/quran_ayah.dart';
import '../../domain/quran_word.dart';
import 'bismillah_v4_glyph.dart';
import 'inline_tafsir_panel.dart';
import 'quran_word_view.dart';
import '../quran_reading_colors.dart';

class AyahCard extends ConsumerStatefulWidget {
  const AyahCard({
    super.key,
    required this.ayah,
    required this.showTranslation,
    this.onWordTap,
    this.onWordLongPress,
    this.wordKeyFor,
    this.onPlay,
    this.onStop,
    this.onShowPlayer,
  });

  final QuranAyah ayah;
  final bool showTranslation;
  final ValueChanged<QuranWord>? onWordTap;
  final ValueChanged<QuranWord>? onWordLongPress;
  final Key Function(QuranWord word)? wordKeyFor;
  final void Function(int repeatCount, double speed)? onPlay;
  final VoidCallback? onStop;
  final VoidCallback? onShowPlayer;

  @override
  ConsumerState<AyahCard> createState() => _AyahCardState();
}

class _AyahCardState extends ConsumerState<AyahCard> {
  int _repeatCount = const AppPreferences.defaults().defaultRepeatCount;
  double _speed = const AppPreferences.defaults().defaultPlaybackSpeed;
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final defaultRepeat = ref.watch(defaultRepeatCountProvider);
    final defaultSpeed = ref.watch(defaultPlaybackSpeedProvider);
    _repeatCount = defaultRepeat;
    _speed = defaultSpeed;
    final theme = Theme.of(context);
    final banglaLineHeight = ref.watch(banglaLineHeightProvider);
    final banglaFontSize = ref.watch(banglaFontSizeProvider);
    final arabicFontSize = ref.watch(arabicFontSizeProvider);
    final showTajweedColors = ref.watch(effectiveQuranTajweedColorsProvider);
    final activeWordPosition = ref.watch(
      activeWordForAyahProvider(widget.ayah.key),
    );
    final isSentencePlaying = ref.watch(
      isAyahPlaybackActiveProvider(widget.ayah.key),
    );
    final showPlaybackBanglaWordMeaning = ref.watch(
      showPlaybackBanglaWordMeaningProvider,
    );
    final translationVisible = widget.showTranslation;
    final isFatihahBismillah =
        widget.ayah.surahNumber == 1 &&
        widget.ayah.ayahNumber == 1 &&
        widget.ayah.words.length == BismillahV4Glyph.wordGlyphs.length;

    return Card(
      key: ValueKey('ayah-${widget.ayah.key}'),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AyahPlayerControls(
              ayahNumber: widget.ayah.ayahNumber,
              onPlay: widget.onPlay == null
                  ? null
                  : () {
                      widget.onShowPlayer?.call();
                      widget.onPlay!(_repeatCount, _speed);
                    },
              onPlaybackOptions: () {
                widget.onShowPlayer?.call();
                if (!isSentencePlaying) {
                  widget.onPlay?.call(_repeatCount, _speed);
                }
              },
              onStop: widget.onStop,
              isPlaying: isSentencePlaying,
              favorite: _favorite,
              onFavorite: () => setState(() => _favorite = !_favorite),
              onBookmark: _toggleAyahBookmark,
              onShare: _shareAyah,
              onCopy: _copyAyah,
            ),
            const SizedBox(height: 20),
            if (isFatihahBismillah)
              SizedBox(
                key: const ValueKey('fatihah-bismillah-v4'),
                width: double.infinity,
                child: BismillahV4WordRow(
                  words: widget.ayah.words,
                  fontSize: (arabicFontSize * 1.55)
                      .clamp(48.0, 78.0)
                      .toDouble(),
                  activeWordPosition: activeWordPosition,
                  wordKeyFor: widget.wordKeyFor,
                  onTap: widget.onWordTap,
                  onLongPress: widget.onWordLongPress ?? _showWordDetails,
                  useTajweedColors: showTajweedColors,
                ),
              )
            else
              Directionality(
                textDirection: TextDirection.rtl,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 12,
                  children: [
                    for (final word in widget.ayah.words)
                      _PlaybackWordMeaningAnchor(
                        meaning:
                            isSentencePlaying &&
                                showPlaybackBanglaWordMeaning &&
                                word.position == activeWordPosition
                            ? word.banglaMeaning?.trim()
                            : null,
                        child: QuranWordView(
                          key:
                              widget.wordKeyFor?.call(word) ??
                              ValueKey(
                                'word-${widget.ayah.key}:${word.position}',
                              ),
                          word: word,
                          playbackAyahKey: widget.ayah.key,
                          onTap: widget.onWordTap == null
                              ? null
                              : () => widget.onWordTap!(word),
                          onLongPress: widget.onWordLongPress == null
                              ? () => _showWordDetails(word)
                              : () => widget.onWordLongPress!(word),
                        ),
                      ),
                  ],
                ),
              ),
            if (translationVisible && widget.ayah.translation != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.ayah.translation!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: banglaFontSize,
                  height: banglaLineHeight,
                ),
              ),
            ],
            InlineTafsirPanel(
              surahNumber: widget.ayah.surahNumber,
              ayahNumber: widget.ayah.ayahNumber,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAyahBookmark() async {
    final controller = ref.read(studyControllerProvider);
    final target = StudyTarget.ayah(
      surahNumber: widget.ayah.surahNumber,
      ayahNumber: widget.ayah.ayahNumber,
    );
    final existing = await controller.load(target);
    if (!mounted) return;
    var state = existing;
    if (existing.isBookmarked) {
      state = await controller.toggleBookmark(target);
    } else {
      final language = ref.read(appLanguageProvider);
      final name = await _askBookmarkName(language);
      if (!mounted || name == null) return;
      state = await controller.saveBookmarkName(target, name);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            state.isBookmarked ? 'Ayah bookmarked.' : 'Ayah bookmark removed.',
          ),
        ),
      );
  }

  Future<String?> _askBookmarkName(AppLanguage language) {
    var name = '';
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appText(language, 'বুকমার্কের নাম', 'Bookmark name')),
        content: TextField(
          key: const ValueKey('bookmark-name-field'),
          autofocus: true,
          onChanged: (value) => name = value,
          decoration: InputDecoration(
            hintText: appText(
              language,
              'খালি রাখলে তারিখ ব্যবহার হবে',
              'Leave blank to use the date',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(appText(language, 'বাতিল', 'Cancel')),
          ),
          FilledButton(
            key: const ValueKey('save-bookmark'),
            onPressed: () => Navigator.pop(dialogContext, name),
            child: Text(appText(language, 'সংরক্ষণ করুন', 'Save')),
          ),
        ],
      ),
    );
  }

  String get _ayahShareText {
    final arabic = widget.ayah.arabicText.trim().isNotEmpty
        ? widget.ayah.arabicText.trim()
        : widget.ayah.words.map((word) => word.arabic).join(' ');
    final translation = widget.ayah.translation?.trim();
    return '${widget.ayah.key}\n$arabic${translation == null || translation.isEmpty ? '' : '\n$translation'}';
  }

  Future<void> _copyAyah() async {
    await Clipboard.setData(ClipboardData(text: _ayahShareText));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ayah copied.')));
  }

  Future<void> _shareAyah() =>
      SharePlus.instance.share(ShareParams(text: _ayahShareText));

  Future<void> _showWordDetails(QuranWord word) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => WordDetailsSheet(
        target: StudyTarget.word(
          surahNumber: widget.ayah.surahNumber,
          ayahNumber: widget.ayah.ayahNumber,
          wordPosition: word.position,
        ),
        word: word,
        controller: ref.read(studyControllerProvider),
      ),
    );
  }
}

class _PlaybackWordMeaningAnchor extends StatelessWidget {
  const _PlaybackWordMeaningAnchor({
    required this.child,
    this.meaning,
  });

  final Widget child;
  final String? meaning;

  @override
  Widget build(BuildContext context) {
    final text = meaning?.trim();
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        if (text != null && text.isNotEmpty)
          Positioned(
            top: -8,
            left: 0,
            right: 0,
            height: 1,
            child: OverflowBox(
              minWidth: 0,
              maxWidth: 220,
              minHeight: 0,
              maxHeight: 80,
              alignment: Alignment.bottomCenter,
              child: _PlaybackWordMeaningBubble(meaning: text),
            ),
          ),
      ],
    );
  }
}

class _PlaybackWordMeaningBubble extends StatelessWidget {
  const _PlaybackWordMeaningBubble({required this.meaning});

  final String meaning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = QuranReadingColors.activeWordFor(context);

    return Semantics(
      liveRegion: true,
      label: 'Current word meaning: $meaning',
      child: Container(
        key: const ValueKey('playback-word-meaning-bubble'),
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.inverseSurface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.38)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.22),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          meaning,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onInverseSurface,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

class _AyahPlayerControls extends StatelessWidget {
  const _AyahPlayerControls({
    required this.ayahNumber,
    required this.onPlay,
    required this.onPlaybackOptions,
    required this.onStop,
    required this.isPlaying,
    required this.favorite,
    required this.onFavorite,
    required this.onBookmark,
    required this.onShare,
    required this.onCopy,
  });

  final int ayahNumber;
  final VoidCallback? onPlay;
  final VoidCallback onPlaybackOptions;
  final VoidCallback? onStop;
  final bool isPlaying;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButtonTheme(
        data: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            minimumSize: const Size(34, 34),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            iconSize: 19,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$ayahNumber',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            IconButton(
              tooltip: isPlaying ? 'Stop ayah' : 'Play ayah',
              onPressed: isPlaying ? onStop : onPlay,
              icon: Icon(
                isPlaying
                    ? Icons.stop_circle_outlined
                    : Icons.play_circle_outline_rounded,
              ),
            ),
            IconButton(
              tooltip: 'Favorite ayah',
              onPressed: onFavorite,
              icon: Icon(
                favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
              ),
            ),
            IconButton(
              tooltip: 'Bookmark ayah',
              onPressed: onBookmark,
              icon: const Icon(Icons.bookmark_border_rounded),
            ),
            IconButton(
              tooltip: 'Share ayah',
              onPressed: onShare,
              icon: const Icon(Icons.share_outlined),
            ),
            IconButton(
              tooltip: 'Copy ayah',
              onPressed: onCopy,
              icon: const Icon(Icons.copy_outlined),
            ),
            IconButton(
              tooltip: 'Playback options',
              onPressed: onPlaybackOptions,
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
