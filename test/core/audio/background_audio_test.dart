import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/audio/background_audio.dart';

void main() {
  test(
    'background audio bootstrap delegates to injected initializer',
    () async {
      var calls = 0;

      await initializeBackgroundAudio(
        initializer: () async {
          calls++;
        },
      );

      expect(calls, 1);
    },
  );

  testWidgets('deferred bootstrap waits until the first Flutter frame', (
    tester,
  ) async {
    var calls = 0;
    final initialization = initializeBackgroundAudioAfterFirstFrame(
      initializer: () async {
        calls++;
      },
    );

    expect(calls, 0);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
    await initialization;

    expect(calls, 1);
  });
}
