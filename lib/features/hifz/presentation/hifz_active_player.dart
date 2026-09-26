import 'package:flutter/material.dart';

import '../../audio/domain/quran_audio_state.dart';
import '../../quran/domain/quran_surah.dart';
import '../application/hifz_session_controller.dart';
import '../domain/hifz_session.dart';
import '../domain/hifz_step.dart';
import 'hifz_pattern_controls.dart';
import 'hifz_typography.dart';

/// Compact view of the existing Hifz sequence and Quran audio state.
/// The engine exposes step/repeat progress, but no seekable media timeline.
class HifzActivePlayer extends StatelessWidget {
  const HifzActivePlayer({
    super.key,
    required this.surah,
    required this.session,
    required this.audio,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final QuranSurahSummary surah;
  final HifzSessionState session;
  final QuranAudioState audio;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = session.config;
    final total = session.totalSteps;
    final index = session.currentStepIndex.clamp(0, total == 0 ? 0 : total - 1);
    final repeatFromAudio =
        session.currentStep is AyahStep &&
        audio.mode == QuranAudioMode.ayah &&
        audio.repeatTotal > 0;
    final repeatIndex = repeatFromAudio
        ? audio.repeatIndex
        : session.stepRepeatIndex;
    final repeatTotal = repeatFromAudio
        ? audio.repeatTotal
        : session.stepRepeatTotal;
    final withinStep = repeatTotal == 0 ? 0.0 : repeatIndex / repeatTotal;
    final progress = total == 0 ? 0.0 : (index + withinStep) / total;
    final paused = session.status == HifzSessionStatus.paused;
    final patternSummary = config == null
        ? null
        : 'New ' +
              config.preset.ayahRepeatCount.toString() +
              '× · Build ' +
              config.preset.combinedRepeatCount.toString() +
              '× · Final ' +
              config.preset.finalRangeRepeatCount.toString() +
              '×';
    final stepSummary =
        'Step ' +
        (total == 0 ? 0 : index + 1).toString() +
        '/' +
        total.toString() +
        (repeatTotal == 0
            ? ''
            : ' · Repeat ' +
                  repeatIndex.toString() +
                  '/' +
                  repeatTotal.toString());

    return Material(
      key: const ValueKey('hifz-active-player'),
      color: colorScheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Surah ' + surah.nameEnglish,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      if (config != null)
                        Text(
                          'Ayah ' +
                              config.start.ayahNumber.toString() +
                              '–' +
                              config.end.ayahNumber.toString(),
                          style: theme.textTheme.labelMedium,
                        ),
                    ],
                  ),
                  if (patternSummary != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      patternSummary,
                      key: const ValueKey('hifz-active-pattern-summary'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                  const SizedBox(height: 7),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0).toDouble(),
                    minHeight: 3,
                    semanticsLabel: 'Hifz step progress',
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    stepSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    hifzStepStatusLabel(session.currentStep),
                    key: const ValueKey('hifz-active-phase'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: hifzBanglaTextStyle(
                      theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        tooltip: paused ? 'Resume Hifz' : 'Pause Hifz',
                        onPressed: paused ? onResume : onPause,
                        icon: Icon(
                          paused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                        ),
                      ),
                      const SizedBox(width: 18),
                      IconButton(
                        tooltip: 'Stop Hifz',
                        onPressed: onStop,
                        icon: const Icon(Icons.stop_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
