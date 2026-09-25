enum TafsirSourceKind { bundled, downloaded, remote }

class TafsirSource {
  const TafsirSource({
    required this.sourceId,
    required this.name,
    required this.language,
    required this.version,
    this.localPath = '',
    this.attribution,
    this.license,
    this.kind = TafsirSourceKind.downloaded,
    this.availableOffline = true,
  });

  final String sourceId;
  final String name;
  final String language;
  final String version;
  final String localPath;
  final String? attribution;
  final String? license;
  final TafsirSourceKind kind;
  final bool availableOffline;
}

class TafsirEntry {
  const TafsirEntry({
    required this.sourceId,
    required this.sourceName,
    required this.language,
    required this.version,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    this.attribution,
    this.license,
  });

  final String sourceId;
  final String sourceName;
  final String language;
  final String version;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String? attribution;
  final String? license;
}
