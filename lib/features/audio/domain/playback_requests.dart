import 'audio_timing.dart';

class WordPlaybackRequest {
  const WordPlaybackRequest({
    required this.source,
    required this.wordKey,
    this.audioKey,
    this.ayahKey,
    this.wordPosition,
    this.speed = 1.0,
  }) : assert(speed > 0);

  final String source;
  final String wordKey;
  final String? audioKey;
  final String? ayahKey;
  final int? wordPosition;
  final double speed;
}

class AyahPlaybackRequest {
  const AyahPlaybackRequest({
    required this.source,
    required this.ayahKey,
    this.audioKey,
    this.start = Duration.zero,
    this.repeatCount = 1,
    this.pauseBetweenRepeats = Duration.zero,
    this.speed = 1.0,
    this.timingKey,
    this.autoNext,
  }) : assert(repeatCount > 0),
       assert(speed > 0);

  final String source;
  final String ayahKey;
  final String? audioKey;
  final Duration start;
  final int repeatCount;
  final Duration pauseBetweenRepeats;
  final double speed;
  final AudioTimingKey? timingKey;
  final AyahPlaybackRequest? autoNext;
}

class SurahPlaybackRequest {
  const SurahPlaybackRequest({
    required this.source,
    required this.surahNumber,
    this.audioKey,
    this.speed = 1.0,
  }) : assert(speed > 0);

  final String source;
  final int surahNumber;
  final String? audioKey;
  final double speed;
}
