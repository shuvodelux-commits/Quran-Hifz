import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/chapter_audio_source.dart';

class BundledChapterAudioSource implements ChapterAudioSource {
  BundledChapterAudioSource({
    required AssetBundle bundle,
    this.assetDirectory = defaultAssetDirectory,
  }) : _bundle = bundle;

  static const defaultAssetDirectory = 'assets/audio/chapters_v1';
  static const _supportedSchemaVersion = 1;

  final AssetBundle _bundle;
  final String assetDirectory;

  @override
  Future<Map<String, dynamic>> loadChapterAudio({
    required int reciterId,
    required int surahNumber,
  }) async {
    if (reciterId <= 0) {
      throw ArgumentError.value(reciterId, 'reciterId', 'must be positive');
    }
    if (surahNumber < 1 || surahNumber > 114) {
      throw RangeError.range(surahNumber, 1, 114, 'surahNumber');
    }

    final assetPath = '$assetDirectory/$reciterId-$surahNumber.json';
    final raw = await _bundle.loadString(assetPath, cache: false);
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw FormatException(
        'Bundled chapter audio metadata is not valid JSON for '
        '$reciterId/$surahNumber: ${error.message}',
      );
    }
    if (decoded is! Map) {
      throw FormatException(
        'Bundled chapter audio metadata root must be an object for '
        '$reciterId/$surahNumber.',
      );
    }

    final document = Map<String, dynamic>.from(decoded);
    if (document['schema_version'] != _supportedSchemaVersion) {
      throw FormatException(
        'Unsupported chapter audio schema version for '
        '$reciterId/$surahNumber: ${document['schema_version']}.',
      );
    }
    if (document['reciter_id'] != reciterId) {
      throw FormatException(
        'Bundled chapter audio reciter mismatch: expected $reciterId, '
        'found ${document['reciter_id']}.',
      );
    }
    if (document['surah_number'] != surahNumber) {
      throw FormatException(
        'Bundled chapter audio Surah mismatch: expected $surahNumber, '
        'found ${document['surah_number']}.',
      );
    }

    final audioFileId = _requirePositiveInt(document, 'audio_file_id');
    final audioUrl = _requireHttpsUrl(document, 'audio_url');
    final format = _requireNonEmptyString(document, 'format');
    final fileSize = _requirePositiveInt(document, 'file_size');
    final timestamps = _validateTimestamps(document['timestamps'], surahNumber);

    return {
      'audio_file': {
        'id': audioFileId,
        'chapter_id': surahNumber,
        'file_size': fileSize,
        'format': format,
        'audio_url': audioUrl,
        'timestamps': timestamps,
      },
    };
  }

  static List<Map<String, dynamic>> _validateTimestamps(
    Object? value,
    int surahNumber,
  ) {
    if (value is! List) {
      throw const FormatException(
        'Bundled chapter timestamps must be an array.',
      );
    }
    final rows = <Map<String, dynamic>>[];
    final verseKeys = <String>{};
    var previousStart = -1;

    for (final raw in value) {
      if (raw is! Map) {
        throw const FormatException(
          'Every bundled timestamp must be an object.',
        );
      }
      final row = Map<String, dynamic>.from(raw);
      final verseKey = _requireNonEmptyString(row, 'verse_key');
      final parts = verseKey.split(':');
      if (parts.length != 2 ||
          int.tryParse(parts[0]) != surahNumber ||
          (int.tryParse(parts[1]) ?? 0) <= 0) {
        throw FormatException(
          'Bundled timestamp verse_key "$verseKey" does not belong to '
          'Surah $surahNumber.',
        );
      }
      if (!verseKeys.add(verseKey)) {
        throw FormatException(
          'Duplicate bundled timestamp verse_key: $verseKey.',
        );
      }

      final from = _requireNonNegativeInt(row, 'timestamp_from');
      final to = _requireNonNegativeInt(row, 'timestamp_to');
      if (to < from || from < previousStart) {
        throw FormatException('Invalid timestamp bounds for $verseKey.');
      }
      previousStart = from;
      final duration = _requireNonNegativeInt(row, 'duration');
      final segments = _validateSegments(row['segments'], verseKey: verseKey);

      rows.add({
        'verse_key': verseKey,
        'timestamp_from': from,
        'timestamp_to': to,
        'duration': duration,
        'segments': segments,
      });
    }

    return rows;
  }

  static List<List<int>> _validateSegments(
    Object? value, {
    required String verseKey,
  }) {
    if (value is! List) {
      throw FormatException('Segments for $verseKey must be an array.');
    }
    final result = <List<int>>[];
    var previousStart = -1;
    var previousPosition = 0;
    for (final raw in value) {
      if (raw is! List || raw.length < 3) {
        throw FormatException('Invalid segment for $verseKey.');
      }
      final position = raw[0];
      final from = raw[1];
      final to = raw[2];
      if (position is! int ||
          position <= 0 ||
          from is! int ||
          from < 0 ||
          to is! int ||
          to < from ||
          (result.isNotEmpty &&
              (position <= previousPosition || from < previousStart))) {
        throw FormatException('Invalid segment for $verseKey: $raw.');
      }
      previousPosition = position;
      previousStart = from;
      result.add([position, from, to]);
    }
    return result;
  }

  static int _requirePositiveInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! int || value <= 0) {
      throw FormatException('Bundled chapter field "$key" must be positive.');
    }
    return value;
  }

  static int _requireNonNegativeInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! int || value < 0) {
      throw FormatException(
        'Bundled chapter field "$key" must be non-negative.',
      );
    }
    return value;
  }

  static String _requireNonEmptyString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Bundled chapter field "$key" is invalid.');
    }
    return value;
  }

  static String _requireHttpsUrl(Map<String, dynamic> map, String key) {
    final value = _requireNonEmptyString(map, key);
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.host == 'example.invalid') {
      throw FormatException(
        'Bundled chapter field "$key" must be a public HTTPS URL.',
      );
    }
    return value;
  }
}
