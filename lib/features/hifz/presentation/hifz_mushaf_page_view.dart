import 'dart:async';
import 'package:flutter/material.dart';

import '../application/hifz_mushaf_controller.dart';
import '../domain/hifz_session.dart';
import '../../quran/domain/quran_page_window.dart';
import '../../quran/presentation/mushaf/quran_mushaf_webview.dart';
import '../../quran/presentation/mushaf/quran_strict_mushaf_surface.dart';
import '../../quran/presentation/mushaf/mushaf_renderer_message.dart';
import '../../quran/presentation/mushaf/mushaf_webview_driver.dart';

class HifzMushafRenderFonts {
  const HifzMushafRenderFonts({
    required this.pageFontBytes,
    required this.surahFontBytes,
    required this.bismillahFontBytes,
    required this.endMarkerFontBytes,
  });

  final List<int> pageFontBytes;
  final List<int> surahFontBytes;
  final List<int> bismillahFontBytes;
  final List<int> endMarkerFontBytes;
}

typedef HifzMushafFontLoader =
    Future<HifzMushafRenderFonts> Function(HifzMushafReady ready);

typedef QuranMushafWebViewBuilder =
    Widget Function(
      Key key,
      ValueChanged<MushafRendererEvent> onEvent,
      ValueChanged<MushafWebViewDriver> onDriverReady,
      MushafRendererDiagnostic onDiagnostic,
    );

class HifzMushafPageView extends StatefulWidget {
  const HifzMushafPageView({
    required this.controller,
    required this.activeAyahKey,
    required this.activeWordPosition,
    required this.playbackRunning,
    required this.autoFollow,
    required this.selectedStartAyah,
    required this.selectedEndAyah,
    required this.onWordTap,
    required this.onWordLongPress,
    required this.onAyahSelected,
    required this.onToggleControls,
    required this.onUseRegularHifz,
    this.webViewBuilder,
    this.fontLoader,
    this.fallbackWindow,
    super.key,
  });

  final HifzMushafController controller;
  final String? activeAyahKey;
  final int? activeWordPosition;
  final bool playbackRunning;
  final bool autoFollow;
  final AyahRef? selectedStartAyah;
  final AyahRef? selectedEndAyah;
  final void Function(String ayahKey, int wordPosition) onWordTap;
  final void Function(String ayahKey, int wordPosition) onWordLongPress;
  final ValueChanged<AyahRef> onAyahSelected;
  final VoidCallback onToggleControls;
  final VoidCallback onUseRegularHifz;
  final QuranMushafWebViewBuilder? webViewBuilder;
  final HifzMushafFontLoader? fontLoader;
  final QuranPageWindow? fallbackWindow;

  @override
  State<HifzMushafPageView> createState() => _HifzMushafPageViewState();
}

class _HifzMushafPageViewState extends State<HifzMushafPageView> {
  late HifzMushafState _state;
  late final PageController _pageController;
  StreamSubscription<HifzMushafState>? _stateSubscription;
  HifzMushafFontLoader get _fontLoader =>
      widget.fontLoader ?? _loadProductionFonts;

  QuranMushafWebViewBuilder get _webViewBuilder =>
      widget.webViewBuilder ?? _defaultWebViewBuilder;

  @override
  void initState() {
    super.initState();
    _state = widget.controller.state;
    final initialPage =
        widget.controller.currentPage ?? _pageFromState(_state) ?? 1;
    _pageController = PageController(initialPage: initialPage - 1);
    _stateSubscription = widget.controller.states.listen(_handleState);
  }

  @override
  void didUpdateWidget(covariant HifzMushafPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      unawaited(_stateSubscription?.cancel());
      _state = widget.controller.state;
      _stateSubscription = widget.controller.states.listen(_handleState);
    }

    if (oldWidget.activeAyahKey != widget.activeAyahKey ||
        oldWidget.activeWordPosition != widget.activeWordPosition ||
        oldWidget.autoFollow != widget.autoFollow) {
      _followPlaybackIfNeeded();
    }
  }

  @override
  void dispose() {
    unawaited(_stateSubscription?.cancel());
    _pageController.dispose();
    super.dispose();
  }

  void _handleState(HifzMushafState next) {
    if (!mounted || identical(next, _state)) return;
    _state = next;
    if (next is HifzMushafReady) {
      _schedulePageSync(next.page.page);
      _followPlaybackIfNeeded();
    }
    setState(() {});
  }

  void _followPlaybackIfNeeded() {
    final ayahKey = widget.activeAyahKey;
    if (ayahKey == null) return;
    unawaited(
      widget.controller.followPlayback(
        ayahKey: ayahKey,
        wordPosition: widget.activeWordPosition,
        autoFollow: widget.autoFollow,
      ),
    );
  }

  void _schedulePageSync(int page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final current = _pageController.page?.round();
      final target = page - 1;
      if (current != target) {
        _pageController.jumpToPage(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: const ValueKey('hifz-mushaf-page-view'),
      controller: _pageController,
      itemCount: 604,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) => _buildPageSlot(index + 1),
    );
  }

  Widget _buildPageSlot(int page) {
    final state = _state;

    if (state is HifzMushafReady && state.page.page == page) {
      final fallback = widget.fallbackWindow;
      return KeyedSubtree(
        key: const ValueKey('hifz-mushaf-page-tap-target'),
        child: QuranStrictMushafSurface(
          page: state.page,
          palette: state.palette,
          generation: state.generation,
          pageFontUri: state.fontUri,
          activeAyahKey: widget.activeAyahKey,
          activeWordPosition: widget.activeWordPosition,
          selectedStartAyahKey: widget.selectedStartAyah?.verseKey,
          selectedEndAyahKey: widget.selectedEndAyah?.verseKey,
          fallbackWindow: fallback?.page == page ? fallback : null,
          fontLoader: (_) async {
            final fonts = await _fontLoader(state);
            return QuranStrictMushafFonts(
              pageFontBytes: fonts.pageFontBytes,
              surahFontBytes: fonts.surahFontBytes,
              bismillahFontBytes: fonts.bismillahFontBytes,
              endMarkerFontBytes: fonts.endMarkerFontBytes,
            );
          },
          webViewBuilder: _webViewBuilder,
          onRetry: () => unawaited(widget.controller.retry()),
          onWordTap: widget.onWordTap,
          onWordLongPress: widget.onWordLongPress,
          onAyahTap: (ayahKey) {
            if (!widget.playbackRunning) {
              widget.onAyahSelected(_ayahRefFromKey(ayahKey));
            }
          },
          onTap: widget.onToggleControls,
          secondaryActionLabel: 'Use Regular Hifz',
          onSecondaryAction: widget.onUseRegularHifz,
          onDiagnostic: _handleDiagnostic,
        ),
      );
    }

    if (state is HifzMushafLoading && state.page == page) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is HifzMushafFailure && state.page == page) {
      return _LoadFailure(
        message: 'Could not load this Mushaf page.',
        onRetry: () => unawaited(widget.controller.retry()),
        onUseRegularHifz: widget.onUseRegularHifz,
      );
    }

    if (state is HifzMushafUnavailable) {
      return _LoadFailure(
        message: state.reason,
        onRetry: () => unawaited(widget.controller.retry()),
        onUseRegularHifz: widget.onUseRegularHifz,
      );
    }

    return const SizedBox.expand();
  }

  void _onPageChanged(int index) {
    final page = index + 1;
    final state = _state;
    if (widget.controller.currentPage == page ||
        (state is HifzMushafLoading && state.page == page)) {
      return;
    }
    unawaited(widget.controller.openPage(page));
  }

  void _handleDiagnostic(Object diagnostic) {
    debugPrint('Mushaf renderer diagnostic: $diagnostic');
  }

  int? _pageFromState(HifzMushafState state) {
    return switch (state) {
      HifzMushafReady() => state.page.page,
      HifzMushafLoading() => state.page,
      HifzMushafFailure() => state.page,
      _ => null,
    };
  }

  AyahRef _ayahRefFromKey(String key) {
    final parts = key.split(':');
    if (parts.length != 2) throw FormatException('Invalid ayah key: $key');
    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    if (surah == null || ayah == null || surah < 1 || ayah < 1) {
      throw FormatException('Invalid ayah key: $key');
    }
    return AyahRef(surahNumber: surah, ayahNumber: ayah);
  }

  Widget _defaultWebViewBuilder(
    Key key,
    ValueChanged<MushafRendererEvent> onEvent,
    ValueChanged<MushafWebViewDriver> onDriverReady,
    MushafRendererDiagnostic onDiagnostic,
  ) {
    return QuranMushafWebView(
      key: key,
      onEvent: onEvent,
      onDriverReady: onDriverReady,
      onDiagnostic: onDiagnostic,
    );
  }

  Future<HifzMushafRenderFonts> _loadProductionFonts(
    HifzMushafReady ready,
  ) async {
    final fonts = await loadQuranStrictMushafFonts(ready.fontUri);
    return HifzMushafRenderFonts(
      pageFontBytes: fonts.pageFontBytes,
      surahFontBytes: fonts.surahFontBytes,
      bismillahFontBytes: fonts.bismillahFontBytes,
      endMarkerFontBytes: fonts.endMarkerFontBytes,
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({
    required this.message,
    required this.onRetry,
    required this.onUseRegularHifz,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onUseRegularHifz;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
            TextButton(
              onPressed: onUseRegularHifz,
              child: const Text('Use Regular Hifz'),
            ),
          ],
        ),
      ),
    );
  }
}
