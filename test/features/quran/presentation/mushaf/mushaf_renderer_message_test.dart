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
