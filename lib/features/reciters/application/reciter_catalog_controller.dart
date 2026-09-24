import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../downloads/application/download_controller.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/data/quran_audio_sync_service.dart';
import '../../downloads/domain/download_job.dart';

import '../../quran/domain/word_audio_source.dart';
import '../data/quran_reciter_repository.dart';
import '../data/user_database_reciter_settings_store.dart';
import '../domain/chapter_reciter.dart';
import '../domain/reciter_repository.dart';
import 'reciter_audio_providers.dart';

enum ChapterPreparationStatus {
  idle,
  downloading,
  completed,
  cancelled,
  failed,
}

class ReciterCatalogState {
  const ReciterCatalogState({
    required this.reciters,
    required this.selectedReciterId,
    this.preparingSurahNumber,
    this.preparationProgress,
    this.preparationStatus = ChapterPreparationStatus.idle,
  });

  final List<ChapterReciter> reciters;
  final int? selectedReciterId;
  final int? preparingSurahNumber;
  final ChapterAudioPreparationProgress? preparationProgress;
  final ChapterPreparationStatus preparationStatus;

  ChapterReciter? get selectedReciter {
    final selected = selectedReciterId;
    if (selected == null) return null;
    for (final reciter in reciters) {
      if (reciter.id == selected) return reciter;
    }
    return null;
  }

  ReciterCatalogState copyWith({
    List<ChapterReciter>? reciters,
    int? selectedReciterId,
    bool clearSelectedReciter = false,
    int? preparingSurahNumber,
    bool clearPreparingSurah = false,
    ChapterAudioPreparationProgress? preparationProgress,
    ChapterPreparationStatus? preparationStatus,
  }) {
    return ReciterCatalogState(
      reciters: reciters ?? this.reciters,
      selectedReciterId: clearSelectedReciter
          ? null
          : (selectedReciterId ?? this.selectedReciterId),
      preparingSurahNumber: clearPreparingSurah
          ? null
          : (preparingSurahNumber ?? this.preparingSurahNumber),
      preparationProgress: preparationProgress ?? this.preparationProgress,
      preparationStatus: preparationStatus ?? this.preparationStatus,
    );
  }
}

enum ChapterAudioPreparationStage { chapter, words, complete }

class ChapterAudioPreparationProgress {
  const ChapterAudioPreparationProgress({
    required this.stage,
    required this.totalWordFiles,
    required this.processedWordFiles,
    required this.downloadedWordFiles,
    required this.failedWordFiles,
    this.wordCatalogUnavailable = false,
  });

  const ChapterAudioPreparationProgress.chapter()
    : stage = ChapterAudioPreparationStage.chapter,
      totalWordFiles = 0,
      processedWordFiles = 0,
      downloadedWordFiles = 0,
      failedWordFiles = 0,
      wordCatalogUnavailable = false;

  final ChapterAudioPreparationStage stage;
  final int totalWordFiles;
  final int processedWordFiles;
  final int downloadedWordFiles;
  final int failedWordFiles;
  final bool wordCatalogUnavailable;
}

typedef ChapterAudioPreparationProgressCallback =
    void Function(ChapterAudioPreparationProgress progress);

abstract class ChapterAudioPreparer {
  Future<ChapterAudioSyncResult> prepare({
    required int reciterId,
    required int surahNumber,
    required bool downloadAudio,
    ChapterAudioPreparationProgressCallback? onProgress,
    bool Function()? isCancelled,
  });
}

class QuranAudioSyncChapterPreparer implements ChapterAudioPreparer {
  QuranAudioSyncChapterPreparer(this._service, this._wordAudioCatalog);

  static const _wordDownloadBatchSize = 4;

  final QuranAudioSync _service;
  final SurahWordAudioCatalog _wordAudioCatalog;

  @override
  Future<ChapterAudioSyncResult> prepare({
    required int reciterId,
    required int surahNumber,
    required bool downloadAudio,
    ChapterAudioPreparationProgressCallback? onProgress,
    bool Function()? isCancelled,
  }) async {
    void throwIfCancelled() {
      if (isCancelled?.call() == true) {
        throw const ChapterAudioDownloadException(
          status: DownloadJobStatus.cancelled,
          errorCode: null,
        );
      }
    }

    throwIfCancelled();
    if (downloadAudio) {
      onProgress?.call(const ChapterAudioPreparationProgress.chapter());
    }

    final chapter = await _service.syncChapter(
      reciterId: reciterId,
      surahNumber: surahNumber,
      downloadAudio: downloadAudio,
    );
    throwIfCancelled();
    if (!downloadAudio) return chapter;

    List<QuranWordAudioSource> words;
    try {
      words = await _wordAudioCatalog.listForSurah(surahNumber);
    } catch (_) {
      onProgress?.call(
        const ChapterAudioPreparationProgress(
          stage: ChapterAudioPreparationStage.complete,
          totalWordFiles: 0,
          processedWordFiles: 0,
          downloadedWordFiles: 0,
          failedWordFiles: 0,
          wordCatalogUnavailable: true,
        ),
      );
      return chapter;
    }

    var processed = 0;
    var downloaded = 0;
    var failed = 0;

    void report(ChapterAudioPreparationStage stage) {
      onProgress?.call(
        ChapterAudioPreparationProgress(
          stage: stage,
          totalWordFiles: words.length,
          processedWordFiles: processed,
          downloadedWordFiles: downloaded,
          failedWordFiles: failed,
        ),
      );
    }

    report(ChapterAudioPreparationStage.words);
    throwIfCancelled();

    for (
      var offset = 0;
      offset < words.length;
      offset += _wordDownloadBatchSize
    ) {
      throwIfCancelled();
      final end = (offset + _wordDownloadBatchSize)
          .clamp(0, words.length)
          .toInt();
      final batch = words.sublist(offset, end);
      final results = await Future.wait(batch.map(_cacheWordSafely));
      for (final success in results) {
        processed += 1;
        if (success) {
          downloaded += 1;
        } else {
          failed += 1;
        }
      }
      report(ChapterAudioPreparationStage.words);
      throwIfCancelled();
    }

    report(ChapterAudioPreparationStage.complete);
    return chapter;
  }

  Future<bool> _cacheWordSafely(QuranWordAudioSource word) async {
    try {
      final localPath = await _service.cacheWordAudio(
        surahNumber: word.surahNumber,
        ayahNumber: word.ayahNumber,
        wordPosition: word.wordPosition,
        relativeAudioPath: word.remotePath,
      );
      return localPath != null && localPath.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

final reciterRepositoryProvider = Provider<ReciterRepository>((ref) {
  return QuranReciterRepository(
    source: ref.watch(reciterCatalogSourceProvider),
    settings: UserDatabaseReciterSettingsStore(ref.watch(userDatabaseProvider)),
  );
});

final chapterAudioPreparerProvider = Provider<ChapterAudioPreparer>((ref) {
  final service = QuranAudioSyncService(
    chapterAudioSource: ref.watch(chapterAudioSourceProvider),
    database: ref.watch(userDatabaseProvider),
    downloads: ref.watch(audioDownloadRepositoryProvider),
  );
  return QuranAudioSyncChapterPreparer(
    service,
    ref.watch(surahWordAudioCatalogProvider),
  );
});

final reciterCatalogControllerProvider =
    AsyncNotifierProvider<ReciterCatalogController, ReciterCatalogState>(
      ReciterCatalogController.new,
    );

class ReciterCatalogController extends AsyncNotifier<ReciterCatalogState> {
  static const _defaultReciterId = 7;

  bool _cancelRequested = false;
  ReciterRepository get _repository => ref.read(reciterRepositoryProvider);
  ChapterAudioPreparer get _preparer => ref.read(chapterAudioPreparerProvider);

  @override
  Future<ReciterCatalogState> build() async {
    final reciters = await _repository.loadCatalog();
    var selected = await _repository.loadSelectedReciterId();
    final selectedIsValid =
        selected != null && reciters.any((item) => item.id == selected);
    if (selected != null && !selectedIsValid) {
      await _repository.clearSelectedReciter();
      selected = null;
    }
    if (selected == null &&
        reciters.any((item) => item.id == _defaultReciterId)) {
      selected = _defaultReciterId;
      await _repository.selectReciter(selected);
    }

    return ReciterCatalogState(reciters: reciters, selectedReciterId: selected);
  }

  Future<void> refresh() async {
    final previous = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final reciters = await _repository.loadCatalog();
      final selected =
          previous?.selectedReciterId ??
          await _repository.loadSelectedReciterId();
      final selectedIsValid =
          selected != null && reciters.any((item) => item.id == selected);
      if (selected != null && !selectedIsValid) {
        await _repository.clearSelectedReciter();
      }
      return ReciterCatalogState(
        reciters: reciters,
        selectedReciterId: selectedIsValid ? selected : null,
      );
    });
  }

  Future<void> select(int id) async {
    final current = state.value;
    if (current == null || !current.reciters.any((item) => item.id == id)) {
      throw ArgumentError.value(id, 'id', 'Unknown chapter-reciter id.');
    }

    await _repository.selectReciter(id);
    state = AsyncData(current.copyWith(selectedReciterId: id));
  }

  Future<ChapterAudioSyncResult> prepareChapter({
    required int surahNumber,
    required bool downloadAudio,
  }) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError.value(surahNumber, 'surahNumber');
    }
    final current = state.value;
    final selected = current?.selectedReciterId;
    if (current == null || selected == null) {
      throw StateError('Select a Quran reciter first.');
    }

    _cancelRequested = false;
    state = AsyncData(
      current.copyWith(
        preparingSurahNumber: surahNumber,
        preparationStatus: downloadAudio
            ? ChapterPreparationStatus.downloading
            : ChapterPreparationStatus.idle,
        preparationProgress: downloadAudio
            ? const ChapterAudioPreparationProgress.chapter()
            : null,
      ),
    );
    try {
      final result = await _preparer.prepare(
        reciterId: selected,
        surahNumber: surahNumber,
        downloadAudio: downloadAudio,
        isCancelled: () => _cancelRequested,
        onProgress: (progress) {
          final latest = state.value;
          if (latest != null) {
            state = AsyncData(latest.copyWith(preparationProgress: progress));
          }
        },
      );
      if (_cancelRequested) {
        throw const ChapterAudioDownloadException(
          status: DownloadJobStatus.cancelled,
          errorCode: null,
        );
      }
      final latest = state.value;
      if (latest != null && downloadAudio) {
        state = AsyncData(
          latest.copyWith(
            preparationStatus: ChapterPreparationStatus.completed,
          ),
        );
      }
      return result;
    } catch (error) {
      final latest = state.value;
      if (latest != null && downloadAudio) {
        state = AsyncData(
          latest.copyWith(
            preparationStatus:
                _cancelRequested ||
                    error is ChapterAudioDownloadException &&
                        error.status == DownloadJobStatus.cancelled
                ? ChapterPreparationStatus.cancelled
                : ChapterPreparationStatus.failed,
          ),
        );
      }
      rethrow;
    } finally {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(clearPreparingSurah: true));
      }
    }
  }

  Future<void> cancelPrepare() async {
    final current = state.value;
    final surah = current?.preparingSurahNumber;
    final reciter = current?.selectedReciterId;
    if (surah == null ||
        reciter == null ||
        current?.preparationStatus != ChapterPreparationStatus.downloading) {
      return;
    }
    _cancelRequested = true;
    final downloads = ref.read(audioDownloadRepositoryProvider);
    final chapterKey = 'chapter:$reciter:$surah';
    final chapter = await downloads.getJob(chapterKey);
    if (chapter == null || chapter.status != DownloadJobStatus.completed) {
      await downloads.cancel(chapterKey);
    }
    final jobs = await downloads.listJobs();
    for (final job in jobs) {
      if (job.audioType == 'word' &&
          job.surahNumber == surah &&
          (job.status == DownloadJobStatus.downloading ||
              job.status == DownloadJobStatus.queued)) {
        await downloads.cancel(job.audioKey);
      }
    }
    final latest = state.value;
    if (latest != null) {
      state = AsyncData(
        latest.copyWith(preparationStatus: ChapterPreparationStatus.cancelled),
      );
    }
  }
}
