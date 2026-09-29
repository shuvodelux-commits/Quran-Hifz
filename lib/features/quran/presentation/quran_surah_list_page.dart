import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../hifz/presentation/hifz_home_page.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../../study/domain/bookmark_display_item.dart';
import '../../study/presentation/bookmarks_view.dart';
import '../../tafsir/presentation/tafsir_reader_page.dart';
import '../application/quran_providers.dart';
import '../application/reader_controller.dart';
import '../application/surah_search.dart';
import '../domain/quran_juz.dart';
import '../domain/quran_surah.dart';
import '../domain/reader_scope.dart';
import 'quran_reader_page.dart';
import 'surah_localized_text.dart';
import 'widgets/number_quick_scroll_rail.dart';
import 'widgets/quran_library_tabs.dart';
import 'widgets/quran_surah_row.dart';

class QuranSurahListPage extends ConsumerStatefulWidget {
  const QuranSurahListPage({super.key});

  @override
  ConsumerState<QuranSurahListPage> createState() => _QuranSurahListPageState();
}

class _QuranSurahListPageState extends ConsumerState<QuranSurahListPage> {
  var _tab = QuranLibraryTab.surah;
  var _query = '';
  var _searchOpen = false;
  final _surahScroll = ScrollController();
  final _juzScroll = ScrollController();
  final _searchFocus = FocusNode();
  late Future<ReadingLocation?> _lastRead;

  @override
  void initState() {
    super.initState();
    _lastRead = ref.read(readingLocationStoreProvider).load();
  }

  @override
  void dispose() {
    _surahScroll.dispose();
    _juzScroll.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final surahs = ref.watch(quranSurahListProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(appText(language, 'কুরআন', 'Quran')),
        actions: [
          IconButton(
            tooltip: 'Search Quran',
            onPressed: () {
              setState(() {
                _tab = QuranLibraryTab.surah;
                _searchOpen = true;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _searchFocus.requestFocus();
              });
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: surahs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            _Retry(onPressed: () => ref.invalidate(quranSurahListProvider)),
        data: (items) => Column(
          children: [
            _QuickActions(
              language: language,
              onTafsir: () => _openTafsirSelector(items),
              onHifz: _openHifz,
            ),
            if (_searchOpen && _tab == QuranLibraryTab.surah)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: SearchBar(
                  focusNode: _searchFocus,
                  hintText: appText(
                    language,
                    'বাংলা, English বা আরবিতে সুরা খুঁজুন…',
                    'Search in English, Bangla, or Arabic…',
                  ),
                  leading: const Icon(Icons.search_rounded),
                  trailing: [
                    IconButton(
                      tooltip: 'Close search',
                      onPressed: () => setState(() {
                        _query = '';
                        _searchOpen = false;
                      }),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            QuranLibraryTabs(
              selected: _tab,
              language: language,
              onSelected: (tab) => setState(() {
                _tab = tab;
                if (tab != QuranLibraryTab.surah) _query = '';
              }),
            ),
            Expanded(
              child: switch (_tab) {
                QuranLibraryTab.surah => _buildSurahList(items, language),
                QuranLibraryTab.juz => _JuzList(
                  controller: _juzScroll,
                  surahs: items,
                  language: language,
                  onOpen: _openJuz,
                ),
                QuranLibraryTab.bookmarks => BookmarksView(
                  onOpen: _openBookmark,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList(List<QuranSurahSummary> items, AppLanguage language) {
    final visible = rankSurahMatches(items, _query);
    return Stack(
      children: [
        CustomScrollView(
          controller: _surahScroll,
          slivers: [
            SliverToBoxAdapter(child: _lastReadCard(items, language)),
            if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    appText(
                      language,
                      'কোনো সুরা পাওয়া যায়নি।',
                      'No Surah found.',
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 34, 16),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox.shrink(),
                  itemBuilder: (_, index) => QuranSurahRow(
                    surah: visible[index],
                    language: language,
                    onTap: () => _openSurah(visible[index]),
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          top: 8,
          right: 1,
          bottom: 8,
          child: NumberQuickScrollRail(
            count: items.length,
            semanticLabel: 'Surah',
            scrollController: _surahScroll,
            onPreview: (number) => _preview(number, items.length),
            onSelected: (number) => _preview(number, items.length),
          ),
        ),
      ],
    );
  }

  Widget _lastReadCard(
    List<QuranSurahSummary> items,
    AppLanguage language,
  ) => FutureBuilder<ReadingLocation?>(
    future: _lastRead,
    builder: (context, snapshot) {
      final saved = snapshot.data;
      final surah = saved == null
          ? null
          : items.where((item) => item.number == saved.surahNumber).firstOrNull;
      if (surah == null) return const SizedBox(height: 8);
      return Card(
        margin: const EdgeInsets.fromLTRB(12, 8, 34, 6),
        child: ListTile(
          leading: const Icon(Icons.history_rounded),
          title: Text(appText(language, 'সর্বশেষ পড়া', 'Last read')),
          subtitle: Text(
            '${_surahName(surah, language)} · ${appText(language, 'আয়াত', 'Ayah')} ${localDigits('${saved!.ayahNumber}', language)}',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _openSurah(surah, ayahNumber: saved.ayahNumber),
        ),
      );
    },
  );

  Future<void> _openSurah(QuranSurahSummary surah, {int ayahNumber = 1}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => QuranReaderPage(
          scope: SurahReaderScope(surah: surah, startAyahNumber: ayahNumber),
          initialAyahNumber: ayahNumber,
        ),
      ),
    );
    if (mounted) {
      setState(() {
        _lastRead = ref.read(readingLocationStoreProvider).load();
      });
    }
  }

  Future<void> _openJuz(QuranJuzSummary juz) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => QuranReaderPage(scope: JuzReaderScope(juz: juz)),
        ),
      );

  void _openBookmark(BookmarkDisplayItem item) {
    final surah = item.surah;
    final ayah = item.ayah;
    if (surah == null || ayah == null) return;
    unawaited(_openSurah(surah, ayahNumber: ayah.ayahNumber));
  }

  void _preview(int number, int count) {
    if (!_surahScroll.hasClients || count <= 1) return;
    final fraction = (number - 1) / (count - 1);
    _surahScroll.jumpTo(
      (_surahScroll.position.maxScrollExtent * fraction).clamp(
        0.0,
        _surahScroll.position.maxScrollExtent,
      ),
    );
  }

  void _openHifz() {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => const HifzHomePage()));
  }

  Future<void> _openTafsirSelector(List<QuranSurahSummary> items) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Choose Surah for Tafsir',
            ),
            items: [
              for (final surah in items)
                DropdownMenuItem(
                  value: surah.number,
                  child: Text('${surah.number}. ${surah.nameEnglish}'),
                ),
            ],
            onChanged: (number) {
              if (number != null) Navigator.of(sheetContext).pop(number);
            },
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TafsirReaderPage(surahNumber: selected, ayahNumber: 1),
      ),
    );
  }
}

class _JuzList extends ConsumerWidget {
  const _JuzList({
    required this.controller,
    required this.surahs,
    required this.language,
    required this.onOpen,
  });

  final ScrollController controller;
  final List<QuranSurahSummary> surahs;
  final AppLanguage language;
  final ValueChanged<QuranJuzSummary> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final juzs = ref.watch(quranJuzListProvider);
    return juzs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          _Retry(onPressed: () => ref.invalidate(quranJuzListProvider)),
      data: (items) => Stack(
        children: [
          ListView.separated(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(12, 8, 34, 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox.shrink(),
            itemBuilder: (_, index) {
              final juz = items[index];
              final start = surahs.firstWhere(
                (surah) => surah.number == juz.startSurahNumber,
              );
              final end = surahs.firstWhere(
                (surah) => surah.number == juz.endSurahNumber,
              );
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  key: ValueKey('juz-${juz.number}'),
                  onTap: () => onOpen(juz),
                  leading: CircleAvatar(
                    child: Text(localDigits('${juz.number}', language)),
                  ),
                  title: Text(
                    '${appText(language, 'পারা', 'Juz')} ${localDigits('${juz.number}', language)}',
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                  subtitle: Text(
                    '${_surahName(start, language)} ${localDigits('${juz.firstTarget.ayahNumber}', language)} — ${_surahName(end, language)} ${localDigits('${juz.lastTarget.ayahNumber}', language)}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              );
            },
          ),
          Positioned(
            top: 8,
            right: 1,
            bottom: 8,
            child: NumberQuickScrollRail(
              count: 30,
              semanticLabel: 'Juz',
              scrollController: controller,
              onPreview: (number) => _jump(controller, number, 30),
              onSelected: (number) => _jump(controller, number, 30),
            ),
          ),
        ],
      ),
    );
  }

  void _jump(ScrollController scroll, int number, int count) {
    if (!scroll.hasClients) return;
    final fraction = (number - 1) / (count - 1);
    scroll.jumpTo(
      (scroll.position.maxScrollExtent * fraction).clamp(
        0,
        scroll.position.maxScrollExtent,
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.language,
    required this.onTafsir,
    required this.onHifz,
  });

  final AppLanguage language;
  final VoidCallback onTafsir;
  final VoidCallback onHifz;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          OutlinedButton.icon(
            onPressed: onTafsir,
            icon: const Icon(Icons.article_outlined),
            label: Text(appText(language, 'তাফসির', 'Tafsir')),
          ),
          OutlinedButton.icon(
            key: const ValueKey('quran-quick-hifz'),
            onPressed: onHifz,
            icon: const Icon(Icons.school_outlined),
            label: Text(appText(language, 'হিফজ', 'Hifz')),
          ),
        ],
      ),
    ),
  );
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('আবার চেষ্টা করুন'),
    ),
  );
}

String _surahName(QuranSurahSummary surah, AppLanguage language) =>
    localizedSurahName(surah, language);
