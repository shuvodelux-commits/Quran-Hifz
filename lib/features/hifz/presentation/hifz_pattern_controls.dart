import 'package:flutter/material.dart';

import '../application/hifz_sequence_builder.dart';
import '../domain/hifz_preset.dart';
import '../domain/hifz_session.dart';
import '../domain/hifz_step.dart';
import 'hifz_typography.dart';

class HifzPatternSelection {
  const HifzPatternSelection({
    required this.ayahRepeatCount,
    required this.combinedRepeatCount,
    required this.finalRangeRepeatCount,
  });

  final int ayahRepeatCount;
  final int combinedRepeatCount;
  final int finalRangeRepeatCount;

  factory HifzPatternSelection.fromPreset(HifzPreset preset) {
    return HifzPatternSelection(
      ayahRepeatCount: preset.ayahRepeatCount,
      combinedRepeatCount: preset.combinedRepeatCount,
      finalRangeRepeatCount: preset.finalRangeRepeatCount,
    );
  }

  HifzPreset toPreset() => HifzPresets.progressive(
    ayahRepeatCount: ayahRepeatCount,
    combinedRepeatCount: combinedRepeatCount,
    finalRangeRepeatCount: finalRangeRepeatCount,
  );
}

String hifzPatternSummary(HifzPatternSelection pattern) {
  final finalReview = pattern.finalRangeRepeatCount > 0
      ? ' · final ×${pattern.finalRangeRepeatCount}'
      : '';
  return 'Each ×${pattern.ayahRepeatCount} · cumulative '
      '×${pattern.combinedRepeatCount}$finalReview';
}

class HifzPatternSheet extends StatefulWidget {
  const HifzPatternSheet({
    super.key,
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
    required this.initialSelection,
  });

  final int surahNumber;
  final int startAyah;
  final int endAyah;
  final HifzPatternSelection initialSelection;

  @override
  State<HifzPatternSheet> createState() => _HifzPatternSheetState();
}

class _HifzPatternSheetState extends State<HifzPatternSheet> {
  late int _ayahRepeatCount;
  late int _combinedRepeatCount;
  late int _finalRangeRepeatCount;

  @override
  void initState() {
    super.initState();
    _ayahRepeatCount = widget.initialSelection.ayahRepeatCount
        .clamp(1, 5)
        .toInt();
    _combinedRepeatCount = widget.initialSelection.combinedRepeatCount
        .clamp(1, 5)
        .toInt();
    _finalRangeRepeatCount = widget.initialSelection.finalRangeRepeatCount
        .clamp(1, 5)
        .toInt();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selection = HifzPatternSelection(
      ayahRepeatCount: _ayahRepeatCount,
      combinedRepeatCount: _combinedRepeatCount,
      finalRangeRepeatCount: _finalRangeRepeatCount,
    );
    final config = HifzSessionConfig(
      start: AyahRef(
        surahNumber: widget.surahNumber,
        ayahNumber: widget.startAyah,
      ),
      end: AyahRef(surahNumber: widget.surahNumber, ayahNumber: widget.endAyah),
      preset: selection.toPreset(),
    );
    final steps = const HifzSequenceBuilder().build(config);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pattern',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Text(
              'নির্বাচিত রেঞ্জ ${widget.surahNumber}:${widget.startAyah}–${widget.endAyah}',
              style: hifzBanglaTextStyle(
                theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _RepeatSelector(
              title: 'নতুন আয়াত পুনরাবৃত্তি',
              subtitle: 'প্রতিটি নতুন আয়াত একা কতবার শুনবেন',
              values: const [1, 2, 3, 4, 5],
              selected: _ayahRepeatCount,
              onSelected: (value) => setState(() => _ayahRepeatCount = value),
            ),
            const SizedBox(height: 16),
            _RepeatSelector(
              title: 'জমা রিভিশন',
              subtitle: 'শুরু থেকে নতুন আয়াত পর্যন্ত একসাথে কতবার',
              values: const [1, 2, 3, 4, 5],
              selected: _combinedRepeatCount,
              onSelected: (value) =>
                  setState(() => _combinedRepeatCount = value),
            ),
            const SizedBox(height: 16),
            _RepeatSelector(
              title: 'শেষে পুরো রেঞ্জ',
              subtitle: 'সব ধাপ শেষে সম্পূর্ণ নির্বাচিত রেঞ্জ',
              values: const [1, 2, 3, 4, 5],
              selected: _finalRangeRepeatCount,
              onSelected: (value) =>
                  setState(() => _finalRangeRepeatCount = value),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'অনুশীলন ক্রম (প্রিভিউ)',
                    style: hifzBanglaTextStyle(
                      theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    buildHifzSequencePreview(steps),
                    key: const ValueKey('hifz-sequence-preview'),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const ValueKey('hifz-pattern-save'),
              onPressed: () => Navigator.of(context).pop(selection),
              icon: const Icon(Icons.check_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Use pattern'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RepeatSelector extends StatelessWidget {
  const _RepeatSelector({
    required this.title,
    required this.subtitle,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final List<int> values;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: hifzBanglaTextStyle(
            theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: hifzBanglaTextStyle(theme.textTheme.bodySmall)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              ChoiceChip(
                label: Text('${value}×'),
                selected: selected == value,
                onSelected: (_) => onSelected(value),
              ),
          ],
        ),
      ],
    );
  }
}

String buildHifzSequencePreview(List<HifzStep> steps) {
  return steps.map(_stepPreview).join('  →  ');
}

String _stepPreview(HifzStep step) {
  if (step is AyahStep) {
    return '${step.ayah.ayahNumber}×${step.repeatCount}';
  }
  if (step is RangeStep) {
    return '${step.start.ayahNumber}–${step.end.ayahNumber}×${step.repeatCount}';
  }
  return '—';
}

String hifzStepStatusLabel(HifzStep? step) {
  if (step is AyahStep) {
    return 'আয়াত ${step.ayah.ayahNumber} · একক অনুশীলন';
  }
  if (step is RangeStep) {
    final prefix = step.phase == HifzStepPhase.finalReview
        ? 'শেষ পূর্ণ রিভিশন'
        : 'জমা রিভিশন';
    return '$prefix · আয়াত ${step.start.ayahNumber}–${step.end.ayahNumber}';
  }
  return 'হিফজ অনুশীলন';
}
