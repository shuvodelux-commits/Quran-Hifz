import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/dua.dart';
import '../domain/dua_repository.dart';

class BundledDuaRepository implements DuaRepository {
  BundledDuaRepository({
    required AssetBundle bundle,
    this.assetPath = defaultAssetPath,
  }) : _bundle = bundle;

  static const defaultAssetPath = 'assets/dua/duas_v1.json';
  static const _supportedSchemaVersion = 1;

  final AssetBundle _bundle;
  final String assetPath;

  Future<_DuaCatalog>? _catalogFuture;

  @override
  Future<List<Dua>> loadAll() async => (await _loadCatalog()).duas;

  @override
  Future<List<DuaCategory>> loadCategories() async =>
      (await _loadCatalog()).categories;

  Future<_DuaCatalog> _loadCatalog() {
    final cached = _catalogFuture;
    if (cached != null) return cached;

    late final Future<_DuaCatalog> future;
    future = _parseCatalog().then(
      (catalog) => catalog,
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_catalogFuture, future)) _catalogFuture = null;
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
    _catalogFuture = future;
    return future;
  }

  Future<_DuaCatalog> _parseCatalog() async {
    final raw = await _bundle.loadString(assetPath, cache: false);
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw FormatException(
        'Bundled Dua catalog is not valid JSON: ${error.message}',
      );
    }

    if (decoded is! Map) {
      throw const FormatException(
        'Bundled Dua catalog root must be an object.',
      );
    }
    final document = Map<String, dynamic>.from(decoded);
    if (document['schema_version'] != _supportedSchemaVersion) {
      throw FormatException(
        'Unsupported bundled Dua schema version: ${document['schema_version']}.',
      );
    }

    final rawCategories = document['categories'];
    if (rawCategories is! List || rawCategories.isEmpty) {
      throw const FormatException('Bundled Dua categories must not be empty.');
    }
    final categoryIds = <String>{};
    final categories = <DuaCategory>[];
    for (final rawCategory in rawCategories) {
      if (rawCategory is! Map) {
        throw const FormatException('Every Dua category must be an object.');
      }
      final category = Map<String, dynamic>.from(rawCategory);
      final id = _requiredString(category, 'id');
      if (!categoryIds.add(id)) {
        throw FormatException('Duplicate Dua category id: $id.');
      }
      categories.add(
        DuaCategory(
          id: id,
          banglaLabel: _requiredString(category, 'bn'),
          englishLabel: _requiredString(category, 'en'),
        ),
      );
    }

    final rawDuas = document['duas'];
    if (rawDuas is! List || rawDuas.isEmpty) {
      throw const FormatException('Bundled Dua catalog must not be empty.');
    }

    final duaIds = <String>{};
    final duas = <Dua>[];
    for (final rawDua in rawDuas) {
      if (rawDua is! Map) {
        throw const FormatException('Every bundled Dua must be an object.');
      }
      final row = Map<String, dynamic>.from(rawDua);
      final id = _requiredString(row, 'id');
      if (!duaIds.add(id)) {
        throw FormatException('Duplicate bundled Dua id: $id.');
      }

      final referencedCategories = _requiredStringList(row, 'category_ids');
      if (referencedCategories.isEmpty) {
        throw FormatException(
          'Dua "$id" must reference at least one category.',
        );
      }
      for (final categoryId in referencedCategories) {
        if (!categoryIds.contains(categoryId)) {
          throw FormatException(
            'Dua "$id" references unknown category "$categoryId".',
          );
        }
      }

      final rawSources = row['sources'];
      if (rawSources is! List || rawSources.isEmpty) {
        throw FormatException('Dua "$id" must have at least one source.');
      }
      final sources = <DuaSource>[
        for (final rawSource in rawSources) _parseSource(id, rawSource),
      ];

      final dailyOrder = row['daily_order'];
      if (dailyOrder != null && (dailyOrder is! int || dailyOrder <= 0)) {
        throw FormatException('Dua "$id" has invalid daily_order.');
      }

      duas.add(
        Dua(
          id: id,
          titleBangla: _requiredString(row, 'title_bn'),
          titleEnglish: _requiredString(row, 'title_en'),
          arabic: _requiredString(row, 'arabic'),
          banglaPronunciation: _requiredString(row, 'pronunciation_bn'),
          banglaMeaning: _requiredString(row, 'meaning_bn'),
          englishTransliteration: _requiredString(row, 'transliteration_en'),
          englishMeaning: _requiredString(row, 'meaning_en'),
          categoryIds: List.unmodifiable(referencedCategories),
          tagsBangla: List.unmodifiable(_requiredStringList(row, 'tags_bn')),
          tagsEnglish: List.unmodifiable(_requiredStringList(row, 'tags_en')),
          sources: List.unmodifiable(sources),
          dailyOrder: dailyOrder as int?,
          noteBangla: _optionalString(row, 'note_bn'),
          noteEnglish: _optionalString(row, 'note_en'),
        ),
      );
    }

    return _DuaCatalog(
      categories: List.unmodifiable(categories),
      duas: List.unmodifiable(duas),
    );
  }

  static DuaSource _parseSource(String duaId, Object? rawSource) {
    if (rawSource is! Map) {
      throw FormatException('Dua "$duaId" has an invalid source object.');
    }
    final source = Map<String, dynamic>.from(rawSource);
    final type = _requiredString(source, 'type');

    return switch (type) {
      'quran' => _parseQuranSource(duaId, source),
      'hadith' => _parseHadithSource(duaId, source),
      _ => throw FormatException(
        'Dua "$duaId" has unsupported source type "$type".',
      ),
    };
  }

  static DuaSource _parseQuranSource(
    String duaId,
    Map<String, dynamic> source,
  ) {
    final surahNumber = source['surah_number'];
    final ayahStart = source['ayah_start'];
    final ayahEnd = source['ayah_end'];
    if (surahNumber is! int || surahNumber < 1 || surahNumber > 114) {
      throw FormatException('Dua "$duaId" has invalid Quran surah_number.');
    }
    if (ayahStart is! int || ayahStart <= 0) {
      throw FormatException('Dua "$duaId" has invalid Quran ayah_start.');
    }
    if (ayahEnd != null && (ayahEnd is! int || ayahEnd < ayahStart)) {
      throw FormatException('Dua "$duaId" has invalid Quran ayah_end.');
    }
    return DuaSource(
      type: DuaSourceType.quran,
      surahNumber: surahNumber,
      ayahStart: ayahStart,
      ayahEnd: ayahEnd as int?,
    );
  }

  static DuaSource _parseHadithSource(
    String duaId,
    Map<String, dynamic> source,
  ) {
    final gradeRaw = _requiredString(source, 'grade');
    final grade = switch (gradeRaw) {
      'sahih' => HadithGrade.sahih,
      'hasan' => HadithGrade.hasan,
      _ => throw FormatException(
        'Dua "$duaId" has unsupported Hadith grade "$gradeRaw".',
      ),
    };
    return DuaSource(
      type: DuaSourceType.hadith,
      collection: _requiredString(source, 'collection'),
      reference: _requiredString(source, 'reference'),
      grade: grade,
      gradingAuthority: _optionalString(source, 'grading_authority'),
    );
  }

  static String _requiredString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Bundled Dua field "$key" is invalid.');
    }
    return value.trim();
  }

  static String? _optionalString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Bundled Dua field "$key" is invalid.');
    }
    return value.trim();
  }

  static List<String> _requiredStringList(
    Map<String, dynamic> map,
    String key,
  ) {
    final value = map[key];
    if (value is! List) {
      throw FormatException('Bundled Dua field "$key" must be a list.');
    }
    final result = <String>[];
    for (final item in value) {
      if (item is! String || item.trim().isEmpty) {
        throw FormatException(
          'Bundled Dua field "$key" contains an invalid value.',
        );
      }
      result.add(item.trim());
    }
    return result;
  }
}

class _DuaCatalog {
  const _DuaCatalog({required this.categories, required this.duas});

  final List<DuaCategory> categories;
  final List<Dua> duas;
}
