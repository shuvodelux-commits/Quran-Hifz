import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/database/user_database.dart';
import '../../downloads/application/download_controller.dart';
import '../../downloads/domain/audio_download_repository.dart';
import '../../downloads/domain/download_job.dart';
import '../../reciters/application/reciter_catalog_controller.dart';
import '../../reciters/data/quran_reciter_repository.dart';

enum ReaderOfflineDownloadStage { chapter, words, complete }

class ReaderOfflineDownloadProgress {
  const ReaderOfflineDownloadProgress({
    required this.stage,
    required this.processedWordAudio,
    required this.totalWordAudio,
    required this.failedWordAudio,
    this.wordCatalogUnavailable = false,
  });

  const ReaderOfflineDownloadProgress.chapter()
    : stage = ReaderOfflineDownloadStage.chapter,
      processedWordAudio = 0,
      totalWordAudio = 0,
      failedWordAudio = 0,
      wordCatalogUnavailable = false;

  final ReaderOfflineDownloadStage stage;
  final int processedWordAudio;
  final int totalWordAudio;
  final int failedWordAudio;
  final bool wordCatalogUnavailable;

  double? get wordProgress {
    if (stage == ReaderOfflineDownloadStage.chapter) return null;
    if (totalWordAudio <= 0) return 1;
    return (processedWordAudio / totalWordAudio).clamp(0, 1).toDouble();
  }
}

class ReaderOfflineDownloadResult {
  const ReaderOfflineDownloadResult({
    required this.totalWordAudio,
    required this.downloadedWordAudio,
    required this.failedWordAudio,
    required this.wordCatalogUnavailable,
  });

  final int totalWordAudio;
  final int downloadedWordAudio;
  final int failedWordAudio;
  final bool wordCatalogUnavailable;

  bool get hasPartialWordAudio => wordCatalogUnavailable || failedWordAudio > 0;
}

typedef ReaderOfflineDownloadProgressCallback =
    void Function(ReaderOfflineDownloadProgress progress);

class ReaderOfflineAudioStatus {
  const ReaderOfflineAudioStatus({
    required this.hasSelectedReciter,
    required this.isDownloaded,
  });

  final bool hasSelectedReciter;
  final bool isDownloaded;
}

abstract interface class ReaderOfflineAudioGate {
  Future<ReaderOfflineAudioStatus> statusForSurah(int surahNumber);

  Future<ReaderOfflineDownloadResult> downloadSurah(
    int surahNumber, {
    ReaderOfflineDownloadProgressCallback? onProgress,
  });

  Future<void> cancelDownload(int surahNumber);
}

class DatabaseReaderOfflineAudioGate implements ReaderOfflineAudioGate {
  DatabaseReaderOfflineAudioGate({
    required UserDatabase database,
    required ChapterAudioPreparer preparer,
    required AudioDownloadRepository downloads,
  }) : _database = database,
       _preparer = preparer,
       _downloads = downloads;

  final UserDatabase _database;
  final ChapterAudioPreparer _preparer;
  final AudioDownloadRepository _downloads;
  final Set<int> _cancelledSurahs = <int>{};

  @override
  Future<ReaderOfflineAudioStatus> statusForSurah(int surahNumber) async {
    final reciterId = await _selectedReciterId();
    if (reciterId == null) {
      return const ReaderOfflineAudioStatus(
        hasSelectedReciter: false,
        isDownloaded: false,
      );
    }

    final row = await _database.getAudio('chapter:$reciterId:$surahNumber');
    final localPath = row?.localPath;
    if (localPath == null || localPath.isEmpty || localPath.endsWith('.part')) {
      return const ReaderOfflineAudioStatus(
        hasSelectedReciter: true,
        isDownloaded: false,
      );
    }

    final file = File(localPath);
    final downloaded = await file.exists() && await file.length() > 0;
    return ReaderOfflineAudioStatus(
      hasSelectedReciter: true,
      isDownloaded: downloaded,
    );
  }

  @override
  Future<ReaderOfflineDownloadResult> downloadSurah(
    int surahNumber, {
    ReaderOfflineDownloadProgressCallback? onProgress,
  }) async {
    _cancelledSurahs.remove(surahNumber);
    final reciterId = await _selectedReciterId();
    if (reciterId == null) {
      throw StateError('Select a Quran reciter first.');
    }

    ChapterAudioPreparationProgress? latest;
    await _preparer.prepare(
      reciterId: reciterId,
      surahNumber: surahNumber,
      downloadAudio: true,
      isCancelled: () => _cancelledSurahs.contains(surahNumber),
      onProgress: (progress) {
        latest = progress;
        onProgress?.call(_mapProgress(progress));
      },
    );

    final progress = latest;
    if (progress == null) {
      return const ReaderOfflineDownloadResult(
        totalWordAudio: 0,
        downloadedWordAudio: 0,
        failedWordAudio: 0,
        wordCatalogUnavailable: false,
      );
    }

    return ReaderOfflineDownloadResult(
      totalWordAudio: progress.totalWordFiles,
      downloadedWordAudio: progress.downloadedWordFiles,
      failedWordAudio: progress.failedWordFiles,
      wordCatalogUnavailable: progress.wordCatalogUnavailable,
    );
  }

  @override
  Future<void> cancelDownload(int surahNumber) async {
    _cancelledSurahs.add(surahNumber);
    final reciterId = await _selectedReciterId();
    if (reciterId == null) return;
    await _downloads.cancel('chapter:$reciterId:$surahNumber');
    for (final job in await _downloads.listJobs()) {
      if (job.audioType == 'word' &&
          job.surahNumber == surahNumber &&
          (job.status == DownloadJobStatus.downloading ||
              job.status == DownloadJobStatus.queued)) {
        await _downloads.cancel(job.audioKey);
      }
    }
  }

  ReaderOfflineDownloadProgress _mapProgress(
    ChapterAudioPreparationProgress progress,
  ) {
    final stage = switch (progress.stage) {
      ChapterAudioPreparationStage.chapter =>
        ReaderOfflineDownloadStage.chapter,
      ChapterAudioPreparationStage.words => ReaderOfflineDownloadStage.words,
      ChapterAudioPreparationStage.complete =>
        ReaderOfflineDownloadStage.complete,
    };
    return ReaderOfflineDownloadProgress(
      stage: stage,
      processedWordAudio: progress.processedWordFiles,
      totalWordAudio: progress.totalWordFiles,
      failedWordAudio: progress.failedWordFiles,
      wordCatalogUnavailable: progress.wordCatalogUnavailable,
    );
  }

  Future<int?> _selectedReciterId() async {
    final raw = await _database.getSetting(
      QuranReciterRepository.selectedReciterKey,
    );
    final value = int.tryParse(raw ?? '');
    return value == null || value <= 0 ? null : value;
  }
}

final readerOfflineAudioGateProvider = Provider<ReaderOfflineAudioGate>((ref) {
  return DatabaseReaderOfflineAudioGate(
    database: ref.watch(userDatabaseProvider),
    preparer: ref.watch(chapterAudioPreparerProvider),
    downloads: ref.watch(audioDownloadRepositoryProvider),
  );
});
