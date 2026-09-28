import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String html;
  late String css;
  late String js;

  setUpAll(() async {
    html = await File('assets/mushaf/renderer/index.html').readAsString();
    css = await File('assets/mushaf/renderer/mushaf.css').readAsString();
    js = await File('assets/mushaf/renderer/mushaf.js').readAsString();
  });

  test('renderer CSP allows only bundled self assets and data fonts', () {
    expect(html, contains('Content-Security-Policy'));
    expect(html, contains("default-src 'none'"));
    expect(html, contains("style-src 'self' 'unsafe-inline'"));
    expect(html, contains("script-src 'self' 'unsafe-inline'"));
    expect(html, contains('font-src data:'));
    expect(html, isNot(contains('http:')));
    expect(html, isNot(contains('https:')));
    expect(html, contains('mushaf.css'));
    expect(html, contains('mushaf.js'));
  });

  test(
    'renderer exposes exact QPC palette families and playback highlight',
    () {
      expect(css, contains('@font-palette-values --Light'));
      expect(css, contains('@font-palette-values --Dark'));
      expect(css, contains('@font-palette-values --Sepia'));
      expect(css, contains('@font-palette-values --Black'));
      for (var palette = 1; palette <= 6; palette++) {
        expect(css, contains('@font-palette-values --P$palette'));
      }
      expect(css, contains('.word.active-word'));
      expect(css, contains('.active-ayah'));
      expect(css, contains('QcfV4TajweedPage'));
      expect(css, contains('QcfV2Page'));
      expect(css, contains('QuranUnicodeHafs'));
      expect(js, contains("payload.variant === 'qcfV4Tajweed'"));
      expect(js, contains("payload.variant === 'qcfV2'"));
      expect(js, contains('unicodeFallback'));
      expect(js, isNot(contains('digitalKhattV2')));
      expect(js, isNot(contains('qpcV4Tajweed')));
      expect(css, contains('#fff7ea'));
      expect(css, contains('#343a40'));
    },
  );

  test('renderer keeps fixed lines and special Mushaf rows explicit', () {
    expect(css, contains('.mushaf-line.centered'));
    expect(css, contains('.mushaf-line.justified'));
    expect(js, contains('isCentered'));
    expect(js, contains('surah_name'));
    expect(js, contains('surah'));
    expect(js, contains('padStart(3'));
    expect(js, contains('﷽'));
  });

  test(
    'renderer emits word and ayah interactions with typed data attributes',
    () {
      expect(js, contains('data-ayah-key'));
      expect(js, contains('data-word-position'));
      expect(js, contains('wordTap'));
      expect(js, contains('wordLongPress'));
      expect(js, contains('ayahTap'));
      expect(js, contains('MushafBridge.postMessage'));
    },
  );


  test('Hifz playback styling distinguishes ayah, word, and meaning bubble', () {
    expect(css, contains('.word.active-word'));
    expect(css, contains('.word.active-ayah:not(.active-word)'));
    expect(css, contains('var(--active-accent) 13%'));
    expect(css, contains('.playback-meaning-bubble'));
    expect(js, contains('showMeaningBubble'));
    expect(js, contains('postPlaybackTarget'));
    expect(js, contains("querySelectorAll('.word.active-word')"));
    expect(js, contains('clearMeaningBubble();'));
    expect(js, contains('activeWord.dataset.ayahKey === ayahKey'));
  });

  test('continuous layout disables nested scrolling without changing page styles', () {
    expect(css, contains('body[data-continuous-layout="on"]'));
    expect(css, contains('overflow-y: hidden'));
    expect(js, contains('continuousLayout'));
    expect(js, contains('postPageMetrics'));
    expect(js, contains('if (state.continuousLayout) return;'));
  });

  test('renderer publishes the complete Flutter command surface', () {
    expect(js, contains('renderPage'));
    expect(js, contains('setPalette'));
    expect(js, contains('setActiveWord'));
    expect(js, contains('setActiveAyah'));
    expect(js, contains('setRange'));
    expect(js, contains('clearPlaybackHighlight'));
    expect(js, contains('pageReady'));
    expect(js, contains('rendererError'));
  });

  test(
    'renderer accepts only supplied data-font URLs, not remote font URLs',
    () {
      expect(js, contains('data:font/'));
      expect(js, isNot(contains('https://')));
      expect(js, isNot(contains('http://')));
      expect(js, isNot(contains('/home/')));
    },
  );
}
