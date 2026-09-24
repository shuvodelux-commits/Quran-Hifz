import 'mushaf_pack_manifest.dart';

enum MushafPackStatus {
  notInstalled,
  queued,
  downloading,
  verifying,
  installing,
  installed,
  failed,
  cancelled,
}

class MushafPackProgress {
  const MushafPackProgress({
    required this.packId,
    required this.status,
    this.downloadedBytes = 0,
    this.totalBytes,
    this.error,
  });

  final String packId;
  final MushafPackStatus status;
  final int downloadedBytes;
  final int? totalBytes;
  final String? error;

  double? get fraction {
    final total = totalBytes;
    if (total == null || total <= 0) return null;
    return (downloadedBytes / total).clamp(0, 1);
  }
}

class InstalledMushafPack {
  const InstalledMushafPack({required this.manifest, required this.rootPath});

  final MushafPackManifest manifest;
  final String rootPath;
}

abstract class MushafPackRepository {
  Future<List<MushafPackManifest>> list();

  Stream<MushafPackProgress> install(String id);

  Future<void> cancel(String id);

  Future<void> delete(String id);

  Future<InstalledMushafPack?> installedPack(String id);
}
