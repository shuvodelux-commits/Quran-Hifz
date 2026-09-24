import 'package:just_audio_background/just_audio_background.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';

typedef BackgroundAudioInitializer = Future<void> Function();

Future<void> initializeBackgroundAudio({
  BackgroundAudioInitializer? initializer,
}) {
  return (initializer ?? _initializeJustAudioBackground)();
}

/// Lets Flutter render the app before Android's media-browser connection is
/// started. Some Android vendor builds can otherwise keep the launch window
/// visible indefinitely while [AudioService] is connecting.
Future<void> initializeBackgroundAudioAfterFirstFrame({
  BackgroundAudioInitializer? initializer,
}) async {
  final firstFrame = Completer<void>();
  WidgetsBinding.instance.addPostFrameCallback((_) => firstFrame.complete());
  await firstFrame.future;
  await initializeBackgroundAudio(initializer: initializer);
}

Future<void> _initializeJustAudioBackground() {
  return JustAudioBackground.init(
    androidNotificationChannelId: 'com.quranhifz.audio',
    androidNotificationChannelName: 'Quran playback',
    androidNotificationIcon: 'drawable/ic_stat_quran',
    androidNotificationOngoing: true,
  );
}
