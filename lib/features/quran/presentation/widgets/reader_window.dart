import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio/application/audio_providers.dart';
import '../../../settings/application/app_preferences_controller.dart';
import '../../application/reader_audio_actions.dart';
import '../../application/reader_offline_audio_gate.dart';
import '../../data/quran_audio_sync_service.dart';
import '../../domain/quran_ayah.dart';
import '../../domain/quran_page_window.dart';
import '../../domain/bismillah_policy.dart';
import 'ayah_card.dart';
import 'reader_offline_audio_prompt.dart';
import 'surah_bismillah_header.dart';

class ReaderWindow extends ConsumerStatefulWidget {
  const ReaderWindow({
    super.key,
    required this.window,
    required this.showTranslation,
    this.jumpToAyahNumber,
    this.onShowPlayer,
  });

  final QuranPageWindow window;
  final bool showTranslation;
  final int? jumpToAyahNumber;
  final VoidCallback? onShowPlayer;

  @override
  ConsumerState<ReaderWindow> createState() => _ReaderWindowState();
}

class _ReaderWindowState extends ConsumerState<ReaderWindow> {
  final Map<String, GlobalKey> _ayahKeys = {};
  final Map<String, GlobalKey> _wordKeys = {};
  String? _lastFollowTargetKey;
  int? _lastJumpedAyah;
  final Set<int> _streamApprovedSurahs = <int>{};

  @override
  Widget build(BuildContext context) {
    if (widget.window.ayahs.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('No Quran content loaded for this page.')),
      );
    }

    final visibleAyahKeys = {for (final ayah in widget.window.ayahs) ayah.key};
    final visibleWordKeys = {
      for (final ayah in widget.window.ayahs)
        for (final word in ayah.words) _wordKey(ayah.key, word.position),
    };
    _ayahKeys.removeWhere((ayahKey, _) => !visibleAyahKeys.contains(ayahKey));
    _wordKeys.removeWhere((wordKey, _) => !visibleWordKeys.contains(wordKey));

    void followPlaybackTarget(ReaderPlaybackFollowTarget? target) {
      if (target == null) {
        _lastFollowTargetKey = null;
        return;
      }

      final activeWordKey = target.wordPosition == null
          ? null
          : _wordKey(target.ayahKey, target.wordPosition!);
      final followTargetKey = activeWordKey ?? target.ayahKey;
      if (followTargetKey == _lastFollowTargetKey) return;

      final targetIsLoaded = activeWordKey != null
          ? visibleWordKeys.contains(activeWordKey)
          : visibleAyahKeys.contains(target.ayahKey);
      if (!targetIsLoaded) return;

      _lastFollowTargetKey = followTargetKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (activeWordKey != null) {
          _ensureWordVisible(activeWordKey);
        } else {
          _ensureAyahVisible(target.ayahKey);
        }
      });
    }

    ref.listen<ReaderPlaybackFollowTarget?>(
      readerPlaybackFollowTargetProvider,
      (previous, next) => followPlaybackTarget(next),
    );
    followPlaybackTarget(ref.read(readerPlaybackFollowTargetProvider));

    final firstAyah = widget.window.ayahs.first;
    final showBismillah =
        firstAyah.ayahNumber == 1 &&
        shouldShowStandaloneBismillah(firstAyah.surahNumber);
    final itemOffset = showBismillah ? 1 : 0;

    Widget itemAt(int index) {
      if (showBismillah && index == 0) {
        return SurahBismillahHeader(surahNumber: firstAyah.surahNumber);
      }
      final ayah = widget.window.ayahs[index - itemOffset];
      return KeyedSubtree(
        key: _ayahKeys.putIfAbsent(ayah.key, () => GlobalKey()),
        child: AyahCard(
          ayah: ayah,
          showTranslation: widget.showTranslation,
          onWordTap: (word) {
            unawaited(
              _runAudioAction(
                context,
                ref.read(readerAudioActionsProvider).playWord(ayah, word),
              ),
            );
          },
          wordKeyFor: (word) => _wordKeys.putIfAbsent(
            _wordKey(ayah.key, word.position),
            () => GlobalKey(),
          ),
          onPlay: (repeatCount, speed) {
            widget.onShowPlayer?.call();
            unawaited(
              _playAyahWithOfflineChoice(
                context,
                ayah: ayah,
                repeatCount: repeatCount,
                speed: speed,
              ),
            );
          },
          onShowPlayer: widget.onShowPlayer,
          onStop: () => unawaited(ref.read(readerAudioActionsProvider).stop()),
        ),
      );
    }

    final target = widget.jumpToAyahNumber;
    if (target == null) _lastJumpedAyah = null;
    if (target != null &&
        widget.window.ayahs.any((ayah) => ayah.ayahNumber == target)) {
      if (_lastJumpedAyah != target) {
        _lastJumpedAyah = target;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _ensureAyahVisible('${firstAyah.surahNumber}:$target');
        });
      }
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              for (
                var index = 0;
                index < widget.window.ayahs.length + itemOffset;
                index++
              )
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: itemAt(index),
                ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      sliver: SliverList.separated(
        itemCount: widget.window.ayahs.length + itemOffset,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) => itemAt(index),
      ),
    );
  }

  Future<void> _playAyahWithOfflineChoice(
    BuildContext context, {
    required QuranAyah ayah,
    required int repeatCount,
    required double speed,
  }) async {
    final surahNumber = ayah.surahNumber;

    if (!_streamApprovedSurahs.contains(surahNumber)) {
      try {
        final status = await ref
            .read(readerOfflineAudioGateProvider)
            .statusForSurah(surahNumber);
        if (!mounted || !context.mounted) return;

        if (status.hasSelectedReciter && !status.isDownloaded) {
          final choice = await showReaderOfflineAudioPrompt(
            context,
            surahNumber: surahNumber,
          );
          if (!mounted || !context.mounted || choice == null) return;

          if (choice == ReaderOfflineAudioChoice.download) {
            final shouldContinue = await _downloadForOfflineOrContinueOnline(
              context,
              surahNumber,
            );
            if (!shouldContinue) return;
          } else {
            _streamApprovedSurahs.add(surahNumber);
          }
        }
      } catch (error, stackTrace) {
        debugPrint('Quran offline availability check failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        // Availability prompting is optional. If the check fails, preserve
        // the existing playback path instead of blocking the user.
      }
    }

    if (!mounted || !context.mounted) return;
    await _runAudioAction(
      context,
      ref
          .read(readerAudioActionsProvider)
          .playAyah(
            ayah,
            repeatCount: repeatCount,
            speed: speed,
            pauseBetweenRepeats: ref.read(repeatPauseProvider),
            autoNext: ref.read(autoNextAyahProvider),
          ),
    );
  }

  Future<bool> _downloadForOfflineOrContinueOnline(
    BuildContext context,
    int surahNumber,
  ) async {
    while (mounted && context.mounted) {
      try {
        final result = await runReaderOfflineDownloadWithProgress(
          context,
          surahNumber: surahNumber,
          download: (onProgress) => ref
              .read(readerOfflineAudioGateProvider)
              .downloadSurah(surahNumber, onProgress: onProgress),
          cancel: () => ref
              .read(readerOfflineAudioGateProvider)
              .cancelDownload(surahNumber),
        );
        if (!mounted || !context.mounted) return false;

        final message = result.wordCatalogUnavailable
            ? 'Surah downloaded for offline playback. Word audio can be retried later.'
            : result.failedWordAudio > 0
            ? 'Surah downloaded for offline playback. '
                  '${result.downloadedWordAudio}/${result.totalWordAudio} word files are ready; '
                  '${result.failedWordAudio} can be retried later.'
            : result.totalWordAudio > 0
            ? 'Surah and word audio downloaded for offline playback.'
            : 'Surah downloaded for offline playback.';
        _showMessage(context, message);
        return true;
      } on ChapterAudioDownloadException catch (error, stackTrace) {
        debugPrint('Quran offline Surah chapter download failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        if (!mounted || !context.mounted) return false;

        final choice = await showReaderOfflineDownloadFailurePrompt(
          context,
          message: error.userMessage,
        );
        if (!mounted || !context.mounted || choice == null) return false;
        if (choice == ReaderOfflineDownloadFailureChoice.retry) continue;

        _streamApprovedSurahs.add(surahNumber);
        return true;
      } catch (error, stackTrace) {
        debugPrint('Quran offline Surah download failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        if (!mounted || !context.mounted) return false;

        final choice = await showReaderOfflineDownloadFailurePrompt(
          context,
          message:
              'The offline download could not be completed. You can retry or continue online.',
        );
        if (!mounted || !context.mounted || choice == null) return false;
        if (choice == ReaderOfflineDownloadFailureChoice.retry) continue;

        _streamApprovedSurahs.add(surahNumber);
        return true;
      }
    }

    return false;
  }

  String _wordKey(String ayahKey, int position) => '$ayahKey:$position';

  void _ensureWordVisible(String wordKey) {
    if (!mounted) return;
    final targetContext = _wordKeys[wordKey]?.currentContext;
    if (targetContext == null) return;
    final renderObject = targetContext.findRenderObject();
    final scrollable = Scrollable.maybeOf(targetContext);
    if (renderObject == null || scrollable == null) return;
    final viewport = RenderAbstractViewport.maybeOf(renderObject);
    if (viewport == null) return;

    final position = scrollable.position;
    final leading = viewport.getOffsetToReveal(renderObject, 0).offset;
    final trailing = viewport.getOffsetToReveal(renderObject, 1).offset;
    final safeLeading = position.pixels + 48;
    final safeTrailing = position.pixels + position.viewportDimension - 88;

    if (leading >= safeLeading && trailing <= safeTrailing) return;

    final target = (leading - position.viewportDimension * 0.34)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    unawaited(
      position.animateTo(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _ensureAyahVisible(String ayahKey) {
    if (!mounted) return;
    final targetContext = _ayahKeys[ayahKey]?.currentContext;
    if (targetContext == null) return;

    unawaited(
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.12,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Future<void> _runAudioAction(
    BuildContext context,
    Future<void> operation,
  ) async {
    try {
      await operation;
    } on ReaderAudioUnavailableException catch (error) {
      if (!context.mounted) return;
      _showMessage(context, error.message);
    } catch (error, stackTrace) {
      debugPrint('Quran audio action failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!context.mounted) return;
      _showMessage(context, 'Quran audio could not be played.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
