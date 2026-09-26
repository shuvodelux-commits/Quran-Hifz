const bundledPrimaryTranslationSourceId = 'bundled.bn.zakaria';

enum QuranTranslationSourceKind { bundled, downloaded, remote }

class QuranTranslationSource {
  const QuranTranslationSource({
    required this.sourceId,
    required this.name,
    required this.language,
    required this.version,
    required this.kind,
    this.resourceId,
    this.author,
    this.localPath,
    this.availableOffline = true,
  });

  final String sourceId;
  final int? resourceId;
  final String name;
  final String language;
  final String version;
  final String? author;
  final String? localPath;
  final QuranTranslationSourceKind kind;
  final bool availableOffline;
}

class QuranTranslationEntry {
  const QuranTranslationEntry({
    required this.sourceId,
    required this.sourceName,
    required this.language,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });

  final String sourceId;
  final String sourceName;
  final String language;
  final int surahNumber;
  final int ayahNumber;
  final String text;
}
