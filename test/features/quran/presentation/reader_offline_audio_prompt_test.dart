import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/application/reader_offline_audio_gate.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/reader_offline_audio_prompt.dart';

void main() {
  testWidgets('offers download, online streaming, and cancel', (tester) async {
    ReaderOfflineAudioChoice? choice;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                choice = await showReaderOfflineAudioPrompt(
                  context,
                  surahNumber: 1,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('সূরার অডিও ডাউনলোড'), findsOneWidget);
    expect(find.text('ডাউনলোড'), findsOneWidget);
    expect(find.text('অনলাইনে শুনুন'), findsOneWidget);
    expect(find.text('বাতিল'), findsOneWidget);

    await tester.tap(find.text('অনলাইনে শুনুন'));
    await tester.pumpAndSettle();

    expect(choice, ReaderOfflineAudioChoice.continueOnline);
  });

  testWidgets('shows word download progress and partial failures', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReaderOfflineDownloadProgressView(
            surahNumber: 67,
            progress: ReaderOfflineDownloadProgress(
              stage: ReaderOfflineDownloadStage.words,
              processedWordAudio: 37,
              totalWordAudio: 142,
              failedWordAudio: 2,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Downloading Surah 67'), findsOneWidget);
    expect(find.text('Word audio: 37 / 142'), findsOneWidget);
    expect(
      find.text('2 word files will be available to retry later.'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('download progress can continue in background or be cancelled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var background = false;
    var cancelled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderOfflineDownloadProgressView(
            surahNumber: 1,
            progress: const ReaderOfflineDownloadProgress.chapter(),
            onBackground: () => background = true,
            onCancel: () => cancelled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Background'));
    expect(background, isTrue);
    await tester.tap(find.text('Cancel download'));
    expect(cancelled, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('download failure prompt offers retry or online playback', (
    tester,
  ) async {
    ReaderOfflineDownloadFailureChoice? choice;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                choice = await showReaderOfflineDownloadFailurePrompt(
                  context,
                  message: 'The Surah audio download did not complete.',
                );
              },
              child: const Text('Open failure'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open failure'));
    await tester.pumpAndSettle();

    expect(find.text('Download could not finish'), findsOneWidget);
    expect(find.text('Retry Download'), findsOneWidget);
    expect(find.text('Continue Online'), findsOneWidget);

    await tester.tap(find.text('Retry Download'));
    await tester.pumpAndSettle();

    expect(choice, ReaderOfflineDownloadFailureChoice.retry);
  });
}
