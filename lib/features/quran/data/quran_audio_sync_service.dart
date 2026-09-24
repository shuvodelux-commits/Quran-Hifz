import '../../../core/config/app_config.dart';
import '../../../core/database/user_database.dart';
import '../../downloads/domain/audio_download_repository.dart';
import '../../downloads/domain/download_job.dart';
import '../../reciters/domain/chapter_audio_source.dart';

abstract interface class QuranAudioSync {
  Future<ChapterAudioSyncResult> syncChapter({
    required int reciterId,
    required int surahNumber,
    bool downloadAudio = true,
  });

  Future<String?> cacheWordAudio({
    required int surahNumber,
    required int ayahNumber,
    required int wordPosition,
    required String relativeAudioPath,
  });
}

class QuranAudioSyncService implements QuranAudioSync {
  QuranAudioSyncService({
    required ChapterAudioSource chapterAudioSource,
    required UserDatabase database,
    required AudioDownloadRepository downloads,
  }) : _chapterAudioSource = chapterAudioSource,
       _database = database,
       _downloads = downloads;

  final ChapterAudioSource _chapterAudioSource;
  final UserDatabase _database;
  final AudioDownloadRepository _downloads;

  @override
  Future<ChapterAudioSyncResult> syncChapter({
    required int reciterId,
    required int surahNumber,
    bool downloadAudio = true,
  }) async {
    final response = await _chapterAudioSource.loadChapterAudio(
      reciterId: reciterId,
      surahNumber: surahNumber,
    );

    final audio = Map<String, dynamic>.from(response['audio_file'] as Map);
    final remoteUrl = audio['audio_url'] as String;
    final format = (audio['format'] as String?) ?? 'mp3';
    final fileSize = (audio['file_size'] as num?)?.toInt();

    final timestampsRaw = audio['timestamps'] as List<dynamic>? ?? const [];
    final timestamps = timestampsRaw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    await _database.replaceTimings(
      reciterId: reciterId,
      surahNumber: surahNumber,
      timestamps: timestamps,
    );

    final audioKey = 'chapter:$reciterId:$surahNumber';
    await _database.registerAudioSource(
      audioKey: audioKey,
      audioType: 'chapter',
      remoteUrl: remoteUrl,
      reciterId: reciterId,
      surahNumber: surahNumber,
      format: format,
      fileSize: fileSize,
    );

    String? localPath = (await _database.getAudio(audioKey))?.localPath;
    if (downloadAudio) {
      final request = AudioDownloadRequest(
        audioKey: audioKey,
        audioType: 'chapter',
        remoteUrl: remoteUrl,
        relativePath:
            'reciters/$reciterId/${surahNumber.toString().padLeft(3, '0')}.$format',
        expectedBytes: fileSize,
        reciterId: reciterId,
        surahNumber: surahNumber,
        format: format,
      );
      await _downloads.enqueue(request);
      final result = await _downloads.download(request.audioKey);
      if (result.status != DownloadJobStatus.completed ||
          result.localPath == null ||
          result.localPath!.isEmpty) {
        throw ChapterAudioDownloadException(
          status: result.status,
          errorCode: result.errorCode,
        );
      }
      localPath = result.localPath;
    }

    return ChapterAudioSyncResult(
      reciterId: reciterId,
      surahNumber: surahNumber,
      remoteUrl: remoteUrl,
      localPath: localPath,
      format: format,
      fileSize: fileSize,
      ayahTimingCount: timestamps.length,
    );
  }

  @override
  Future<String?> cacheWordAudio({
    required int surahNumber,
    required int ayahNumber,
    required int wordPosition,
    required String relativeAudioPath,
  }) async {
    final remoteUrl = relativeAudioPath.startsWith('http')
        ? relativeAudioPath
        : '${AppConfig.wordAudioCdnBase}$relativeAudioPath';
    final s = surahNumber.toString().padLeft(3, '0');
    final a = ayahNumber.toString().padLeft(3, '0');
    final w = wordPosition.toString().padLeft(3, '0');
    final request = AudioDownloadRequest(
      audioKey: 'word:$surahNumber:$ayahNumber:$wordPosition',
      audioType: 'word',
      remoteUrl: remoteUrl,
      relativePath: 'words/$s/$a/$w.mp3',
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      wordPosition: wordPosition,
      format: 'mp3',
    );
    await _downloads.enqueue(request);
    final result = await _downloads.download(request.audioKey);
    return result.localPath;
  }
}

class ChapterAudioSyncResult {
  const ChapterAudioSyncResult({
    required this.reciterId,
    required this.surahNumber,
    required this.remoteUrl,
    required this.localPath,
    required this.format,
    required this.fileSize,
    required this.ayahTimingCount,
  });

  final int reciterId;
  final int surahNumber;
  final String remoteUrl;
  final String? localPath;
  final String format;
  final int? fileSize;
  final int ayahTimingCount;
}

class ChapterAudioDownloadException implements Exception {
  const ChapterAudioDownloadException({
    required this.status,
    required this.errorCode,
  });

  final DownloadJobStatus status;
  final String? errorCode;

  String get userMessage {
    switch (errorCode) {
      case 'insufficientStorage':
        return 'Not enough free storage to download this Surah.';
      case 'httpFailure':
        return 'The audio server rejected the download request.';
      case 'sizeMismatch':
        return 'The downloaded audio size did not match the verified metadata.';
      case 'ioFailure':
        return 'The audio download was interrupted or could not be written.';
      default:
        if (status == DownloadJobStatus.paused) {
          return 'The Surah download is paused.';
        }
        if (status == DownloadJobStatus.cancelled) {
          return 'The Surah download was cancelled.';
        }
        return 'The Surah audio download did not complete.';
    }
  }

  @override
  String toString() =>
      'ChapterAudioDownloadException(status: ${status.name}, errorCode: $errorCode)';
}
