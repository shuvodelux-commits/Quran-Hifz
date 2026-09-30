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
      'pageMetrics' => MushafPageMetricsEvent(
        page: _page(decoded['page']),
        generation: _generation(decoded['generation']),
        contentHeight: _positiveFiniteDouble(
          decoded['contentHeight'],
          'contentHeight',
        ),
      ),
      'playbackTarget' => _playbackTarget(decoded),
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

  static MushafPlaybackTargetEvent _playbackTarget(
    Map<String, dynamic> decoded,
  ) {
    final top = _finiteDouble(decoded['top'], 'top');
    final bottom = _finiteDouble(decoded['bottom'], 'bottom');
    if (bottom < top) {
      throw const FormatException(
        'Mushaf playback target bottom must be >= top.',
      );
    }
    final rawWordPosition = decoded['wordPosition'];
    return MushafPlaybackTargetEvent(
      page: _page(decoded['page']),
      generation: _generation(decoded['generation']),
      ayahKey: _ayahKey(decoded['ayahKey']),
      wordPosition: rawWordPosition == null
          ? null
          : _wordPosition(rawWordPosition),
      top: top,
      bottom: bottom,
    );
  }

  static double _positiveFiniteDouble(Object? value, String name) {
    final number = _finiteDouble(value, name);
    if (number <= 0) {
      throw FormatException('Mushaf renderer $name must be positive.');
    }
    return number;
  }

  static double _finiteDouble(Object? value, String name) {
    if (value is! num) {
      throw FormatException('Mushaf renderer $name must be numeric.');
    }
    final number = value.toDouble();
    if (!number.isFinite) {
      throw FormatException('Mushaf renderer $name must be finite.');
    }
    return number;
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

final class MushafPageMetricsEvent extends MushafRendererEvent {
  const MushafPageMetricsEvent({
    required this.page,
    required this.generation,
    required this.contentHeight,
  });

  final int page;
  final int generation;
  final double contentHeight;

  @override
  bool operator ==(Object other) =>
      other is MushafPageMetricsEvent &&
      page == other.page &&
      generation == other.generation &&
      contentHeight == other.contentHeight;

  @override
  int get hashCode => Object.hash(page, generation, contentHeight);
}

final class MushafPlaybackTargetEvent extends MushafRendererEvent {
  const MushafPlaybackTargetEvent({
    required this.page,
    required this.generation,
    required this.ayahKey,
    this.wordPosition,
    required this.top,
    required this.bottom,
  });

  final int page;
  final int generation;
  final String ayahKey;
  final int? wordPosition;
  final double top;
  final double bottom;

  @override
  bool operator ==(Object other) =>
      other is MushafPlaybackTargetEvent &&
      page == other.page &&
      generation == other.generation &&
      ayahKey == other.ayahKey &&
      wordPosition == other.wordPosition &&
      top == other.top &&
      bottom == other.bottom;

  @override
  int get hashCode =>
      Object.hash(page, generation, ayahKey, wordPosition, top, bottom);
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
