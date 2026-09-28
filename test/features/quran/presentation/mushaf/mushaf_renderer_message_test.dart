import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/mushaf_renderer_message.dart';

void main() {
  test('parses a valid word tap and ayah-end tap', () {
    final word = MushafRendererEvent.parse(
      '{"type":"wordTap","ayahKey":"2:255","wordPosition":3}',
    );
    final ayah = MushafRendererEvent.parse(
      '{"type":"ayahTap","ayahKey":"2:255"}',
    );

    expect(word, const MushafWordTapEvent('2:255', 3));
    expect(ayah, const MushafAyahTapEvent('2:255'));
  });

  test('parses pageReady and rendererError', () {
    expect(
      MushafRendererEvent.parse('{"type":"pageReady","page":2,"generation":7}'),
      const MushafPageReadyEvent(page: 2, generation: 7),
    );
    expect(
      MushafRendererEvent.parse(
        '{"type":"rendererError","code":"FONT_LOAD","message":"failed"}',
      ),
      const MushafRendererErrorEvent(code: 'FONT_LOAD', message: 'failed'),
    );
  });

  test('parses page metrics and playback target geometry', () {
    expect(
      MushafRendererEvent.parse(
        '{"type":"pageMetrics","page":2,"generation":7,"contentHeight":812.5}',
      ),
      const MushafPageMetricsEvent(
        page: 2,
        generation: 7,
        contentHeight: 812.5,
      ),
    );
    expect(
      MushafRendererEvent.parse(
        '{"type":"playbackTarget","page":2,"generation":7,"ayahKey":"2:255","wordPosition":3,"top":180.25,"bottom":224.75}',
      ),
      const MushafPlaybackTargetEvent(
        page: 2,
        generation: 7,
        ayahKey: '2:255',
        wordPosition: 3,
        top: 180.25,
        bottom: 224.75,
      ),
    );
    expect(
      MushafRendererEvent.parse(
        '{"type":"playbackTarget","page":2,"generation":7,"ayahKey":"2:255","top":160.0,"bottom":260.0}',
      ),
      const MushafPlaybackTargetEvent(
        page: 2,
        generation: 7,
        ayahKey: '2:255',
        top: 160,
        bottom: 260,
      ),
    );
  });

  test('rejects invalid renderer geometry', () {
    for (final raw in [
      '{"type":"pageMetrics","page":2,"generation":7,"contentHeight":0}',
      '{"type":"pageMetrics","page":2,"generation":7,"contentHeight":"NaN"}',
      '{"type":"playbackTarget","page":2,"generation":7,"ayahKey":"2:255","top":20.0,"bottom":10.0}',
      '{"type":"playbackTarget","page":605,"generation":7,"ayahKey":"2:255","top":10.0,"bottom":20.0}',
      '{"type":"playbackTarget","page":2,"generation":-1,"ayahKey":"2:255","top":10.0,"bottom":20.0}',
    ]) {
      expect(() => MushafRendererEvent.parse(raw), throwsFormatException);
    }
  });

  test('rejects pageReady outside 1 through 604', () {
    expect(
      () => MushafRendererEvent.parse(
        '{"type":"pageReady","page":605,"generation":1}',
      ),
      throwsFormatException,
    );
    expect(
      () => MushafRendererEvent.parse(
        '{"type":"pageReady","page":0,"generation":1}',
      ),
      throwsFormatException,
    );
  });

  test('rejects unknown events and malformed word coordinates', () {
    expect(
      () => MushafRendererEvent.parse(
        '{"type":"openUrl","url":"https://example.com"}',
      ),
      throwsFormatException,
    );
    expect(
      () => MushafRendererEvent.parse(
        '{"type":"wordTap","ayahKey":"2:255","wordPosition":0}',
      ),
      throwsFormatException,
    );
    expect(
      () => MushafRendererEvent.parse(
        '{"type":"wordLongPress","ayahKey":"bad","wordPosition":3}',
      ),
      throwsFormatException,
    );
  });

  test('rejects negative generation and oversized renderer diagnostics', () {
    expect(
      () => MushafRendererEvent.parse(
        '{"type":"pageReady","page":2,"generation":-1}',
      ),
      throwsFormatException,
    );

    final longCode = 'A' * 65;
    final longMessage = 'B' * 513;
    expect(
      () => MushafRendererEvent.parse(
        '{"type":"rendererError","code":"$longCode","message":"failed"}',
      ),
      throwsFormatException,
    );
    expect(
      () => MushafRendererEvent.parse(
        '{"type":"rendererError","code":"FONT_LOAD","message":"$longMessage"}',
      ),
      throwsFormatException,
    );
  });
}
