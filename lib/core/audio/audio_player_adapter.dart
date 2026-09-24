enum AudioTerminalState { completed, interrupted }

abstract class AudioPlayerAdapter {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;

  Future<void> load(String source);
  Future<void> seek(Duration position);
  Future<void> setClip({Duration? start, Duration? end});
  void play();
  Future<AudioTerminalState> waitForTerminal();
  Future<void> pause();
  Future<void> stop();
  Future<void> setSpeed(double speed);
  Future<void> dispose();
}
