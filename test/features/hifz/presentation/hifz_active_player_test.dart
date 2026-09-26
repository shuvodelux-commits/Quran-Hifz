import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/hifz/application/hifz_session_controller.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_step.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_active_player.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';

void main() {
  testWidgets('active player shows the 5 3 3 pattern summary', (tester) async {
    final config = HifzSessionConfig(
      start: const AyahRef(surahNumber: 1, ayahNumber: 1),
      end: const AyahRef(surahNumber: 1, ayahNumber: 3),
      preset: HifzPresets.progressive(),
    );
    const step = AyahStep(
      ayah: AyahRef(surahNumber: 1, ayahNumber: 1),
      repeatCount: 5,
      pauseBetweenRepeats: Duration(seconds: 1),
    );
    final session = HifzSessionState(
      status: HifzSessionStatus.running,
      currentStepIndex: 0,
      totalSteps: 6,
      stepRepeatIndex: 2,
      stepRepeatTotal: 5,
      currentStep: step,
      config: config,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HifzActivePlayer(
            surah: const QuranSurahSummary(
              number: 1,
              nameArabic: 'الفاتحة',
              nameEnglish: 'Al-Fatihah',
              ayahCount: 7,
              pageStart: 1,
              pageEnd: 1,
              juzStart: 1,
            ),
            session: session,
            audio: const QuranAudioState(
              mode: QuranAudioMode.ayah,
              status: QuranAudioStatus.playing,
              speed: 1,
              repeatIndex: 2,
              repeatTotal: 5,
              ayahKey: '1:1',
            ),
            onPause: _noop,
            onResume: _noop,
            onStop: _noop,
          ),
        ),
      ),
    );

    expect(find.text('New 5× · Build 3× · Final 3×'), findsOneWidget);
    final phase = tester.widget<Text>(
      find.byKey(const ValueKey('hifz-active-phase')),
    );
    expect(phase.style?.fontFamily, 'SolaimanLipi');
    final english = tester.widget<Text>(find.text('Surah Al-Fatihah'));
    expect(english.style?.fontFamily, isNot('SolaimanLipi'));
    expect(find.byType(Slider), findsNothing);
  });
}

void _noop() {}
