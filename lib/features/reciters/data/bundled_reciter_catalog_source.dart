import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/reciter_catalog_source.dart';

class BundledReciterCatalogSource implements ReciterCatalogSource {
  BundledReciterCatalogSource({
    required AssetBundle bundle,
    this.assetPath = defaultAssetPath,
  }) : _bundle = bundle;

  static const defaultAssetPath = 'assets/audio/reciters_v1.json';
  static const _supportedSchemaVersion = 1;

  final AssetBundle _bundle;
  final String assetPath;

  @override
  Future<List<Map<String, dynamic>>> fetchChapterReciters() async {
    final raw = await _bundle.loadString(assetPath, cache: false);
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw FormatException(
        'Bundled reciter catalog is not valid JSON: ${error.message}',
      );
    }
    if (decoded is! Map) {
      throw const FormatException(
        'Bundled reciter catalog root must be an object.',
      );
    }

    final document = Map<String, dynamic>.from(decoded);
    final schemaVersion = document['schema_version'];
    if (schemaVersion != _supportedSchemaVersion) {
      throw FormatException(
        'Unsupported bundled reciter catalog schema version: $schemaVersion.',
      );
    }
    _requireNonEmptyString(document, 'source_name');
    _requireNonEmptyString(document, 'source_version');
    _requireNonEmptyString(document, 'generated_at_utc');

    final rawRows = document['reciters'];
    if (rawRows is! List || rawRows.isEmpty) {
      throw const FormatException('Bundled reciter catalog must not be empty.');
    }

    final ids = <int>{};
    final rows = <Map<String, dynamic>>[];
    for (final rawRow in rawRows) {
      if (rawRow is! Map) {
        throw const FormatException('Every bundled reciter must be an object.');
      }
      final row = Map<String, dynamic>.from(rawRow);
      final id = row['id'];
      if (id is! int || id <= 0) {
        throw const FormatException('Bundled reciter id must be positive.');
      }
      if (!ids.add(id)) {
        throw FormatException('Duplicate bundled reciter id: $id.');
      }
      _requireNonEmptyString(row, 'name');
      _validateNamedMetadata(row['style'], 'style');
      _validateNamedMetadata(row['qirat'], 'qirat');
      rows.add(row);
    }

    rows.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    return rows;
  }

  static String _requireNonEmptyString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Bundled reciter catalog field "$key" is invalid.');
    }
    return value;
  }

  static void _validateNamedMetadata(Object? value, String label) {
    if (value is! Map) {
      throw FormatException('Bundled reciter $label metadata is invalid.');
    }
    final map = Map<String, dynamic>.from(value);
    _validateNullableMetadataString(map['name'], '$label name');
    _validateNullableMetadataString(
      map['language_name'],
      '$label language metadata',
    );
  }

  static void _validateNullableMetadataString(Object? value, String label) {
    if (value == null) return;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Bundled reciter $label is invalid.');
    }
  }
}
