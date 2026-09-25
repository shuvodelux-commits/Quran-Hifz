import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/application/hifz_mushaf_controller.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_mushaf_page.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_mushaf_page_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reading_mode.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/domain/mushaf_page_font_repository.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_mushaf_page_view.dart';
import 'package:quran_hifz/features/hifz/presentation/mushaf_renderer_message.dart';
import 'package:quran_hifz/features/hifz/presentation/mushaf_webview_driver.dart';

void main() {
  late _PageRepository pageRepo;
  late _FontRepository fontRepo;
  late HifzMushafController controller;
  late _FakeDriver driver;
  late _WebViewHarness webView;
  late List<(String, int)> played;
  late List<(String, int)> details;
  late List<AyahRef> selected;
  late int toggleCalls;
  late int regularCalls;

  setUp(() async {
    pageRepo = _PageRepository();
    fontRepo = _FontRepository();
    controller = HifzMushafController(
      pageRepository: pageRepo,
      fontRepository: fontRepo,
    );
    await controller.openPage(2);
    driver = _FakeDriver();
    webView = _WebViewHarness(driver);
    played = <(String, int)>[];
    details = <(String, int)>[];
    selected = <AyahRef>[];
    toggleCalls = 0;
    regularCalls = 0;
  });

  tearDown(() {
    controller.dispose();
  });

  Widget _app({
    String? activeAyah,
    int? activeWord,
    bool playbackRunning = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HifzMushafPageView(
          controller: controller,
          activeAyahKey: activeAyah,
          activeWordPosition: activeWord,
          playbackRunning: playbackRunning,
          autoFollow: true,
          selectedStartAyah: const AyahRef(surahNumber: 2, ayahNumber: 1),
          selectedEndAyah: const AyahRef(surahNumber: 2, ayahNumber: 5),
          onWordTap: (ayahKey, position) => played.add((ayahKey, position)),
          onWordLongPress: (ayahKey, position) =>
              details.add((ayahKey, position)),
          onAyahSelected: selected.add,
          onToggleControls: () => toggleCalls++,
          onUseRegularHifz: () => regularCalls++,
          webViewBuilder: webView.build,
          fontLoader: (_) async => const HifzMushafRenderFonts(
            pageFontBytes: [0x77, 0x4f, 0x46, 0x32, 1],
            surahFontBytes: [1, 2, 3],
            bismillahFontBytes: [4, 5, 6],
          ),
        ),
      ),
    );
  }

  testWidgets('active word sends exact ayah and position highlight', (
    tester,
  ) async {
    await tester.pumpWidget(_app(activeAyah: '2:255', activeWord: 3));
    await tester.pumpAndSettle();

    expect(driver.activeAyahs.last, '2:255');
    expect(driver.activeWords.last, ('2:255', 3));
  });

  testWidgets('bridge word tap and long press preserve exact coordinates', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    webView.emit(const MushafWordTapEvent('2:255', 3));
    webView.emit(const MushafWordLongPressEvent('2:255', 4));
    await tester.pump();

    expect(played, [('2:255', 3)]);
    expect(details, [('2:255', 4)]);
  });

  testWidgets('ayah-end tap selects range only while playback is idle', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    webView.emit(const MushafAyahTapEvent('2:255'));
    await tester.pump();
    expect(selected, [const AyahRef(surahNumber: 2, ayahNumber: 255)]);

    selected.clear();
    await tester.pumpWidget(_app(playbackRunning: true));
    await tester.pumpAndSettle();
    webView.emit(const MushafAyahTapEvent('2:256'));
    await tester.pump();

    expect(selected, isEmpty);
  });

  testWidgets('horizontal swipe requests the adjacent Mushaf page', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('hifz-mushaf-page-view')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(controller.currentPage, 3);
  });

  testWidgets('blank page tap toggles Hifz controls', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('hifz-mushaf-page-tap-target')),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(toggleCalls, 1);
  });

  testWidgets('renderer failure recreates once then offers Regular Hifz', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(webView.builds, 1);

    webView.emit(
      const MushafRendererErrorEvent(code: 'FONT_LOAD', message: 'failed once'),
    );
    await tester.pumpAndSettle();
    expect(webView.builds, 2);

    webView.emit(
      const MushafRendererErrorEvent(
        code: 'FONT_LOAD',
        message: 'failed twice',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Use Regular Hifz'), findsOneWidget);
    await tester.tap(find.text('Use Regular Hifz'));
    expect(regularCalls, 1);
  });
}

class _PageRepository implements HifzMushafPageRepository {
  @override
  Future<bool> isVariantAvailable(HifzMushafVariant variant) async => true;

  @override
  Future<HifzMushafPage> loadPage({
    required HifzMushafVariant variant,
    required int page,
  }) async {
    return HifzMushafPage(
      page: page,
      variant: variant,
      lines: const <HifzMushafLine>[
        HifzMushafLine(
          lineNumber: 1,
          type: HifzMushafLineType.ayah,
          isCentered: true,
          tokens: <HifzMushafToken>[],
        ),
      ],
    );
  }

  @override
  Future<int?> pageForAyah({
    required HifzMushafVariant variant,
    required AyahRef ayah,
  }) async => 2;
}

class _FontRepository implements MushafPageFontRepository {
  @override
  Future<Uri> ensurePageFont(int page) async =>
      Uri.file('/tmp/qpc-v4/p$page.woff2');

  @override
  Future<bool> isCached(int page) async => true;

  @override
  Future<void> prefetchNeighbors(int page) async {}
}

class _FakeDriver implements MushafWebViewDriver {
  final rendered = <MushafRenderPayload>[];
  final palettes = <HifzMushafPalette>[];
  final activeWords = <(String, int)>[];
  final activeAyahs = <String>[];
  final ranges = <(String?, String?)>[];
  int clearCalls = 0;

  @override
  Future<void> clearPlaybackHighlight() async {
    clearCalls++;
  }

  @override
  Future<void> loadRenderer() async {}

  @override
  Future<void> renderPage(MushafRenderPayload payload) async {
    rendered.add(payload);
  }

  @override
  Future<void> setActiveAyah(String ayahKey) async {
    activeAyahs.add(ayahKey);
  }

  @override
  Future<void> setActiveWord(String ayahKey, int wordPosition) async {
    activeWords.add((ayahKey, wordPosition));
  }

  @override
  Future<void> setPalette(HifzMushafPalette palette) async {
    palettes.add(palette);
  }

  @override
  Future<void> setRange(String? startAyahKey, String? endAyahKey) async {
    ranges.add((startAyahKey, endAyahKey));
  }
}

class _WebViewHarness {
  _WebViewHarness(this.driver);

  final _FakeDriver driver;
  ValueChanged<MushafRendererEvent>? _onEvent;
  int builds = 0;

  Widget build(
    Key key,
    ValueChanged<MushafRendererEvent> onEvent,
    ValueChanged<MushafWebViewDriver> onDriverReady,
    MushafRendererDiagnostic onDiagnostic,
  ) {
    builds++;
    _onEvent = onEvent;
    return _FakeHost(key: key, driver: driver, onDriverReady: onDriverReady);
  }

  void emit(MushafRendererEvent event) {
    final callback = _onEvent;
    if (callback == null) throw StateError('WebView host is not mounted.');
    callback(event);
  }
}

class _FakeHost extends StatefulWidget {
  const _FakeHost({
    required this.driver,
    required this.onDriverReady,
    super.key,
  });

  final MushafWebViewDriver driver;
  final ValueChanged<MushafWebViewDriver> onDriverReady;

  @override
  State<_FakeHost> createState() => _FakeHostState();
}

class _FakeHostState extends State<_FakeHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onDriverReady(widget.driver);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: Colors.white, child: SizedBox.expand());
  }
}
