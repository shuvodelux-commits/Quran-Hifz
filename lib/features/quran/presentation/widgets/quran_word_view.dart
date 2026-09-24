import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio/application/audio_providers.dart';
import '../../../settings/application/app_preferences_controller.dart';
import '../../data/bengali_word_meanings.dart';
import '../../domain/quran_font_preference.dart';
import '../../domain/quran_script.dart';
import '../../domain/quran_word.dart';
import '../quran_reading_colors.dart';
import '../quran_text_style.dart';
import 'quran_tajweed_text.dart';

class QuranWordView extends ConsumerStatefulWidget {
  const QuranWordView({
    super.key,
    required this.word,
    this.onTap,
    this.onLongPress,
    this.isActive = false,
    this.playbackAyahKey,
    this.typographyFont,
    this.typographyScript,
    this.typographyFontFamily,
    this.typographyFontPackage,
    this.typographyFontSize,
    this.typographyLineHeight,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 4,
      vertical: 2,
    ),
  });

  final QuranWord word;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isActive;
  final String? playbackAyahKey;

  /// An owning surface can supply its own independent Quran typography.
  final QuranFontPreference? typographyFont;
  final QuranScriptPreference? typographyScript;
  final String? typographyFontFamily;
  final String? typographyFontPackage;
  final double? typographyFontSize;
  final double? typographyLineHeight;
  final EdgeInsetsGeometry contentPadding;

  @override
  ConsumerState<QuranWordView> createState() => _QuranWordViewState();
}

class _QuranWordViewState extends ConsumerState<QuranWordView> {
  final _tooltipKey = GlobalKey<TooltipState>();
  Timer? _tapHighlightTimer;
  bool _tapped = false;
  String? _loadedMeaning;

  @override
  void dispose() {
    _tapHighlightTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _tapped = true);
    _tapHighlightTimer?.cancel();
    _tapHighlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _tapped = false);
    });
    final showMeaning = ref.read(tapToShowBanglaWordMeaningProvider);
    if (showMeaning) _tooltipKey.currentState?.ensureTooltipVisible();
    widget.onTap?.call();
    if (showMeaning &&
        widget.word.banglaMeaning?.trim().isNotEmpty != true &&
        widget.playbackAyahKey != null) {
      unawaited(_loadMeaning());
    }
  }

  Future<void> _loadMeaning() async {
    try {
      final meaning = await ref
          .read(bengaliWordMeaningsProvider)
          .meaningFor(widget.playbackAyahKey!, widget.word.position);
      if (!mounted) return;
      setState(
        () => _loadedMeaning = meaning ?? 'বাংলা অর্থ এখন পাওয়া যাচ্ছে না',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadedMeaning = 'ইন্টারনেট সংযোগে বাংলা অর্থ দেখুন');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tooltipKey.currentState?.ensureTooltipVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final double fontSize =
        widget.typographyFontSize ?? ref.watch(arabicFontSizeProvider);
    final double lineHeight =
        widget.typographyLineHeight ?? ref.watch(arabicLineHeightProvider);
    final QuranFontPreference font =
        widget.typographyFont ?? ref.watch(quranFontProvider);
    final script = widget.typographyScript ?? font.script;
    final highlightEnabled = ref.watch(highlightActiveWordProvider);
    final tajweedEnabled = ref.watch(showTajweedColorsProvider);
    final audioActive = widget.playbackAyahKey == null
        ? false
        : ref.watch(
            isWordPlaybackActiveProvider((
              ayahKey: widget.playbackAyahKey!,
              wordPosition: widget.word.position,
            )),
          );
    if (audioActive && _tapped) {
      _tapHighlightTimer?.cancel();
      _tapped = false;
    }
    final highlighted =
        (_tapped || widget.isActive || audioActive) &&
        (widget.isActive || _tapped || highlightEnabled);
    final arabic = widget.word.arabicFor(script);
    final useTajweed =
        tajweedEnabled &&
        !highlighted &&
        script == QuranScriptPreference.uthmaniMadani &&
        widget.word.arabicTajweedMarkup != null;

    final textStyle = QuranTextStyle.forScript(
      script: script,
      color: highlighted
          ? QuranReadingColors.activeWordFor(context)
          : scheme.onSurface,
      fontSize: fontSize,
      lineHeight: lineHeight,
      font: font,
      fontFamily: widget.typographyFontFamily,
      fontPackage: widget.typographyFontPackage,
    );

    return Semantics(
      button: widget.onTap != null,
      label: widget.word.transliteration ?? arabic,
      hint: widget.onLongPress == null ? null : 'Long press for word details',
      child: Tooltip(
        key: _tooltipKey,
        triggerMode: TooltipTriggerMode.manual,
        message: widget.word.banglaMeaning?.trim().isNotEmpty == true
            ? widget.word.banglaMeaning!
            : _loadedMeaning ?? 'বাংলা অর্থ খোঁজা হচ্ছে…',
        preferBelow: false,
        showDuration: const Duration(seconds: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap == null ? null : _handleTap,
          onLongPress: widget.onLongPress,
          child: Padding(
            padding: widget.contentPadding,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              style: textStyle,
              child: QuranTajweedText(
                plainText: arabic,
                markup: widget.word.arabicTajweedMarkup,
                useTajweedColors: useTajweed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
