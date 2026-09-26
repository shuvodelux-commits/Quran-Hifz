import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/quran_mushaf_page.dart';
import '../../domain/quran_mushaf_palette.dart';
import '../../domain/quran_mushaf_line.dart';
import '../../domain/quran_page_window.dart';
import '../widgets/bismillah_v4_glyph.dart';
import 'mushaf_renderer_message.dart';
import 'mushaf_webview_driver.dart';
import 'quran_mushaf_webview.dart';

class QuranStrictMushafFonts {
  const QuranStrictMushafFonts({
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

typedef QuranStrictMushafFontLoader =
    Future<QuranStrictMushafFonts> Function(Uri pageFontUri);

typedef QuranStrictMushafWebViewBuilder =
    Widget Function(
      Key key,
      ValueChanged<MushafRendererEvent> onEvent,
      ValueChanged<MushafWebViewDriver> onDriverReady,
      MushafRendererDiagnostic onDiagnostic,
    );

class QuranStrictMushafSurface extends StatefulWidget {
  const QuranStrictMushafSurface({
    required this.page,
    required this.palette,
    required this.generation,
    required this.pageFontUri,
    required this.onRetry,
    required this.onWordTap,
    required this.onWordLongPress,
    required this.onAyahTap,
    this.activeAyahKey,
    this.activeWordPosition,
    this.selectedStartAyahKey,
    this.selectedEndAyahKey,
    this.fallbackWindow,
    this.fontLoader,
    this.webViewBuilder,
    this.onDiagnostic,
    this.onTap,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    super.key,
  });

  final QcfMushafPage page;
  final QuranMushafPalette palette;
  final int generation;
  final Uri pageFontUri;
  final String? activeAyahKey;
  final int? activeWordPosition;
  final String? selectedStartAyahKey;
  final String? selectedEndAyahKey;
  final QuranPageWindow? fallbackWindow;
  final VoidCallback onRetry;
  final void Function(String ayahKey, int wordPosition) onWordTap;
  final void Function(String ayahKey, int wordPosition) onWordLongPress;
  final ValueChanged<String> onAyahTap;
  final QuranStrictMushafFontLoader? fontLoader;
  final QuranStrictMushafWebViewBuilder? webViewBuilder;
  final MushafRendererDiagnostic? onDiagnostic;
  final VoidCallback? onTap;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  State<QuranStrictMushafSurface> createState() =>
      _QuranStrictMushafSurfaceState();
}

class _QuranStrictMushafSurfaceState extends State<QuranStrictMushafSurface> {
  late Future<QuranStrictMushafFonts> _fonts;
  MushafWebViewDriver? _driver;
  int _webViewEpoch = 0;
  int _rendererFailures = 0;
  bool _rendererFallback = false;

  QuranStrictMushafFontLoader get _fontLoader =>
      widget.fontLoader ?? loadQuranStrictMushafFonts;

  QuranStrictMushafWebViewBuilder get _webViewBuilder =>
      widget.webViewBuilder ?? _defaultWebViewBuilder;

  @override
  void initState() {
    super.initState();
    _fonts = _loadFonts();
  }

  @override
  void didUpdateWidget(covariant QuranStrictMushafSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageFontUri != widget.pageFontUri ||
        oldWidget.generation != widget.generation ||
        oldWidget.page.variant != widget.page.variant) {
      _resetAndReload();
      return;
    }

    final driver = _driver;
    if (driver == null) return;
    if (oldWidget.palette != widget.palette) {
      driver.setPalette(widget.palette);
    }
    if (oldWidget.activeAyahKey != widget.activeAyahKey ||
        oldWidget.activeWordPosition != widget.activeWordPosition ||
        oldWidget.selectedStartAyahKey != widget.selectedStartAyahKey ||
        oldWidget.selectedEndAyahKey != widget.selectedEndAyahKey) {
      _syncHighlights(driver);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rendererFallback) {
      return _fallback(context);
    }
    return FutureBuilder<QuranStrictMushafFonts>(
      future: _fonts,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _fallback(context);
        final fonts = snapshot.data;
        if (fonts == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return GestureDetector(
          key: const ValueKey('quran-strict-mushaf-tap-target'),
          behavior: HitTestBehavior.translucent,
          onTap: widget.onTap,
          child: _webViewBuilder(
            ValueKey(
              'quran-strict-mushaf-' +
                  widget.generation.toString() +
                  '-' +
                  _webViewEpoch.toString(),
            ),
            _handleEvent,
            (driver) => _onDriverReady(driver, fonts),
            _handleDiagnostic,
          ),
        );
      },
    );
  }

  void _onDriverReady(
    MushafWebViewDriver driver,
    QuranStrictMushafFonts fonts,
  ) {
    _driver = driver;
    _render(driver, fonts);
  }

  Future<void> _render(
    MushafWebViewDriver driver,
    QuranStrictMushafFonts fonts,
  ) async {
    try {
      await driver.renderPage(
        MushafRenderPayload(
          page: widget.page,
          palette: widget.palette,
          generation: widget.generation,
          pageFontBytes: fonts.pageFontBytes,
          surahFontBytes: fonts.surahFontBytes,
          bismillahFontBytes: fonts.bismillahFontBytes,
          endMarkerFontBytes: fonts.endMarkerFontBytes,
        ),
      );
      await _syncHighlights(driver);
    } on Object catch (error) {
      _handleDiagnostic(error);
      _recoverRenderer();
    }
  }

  Future<void> _syncHighlights(MushafWebViewDriver driver) async {
    await driver.setRange(
      widget.selectedStartAyahKey,
      widget.selectedEndAyahKey,
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
  }

  void _handleEvent(MushafRendererEvent event) {
    switch (event) {
      case MushafWordTapEvent():
        widget.onWordTap(event.ayahKey, event.wordPosition);
      case MushafWordLongPressEvent():
        widget.onWordLongPress(event.ayahKey, event.wordPosition);
      case MushafAyahTapEvent():
        widget.onAyahTap(event.ayahKey);
      case MushafPageReadyEvent():
        final driver = _driver;
        if (driver != null &&
            event.page == widget.page.page &&
            event.generation == widget.generation) {
          _syncHighlights(driver);
        }
      case MushafRendererErrorEvent():
        _recoverRenderer();
    }
  }

  void _recoverRenderer() {
    if (!mounted) return;
    _driver = null;
    _rendererFailures++;
    if (_rendererFailures == 1) {
      setState(() => _webViewEpoch++);
      return;
    }
    setState(() => _rendererFallback = true);
  }

  void _resetAndReload() {
    _driver = null;
    _rendererFailures = 0;
    _rendererFallback = false;
    _webViewEpoch++;
    _fonts = _loadFonts();
    if (mounted) setState(() {});
  }

  Future<QuranStrictMushafFonts> _loadFonts() {
    final completer = Completer<QuranStrictMushafFonts>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        completer.complete(await _fontLoader(widget.pageFontUri));
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Widget _fallback(BuildContext context) {
    final window = widget.fallbackWindow;
    if (window == null) {
      return _FallbackShell(
        page: widget.page.page,
        onRetry: _retry,
        secondaryActionLabel: widget.secondaryActionLabel,
        onSecondaryAction: widget.onSecondaryAction,
        child: const Text(
          'Strict Mushaf font is unavailable. Use the readable Quran view.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return _FallbackShell(
      page: window.page,
      onRetry: _retry,
      secondaryActionLabel: widget.secondaryActionLabel,
      onSecondaryAction: widget.onSecondaryAction,
      child: _UnicodeQuranFallback(window: window),
    );
  }

  void _retry() {
    widget.onRetry();
    _resetAndReload();
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

  void _handleDiagnostic(Object error) {
    widget.onDiagnostic?.call(error);
    debugPrint('Strict Mushaf renderer diagnostic: ' + error.toString());
  }
}

class _FallbackShell extends StatelessWidget {
  const _FallbackShell({
    required this.page,
    required this.onRetry,
    required this.child,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final int page;
  final VoidCallback onRetry;
  final Widget child;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F1E3),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            children: [
              Expanded(
                child: Center(child: SingleChildScrollView(child: child)),
              ),
              const SizedBox(height: 12),
              Text('Page ' + page.toString()),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
              if (secondaryActionLabel != null && onSecondaryAction != null)
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryActionLabel!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnicodeQuranFallback extends StatelessWidget {
  const _UnicodeQuranFallback({required this.window});

  final QuranPageWindow window;

  @override
  Widget build(BuildContext context) {
    final wordText = <String, String>{};
    for (final ayah in window.ayahs) {
      for (final word in ayah.words) {
        wordText[ayah.surahNumber.toString() +
                ':' +
                ayah.ayahNumber.toString() +
                ':' +
                word.position.toString()] =
            word.arabic;
      }
    }

    final children = <Widget>[];
    final lines = [...window.lines]
      ..sort((left, right) => left.lineNumber.compareTo(right.lineNumber));
    if (lines.isEmpty) {
      for (final ayah in window.ayahs) {
        children.add(
          Text(
            ayah.words.map((word) => word.arabic).join(' '),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'QPC Hafs',
              fontSize: 30,
              height: 1.8,
            ),
          ),
        );
      }
    } else {
      for (final line in lines) {
        switch (line.type) {
          case QuranMushafLineType.surahName:
            children.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'سورة ' + (line.surahNumber ?? 0).toString(),
                  key: ValueKey(
                    'strict-fallback-surah-' + line.lineNumber.toString(),
                  ),
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'QPC Hafs',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          case QuranMushafLineType.bismillah:
            children.add(
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: BismillahV4Glyph(fontSize: 36, useTajweedColors: false),
              ),
            );
          case QuranMushafLineType.ayah:
            final text = line.wordLocations
                .map((location) => wordText[location.toString()] ?? '')
                .where((value) => value.isNotEmpty)
                .join(' ');
            children.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  text,
                  textDirection: TextDirection.rtl,
                  textAlign: line.centered
                      ? TextAlign.center
                      : TextAlign.justify,
                  style: const TextStyle(
                    fontFamily: 'QPC Hafs',
                    fontSize: 30,
                    height: 1.7,
                  ),
                ),
              ),
            );
        }
      }
    }
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}

Future<QuranStrictMushafFonts> loadQuranStrictMushafFonts(
  Uri pageFontUri,
) async {
  final pageFont = await _readFontUri(pageFontUri);
  final surahFont = await _readAsset('assets/fonts/surah-name-v4.ttf');
  final unicodeHafs = await _readAsset('assets/fonts/UthmanicHafs1Ver18.ttf');
  return QuranStrictMushafFonts(
    pageFontBytes: pageFont,
    surahFontBytes: surahFont,
    bismillahFontBytes: unicodeHafs,
    endMarkerFontBytes: unicodeHafs,
  );
}

Future<List<int>> _readFontUri(Uri uri) async {
  if (uri.scheme == 'file') return File.fromUri(uri).readAsBytes();
  if (uri.scheme == 'asset') return _readAsset(uri.path);
  throw FormatException('Unsupported Mushaf font URI scheme: ' + uri.scheme);
}

Future<List<int>> _readAsset(String path) async {
  final data = await rootBundle.load(path);
  return Uint8List.sublistView(data);
}
