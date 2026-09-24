import 'package:flutter/material.dart';

import '../../../audio/domain/quran_audio_state.dart';

class ReaderPlaybackPanel extends StatelessWidget {
  const ReaderPlaybackPanel({
    super.key,
    required this.state,
    required this.reciterName,
    required this.onPause,
    required this.onResume,
    required this.onPrevious,
    required this.onNext,
    required this.onSeek,
    required this.onSpeed,
    required this.onRepeat,
    required this.onStop,
    required this.onMinimize,
  });

  final QuranAudioState state;
  final String reciterName;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<double> onSpeed;
  final VoidCallback onRepeat;
  final VoidCallback onStop;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final totalMs = state.duration.inMilliseconds;
    final max = totalMs > 0 ? totalMs.toDouble() : 1.0;
    final value = state.position.inMilliseconds
        .clamp(0, totalMs > 0 ? totalMs : 0)
        .toDouble();
    final isPaused = state.status == QuranAudioStatus.paused;
    final isLoading = state.status == QuranAudioStatus.loading;

    return SafeArea(
      top: false,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 250) onMinimize();
        },
        child: Material(
          key: const ValueKey('reader-playback-panel'),
          color: colors.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: IconButtonTheme(
              data: IconButtonThemeData(
                style: IconButton.styleFrom(foregroundColor: colors.onPrimary),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Tooltip(
                    message: 'Minimize player',
                    child: InkWell(
                      key: const ValueKey('minimize-player-handle'),
                      onTap: onMinimize,
                      child: SizedBox(
                        height: 16,
                        child: Center(
                          child: Container(
                            width: 64,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colors.onPrimary.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verse ${state.ayahKey ?? '—'}',
                              style: TextStyle(
                                color: colors.onPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              reciterName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onPrimary.withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => onSpeed(_nextSpeed(state.speed)),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onPrimary,
                        ),
                        child: Text('${_speedText(state.speed)}×'),
                      ),
                      IconButton(
                        tooltip: 'Stop recitation',
                        onPressed: onStop,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: colors.onPrimary,
                      inactiveTrackColor: colors.onPrimary.withValues(
                        alpha: 0.35,
                      ),
                      thumbColor: colors.onPrimary,
                      overlayColor: colors.onPrimary.withValues(alpha: 0.12),
                    ),
                    child: Slider(
                      value: value,
                      max: max,
                      onChanged: isLoading || totalMs <= 0
                          ? null
                          : (next) =>
                                onSeek(Duration(milliseconds: next.round())),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _durationText(state.position),
                        style: TextStyle(color: colors.onPrimary),
                      ),
                      Text(
                        _durationText(state.duration),
                        style: TextStyle(color: colors.onPrimary),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: 'Repeat options',
                        onPressed: isLoading ? null : onRepeat,
                        icon: Badge(
                          label: Text('${state.repeatTotal}'),
                          child: const Icon(Icons.repeat_rounded),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Previous ayah',
                        onPressed: isLoading ? null : onPrevious,
                        icon: const Icon(Icons.skip_previous_rounded),
                      ),
                      FilledButton(
                        onPressed: isLoading
                            ? null
                            : (isPaused ? onResume : onPause),
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(17),
                          backgroundColor: colors.onPrimary,
                          foregroundColor: colors.primary,
                        ),
                        child: isLoading
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Tooltip(
                                message: isPaused
                                    ? 'Resume recitation'
                                    : 'Pause recitation',
                                child: Icon(
                                  isPaused
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_rounded,
                                  size: 30,
                                ),
                              ),
                      ),
                      IconButton(
                        tooltip: 'Next ayah',
                        onPressed: isLoading ? null : onNext,
                        icon: const Icon(Icons.skip_next_rounded),
                      ),
                      const SizedBox(width: 48),
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

class ReaderMinimizedPlaybackBar extends StatelessWidget {
  const ReaderMinimizedPlaybackBar({super.key, required this.onExpand});

  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Tooltip(
        message: 'Expand player',
        child: Material(
          key: const ValueKey('reader-minimized-player'),
          color: colors.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          elevation: 16,
          child: InkWell(
            onTap: onExpand,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 20,
              width: double.infinity,
              child: Center(
                child: Container(
                  width: 64,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _durationText(Duration duration) {
  final seconds = duration.inSeconds.clamp(0, 359999);
  final minutes = seconds ~/ 60;
  return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
}

String _speedText(double speed) => speed == speed.roundToDouble()
    ? speed.toInt().toString()
    : speed.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');

double _nextSpeed(double current) {
  const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
  final index = speeds.indexWhere((speed) => (speed - current).abs() < 0.001);
  return speeds[(index + 1) % speeds.length];
}
