import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'mushaf_renderer_message.dart';
import 'mushaf_webview_driver.dart';

NavigationDecision mushafNavigationDecision(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return NavigationDecision.prevent;
  return uri.scheme == 'file' || uri.scheme == 'about'
      ? NavigationDecision.navigate
      : NavigationDecision.prevent;
}

class QuranMushafWebView extends StatefulWidget {
  const QuranMushafWebView({
    required this.onEvent,
    required this.onDriverReady,
    this.onDiagnostic,
    super.key,
  });

  final ValueChanged<MushafRendererEvent> onEvent;
  final ValueChanged<MushafWebViewDriver> onDriverReady;
  final MushafRendererDiagnostic? onDiagnostic;

  @override
  State<QuranMushafWebView> createState() => _QuranMushafWebViewState();
}

class _QuranMushafWebViewState extends State<QuranMushafWebView> {
  late final WebViewController _controller;
  late final ControllerMushafWebViewDriver _driver;
  late final MushafRendererChannel _channel;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _driver = ControllerMushafWebViewDriver(
      _WebViewControllerAdapter(_controller),
    );
    _channel = MushafRendererChannel(
      onEvent: widget.onEvent,
      onDiagnostic: widget.onDiagnostic,
    );
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await _controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) =>
              mushafNavigationDecision(request.url),
        ),
      );
      await _controller.addJavaScriptChannel(
        'MushafBridge',
        onMessageReceived: (message) => _channel.onMessage(message.message),
      );
      await _driver.loadRenderer();
      if (mounted) widget.onDriverReady(_driver);
    } on Object catch (error) {
      widget.onDiagnostic?.call(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

class _WebViewControllerAdapter implements MushafJavaScriptController {
  const _WebViewControllerAdapter(this.controller);

  final WebViewController controller;

  @override
  Future<void> loadFlutterAsset(String key) {
    return controller.loadFlutterAsset(key);
  }

  @override
  Future<void> runJavaScript(String javaScript) {
    return controller.runJavaScript(javaScript);
  }
}
