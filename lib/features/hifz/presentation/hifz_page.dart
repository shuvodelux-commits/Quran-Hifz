import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/application/audio_providers.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/application/reader_audio_actions.dart';
import '../../quran/domain/quran_ayah.dart';
import '../../quran/domain/quran_page_window.dart';
import '../../quran/domain/quran_surah.dart';
import '../../quran/domain/quran_word.dart';
import '../../reciters/application/reciter_catalog_controller.dart';
import '../../study/application/study_providers.dart';
import '../../study/domain/bookmark.dart';
import '../../study/presentation/word_details_sheet.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/hifz_mushaf_controller.dart';
import '../application/hifz_mushaf_providers.dart';
import '../application/hifz_session_controller.dart';
import '../domain/hifz_reading_mode.dart';
import '../domain/hifz_session.dart';
import 'hifz_active_player.dart';
import 'hifz_appearance_sheet.dart';
import 'hifz_mushaf_appearance_sheet.dart';
import 'hifz_mushaf_page_view.dart';
import 'hifz_mushaf_surface.dart';
import 'hifz_pattern_controls.dart';
import 'hifz_reading_mode_selector.dart';
import 'hifz_setup_sheet.dart';
import 'hifz_system_ui.dart';

class HifzPage extends ConsumerStatefulWidget {
  const HifzPage({
    super.key,
    this.initialPage = 1,
    this.initialSurahNumber,
    this.initialConfig,
    this.openSetupOnStart = false,
  }) : assert(initialPage >= 1 && initialPage <= 604),
       assert(
         initialSurahNumber == null ||
             (initialSurahNumber >= 1 && initialSurahNumber <= 114),
       );

  final int initialPage;
  final int? initialSurahNumber;
  final HifzSessionConfig? initialConfig;
  final bool openSetupOnStart;

  @override
  ConsumerState<HifzPage> createState() => _HifzPageState();
}

class _HifzPageState extends ConsumerState<HifzPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final HifzSystemUi _systemUi;
  final ScrollController _mushafScrollController = ScrollController();
  bool _controlsVisible = true;
  int _selectedSurahNumber = 1;
  late int _selectedPage;
  AyahRef? _rangeStartAyah;
  AyahRef? _rangeEndAyah;
  final Map<int, QuranPageWindow> _loadedPages = {};
  final Map<int, GlobalKey> _pageKeys = {};
  bool _initialPageLoading = true;
  Object? _pageLoadError;
  bool _loadingNextPage = false;
  bool _loadingPreviousPage = false;
  late final Ticker _autoScrollTicker;
  Duration? _lastAutoScrollElapsed;
  bool _readerPointerDown = false;
  bool _sheetOpen = false;
  bool _appActive = true;
  bool _initialSetupScheduled = false;
  bool _mushafInitialOpenScheduled = false;
  int? _pendingPageJump;
  String? _lastFollowedAyahKey;
  HifzPatternSelection _pattern = const HifzPatternSelection(
    ayahRepeatCount: 5,
    combinedRepeatCount: 3,
    finalRangeRepeatCount: 3,
  );

  @override
  void initState() {
    super.initState();
    _systemUi = ref.read(hifzSystemUiProvider);
    _selectedPage = widget.initialPage;
    _selectedSurahNumber = widget.initialSurahNumber ?? 1;
    final initialConfig = widget.initialConfig;
    if (initialConfig != null) {
      _selectedSurahNumber = initialConfig.start.surahNumber;
      _rangeStartAyah = initialConfig.start;
      _rangeEndAyah = initialConfig.end;
      _pattern = HifzPatternSelection.fromPreset(initialConfig.preset);
    }
    WidgetsBinding.instance.addObserver(this);
    _autoScrollTicker = createTicker(_onAutoScrollTick);
    unawaited(_loadAround(_selectedPage));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_systemUi.enter());
    });
  }

  Widget _buildContinuousReader(
    List<QuranSurahSummary> surahs, {
    required bool playing,
    required String? activeAyahKey,
  }) {
    if (_initialPageLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pageLoadError != null || _loadedPages.isEmpty) {
      return Center(
        child: FilledButton(
          onPressed: _reloadPage,
          child: const Text('Retry page'),
        ),
      );
    }

    final pages = _loadedPages.keys.toList()..sort();
    _pageKeys.removeWhere((page, _) => !pages.contains(page));
    for (final page in pages) {
      _pageKeys.putIfAbsent(page, GlobalKey.new);
    }

    return Listener(
      onPointerDown: (_) {
        _readerPointerDown = true;
        _lastAutoScrollElapsed = null;
      },
      onPointerUp: (_) => _readerPointerDown = false,
      onPointerCancel: (_) => _readerPointerDown = false,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleContinuousScroll,
        child: CustomScrollView(
          key: const PageStorageKey('hifz-continuous-reader'),
          controller: _mushafScrollController,
          slivers: [
            if (_loadingPreviousPage)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            for (final page in pages)
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _pageKeys[page],
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: HifzMushafSurface(
                      key: ValueKey('hifz-mushaf-$page'),
                      surah: _surahForWindow(surahs, _loadedPages[page]!),
                      surahs: surahs,
                      window: _loadedPages[page]!,
                      embeddedInScroll: true,
                      showAllPageSurahs: true,
                      selectedStartAyah: _rangeStartAyah,
                      selectedEndAyah: _rangeEndAyah,
                      activeAyahKey: playing ? activeAyahKey : null,
                      onAyahSelected: playing ? null : _selectRangeAyah,
                      onWordTap: (ayah, word) =>
                          unawaited(_playWord(ayah, word)),
                      onWordLongPress: _showWordDetails,
                    ),
                  ),
                ),
              ),
            if (_loadingNextPage)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 72)),
          ],
        ),
      ),
    );
  }

  QuranSurahSummary _surahForWindow(
    List<QuranSurahSummary> surahs,
    QuranPageWindow window,
  ) {
    final number = window.ayahs.isEmpty
        ? _selectedSurahNumber
        : window.ayahs.first.surahNumber;
    return _findSurah(surahs, number);
  }

  @override
  void dispose() {
    unawaited(_systemUi.restore());
    WidgetsBinding.instance.removeObserver(this);
    _autoScrollTicker.dispose();
    _mushafScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    if (!_appActive) _lastAutoScrollElapsed = null;
  }

  @override
  Widget build(BuildContext context) {
    final surahs = ref.watch(quranSurahListProvider);
    final session = ref.watch(hifzSessionControllerProvider);
    final activeAyahKey = ref.watch(activeAyahPlaybackKeyProvider);
    final audio = ref.watch(quranAudioControllerProvider);
    final autoScrollEnabled = ref.watch(hifzAutoScrollEnabledProvider);
    final readingMode = ref.watch(hifzReadingModeProvider);
    final mushafController = ref.watch(hifzMushafControllerProvider);
    final mushafState =
        ref.watch(hifzMushafStateProvider).asData?.value ??
        mushafController.state;
    final continuousAutoScroll =
        autoScrollEnabled && readingMode == HifzReadingMode.regular;
    if (continuousAutoScroll && !_autoScrollTicker.isActive) {
      _autoScrollTicker.start();
    } else if (!continuousAutoScroll && _autoScrollTicker.isActive) {
      _autoScrollTicker.stop();
      _lastAutoScrollElapsed = null;
    }

    ref.listen<String?>(activeAyahPlaybackKeyProvider, (previous, next) {
      if (next == null || next == previous) return;
      if (ref.read(hifzReadingModeProvider) == HifzReadingMode.regular) {
        unawaited(_followActiveAyah(next));
      }
    });
    ref.listen<HifzSessionState>(hifzSessionControllerProvider, (
      previous,
      next,
    ) {
      final config = next.config;
      if (config == null || identical(previous?.config, config)) return;
      unawaited(_alignToSession(config));
    });
    ref.listen<HifzReadingMode>(hifzReadingModeProvider, (previous, next) {
      if (next == HifzReadingMode.mushaf) {
        _mushafInitialOpenScheduled = true;
        unawaited(mushafController.openPage(_selectedPage));
        return;
      }

      _mushafInitialOpenScheduled = false;
      final page = mushafController.currentPage ?? _selectedPage;
      if (_selectedPage != page && mounted) {
        setState(() => _selectedPage = page);
      }
      unawaited(_jumpToPage(page));
    });
    ref.listen<QuranMushafVariant>(hifzMushafVariantProvider, (previous, next) {
      if (next != mushafController.variant) {
        unawaited(mushafController.selectVariant(next));
      }
    });
    ref.listen<HifzMushafPalette>(hifzMushafPaletteProvider, (previous, next) {
      if (next != mushafController.palette &&
          next.supports(mushafController.variant)) {
        unawaited(mushafController.setPalette(next));
      }
    });
    ref.listen<AsyncValue<HifzMushafState>>(hifzMushafStateProvider, (
      previous,
      next,
    ) {
      if (ref.read(hifzReadingModeProvider) != HifzReadingMode.mushaf) return;
      final state = next.asData?.value;
      if (state is! HifzMushafReady) return;
      final surahNumber =
          _surahNumberForMushafState(state) ?? _selectedSurahNumber;
      if (state.page.page == _selectedPage &&
          surahNumber == _selectedSurahNumber) {
        return;
      }
      if (!mounted) return;
      setState(() {
        _selectedPage = state.page.page;
        _selectedSurahNumber = surahNumber;
      });
    });

    if (readingMode == HifzReadingMode.mushaf && !_mushafInitialOpenScheduled) {
      _mushafInitialOpenScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            ref.read(hifzReadingModeProvider) != HifzReadingMode.mushaf) {
          return;
        }
        unawaited(
          ref.read(hifzMushafControllerProvider).openPage(_selectedPage),
        );
      });
    } else if (readingMode == HifzReadingMode.regular) {
      _mushafInitialOpenScheduled = false;
    }

    return surahs.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(quranSurahListProvider),
            child: const Text('Retry Quran library'),
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Quran library is unavailable.')),
          );
        }
        final readyMushaf = mushafState is HifzMushafReady ? mushafState : null;
        final visiblePage = readingMode == HifzReadingMode.mushaf
            ? readyMushaf?.page.page ??
                  mushafController.currentPage ??
                  _selectedPage
            : _selectedPage;
        final visibleSurahNumber = readingMode == HifzReadingMode.mushaf
            ? _surahNumberForMushafState(readyMushaf) ?? _selectedSurahNumber
            : _selectedSurahNumber;
        final selectedSurah = _findSurah(items, visibleSurahNumber);
        if (widget.openSetupOnStart &&
            widget.initialConfig != null &&
            !_initialSetupScheduled) {
          _initialSetupScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) unawaited(_openSetupSheet(selectedSurah));
          });
        }
        final playing =
            session.status == HifzSessionStatus.running ||
            session.status == HifzSessionStatus.paused;
        final reader = switch (readingMode) {
          HifzReadingMode.regular => _buildContinuousReader(
            items,
            playing: playing,
            activeAyahKey: activeAyahKey,
          ),
          HifzReadingMode.mushaf => HifzMushafPageView(
            controller: mushafController,
            activeAyahKey: activeAyahKey,
            activeWordPosition: activeAyahKey == null
                ? null
                : audio.activeWordPosition,
            playbackRunning: playing,
            autoFollow: autoScrollEnabled,
            selectedStartAyah: _rangeStartAyah,
            selectedEndAyah: _rangeEndAyah,
            onWordTap: (ayahKey, position) =>
                unawaited(_playMushafWord(ayahKey, position)),
            onWordLongPress: (ayahKey, position) =>
                unawaited(_showMushafWordDetails(ayahKey, position)),
            onAyahSelected: _selectRangeAyah,
            onToggleControls: () {},
            onUseRegularHifz: () => unawaited(
              ref
                  .read(appPreferencesControllerProvider.notifier)
                  .setHifzReadingMode(HifzReadingMode.regular),
            ),
          ),
        };

        return Scaffold(
          body: Column(
            children: [
              if (readingMode == HifzReadingMode.regular)
                Visibility(
                  key: const ValueKey('hifz-top-controls-visibility'),
                  visible: _controlsVisible,
                  maintainAnimation: true,
                  maintainState: true,
                  maintainSize: true,
                  child: Material(
                    key: const ValueKey('hifz-top-controls'),
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 2,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                key: const ValueKey('hifz-close'),
                                tooltip: 'Close Hifz',
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                icon: const Icon(Icons.close_rounded),
                              ),
                              const Expanded(
                                child: Text(
                                  'Hifz',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Hifz settings',
                                onPressed: _openSettings,
                                icon: const Icon(Icons.settings_outlined),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(12, 0, 12, 6),
                            child: HifzReadingModeSelector(),
                          ),
                          if (!playing)
                            _CompactSurahSelector(
                              surah: selectedSurah,
                              page: visiblePage,
                              onTap: () =>
                                  _showSurahPicker(items, selectedSurah),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: GestureDetector(
                  key: const ValueKey('hifz-reading-gesture'),
                  behavior: HitTestBehavior.translucent,
                  onTap: readingMode == HifzReadingMode.regular
                      ? (_controlsVisible ? _hideControls : _showControls)
                      : null,
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 840),
                        child: reader,
                      ),
                    ),
                  ),
                ),
              ),
              if (readingMode == HifzReadingMode.regular)
                Visibility(
                  key: const ValueKey('hifz-bottom-controls-visibility'),
                  visible: _controlsVisible,
                  maintainAnimation: true,
                  maintainState: true,
                  maintainSize: true,
                  child: Material(
                    key: const ValueKey('hifz-bottom-controls'),
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 4,
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (playing)
                            HifzActivePlayer(
                              surah: selectedSurah,
                              session: session,
                              audio: audio,
                              onPause: () => unawaited(
                                ref
                                    .read(
                                      hifzSessionControllerProvider.notifier,
                                    )
                                    .pause(),
                              ),
                              onResume: () => unawaited(
                                ref
                                    .read(
                                      hifzSessionControllerProvider.notifier,
                                    )
                                    .resume(),
                              ),
                              onStop: () => unawaited(
                                ref
                                    .read(
                                      hifzSessionControllerProvider.notifier,
                                    )
                                    .stop(),
                              ),
                            ),
                          _HifzPageControls(
                            page: visiblePage,
                            showTools: !playing,
                            onPrevious: visiblePage > 1
                                ? () => _turnPage(visiblePage - 1)
                                : null,
                            onTools: playing
                                ? null
                                : () => _openSetupSheet(selectedSurah),
                            onNext: visiblePage < 604
                                ? () => _turnPage(visiblePage + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _hideControls() {
    if (!_controlsVisible) return;
    setState(() => _controlsVisible = false);
  }

  void _showControls() {
    if (_controlsVisible) return;
    setState(() => _controlsVisible = true);
  }

  bool _handleContinuousScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification ||
        notification is ScrollEndNotification) {
      _syncVisiblePage();
    }
    final metrics = notification.metrics;
    if (metrics.extentAfter < 900 || metrics.extentBefore < 900) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (metrics.extentAfter < 900) unawaited(_loadNextPage());
        if (metrics.extentBefore < 900) unawaited(_loadPreviousPage());
      });
    }
    return false;
  }

  void _syncVisiblePage() {
    if (_pendingPageJump != null) return;
    int? visiblePage;
    for (final page in (_pageKeys.keys.toList()..sort())) {
      final render = _pageKeys[page]?.currentContext?.findRenderObject();
      if (render == null || !render.attached) continue;
      final y = MatrixUtils.transformPoint(
        render.getTransformTo(null),
        Offset.zero,
      ).dy;
      if (y <= 260) visiblePage = page;
    }
    visiblePage ??= _pageKeys.keys.isEmpty ? null : _pageKeys.keys.first;
    if (visiblePage == null || visiblePage == _selectedPage) return;
    final window = _loadedPages[visiblePage];
    if (window == null) return;
    setState(() {
      _selectedPage = visiblePage!;
      if (window.ayahs.isNotEmpty) {
        _selectedSurahNumber = window.ayahs.first.surahNumber;
      }
    });
  }

  void _openSettings() {
    final readingMode = ref.read(hifzReadingModeProvider);
    unawaited(
      _pauseWhileSheet<void>(
        () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => readingMode == HifzReadingMode.mushaf
              ? const HifzMushafAppearanceSheet()
              : const HifzAppearanceSheet(),
        ),
      ),
    );
  }

  Future<T?> _pauseWhileSheet<T>(Future<T?> Function() show) async {
    _sheetOpen = true;
    _lastAutoScrollElapsed = null;
    try {
      return await show();
    } finally {
      _sheetOpen = false;
      _lastAutoScrollElapsed = null;
    }
  }

  Future<void> _showSurahPicker(
    List<QuranSurahSummary> surahs,
    QuranSurahSummary selected,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SizedBox(
              height: MediaQuery.sizeOf(sheetContext).height * 0.7,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Choose Surah',
                            style: Theme.of(sheetContext).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Previous Mushaf page',
                          onPressed: _selectedPage > selected.pageStart
                              ? () {
                                  _turnPage(_selectedPage - 1);
                                  Navigator.of(sheetContext).pop();
                                }
                              : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                        Text('Page $_selectedPage'),
                        IconButton(
                          tooltip: 'Next Mushaf page',
                          onPressed: _selectedPage < selected.pageEnd
                              ? () {
                                  _turnPage(_selectedPage + 1);
                                  Navigator.of(sheetContext).pop();
                                }
                              : null,
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: surahs.length,
                      itemBuilder: (context, index) {
                        final surah = surahs[index];
                        return ListTile(
                          key: ValueKey('hifz-surah-choice-${surah.number}'),
                          selected: surah.number == selected.number,
                          title: Text('${surah.number}. ${surah.nameEnglish}'),
                          subtitle: Text(surah.nameArabic),
                          trailing: surah.number == selected.number
                              ? const Icon(Icons.check_rounded)
                              : null,
                          onTap: () {
                            _selectSurah(surah);
                            Navigator.of(sheetContext).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSetupSheet(QuranSurahSummary surah) {
    return _pauseWhileSheet<void>(
      () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, refreshSheet) => Consumer(
            builder: (context, ref, _) {
              final reciterSelected =
                  ref
                      .watch(reciterCatalogControllerProvider)
                      .value
                      ?.selectedReciterId !=
                  null;
              final sessionStatus = ref
                  .watch(hifzSessionControllerProvider)
                  .status;
              return HifzSetupSheet(
                surah: surah,
                startAyah: _rangeStartAyah?.ayahNumber,
                endAyah: _rangeEndAyah?.ayahNumber,
                pattern: _pattern,
                reciterSelected: reciterSelected,
                onStartRange: () =>
                    unawaited(_pickRangeStart(surah, refreshSheet)),
                onEndRange: _rangeStartAyah == null
                    ? null
                    : () => unawaited(_pickRangeEnd(surah, refreshSheet)),
                onPattern: () => unawaited(_pickPattern(surah, refreshSheet)),
                onAdvancedSettings: () {
                  Navigator.of(sheetContext).pop();
                  _openSettings();
                },
                onPlay: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_beginPlayback());
                },
                onClose: () => Navigator.of(sheetContext).pop(),
                onResumeSaved:
                    sessionStatus == HifzSessionStatus.stopped ||
                        sessionStatus == HifzSessionStatus.error
                    ? () {
                        Navigator.of(sheetContext).pop();
                        unawaited(_resumeSaved());
                      }
                    : null,
              );
            },
          ),
        ),
      ),
    ).then((_) {});
  }

  Future<void> _pickRangeStart(
    QuranSurahSummary surah,
    StateSetter refreshSheet,
  ) async {
    final ayah = await _pickAyah(
      title: 'Start Range',
      minimum: 1,
      maximum: surah.ayahCount,
      selected: _rangeStartAyah?.ayahNumber,
    );
    if (!mounted || ayah == null) return;
    await _setRangeStart(ayah);
    if (mounted) refreshSheet(() {});
  }

  Future<void> _pickRangeEnd(
    QuranSurahSummary surah,
    StateSetter refreshSheet,
  ) async {
    final start = _rangeStartAyah;
    if (start == null) return;
    final ayah = await _pickAyah(
      title: 'End Range',
      minimum: start.ayahNumber,
      maximum: surah.ayahCount,
      selected: _rangeEndAyah?.ayahNumber,
    );
    if (!mounted || ayah == null) return;
    await _setRangeEnd(ayah);
    if (mounted) refreshSheet(() {});
  }

  Future<int?> _pickAyah({
    required String title,
    required int minimum,
    required int maximum,
    required int? selected,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => HifzAyahPickerSheet(
        title: title,
        minimum: minimum,
        maximum: maximum,
        selected: selected,
      ),
    );
  }

  Future<void> _pickPattern(
    QuranSurahSummary surah,
    StateSetter refreshSheet,
  ) async {
    final result = await showModalBottomSheet<HifzPatternSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => HifzPatternSheet(
        surahNumber: surah.number,
        startAyah: _rangeStartAyah?.ayahNumber ?? 1,
        endAyah: _rangeEndAyah?.ayahNumber ?? _rangeStartAyah?.ayahNumber ?? 1,
        initialSelection: _pattern,
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _pattern = result);
    refreshSheet(() {});
  }

  Future<void> _beginPlayback() async {
    final start = _rangeStartAyah;
    if (start == null) return;
    if (ref.read(reciterCatalogControllerProvider).value?.selectedReciterId ==
        null) {
      _showMessage('Choose a reciter in Advanced Settings before playing.');
      return;
    }
    await _startSession(
      HifzSessionConfig(
        start: start,
        end: _rangeEndAyah ?? start,
        preset: _pattern.toPreset(),
      ),
    );
  }

  Future<QuranPageWindow> _loadPage(int page) {
    return ref
        .read(quranRepositoryProvider)
        .loadPageWindow(
          page: page,
          translationResourceId: ref.read(quranTranslationResourceIdProvider),
        );
  }

  Future<void> _loadAround(int page, {bool jumpToPage = true}) async {
    final bounded = page.clamp(1, 604).toInt();
    if (mounted) {
      setState(() {
        _initialPageLoading = true;
        _pageLoadError = null;
      });
    }
    try {
      final candidates = <int>{
        if (bounded > 1) bounded - 1,
        bounded,
        if (bounded < 604) bounded + 1,
      }.toList()..sort();
      final windows = await Future.wait(candidates.map(_loadPage));
      if (!mounted) return;
      setState(() {
        _loadedPages
          ..clear()
          ..addEntries(windows.map((window) => MapEntry(window.page, window)));
        _initialPageLoading = false;
        _pageLoadError = null;
        _selectedPage = bounded;
      });
      if (jumpToPage) _schedulePageJump(bounded);
    } catch (error, stackTrace) {
      debugPrint('Could not load Hifz pages: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _initialPageLoading = false;
        _pageLoadError = error;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingNextPage || _loadedPages.isEmpty) return;
    final page = _loadedPages.keys.reduce((a, b) => a > b ? a : b) + 1;
    if (page > 604) return;
    setState(() => _loadingNextPage = true);
    try {
      final window = await _loadPage(page);
      if (!mounted) return;
      setState(() => _loadedPages[page] = window);
    } catch (error, stackTrace) {
      debugPrint('Could not load next Hifz page: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => _loadingNextPage = false);
    }
  }

  Future<void> _loadPreviousPage() async {
    if (_loadingPreviousPage ||
        _loadedPages.isEmpty ||
        !_mushafScrollController.hasClients) {
      return;
    }
    final page = _loadedPages.keys.reduce((a, b) => a < b ? a : b) - 1;
    if (page < 1) return;
    setState(() => _loadingPreviousPage = true);
    final beforePixels = _mushafScrollController.position.pixels;
    final beforeMax = _mushafScrollController.position.maxScrollExtent;
    try {
      final window = await _loadPage(page);
      if (!mounted) return;
      setState(() => _loadedPages[page] = window);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !_mushafScrollController.hasClients) return;
      final inserted =
          _mushafScrollController.position.maxScrollExtent - beforeMax;
      if (inserted > 0) {
        _mushafScrollController.jumpTo(beforePixels + inserted);
      }
    } catch (error, stackTrace) {
      debugPrint('Could not load previous Hifz page: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => _loadingPreviousPage = false);
    }
  }

  Future<void> _jumpToPage(int page) async {
    final bounded = page.clamp(1, 604).toInt();
    if (!_loadedPages.containsKey(bounded)) {
      await _loadAround(bounded);
      return;
    }
    if (!mounted) return;
    setState(() => _selectedPage = bounded);
    _schedulePageJump(bounded);
  }

  void _schedulePageJump(int page) {
    _pendingPageJump = page;
    _lastAutoScrollElapsed = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _pageKeys[page]?.currentContext;
      if (context == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final retryContext = _pageKeys[page]?.currentContext;
          if (retryContext != null) {
            unawaited(
              Scrollable.ensureVisible(
                retryContext,
                alignment: 0,
              ).whenComplete(() => _pendingPageJump = null),
            );
          } else {
            _pendingPageJump = null;
          }
        });
        return;
      }
      unawaited(
        Scrollable.ensureVisible(
          context,
          alignment: 0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        ).whenComplete(() => _pendingPageJump = null),
      );
    });
  }

  void _onAutoScrollTick(Duration elapsed) {
    final previous = _lastAutoScrollElapsed;
    _lastAutoScrollElapsed = elapsed;
    if (previous == null ||
        !_appActive ||
        _readerPointerDown ||
        _sheetOpen ||
        !ref.read(hifzAutoScrollEnabledProvider) ||
        !_mushafScrollController.hasClients) {
      return;
    }
    final seconds = (elapsed - previous).inMicroseconds / 1000000;
    final pixelsPerSecond = switch (ref.read(hifzAutoScrollSpeedProvider)) {
      HifzAutoScrollSpeed.slow => 14.0,
      HifzAutoScrollSpeed.medium => 30.0,
      HifzAutoScrollSpeed.fast => 52.0,
    };
    final position = _mushafScrollController.position;
    if (position.pixels >= position.maxScrollExtent) {
      if (_loadedPages.keys.any((page) => page < 604)) {
        unawaited(_loadNextPage());
      }
      return;
    }
    _mushafScrollController.jumpTo(
      (position.pixels + pixelsPerSecond * seconds).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
  }

  void _reloadPage() {
    unawaited(_loadAround(_selectedPage));
  }

  void _selectSurah(QuranSurahSummary surah) {
    setState(() {
      _selectedSurahNumber = surah.number;
      _selectedPage = surah.pageStart;
      _rangeStartAyah = null;
      _rangeEndAyah = null;
      _lastFollowedAyahKey = null;
    });
    if (ref.read(hifzReadingModeProvider) == HifzReadingMode.mushaf) {
      unawaited(
        ref.read(hifzMushafControllerProvider).openPage(surah.pageStart),
      );
    } else {
      unawaited(_jumpToPage(surah.pageStart));
    }
  }

  void _turnPage(int page) {
    if (page < 1 || page > 604 || page == _selectedPage) return;
    if (ref.read(hifzReadingModeProvider) == HifzReadingMode.mushaf) {
      setState(() => _selectedPage = page);
      unawaited(ref.read(hifzMushafControllerProvider).openPage(page));
    } else {
      unawaited(_jumpToPage(page));
    }
  }

  void _selectRangeAyah(AyahRef ayah) {
    setState(() {
      final start = _rangeStartAyah;
      _selectedSurahNumber = ayah.surahNumber;
      if (start == null ||
          _rangeEndAyah != null ||
          start.surahNumber != ayah.surahNumber) {
        _rangeStartAyah = ayah;
        _rangeEndAyah = null;
        return;
      }
      if (ayah.ayahNumber < start.ayahNumber) {
        _rangeStartAyah = ayah;
        _rangeEndAyah = null;
        return;
      }
      _rangeEndAyah = ayah;
    });
  }

  Future<void> _setRangeStart(int ayahNumber) async {
    setState(() {
      _rangeStartAyah = AyahRef(
        surahNumber: _selectedSurahNumber,
        ayahNumber: ayahNumber,
      );
      if (_rangeEndAyah != null && _rangeEndAyah!.ayahNumber < ayahNumber) {
        _rangeEndAyah = null;
      }
    });
    await _showAyahPage(ayahNumber);
  }

  Future<void> _setRangeEnd(int ayahNumber) async {
    final start = _rangeStartAyah;
    if (start != null && ayahNumber < start.ayahNumber) {
      _showMessage('শেষ আয়াত শুরুর আয়াতের আগে হতে পারে না।');
      return;
    }
    setState(
      () => _rangeEndAyah = AyahRef(
        surahNumber: _selectedSurahNumber,
        ayahNumber: ayahNumber,
      ),
    );
    await _showAyahPage(ayahNumber);
  }

  Future<void> _showAyahPage(int ayahNumber) async {
    final ayah = await ref
        .read(quranRepositoryProvider)
        .loadAyah(
          surahNumber: _selectedSurahNumber,
          ayahNumber: ayahNumber,
          translationResourceId: ref.read(quranTranslationResourceIdProvider),
        );
    if (!mounted || ayah == null || ayah.pageNumber == _selectedPage) return;
    _turnPage(ayah.pageNumber);
  }

  Future<void> _startSession(HifzSessionConfig config) async {
    try {
      await ref.read(hifzSessionControllerProvider.notifier).start(config);
    } on ArgumentError catch (error) {
      debugPrint('Invalid Hifz range: $error');
      if (!mounted) return;
      _showMessage('নির্বাচিত আয়াত রেঞ্জটি সঠিক নয়।');
    }
  }

  Future<void> _resumeSaved() async {
    try {
      await ref.read(hifzSessionControllerProvider.notifier).resume();
    } catch (error, stackTrace) {
      debugPrint('Hifz resume failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      _showMessage('আগের হিফজ সেশনটি চালু করা যায়নি।');
    }
  }

  Future<void> _followActiveAyah(String ayahKey) async {
    if (_lastFollowedAyahKey == ayahKey) return;
    _lastFollowedAyahKey = ayahKey;

    final parts = ayahKey.split(':');
    if (parts.length != 2) return;
    final surahNumber = int.tryParse(parts[0]);
    final ayahNumber = int.tryParse(parts[1]);
    if (surahNumber != _selectedSurahNumber || ayahNumber == null) return;

    final ayah = await ref
        .read(quranRepositoryProvider)
        .loadAyah(
          surahNumber: surahNumber!,
          ayahNumber: ayahNumber,
          translationResourceId: ref.read(quranTranslationResourceIdProvider),
        );
    if (!mounted || ayah == null || ayah.pageNumber == _selectedPage) return;

    await _jumpToPage(ayah.pageNumber);
  }

  Future<void> _alignToSession(HifzSessionConfig config) async {
    final surahs = await ref.read(quranSurahListProvider.future);
    final surah = _findSurah(surahs, config.start.surahNumber);
    final ayah = await ref
        .read(quranRepositoryProvider)
        .loadAyah(
          surahNumber: config.start.surahNumber,
          ayahNumber: config.start.ayahNumber,
          translationResourceId: ref.read(quranTranslationResourceIdProvider),
        );
    if (!mounted) return;

    setState(() {
      _selectedSurahNumber = surah.number;
      _selectedPage = ayah?.pageNumber ?? surah.pageStart;
      _rangeStartAyah = config.start;
      _rangeEndAyah = config.end;
      _pattern = HifzPatternSelection(
        ayahRepeatCount: config.preset.ayahRepeatCount,
        combinedRepeatCount: config.preset.combinedRepeatCount,
        finalRangeRepeatCount: config.preset.finalRangeRepeatCount,
      );
    });
    if (ref.read(hifzReadingModeProvider) == HifzReadingMode.mushaf) {
      await ref.read(hifzMushafControllerProvider).openPage(_selectedPage);
    } else {
      await _jumpToPage(_selectedPage);
    }
  }

  int? _surahNumberForMushafState(HifzMushafReady? state) {
    if (state == null) return null;
    for (final line in state.page.lines) {
      final surahNumber = line.surahNumber;
      if (surahNumber != null) return surahNumber;
      for (final token in line.tokens) {
        final ayahKey = token.ayahKey;
        if (ayahKey == null) continue;
        final separator = ayahKey.indexOf(':');
        if (separator <= 0) continue;
        final parsed = int.tryParse(ayahKey.substring(0, separator));
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  Future<void> _playMushafWord(String ayahKey, int wordPosition) async {
    final target = await _resolveMushafWord(ayahKey, wordPosition);
    if (target == null) return;
    await _playWord(target.ayah, target.word);
  }

  Future<void> _showMushafWordDetails(String ayahKey, int wordPosition) async {
    final target = await _resolveMushafWord(ayahKey, wordPosition);
    if (target == null) return;
    await _showWordDetails(target.ayah, target.word);
  }

  Future<({QuranAyah ayah, QuranWord word})?> _resolveMushafWord(
    String ayahKey,
    int wordPosition,
  ) async {
    final parts = ayahKey.split(':');
    if (parts.length != 2) return null;
    final surahNumber = int.tryParse(parts[0]);
    final ayahNumber = int.tryParse(parts[1]);
    if (surahNumber == null || ayahNumber == null || wordPosition < 1) {
      return null;
    }

    final ayah = await ref
        .read(quranRepositoryProvider)
        .loadAyah(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          translationResourceId: ref.read(quranTranslationResourceIdProvider),
        );
    if (ayah == null) return null;

    QuranWord? selectedWord;
    for (final word in ayah.words) {
      if (word.position == wordPosition) {
        selectedWord = word;
        break;
      }
    }
    if (selectedWord == null) return null;
    return (ayah: ayah, word: selectedWord);
  }

  Future<void> _playWord(QuranAyah ayah, QuranWord word) async {
    try {
      await ref.read(readerAudioActionsProvider).playWord(ayah, word);
    } on ReaderAudioUnavailableException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error, stackTrace) {
      debugPrint('Hifz word audio failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      _showMessage('শব্দের অডিও চালানো যায়নি।');
    }
  }

  Future<void> _showWordDetails(QuranAyah ayah, QuranWord word) {
    return _pauseWhileSheet<void>(
      () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => WordDetailsSheet(
          target: StudyTarget.word(
            surahNumber: ayah.surahNumber,
            ayahNumber: ayah.ayahNumber,
            wordPosition: word.position,
          ),
          word: word,
          controller: ref.read(studyControllerProvider),
        ),
      ),
    ).then((_) {});
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  QuranSurahSummary _findSurah(List<QuranSurahSummary> surahs, int number) {
    return surahs.firstWhere(
      (item) => item.number == number,
      orElse: () => surahs.first,
    );
  }
}

class _HifzPageControls extends StatelessWidget {
  const _HifzPageControls({
    required this.page,
    required this.showTools,
    required this.onPrevious,
    required this.onTools,
    required this.onNext,
  });

  final int page;
  final bool showTools;
  final VoidCallback? onPrevious;
  final VoidCallback? onTools;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Previous Mushaf page',
                    onPressed: onPrevious,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                  Text('Page $page'),
                ],
              ),
            ),
            if (showTools)
              IconButton.filled(
                key: const ValueKey('hifz-tools'),
                tooltip: 'Expand Audio & Hifz',
                onPressed: onTools,
                alignment: Alignment.center,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  fixedSize: const Size.square(48),
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  disabledBackgroundColor: scheme.primary.withValues(alpha: .4),
                  disabledForegroundColor: scheme.onPrimary.withValues(
                    alpha: .7,
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 28),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Next Mushaf page',
                onPressed: onNext,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactSurahSelector extends StatelessWidget {
  const _CompactSurahSelector({
    required this.surah,
    required this.page,
    required this.onTap,
  });

  final QuranSurahSummary surah;
  final int page;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Material(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: InkWell(
          key: const ValueKey('hifz-surah-selector'),
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${surah.nameEnglish} · Juz ${surah.juzStart} · Page $page',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
