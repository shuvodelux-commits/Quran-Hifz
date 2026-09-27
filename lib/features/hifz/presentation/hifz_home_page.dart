import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/domain/quran_surah.dart';
import '../../quran/presentation/surah_localized_text.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/hifz_plan_providers.dart';
import '../application/hifz_session_controller.dart';
import '../application/hifz_start_defaults.dart';
import '../domain/hifz_plan.dart';
import '../domain/hifz_progress.dart';
import '../domain/hifz_session.dart';
import 'hifz_reader_page.dart';
import 'hifz_setup_sheet.dart';
import 'hifz_surah_picker_sheet.dart';

class HifzHomePage extends ConsumerStatefulWidget {
  const HifzHomePage({super.key});

  @override
  ConsumerState<HifzHomePage> createState() => _HifzHomePageState();
}

class _HifzHomePageState extends ConsumerState<HifzHomePage> {
  bool _starting = false;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final surahs = ref.watch(quranSurahListProvider);
    final plans = ref.watch(hifzPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(appText(language, 'হিফজ', 'Hifz')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          FilledButton.icon(
            key: const ValueKey('hifz-start-surah'),
            onPressed: _starting || surahs.value == null
                ? null
                : () => unawaited(_startFromSurah(surahs.value!)),
            icon: _starting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.menu_book_outlined),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Text(
                appText(
                  language,
                  'সূরা থেকে হিফজ শুরু করুন',
                  'Start Hifz from a Surah',
                ),
              ),
            ),
          ),
          if (surahs.hasError) ...[
            const SizedBox(height: 8),
            _InlineMessage(
              text: appText(
                language,
                'কুরআনের সূরা তালিকা খোলা যায়নি।',
                'The Surah list could not be opened.',
              ),
              actionLabel: appText(language, 'আবার চেষ্টা', 'Retry'),
              onAction: () => ref.invalidate(quranSurahListProvider),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            appText(language, 'সংরক্ষিত পরিকল্পনা', 'Saved plans'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          plans.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => _InlineMessage(
              text: appText(
                language,
                'সংরক্ষিত হিফজ পরিকল্পনা এখন খোলা যাচ্ছে না।',
                'Saved Hifz plans are unavailable right now.',
              ),
              actionLabel: appText(language, 'আবার চেষ্টা', 'Retry'),
              actionKey: const ValueKey('hifz-plans-retry'),
              onAction: () => ref.invalidate(hifzPlansProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    appText(
                      language,
                      'এখনও কোনো সংরক্ষিত হিফজ পরিকল্পনা নেই।',
                      'No saved Hifz plans yet.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    _PlanRow(
                      plan: items[index],
                      language: language,
                      progress: _planProgress(items[index]),
                      onOpen: () => _openPlan(items[index]),
                      onDelete: () => unawaited(_deletePlan(items[index])),
                    ),
                    if (index != items.length - 1)
                      const Divider(height: 1),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startFromSurah(List<QuranSurahSummary> surahs) async {
    final selected = await showModalBottomSheet<QuranSurahSummary>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => HifzSurahPickerSheet(surahs: surahs),
    );
    if (!mounted || selected == null) return;

    List<HifzProgress> progress = const [];
    try {
      progress = await ref
          .read(hifzRepositoryProvider)
          .loadSurahProgress(
            profileKey: defaultHifzPlanProfileKey,
            surahNumber: selected.number,
          );
    } on Object {
      progress = const [];
    }
    if (!mounted) return;

    final defaults = HifzStartDefaults.forSurah(
      surah: selected,
      progress: progress,
    );
    final setup = await showModalBottomSheet<HifzSetupResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => HifzSetupSheet(
        surah: selected,
        initialStartAyah: defaults.startAyah,
        initialEndAyah: defaults.endAyah,
        initialPreset: HifzPresets.progressive(),
      ),
    );
    if (!mounted || setup == null) return;

    setState(() => _starting = true);
    try {
      final start = AyahRef(
        surahNumber: selected.number,
        ayahNumber: setup.startAyah,
      );
      final end = AyahRef(
        surahNumber: selected.number,
        ayahNumber: setup.endAyah,
      );
      final ayah = await ref.read(quranRepositoryProvider).loadAyah(
        surahNumber: selected.number,
        ayahNumber: setup.startAyah,
        translationResourceId: ref.read(quranTranslationResourceIdProvider),
      );
      if (ayah == null) {
        throw StateError('Selected ayah is unavailable.');
      }

      final title =
          selected.nameEnglish +
          ' ' +
          setup.startAyah.toString() +
          '–' +
          setup.endAyah.toString();
      await ref.read(hifzPlanRepositoryProvider).createPlan(
        profileKey: defaultHifzPlanProfileKey,
        title: title,
        start: start,
        end: end,
        startPage: ayah.pageNumber,
        preset: setup.preset,
      );
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => HifzReaderPage(
            config: HifzSessionConfig(
              start: start,
              end: end,
              preset: setup.preset,
            ),
            initialPage: ayah.pageNumber,
            planTitle: title,
          ),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appText(
              ref.read(appLanguageProvider),
              'হিফজ পরিকল্পনা সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।',
              'Could not save the Hifz plan. Please try again.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<List<HifzProgress>> _planProgress(HifzPlan plan) {
    return ref.read(hifzRepositoryProvider).loadSurahProgress(
      profileKey: plan.profileKey,
      surahNumber: plan.start.surahNumber,
    );
  }

  void _openPlan(HifzPlan plan) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HifzReaderPage(
          config: plan.sessionConfig,
          initialPage: plan.startPage,
          planTitle: plan.title,
        ),
      ),
    );
  }

  Future<void> _deletePlan(HifzPlan plan) async {
    try {
      await ref.read(hifzPlanRepositoryProvider).deletePlan(plan.id);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete the Hifz plan.')),
      );
    }
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.plan,
    required this.language,
    required this.progress,
    required this.onOpen,
    required this.onDelete,
  });

  final HifzPlan plan;
  final AppLanguage language;
  final Future<List<HifzProgress>> progress;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final rangeText =
        appText(language, 'আয়াত', 'Ayah') +
        ' ' +
        localDigits(plan.start.ayahNumber.toString(), language) +
        '–' +
        localDigits(plan.end.ayahNumber.toString(), language);
    return ListTile(
      key: ValueKey('hifz-plan-' + plan.id.toString()),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      minTileHeight: 64,
      onTap: onOpen,
      title: Text(
        plan.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rangeText),
          FutureBuilder<List<HifzProgress>>(
            future: progress,
            builder: (context, snapshot) {
              final items = snapshot.data;
              if (items == null) {
                return Text(
                  appText(language, 'অগ্রগতি…', 'Progress…'),
                  key: ValueKey(
                    'hifz-plan-progress-' + plan.id.toString(),
                  ),
                );
              }
              final learned = items.where((item) {
                final number = item.ayah.ayahNumber;
                return number >= plan.start.ayahNumber &&
                    number <= plan.end.ayahNumber &&
                    item.status != HifzStatus.notStarted;
              }).length;
              final total =
                  plan.end.ayahNumber - plan.start.ayahNumber + 1;
              return Text(
                appText(language, 'অগ্রগতি', 'Progress') +
                    ' ' +
                    localDigits(learned.toString(), language) +
                    '/' +
                    localDigits(total.toString(), language),
                key: ValueKey(
                  'hifz-plan-progress-' + plan.id.toString(),
                ),
              );
            },
          ),
          Text(
            _lastActivity(plan.updatedAt, language),
            key: ValueKey('hifz-plan-updated-' + plan.id.toString()),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        key: ValueKey('hifz-plan-menu-' + plan.id.toString()),
        tooltip: 'Plan actions',
        onSelected: (value) {
          if (value == 'delete') onDelete();
        },
        itemBuilder: (_) => const [
          PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _lastActivity(DateTime value, AppLanguage language) {
    final date =
        value.year.toString().padLeft(4, '0') +
        '-' +
        value.month.toString().padLeft(2, '0') +
        '-' +
        value.day.toString().padLeft(2, '0');
    return appText(language, 'সর্বশেষ ', 'Last activity ') +
        localDigits(date, language);
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.text,
    required this.actionLabel,
    required this.onAction,
    this.actionKey,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onAction;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextButton(
          key: actionKey,
          onPressed: onAction,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
