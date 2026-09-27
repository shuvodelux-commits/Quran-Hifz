import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/application/hifz_sequence_builder.dart';
import 'package:quran_hifz/features/hifz/application/hifz_session_controller.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_audio_port.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_progress.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_step.dart';

void main() {
  const config = HifzSessionConfig(
    start: AyahRef(surahNumber: 67, ayahNumber: 1),
    end: AyahRef(surahNumber: 67, ayahNumber: 3),
    preset: HifzPresets.newMemorization,
  );

  test('executes planned steps in order and persists completion', () async {
    final repository = _FakeHifzRepository();
    final audio = _RecordingAudioPort();
    final container = _container(repository: repository, audio: audio);
    addTearDown(container.dispose);

    await container.read(hifzSessionControllerProvider.notifier).start(config);

    final expected = const HifzSequenceBuilder().build(config);
    expect(audio.steps, expected);
    expect(repository.learningAyahs, {
      const AyahRef(surahNumber: 67, ayahNumber: 1),
      const AyahRef(surahNumber: 67, ayahNumber: 2),
      const AyahRef(surahNumber: 67, ayahNumber: 3),
    });
    expect(repository.checkpoint?.nextStepIndex, expected.length);
    expect(repository.checkpoint?.status, HifzSessionStatus.completed);
    expect(
      container.read(hifzSessionControllerProvider).status,
      HifzSessionStatus.completed,
    );
  });

  test('publishes within-step repeat progress for Hifz UI', () async {
    final repository = _FakeHifzRepository();
    final audio = _ProgressAudioPort();
    final container = _container(repository: repository, audio: audio);
    addTearDown(container.dispose);

    final running = container
        .read(hifzSessionControllerProvider.notifier)
        .start(config);
    await audio.started.future;

    final state = container.read(hifzSessionControllerProvider);
    expect(state.currentStepIndex, 0);
    expect(state.stepRepeatIndex, 3);
    expect(state.stepRepeatTotal, 5);
    expect(state.currentStep, isA<AyahStep>());

    audio.complete();
    await running;
  });

  test(
    'stop cancels current program and preserves current step checkpoint',
    () async {
      final repository = _FakeHifzRepository();
      final audio = _BlockingAudioPort();
      final container = _container(repository: repository, audio: audio);
      addTearDown(container.dispose);

      final running = container
          .read(hifzSessionControllerProvider.notifier)
          .start(config);
      await audio.started.future;

      await container.read(hifzSessionControllerProvider.notifier).stop();
      await running;

      expect(audio.stopCalls, 1);
      expect(repository.checkpoint?.nextStepIndex, 0);
      expect(repository.checkpoint?.status, HifzSessionStatus.stopped);
      expect(
        container.read(hifzSessionControllerProvider).status,
        HifzSessionStatus.stopped,
      );
    },
  );

  test('external notification stop becomes stopped instead of error', () async {
    final repository = _FakeHifzRepository();
    final audio = _ExternallyStoppedAudioPort();
    final container = _container(repository: repository, audio: audio);
    addTearDown(container.dispose);

    await container.read(hifzSessionControllerProvider.notifier).start(config);

    final state = container.read(hifzSessionControllerProvider);
    expect(state.status, HifzSessionStatus.stopped);
    expect(state.error, isNull);
    expect(repository.checkpoint?.status, HifzSessionStatus.stopped);
    expect(repository.checkpoint?.nextStepIndex, 0);
  });

  test('resume after restart continues from persisted next step', () async {
    final repository = _FakeHifzRepository();
    final allSteps = const HifzSequenceBuilder().build(config);
    repository.checkpoint = HifzSessionCheckpoint(
      profileKey: HifzSessionController.defaultProfileKey,
      config: config,
      nextStepIndex: 2,
      status: HifzSessionStatus.stopped,
      updatedAt: DateTime.utc(2026, 9, 4),
    );
    final audio = _RecordingAudioPort();
    final container = _container(repository: repository, audio: audio);
    addTearDown(container.dispose);

    await container.read(hifzSessionControllerProvider.notifier).resume();

    expect(audio.steps, allSteps.skip(2).toList());
    expect(repository.checkpoint?.nextStepIndex, allSteps.length);
    expect(repository.checkpoint?.status, HifzSessionStatus.completed);
  });

  test('pause and in-memory resume delegate to the audio port', () async {
    final repository = _FakeHifzRepository();
    final audio = _BlockingAudioPort();
    final container = _container(repository: repository, audio: audio);
    addTearDown(container.dispose);

    final running = container
        .read(hifzSessionControllerProvider.notifier)
        .start(config);
    await audio.started.future;

    await container.read(hifzSessionControllerProvider.notifier).pause();
    expect(audio.pauseCalls, 1);
    expect(repository.checkpoint?.status, HifzSessionStatus.paused);

    await container.read(hifzSessionControllerProvider.notifier).resume();
    expect(audio.resumeCalls, 1);
    expect(repository.checkpoint?.status, HifzSessionStatus.running);

    await container.read(hifzSessionControllerProvider.notifier).stop();
    await running;
  });
}

ProviderContainer _container({
  required HifzRepository repository,
  required HifzAudioPort audio,
}) {
  return ProviderContainer(
    overrides: [
      hifzRepositoryProvider.overrideWithValue(repository),
      hifzAudioPortProvider.overrideWithValue(audio),
    ],
  );
}

class _FakeHifzRepository implements HifzRepository {
  HifzSessionCheckpoint? checkpoint;
  final Set<AyahRef> learningAyahs = {};

  @override
  Future<HifzSessionCheckpoint?> loadCheckpoint(String profileKey) async {
    return checkpoint?.profileKey == profileKey ? checkpoint : null;
  }

  @override
  Future<void> markRangeLearning({
    required String profileKey,
    required AyahRef start,
    required AyahRef end,
  }) async {
    for (var ayah = start.ayahNumber; ayah <= end.ayahNumber; ayah++) {
      learningAyahs.add(
        AyahRef(surahNumber: start.surahNumber, ayahNumber: ayah),
      );
    }
  }

  @override
  Future<void> saveCheckpoint(HifzSessionCheckpoint value) async {
    checkpoint = value;
  }

  @override
  Future<HifzProgress?> loadProgress({
    required String profileKey,
    required AyahRef ayah,
  }) async {
    return null;
  }

  @override
  Future<List<HifzProgress>> loadSurahProgress({
    required String profileKey,
    required int surahNumber,
  }) async => const <HifzProgress>[];

  @override
  Future<void> saveProgress({
    required String profileKey,
    required HifzProgress progress,
  }) async {}
}

class _RecordingAudioPort implements HifzAudioPort {
  final List<HifzStep> steps = [];

  @override
  Future<void> playStep(
    HifzStep step, {
    HifzStepProgressCallback? onProgress,
  }) async {
    steps.add(step);
    onProgress?.call(
      HifzStepProgress(
        repeatIndex: step.repeatCount,
        repeatTotal: step.repeatCount,
      ),
    );
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}
}

class _BlockingAudioPort implements HifzAudioPort {
  final Completer<void> started = Completer<void>();
  final Completer<void> _current = Completer<void>();
  int pauseCalls = 0;
  int resumeCalls = 0;
  int stopCalls = 0;

  @override
  Future<void> playStep(
    HifzStep step, {
    HifzStepProgressCallback? onProgress,
  }) async {
    if (!started.isCompleted) started.complete();
    await _current.future;
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
  }

  @override
  Future<void> resume() async {
    resumeCalls++;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    if (!_current.isCompleted) _current.complete();
  }
}

class _ProgressAudioPort implements HifzAudioPort {
  final Completer<void> started = Completer<void>();
  final Completer<void> _done = Completer<void>();

  @override
  Future<void> playStep(
    HifzStep step, {
    HifzStepProgressCallback? onProgress,
  }) async {
    onProgress?.call(const HifzStepProgress(repeatIndex: 3, repeatTotal: 5));
    if (!started.isCompleted) started.complete();
    await _done.future;
  }

  void complete() {
    if (!_done.isCompleted) _done.complete();
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async => complete();
}

class _ExternallyStoppedAudioPort implements HifzAudioPort {
  @override
  Future<void> playStep(
    HifzStep step, {
    HifzStepProgressCallback? onProgress,
  }) async {
    throw const HifzPlaybackStoppedException();
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}
}
