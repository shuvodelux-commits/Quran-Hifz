enum QuranMushafLineType { ayah, surahName, bismillah }

class QuranWordLocation {
  const QuranWordLocation({
    required this.surahNumber,
    required this.ayahNumber,
    required this.position,
  }) : assert(surahNumber > 0),
       assert(ayahNumber > 0),
       assert(position > 0);

  final int surahNumber;
  final int ayahNumber;
  final int position;

  factory QuranWordLocation.parse(String value) {
    final match = RegExp(
      r'^([1-9][0-9]*):([1-9][0-9]*):([1-9][0-9]*)$',
    ).firstMatch(value);
    if (match == null) {
      throw FormatException(
        'Invalid Quran word location "$value". Expected surah:ayah:position '
        'with positive integers.',
      );
    }
    return QuranWordLocation(
      surahNumber: int.parse(match.group(1)!),
      ayahNumber: int.parse(match.group(2)!),
      position: int.parse(match.group(3)!),
    );
  }

  @override
  String toString() => '$surahNumber:$ayahNumber:$position';

  @override
  bool operator ==(Object other) =>
      other is QuranWordLocation &&
      other.surahNumber == surahNumber &&
      other.ayahNumber == ayahNumber &&
      other.position == position;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber, position);
}

class QuranMushafLine {
  factory QuranMushafLine({
    required int lineNumber,
    required QuranMushafLineType type,
    required bool centered,
    required int? surahNumber,
    Iterable<QuranWordLocation> wordLocations = const [],
  }) {
    final immutableLocations = List<QuranWordLocation>.unmodifiable(
      wordLocations,
    );
    if (lineNumber < 1) {
      throw ArgumentError.value(lineNumber, 'lineNumber', 'Must be positive.');
    }
    if (surahNumber != null && (surahNumber < 1 || surahNumber > 114)) {
      throw ArgumentError.value(
        surahNumber,
        'surahNumber',
        'Must be between 1 and 114.',
      );
    }
    if (type == QuranMushafLineType.ayah && immutableLocations.isEmpty) {
      throw ArgumentError.value(
        wordLocations,
        'wordLocations',
        'Ayah lines require at least one word location.',
      );
    }
    if (type != QuranMushafLineType.ayah && immutableLocations.isNotEmpty) {
      throw ArgumentError.value(
        wordLocations,
        'wordLocations',
        'Metadata lines cannot contain word locations.',
      );
    }
    if (type != QuranMushafLineType.ayah && surahNumber == null) {
      throw ArgumentError.value(
        surahNumber,
        'surahNumber',
        'Metadata lines require a Surah identity.',
      );
    }
    return QuranMushafLine._(
      lineNumber: lineNumber,
      type: type,
      centered: centered,
      surahNumber: surahNumber,
      wordLocations: immutableLocations,
    );
  }

  const QuranMushafLine._({
    required this.lineNumber,
    required this.type,
    required this.centered,
    required this.surahNumber,
    required this.wordLocations,
  });

  final int lineNumber;
  final QuranMushafLineType type;
  final bool centered;
  final int? surahNumber;
  final List<QuranWordLocation> wordLocations;
}
