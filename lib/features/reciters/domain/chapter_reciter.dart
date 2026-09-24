class ChapterReciter {
  const ChapterReciter({
    required this.id,
    required this.name,
    required this.styleName,
    required this.styleLanguageName,
    required this.qiratName,
    required this.qiratLanguageName,
  });

  final int id;
  final String name;
  final String? styleName;
  final String? styleLanguageName;
  final String? qiratName;
  final String? qiratLanguageName;

  factory ChapterReciter.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final style = json['style'];
    final qirat = json['qirat'];

    if (id is! int || id <= 0) {
      throw const FormatException('Invalid chapter-reciter id.');
    }
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid chapter-reciter name.');
    }
    if (style is! Map || qirat is! Map) {
      throw const FormatException('Invalid chapter-reciter metadata.');
    }

    final styleMap = Map<String, dynamic>.from(style);
    final qiratMap = Map<String, dynamic>.from(qirat);
    final styleLanguageName = _nullableMetadataLanguage(
      styleMap['language_name'],
    );
    final qiratLanguageName = _nullableMetadataLanguage(
      qiratMap['language_name'],
    );

    return ChapterReciter(
      id: id,
      name: name.trim(),
      styleName: _nullableName(styleMap['name']),
      styleLanguageName: styleLanguageName,
      qiratName: _nullableName(qiratMap['name']),
      qiratLanguageName: qiratLanguageName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'style': {'name': styleName, 'language_name': styleLanguageName},
    'qirat': {'name': qiratName, 'language_name': qiratLanguageName},
  };

  static String? _nullableMetadataLanguage(Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw const FormatException('Invalid reciter metadata language.');
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _nullableName(Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw const FormatException('Invalid reciter metadata name.');
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
