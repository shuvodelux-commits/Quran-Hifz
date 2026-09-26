import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../hifz/application/hifz_mushaf_providers.dart';
import '../../../hifz/domain/hifz_mushaf_page.dart';
import '../../../hifz/domain/hifz_reading_mode.dart';
import '../../application/reader_state.dart';
import '../../domain/quran_font_preference.dart';
import '../../domain/quran_page_window.dart';
import 'quran_strict_mushaf_surface.dart';

class QuranStrictReaderBody extends ConsumerStatefulWidget {
  const QuranStrictReaderBody({
    required this.state,
    required this.font,
    required this.activeAyahKey,
    required this.activeWordPosition,
    required this.onPageChanged,
    required this.onWordTap,
    required this.onWordLongPress,
    required this.onAyahTap,
    super.key,
  });

  final ReaderState state;
  final QuranFontPreference font;
  final String? activeAyahKey;
  final int? activeWordPosition;
  final ValueChanged<int> onPageChanged;
  final void Function(String ayahKey, int wordPosition) onWordTap;
  final void Function(String ayahKey, int wordPosition) onWordLongPress;
  final ValueChanged<String> onAyahTap;

  @override
  ConsumerState<QuranStrictReaderBody> createState() =>
      _QuranStrictReaderBodyState();
}

class _QuranStrictReaderBodyState extends ConsumerState<QuranStrictReaderBody> {
  late final PageController _pageController;
  final Map<int, Future<_StrictPageLoad>> _loads =
      <int, Future<_StrictPageLoad>>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _pageIndex(widget.state.currentPage),
    );
  }

  @override
  void didUpdateWidget(covariant QuranStrictReaderBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.font != widget.font) {
      _loads.clear();
    }
    if (oldWidget.state.currentPage != widget.state.currentPage) {
      _syncController(widget.state.currentPage);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _pageIndex(int page) => page - widget.state.firstPage;

  void _syncController(int page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final target = _pageIndex(page);
      if (_pageController.page?.round() != target) {
        _pageController.jumpToPage(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: ValueKey('quran-strict-reader-${widget.font.name}'),
      controller: _pageController,
      itemCount: widget.state.lastPage - widget.state.firstPage + 1,
      onPageChanged: (index) {
        final page = widget.state.firstPage + index;
        if (page != widget.state.currentPage) widget.onPageChanged(page);
      },
      itemBuilder: (context, index) {
        final page = widget.state.firstPage + index;
        final fallbackWindow = widget.state.windows[page];
        if (fallbackWindow == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _pageSlot(page, fallbackWindow);
      },
    );
  }

  Widget _pageSlot(int page, QuranPageWindow fallbackWindow) {
    final future = _loads.putIfAbsent(page, () => _loadPage(page));
    return FutureBuilder<_StrictPageLoad>(
      future: future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null) {
          return QuranStrictMushafSurface(
            page: data.page,
            palette: HifzMushafPalette.light,
            generation: Object.hash(widget.font, page) & 0x7fffffff,
            pageFontUri: data.fontUri,
            fallbackWindow: fallbackWindow,
            fontLoader: data.fontError == null
                ? null
                : (_) async => throw data.fontError!,
            activeAyahKey: widget.activeAyahKey,
            activeWordPosition: widget.activeWordPosition,
            onRetry: () => _retry(page),
            onWordTap: widget.onWordTap,
            onWordLongPress: widget.onWordLongPress,
            onAyahTap: widget.onAyahTap,
          );
        }

        if (snapshot.hasError) {
          final variant = widget.font.mushafVariant!;
          return QuranStrictMushafSurface(
            page: HifzMushafPage(page: page, variant: variant, lines: const []),
            palette: HifzMushafPalette.light,
            generation: Object.hash(widget.font, page) & 0x7fffffff,
            pageFontUri: Uri.parse('unavailable://qcf-page/$page'),
            fallbackWindow: fallbackWindow,
            fontLoader: (_) async => throw snapshot.error!,
            onRetry: () => _retry(page),
            onWordTap: widget.onWordTap,
            onWordLongPress: widget.onWordLongPress,
            onAyahTap: widget.onAyahTap,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<_StrictPageLoad> _loadPage(int page) async {
    final variant = widget.font.mushafVariant;
    if (variant == null) {
      throw StateError('Strict Quran reader requires a QCF font.');
    }

    final pageRepository = ref.read(hifzMushafPageRepositoryProvider);
    if (variant == QuranMushafVariant.qcfV2 &&
        !await pageRepository.isVariantAvailable(variant)) {
      throw StateError('QCF V2 Quran page data is not installed.');
    }

    final mushafPage = await pageRepository.loadPage(
      variant: variant,
      page: page,
    );
    final fontRepository = ref.read(
      quranPageFontRepositoryProvider(widget.font),
    );
    Object? fontError;
    Uri fontUri;
    try {
      fontUri = await fontRepository.ensurePageFont(page);
      unawaited(fontRepository.prefetchNeighbors(page));
    } on Object catch (error) {
      fontError = error;
      fontUri = Uri.parse('unavailable://qcf-page/$page');
    }

    return _StrictPageLoad(
      page: mushafPage,
      fontUri: fontUri,
      fontError: fontError,
    );
  }

  void _retry(int page) {
    setState(() {
      _loads.remove(page);
    });
  }
}

class _StrictPageLoad {
  const _StrictPageLoad({
    required this.page,
    required this.fontUri,
    required this.fontError,
  });

  final HifzMushafPage page;
  final Uri fontUri;
  final Object? fontError;
}
