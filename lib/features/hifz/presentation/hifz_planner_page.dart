import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/domain/quran_surah.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../application/hifz_plan_providers.dart';
import '../application/hifz_session_controller.dart';
import '../domain/hifz_plan.dart';
import '../domain/hifz_session.dart';
import 'hifz_page.dart';
import 'hifz_pattern_controls.dart';

class HifzPlannerPage extends ConsumerWidget {
  const HifzPlannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final plans = ref.watch(hifzPlansProvider);
    final surahs = ref.watch(quranSurahListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(appText(language, 'হিফজ পরিকল্পনা', 'Hifz Planner')),
        centerTitle: true,
      ),
      body: plans.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            _PlannerError(onRetry: () => ref.invalidate(hifzPlansProvider)),
        data: (items) => items.isEmpty
            ? _EmptyPlanner(
                onCreate: surahs.value == null
                    ? null
                    : () => _createPlan(context, ref, surahs.requireValue),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(hifzPlansProvider),
                child: ListView.separated(
                  key: const ValueKey('hifz-plan-list'),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final plan = items[index];
                    final surah = _findSurah(
                      surahs.value,
                      plan.start.surahNumber,
                    );
                    return _PlanCard(
                      plan: plan,
                      surahName:
                          surah?.nameEnglish ??
                          'Surah ${plan.start.surahNumber}',
                      onOpen: () => _openPlan(context, ref, plan),
                      onDelete: () => _deletePlan(context, ref, plan),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('hifz-add-plan'),
        onPressed: surahs.value == null
            ? null
            : () => _createPlan(context, ref, surahs.requireValue),
        icon: const Icon(Icons.add_rounded),
        label: Text(appText(language, 'পরিকল্পনা যোগ করুন', 'Add plan')),
      ),
    );
  }

  QuranSurahSummary? _findSurah(List<QuranSurahSummary>? surahs, int number) {
    if (surahs == null) return null;
    for (final surah in surahs) {
      if (surah.number == number) return surah;
    }
    return null;
  }

  Future<void> _createPlan(
    BuildContext context,
    WidgetRef ref,
    List<QuranSurahSummary> surahs,
  ) async {
    if (surahs.isEmpty) return;
    final draft = await showModalBottomSheet<_HifzPlanDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CreateHifzPlanSheet(surahs: surahs),
    );
    if (draft == null || !context.mounted) return;

    try {
      final ayah = await ref
          .read(quranRepositoryProvider)
          .loadAyah(
            surahNumber: draft.surah.number,
            ayahNumber: draft.startAyah,
            translationResourceId: ref.read(quranTranslationResourceIdProvider),
          );
      if (ayah == null) throw StateError('The selected ayah is unavailable.');
      await ref
          .read(hifzPlanRepositoryProvider)
          .createPlan(
            profileKey: defaultHifzPlanProfileKey,
            title: draft.title,
            start: AyahRef(
              surahNumber: draft.surah.number,
              ayahNumber: draft.startAyah,
            ),
            end: AyahRef(
              surahNumber: draft.surah.number,
              ayahNumber: draft.endAyah,
            ),
            startPage: ayah.pageNumber,
            preset: draft.pattern.toPreset(),
          );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save Hifz plan: $error')),
      );
    }
  }

  Future<void> _openPlan(
    BuildContext context,
    WidgetRef ref,
    HifzPlan plan,
  ) async {
    final session = ref.read(hifzSessionControllerProvider);
    if (session.status == HifzSessionStatus.running ||
        session.status == HifzSessionStatus.paused) {
      await ref.read(hifzSessionControllerProvider.notifier).stop();
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HifzPage(
          initialPage: plan.startPage,
          initialConfig: plan.sessionConfig,
          openSetupOnStart: true,
        ),
      ),
    );
  }

  Future<void> _deletePlan(
    BuildContext context,
    WidgetRef ref,
    HifzPlan plan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Hifz plan?'),
        content: Text('“${plan.title}” will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(hifzPlanRepositoryProvider).deletePlan(plan.id);
    }
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.surahName,
    required this.onOpen,
    required this.onDelete,
  });

  final HifzPlan plan;
  final String surahName;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final count = plan.end.ayahNumber - plan.start.ayahNumber + 1;
    return Card(
      key: ValueKey('hifz-plan-${plan.id}'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: const Icon(Icons.menu_book_rounded),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$surahName · Ayah ${plan.start.ayahNumber}–${plan.end.ayahNumber} · $count ${count == 1 ? 'ayah' : 'ayahs'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Start Hifz',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: colors.primary),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('hifz-delete-plan-${plan.id}'),
                tooltip: 'Delete plan',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPlanner extends StatelessWidget {
  const _EmptyPlanner({required this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 58,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Plan your Hifz',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Save as many ayah ranges as you need. Open any plan later and begin from the selected ayah.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const ValueKey('hifz-create-first-plan'),
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create plan'),
          ),
        ],
      ),
    ),
  );
}

class _PlannerError extends StatelessWidget {
  const _PlannerError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: FilledButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Retry plans'),
    ),
  );
}

class _HifzPlanDraft {
  const _HifzPlanDraft({
    required this.title,
    required this.surah,
    required this.startAyah,
    required this.endAyah,
    required this.pattern,
  });

  final String title;
  final QuranSurahSummary surah;
  final int startAyah;
  final int endAyah;
  final HifzPatternSelection pattern;
}

class _CreateHifzPlanSheet extends StatefulWidget {
  const _CreateHifzPlanSheet({required this.surahs});
  final List<QuranSurahSummary> surahs;

  @override
  State<_CreateHifzPlanSheet> createState() => _CreateHifzPlanSheetState();
}

class _CreateHifzPlanSheetState extends State<_CreateHifzPlanSheet> {
  final _titleController = TextEditingController();
  late QuranSurahSummary _surah;
  int _startAyah = 1;
  int _endAyah = 1;
  HifzPatternSelection _pattern = const HifzPatternSelection(
    ayahRepeatCount: 5,
    combinedRepeatCount: 3,
    finalRangeRepeatCount: 3,
  );

  @override
  void initState() {
    super.initState();
    _surah = widget.surahs.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          2,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Hifz plan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('hifz-plan-title'),
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Plan name (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              key: const ValueKey('hifz-plan-surah'),
              initialValue: _surah.number,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Surah',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final surah in widget.surahs)
                  DropdownMenuItem(
                    value: surah.number,
                    child: Text('${surah.number}. ${surah.nameEnglish}'),
                  ),
              ],
              onChanged: (number) {
                if (number == null) return;
                setState(() {
                  _surah = widget.surahs.firstWhere(
                    (surah) => surah.number == number,
                  );
                  _startAyah = 1;
                  _endAyah = 1;
                });
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey('hifz-plan-start-${_surah.number}'),
                    initialValue: _startAyah,
                    decoration: const InputDecoration(
                      labelText: 'Start ayah',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var ayah = 1; ayah <= _surah.ayahCount; ayah++)
                        DropdownMenuItem(value: ayah, child: Text('$ayah')),
                    ],
                    onChanged: (ayah) {
                      if (ayah == null) return;
                      setState(() {
                        _startAyah = ayah;
                        if (_endAyah < ayah) _endAyah = ayah;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey('hifz-plan-end-${_surah.number}-$_startAyah'),
                    initialValue: _endAyah,
                    decoration: const InputDecoration(
                      labelText: 'End ayah',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (
                        var ayah = _startAyah;
                        ayah <= _surah.ayahCount;
                        ayah++
                      )
                        DropdownMenuItem(value: ayah, child: Text('$ayah')),
                    ],
                    onChanged: (ayah) {
                      if (ayah != null) setState(() => _endAyah = ayah);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              key: const ValueKey('hifz-plan-pattern'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.repeat_rounded),
              title: const Text('Repetition pattern'),
              subtitle: Text(hifzPatternSummary(_pattern)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _choosePattern,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('hifz-save-plan'),
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Save plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _choosePattern() async {
    final selection = await showModalBottomSheet<HifzPatternSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => HifzPatternSheet(
        surahNumber: _surah.number,
        startAyah: _startAyah,
        endAyah: _endAyah,
        initialSelection: _pattern,
      ),
    );
    if (selection != null && mounted) setState(() => _pattern = selection);
  }

  void _save() {
    final customTitle = _titleController.text.trim();
    Navigator.of(context).pop(
      _HifzPlanDraft(
        title: customTitle.isEmpty
            ? '${_surah.nameEnglish} $_startAyah–$_endAyah'
            : customTitle,
        surah: _surah,
        startAyah: _startAyah,
        endAyah: _endAyah,
        pattern: _pattern,
      ),
    );
  }
}
