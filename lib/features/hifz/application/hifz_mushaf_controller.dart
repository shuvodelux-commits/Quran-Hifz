import 'dart:async';

import '../domain/hifz_mushaf_page.dart';
import '../domain/hifz_mushaf_page_repository.dart';
import '../domain/hifz_reading_mode.dart';
import '../domain/mushaf_page_font_repository.dart';

sealed class HifzMushafState {
  const HifzMushafState();
}

final class HifzMushafInitial extends HifzMushafState {
  const HifzMushafInitial();
}

final class HifzMushafLoading extends HifzMushafState {
  const HifzMushafLoading({required this.page, required this.variant});

  final int page;
  final HifzMushafVariant variant;
}

final class HifzMushafReady extends HifzMushafState {
  const HifzMushafReady({
    required this.page,
    required this.palette,
    required this.generation,
    required this.fontUri,
  });

  final HifzMushafPage page;
  final HifzMushafPalette palette;
  final int generation;
  final Uri fontUri;
}

final class HifzMushafUnavailable extends HifzMushafState {
  const HifzMushafUnavailable(this.reason);

  final String reason;
}

final class HifzMushafFailure extends HifzMushafState {
  const HifzMushafFailure({required this.page, required this.error});

  final int page;
  final Object error;
}

typedef HifzMushafVariantChanged =
    Future<void> Function(HifzMushafVariant variant);
typedef HifzMushafPaletteChanged =
    Future<void> Function(HifzMushafPalette palette);

class HifzMushafController {
  HifzMushafController({
    required HifzMushafPageRepository pageRepository,
    required MushafPageFontRepository fontRepository,
    HifzMushafVariant initialVariant = HifzMushafVariant.qpcV4Tajweed,
    HifzMushafPalette initialPalette = HifzMushafPalette.light,
    HifzMushafVariantChanged? onVariantChanged,
    HifzMushafPaletteChanged? onPaletteChanged,
  }) : _pageRepository = pageRepository,
       _fontRepository = fontRepository,
       _variant = initialVariant,
       _palette = initialPalette,
       _onVariantChanged = onVariantChanged,
       _onPaletteChanged = onPaletteChanged;

  static final Uri digitalKhattFontAssetUri = Uri(
    scheme: 'asset',
    path: 'assets/mushaf/fonts/DigitalKhattV2.otf',
  );

  final HifzMushafPageRepository _pageRepository;
  final MushafPageFontRepository _fontRepository;
  final HifzMushafVariantChanged? _onVariantChanged;
  final HifzMushafPaletteChanged? _onPaletteChanged;
  final StreamController<HifzMushafState> _stateChanges =
      StreamController<HifzMushafState>.broadcast();

  HifzMushafState _state = const HifzMushafInitial();
  HifzMushafVariant _variant;
  HifzMushafPalette _palette;
  int _generation = 0;
  int? _currentPage;
  int? _lastRequestedPage;
  int _requestToken = 0;
  bool _disposed = false;

  HifzMushafState get state => _state;
  HifzMushafVariant get variant => _variant;
  HifzMushafPalette get palette => _palette;
  HifzMushafPalette get effectiveCurrentPalette =>
      effectivePalette(_variant, _palette);
  int get generation => _generation;
  int? get currentPage => _currentPage;

  Stream<HifzMushafState> get states async* {
    yield _state;
    yield* _stateChanges.stream;
  }

  Future<void> openPage(int page) async {
    _ensureAlive();
    if (page < 1 || page > 604) {
      throw RangeError.range(page, 1, 604, 'page');
    }

    _lastRequestedPage = page;
    final token = ++_requestToken;
    _emit(HifzMushafLoading(page: page, variant: _variant));

    try {
      if (_variant == HifzMushafVariant.digitalKhattV2) {
        final available = await _pageRepository.isVariantAvailable(_variant);
        if (!_isCurrent(token)) return;
        if (!available) {
          _emit(
            const HifzMushafUnavailable(
              'Digital Khatt V2 exact Quran script is not installed.',
            ),
          );
          return;
        }

        final mushafPage = await _pageRepository.loadPage(
          variant: _variant,
          page: page,
        );
        if (!_isCurrent(token)) return;
        _publishReady(page: mushafPage, fontUri: digitalKhattFontAssetUri);
        return;
      }

      final fontUri = await _fontRepository.ensurePageFont(page);
      if (!_isCurrent(token)) return;
      final mushafPage = await _pageRepository.loadPage(
        variant: _variant,
        page: page,
      );
      if (!_isCurrent(token)) return;
      _publishReady(page: mushafPage, fontUri: fontUri);

      try {
        await _fontRepository.prefetchNeighbors(page);
      } on Object {
        // Neighbor prefetch is opportunistic and never blocks the ready page.
      }
    } on Object catch (error) {
      if (!_isCurrent(token)) return;
      _emit(HifzMushafFailure(page: page, error: error));
    }
  }

  Future<void> retry() async {
    final page = _lastRequestedPage ?? _currentPage;
    if (page == null) return;
    await openPage(page);
  }

  Future<void> selectVariant(HifzMushafVariant variant) async {
    _ensureAlive();
    _variant = variant;
    await _onVariantChanged?.call(variant);

    if (variant == HifzMushafVariant.digitalKhattV2) {
      final available = await _pageRepository.isVariantAvailable(variant);
      if (!available) {
        ++_requestToken;
        _emit(
          const HifzMushafUnavailable(
            'Digital Khatt V2 exact Quran script is not installed.',
          ),
        );
        return;
      }
    }

    final page = _currentPage ?? _lastRequestedPage;
    if (page != null) {
      await openPage(page);
    } else {
      _emit(const HifzMushafInitial());
    }
  }

  Future<void> setPalette(HifzMushafPalette palette) async {
    _ensureAlive();
    if (!palette.supports(_variant)) {
      throw ArgumentError.value(
        palette,
        'palette',
        'Palette is not supported by ' + _variant.name + '.',
      );
    }
    _palette = palette;
    await _onPaletteChanged?.call(palette);

    final current = _state;
    if (current is HifzMushafReady) {
      _emit(
        HifzMushafReady(
          page: current.page,
          palette: effectiveCurrentPalette,
          generation: current.generation,
          fontUri: current.fontUri,
        ),
      );
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    ++_requestToken;
    unawaited(_stateChanges.close());
  }

  void _publishReady({required HifzMushafPage page, required Uri fontUri}) {
    _currentPage = page.page;
    _generation++;
    _emit(
      HifzMushafReady(
        page: page,
        palette: effectiveCurrentPalette,
        generation: _generation,
        fontUri: fontUri,
      ),
    );
  }

  bool _isCurrent(int token) => !_disposed && token == _requestToken;

  void _emit(HifzMushafState next) {
    if (_disposed) return;
    _state = next;
    _stateChanges.add(next);
  }

  void _ensureAlive() {
    if (_disposed) {
      throw StateError('HifzMushafController has been disposed.');
    }
  }
}
