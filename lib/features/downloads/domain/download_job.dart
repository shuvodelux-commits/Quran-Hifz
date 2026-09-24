enum DownloadJobStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

enum DownloadErrorCode {
  insufficientStorage,
  httpFailure,
  sizeMismatch,
  ioFailure,
}

class AudioDownloadRequest {
  const AudioDownloadRequest({
    required this.audioKey,
    required this.audioType,
    required this.remoteUrl,
    required this.relativePath,
    this.expectedBytes,
    this.reciterId,
    this.surahNumber,
    this.ayahNumber,
    this.wordPosition,
    this.format,
  });

  final String audioKey;
  final String audioType;
  final String remoteUrl;
  final String relativePath;
  final int? expectedBytes;
  final int? reciterId;
  final int? surahNumber;
  final int? ayahNumber;
  final int? wordPosition;
  final String? format;
}

class DownloadJob {
  const DownloadJob({
    required this.audioKey,
    required this.audioType,
    required this.remoteUrl,
    required this.relativePath,
    required this.status,
    required this.downloadedBytes,
    this.expectedBytes,
    this.reciterId,
    this.surahNumber,
    this.ayahNumber,
    this.wordPosition,
    this.format,
    this.localPath,
    this.errorCode,
  });

  factory DownloadJob.fromRequest(AudioDownloadRequest request) {
    return DownloadJob(
      audioKey: request.audioKey,
      audioType: request.audioType,
      remoteUrl: request.remoteUrl,
      relativePath: request.relativePath,
      status: DownloadJobStatus.queued,
      downloadedBytes: 0,
      expectedBytes: request.expectedBytes,
      reciterId: request.reciterId,
      surahNumber: request.surahNumber,
      ayahNumber: request.ayahNumber,
      wordPosition: request.wordPosition,
      format: request.format,
    );
  }

  final String audioKey;
  final String audioType;
  final String remoteUrl;
  final String relativePath;
  final DownloadJobStatus status;
  final int downloadedBytes;
  final int? expectedBytes;
  final int? reciterId;
  final int? surahNumber;
  final int? ayahNumber;
  final int? wordPosition;
  final String? format;
  final String? localPath;
  final String? errorCode;

  DownloadJob copyWith({
    DownloadJobStatus? status,
    int? downloadedBytes,
    Object? localPath = _unset,
    Object? errorCode = _unset,
  }) {
    return DownloadJob(
      audioKey: audioKey,
      audioType: audioType,
      remoteUrl: remoteUrl,
      relativePath: relativePath,
      status: status ?? this.status,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      expectedBytes: expectedBytes,
      reciterId: reciterId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      wordPosition: wordPosition,
      format: format,
      localPath: identical(localPath, _unset)
          ? this.localPath
          : localPath as String?,
      errorCode: identical(errorCode, _unset)
          ? this.errorCode
          : errorCode as String?,
    );
  }
}

const _unset = Object();
