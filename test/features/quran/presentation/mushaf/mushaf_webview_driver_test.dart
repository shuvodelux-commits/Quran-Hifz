import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_palette.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/quran_mushaf_webview.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/mushaf_renderer_message.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/mushaf_webview_driver.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';

void main() {
  late _FakeController controller;
  late List<MushafRendererEvent> events;
  late List<Object> diagnostics;
  late MushafRendererChannel channel;
  late ControllerMushafWebViewDriver driver;

  setUp(() {
    controller = _FakeController();
    events = <MushafRendererEvent>[];
    diagnostics = <Object>[];
    channel = MushafRendererChannel(
      onEvent: events.add,
      onDiagnostic: diagnostics.add,
    );
    driver = ControllerMushafWebViewDriver(controller);
  });


  test('renderer readiness ignores about:blank and fires once for renderer asset', () {
    final gate = MushafWebViewLoadGate();

    expect(gate.onPageFinished('about:blank'), isFalse);

    gate.markRendererLoadRequested();
    expect(gate.onPageFinished('about:blank'), isFalse);
    expect(
      gate.onPageFinished(
        'file:///android_asset/flutter_assets/assets/mushaf/renderer/index.html',
      ),
      isTrue,
    );
    expect(
      gate.onPageFinished(
        'file:///android_asset/flutter_assets/assets/mushaf/renderer/index.html',
      ),
      isFalse,
    );
  });

  test('loadRenderer loads only the bundled renderer asset', () async {
    await driver.loadRenderer();

    expect(controller.loadedAssets, ['assets/mushaf/renderer/index.html']);
  });

  test(
    'renderPage base64 encodes Quran text instead of concatenating JS',
    () async {
      final payload = _fixture(display: "x');window.evil=true;//");

      await driver.renderPage(payload);

      final js = controller.lastScript!;
      expect(js, contains('JSON.parse'));
      expect(js, contains('atob'));
      expect(js, isNot(contains('window.evil=true')));

      final decoded = _decodeFirstArgumentList(js);
      final page = decoded.single as Map<String, dynamic>;
      final lines = page['lines']! as List<dynamic>;
      final tokens =
          (lines.single as Map<String, dynamic>)['tokens']! as List<dynamic>;
      expect(
        (tokens.single as Map<String, dynamic>)['display'],
        "x');window.evil=true;//",
      );
      expect(page['fontDataUrl'], startsWith('data:font/woff2;base64,'));
    },
  );

  test('QCF V2 and V4 use distinct page font family identities', () {
    final v2 = _fixture(
      display: 'A',
      variant: QuranMushafVariant.qcfV2,
    ).toRendererJson();
    final v4 = _fixture(
      display: 'B',
      variant: QuranMushafVariant.qcfV4Tajweed,
    ).toRendererJson();

    expect(v2['pageFontFamily'], 'QcfV2Page');
    expect(v4['pageFontFamily'], 'QcfV4TajweedPage');
    expect(v2['pageFontFamily'], isNot(v4['pageFontFamily']));
  });


  test('continuous Mushaf payload preserves typography and opts into natural height', () {
    final payload = _fixture(
      display: 'A',
      fontSize: 48,
      lineHeight: 1.8,
      continuousLayout: true,
    ).toRendererJson();

    expect(payload['fontSize'], 48);
    expect(payload['lineHeight'], 1.8);
    expect(payload['continuousLayout'], isTrue);
  });

  test('ayah end carries Unicode Hafs fallback text', () {
    final payload = MushafRenderPayload(
      page: QcfMushafPage(
        page: 2,
        variant: QuranMushafVariant.qcfV4Tajweed,
        lines: const [
          QcfMushafLine(
            lineNumber: 3,
            type: QcfMushafLineType.ayah,
            isCentered: true,
            tokens: [
              QcfMushafToken(
                wordIndex: 38,
                type: QcfMushafTokenType.end,
                display: 'glyph-end',
                unicodeFallback: '١',
                ayahKey: '2:1',
              ),
            ],
          ),
        ],
      ),
      palette: QuranMushafPalette.light,
      generation: 1,
      pageFontBytes: const [1],
      surahFontBytes: const [2],
      bismillahFontBytes: const [3],
      endMarkerFontBytes: const [4],
      fontSize: 56,
      lineHeight: 2.4,
      showTajweedColors: false,
    ).toRendererJson();

    final lines = payload['lines']! as List<Object?>;
    final tokens =
        (lines.single as Map<String, Object?>)['tokens']! as List<Object?>;
    expect((tokens.single as Map<String, Object?>)['unicodeFallback'], '١');
    expect(payload['endMarkerFontFamily'], 'QuranUnicodeHafs');
    expect(payload['fontSize'], 56);
    expect(payload['lineHeight'], 2.4);
    expect(payload['showTajweedColors'], isFalse);
  });

  test('setTypography sends exact requested Hifz values', () async {
    await driver.setTypography(
      fontSize: 48,
      lineHeight: 1.8,
      showTajweedColors: false,
    );

    expect(controller.lastScript, contains('setTypography'));
    expect(_decodeFirstArgumentList(controller.lastScript!), [48.0, 1.8, false]);
  });

  test(
    'typed commands encode arguments and Bangla meaning without interpolation',
    () async {
      await driver.setActiveWord(
        "2:255');window.evil=true;//",
        3,
        banglaMeaning: "আল্লাহ');window.evil=true;//",
      );

      final js = controller.lastScript!;
      expect(js, isNot(contains('window.evil=true')));
      expect(
        _decodeFirstArgumentList(js),
        [
          "2:255');window.evil=true;//",
          3,
          "আল্লাহ');window.evil=true;//",
        ],
      );
    },
  );

  test('ignores unknown bridge events without state callbacks', () {
    channel.onMessage('{"type":"openUrl","url":"https://example.com"}');

    expect(events, isEmpty);
    expect(diagnostics, hasLength(1));
  });

  test('ignores invalid word coordinate', () {
    channel.onMessage('{"type":"wordTap","ayahKey":"2:255","wordPosition":0}');

    expect(events, isEmpty);
    expect(diagnostics, hasLength(1));
  });

  test('delivers valid renderer events', () {
    channel.onMessage('{"type":"wordTap","ayahKey":"2:255","wordPosition":3}');

    expect(events, [const MushafWordTapEvent('2:255', 3)]);
    expect(diagnostics, isEmpty);
  });

  test('allows only local renderer navigation schemes', () {
    expect(
      mushafNavigationDecision('file:///android_asset/flutter_assets/a'),
      NavigationDecision.navigate,
    );
    expect(
      mushafNavigationDecision('about:blank'),
      NavigationDecision.navigate,
    );
    expect(
      mushafNavigationDecision('https://example.com'),
      NavigationDecision.prevent,
    );
    expect(
      mushafNavigationDecision('javascript:alert(1)'),
      NavigationDecision.prevent,
    );
    expect(mushafNavigationDecision('not a uri'), NavigationDecision.prevent);
  });
}

MushafRenderPayload _fixture({
  required String display,
  QuranMushafVariant variant = QuranMushafVariant.qcfV4Tajweed,
  double fontSize = 32,
  double lineHeight = 1.35,
  bool showTajweedColors = true,
  bool continuousLayout = false,
}) {
  return MushafRenderPayload(
    page: QcfMushafPage(
      page: 2,
      variant: variant,
      lines: [
        QcfMushafLine(
          lineNumber: 3,
          type: QcfMushafLineType.ayah,
          isCentered: true,
          tokens: [
            QcfMushafToken(
              wordIndex: 37,
              type: QcfMushafTokenType.word,
              display: display,
              ayahKey: '2:1',
              wordPosition: 1,
            ),
          ],
        ),
      ],
    ),
    palette: QuranMushafPalette.sepia,
    generation: 7,
    pageFontBytes: const [0x77, 0x4f, 0x46, 0x32, 1, 2, 3],
    surahFontBytes: const [1, 2, 3],
    bismillahFontBytes: const [4, 5, 6],
    endMarkerFontBytes: const [7, 8, 9],
    fontSize: fontSize,
    lineHeight: lineHeight,
    showTajweedColors: showTajweedColors,
    continuousLayout: continuousLayout,
  );
}

List<dynamic> _decodeFirstArgumentList(String script) {
  final match = RegExp(r"atob\('([^']+)'\)").firstMatch(script);
  expect(match, isNotNull);
  final bytes = base64Decode(match!.group(1)!);
  return jsonDecode(utf8.decode(bytes))! as List<dynamic>;
}

class _FakeController implements MushafJavaScriptController {
  final loadedAssets = <String>[];
  final scripts = <String>[];

  String? get lastScript => scripts.isEmpty ? null : scripts.last;

  @override
  Future<void> loadFlutterAsset(String key) async {
    loadedAssets.add(key);
  }

  @override
  Future<void> runJavaScript(String javaScript) async {
    scripts.add(javaScript);
  }
}
