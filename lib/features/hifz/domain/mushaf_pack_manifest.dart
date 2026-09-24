class MushafPackManifest {
  MushafPackManifest({
    required this.id,
    required this.name,
    required this.script,
    required this.version,
    required this.pageCount,
    required this.sizeBytes,
    required this.sha256,
    required this.downloadUrl,
    required this.attribution,
    required this.license,
    required this.pageFilePattern,
    this.coordinatesFile,
  }) {
    _validateSafeIdentifier(id, 'id');
    _validateRequiredText(name, 'name');
    _validateRequiredText(script, 'script');
    _validateSafeIdentifier(version, 'version');
    if (pageCount < 1 || pageCount > 604) {
      throw const FormatException('page_count must be between 1 and 604');
    }
    if (sizeBytes <= 0) {
      throw const FormatException('size_bytes must be greater than zero');
    }
    if (!_sha256Pattern.hasMatch(sha256)) {
      throw const FormatException(
        'sha256 must contain exactly 64 hexadecimal characters',
      );
    }
    if (downloadUrl.scheme != 'https' || downloadUrl.host.isEmpty) {
      throw const FormatException('download_url must be an absolute HTTPS URL');
    }
    _validateRequiredText(attribution, 'attribution');
    _validateRequiredText(license, 'license');
    _validatePagePattern(pageFilePattern);
    final coordinatePath = coordinatesFile;
    if (coordinatePath != null) {
      _validateRelativePath(coordinatePath, 'coordinates_file');
      if (!coordinatePath.toLowerCase().endsWith('.json')) {
        throw const FormatException('coordinates_file must be a JSON file');
      }
    }
  }

  factory MushafPackManifest.fromJson(Map<String, Object?> json) {
    try {
      return MushafPackManifest(
        id: _string(json, 'id'),
        name: _string(json, 'name'),
        script: _string(json, 'script'),
        version: _string(json, 'version'),
        pageCount: _integer(json, 'page_count'),
        sizeBytes: _integer(json, 'size_bytes'),
        sha256: _string(json, 'sha256'),
        downloadUrl: Uri.parse(_string(json, 'download_url')),
        attribution: _string(json, 'attribution'),
        license: _string(json, 'license'),
        pageFilePattern: _string(json, 'page_file_pattern'),
        coordinatesFile: _optionalString(json, 'coordinates_file'),
      );
    } on FormatException {
      rethrow;
    } on Object catch (error) {
      throw FormatException('Invalid Mushaf pack manifest: $error');
    }
  }

  final String id;
  final String name;
  final String script;
  final String version;
  final int pageCount;
  final int sizeBytes;
  final String sha256;
  final Uri downloadUrl;
  final String attribution;
  final String license;
  final String pageFilePattern;
  final String? coordinatesFile;

  String pagePath(int page) {
    if (page < 1 || page > pageCount) {
      throw RangeError.range(page, 1, pageCount, 'page');
    }
    return pageFilePattern.replaceAll('{page}', '$page');
  }

  static final RegExp _identifierPattern = RegExp(
    r'^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$',
  );
  static final RegExp _sha256Pattern = RegExp(r'^[0-9a-fA-F]{64}$');

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String) throw FormatException('$key must be a string');
    return value;
  }

  static String? _optionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) throw FormatException('$key must be a string');
    return value;
  }

  static int _integer(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! num || value != value.roundToDouble()) {
      throw FormatException('$key must be an integer');
    }
    return value.toInt();
  }

  static void _validateRequiredText(String value, String field) {
    if (value.trim().isEmpty) throw FormatException('$field must not be empty');
  }

  static void _validateSafeIdentifier(String value, String field) {
    if (!_identifierPattern.hasMatch(value)) {
      throw FormatException('$field contains unsafe characters');
    }
  }

  static void _validatePagePattern(String value) {
    _validateRelativePath(value, 'page_file_pattern');
    if (RegExp(r'\{page\}').allMatches(value).length != 1) {
      throw const FormatException(
        'page_file_pattern must contain one {page} placeholder',
      );
    }
    if (!value.toLowerCase().endsWith('.webp')) {
      throw const FormatException('page_file_pattern must use WebP pages');
    }
  }

  static void _validateRelativePath(String value, String field) {
    if (value.isEmpty ||
        value.startsWith('/') ||
        value.contains(r'\') ||
        value.split('/').any((segment) => segment.isEmpty || segment == '..')) {
      throw FormatException('$field must be a safe relative path');
    }
  }
}
