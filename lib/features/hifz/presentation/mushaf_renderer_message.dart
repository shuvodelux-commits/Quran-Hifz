import 'dart:convert';

sealed class MushafRendererEvent {
  const MushafRendererEvent();

  static MushafRendererEvent parse(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Mushaf renderer event must be a JSON object.',
      );
    }

    final type = decoded['type'];
    if (type is! String || type.isEmpty) {
      throw const FormatException('Mushaf renderer event type is required.');
    }

    return switch (type) {
      'pageReady' => MushafPageReadyEvent(
        page: _page(decoded['page']),
        generation: _generation(decoded['generation']),
      ),
      'wordTap' => MushafWordTapEvent(
        _ayahKey(decoded['ayahKey']),
        _wordPosition(decoded['wordPosition']),
      ),
      'wordLongPress' => MushafWordLongPressEvent(
        _ayahKey(decoded['ayahKey']),
        _wordPosition(decoded['wordPosition']),
      ),
      'ayahTap' => MushafAyahTapEvent(_ayahKey(decoded['ayahKey'])),
      'rendererError' => MushafRendererErrorEvent(
        code: _boundedString(decoded['code'], name: 'code', maxLength: 64),
        message: _boundedString(
          decoded['message'],
          name: 'message',
          maxLength: 512,
        ),
      ),
      _ => throw FormatException('Unknown Mushaf renderer event: $type.'),
    };
  }

  static int _page(Object? value) {
    final page = _int(value, 'page');
    if (page < 1 || page > 604) {
      throw const FormatException('Mushaf page must be in 1..604.');
    }
    return page;
  }

  static int _generation(Object? value) {
    final generation = _int(value, 'generation');
    if (generation < 0) {
      throw const FormatException('Mushaf generation must be non-negative.');
    }
    return generation;
  }

  static int _wordPosition(Object? value) {
    final position = _int(value, 'wordPosition');
    if (position <= 0) {
      throw const FormatException('Mushaf wordPosition must be positive.');
    }
    return position;
  }

  static String _ayahKey(Object? value) {
    if (value is! String ||
        !RegExp(r'^[1-9][0-9]{0,2}:[1-9][0-9]{0,2}$').hasMatch(value)) {
      throw const FormatException('Invalid Mushaf ayahKey.');
    }
    return value;
  }

  static String _boundedString(
    Object? value, {
    required String name,
    required int maxLength,
  }) {
    if (value is! String || value.isEmpty || value.length > maxLength) {
      throw FormatException(
        'Mushaf renderer $name must contain 1..$maxLength characters.',
      );
    }
    return value;
  }

  static int _int(Object? value, String name) {
    if (value is int) return value;
    throw FormatException('Mushaf renderer $name must be an integer.');
  }
}

final class MushafPageReadyEvent extends MushafRendererEvent {
  const MushafPageReadyEvent({required this.page, required this.generation});

  final int page;
  final int generation;

  @override
  bool operator ==(Object other) =>
      other is MushafPageReadyEvent &&
      page == other.page &&
      generation == other.generation;

  @override
  int get hashCode => Object.hash(page, generation);
}

final class MushafWordTapEvent extends MushafRendererEvent {
  const MushafWordTapEvent(this.ayahKey, this.wordPosition);

  final String ayahKey;
  final int wordPosition;

  @override
  bool operator ==(Object other) =>
      other is MushafWordTapEvent &&
      ayahKey == other.ayahKey &&
      wordPosition == other.wordPosition;

  @override
  int get hashCode => Object.hash(ayahKey, wordPosition);
}

final class MushafWordLongPressEvent extends MushafRendererEvent {
  const MushafWordLongPressEvent(this.ayahKey, this.wordPosition);

  final String ayahKey;
  final int wordPosition;

  @override
  bool operator ==(Object other) =>
      other is MushafWordLongPressEvent &&
      ayahKey == other.ayahKey &&
      wordPosition == other.wordPosition;

  @override
  int get hashCode => Object.hash(ayahKey, wordPosition);
}

final class MushafAyahTapEvent extends MushafRendererEvent {
  const MushafAyahTapEvent(this.ayahKey);

  final String ayahKey;

  @override
  bool operator ==(Object other) =>
      other is MushafAyahTapEvent && ayahKey == other.ayahKey;

  @override
  int get hashCode => ayahKey.hashCode;
}

final class MushafRendererErrorEvent extends MushafRendererEvent {
  const MushafRendererErrorEvent({required this.code, required this.message});

  final String code;
  final String message;

  @override
  bool operator ==(Object other) =>
      other is MushafRendererErrorEvent &&
      code == other.code &&
      message == other.message;

  @override
  int get hashCode => Object.hash(code, message);
}
