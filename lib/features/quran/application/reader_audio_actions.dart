import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/user_database.dart';
import '../../audio/application/audio_providers.dart';
import '../../audio/domain/audio_timing.dart';
import '../../audio/domain/playback_requests.dart';
import '../../audio/domain/quran_audio_state.dart';
import '../../downloads/application/download_controller.dart';
import '../../reciters/application/reciter_audio_providers.dart';
import '../../reciters/data/quran_reciter_repository.dart';
import '../data/quran_audio_sync_service.dart';
import '../domain/quran_ayah.dart';
import '../domain/quran_repository.dart';
import '../domain/quran_word.dart';
import '../domain/reader_scope.dart';
import 'quran_providers.dart';

class ReaderAudioUnavailableException implements Exception {
  const ReaderAudioUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class ReaderPlaybackRequestResolver {
  Future<WordPlaybackRequest> resolveWord(QuranAyah ayah, QuranWord word);

  Future<AyahPlaybackRequest> resolveAyah(
    QuranAyah ayah, {
    required int repeatCount,
    required Duration pauseBetweenRepeats,
    required double speed,
  });
}

abstract class ReaderAudioPort {
  Future<void> playWord(WordPlaybackRequest request);
  Future<void> playAyah(AyahPlaybackRequest request);
  Future<void> stop();
  QuranAudioState readState();
}

class QuranControllerReaderAudioPort implements ReaderAudioPort {
  QuranControllerReaderAudioPort({
    required Future<void> Function(WordPlaybackRequest request) playWord,
    required Future<void> Function(AyahPlaybackRequest request) playAyah,
    required Future<void> Function() stop,
    required QuranAudioState Function() readState,
  }) : _playWord = playWord,
       _playAyah = playAyah,
       _stop = stop,
       _readState = readState;

  final Future<void> Function(WordPlaybackRequest request) _playWord;
  final Future<void> Function(AyahPlaybackRequest request) _playAyah;
  final Future<void> Function() _stop;
  final QuranAudioState Function() _readState;

  @override
  Future<void> playWord(WordPlaybackRequest request) => _playWord(request);

  @override
  Future<void> playAyah(AyahPlaybackRequest request) => _playAyah(request);

  @override
  QuranAudioState readState() => _readState();

  @override
  Future<void> stop() => _stop();
}

class DriftReaderPlaybackRequestResolver
    implements ReaderPlaybackRequestResolver {
  DriftReaderPlaybackRequestResolver({
    required UserDatabase database,
    required QuranAudioSync syncService,
  }) : _database = database,
       _syncService = syncService;

  final UserDatabase _database;
  final QuranAudioSync _syncService;

  @override
  Future<WordPlaybackRequest> resolveWord(
    QuranAyah ayah,
    QuranWord word,
  ) async {
    final path = word.audioUrl;
    if (path == null || path.trim().isEmpty) {
      throw const ReaderAudioUnavailableException(
        'Word pronunciation audio is unavailable.',
      );
    }

    final remoteUrl = path.startsWith('http')
        ? path
        : '${AppConfig.wordAudioCdnBase}$path';

    unawaited(
      _cacheWordAudioInBackground(
        ayah: ayah,
        word: word,
        relativeAudioPath: path,
      ),
    );

    return WordPlaybackRequest(
      source: remoteUrl,
      audioKey: 'word:${ayah.surahNumber}:${ayah.ayahNumber}:${word.position}',
      wordKey: '${ayah.key}:${word.position}',
      ayahKey: ayah.key,
      wordPosition: word.position,
    );
  }

  Future<void> _cacheWordAudioInBackground({
    required QuranAyah ayah,
    required QuranWord word,
    required String relativeAudioPath,
  }) async {
    try {
      await _syncService.cacheWordAudio(
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        wordPosition: word.position,
        relativeAudioPath: relativeAudioPath,
      );
    } catch (_) {
      // Caching is best-effort; a failed download must not block immediate play.
    }
  }

  @override
  Future<AyahPlaybackRequest> resolveAyah(
    QuranAyah ayah, {
    required int repeatCount,
    required Duration pauseBetweenRepeats,
    required double speed,
  }) async {
    final rawReciterId = await _database.getSetting(
      QuranReciterRepository.selectedReciterKey,
    );
    final reciterId = int.tryParse(rawReciterId ?? '');
    if (reciterId == null || reciterId <= 0) {
      throw const ReaderAudioUnavailableException(
        'Select a Quran reciter before playing an ayah.',
      );
    }

    final audioKey = 'chapter:$reciterId:${ayah.surahNumber}';
    var audio = await _database.getAudio(audioKey);
    var timing = await _database.getAyahTiming(
      reciterId: reciterId,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
    );

    if (audio == null || audio.remoteUrl.isEmpty || timing == null) {
      await _syncService.syncChapter(
        reciterId: reciterId,
        surahNumber: ayah.surahNumber,
        downloadAudio: false,
      );
      audio = await _database.getAudio(audioKey);
      timing = await _database.getAyahTiming(
        reciterId: reciterId,
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
      );
    }

    if (audio == null || audio.remoteUrl.isEmpty) {
      throw ReaderAudioUnavailableException(
        'Recitation audio is unavailable for Surah ${ayah.surahNumber}.',
      );
    }
    if (timing == null || timing.endMs <= timing.startMs) {
      throw ReaderAudioUnavailableException(
        'Verified ayah timing is unavailable for ${ayah.key}.',
      );
    }

    return AyahPlaybackRequest(
      source: audio.remoteUrl,
      audioKey: audioKey,
      ayahKey: ayah.key,
      repeatCount: repeatCount,
      pauseBetweenRepeats: pauseBetweenRepeats,
      speed: speed,
      timingKey: AudioTimingKey(
        reciterId: reciterId,
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
      ),
      fallbackWordPositions: [for (final word in ayah.words) word.position],
    );
  }
}

class ReaderAudioActions {
  ReaderAudioActions({
    required QuranRepository repository,
    required ReaderPlaybackRequestResolver resolver,
    required ReaderAudioPort audio,
    required int translationResourceId,
  }) : _repository = repository,
       _resolver = resolver,
       _audio = audio,
       _translationResourceId = translationResourceId;

  final QuranRepository _repository;
  final ReaderPlaybackRequestResolver _resolver;
  final ReaderAudioPort _audio;
  final int _translationResourceId;

  int _programToken = 0;

  Future<void> playWord(QuranAyah ayah, QuranWord word) async {
    final token = ++_programToken;
    final request = await _resolver.resolveWord(ayah, word);
    if (!_isCurrent(token)) return;
    await _audio.playWord(request);
  }

  Future<QuranAyah?> adjacentAyah(
    QuranAyah current, {
    required bool forward,
    required ReaderScope scope,
  }) async {
    final surahs = await _repository.listSurahs();
    final index = surahs.indexWhere(
      (item) => item.number == current.surahNumber,
    );
    if (index < 0) return null;
    final summary = surahs[index];
    var surahNumber = current.surahNumber;
    var ayahNumber = current.ayahNumber + (forward ? 1 : -1);
    if (forward && ayahNumber > summary.ayahCount) {
      if (index == surahs.length - 1) return null;
      surahNumber = surahs[index + 1].number;
      ayahNumber = 1;
    } else if (!forward && ayahNumber < 1) {
      if (index == 0) return null;
      final previous = surahs[index - 1];
      surahNumber = previous.number;
      ayahNumber = previous.ayahCount;
    }
    final candidate = await _repository.loadAyah(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      translationResourceId: _translationResourceId,
    );
    return candidate != null && scope.contains(candidate) ? candidate : null;
  }

  Future<void> playAyah(
    QuranAyah ayah, {
    required int repeatCount,
    required double speed,
    required Duration pauseBetweenRepeats,
    required bool autoNext,
  }) async {
    if (repeatCount <= 0) {
      throw ArgumentError.value(repeatCount, 'repeatCount');
    }
    if (speed <= 0) {
      throw ArgumentError.value(speed, 'speed');
    }

    final token = ++_programToken;
    var current = ayah;

    while (_isCurrent(token)) {
      final request = await _resolver.resolveAyah(
        current,
        repeatCount: repeatCount,
        pauseBetweenRepeats: pauseBetweenRepeats,
        speed: speed,
      );
      if (!_isCurrent(token)) return;

      await _audio.playAyah(request);
      if (!_isCurrent(token)) return;

      final result = _audio.readState();
      if (result.status == QuranAudioStatus.error) {
        final error = result.error;
        if (error is Exception) throw error;
        throw StateError('Quran audio playback failed: $error');
      }
      if (result.status != QuranAudioStatus.completed || !autoNext) return;

      final next = await _repository.loadAyah(
        surahNumber: current.surahNumber,
        ayahNumber: current.ayahNumber + 1,
        translationResourceId: _translationResourceId,
      );
      if (!_isCurrent(token) || next == null) return;
      if (next.surahNumber != current.surahNumber) return;
      current = next;
    }
  }

  Future<void> stop() async {
    ++_programToken;
    await _audio.stop();
  }

  bool _isCurrent(int token) => token == _programToken;
}

final readerPlaybackRequestResolverProvider =
    Provider<ReaderPlaybackRequestResolver>((ref) {
      return DriftReaderPlaybackRequestResolver(
        database: ref.watch(userDatabaseProvider),
        syncService: QuranAudioSyncService(
          chapterAudioSource: ref.watch(chapterAudioSourceProvider),
          database: ref.watch(userDatabaseProvider),
          downloads: ref.watch(audioDownloadRepositoryProvider),
        ),
      );
    });

final readerAudioPortProvider = Provider<ReaderAudioPort>((ref) {
  final controller = ref.read(quranAudioControllerProvider.notifier);
  return QuranControllerReaderAudioPort(
    playWord: controller.playWord,
    playAyah: controller.playAyah,
    stop: controller.stop,
    readState: () => ref.read(quranAudioControllerProvider),
  );
});

final readerAudioActionsProvider = Provider<ReaderAudioActions>((ref) {
  return ReaderAudioActions(
    repository: ref.watch(quranRepositoryProvider),
    resolver: ref.watch(readerPlaybackRequestResolverProvider),
    audio: ref.watch(readerAudioPortProvider),
    translationResourceId: ref.watch(quranTranslationResourceIdProvider),
  );
});
