import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../audio/application/audio_providers.dart';
import '../../audio/domain/quran_audio_state.dart';
import '../../reciters/application/reciter_catalog_controller.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../../settings/presentation/settings_page.dart';
import '../../study/presentation/bookmarks_page.dart';
import '../../tafsir/presentation/tafsir_reader_page.dart';
import '../data/bengali_word_meanings.dart';
import '../application/quran_providers.dart';
import '../application/reader_controller.dart';
import '../application/reader_audio_actions.dart';
import '../application/reader_offline_audio_gate.dart';
import '../domain/quran_page_window.dart';
import '../domain/quran_ayah.dart';
import '../domain/reader_scope.dart';
import '../domain/quran_surah.dart';
import 'surah_localized_text.dart';
import 'widgets/reader_window.dart';
import 'widgets/reader_offline_audio_prompt.dart';
import 'widgets/reader_playback_panel.dart';
import 'widgets/reader_surah_header.dart';
import 'widgets/reader_surah_navigation.dart';
import 'widgets/number_quick_scroll_rail.dart';

class QuranReaderPage extends ConsumerStatefulWidget {
  const QuranReaderPage({
    super.key,
    this.surah,
    this.scope,
    this.initialAyahNumber,
  }) : assert(surah != null || scope != null);

  final QuranSurahSummary? surah;
  final ReaderScope? scope;
  final int? initialAyahNumber;

  @override
  ConsumerState<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends ConsumerState<QuranReaderPage> {
  static const _paginationThreshold = 900.0;

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _pageKeys = {};
  bool _loadingNext = false;
  bool _loadingPrevious = false;
  bool _userScrollActive = false;
  int? _lastPositionedPage;
  int? _lastSavedPage;
  int? _jumpTargetAyah;
  bool _wordDownloadActive = false;
  bool _wordDownloaded = false;
  int _wordDownloadCompleted = 0;
  bool _playerMinimized = false;
  List<QuranSurahSummary> _surahs = const [];

  ReaderScope get _scope =>
      widget.scope ??
      SurahReaderScope(
        surah: widget.surah!,
        startAyahNumber: widget.initialAyahNumber ?? 1,
      );

  QuranSurahSummary get _primarySurah =>
      widget.surah ??
      _surahs.firstWhere((surah) => surah.number == _scope.initialSurahNumber);

  @override
  void initState() {
    super.initState();
    Future.microtask(_openSelectedScope);
  }

  Future<void> _refreshWordDownloadStatus(QuranSurahSummary surah) async {
    final downloaded = await ref
        .read(bengaliWordMeaningsProvider)
        .isSurahDownloaded(surah.number);
    if (mounted) setState(() => _wordDownloaded = downloaded);
  }

  Future<void> _downloadBanglaWords() async {
    if (_wordDownloadActive || _wordDownloaded) return;
    setState(() {
      _wordDownloadActive = true;
      _wordDownloadCompleted = 0;
    });
    try {
      await ref
          .read(bengaliWordMeaningsProvider)
          .downloadSurah(
            _primarySurah.number,
            _primarySurah.ayahCount,
            onProgress: (completed, _) {
              if (mounted) setState(() => _wordDownloadCompleted = completed);
            },
          );
      if (mounted) setState(() => _wordDownloaded = true);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bangla word download failed. Try again.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _wordDownloadActive = false);
    }
  }

  Future<void> _chooseAyah(int number) async {
    final ayah = await ref
        .read(quranRepositoryProvider)
        .loadAyah(
          surahNumber: _primarySurah.number,
          ayahNumber: number,
          translationResourceId: ref.read(quranTranslationResourceIdProvider),
        );
    if (!mounted || ayah == null) return;
    setState(() {
      _jumpTargetAyah = number;
      _lastPositionedPage = null;
    });
    await ref
        .read(readerControllerProvider.notifier)
        .openPage(
          ayah.pageNumber,
          preferredSurahNumber: _primarySurah.number,
          firstPage: _scope.firstPage,
          lastPage: _scope.lastPage,
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openSelectedScope() async {
    await ref.read(readerControllerProvider.future);
    if (!mounted) return;
    final surahs = await ref.read(quranRepositoryProvider).listSurahs();
    if (!mounted) return;
    setState(() => _surahs = surahs);
    final primary = _primarySurah;
    unawaited(_refreshWordDownloadStatus(primary));
    final store = ref.read(readingLocationStoreProvider);
    final isSurahScope = _scope is SurahReaderScope;
    final saved = isSurahScope && store is SurahReadingLocationStore
        ? await (store as SurahReadingLocationStore).loadForSurah(
            primary.number,
          )
        : null;
    if (!mounted) return;
    var page = _scope.firstPage;
    final requestedAyah = widget.initialAyahNumber ?? _scope.initialAyahNumber;
    if (requestedAyah > 1) {
      final ayah = await ref
          .read(quranRepositoryProvider)
          .loadAyah(
            surahNumber: _scope.initialSurahNumber,
            ayahNumber: requestedAyah,
            translationResourceId: ref.read(quranTranslationResourceIdProvider),
          );
      if (ayah != null && _scope.contains(ayah)) {
        page = ayah.pageNumber;
        _jumpTargetAyah = requestedAyah;
      }
    }
    if (saved != null &&
        saved.page >= _scope.firstPage &&
        saved.page <= _scope.lastPage &&
        saved.page > _scope.firstPage) {
      final resume = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            appText(
              ref.read(appLanguageProvider),
              'শেষ পড়া জায়গা থেকে শুরু করবেন?',
              'Continue where you left off?',
            ),
          ),
          content: Text(
            '${appText(ref.read(appLanguageProvider), 'এই সূরায় আপনার শেষ পড়া: আয়াত', 'Last read in this surah: ayah')} ${localDigits('${saved.ayahNumber}', ref.read(appLanguageProvider))}।',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                appText(
                  ref.read(appLanguageProvider),
                  'শুরু থেকে',
                  'Start over',
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                appText(
                  ref.read(appLanguageProvider),
                  'চালিয়ে যান',
                  'Continue',
                ),
              ),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (resume == true) page = saved.page;
    }
    await ref
        .read(readerControllerProvider.notifier)
        .openPage(
          page,
          preferredSurahNumber: _scope.initialSurahNumber,
          firstPage: _scope.firstPage,
          lastPage: _scope.lastPage,
        );
  }

  @override
  Widget build(BuildContext context) {
    final reader = ref.watch(readerControllerProvider);
    final audio = ref.watch(quranAudioControllerProvider);
    final showTranslation = ref.watch(showTranslationPreferenceProvider);
    final language = ref.watch(appLanguageProvider);
    ref.listen<String?>(activeAyahPlaybackKeyProvider, (previous, next) {
      if (next == null || next == previous) return;
      unawaited(_ensurePlaybackAyahLoaded(next));
    });

    final primary = _surahs.isEmpty ? widget.surah : _primarySurah;
    final showPlayer =
        audio.mode == QuranAudioMode.ayah &&
        (audio.status == QuranAudioStatus.loading ||
            audio.status == QuranAudioStatus.playing ||
            audio.status == QuranAudioStatus.paused) &&
        _activeAyah(audio.ayahKey) != null;
    final reciterName =
        ref
            .watch(reciterCatalogControllerProvider)
            .value
            ?.selectedReciter
            ?.name ??
        appText(language, 'কুরআন তিলাওয়াত', 'Quran recitation');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(primary?.nameArabic ?? ''),
            ),
            Text(
              language == AppLanguage.bangla
                  ? (primary == null
                        ? 'কুরআন'
                        : localizedSurahName(primary, language))
                  : (primary?.nameEnglish ?? 'Quran'),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: showTranslation ? 'Hide translation' : 'Show translation',
            onPressed: () => ref
                .read(appPreferencesControllerProvider.notifier)
                .setShowTranslation(!showTranslation),
            icon: Icon(
              showTranslation
                  ? Icons.translate_rounded
                  : Icons.translate_outlined,
            ),
          ),
          IconButton(
            tooltip: appText(language, 'বুকমার্ক', 'Bookmarks'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BookmarksPage()),
            ),
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
          IconButton(
            tooltip: appText(language, 'কারি ও অডিও', 'Reciters & audio'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SettingsPage(
                    currentSurahNumber:
                        primary?.number ?? _scope.initialSurahNumber,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      bottomSheet: showPlayer
          ? (_playerMinimized
                ? ReaderMinimizedPlaybackBar(onExpand: _expandPlayer)
                : ReaderPlaybackPanel(
                    state: audio,
                    reciterName: reciterName,
                    onPause: () => unawaited(
                      ref.read(quranAudioControllerProvider.notifier).pause(),
                    ),
                    onResume: () => ref
                        .read(quranAudioControllerProvider.notifier)
                        .resume(),
                    onPrevious: () => unawaited(_playAdjacent(forward: false)),
                    onNext: () => unawaited(_playAdjacent(forward: true)),
                    onSeek: (position) => unawaited(
                      ref
                          .read(quranAudioControllerProvider.notifier)
                          .seek(position),
                    ),
                    onSpeed: (speed) => unawaited(
                      ref
                          .read(quranAudioControllerProvider.notifier)
                          .setSpeed(speed),
                    ),
                    onRepeat: () => unawaited(_choosePlayerRepeat()),
                    onStop: () =>
                        unawaited(ref.read(readerAudioActionsProvider).stop()),
                    onMinimize: _minimizePlayer,
                  ))
          : null,
      body: reader.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ReaderError(onRetry: _openSelectedScope),
        data: (state) {
          if (_surahs.isEmpty ||
              state.currentPage < _scope.firstPage ||
              state.currentPage > _scope.lastPage) {
            return const Center(child: CircularProgressIndicator());
          }

          final pages = _visibleLoadedPages(state.loadedPages);
          final windows = <int, QuranPageWindow>{};
          for (final page in pages) {
            final source = state.windows[page];
            if (source == null) continue;
            final ayahs = source.ayahs
                .where(_scope.contains)
                .toList(growable: false);
            if (ayahs.isEmpty) continue;
            windows[page] = QuranPageWindow(
              page: source.page,
              ayahs: ayahs,
              previousPage: source.previousPage,
              nextPage: source.nextPage,
            );
          }

          if (windows.isEmpty) {
            return const Center(child: Text('Reader content unavailable.'));
          }

          _syncPageKeys(windows.keys.toList(growable: false));
          _scheduleCurrentPagePosition(state.currentPage);
          final activeSurahNumber =
              windows[state.currentPage]?.ayahs.firstOrNull?.surahNumber ??
              windows.values.first.ayahs.first.surahNumber;
          final activeIndex = _surahs.indexWhere(
            (surah) => surah.number == activeSurahNumber,
          );
          final activeSurah = _surahs[activeIndex];
          final previousSurah = activeIndex > 0
              ? _surahs[activeIndex - 1]
              : null;
          final nextSurah = activeIndex < _surahs.length - 1
              ? _surahs[activeIndex + 1]
              : null;

          return Column(
            children: [
              ReaderSurahNavigation(
                previous: previousSurah,
                current: activeSurah,
                next: nextSurah,
                language: language,
                centerLabel: _scope is JuzReaderScope
                    ? '${appText(language, 'জুজ', 'Juz')} ${localDigits('${(_scope as JuzReaderScope).juz.number}', language)} · ${localizedSurahName(activeSurah, language)}'
                    : null,
                onSelected: _openSurahScope,
              ),
              Expanded(
                child: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: _handleScrollNotification,
                      child: CustomScrollView(
                        key: PageStorageKey(
                          'quran-reader-${_scope.runtimeType}-${_scope.initialSurahNumber}',
                        ),
                        controller: _scrollController,
                        scrollCacheExtent: const ScrollCacheExtent.pixels(900),
                        slivers: [
                          SliverToBoxAdapter(
                            child: ReaderSurahHeader(
                              surah: activeSurah,
                              language: language,
                              onPlay: () {
                                _expandPlayer();
                                unawaited(_playSurahFromStart(activeSurah));
                              },
                              onTafsir: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => TafsirReaderPage(
                                    surahNumber: activeSurah.number,
                                    ayahNumber: 1,
                                    wholeSurah: true,
                                    ayahCount: activeSurah.ayahCount,
                                  ),
                                ),
                              ),
                              onDownload: _showDownloadMenu,
                            ),
                          ),
                          for (final page in windows.keys)
                            ReaderWindow(
                              key: _pageKeys[page],
                              window: windows[page]!,
                              showTranslation: showTranslation,
                              onShowPlayer: _expandPlayer,
                              jumpToAyahNumber:
                                  windows[page]!.ayahs.any(
                                    (ayah) =>
                                        ayah.ayahNumber == _jumpTargetAyah,
                                  )
                                  ? _jumpTargetAyah
                                  : null,
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
                      ),
                    ),
                    if (_scope is SurahReaderScope)
                      Positioned(
                        top: 8,
                        right: 1,
                        bottom: 8,
                        child: NumberQuickScrollRail(
                          count: _primarySurah.ayahCount,
                          semanticLabel: 'Ayah',
                          current: _jumpTargetAyah,
                          onPreview: (_) {},
                          onSelected: (number) =>
                              unawaited(_chooseAyah(number)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _expandPlayer() {
    if (mounted && _playerMinimized) {
      setState(() => _playerMinimized = false);
    }
  }

  void _minimizePlayer() {
    if (mounted && !_playerMinimized) {
      setState(() => _playerMinimized = true);
    }
  }

  Future<void> _playSurahFromStart(QuranSurahSummary surah) async {
    try {
      final firstAyah = await ref
          .read(quranRepositoryProvider)
          .loadAyah(
            surahNumber: surah.number,
            ayahNumber: 1,
            translationResourceId: ref.read(quranTranslationResourceIdProvider),
          );
      if (!mounted || firstAyah == null || !_scope.contains(firstAyah)) {
        return;
      }
      await _goToAndPlay(firstAyah, repeatCount: 1);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error is ReaderAudioUnavailableException
                  ? error.message
                  : appText(
                      ref.read(appLanguageProvider),
                      'তিলাওয়াত চালু করা যায়নি।',
                      'Could not start recitation.',
                    ),
            ),
          ),
        );
    }
  }

  void _showDownloadMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.headphones_rounded),
              title: const Text('Audio download'),
              onTap: () {
                Navigator.pop(sheetContext);
                unawaited(_downloadAudio());
              },
            ),
            ListTile(
              leading: Icon(
                _wordDownloaded
                    ? Icons.download_done_rounded
                    : Icons.translate_rounded,
              ),
              title: const Text('বাংলা word download'),
              subtitle: _wordDownloadActive
                  ? Text('$_wordDownloadCompleted/${_primarySurah.ayahCount}')
                  : _wordDownloaded
                  ? const Text('Ready offline')
                  : null,
              enabled: !_wordDownloadActive && !_wordDownloaded,
              onTap: () {
                Navigator.pop(sheetContext);
                unawaited(_downloadBanglaWords());
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books_outlined),
              title: const Text('Tafsir download'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TafsirReaderPage(
                      surahNumber: _primarySurah.number,
                      ayahNumber: 1,
                      wholeSurah: true,
                      ayahCount: _primarySurah.ayahCount,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAudio() async {
    try {
      await runReaderOfflineDownloadWithProgress(
        context,
        surahNumber: _primarySurah.number,
        download: (onProgress) => ref
            .read(readerOfflineAudioGateProvider)
            .downloadSurah(_primarySurah.number, onProgress: onProgress),
        cancel: () => ref
            .read(readerOfflineAudioGateProvider)
            .cancelDownload(_primarySurah.number),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio is ready offline.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio download failed. Try again.')),
        );
      }
    }
  }

  Future<void> _ensurePlaybackAyahLoaded(String ayahKey) async {
    for (var attempt = 0; attempt < 3 && mounted; attempt++) {
      final current = ref.read(readerControllerProvider).value;
      if (current == null) return;
      final visiblePages = _visibleLoadedPages(current.loadedPages);
      final alreadyLoaded = visiblePages.any(
        (page) =>
            current.windows[page]?.ayahs.any((ayah) => ayah.key == ayahKey) ??
            false,
      );
      if (alreadyLoaded ||
          visiblePages.isEmpty ||
          visiblePages.last >= _scope.lastPage) {
        return;
      }

      await _loadNextWindow();
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  List<int> _visibleLoadedPages(List<int> pages) => pages
      .where((page) => page >= _scope.firstPage && page <= _scope.lastPage)
      .toList(growable: false);

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _userScrollActive = notification.dragDetails != null;
    } else if (notification is ScrollEndNotification) {
      if (_userScrollActive) unawaited(_saveVisiblePosition());
      _userScrollActive = false;
    }

    if (!_userScrollActive) return false;
    if (notification is! ScrollUpdateNotification &&
        notification is! OverscrollNotification) {
      return false;
    }

    final metrics = notification.metrics;
    if (metrics.extentAfter < _paginationThreshold) {
      unawaited(_loadNextWindow());
    }
    if (metrics.extentBefore < _paginationThreshold) {
      unawaited(_loadPreviousWindow());
    }
    return false;
  }

  Future<void> _saveVisiblePosition() async {
    final state = ref.read(readerControllerProvider).value;
    if (state == null) return;
    final pages = _visibleLoadedPages(state.loadedPages);
    int? visiblePage;
    for (final page in pages) {
      final render = _pageKeys[page]?.currentContext?.findRenderObject();
      if (render == null || !render.attached) continue;
      final y = MatrixUtils.transformPoint(
        render.getTransformTo(null),
        Offset.zero,
      ).dy;
      if (y <= 180) visiblePage = page;
    }
    visiblePage ??= pages.isEmpty ? null : pages.first;
    if (visiblePage == null || visiblePage == _lastSavedPage) return;
    final ayahs = state.windows[visiblePage]?.ayahs.where(_scope.contains);
    if (ayahs == null || ayahs.isEmpty) return;
    _lastSavedPage = visiblePage;
    final location = ReadingLocation(
      page: visiblePage,
      surahNumber: ayahs.first.surahNumber,
      ayahNumber: ayahs.first.ayahNumber,
    );
    final store = ref.read(readingLocationStoreProvider);
    await store.save(location);
    if (_scope is SurahReaderScope && store is SurahReadingLocationStore) {
      await (store as SurahReadingLocationStore).saveForSurah(location);
    }
  }

  Future<void> _loadNextWindow() async {
    if (_loadingNext) return;
    final current = ref.read(readerControllerProvider).value;
    if (current == null) return;
    final visiblePages = _visibleLoadedPages(current.loadedPages);
    if (visiblePages.isEmpty || visiblePages.last >= _scope.lastPage) return;

    _loadingNext = true;
    try {
      await ref.read(readerControllerProvider.notifier).loadNextWindow();
    } catch (error, stackTrace) {
      debugPrint('Could not load the next Surah reader page: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _loadingNext = false;
    }
  }

  Future<void> _loadPreviousWindow() async {
    if (_loadingPrevious || !_scrollController.hasClients) return;
    final current = ref.read(readerControllerProvider).value;
    if (current == null) return;
    final visiblePages = _visibleLoadedPages(current.loadedPages);
    if (visiblePages.isEmpty || visiblePages.first <= _scope.firstPage) {
      return;
    }

    _loadingPrevious = true;
    final position = _scrollController.position;
    final beforePixels = position.pixels;
    final beforeMaxExtent = position.maxScrollExtent;
    try {
      await ref.read(readerControllerProvider.notifier).loadPreviousWindow();
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !_scrollController.hasClients) return;

      final afterMaxExtent = _scrollController.position.maxScrollExtent;
      final insertedExtent = afterMaxExtent - beforeMaxExtent;
      if (insertedExtent > 0) {
        final target = (beforePixels + insertedExtent).clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        );
        _scrollController.jumpTo(target.toDouble());
      }
    } catch (error, stackTrace) {
      debugPrint('Could not load the previous Surah reader page: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _loadingPrevious = false;
    }
  }

  void _syncPageKeys(List<int> pages) {
    final available = pages.toSet();
    _pageKeys.removeWhere((page, _) => !available.contains(page));
    for (final page in pages) {
      _pageKeys.putIfAbsent(page, () => GlobalKey());
    }
  }

  void _scheduleCurrentPagePosition(int page) {
    if (_lastPositionedPage == page || !_pageKeys.containsKey(page)) return;
    if (page == _scope.firstPage && _jumpTargetAyah == null) {
      _lastPositionedPage = page;
      return;
    }
    _lastPositionedPage = page;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetContext = _pageKeys[page]?.currentContext;
      if (targetContext == null) {
        _lastPositionedPage = null;
        return;
      }
      unawaited(
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0,
          duration: Duration.zero,
        ),
      );
    });
  }

  void _openSurahScope(QuranSurahSummary surah) {
    if (_scope is SurahReaderScope && surah.number == _primarySurah.number) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => QuranReaderPage(surah: surah)),
    );
  }

  QuranAyah? _activeAyah(String? key) {
    if (key == null) return null;
    final state = ref.read(readerControllerProvider).value;
    if (state == null) return null;
    for (final window in state.windows.values) {
      for (final ayah in window.ayahs) {
        if (ayah.key == key && _scope.contains(ayah)) return ayah;
      }
    }
    return null;
  }

  Future<void> _playAdjacent({required bool forward}) async {
    final audio = ref.read(quranAudioControllerProvider);
    final current = _activeAyah(audio.ayahKey);
    if (current == null) return;
    final adjacent = await ref
        .read(readerAudioActionsProvider)
        .adjacentAyah(current, forward: forward, scope: _scope);
    if (!mounted || adjacent == null) return;
    await _goToAndPlay(adjacent);
  }

  Future<void> _goToAndPlay(QuranAyah ayah, {int? repeatCount}) async {
    setState(() {
      _jumpTargetAyah = ayah.ayahNumber;
      _lastPositionedPage = null;
    });
    await ref
        .read(readerControllerProvider.notifier)
        .openPage(
          ayah.pageNumber,
          preferredSurahNumber: ayah.surahNumber,
          firstPage: _scope.firstPage,
          lastPage: _scope.lastPage,
        );
    if (!mounted) return;
    await ref
        .read(readerAudioActionsProvider)
        .playAyah(
          ayah,
          repeatCount: repeatCount ?? ref.read(defaultRepeatCountProvider),
          speed: ref.read(quranAudioControllerProvider).speed,
          pauseBetweenRepeats: ref.read(repeatPauseProvider),
          autoNext: ref.read(autoNextAyahProvider),
        );
  }

  Future<void> _choosePlayerRepeat() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final count in AppPreferences.supportedRepeatCounts)
              ListTile(
                title: Text('$count×'),
                trailing:
                    count == ref.read(quranAudioControllerProvider).repeatTotal
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, count),
              ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    await ref
        .read(appPreferencesControllerProvider.notifier)
        .setDefaultRepeatCount(selected);
    final current = _activeAyah(ref.read(quranAudioControllerProvider).ayahKey);
    if (current != null) await _goToAndPlay(current, repeatCount: selected);
  }
}

class _ReaderError extends StatelessWidget {
  const _ReaderError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Quran content could not be loaded.'),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => unawaited(onRetry()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
