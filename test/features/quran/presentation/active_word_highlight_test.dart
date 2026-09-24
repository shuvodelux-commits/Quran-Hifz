import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/application/quran_audio_controller.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';

void main() {
  test('only active ayah or word playback exposes a highlighted word', () {
    final container = ProviderContainer(
      overrides: [
        quranAudioControllerProvider.overrideWith(
          _TestQuranAudioController.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;

    controller.setActiveWord(
      ayahKey: '1:1',
      wordPosition: 2,
      mode: QuranAudioMode.word,
      status: QuranAudioStatus.loading,
    );
    expect(container.read(activeWordForAyahProvider('1:1')), 2);
    expect(container.read(activeWordForAyahProvider('1:2')), isNull);
    expect(container.read(activeAyahPlaybackKeyProvider), isNull);
    expect(container.read(readerPlaybackFollowTargetProvider), isNull);

    controller.setActiveWord(
      ayahKey: '1:1',
      wordPosition: 2,
      mode: QuranAudioMode.word,
      status: QuranAudioStatus.completed,
    );
    expect(container.read(activeWordForAyahProvider('1:1')), isNull);
  });

  testWidgets('active-word changes do not rebuild an unrelated ayah consumer', (
    tester,
  ) async {
    var ayahOneBuilds = 0;
    var ayahTwoBuilds = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
        ],
        child: MaterialApp(
          home: Column(
            children: [
              _CountingAyah(ayahKey: '1:1', onBuild: () => ayahOneBuilds++),
              _CountingAyah(ayahKey: '1:2', onBuild: () => ayahTwoBuilds++),
            ],
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(_CountingAyah).first);
    final container = ProviderScope.containerOf(context);
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;

    final baselineOne = ayahOneBuilds;
    final baselineTwo = ayahTwoBuilds;

    controller.setActiveWord(ayahKey: '1:1', wordPosition: 2);
    await tester.pump();

    expect(find.text('1:1 → 2'), findsOneWidget);
    expect(ayahOneBuilds, greaterThan(baselineOne));
    expect(ayahTwoBuilds, baselineTwo);

    final afterWordTwo = ayahOneBuilds;
    controller.setActiveWord(ayahKey: '1:1', wordPosition: 3);
    await tester.pump();

    expect(find.text('1:1 → 3'), findsOneWidget);
    expect(ayahOneBuilds, greaterThan(afterWordTwo));
    expect(ayahTwoBuilds, baselineTwo);
  });

  testWidgets(
    'active ayah playback only highlights the matching ayah consumer',
    (tester) async {
      var ayahOneBuilds = 0;
      var ayahTwoBuilds = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quranAudioControllerProvider.overrideWith(
              _TestQuranAudioController.new,
            ),
          ],
          child: MaterialApp(
            home: Column(
              children: [
                _CountingActiveAyah(
                  ayahKey: '1:1',
                  onBuild: () => ayahOneBuilds++,
                ),
                _CountingActiveAyah(
                  ayahKey: '1:2',
                  onBuild: () => ayahTwoBuilds++,
                ),
              ],
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(_CountingActiveAyah).first);
      final container = ProviderScope.containerOf(context);
      final controller =
          container.read(quranAudioControllerProvider.notifier)
              as _TestQuranAudioController;
      final baselineOne = ayahOneBuilds;
      final baselineTwo = ayahTwoBuilds;

      controller.setActiveAyah('1:1');
      await tester.pump();

      expect(find.text('1:1 active=true'), findsOneWidget);
      expect(find.text('1:2 active=false'), findsOneWidget);
      expect(ayahOneBuilds, greaterThan(baselineOne));
      expect(ayahTwoBuilds, baselineTwo);
    },
  );
}

class _TestQuranAudioController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState.initial();

  void setActiveWord({
    required String ayahKey,
    required int wordPosition,
    QuranAudioMode mode = QuranAudioMode.ayah,
    QuranAudioStatus status = QuranAudioStatus.playing,
  }) {
    state = QuranAudioState(
      mode: mode,
      status: status,
      speed: 1,
      repeatIndex: 1,
      repeatTotal: 1,
      ayahKey: ayahKey,
      activeWordPosition: wordPosition,
    );
  }

  void setActiveAyah(String ayahKey) {
    state = QuranAudioState(
      mode: QuranAudioMode.ayah,
      status: QuranAudioStatus.playing,
      speed: 1,
      repeatIndex: 1,
      repeatTotal: 1,
      ayahKey: ayahKey,
    );
  }
}

class _CountingAyah extends ConsumerWidget {
  const _CountingAyah({required this.ayahKey, required this.onBuild});

  final String ayahKey;
  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    onBuild();
    final active = ref.watch(activeWordForAyahProvider(ayahKey));
    return Text('$ayahKey → ${active ?? '-'}');
  }
}

class _CountingActiveAyah extends ConsumerWidget {
  const _CountingActiveAyah({required this.ayahKey, required this.onBuild});

  final String ayahKey;
  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    onBuild();
    final active = ref.watch(isAyahPlaybackActiveProvider(ayahKey));
    return Text('$ayahKey active=$active');
  }
}
