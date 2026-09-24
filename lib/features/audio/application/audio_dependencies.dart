import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player_adapter.dart';
import '../../../core/audio/just_audio_player_adapter.dart';
import '../../../core/audio/offline_audio_resolver.dart';
import '../../../core/database/database_providers.dart';
import '../data/drift_timing_repository.dart';
import '../domain/audio_timing.dart';

typedef PlaybackDelay = Future<void> Function(Duration duration);

final audioPlayerAdapterProvider = Provider<AudioPlayerAdapter>((ref) {
  final adapter = JustAudioPlayerAdapter();
  ref.onDispose(() {
    unawaited(adapter.dispose());
  });
  return adapter;
});

final playbackDelayProvider = Provider<PlaybackDelay>((ref) {
  return Future<void>.delayed;
});

final timingRepositoryProvider = Provider<TimingRepository>((ref) {
  return DriftTimingRepository(ref.watch(userDatabaseProvider));
});

final audioSourceResolverProvider = Provider<AudioSourceResolver>((ref) {
  return OfflineAudioResolver(ref.watch(userDatabaseProvider));
});
