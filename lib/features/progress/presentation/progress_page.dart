import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/progress_controller.dart';
import '../domain/progress_summary.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(progressControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load progress: $error')),
        data: (value) => RefreshIndicator(
          onRefresh: () =>
              ref.read(progressControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TodayCard(summary: value),
              const SizedBox(height: 12),
              _HifzCard(summary: value),
              const SizedBox(height: 12),
              _PeriodCard(title: 'Last 7 days', period: value.trailing7Days),
              const SizedBox(height: 12),
              _PeriodCard(title: 'Last 30 days', period: value.trailing30Days),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _GoalRow(
              label: 'New Hifz',
              value: summary.today.newHifzAyahs,
              target: summary.goals.newHifzAyahsTarget,
            ),
            _GoalRow(
              label: 'Revision',
              value: summary.today.revisionAyahs,
              target: summary.goals.revisionAyahsTarget,
            ),
            _GoalRow(
              label: 'Reading pages',
              value: summary.today.readingPages,
              target: summary.goals.readingPagesTarget,
            ),
            const Divider(),
            Text('${summary.revisionDue} ayahs currently due for revision'),
          ],
        ),
      ),
    );
  }
}

class _HifzCard extends StatelessWidget {
  const _HifzCard({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hifz', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Learning: ${summary.hifz.learning}'),
            Text('Memorized: ${summary.hifz.memorized}'),
            Text('Needs revision: ${summary.hifz.needsRevision}'),
            Text('Strong: ${summary.hifz.strong}'),
          ],
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.title, required this.period});

  final String title;
  final ProgressPeriodSummary period;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('New Hifz: ${period.newHifzAyahs} ayahs'),
            Text('Revision: ${period.revisionAyahs} ayahs'),
            Text('Reading: ${period.readingPages} pages'),
          ],
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.label,
    required this.value,
    required this.target,
  });

  final String label;
  final int value;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(target > 0 ? '$value / $target' : '$value'),
        ],
      ),
    );
  }
}
