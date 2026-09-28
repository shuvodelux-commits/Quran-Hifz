import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_controls_bar.dart';

void main() {
  testWidgets('controls are compact, reachable, and expose the Hifz actions', (
    tester,
  ) async {
    var playPause = 0;
    var repeat = 0;
    var hide = 0;
    var finish = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: HifzControlsBar(
              status: HifzSessionStatus.idle,
              repeatIndex: 0,
              repeatTotal: 0,
              hidden: false,
              onPlayPause: () => playPause++,
              onRepeatPattern: () => repeat++,
              onToggleHidden: () => hide++,
              onFinish: () => finish++,
            ),
          ),
        ),
      ),
    );

    for (final key in const [
      'hifz-play-pause',
      'hifz-repeat-pattern',
      'hifz-toggle-hidden',
      'hifz-finish',
    ]) {
      final finder = find.byKey(ValueKey(key));
      expect(finder, findsOneWidget);
      final size = tester.getSize(finder);
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
      await tester.tap(finder);
    }

    expect(playPause, 1);
    expect(repeat, 1);
    expect(hide, 1);
    expect(finish, 1);
  });

  testWidgets('running session exposes pause and hidden mode exposes reveal', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HifzControlsBar(
            status: HifzSessionStatus.running,
            repeatIndex: 2,
            repeatTotal: 5,
            hidden: true,
            onPlayPause: () {},
            onRepeatPattern: () {},
            onToggleHidden: () {},
            onFinish: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Pause memorization'), findsOneWidget);
    expect(find.byTooltip('Reveal Quran'), findsOneWidget);
    expect(find.text('2 / 5'), findsOneWidget);
  });
}
