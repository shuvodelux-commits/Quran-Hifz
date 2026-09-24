import 'package:flutter/material.dart';

import '../../quran/domain/quran_surah.dart';
import 'hifz_pattern_controls.dart';

/// Configuration only. Playback is started by HifzPage through its session
/// controller after this route closes.
class HifzSetupSheet extends StatelessWidget {
  const HifzSetupSheet({
    super.key,
    required this.surah,
    required this.startAyah,
    required this.endAyah,
    required this.pattern,
    required this.reciterSelected,
    required this.onStartRange,
    required this.onEndRange,
    required this.onPattern,
    required this.onAdvancedSettings,
    required this.onPlay,
    required this.onClose,
    this.onResumeSaved,
  });

  final QuranSurahSummary surah;
  final int? startAyah;
  final int? endAyah;
  final HifzPatternSelection pattern;
  final bool reciterSelected;
  final VoidCallback onStartRange;
  final VoidCallback? onEndRange;
  final VoidCallback onPattern;
  final VoidCallback onAdvancedSettings;
  final VoidCallback? onPlay;
  final VoidCallback onClose;
  final VoidCallback? onResumeSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final start = startAyah;
    final end = endAyah ?? start;
    final rangeCount = start == null || end == null ? 0 : end - start + 1;

    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Audio & Hifz',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Collapse Audio & Hifz',
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SetupRow(
                        key: const ValueKey('hifz-start-range'),
                        icon: Icons.play_circle_outline_rounded,
                        title: 'Start Range',
                        value: start == null ? 'Choose ayah' : 'Ayah $start',
                        onTap: onStartRange,
                      ),
                      const Divider(height: 1),
                      _SetupRow(
                        key: const ValueKey('hifz-end-range'),
                        icon: Icons.flag_outlined,
                        title: 'End Range',
                        value: endAyah == null
                            ? (start == null
                                  ? 'Choose start first'
                                  : 'Ayah $start')
                            : 'Ayah $endAyah',
                        onTap: onEndRange,
                      ),
                      const Divider(height: 1),
                      _SetupRow(
                        key: const ValueKey('hifz-pattern'),
                        icon: Icons.repeat_rounded,
                        title: 'Pattern',
                        value: hifzPatternSummary(pattern),
                        onTap: onPattern,
                      ),
                      const Divider(height: 1),
                      _SetupRow(
                        key: const ValueKey('hifz-advanced-settings'),
                        icon: Icons.settings_outlined,
                        title: 'Advanced Settings',
                        onTap: onAdvancedSettings,
                      ),
                    ],
                  ),
                ),
                if (onResumeSaved != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('hifz-resume-saved'),
                    onPressed: onResumeSaved,
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Resume saved session'),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const ValueKey('hifz-setup-play'),
                  onPressed: reciterSelected && start != null ? onPlay : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 9),
                    child: Text('Play'),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  start == null
                      ? 'Choose a start ayah to begin'
                      : 'Ayah $start–$end · $rangeCount '
                            '${rangeCount == 1 ? 'ayah' : 'ayahs'} · ${surah.nameEnglish}',
                  key: const ValueKey('hifz-range-summary'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!reciterSelected) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Choose a reciter in Advanced Settings before playing.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      enabled: onTap != null,
      leading: Icon(icon, size: 21),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.sizeOf(context).width * 0.34).clamp(
                  90.0,
                  175.0,
                ),
              ),
              child: Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(width: 3),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

class HifzAyahPickerSheet extends StatelessWidget {
  const HifzAyahPickerSheet({
    super.key,
    required this.title,
    required this.minimum,
    required this.maximum,
    this.selected,
  });

  final String title;
  final int minimum;
  final int maximum;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.65;
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: maximum - minimum + 1,
                    itemBuilder: (context, index) {
                      final ayah = minimum + index;
                      return ListTile(
                        key: ValueKey('hifz-ayah-choice-$ayah'),
                        title: Text('Ayah $ayah'),
                        selected: selected == ayah,
                        trailing: selected == ayah
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () => Navigator.of(context).pop(ayah),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
