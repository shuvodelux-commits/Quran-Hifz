import 'package:flutter/material.dart';

import '../domain/hifz_session.dart';

class HifzControlsBar extends StatelessWidget {
  const HifzControlsBar({
    required this.status,
    required this.repeatIndex,
    required this.repeatTotal,
    required this.hidden,
    required this.onPlayPause,
    required this.onRepeatPattern,
    required this.onToggleHidden,
    required this.onFinish,
    super.key,
  });

  final HifzSessionStatus status;
  final int repeatIndex;
  final int repeatTotal;
  final bool hidden;
  final VoidCallback onPlayPause;
  final VoidCallback onRepeatPattern;
  final VoidCallback onToggleHidden;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRunning = status == HifzSessionStatus.running;
    final isPaused = status == HifzSessionStatus.paused;

    return Material(
      color: colors.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                key: const ValueKey('hifz-play-pause'),
                tooltip: isRunning
                    ? 'Pause memorization'
                    : isPaused
                    ? 'Resume memorization'
                    : 'Start memorization',
                onPressed: onPlayPause,
                icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
              ),
              IconButton(
                key: const ValueKey('hifz-repeat-pattern'),
                tooltip: 'Repeat pattern',
                onPressed: onRepeatPattern,
                icon: const Icon(Icons.repeat_rounded),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    repeatTotal > 0 ? '$repeatIndex / $repeatTotal' : 'Ready',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('hifz-toggle-hidden'),
                tooltip: hidden ? 'Reveal Quran' : 'Hide Quran',
                onPressed: onToggleHidden,
                icon: Icon(
                  hidden
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
              IconButton(
                key: const ValueKey('hifz-finish'),
                tooltip: 'Finish Hifz',
                onPressed: onFinish,
                icon: const Icon(Icons.stop_circle_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
