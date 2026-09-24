class TafsirPackageManifest {
  TafsirPackageManifest({
    required this.sourceId,
    required this.name,
    required this.language,
    required this.version,
    required this.downloadUrl,
    required this.sha256,
    required this.sizeBytes,
    this.attribution,
    this.license,
  }) {
    if (!_safeId.hasMatch(sourceId)) {
      throw ArgumentError.value(
        sourceId,
        'sourceId',
        'must be a safe non-empty package id',
      );
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    if (language.trim().isEmpty) {
      throw ArgumentError.value(language, 'language', 'must not be empty');
    }
    if (!_safeVersion.hasMatch(version)) {
      throw ArgumentError.value(
        version,
        'version',
        'must be a safe non-empty version',
      );
    }
    if (!downloadUrl.hasScheme ||
        (downloadUrl.scheme != 'https' && downloadUrl.scheme != 'http')) {
      throw ArgumentError.value(downloadUrl, 'downloadUrl', 'must be HTTP(S)');
    }
    if (!_sha256.hasMatch(sha256)) {
      throw ArgumentError.value(
        sha256,
        'sha256',
        'must be a 64-character hexadecimal SHA-256',
      );
    }
    if (sizeBytes <= 0) {
      throw ArgumentError.value(
        sizeBytes,
        'sizeBytes',
        'must be greater than zero',
      );
    }
  }

  factory TafsirPackageManifest.fromJson(Map<String, Object?> json) {
    return TafsirPackageManifest(
      sourceId: json['source_id']! as String,
      name: json['name']! as String,
      language: json['language']! as String,
      version: json['version']! as String,
      downloadUrl: Uri.parse(json['download_url']! as String),
      sha256: json['sha256']! as String,
      sizeBytes: (json['size_bytes']! as num).toInt(),
      attribution: json['attribution'] as String?,
      license: json['license'] as String?,
    );
  }

  static final RegExp _safeId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$');
  static final RegExp _safeVersion = RegExp(
    r'^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$',
  );
  static final RegExp _sha256 = RegExp(r'^[0-9a-fA-F]{64}$');

  final String sourceId;
  final String name;
  final String language;
  final String version;
  final Uri downloadUrl;
  final String sha256;
  final int sizeBytes;
  final String? attribution;
  final String? license;
}
