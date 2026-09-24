const int reciterAudioCatalogSchemaVersion = 1;
const String reciterAudioCatalogSourceName = 'Quran Foundation Content API v4';

Map<String, dynamic> buildReciterIndex({
  required String sourceVersion,
  required DateTime generatedAtUtc,
  required List<Map<String, dynamic>> reciters,
}) {
  final normalizedSourceVersion = sourceVersion.trim();
  if (normalizedSourceVersion.isEmpty) {
    throw const FormatException('Reciter catalog source version is required.');
  }
  if (reciters.isEmpty) {
    throw const FormatException('Reciter catalog must not be empty.');
  }

  final normalized = <Map<String, dynamic>>[];
  final seenIds = <int>{};

  for (final raw in reciters) {
    final id = _requiredInt(raw, 'id');
    if (id <= 0) {
      throw FormatException('Reciter id must be positive, got $id.');
    }
    if (!seenIds.add(id)) {
      throw FormatException('Duplicate reciter id $id.');
    }

    normalized.add({
      'id': id,
      'name': _requiredString(raw, 'name'),
      'style': _requiredNamedMetadata(raw['style'], 'style'),
      'qirat': _requiredNamedMetadata(raw['qirat'], 'qirat'),
    });
  }

  normalized.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

  return {
    'schema_version': reciterAudioCatalogSchemaVersion,
    'source_name': reciterAudioCatalogSourceName,
    'source_version': normalizedSourceVersion,
    'generated_at_utc': generatedAtUtc.toUtc().toIso8601String(),
    'reciters': normalized,
  };
}

Map<String, dynamic> buildChapterAudioDocument({
  required int reciterId,
  required int surahNumber,
  required Map<String, dynamic> raw,
}) {
  if (reciterId <= 0) {
    throw FormatException('Reciter id must be positive, got $reciterId.');
  }
  if (surahNumber < 1 || surahNumber > 114) {
    throw FormatException('Surah number must be between 1 and 114.');
  }

  final audioFile = _requiredMap(raw, 'audio_file');
  final chapterId = _requiredInt(audioFile, 'chapter_id');
  if (chapterId != surahNumber) {
    throw FormatException(
      'Chapter audio metadata belongs to Surah $chapterId, expected '
      '$surahNumber.',
    );
  }

  final audioUrl = _requiredString(audioFile, 'audio_url');
  final uri = Uri.tryParse(audioUrl);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.host == 'example.invalid') {
    throw FormatException('Audio URL must be a public absolute HTTPS URL.');
  }

  final audioFileId = _requiredInt(audioFile, 'id');
  if (audioFileId <= 0) {
    throw const FormatException('Audio file id must be positive.');
  }
  final fileSize = _requiredInt(audioFile, 'file_size');
  if (fileSize <= 0) {
    throw const FormatException('Audio file size must be positive.');
  }

  final rawTimestamps = _requiredList(audioFile, 'timestamps');
  final timestamps = <Map<String, dynamic>>[];
  final seenVerseKeys = <String>{};
  var previousTimestampFrom = -1;

  for (final item in rawTimestamps) {
    if (item is! Map) {
      throw const FormatException('Every timestamp entry must be an object.');
    }
    final timestamp = Map<String, dynamic>.from(item);
    final verseKey = _requiredString(timestamp, 'verse_key');
    _validateVerseKey(verseKey, surahNumber);
    if (!seenVerseKeys.add(verseKey)) {
      throw FormatException('Duplicate verse_key "$verseKey".');
    }

    final timestampFrom = _requiredInt(timestamp, 'timestamp_from');
    final timestampTo = _requiredInt(timestamp, 'timestamp_to');
    if (timestampFrom < 0 || timestampTo < 0 || timestampTo < timestampFrom) {
      throw FormatException(
        'Invalid timestamp bounds for $verseKey: '
        '$timestampFrom..$timestampTo.',
      );
    }
    if (timestampFrom < previousTimestampFrom) {
      throw FormatException(
        'Timestamp starts are not monotonic at $verseKey: '
        '$timestampFrom starts before $previousTimestampFrom.',
      );
    }
    previousTimestampFrom = timestampFrom;

    final rawDuration = _requiredInt(timestamp, 'duration');
    final duration = rawDuration < 0
        ? -rawDuration
        : (rawDuration == 0 ? timestampTo - timestampFrom : rawDuration);

    final segments = _normalizeSegments(
      timestamp['segments'],
      verseKey: verseKey,
    );

    timestamps.add({
      'verse_key': verseKey,
      'timestamp_from': timestampFrom,
      'timestamp_to': timestampTo,
      'duration': duration,
      'segments': segments,
    });
  }

  return {
    'schema_version': reciterAudioCatalogSchemaVersion,
    'reciter_id': reciterId,
    'surah_number': surahNumber,
    'audio_file_id': audioFileId,
    'audio_url': audioUrl,
    'format': _requiredString(audioFile, 'format'),
    'file_size': fileSize,
    'timestamps': timestamps,
  };
}

void validateGeneratedAudioCatalog({
  required Map<String, dynamic> reciterIndex,
  required Map<int, Map<int, Map<String, dynamic>>> chaptersByReciter,
}) {
  if (_requiredInt(reciterIndex, 'schema_version') !=
      reciterAudioCatalogSchemaVersion) {
    throw StateError(
      'Unsupported reciter catalog schema version '
      '${reciterIndex['schema_version']}.',
    );
  }

  final rawReciters = _requiredList(reciterIndex, 'reciters');
  final expectedReciterIds = <int>{};
  for (final row in rawReciters) {
    if (row is! Map) {
      throw const FormatException('Every reciter entry must be an object.');
    }
    final id = _requiredInt(Map<String, dynamic>.from(row), 'id');
    if (!expectedReciterIds.add(id)) {
      throw FormatException('Duplicate reciter id $id in generated index.');
    }
  }

  final providedReciterIds = chaptersByReciter.keys.toSet();
  if (!_sameIntSet(expectedReciterIds, providedReciterIds)) {
    final missing = expectedReciterIds.difference(providedReciterIds).toList()
      ..sort();
    final extra = providedReciterIds.difference(expectedReciterIds).toList()
      ..sort();
    throw StateError(
      'Generated chapter metadata reciter coverage does not match the index. '
      'Missing: $missing; extra: $extra.',
    );
  }

  final expectedSurahs = <int>{
    for (var surah = 1; surah <= 114; surah++) surah,
  };

  for (final reciterId in expectedReciterIds) {
    final chapters = chaptersByReciter[reciterId] ?? const {};
    final chapterNumbers = chapters.keys.toSet();
    if (!_sameIntSet(expectedSurahs, chapterNumbers)) {
      final missing = expectedSurahs.difference(chapterNumbers).toList()
        ..sort();
      final extra = chapterNumbers.difference(expectedSurahs).toList()..sort();
      throw StateError(
        'Reciter $reciterId must have exactly 114 Surah documents. '
        'Missing: $missing; extra: $extra.',
      );
    }

    for (var surahNumber = 1; surahNumber <= 114; surahNumber++) {
      final document = chapters[surahNumber]!;
      final documentSchema = _requiredInt(document, 'schema_version');
      final documentReciter = _requiredInt(document, 'reciter_id');
      final documentSurah = _requiredInt(document, 'surah_number');
      final audioUrl = _requiredString(document, 'audio_url');
      final uri = Uri.tryParse(audioUrl);

      if (documentSchema != reciterAudioCatalogSchemaVersion) {
        throw StateError(
          'Reciter $reciterId Surah $surahNumber uses unsupported schema '
          '$documentSchema.',
        );
      }
      if (documentReciter != reciterId || documentSurah != surahNumber) {
        throw StateError(
          'Chapter document identity mismatch: expected '
          '$reciterId/$surahNumber but got $documentReciter/$documentSurah.',
        );
      }
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
        throw StateError(
          'Reciter $reciterId Surah $surahNumber has a non-HTTPS audio URL.',
        );
      }
    }
  }
}

Map<String, dynamic> _requiredNamedMetadata(dynamic value, String label) {
  if (value is! Map) {
    throw FormatException('Expected "$label" to be an object.');
  }
  final map = Map<String, dynamic>.from(value);
  return {
    'name': _nullableMetadataString(map['name'], '$label.name'),
    'language_name': _nullableMetadataString(
      map['language_name'],
      '$label.language_name',
    ),
  };
}

String? _nullableMetadataString(Object? value, String label) {
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Expected "$label" to be a string or null.');
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<List<int>> _normalizeSegments(dynamic raw, {required String verseKey}) {
  // Word-level segments are optional Quran Foundation alignment metadata.
  // Production payloads can contain incomplete, malformed, reversed, or
  // inconsistently ordered entries even when the parent ayah timestamps are
  // usable. Never guess, reorder, or partially reinterpret a corrupt verse.
  // Instead, omit word timing for that verse and preserve its authoritative
  // ayah-level timestamp row. The generated runtime catalog therefore contains
  // either a fully validated segment list or an empty list.
  if (raw == null) return const [];
  if (raw is! List) return const [];

  final normalized = <List<int>>[];
  var previousSegmentFrom = -1;
  var previousPosition = 0;

  for (final segment in raw) {
    if (segment is! List || segment.length < 3) {
      return const [];
    }

    late final int position;
    late final int from;
    late final int to;
    try {
      position = _requiredIntValue(segment[0], 'segment position');
      from = _requiredIntValue(segment[1], 'segment start');
      to = _requiredIntValue(segment[2], 'segment end');
    } on FormatException {
      return const [];
    }

    if (position <= 0 || from < 0 || to < from) {
      return const [];
    }
    if (normalized.isNotEmpty &&
        (position <= previousPosition || from < previousSegmentFrom)) {
      return const [];
    }

    previousPosition = position;
    previousSegmentFrom = from;
    normalized.add([position, from, to]);
  }

  return normalized;
}

void _validateVerseKey(String verseKey, int expectedSurah) {
  final parts = verseKey.split(':');
  if (parts.length != 2) {
    throw FormatException('Invalid verse_key "$verseKey".');
  }
  final surah = int.tryParse(parts[0]);
  final ayah = int.tryParse(parts[1]);
  if (surah != expectedSurah || ayah == null || ayah <= 0) {
    throw FormatException(
      'verse_key "$verseKey" does not belong to Surah $expectedSurah.',
    );
  }
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! Map) {
    throw FormatException('Expected "$key" to be an object.');
  }
  return Map<String, dynamic>.from(value);
}

List<dynamic> _requiredList(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! List) {
    throw FormatException('Expected "$key" to be an array.');
  }
  return value;
}

int _requiredInt(Map<String, dynamic> map, String key) =>
    _requiredIntValue(map[key], '"$key"');

int _requiredIntValue(dynamic value, String label) {
  if (value is int) return value;
  if (value is num && value == value.roundToDouble()) return value.toInt();
  throw FormatException('Expected integer $label.');
}

String _requiredString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty string "$key".');
  }
  return value;
}

bool _sameIntSet(Set<int> a, Set<int> b) =>
    a.length == b.length && a.containsAll(b);
