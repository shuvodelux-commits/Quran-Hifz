import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../config/app_config.dart';
import 'audio_player_adapter.dart';

MediaItem buildQuranRecitationMediaItem(
  String id, {
  String title = 'Quran recitation',
}) {
  return MediaItem(id: id, album: 'Quran Hifz', title: title);
}

class JustAudioPlayerAdapter implements AudioPlayerAdapter {
  JustAudioPlayerAdapter({AudioPlayer? player})
    : _player =
          player ??
          AudioPlayer(
            userAgent: AppConfig.audioUserAgent,
            useProxyForRequestHeaders: false,
          );

  final AudioPlayer _player;
  MediaItem? _currentMediaItem;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Future<void> load(String source) async {
    final parsed = Uri.tryParse(source);
    final uri = parsed != null && parsed.hasScheme ? parsed : Uri.file(source);
    final mediaItem = buildQuranRecitationMediaItem(source);
    _currentMediaItem = mediaItem;
    await _player.setAudioSource(AudioSource.uri(uri, tag: mediaItem));
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setClip({Duration? start, Duration? end}) async {
    final isClipped = start != null || end != null;
    final tag = isClipped ? _currentMediaItem : null;
    if (isClipped && tag == null) {
      throw StateError('Audio must be loaded before applying an ayah clip.');
    }
    await _player.setClip(start: start, end: end, tag: tag);
  }

  @override
  void play() {
    unawaited(_player.play());
  }

  @override
  Future<AudioTerminalState> waitForTerminal() async {
    final current = _player.processingState;
    if (current == ProcessingState.completed) {
      return AudioTerminalState.completed;
    }
    if (current == ProcessingState.idle) {
      return AudioTerminalState.interrupted;
    }

    final terminal = await _player.processingStateStream.firstWhere(
      (state) =>
          state == ProcessingState.completed || state == ProcessingState.idle,
    );

    return terminal == ProcessingState.completed
        ? AudioTerminalState.completed
        : AudioTerminalState.interrupted;
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> dispose() => _player.dispose();
}
