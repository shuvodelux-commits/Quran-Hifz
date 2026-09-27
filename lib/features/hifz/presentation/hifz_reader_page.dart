import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/application/audio_providers.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/application/reader_state.dart';
import '../../quran/domain/quran_mushaf_variant.dart';
import '../../quran/domain/quran_page_window.dart';
import '../../quran/domain/quran_surah.dart';
import '../../quran/presentation/mushaf/quran_strict_reader_body.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../application/hifz_session_controller.dart';
import '../domain/hifz_session.dart';
import 'hifz_appearance_sheet.dart';
import 'hifz_controls_bar.dart';

class HifzReaderPage extends ConsumerStatefulWidget {
  const HifzReaderPage({
    required this.config,
    required this.initialPage,
    required this.planTitle,
    super.key,
  });

  final HifzSessionConfig config;
  final int initialPage;
  final String planTitle;

  @override
  ConsumerState<HifzReaderPage> createState() => _HifzReaderPageState();
}

class _HifzReaderPageState extends ConsumerState<HifzReaderPage> {
  ReaderState? _readerState;
  Object? _loadError;
  bool _hidden = false;
  bool _loadingPage = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadInitial());
  }

  Future<void> _loadInitial() async {
    try {
      final repository = ref.read(quranRepositoryProvider);
      final surahs = await repository.listSurahs();
      final surah = _surahFor(surahs, widget.config.start.surahNumber);
      final page = _boundedPage(widget.initialPage, surah);
      final translationId = ref.read(quranTranslationResourceIdProvider);
      final window = await repository.loadPageWindow(
        page: page,
        translationResourceId: translationId,
      );
      if (!mounted) return;
      setState(() {
        _readerState = ReaderState(
          currentPage: page,
          windows: {page: window},
          translationResourceId: translationId,
          firstPage: surah.pageStart,
          lastPage: surah.pageEnd,
        );
        _loadError = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error);
    }
  }

  QuranSurahSummary _surahFor(
    List<QuranSurahSummary> surahs,
    int surahNumber,
  ) {
    for (final surah in surahs) {
      if (surah.number == surahNumber) return surah;
    }
    throw StateError('Selected Hifz Surah is unavailable.');
  }

  int _boundedPage(int page, QuranSurahSummary surah) {
    if (page < surah.pageStart) return surah.pageStart;
    if (page > surah.pageEnd) return surah.pageEnd;
    return page;
  }

  Future<void> _openPage(int page) async {
    final current = _readerState;
    if (current == null ||
        page < current.firstPage ||
        page > current.lastPage ||
        _loadingPage) {
      return;
    }

    final existing = current.windows[page];
    if (existing != null) {
      setState(() => _readerState = current.copyWith(currentPage: page));
      return;
    }

    _loadingPage = true;
    try {
      final window = await ref.read(quranRepositoryProvider).loadPageWindow(
        page: page,
        translationResourceId: current.translationResourceId,
      );
      if (!mounted) return;
      final windows = Map<int, QuranPageWindow>.from(current.windows)
        ..[page] = window;
      setState(() {
        _readerState = current.copyWith(currentPage: page, windows: windows);
      });
    } finally {
      _loadingPage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _readerState;
    final variant = ref.watch(hifzMushafVariantProvider);
    final fontSize = ref.watch(hifzFontSizeProvider);
    final lineHeight = ref.watch(hifzLineHeightProvider);
    final tajweed = ref.watch(hifzShowTajweedColorsProvider);
    final session = ref.watch(hifzSessionControllerProvider);
    final audio = ref.watch(quranAudioControllerProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 54,
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.planTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (state != null)
              Text(
                _pageProgress(state),
                key: const ValueKey('hifz-reader-progress'),
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('hifz-reader-settings'),
            tooltip: 'Hifz appearance',
            onPressed: _showAppearance,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _readerBody(
              state: state,
              variant: variant,
              fontSize: fontSize,
              lineHeight: lineHeight,
              tajweed: tajweed,
              activeAyahKey: audio.ayahKey,
              activeWordPosition: audio.activeWordPosition,
            ),
          ),
          SafeArea(
            top: false,
            child: HifzControlsBar(
              status: session.status,
              repeatIndex: session.stepRepeatIndex,
              repeatTotal: session.stepRepeatTotal,
              hidden: _hidden,
              onPlayPause: _togglePlayback,
              onRepeatPattern: _showRepeatPattern,
              onToggleHidden: () => setState(() => _hidden = !_hidden),
              onFinish: () => unawaited(
                ref.read(hifzSessionControllerProvider.notifier).stop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readerBody({
    required ReaderState? state,
    required QuranMushafVariant variant,
    required double fontSize,
    required double lineHeight,
    required bool tajweed,
    required String? activeAyahKey,
    required int? activeWordPosition,
  }) {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'The Hifz Mushaf could not be opened.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () {
                  setState(() => _loadError = null);
                  unawaited(_loadInitial());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final mushaf = QuranStrictReaderBody(
      key: const ValueKey('hifz-reader-quran'),
      state: state,
      variant: variant,
      fontSize: fontSize,
      lineHeight: lineHeight,
      showTajweedColors: tajweed,
      activeAyahKey: activeAyahKey,
      activeWordPosition: activeWordPosition,
      selectedStartAyahKey: widget.config.start.verseKey,
      selectedEndAyahKey: widget.config.end.verseKey,
      onPageChanged: (page) => unawaited(_openPage(page)),
      onWordTap: (_, __) {},
      onWordLongPress: (_, __) {},
      onAyahTap: (_) {},
    );

    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            excluding: _hidden,
            child: Opacity(opacity: _hidden ? 0 : 1, child: mushaf),
          ),
        ),
        if (_hidden)
          Positioned.fill(
            child: Material(
              key: const ValueKey('hifz-hidden-overlay'),
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Text(
                  'Quran hidden for recall',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _pageProgress(ReaderState state) {
    final current = state.currentPage - state.firstPage + 1;
    final total = state.lastPage - state.firstPage + 1;
    return current.toString() + ' / ' + total.toString();
  }

  void _togglePlayback() {
    final controller = ref.read(hifzSessionControllerProvider.notifier);
    final status = ref.read(hifzSessionControllerProvider).status;
    if (status == HifzSessionStatus.running) {
      unawaited(controller.pause());
      return;
    }
    if (status == HifzSessionStatus.paused) {
      unawaited(controller.resume());
      return;
    }
    unawaited(controller.start(widget.config));
  }

  void _showAppearance() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => const HifzAppearanceSheet(),
    );
  }

  void _showRepeatPattern() {
    final preset = widget.config.preset;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Repeat pattern',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Ayah repetitions: ' + preset.ayahRepeatCount.toString(),
              ),
              Text(
                'Combined repetitions: ' +
                    preset.combinedRepeatCount.toString(),
              ),
              Text(
                'Final range repetitions: ' +
                    preset.finalRangeRepeatCount.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
