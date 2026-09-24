import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/reader_playback_panel.dart';

void main() {
  testWidgets('shows progress and delegates playback controls', (tester) async {
    var paused = false;
    var previous = false;
    var next = false;
    var stopped = false;
    var minimized = false;
    Duration? seek;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ReaderPlaybackPanel(
              state: const QuranAudioState(
                mode: QuranAudioMode.ayah,
                status: QuranAudioStatus.playing,
                speed: 1,
                repeatIndex: 1,
                repeatTotal: 1,
                ayahKey: '2:255',
                position: Duration(seconds: 85),
                duration: Duration(seconds: 216),
              ),
              reciterName: 'Muhammad Al-Minshawi',
              onPause: () => paused = true,
              onResume: () {},
              onPrevious: () => previous = true,
              onNext: () => next = true,
              onSeek: (value) => seek = value,
              onSpeed: (_) {},
              onRepeat: () {},
              onStop: () => stopped = true,
              onMinimize: () => minimized = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('reader-playback-panel')), findsOneWidget);
    expect(find.text('Verse 2:255'), findsOneWidget);
    expect(find.text('Muhammad Al-Minshawi'), findsOneWidget);
    expect(find.text('1:25'), findsOneWidget);
    expect(find.text('3:36'), findsOneWidget);

    await tester.tap(find.byTooltip('Pause recitation'));
    await tester.tap(find.byTooltip('Previous ayah'));
    await tester.tap(find.byTooltip('Next ayah'));
    await tester.tap(find.byTooltip('Stop recitation'));
    await tester.tap(find.byTooltip('Minimize player'));
    await tester.drag(find.byType(Slider), const Offset(100, 0));

    expect(paused, isTrue);
    expect(previous, isTrue);
    expect(next, isTrue);
    expect(stopped, isTrue);
    expect(minimized, isTrue);
    expect(seek, isNotNull);
  });

  testWidgets('paused playback offers resume', (tester) async {
    var resumed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderPlaybackPanel(
            state: const QuranAudioState(
              mode: QuranAudioMode.ayah,
              status: QuranAudioStatus.paused,
              speed: 1,
              repeatIndex: 1,
              repeatTotal: 2,
              ayahKey: '1:1',
            ),
            reciterName: 'Reciter',
            onPause: () {},
            onResume: () => resumed = true,
            onPrevious: null,
            onNext: null,
            onSeek: (_) {},
            onSpeed: (_) {},
            onRepeat: () {},
            onStop: () {},
            onMinimize: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Resume recitation'));
    expect(resumed, isTrue);
  });

  testWidgets('minimized player is a thin tappable bottom handle', (
    tester,
  ) async {
    var expanded = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomSheet: ReaderMinimizedPlaybackBar(
            onExpand: () => expanded = true,
          ),
        ),
      ),
    );

    final bar = find.byKey(const ValueKey('reader-minimized-player'));
    expect(bar, findsOneWidget);
    expect(tester.getSize(bar).height, lessThanOrEqualTo(20));
    await tester.tap(bar);
    expect(expanded, isTrue);
  });
}
