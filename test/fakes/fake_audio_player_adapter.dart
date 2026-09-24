import 'dart:async';

import 'package:quran_hifz/core/audio/audio_player_adapter.dart';

class FakeAudioPlayerAdapter implements AudioPlayerAdapter {
  FakeAudioPlayerAdapter({required this.autoComplete});

  final bool autoComplete;
  final List<String> loadedSources = [];
  final List<Duration> seekPositions = [];
  final List<double> speeds = [];
  final List<({Duration? start, Duration? end})> clips = [];
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  Completer<AudioTerminalState>? _terminal;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Future<void> load(String source) async {
    loadedSources.add(source);
  }

  @override
  Future<void> seek(Duration position) async {
    seekPositions.add(position);
    _positionController.add(position);
  }

  @override
  Future<void> setClip({Duration? start, Duration? end}) async {
    clips.add((start: start, end: end));
  }

  void emitPosition(Duration position) {
    _positionController.add(position);
  }

  void emitDuration(Duration duration) {
    _durationController.add(duration);
  }

  @override
  void play() {
    playCalls++;
    _terminal = Completer<AudioTerminalState>();
    if (autoComplete) {
      _terminal!.complete(AudioTerminalState.completed);
    }
  }

  @override
  Future<AudioTerminalState> waitForTerminal() {
    final terminal = _terminal;
    if (terminal == null) {
      throw StateError('play() must be called before waitForTerminal()');
    }
    return terminal.future;
  }

  void completeCurrent() {
    final terminal = _terminal;
    if (terminal != null && !terminal.isCompleted) {
      terminal.complete(AudioTerminalState.completed);
    }
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    final terminal = _terminal;
    if (terminal != null && !terminal.isCompleted) {
      terminal.complete(AudioTerminalState.interrupted);
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    speeds.add(speed);
  }

  @override
  Future<void> dispose() async {
    await _positionController.close();
    await _durationController.close();
  }
}

class ControllableDelay {
  final List<Completer<void>> _pending = [];

  int get pendingCount => _pending.where((item) => !item.isCompleted).length;

  Future<void> call(Duration duration) {
    if (duration == Duration.zero) return Future.value();
    final completer = Completer<void>();
    _pending.add(completer);
    return completer.future;
  }

  void releaseAll() {
    for (final completer in _pending) {
      if (!completer.isCompleted) completer.complete();
    }
  }
}
