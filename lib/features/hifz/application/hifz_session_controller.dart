import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../audio/application/audio_providers.dart';
import '../../downloads/application/download_controller.dart';
import '../../quran/data/quran_audio_sync_service.dart';
import '../../reciters/application/reciter_audio_providers.dart';
import '../data/drift_hifz_repository.dart';
import '../data/quran_audio_hifz_port.dart';
import '../domain/hifz_audio_port.dart';
import '../domain/hifz_repository.dart';
import '../domain/hifz_session.dart';
import '../domain/hifz_step.dart';
import 'hifz_sequence_builder.dart';

class HifzSessionState {
  const HifzSessionState({
    required this.status,
    required this.currentStepIndex,
    required this.totalSteps,
    this.stepRepeatIndex = 0,
    this.stepRepeatTotal = 0,
    this.currentStep,
    this.config,
    this.error,
  });

  const HifzSessionState.initial()
    : status = HifzSessionStatus.idle,
      currentStepIndex = 0,
      totalSteps = 0,
      stepRepeatIndex = 0,
      stepRepeatTotal = 0,
      currentStep = null,
      config = null,
      error = null;

  final HifzSessionStatus status;
  final int currentStepIndex;
  final int totalSteps;
  final int stepRepeatIndex;
  final int stepRepeatTotal;
  final HifzStep? currentStep;
  final HifzSessionConfig? config;
  final Object? error;

  HifzSessionState copyWith({
    HifzSessionStatus? status,
    int? currentStepIndex,
    int? totalSteps,
    int? stepRepeatIndex,
    int? stepRepeatTotal,
    HifzStep? currentStep,
    HifzSessionConfig? config,
    Object? error,
  }) {
    return HifzSessionState(
      status: status ?? this.status,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalSteps: totalSteps ?? this.totalSteps,
      stepRepeatIndex: stepRepeatIndex ?? this.stepRepeatIndex,
      stepRepeatTotal: stepRepeatTotal ?? this.stepRepeatTotal,
      currentStep: currentStep ?? this.currentStep,
      config: config ?? this.config,
      error: error,
    );
  }
}

final hifzRepositoryProvider = Provider<HifzRepository>((ref) {
  return DriftHifzRepository(ref.watch(userDatabaseProvider));
});

final hifzSequenceBuilderProvider = Provider<HifzSequenceBuilder>((ref) {
  return const HifzSequenceBuilder();
});

final hifzAudioPortProvider = Provider<HifzAudioPort>((ref) {
  final database = ref.watch(userDatabaseProvider);
  final audioController = ref.read(quranAudioControllerProvider.notifier);

  return QuranAudioHifzPort(
    playAyah: audioController.playAyah,
    pause: audioController.pause,
    resume: audioController.resume,
    stop: audioController.stop,
    readState: () => ref.read(quranAudioControllerProvider),
    resolver: DriftHifzPlaybackRequestResolver(
      database: database,
      syncService: QuranAudioSyncService(
        chapterAudioSource: ref.watch(chapterAudioSourceProvider),
        database: database,
        downloads: ref.watch(audioDownloadRepositoryProvider),
      ),
    ),
    delay: ref.read(playbackDelayProvider),
  );
});

final hifzSessionControllerProvider =
    NotifierProvider<HifzSessionController, HifzSessionState>(
      HifzSessionController.new,
    );

class HifzSessionController extends Notifier<HifzSessionState> {
  static const defaultProfileKey = 'default';

  int _runToken = 0;

  HifzRepository get _repository => ref.read(hifzRepositoryProvider);
  HifzAudioPort get _audio => ref.read(hifzAudioPortProvider);
  HifzSequenceBuilder get _builder => ref.read(hifzSequenceBuilderProvider);

  @override
  HifzSessionState build() {
    ref.onDispose(() {
      _runToken++;
    });
    return const HifzSessionState.initial();
  }

  Future<void> start(HifzSessionConfig config) async {
    final steps = _builder.build(config);
    final token = ++_runToken;

    state = HifzSessionState(
      status: HifzSessionStatus.running,
      currentStepIndex: 0,
      totalSteps: steps.length,
      config: config,
    );

    try {
      await _repository.markRangeLearning(
        profileKey: defaultProfileKey,
        start: config.start,
        end: config.end,
      );
      if (!_isCurrent(token)) return;

      await _saveCheckpoint(
        config: config,
        nextStepIndex: 0,
        status: HifzSessionStatus.running,
      );
      if (!_isCurrent(token)) return;

      await _runSteps(
        config: config,
        steps: steps,
        startIndex: 0,
        token: token,
      );
    } on HifzPlaybackStoppedException {
      await _handleExternalStop(
        token: token,
        config: config,
        nextStepIndex: state.currentStepIndex,
      );
    } catch (error) {
      await _handleError(
        token: token,
        config: config,
        nextStepIndex: state.currentStepIndex,
        error: error,
      );
    }
  }

  Future<void> pause() async {
    if (state.status != HifzSessionStatus.running || state.config == null) {
      return;
    }

    final token = _runToken;
    await _audio.pause();
    if (!_isCurrent(token)) return;

    state = state.copyWith(status: HifzSessionStatus.paused);
    await _saveCheckpoint(
      config: state.config!,
      nextStepIndex: state.currentStepIndex,
      status: HifzSessionStatus.paused,
    );
  }

  Future<void> resume() async {
    if (state.status == HifzSessionStatus.paused && state.config != null) {
      final token = _runToken;
      await _audio.resume();
      if (!_isCurrent(token)) return;

      state = state.copyWith(status: HifzSessionStatus.running);
      await _saveCheckpoint(
        config: state.config!,
        nextStepIndex: state.currentStepIndex,
        status: HifzSessionStatus.running,
      );
      return;
    }

    final checkpoint = await _repository.loadCheckpoint(defaultProfileKey);
    if (checkpoint == null ||
        checkpoint.status == HifzSessionStatus.completed) {
      return;
    }

    final steps = _builder.build(checkpoint.config);
    if (checkpoint.nextStepIndex < 0 ||
        checkpoint.nextStepIndex > steps.length) {
      throw StateError('Persisted Hifz checkpoint is outside the sequence.');
    }

    if (checkpoint.nextStepIndex == steps.length) {
      await _saveCheckpoint(
        config: checkpoint.config,
        nextStepIndex: steps.length,
        status: HifzSessionStatus.completed,
      );
      state = HifzSessionState(
        status: HifzSessionStatus.completed,
        currentStepIndex: steps.length,
        totalSteps: steps.length,
        config: checkpoint.config,
      );
      return;
    }

    final token = ++_runToken;
    state = HifzSessionState(
      status: HifzSessionStatus.running,
      currentStepIndex: checkpoint.nextStepIndex,
      totalSteps: steps.length,
      config: checkpoint.config,
    );

    await _saveCheckpoint(
      config: checkpoint.config,
      nextStepIndex: checkpoint.nextStepIndex,
      status: HifzSessionStatus.running,
    );

    try {
      await _runSteps(
        config: checkpoint.config,
        steps: steps,
        startIndex: checkpoint.nextStepIndex,
        token: token,
      );
    } on HifzPlaybackStoppedException {
      await _handleExternalStop(
        token: token,
        config: checkpoint.config,
        nextStepIndex: state.currentStepIndex,
      );
    } catch (error) {
      await _handleError(
        token: token,
        config: checkpoint.config,
        nextStepIndex: state.currentStepIndex,
        error: error,
      );
    }
  }

  Future<void> stop() async {
    final config = state.config;
    final nextStepIndex = state.currentStepIndex;
    ++_runToken;
    await _audio.stop();

    if (config == null) {
      state = const HifzSessionState.initial();
      return;
    }

    state = state.copyWith(status: HifzSessionStatus.stopped);
    await _saveCheckpoint(
      config: config,
      nextStepIndex: nextStepIndex,
      status: HifzSessionStatus.stopped,
    );
  }

  Future<void> _runSteps({
    required HifzSessionConfig config,
    required List<HifzStep> steps,
    required int startIndex,
    required int token,
  }) async {
    for (var index = startIndex; index < steps.length; index++) {
      if (!_isCurrent(token)) return;

      final step = steps[index];
      state = state.copyWith(
        status: HifzSessionStatus.running,
        currentStepIndex: index,
        currentStep: step,
        stepRepeatIndex: 0,
        stepRepeatTotal: step.repeatCount,
      );
      await _audio.playStep(
        step,
        onProgress: (progress) {
          if (!_isCurrent(token)) return;
          state = state.copyWith(
            stepRepeatIndex: progress.repeatIndex,
            stepRepeatTotal: progress.repeatTotal,
          );
        },
      );
      if (!_isCurrent(token)) return;

      final nextStep = index + 1;
      state = state.copyWith(
        currentStepIndex: nextStep,
        stepRepeatIndex: step.repeatCount,
        stepRepeatTotal: step.repeatCount,
      );
      await _saveCheckpoint(
        config: config,
        nextStepIndex: nextStep,
        status: nextStep == steps.length
            ? HifzSessionStatus.completed
            : HifzSessionStatus.running,
      );
    }

    if (!_isCurrent(token)) return;
    state = state.copyWith(status: HifzSessionStatus.completed);
  }

  Future<void> _handleExternalStop({
    required int token,
    required HifzSessionConfig config,
    required int nextStepIndex,
  }) async {
    if (!_isCurrent(token)) return;
    state = state.copyWith(
      status: HifzSessionStatus.stopped,
      currentStepIndex: nextStepIndex,
    );
    await _saveCheckpoint(
      config: config,
      nextStepIndex: nextStepIndex,
      status: HifzSessionStatus.stopped,
    );
  }

  Future<void> _handleError({
    required int token,
    required HifzSessionConfig config,
    required int nextStepIndex,
    required Object error,
  }) async {
    if (!_isCurrent(token)) return;
    state = state.copyWith(status: HifzSessionStatus.error, error: error);
    await _saveCheckpoint(
      config: config,
      nextStepIndex: nextStepIndex,
      status: HifzSessionStatus.error,
    );
  }

  Future<void> _saveCheckpoint({
    required HifzSessionConfig config,
    required int nextStepIndex,
    required HifzSessionStatus status,
  }) {
    return _repository.saveCheckpoint(
      HifzSessionCheckpoint(
        profileKey: defaultProfileKey,
        config: config,
        nextStepIndex: nextStepIndex,
        status: status,
        updatedAt: DateTime.now(),
      ),
    );
  }

  bool _isCurrent(int token) => token == _runToken;
}
