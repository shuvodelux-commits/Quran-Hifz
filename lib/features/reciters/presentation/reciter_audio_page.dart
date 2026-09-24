import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/application/audio_providers.dart';
import '../../audio/domain/playback_requests.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/data/quran_audio_sync_service.dart';
import '../../quran/domain/quran_surah.dart';
import '../application/reciter_catalog_controller.dart';
import '../domain/chapter_reciter.dart';
import '../../downloads/application/download_controller.dart';
import '../../downloads/domain/download_job.dart';

class ReciterAudioPage extends ConsumerStatefulWidget {
  const ReciterAudioPage({super.key, this.currentSurahNumber = 1});

  final int currentSurahNumber;

  @override
  ConsumerState<ReciterAudioPage> createState() => _ReciterAudioPageState();
}

class _ReciterAudioPageState extends ConsumerState<ReciterAudioPage> {
  late int _selectedSurahNumber;
  Timer? _progressTimer;
  DownloadJob? _chapterJob;

  @override
  void initState() {
    super.initState();
    _selectedSurahNumber = widget.currentSurahNumber;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      unawaited(_refreshChapterJob());
    });
    Future.microtask(_refreshChapterJob);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshChapterJob() async {
    final state = ref.read(reciterCatalogControllerProvider).value;
    final reciter = state?.selectedReciterId;
    if (reciter == null) return;
    final job = await ref
        .read(audioDownloadRepositoryProvider)
        .getJob('chapter:$reciter:$_selectedSurahNumber');
    if (mounted && job != _chapterJob) setState(() => _chapterJob = job);
  }

  @override
  void didUpdateWidget(covariant ReciterAudioPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSurahNumber != widget.currentSurahNumber &&
        _selectedSurahNumber == oldWidget.currentSurahNumber) {
      _selectedSurahNumber = widget.currentSurahNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(reciterCatalogControllerProvider);
    final surahs = ref.watch(quranSurahListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reciters & audio'),
        actions: [
          IconButton(
            tooltip: 'Reload reciters',
            onPressed: () =>
                ref.read(reciterCatalogControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _CatalogError(
          onRetry: () =>
              ref.read(reciterCatalogControllerProvider.notifier).refresh(),
        ),
        data: (state) {
          final busy = state.preparingSurahNumber != null;
          final busySelectedSurah =
              state.preparingSurahNumber == _selectedSurahNumber;
          final selected = state.selectedReciter;

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Surah audio',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selected == null
                            ? 'Select a reciter first.'
                            : 'Selected reciter: ${selected.name}',
                      ),
                      const SizedBox(height: 12),
                      surahs.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) =>
                            const Text('Could not load the Surah list.'),
                        data: (items) => DropdownButtonFormField<int>(
                          initialValue: _safeSelectedSurah(items),
                          decoration: const InputDecoration(
                            labelText: 'Choose Surah to play or download',
                          ),
                          items: [
                            for (final surah in items)
                              DropdownMenuItem<int>(
                                value: surah.number,
                                child: Text(_surahLabel(surah)),
                              ),
                          ],
                          onChanged: busy
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedSurahNumber = value;
                                    _chapterJob = null;
                                  });
                                  unawaited(_refreshChapterJob());
                                },
                        ),
                      ),
                      if (busySelectedSurah) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value:
                              state.preparationProgress?.stage ==
                                      ChapterAudioPreparationStage.words &&
                                  (state.preparationProgress?.totalWordFiles ??
                                          0) >
                                      0
                              ? state.preparationProgress!.processedWordFiles /
                                    state.preparationProgress!.totalWordFiles
                              : _chapterJob?.expectedBytes != null &&
                                    _chapterJob!.expectedBytes! > 0
                              ? (_chapterJob!.downloadedBytes /
                                        _chapterJob!.expectedBytes!)
                                    .clamp(0.0, 1.0)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.preparationProgress?.stage ==
                                  ChapterAudioPreparationStage.words
                              ? 'Word audio: ${state.preparationProgress!.processedWordFiles}/${state.preparationProgress!.totalWordFiles} files'
                              : 'Surah audio: ${_chapterJob?.downloadedBytes ?? 0} bytes downloaded',
                        ),
                        if (state.preparationStatus ==
                            ChapterPreparationStatus.downloading)
                          TextButton.icon(
                            onPressed: () => unawaited(
                              ref
                                  .read(
                                    reciterCatalogControllerProvider.notifier,
                                  )
                                  .cancelPrepare(),
                            ),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel download'),
                          ),
                      ],
                      if (!busySelectedSurah) ...[
                        const SizedBox(height: 8),
                        Text(switch (state.preparationStatus) {
                          ChapterPreparationStatus.completed =>
                            'Download completed',
                          ChapterPreparationStatus.cancelled =>
                            'Download cancelled',
                          ChapterPreparationStatus.failed =>
                            'Download failed · retry below',
                          _ => switch (_chapterJob?.status) {
                            DownloadJobStatus.completed =>
                              'Downloaded for offline use',
                            DownloadJobStatus.cancelled => 'Download cancelled',
                            DownloadJobStatus.failed =>
                              'Download failed · retry below',
                            _ => 'Not downloaded',
                          },
                        }),
                      ],
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: selected == null || busy
                            ? null
                            : () => _prepareSelectedSurah(
                                context,
                                ref,
                                downloadAudio: false,
                              ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play / Stream'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: selected == null || busy
                            ? null
                            : () => _prepareSelectedSurah(
                                context,
                                ref,
                                downloadAudio: true,
                              ),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download for offline'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chapter reciter',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              ...state.reciters.map(
                (reciter) => _ReciterTile(
                  reciter: reciter,
                  selected: reciter.id == state.selectedReciterId,
                  onTap: busy
                      ? null
                      : () => _selectReciter(context, ref, reciter.id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int? _safeSelectedSurah(List<QuranSurahSummary> surahs) {
    if (surahs.isEmpty) return null;
    return surahs.any((surah) => surah.number == _selectedSurahNumber)
        ? _selectedSurahNumber
        : surahs.first.number;
  }

  String _surahLabel(QuranSurahSummary surah) {
    return '${surah.number}. ${surah.nameEnglish} · ${surah.nameArabic}';
  }

  Future<void> _selectReciter(
    BuildContext context,
    WidgetRef ref,
    int reciterId,
  ) async {
    try {
      await ref
          .read(reciterCatalogControllerProvider.notifier)
          .select(reciterId);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the selected reciter.')),
      );
    }
  }

  Future<void> _prepareSelectedSurah(
    BuildContext context,
    WidgetRef ref, {
    required bool downloadAudio,
  }) async {
    final surahNumber = _selectedSurahNumber;
    try {
      final result = await ref
          .read(reciterCatalogControllerProvider.notifier)
          .prepareChapter(
            surahNumber: surahNumber,
            downloadAudio: downloadAudio,
          );
      if (!context.mounted) return;
      if (!downloadAudio) {
        final audioKey = 'chapter:${result.reciterId}:${result.surahNumber}';
        unawaited(
          ref
              .read(quranAudioControllerProvider.notifier)
              .playSurah(
                SurahPlaybackRequest(
                  source: result.remoteUrl,
                  audioKey: audioKey,
                  surahNumber: result.surahNumber,
                ),
              ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            downloadAudio
                ? (result.localPath == null
                      ? 'Audio metadata prepared, but no local file was returned.'
                      : 'Surah and word audio downloaded for offline playback.')
                : 'Surah audio playback started.',
          ),
        ),
      );
    } on ChapterAudioDownloadException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.userMessage)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            downloadAudio
                ? 'Could not download this Surah. Tap Download for offline to retry.'
                : 'Could not prepare this Surah. Tap Play / Stream to retry.',
          ),
        ),
      );
    }
  }
}

class _ReciterTile extends StatelessWidget {
  const _ReciterTile({
    required this.reciter,
    required this.selected,
    required this.onTap,
  });

  final ChapterReciter reciter;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (reciter.styleName != null) reciter.styleName!,
      if (reciter.qiratName != null) reciter.qiratName!,
    ].join(' · ');

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
        ),
        title: Text(reciter.name),
        subtitle: details.isEmpty ? null : Text(details),
        trailing: selected ? const Icon(Icons.check_rounded) : null,
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bundled reciter catalog is unavailable or corrupted.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'The app does not need a Quran backend URL for the bundled '
              'reciter list. Reinstall or use a build with verified audio '
              'metadata if this error persists.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
