import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Hifz Mushaf CSS grows and wraps instead of shrinking to viewport', () {
    final css = File('assets/mushaf/renderer/mushaf.css').readAsStringSync();

    expect(css, contains('overflow-y: auto'));
    expect(css, contains('flex-wrap: wrap'));
    expect(css, contains('var(--hifz-font-size)'));
    expect(css, contains('var(--hifz-line-height)'));
    expect(css, isNot(contains('font-size: clamp(18px, 5.6vw, 38px)')));
    expect(css, isNot(contains('transform: scale')));
  });

  test('renderer exposes a live typography command', () {
    final js = File('assets/mushaf/renderer/mushaf.js').readAsStringSync();

    expect(js, contains('function setTypography'));
    expect(js, contains('showTajweedColors'));
    expect(js, contains('setProperty'));
    expect(js, contains('setTypography,'));
  });
}
