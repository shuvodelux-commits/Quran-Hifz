const customDuaIdPrefix = 'custom:';

bool isCustomDuaId(String id) {
  final value = id.trim();
  return value.startsWith(customDuaIdPrefix) &&
      value.length > customDuaIdPrefix.length;
}

class CustomDua {
  const CustomDua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.reference,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String reference;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomDua copyWith({
    String? title,
    String? arabic,
    String? transliteration,
    String? meaning,
    String? reference,
    DateTime? updatedAt,
  }) => CustomDua(
    id: id,
    title: title ?? this.title,
    arabic: arabic ?? this.arabic,
    transliteration: transliteration ?? this.transliteration,
    meaning: meaning ?? this.meaning,
    reference: reference ?? this.reference,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is CustomDua &&
      other.id == id &&
      other.title == title &&
      other.arabic == arabic &&
      other.transliteration == transliteration &&
      other.meaning == meaning &&
      other.reference == reference &&
      other.createdAt.isAtSameMomentAs(createdAt) &&
      other.updatedAt.isAtSameMomentAs(updatedAt);

  @override
  int get hashCode => Object.hash(
    id,
    title,
    arabic,
    transliteration,
    meaning,
    reference,
    createdAt.microsecondsSinceEpoch,
    updatedAt.microsecondsSinceEpoch,
  );
}
