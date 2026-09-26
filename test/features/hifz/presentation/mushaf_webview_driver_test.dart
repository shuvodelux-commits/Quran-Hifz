import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_mushaf_page.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reading_mode.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_mushaf_webview.dart';
import 'package:quran_hifz/features/hifz/presentation/mushaf_renderer_message.dart';
import 'package:quran_hifz/features/hifz/presentation/mushaf_webview_driver.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  test(
    'typed commands encode arguments instead of interpolating them',
    () async {
      await driver.setActiveWord("2:255');window.evil=true;//", 3);

      final js = controller.lastScript!;
      expect(js, isNot(contains('window.evil=true')));
      expect(_decodeFirstArgumentList(js), ["2:255');window.evil=true;//", 3]);
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

MushafRenderPayload _fixture({required String display}) {
  return MushafRenderPayload(
    page: HifzMushafPage(
      page: 2,
      variant: QuranMushafVariant.qcfV4Tajweed,
      lines: [
        HifzMushafLine(
          lineNumber: 3,
          type: HifzMushafLineType.ayah,
          isCentered: true,
          tokens: [
            HifzMushafToken(
              wordIndex: 37,
              type: HifzMushafTokenType.word,
              display: display,
              ayahKey: '2:1',
              wordPosition: 1,
            ),
          ],
        ),
      ],
    ),
    palette: HifzMushafPalette.sepia,
    generation: 7,
    pageFontBytes: const [0x77, 0x4f, 0x46, 0x32, 1, 2, 3],
    surahFontBytes: const [1, 2, 3],
    bismillahFontBytes: const [4, 5, 6],
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
