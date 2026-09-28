import 'package:flutter/material.dart';

import '../domain/hifz_preset.dart';

String hifzPatternSummary(HifzPreset preset) {
  final finalPart = preset.finalRangeRepeatCount == 0
      ? ''
      : ' → Full range ×${preset.finalRangeRepeatCount}';
  return 'Each ayah ×${preset.ayahRepeatCount} → '
      'Combined ×${preset.combinedRepeatCount}$finalPart';
}

class HifzPatternEditorSheet extends StatefulWidget {
  const HifzPatternEditorSheet({
    required this.initialPreset,
    super.key,
  });

  final HifzPreset initialPreset;

  @override
  State<HifzPatternEditorSheet> createState() => _HifzPatternEditorSheetState();
}

class _HifzPatternEditorSheetState extends State<HifzPatternEditorSheet> {
  static const _ayahCounts = [1, 2, 3, 5, 10, 20];
  static const _combinedCounts = [1, 2, 3, 5, 10];
  static const _finalCounts = [0, 1, 2, 3, 5, 10];
  static const _pauseOptions = <Duration>[
    Duration.zero,
    Duration(milliseconds: 500),
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 3),
  ];

  late int _ayahRepeatCount;
  late int _combinedRepeatCount;
  late int _finalRangeRepeatCount;
  late Duration _pauseBetweenRepeats;

  @override
  void initState() {
    super.initState();
    _ayahRepeatCount = widget.initialPreset.ayahRepeatCount;
    _combinedRepeatCount = widget.initialPreset.combinedRepeatCount;
    _finalRangeRepeatCount = widget.initialPreset.finalRangeRepeatCount;
    _pauseBetweenRepeats = widget.initialPreset.pauseBetweenRepeats;
  }

  HifzPreset get _preset => HifzPresets.progressive(
    ayahRepeatCount: _ayahRepeatCount,
    combinedRepeatCount: _combinedRepeatCount,
    finalRangeRepeatCount: _finalRangeRepeatCount,
    pauseBetweenRepeats: _pauseBetweenRepeats,
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Repeat pattern',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Set how the selected ayahs build up during memorization.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            _ChoiceGroup<int>(
              title: 'Each new ayah',
              values: _ayahCounts,
              selected: _ayahRepeatCount,
              keyFor: (value) => ValueKey('hifz-pattern-ayah-$value'),
              labelFor: (value) => '$value×',
              onSelected: (value) => setState(() => _ayahRepeatCount = value),
            ),
            const SizedBox(height: 16),
            _ChoiceGroup<int>(
              title: 'Combined ayahs',
              values: _combinedCounts,
              selected: _combinedRepeatCount,
              keyFor: (value) => ValueKey('hifz-pattern-combined-$value'),
              labelFor: (value) => '$value×',
              onSelected: (value) =>
                  setState(() => _combinedRepeatCount = value),
            ),
            const SizedBox(height: 16),
            _ChoiceGroup<int>(
              title: 'Full selected range',
              values: _finalCounts,
              selected: _finalRangeRepeatCount,
              keyFor: (value) => ValueKey('hifz-pattern-final-$value'),
              labelFor: (value) => value == 0 ? 'Off' : '$value×',
              onSelected: (value) =>
                  setState(() => _finalRangeRepeatCount = value),
            ),
            const SizedBox(height: 16),
            _ChoiceGroup<Duration>(
              title: 'Pause between repeats',
              values: _pauseOptions,
              selected: _pauseBetweenRepeats,
              keyFor: (value) =>
                  ValueKey('hifz-pattern-pause-${value.inMilliseconds}'),
              labelFor: _pauseLabel,
              onSelected: (value) =>
                  setState(() => _pauseBetweenRepeats = value),
            ),
            const SizedBox(height: 18),
            Container(
              key: const ValueKey('hifz-pattern-preview'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Text(
                _summary,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const ValueKey('hifz-pattern-save'),
              onPressed: () => Navigator.of(context).pop(_preset),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Save pattern'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _summary => hifzPatternSummary(_preset);

  static String _pauseLabel(Duration value) {
    if (value == Duration.zero) return 'No pause';
    if (value.inMilliseconds == 500) return '0.5 s';
    return '${value.inSeconds} s';
  }
}

class _ChoiceGroup<T> extends StatelessWidget {
  const _ChoiceGroup({
    required this.title,
    required this.values,
    required this.selected,
    required this.keyFor,
    required this.labelFor,
    required this.onSelected,
  });

  final String title;
  final List<T> values;
  final T selected;
  final Key Function(T value) keyFor;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in values)
            ChoiceChip(
              key: keyFor(value),
              label: Text(labelFor(value)),
              selected: value == selected,
              showCheckmark: false,
              onSelected: (_) => onSelected(value),
            ),
        ],
      ),
    ],
  );
}
