enum StudyTargetType { ayah, word }

class StudyTarget {
  const StudyTarget.ayah({required this.surahNumber, required this.ayahNumber})
    : type = StudyTargetType.ayah,
      wordPosition = null;

  const StudyTarget.word({
    required this.surahNumber,
    required this.ayahNumber,
    required int wordPosition,
  }) : type = StudyTargetType.word,
       wordPosition = wordPosition;

  final StudyTargetType type;
  final int surahNumber;
  final int ayahNumber;
  final int? wordPosition;

  String get key => switch (type) {
    StudyTargetType.ayah => 'ayah:$surahNumber:$ayahNumber',
    StudyTargetType.word => 'word:$surahNumber:$ayahNumber:$wordPosition',
  };

  @override
  bool operator ==(Object other) {
    return other is StudyTarget &&
        other.type == type &&
        other.surahNumber == surahNumber &&
        other.ayahNumber == ayahNumber &&
        other.wordPosition == wordPosition;
  }

  @override
  int get hashCode => Object.hash(type, surahNumber, ayahNumber, wordPosition);
}

class Bookmark {
  const Bookmark({
    required this.target,
    required this.category,
    this.createdAt,
  });

  final StudyTarget target;
  final String category;
  final DateTime? createdAt;
}
