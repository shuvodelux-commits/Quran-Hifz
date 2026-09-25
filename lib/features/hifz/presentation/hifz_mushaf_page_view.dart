import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../application/hifz_mushaf_controller.dart';
import '../domain/hifz_session.dart';
import 'hifz_mushaf_webview.dart';
import 'mushaf_renderer_message.dart';
import 'mushaf_webview_driver.dart';

class HifzMushafRenderFonts {
  const HifzMushafRenderFonts({
    required this.pageFontBytes,
    required this.surahFontBytes,
    required this.bismillahFontBytes,
  });

  final List<int> pageFontBytes;
  final List<int> surahFontBytes;
  final List<int> bismillahFontBytes;
}

typedef HifzMushafFontLoader =
    Future<HifzMushafRenderFonts> Function(HifzMushafReady ready);

typedef HifzMushafWebViewBuilder =
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
  final HifzMushafWebViewBuilder? webViewBuilder;
  final HifzMushafFontLoader? fontLoader;

  @override
  State<HifzMushafPageView> createState() => _HifzMushafPageViewState();
}

class _HifzMushafPageViewState extends State<HifzMushafPageView> {
  late HifzMushafState _state;
  late final PageController _pageController;
  StreamSubscription<HifzMushafState>? _stateSubscription;
  MushafWebViewDriver? _driver;
  int _webViewEpoch = 0;
  int? _rendererFailureGeneration;
  int _rendererFailureCount = 0;
  bool _showRendererFallback = false;
  Object? _localRenderError;

  HifzMushafFontLoader get _fontLoader =>
      widget.fontLoader ?? _loadProductionFonts;

  HifzMushafWebViewBuilder get _webViewBuilder =>
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
        oldWidget.selectedStartAyah != widget.selectedStartAyah ||
        oldWidget.selectedEndAyah != widget.selectedEndAyah ||
        oldWidget.autoFollow != widget.autoFollow) {
      unawaited(_syncPlaybackAndSelection());
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
      if (_rendererFailureGeneration != next.generation) {
        _rendererFailureGeneration = next.generation;
        _rendererFailureCount = 0;
        _showRendererFallback = false;
      }
      _localRenderError = null;
      _schedulePageSync(next.page.page);
    }

    setState(() {});
    if (next is HifzMushafReady && _driver != null) {
      unawaited(_renderReady(next, _driver!));
    }
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
      if (_showRendererFallback) {
        return _RendererFallback(
          onRetry: _retryRenderer,
          onUseRegularHifz: widget.onUseRegularHifz,
        );
      }
      if (_localRenderError != null) {
        return _LoadFailure(
          message: 'Could not prepare this Mushaf page.',
          onRetry: _retryRenderer,
          onUseRegularHifz: widget.onUseRegularHifz,
        );
      }

      return GestureDetector(
        key: const ValueKey('hifz-mushaf-page-tap-target'),
        behavior: HitTestBehavior.translucent,
        onTap: widget.onToggleControls,
        child: _webViewBuilder(
          ValueKey('hifz-mushaf-webview-${state.generation}-$_webViewEpoch'),
          _handleRendererEvent,
          _handleDriverReady,
          _handleDiagnostic,
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

  void _handleDriverReady(MushafWebViewDriver driver) {
    _driver = driver;
    final state = _state;
    if (state is HifzMushafReady) {
      unawaited(_renderReady(state, driver));
    }
  }

  Future<void> _renderReady(
    HifzMushafReady ready,
    MushafWebViewDriver driver,
  ) async {
    try {
      final fonts = await _fontLoader(ready);
      if (!mounted ||
          !identical(driver, _driver) ||
          _state is! HifzMushafReady ||
          (_state as HifzMushafReady).generation != ready.generation) {
        return;
      }

      await driver.renderPage(
        MushafRenderPayload(
          page: ready.page,
          palette: ready.palette,
          generation: ready.generation,
          pageFontBytes: fonts.pageFontBytes,
          surahFontBytes: fonts.surahFontBytes,
          bismillahFontBytes: fonts.bismillahFontBytes,
        ),
      );
      await _syncPlaybackAndSelection();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _localRenderError = error);
    }
  }

  Future<void> _syncPlaybackAndSelection() async {
    final driver = _driver;
    if (driver == null) return;

    await driver.setRange(
      widget.selectedStartAyah?.verseKey,
      widget.selectedEndAyah?.verseKey,
    );

    final ayahKey = widget.activeAyahKey;
    if (ayahKey == null) {
      await driver.clearPlaybackHighlight();
      return;
    }

    await driver.setActiveAyah(ayahKey);
    final wordPosition = widget.activeWordPosition;
    if (wordPosition != null) {
      await driver.setActiveWord(ayahKey, wordPosition);
    }

    unawaited(
      widget.controller.followPlayback(
        ayahKey: ayahKey,
        wordPosition: wordPosition,
        autoFollow: widget.autoFollow,
      ),
    );
  }

  void _handleRendererEvent(MushafRendererEvent event) {
    switch (event) {
      case MushafWordTapEvent():
        widget.onWordTap(event.ayahKey, event.wordPosition);
      case MushafWordLongPressEvent():
        widget.onWordLongPress(event.ayahKey, event.wordPosition);
      case MushafAyahTapEvent():
        if (!widget.playbackRunning) {
          widget.onAyahSelected(_ayahRefFromKey(event.ayahKey));
        }
      case MushafPageReadyEvent():
        final current = _state;
        if (current is HifzMushafReady &&
            current.generation == event.generation &&
            current.page.page == event.page) {
          unawaited(_syncPlaybackAndSelection());
        }
      case MushafRendererErrorEvent():
        _recoverRenderer();
    }
  }

  void _recoverRenderer() {
    final state = _state;
    if (state is! HifzMushafReady) return;

    if (_rendererFailureGeneration != state.generation) {
      _rendererFailureGeneration = state.generation;
      _rendererFailureCount = 0;
    }

    _rendererFailureCount++;
    _driver = null;
    if (_rendererFailureCount == 1) {
      setState(() {
        _webViewEpoch++;
        _localRenderError = null;
      });
      return;
    }

    setState(() => _showRendererFallback = true);
  }

  void _retryRenderer() {
    setState(() {
      _rendererFailureCount = 0;
      _showRendererFallback = false;
      _localRenderError = null;
      _driver = null;
      _webViewEpoch++;
    });
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
    return HifzMushafWebView(
      key: key,
      onEvent: onEvent,
      onDriverReady: onDriverReady,
      onDiagnostic: onDiagnostic,
    );
  }

  Future<HifzMushafRenderFonts> _loadProductionFonts(
    HifzMushafReady ready,
  ) async {
    final pageFont = await _readFontUri(ready.fontUri);
    final surahFont = await _readAsset('assets/fonts/surah-name-v4.ttf');
    final bismillahFont = await _readAsset(
      'assets/fonts/KFGQPC-Uthmanic-Script-HAFS-Regular.otf',
    );
    return HifzMushafRenderFonts(
      pageFontBytes: pageFont,
      surahFontBytes: surahFont,
      bismillahFontBytes: bismillahFont,
    );
  }

  Future<List<int>> _readFontUri(Uri uri) async {
    if (uri.scheme == 'file') {
      return File.fromUri(uri).readAsBytes();
    }
    if (uri.scheme == 'asset') {
      return _readAsset(uri.path);
    }
    throw FormatException('Unsupported Mushaf font URI scheme: ${uri.scheme}');
  }

  Future<List<int>> _readAsset(String path) async {
    final data = await rootBundle.load(path);
    return Uint8List.sublistView(data);
  }
}

class _RendererFallback extends StatelessWidget {
  const _RendererFallback({
    required this.onRetry,
    required this.onUseRegularHifz,
  });

  final VoidCallback onRetry;
  final VoidCallback onUseRegularHifz;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Mushaf renderer could not recover.'),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
          TextButton(
            onPressed: onUseRegularHifz,
            child: const Text('Use Regular Hifz'),
          ),
        ],
      ),
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
