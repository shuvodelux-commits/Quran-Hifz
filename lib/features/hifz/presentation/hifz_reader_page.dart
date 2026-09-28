import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/application/audio_providers.dart';
import '../../audio/domain/quran_audio_state.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/application/reader_audio_actions.dart';
import '../../quran/application/reader_state.dart';
import '../../quran/domain/quran_ayah.dart';
import '../../quran/domain/quran_mushaf_variant.dart';
import '../../quran/domain/quran_page_window.dart';
import '../../quran/domain/quran_surah.dart';
import '../../quran/domain/quran_word.dart';
import '../../quran/presentation/mushaf/quran_strict_reader_body.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../study/application/study_providers.dart';
import '../../study/domain/bookmark.dart';
import '../../study/presentation/word_details_sheet.dart';
import '../application/hifz_plan_providers.dart';
import '../application/hifz_session_controller.dart';
import '../application/hifz_start_defaults.dart';
import '../domain/hifz_preset.dart';
import '../domain/hifz_reader_mode.dart';
import '../domain/hifz_session.dart';
import 'hifz_appearance_sheet.dart';
import 'hifz_continuous_reader.dart';
import 'hifz_controls_bar.dart';
import 'hifz_pattern_editor_sheet.dart';
import 'hifz_setup_sheet.dart';
import 'hifz_surah_picker_sheet.dart';

class HifzReaderPage extends ConsumerStatefulWidget {
  const HifzReaderPage({
    required this.config,
    required this.initialPage,
    required this.planTitle,
    this.planId,
    super.key,
  });

  final HifzSessionConfig config;
  final int initialPage;
  final String planTitle;
  final int? planId;

  @override
  ConsumerState<HifzReaderPage> createState() => _HifzReaderPageState();
}

class _HifzReaderPageState extends ConsumerState<HifzReaderPage> {
  ReaderState? _readerState;
  Object? _loadError;
  bool _hidden = false;
  final Set<int> _loadingPages = <int>{};
  String? _activeWordBanglaMeaning;
  int? _playbackPage;
  int _audioSyncToken = 0;
  late HifzSessionConfig _config;
  late String _planTitle;
  late int _initialPage;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
    _planTitle = widget.planTitle;
    _initialPage = widget.initialPage;
    unawaited(_loadInitial());
  }

  Future<void> _loadInitial() async {
    try {
      final repository = ref.read(quranRepositoryProvider);
      final surahs = await repository.listSurahs();
      final surah = _surahFor(surahs, _config.start.surahNumber);
      final page = _boundedPage(_initialPage, surah);
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
      unawaited(
        _syncPlaybackTarget(ref.read(quranAudioControllerProvider)),
      );
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

  Future<void> _openPage(int page) =>
      _ensurePageWindow(page, makeCurrent: true);

  Future<void> _ensurePageWindow(
    int page, {
    required bool makeCurrent,
  }) async {
    final current = _readerState;
    if (current == null ||
        page < current.firstPage ||
        page > current.lastPage) {
      return;
    }

    if (current.windows.containsKey(page)) {
      if (makeCurrent && current.currentPage != page && mounted) {
        setState(() => _readerState = current.copyWith(currentPage: page));
      }
      return;
    }
    if (!_loadingPages.add(page)) return;

    try {
      final window = await ref.read(quranRepositoryProvider).loadPageWindow(
        page: page,
        translationResourceId: current.translationResourceId,
      );
      if (!mounted) return;
      final latest = _readerState;
      if (latest == null ||
          page < latest.firstPage ||
          page > latest.lastPage) {
        return;
      }
      final windows = Map<int, QuranPageWindow>.from(latest.windows)
        ..[page] = window;
      setState(() {
        _readerState = latest.copyWith(
          currentPage: makeCurrent ? page : latest.currentPage,
          windows: windows,
        );
      });
    } finally {
      _loadingPages.remove(page);
    }
  }

  void _setContinuousCurrentPage(int page) {
    final current = _readerState;
    if (current == null ||
        page < current.firstPage ||
        page > current.lastPage ||
        page == current.currentPage) {
      return;
    }
    setState(() => _readerState = current.copyWith(currentPage: page));
  }

  @override
  Widget build(BuildContext context) {
    final state = _readerState;
    final variant = ref.watch(hifzMushafVariantProvider);
    final fontSize = ref.watch(hifzFontSizeProvider);
    final lineHeight = ref.watch(hifzLineHeightProvider);
    final tajweed = ref.watch(hifzShowTajweedColorsProvider);
    final readerMode = ref.watch(hifzReaderModeProvider);
    final continuousAutoScrollEnabled = ref.watch(
      hifzContinuousAutoScrollEnabledProvider,
    );
    final autoScrollSpeed = ref.watch(hifzAutoScrollSpeedProvider);
    final showPlaybackMeaning = ref.watch(
      showPlaybackBanglaWordMeaningProvider,
    );
    final session = ref.watch(hifzSessionControllerProvider);
    final audio = ref.watch(quranAudioControllerProvider);

    ref.listen<QuranAudioState>(quranAudioControllerProvider, (previous, next) {
      if (_audioTargetSignature(previous) != _audioTargetSignature(next)) {
        unawaited(_syncPlaybackTarget(next));
      }
      if (readerMode == HifzReaderMode.page &&
          !_isAudioRunning(previous) &&
          _isAudioRunning(next) &&
          ref.read(hifzContinuousAutoScrollEnabledProvider)) {
        unawaited(
          ref
              .read(appPreferencesControllerProvider.notifier)
              .setHifzContinuousAutoScrollEnabled(false),
        );
      }
    });

    final audioVisible =
        (audio.status == QuranAudioStatus.loading ||
            audio.status == QuranAudioStatus.playing ||
            audio.status == QuranAudioStatus.paused) &&
        (audio.mode == QuranAudioMode.ayah || audio.mode == QuranAudioMode.word);
    final activeAyahKey = audioVisible ? audio.ayahKey : null;
    final activeWordPosition = audioVisible ? audio.activeWordPosition : null;
    final audioPlaying =
        audio.status == QuranAudioStatus.loading ||
        audio.status == QuranAudioStatus.playing;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 54,
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _planTitle,
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
            key: const ValueKey('hifz-reader-surah'),
            tooltip: 'Change Surah',
            onPressed: () => unawaited(_changeSurah()),
            icon: const Icon(Icons.menu_book_outlined),
          ),
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
              readerMode: readerMode,
              continuousAutoScrollEnabled: continuousAutoScrollEnabled,
              autoScrollSpeed: autoScrollSpeed,
              audioPlaying: audioPlaying,
              activeAyahKey: activeAyahKey,
              activeWordPosition: activeWordPosition,
              activeWordBanglaMeaning: showPlaybackMeaning
                  ? _activeWordBanglaMeaning
                  : null,
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
              onRepeatPattern: () => unawaited(_showRepeatPattern()),
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
    required HifzReaderMode readerMode,
    required bool continuousAutoScrollEnabled,
    required double autoScrollSpeed,
    required bool audioPlaying,
    required String? activeAyahKey,
    required int? activeWordPosition,
    required String? activeWordBanglaMeaning,
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

    final Widget mushaf = readerMode == HifzReaderMode.page
        ? QuranStrictReaderBody(
            key: const ValueKey('hifz-reader-quran'),
            state: state,
            variant: variant,
            fontSize: fontSize,
            lineHeight: lineHeight,
            showTajweedColors: tajweed,
            activeAyahKey: activeAyahKey,
            activeWordPosition: activeWordPosition,
            activeWordBanglaMeaning: activeWordBanglaMeaning,
            selectedStartAyahKey: _config.start.verseKey,
            selectedEndAyahKey: _config.end.verseKey,
            onPageChanged: (page) => unawaited(_openPage(page)),
            onWordTap: (ayahKey, wordPosition) =>
                unawaited(_playMushafWord(ayahKey, wordPosition)),
            onWordLongPress: (ayahKey, wordPosition) =>
                unawaited(_showMushafWordDetails(ayahKey, wordPosition)),
            onAyahTap: (_) {},
          )
        : HifzContinuousReader(
            key: const ValueKey('hifz-reader-quran'),
            state: state,
            variant: variant,
            fontSize: fontSize,
            lineHeight: lineHeight,
            showTajweedColors: tajweed,
            activeAyahKey: activeAyahKey,
            activeWordPosition: activeWordPosition,
            activeWordBanglaMeaning: activeWordBanglaMeaning,
            selectedStartAyahKey: _config.start.verseKey,
            selectedEndAyahKey: _config.end.verseKey,
            playbackPage: _playbackPage,
            autoScrollEnabled: continuousAutoScrollEnabled,
            autoScrollSpeed: autoScrollSpeed,
            audioPlaying: audioPlaying,
            onDisableAutoScroll: () => unawaited(
              ref
                  .read(appPreferencesControllerProvider.notifier)
                  .setHifzContinuousAutoScrollEnabled(false),
            ),
            onPageNeeded: (page) =>
                unawaited(_ensurePageWindow(page, makeCurrent: false)),
            onCurrentPageChanged: _setContinuousCurrentPage,
            onWordTap: (ayahKey, wordPosition) =>
                unawaited(_playMushafWord(ayahKey, wordPosition)),
            onWordLongPress: (ayahKey, wordPosition) =>
                unawaited(_showMushafWordDetails(ayahKey, wordPosition)),
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

  Future<void> _playMushafWord(
    String ayahKey,
    int wordPosition,
  ) async {
    final target = await _resolveMushafWord(ayahKey, wordPosition);
    if (target == null) return;
    try {
      await ref.read(readerAudioActionsProvider).playWord(
            target.ayah,
            target.word,
          );
    } on ReaderAudioUnavailableException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object catch (error, stackTrace) {
      debugPrint('Hifz word audio failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) _showMessage('Word pronunciation could not be played.');
    }
  }

  bool _isAudioRunning(QuranAudioState? audio) {
    if (audio == null) return false;
    return audio.status == QuranAudioStatus.loading ||
        audio.status == QuranAudioStatus.playing;
  }

  String _audioTargetSignature(QuranAudioState? audio) {
    if (audio == null) return 'none';
    return [
      audio.mode.name,
      audio.status.name,
      audio.ayahKey ?? '',
      audio.activeWordPosition?.toString() ?? '',
    ].join('|');
  }

  Future<void> _syncPlaybackTarget(QuranAudioState audio) async {
    final token = ++_audioSyncToken;
    final active =
        (audio.status == QuranAudioStatus.loading ||
            audio.status == QuranAudioStatus.playing ||
            audio.status == QuranAudioStatus.paused) &&
        (audio.mode == QuranAudioMode.ayah || audio.mode == QuranAudioMode.word);
    final ayahKey = active ? audio.ayahKey : null;
    if (ayahKey == null) {
      if (mounted) {
        setState(() {
          _activeWordBanglaMeaning = null;
          _playbackPage = null;
        });
      }
      return;
    }

    final parts = ayahKey.split(':');
    if (parts.length != 2) return;
    final surahNumber = int.tryParse(parts[0]);
    final ayahNumber = int.tryParse(parts[1]);
    if (surahNumber == null || ayahNumber == null) return;

    final ayah = await ref.read(quranRepositoryProvider).loadAyah(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          translationResourceId: ref.read(quranTranslationResourceIdProvider),
        );
    if (!mounted || token != _audioSyncToken || ayah == null) return;

    String? meaning;
    final wordPosition = audio.activeWordPosition;
    if (wordPosition != null) {
      for (final word in ayah.words) {
        if (word.position == wordPosition) {
          final candidate = word.banglaMeaning?.trim();
          if (candidate != null && candidate.isNotEmpty) {
            meaning = candidate;
          }
          break;
        }
      }
    }

    int? playbackPage;
    if (audio.mode == QuranAudioMode.ayah) {
      playbackPage = ayah.pageNumber;
      if (ref.read(hifzReaderModeProvider) == HifzReaderMode.page) {
        await _ensurePageWindow(playbackPage, makeCurrent: true);
      } else {
        await _ensurePageWindow(playbackPage, makeCurrent: false);
      }
      if (!mounted || token != _audioSyncToken) return;
    }

    setState(() {
      _activeWordBanglaMeaning = meaning;
      _playbackPage = playbackPage;
    });
  }

  Future<void> _showMushafWordDetails(
    String ayahKey,
    int wordPosition,
  ) async {
    final target = await _resolveMushafWord(ayahKey, wordPosition);
    if (!mounted || target == null) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => WordDetailsSheet(
        target: StudyTarget.word(
          surahNumber: target.ayah.surahNumber,
          ayahNumber: target.ayah.ayahNumber,
          wordPosition: target.word.position,
        ),
        word: target.word,
        controller: ref.read(studyControllerProvider),
      ),
    );
  }

  Future<({QuranAyah ayah, QuranWord word})?> _resolveMushafWord(
    String ayahKey,
    int wordPosition,
  ) async {
    final parts = ayahKey.split(':');
    if (parts.length != 2 || wordPosition < 1) return null;
    final surahNumber = int.tryParse(parts[0]);
    final ayahNumber = int.tryParse(parts[1]);
    if (surahNumber == null || ayahNumber == null) return null;

    final ayah = await ref.read(quranRepositoryProvider).loadAyah(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          translationResourceId: ref.read(quranTranslationResourceIdProvider),
        );
    if (ayah == null) return null;
    for (final word in ayah.words) {
      if (word.position == wordPosition) {
        return (ayah: ayah, word: word);
      }
    }
    return null;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
    unawaited(controller.start(_config));
  }

  Future<void> _changeSurah() async {
    final repository = ref.read(quranRepositoryProvider);
    try {
      final surahs = await repository.listSurahs();
      if (!mounted) return;
      final selected = await showModalBottomSheet<QuranSurahSummary>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => HifzSurahPickerSheet(
          surahs: surahs,
          selectedSurahNumber: _config.start.surahNumber,
        ),
      );
      if (!mounted || selected == null) return;

      var progress = await ref
          .read(hifzRepositoryProvider)
          .loadSurahProgress(
            profileKey: HifzSessionController.defaultProfileKey,
            surahNumber: selected.number,
          );
      if (!mounted) return;
      final defaults = HifzStartDefaults.forSurah(
        surah: selected,
        progress: progress,
      );
      final setup = await showModalBottomSheet<HifzSetupResult>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => HifzSetupSheet(
          surah: selected,
          initialStartAyah: defaults.startAyah,
          initialEndAyah: defaults.endAyah,
          initialPreset: _config.preset,
        ),
      );
      if (!mounted || setup == null) return;

      final ayah = await repository.loadAyah(
        surahNumber: selected.number,
        ayahNumber: setup.startAyah,
        translationResourceId: ref.read(quranTranslationResourceIdProvider),
      );
      if (!mounted || ayah == null) {
        if (mounted) _showSurahChangeError();
        return;
      }

      await ref.read(hifzSessionControllerProvider.notifier).stop();
      if (!mounted) return;
      setState(() {
        _config = HifzSessionConfig(
          start: AyahRef(
            surahNumber: selected.number,
            ayahNumber: setup.startAyah,
          ),
          end: AyahRef(
            surahNumber: selected.number,
            ayahNumber: setup.endAyah,
          ),
          preset: setup.preset,
        );
        _planTitle =
            selected.nameEnglish +
            ' ' +
            setup.startAyah.toString() +
            '–' +
            setup.endAyah.toString();
        _initialPage = ayah.pageNumber;
        _readerState = null;
        _loadError = null;
      });
      unawaited(_loadInitial());
    } on Object {
      if (mounted) _showSurahChangeError();
    }
  }

  void _showSurahChangeError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not change the Hifz Surah. Please try again.'),
      ),
    );
  }

  void _showAppearance() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => const HifzAppearanceSheet(),
    );
  }

  Future<void> _showRepeatPattern() async {
    final selected = await showModalBottomSheet<HifzPreset>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => HifzPatternEditorSheet(initialPreset: _config.preset),
    );
    if (!mounted || selected == null || selected.id == _config.preset.id) {
      return;
    }

    final session = ref.read(hifzSessionControllerProvider);
    if (session.status == HifzSessionStatus.running ||
        session.status == HifzSessionStatus.paused) {
      await ref.read(hifzSessionControllerProvider.notifier).stop();
      if (!mounted) return;
    }

    final planId = widget.planId;
    if (planId != null) {
      try {
        await ref.read(hifzPlanRepositoryProvider).updatePreset(planId, selected);
      } on Object {
        if (mounted) _showMessage('Could not save the repeat pattern.');
        return;
      }
      if (!mounted) return;
    }

    setState(() {
      _config = HifzSessionConfig(
        start: _config.start,
        end: _config.end,
        preset: selected,
      );
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Repeat pattern updated. Press Play to use it.'),
        ),
      );
  }
}
