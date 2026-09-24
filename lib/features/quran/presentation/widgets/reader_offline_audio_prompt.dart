import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/reader_offline_audio_gate.dart';

enum ReaderOfflineAudioChoice { download, continueOnline }

enum ReaderOfflineDownloadFailureChoice { retry, continueOnline }

Future<ReaderOfflineAudioChoice?> showReaderOfflineAudioPrompt(
  BuildContext context, {
  required int surahNumber,
}) {
  return showDialog<ReaderOfflineAudioChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('সূরার অডিও ডাউনলোড'),
      content: Text(
        'সূরা $surahNumber-এর অডিও এই ডিভাইসে নেই। ডাউনলোড করলে ইন্টারনেট ছাড়াই সূরা ও শব্দের অডিও শুনতে পারবেন। এখন ইন্টারনেটে শুনতেও পারেন।',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('বাতিল'),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(ReaderOfflineAudioChoice.continueOnline),
          child: const Text('অনলাইনে শুনুন'),
        ),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).pop(ReaderOfflineAudioChoice.download),
          icon: const Icon(Icons.download_rounded),
          label: const Text('ডাউনলোড'),
        ),
      ],
    ),
  );
}

Future<ReaderOfflineDownloadFailureChoice?>
showReaderOfflineDownloadFailurePrompt(
  BuildContext context, {
  required String message,
}) {
  return showDialog<ReaderOfflineDownloadFailureChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Download could not finish'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(ReaderOfflineDownloadFailureChoice.continueOnline),
          child: const Text('Continue Online'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).pop(ReaderOfflineDownloadFailureChoice.retry),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry Download'),
        ),
      ],
    ),
  );
}

Future<ReaderOfflineDownloadResult> runReaderOfflineDownloadWithProgress(
  BuildContext context, {
  required int surahNumber,
  required Future<ReaderOfflineDownloadResult> Function(
    ReaderOfflineDownloadProgressCallback onProgress,
  )
  download,
  required Future<void> Function() cancel,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final progress = ValueNotifier<ReaderOfflineDownloadProgress>(
    const ReaderOfflineDownloadProgress.chapter(),
  );
  var dialogOpen = true;

  final dialogFuture = showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    builder: (_) => ValueListenableBuilder<ReaderOfflineDownloadProgress>(
      valueListenable: progress,
      builder: (dialogContext, value, __) => AlertDialog(
        content: ReaderOfflineDownloadProgressView(
          surahNumber: surahNumber,
          progress: value,
          onBackground: () => Navigator.of(dialogContext).pop(),
          onCancel: () {
            unawaited(cancel());
            Navigator.of(dialogContext).pop();
          },
        ),
      ),
    ),
  ).whenComplete(() => dialogOpen = false);

  try {
    return await download((value) {
      if (dialogOpen) progress.value = value;
    });
  } finally {
    if (dialogOpen && navigator.mounted && navigator.canPop()) {
      navigator.pop();
    }
    await dialogFuture;
    progress.dispose();
  }
}

class ReaderOfflineDownloadProgressView extends StatelessWidget {
  const ReaderOfflineDownloadProgressView({
    super.key,
    required this.surahNumber,
    required this.progress,
    this.onBackground,
    this.onCancel,
  });

  final int surahNumber;
  final ReaderOfflineDownloadProgress progress;
  final VoidCallback? onBackground;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final isChapter = progress.stage == ReaderOfflineDownloadStage.chapter;
    final isComplete = progress.stage == ReaderOfflineDownloadStage.complete;

    final status = isChapter
        ? 'Downloading Surah audio…'
        : progress.wordCatalogUnavailable
        ? 'Surah audio downloaded. Word audio list is unavailable.'
        : 'Word audio: ${progress.processedWordAudio} / '
              '${progress.totalWordAudio}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.download_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Downloading Surah $surahNumber',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: isChapter ? null : progress.wordProgress,
        ),
        const SizedBox(height: 10),
        Text(status),
        if (!isChapter &&
            !progress.wordCatalogUnavailable &&
            progress.failedWordAudio > 0) ...[
          const SizedBox(height: 6),
          Text(
            '${progress.failedWordAudio} word files will be available to retry later.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (isComplete &&
            progress.totalWordAudio == 0 &&
            !progress.wordCatalogUnavailable) ...[
          const SizedBox(height: 6),
          const Text('Surah audio is ready for offline playback.'),
        ],
        if (onBackground != null || onCancel != null) ...[
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 4,
            runSpacing: 4,
            children: [
              if (onBackground != null)
                TextButton(
                  onPressed: onBackground,
                  child: const Text('Background'),
                ),
              if (onCancel != null)
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Cancel download'),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
