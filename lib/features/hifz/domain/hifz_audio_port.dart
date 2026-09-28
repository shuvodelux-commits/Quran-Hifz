import 'hifz_step.dart';

class HifzStepProgress {
  const HifzStepProgress({
    required this.repeatIndex,
    required this.repeatTotal,
  });

  final int repeatIndex;
  final int repeatTotal;
}

typedef HifzStepProgressCallback = void Function(HifzStepProgress progress);

class HifzPlaybackStoppedException implements Exception {
  const HifzPlaybackStoppedException();
}

abstract class HifzAudioPort {
  Future<void> playStep(HifzStep step, {HifzStepProgressCallback? onProgress});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
}
