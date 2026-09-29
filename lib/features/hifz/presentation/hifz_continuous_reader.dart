import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../quran/application/quran_mushaf_providers.dart';
import '../../quran/application/reader_state.dart';
import '../../quran/domain/quran_mushaf_page.dart';
import '../../quran/domain/quran_mushaf_palette.dart';
import '../../quran/domain/quran_mushaf_variant.dart';
import '../../quran/domain/quran_page_window.dart';
import '../../quran/presentation/mushaf/mushaf_renderer_message.dart';
import '../../quran/presentation/mushaf/quran_strict_mushaf_surface.dart';
import 'hifz_auto_scroll_driver.dart';

class HifzContinuousReader extends ConsumerStatefulWidget {
  const HifzContinuousReader({
    required this.state,
    required this.variant,
    required this.fontSize,
    required this.lineHeight,
    required this.showTajweedColors,
    required this.activeAyahKey,
    required this.activeWordPosition,
    required this.selectedStartAyahKey,
    required this.selectedEndAyahKey,
    required this.onPageNeeded,
    required this.onCurrentPageChanged,
    required this.onWordTap,
    required this.onWordLongPress,
    required this.onAyahTap,
    this.activeWordBanglaMeaning,
    this.playbackPage,
    this.autoScrollEnabled = false,
    this.autoScrollSpeed = 0.35,
    this.audioPlaying = false,
    this.onDisableAutoScroll,
    super.key,
  });

  final ReaderState state;
  final QuranMushafVariant variant;
  final double fontSize;
  final double lineHeight;
  final bool showTajweedColors;
  final String? activeAyahKey;
  final int? activeWordPosition;
  final String? activeWordBanglaMeaning;
  final String? selectedStartAyahKey;
  final String? selectedEndAyahKey;
  final int? playbackPage;
  final bool autoScrollEnabled;
  final double autoScrollSpeed;
  final bool audioPlaying;
  final VoidCallback? onDisableAutoScroll;
  final ValueChanged<int> onPageNeeded;
  final ValueChanged<int> onCurrentPageChanged;
  final void Function(String ayahKey, int wordPosition) onWordTap;
  final void Function(String ayahKey, int wordPosition) onWordLongPress;
  final ValueChanged<String> onAyahTap;

  @override
  ConsumerState<HifzContinuousReader> createState() =>
      _HifzContinuousReaderState();
}

class _HifzContinuousReaderState extends ConsumerState<HifzContinuousReader>
    with SingleTickerProviderStateMixin {
  final Map<int, double> _pageHeights = <int, double>{};
  final Map<int, GlobalKey> _pageKeys = <int, GlobalKey>{};
  ScrollController? _scrollController;
  late final Ticker _autoScrollTicker;
  Duration? _lastAutoScrollTick;
  double _defaultPageExtent = 1;
  bool _currentPageUpdateScheduled = false;
  bool _userScrollActive = false;
  bool _audioDisableRequested = false;

  @override
  void initState() {
    super.initState();
    _autoScrollTicker = createTicker(_onAutoScrollTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.audioPlaying &&
          widget.autoScrollEnabled &&
          !_audioDisableRequested) {
        _audioDisableRequested = true;
        widget.onDisableAutoScroll?.call();
      }
      _syncAutoScrollTicker();
    });
  }

  @override
  void didUpdateWidget(covariant HifzContinuousReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variant != widget.variant) {
      _pageHeights.clear();
    }
    if (widget.audioPlaying &&
        widget.autoScrollEnabled &&
        !_audioDisableRequested) {
      _audioDisableRequested = true;
      widget.onDisableAutoScroll?.call();
    }
    if (!widget.audioPlaying || !widget.autoScrollEnabled) {
      _audioDisableRequested = false;
    }
    _syncAutoScrollTicker();

    if (oldWidget.playbackPage != widget.playbackPage &&
        widget.playbackPage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _followPlaybackPage(widget.playbackPage!);
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTicker.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        _defaultPageExtent = extent;
        _scrollController ??= ScrollController(
          initialScrollOffset:
              (widget.state.currentPage - widget.state.firstPage) * extent,
        );

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification &&
                notification.dragDetails != null) {
              _userScrollActive = true;
              _syncAutoScrollTicker();
            }
            if (notification is ScrollEndNotification &&
                _userScrollActive) {
              _userScrollActive = false;
              _lastAutoScrollTick = Duration.zero;
              _syncAutoScrollTicker();
            }
            if (notification is ScrollUpdateNotification ||
                notification is ScrollEndNotification) {
              _scheduleCurrentPageUpdate();
            }
            return false;
          },
          child: ListView.builder(
            key: const ValueKey('hifz-continuous-reader'),
            controller: _scrollController,
            itemCount: widget.state.lastPage - widget.state.firstPage + 1,
            itemBuilder: (context, index) {
              final page = widget.state.firstPage + index;
              final pageKey = _pageKeys.putIfAbsent(page, () => GlobalKey());
              final window = widget.state.windows[page];
              if (window == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) widget.onPageNeeded(page);
                });
              }
              final height = _pageHeights[page] ?? extent;
              return KeyedSubtree(
                key: pageKey,
                child: SizedBox(
                  key: ValueKey('hifz-continuous-page-$page'),
                  height: height,
                  child: window == null
                      ? const Center(child: CircularProgressIndicator())
                      : _ContinuousMushafPage(
                          page: page,
                          window: window,
                          variant: widget.variant,
                          fontSize: widget.fontSize,
                          lineHeight: widget.lineHeight,
                          showTajweedColors: widget.showTajweedColors,
                          activeAyahKey: widget.activeAyahKey,
                          activeWordPosition: widget.activeWordPosition,
                          activeWordBanglaMeaning:
                              widget.activeWordBanglaMeaning,
                          selectedStartAyahKey: widget.selectedStartAyahKey,
                          selectedEndAyahKey: widget.selectedEndAyahKey,
                          onPageMetrics: (event) =>
                              _handlePageMetrics(event, extent),
                          onPlaybackTarget: _handlePlaybackTarget,
                          onWordTap: widget.onWordTap,
                          onWordLongPress: widget.onWordLongPress,
                          onAyahTap: widget.onAyahTap,
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  bool get _shouldAutoScroll =>
      widget.autoScrollEnabled &&
      !widget.audioPlaying &&
      !_userScrollActive;

  void _syncAutoScrollTicker() {
    if (!mounted) return;
    final controller = _scrollController;
    final atEnd =
        controller != null &&
        controller.hasClients &&
        controller.offset >= controller.position.maxScrollExtent - 0.5;
    if (_shouldAutoScroll && !atEnd) {
      if (!_autoScrollTicker.isActive) {
        _lastAutoScrollTick = Duration.zero;
        _autoScrollTicker.start();
      }
      return;
    }
    _lastAutoScrollTick = null;
    if (_autoScrollTicker.isActive) {
      _autoScrollTicker.stop();
    }
  }

  void _onAutoScrollTick(Duration elapsed) {
    if (!_shouldAutoScroll) {
      _syncAutoScrollTicker();
      return;
    }
    final previousTick = _lastAutoScrollTick;
    _lastAutoScrollTick = elapsed;
    if (previousTick == null) return;

    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;
    final delta = elapsed - previousTick;
    if (delta <= Duration.zero) return;

    final position = controller.position;
    final next = hifzAutoScrollNextOffset(
      currentOffset: controller.offset,
      maxScrollExtent: position.maxScrollExtent,
      normalizedSpeed: widget.autoScrollSpeed,
      elapsed: delta,
    );
    if (next > controller.offset) {
      controller.jumpTo(next);
    }
    if (next >= position.maxScrollExtent - 0.5) {
      _syncAutoScrollTicker();
    }
  }

  void _handlePageMetrics(MushafPageMetricsEvent event, double minimumHeight) {
    final next = event.contentHeight < minimumHeight
        ? minimumHeight
        : event.contentHeight;
    final previous = _pageHeights[event.page];
    if (previous != null && (previous - next).abs() < 0.5) return;

    final controller = _scrollController;
    final currentPage = _pageForOffset(
      (controller?.hasClients ?? false) ? controller!.offset : 0,
    );
    final shouldCompensate =
        event.page < currentPage &&
        controller != null &&
        controller.hasClients;
    final previousExtent = previous ?? minimumHeight;
    final delta = next - previousExtent;

    setState(() => _pageHeights[event.page] = next);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentController = _scrollController;
      if (!mounted ||
          currentController == null ||
          !currentController.hasClients) {
        return;
      }
      if (shouldCompensate && delta != 0) {
        final position = currentController.position;
        currentController.jumpTo(
          (currentController.offset + delta)
              .clamp(position.minScrollExtent, position.maxScrollExtent)
              .toDouble(),
        );
      }
      _syncAutoScrollTicker();
    });
  }

  void _handlePlaybackTarget(MushafPlaybackTargetEvent event) {
    if (widget.activeAyahKey == null ||
        event.ayahKey != widget.activeAyahKey ||
        (widget.playbackPage != null && event.page != widget.playbackPage)) {
      return;
    }
    final controller = _scrollController;
    final pageContext = _pageKeys[event.page]?.currentContext;
    if (controller == null ||
        !controller.hasClients ||
        pageContext == null) {
      return;
    }

    final box = pageContext.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final pageTop = box.localToGlobal(Offset.zero).dy;
    final targetTop = pageTop + event.top;
    final targetBottom = pageTop + event.bottom;
    final viewportObject = context.findRenderObject();
    final viewportTop = viewportObject is RenderBox
        ? viewportObject.localToGlobal(Offset.zero).dy
        : 0.0;
    final localTop = targetTop - viewportTop;
    final localBottom = targetBottom - viewportTop;
    final safeTop = 48.0;
    final safeBottom = _defaultPageExtent - 88.0;

    if (localTop >= safeTop && localBottom <= safeBottom) return;

    final position = controller.position;
    final target =
        (controller.offset + localTop - _defaultPageExtent * 0.34)
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble();
    unawaited(
      controller.animateTo(
        target,
        duration: Duration(
          milliseconds: event.wordPosition == null ? 320 : 260,
        ),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _followPlaybackPage(int page) {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
    final target = _estimatedOffsetForPage(page)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if ((controller.offset - target).abs() < _defaultPageExtent * 0.25) {
      return;
    }
    unawaited(
      controller.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  double _estimatedOffsetForPage(int page) {
    var offset = 0.0;
    for (var candidate = widget.state.firstPage;
        candidate < page;
        candidate++) {
      offset += _pageHeights[candidate] ?? _defaultPageExtent;
    }
    return offset;
  }

  int _pageForOffset(double offset) {
    final target = offset + _defaultPageExtent * 0.34;
    var cursor = 0.0;
    for (var page = widget.state.firstPage;
        page <= widget.state.lastPage;
        page++) {
      final height = _pageHeights[page] ?? _defaultPageExtent;
      if (target < cursor + height) return page;
      cursor += height;
    }
    return widget.state.lastPage;
  }

  void _scheduleCurrentPageUpdate() {
    if (_currentPageUpdateScheduled) return;
    _currentPageUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentPageUpdateScheduled = false;
      final controller = _scrollController;
      if (!mounted || controller == null || !controller.hasClients) return;
      final page = _pageForOffset(controller.offset);
      if (page != widget.state.currentPage) {
        widget.onCurrentPageChanged(page);
      }
    });
  }
}

class _ContinuousMushafPage extends ConsumerStatefulWidget {
  const _ContinuousMushafPage({
    required this.page,
    required this.window,
    required this.variant,
    required this.fontSize,
    required this.lineHeight,
    required this.showTajweedColors,
    required this.activeAyahKey,
    required this.activeWordPosition,
    required this.activeWordBanglaMeaning,
    required this.selectedStartAyahKey,
    required this.selectedEndAyahKey,
    required this.onPageMetrics,
    required this.onPlaybackTarget,
    required this.onWordTap,
    required this.onWordLongPress,
    required this.onAyahTap,
  });

  final int page;
  final QuranPageWindow window;
  final QuranMushafVariant variant;
  final double fontSize;
  final double lineHeight;
  final bool showTajweedColors;
  final String? activeAyahKey;
  final int? activeWordPosition;
  final String? activeWordBanglaMeaning;
  final String? selectedStartAyahKey;
  final String? selectedEndAyahKey;
  final ValueChanged<MushafPageMetricsEvent> onPageMetrics;
  final ValueChanged<MushafPlaybackTargetEvent> onPlaybackTarget;
  final void Function(String ayahKey, int wordPosition) onWordTap;
  final void Function(String ayahKey, int wordPosition) onWordLongPress;
  final ValueChanged<String> onAyahTap;

  @override
  ConsumerState<_ContinuousMushafPage> createState() =>
      _ContinuousMushafPageState();
}

class _ContinuousMushafPageState
    extends ConsumerState<_ContinuousMushafPage> {
  late Future<_ContinuousPageLoad> _load;

  @override
  void initState() {
    super.initState();
    _load = _loadPage();
  }

  @override
  void didUpdateWidget(covariant _ContinuousMushafPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page || oldWidget.variant != widget.variant) {
      _load = _loadPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ContinuousPageLoad>(
      future: _load,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null) {
          return QuranStrictMushafSurface(
            page: data.page,
            palette: QuranMushafPalette.light,
            generation: Object.hash(widget.variant, widget.page) & 0x7fffffff,
            fontSize: widget.fontSize,
            lineHeight: widget.lineHeight,
            showTajweedColors: widget.showTajweedColors,
            continuousLayout: true,
            pageFontUri: data.fontUri,
            fallbackWindow: widget.window,
            fontLoader: data.fontError == null
                ? null
                : (_) async => throw data.fontError!,
            activeAyahKey: widget.activeAyahKey,
            activeWordPosition: widget.activeWordPosition,
            activeWordBanglaMeaning: widget.activeWordBanglaMeaning,
            selectedStartAyahKey: widget.selectedStartAyahKey,
            selectedEndAyahKey: widget.selectedEndAyahKey,
            onPageMetrics: widget.onPageMetrics,
            onPlaybackTarget: widget.onPlaybackTarget,
            onRetry: _retry,
            onWordTap: widget.onWordTap,
            onWordLongPress: widget.onWordLongPress,
            onAyahTap: widget.onAyahTap,
          );
        }

        if (snapshot.hasError) {
          return QuranStrictMushafSurface(
            page: QcfMushafPage(
              page: widget.page,
              variant: widget.variant,
              lines: const [],
            ),
            palette: QuranMushafPalette.light,
            generation: Object.hash(widget.variant, widget.page) & 0x7fffffff,
            fontSize: widget.fontSize,
            lineHeight: widget.lineHeight,
            showTajweedColors: widget.showTajweedColors,
            continuousLayout: true,
            pageFontUri: Uri.parse(
              'unavailable://qcf-page/${widget.page}',
            ),
            fallbackWindow: widget.window,
            fontLoader: (_) async => throw snapshot.error!,
            activeAyahKey: widget.activeAyahKey,
            activeWordPosition: widget.activeWordPosition,
            activeWordBanglaMeaning: widget.activeWordBanglaMeaning,
            selectedStartAyahKey: widget.selectedStartAyahKey,
            selectedEndAyahKey: widget.selectedEndAyahKey,
            onPageMetrics: widget.onPageMetrics,
            onPlaybackTarget: widget.onPlaybackTarget,
            onRetry: _retry,
            onWordTap: widget.onWordTap,
            onWordLongPress: widget.onWordLongPress,
            onAyahTap: widget.onAyahTap,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<_ContinuousPageLoad> _loadPage() async {
    final pageRepository = ref.read(quranMushafPageRepositoryProvider);
    if (widget.variant == QuranMushafVariant.qcfV2 &&
        !await pageRepository.isVariantAvailable(widget.variant)) {
      throw StateError('QCF V2 Quran page data is not installed.');
    }

    final page = await pageRepository.loadPage(
      variant: widget.variant,
      page: widget.page,
    );
    final fontRepository = ref.read(
      quranPageFontRepositoryProvider(widget.variant),
    );
    Object? fontError;
    Uri fontUri;
    try {
      fontUri = await fontRepository.ensurePageFont(widget.page);
      unawaited(fontRepository.prefetchNeighbors(widget.page));
    } on Object catch (error) {
      fontError = error;
      fontUri = Uri.parse('unavailable://qcf-page/${widget.page}');
    }
    return _ContinuousPageLoad(
      page: page,
      fontUri: fontUri,
      fontError: fontError,
    );
  }

  void _retry() {
    setState(() => _load = _loadPage());
  }
}

class _ContinuousPageLoad {
  const _ContinuousPageLoad({
    required this.page,
    required this.fontUri,
    required this.fontError,
  });

  final QcfMushafPage page;
  final Uri fontUri;
  final Object? fontError;
}
