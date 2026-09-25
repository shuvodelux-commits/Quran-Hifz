import 'dart:convert';

import '../domain/hifz_mushaf_page.dart';
import '../domain/hifz_reading_mode.dart';
import 'mushaf_renderer_message.dart';

abstract interface class MushafJavaScriptController {
  Future<void> loadFlutterAsset(String key);

  Future<void> runJavaScript(String javaScript);
}

abstract interface class MushafWebViewDriver {
  Future<void> loadRenderer();

  Future<void> renderPage(MushafRenderPayload payload);

  Future<void> setPalette(HifzMushafPalette palette);

  Future<void> setActiveWord(String ayahKey, int wordPosition);

  Future<void> setActiveAyah(String ayahKey);

  Future<void> setRange(String? startAyahKey, String? endAyahKey);

  Future<void> clearPlaybackHighlight();
}

class MushafRenderPayload {
  const MushafRenderPayload({
    required this.page,
    required this.palette,
    required this.generation,
    required this.pageFontBytes,
    required this.surahFontBytes,
    required this.bismillahFontBytes,
  });

  final HifzMushafPage page;
  final HifzMushafPalette palette;
  final int generation;
  final List<int> pageFontBytes;
  final List<int> surahFontBytes;
  final List<int> bismillahFontBytes;

  Map<String, Object?> toRendererJson() {
    if (generation < 0) {
      throw const FormatException('Mushaf generation must be non-negative.');
    }
    return <String, Object?>{
      'variant': page.variant.name,
      'page': page.page,
      'palette': palette.name,
      'generation': generation,
      'fontDataUrl': _fontDataUrl(
        pageFontBytes,
        page.variant == HifzMushafVariant.qpcV4Tajweed ? 'woff2' : 'otf',
      ),
      'surahFontDataUrl': _fontDataUrl(surahFontBytes, 'ttf'),
      'bismillahFontDataUrl': _fontDataUrl(bismillahFontBytes, 'otf'),
      'lines': [
        for (final line in page.lines)
          <String, Object?>{
            'lineNumber': line.lineNumber,
            'type': _lineTypeName(line.type),
            'isCentered': line.isCentered,
            if (line.surahNumber != null) 'surahNumber': line.surahNumber,
            'tokens': [
              for (final token in line.tokens)
                <String, Object?>{
                  'wordIndex': token.wordIndex,
                  'type': token.type.name,
                  'display': token.display,
                  if (token.ayahKey != null) 'ayahKey': token.ayahKey,
                  if (token.wordPosition != null)
                    'wordPosition': token.wordPosition,
                },
            ],
          },
      ],
    };
  }

  static String _lineTypeName(HifzMushafLineType type) => switch (type) {
    HifzMushafLineType.ayah => 'ayah',
    HifzMushafLineType.basmallah => 'basmallah',
    HifzMushafLineType.surahName => 'surah_name',
  };
  static String _fontDataUrl(List<int> bytes, String subtype) {
    if (bytes.isEmpty) {
      throw const FormatException('Mushaf font bytes must not be empty.');
    }
    return 'data:font/' + subtype + ';base64,' + base64Encode(bytes);
  }
}

class ControllerMushafWebViewDriver implements MushafWebViewDriver {
  ControllerMushafWebViewDriver(this._controller);

  static const rendererAsset = 'assets/mushaf/renderer/index.html';

  final MushafJavaScriptController _controller;

  @override
  Future<void> loadRenderer() => _controller.loadFlutterAsset(rendererAsset);

  @override
  Future<void> renderPage(MushafRenderPayload payload) {
    return _runEncoded('renderPage', <Object?>[payload.toRendererJson()]);
  }

  @override
  Future<void> setPalette(HifzMushafPalette palette) {
    return _runEncoded('setPalette', <Object?>[palette.name]);
  }

  @override
  Future<void> setActiveWord(String ayahKey, int wordPosition) {
    return _runEncoded('setActiveWord', <Object?>[ayahKey, wordPosition]);
  }

  @override
  Future<void> setActiveAyah(String ayahKey) {
    return _runEncoded('setActiveAyah', <Object?>[ayahKey]);
  }

  @override
  Future<void> setRange(String? startAyahKey, String? endAyahKey) {
    return _runEncoded('setRange', <Object?>[startAyahKey, endAyahKey]);
  }

  @override
  Future<void> clearPlaybackHighlight() {
    return _runEncoded('clearPlaybackHighlight', const <Object?>[]);
  }

  Future<void> _runEncoded(String method, List<Object?> arguments) {
    const allowedMethods = <String>{
      'renderPage',
      'setPalette',
      'setActiveWord',
      'setActiveAyah',
      'setRange',
      'clearPlaybackHighlight',
    };
    if (!allowedMethods.contains(method)) {
      throw ArgumentError.value(method, 'method');
    }
    final encoded = base64Encode(utf8.encode(jsonEncode(arguments)));
    final script =
        "(()=>{const raw=atob('" +
        encoded +
        "');const bytes=Uint8Array.from(raw,c=>c.charCodeAt(0));" +
        "const args=JSON.parse(new TextDecoder().decode(bytes));" +
        "return window.mushaf." +
        method +
        "(...args);})()";
    return _controller.runJavaScript(script);
  }
}

typedef MushafRendererDiagnostic = void Function(Object diagnostic);

class MushafRendererChannel {
  const MushafRendererChannel({required this.onEvent, this.onDiagnostic});

  final void Function(MushafRendererEvent event) onEvent;
  final MushafRendererDiagnostic? onDiagnostic;

  void onMessage(String raw) {
    try {
      onEvent(MushafRendererEvent.parse(raw));
    } on Object catch (error) {
      onDiagnostic?.call(error);
    }
  }
}
