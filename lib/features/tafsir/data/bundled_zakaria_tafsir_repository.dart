import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

import '../domain/tafsir_catalog.dart';
import '../domain/tafsir_entry.dart';
import '../domain/tafsir_repository.dart';
import 'tafsir_text_normalizer.dart';

class BundledTafsirIntegrityException implements Exception {
  const BundledTafsirIntegrityException(this.message);

  final String message;

  @override
  String toString() => 'BundledTafsirIntegrityException: $message';
}

class BundledZakariaTafsirRepository implements TafsirRepository {
  BundledZakariaTafsirRepository(
    this._bundle, {
    this.manifestAssetPath = 'assets/tafsir/zakaria/1.1.1/manifest.json',
  });

  final AssetBundle _bundle;
  final String manifestAssetPath;

  _BundledManifest? _manifest;
  int? _cachedSurahNumber;
  List<TafsirEntry>? _cachedEntries;

  String get _assetRoot {
    final slash = manifestAssetPath.lastIndexOf('/');
    return slash < 0 ? '' : manifestAssetPath.substring(0, slash);
  }

  @override
  Future<List<TafsirSource>> listInstalledSources() async {
    final manifest = await _loadManifest();
    return [
      TafsirSource(
        sourceId: manifest.sourceId,
        name: manifest.name,
        language: manifest.language,
        version: manifest.version,
        attribution: manifest.attribution,
        license: manifest.license,
        kind: TafsirSourceKind.bundled,
        availableOffline: true,
      ),
    ];
  }

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (sourceId != primaryBanglaTafsirSourceId ||
        surahNumber < 1 ||
        surahNumber > 114 ||
        ayahNumber < 1) {
      return null;
    }
    final entries = await _loadSurah(surahNumber);
    for (final entry in entries) {
      if (entry.ayahNumber == ayahNumber) return entry;
    }
    return null;
  }

  @override
  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async {
    if (sourceId != primaryBanglaTafsirSourceId ||
        surahNumber < 1 ||
        surahNumber > 114) {
      return const [];
    }
    return List.unmodifiable(await _loadSurah(surahNumber));
  }

  Future<_BundledManifest> _loadManifest() async {
    final cached = _manifest;
    if (cached != null) return cached;
    try {
      final raw = await _bundle.loadString(manifestAssetPath, cache: true);
      final json = jsonDecode(raw);
      if (json is! Map) {
        throw const FormatException('manifest root must be an object');
      }
      final manifest = _BundledManifest.fromJson(
        Map<String, dynamic>.from(json),
      );
      if (manifest.sourceId != primaryBanglaTafsirSourceId) {
        throw const FormatException('unexpected source id');
      }
      _manifest = manifest;
      return manifest;
    } catch (error) {
      if (error is BundledTafsirIntegrityException) rethrow;
      throw BundledTafsirIntegrityException(
        'Bundled Zakaria manifest is missing or invalid: $error',
      );
    }
  }

  Future<List<TafsirEntry>> _loadSurah(int surahNumber) async {
    if (_cachedSurahNumber == surahNumber && _cachedEntries != null) {
      return _cachedEntries!;
    }
    final manifest = await _loadManifest();
    final asset = manifest.surahs[surahNumber];
    if (asset == null) {
      throw BundledTafsirIntegrityException(
        'Bundled Zakaria manifest has no Surah $surahNumber.',
      );
    }

    try {
      final data = await _bundle.load('$_assetRoot/${asset.assetName}');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final digest = sha256.convert(bytes).toString();
      if (digest != asset.sha256) {
        throw BundledTafsirIntegrityException(
          'Bundled Zakaria Surah $surahNumber failed SHA-256 verification.',
        );
      }

      final decoded = jsonDecode(
        utf8.decode(gzip.decode(Uint8List.fromList(bytes))),
      );
      if (decoded is! Map) {
        throw const FormatException('Surah payload root must be an object');
      }
      final payload = Map<String, dynamic>.from(decoded);
      if (payload['source_id'] != manifest.sourceId ||
          payload['version'] != manifest.version ||
          payload['surah_number'] != surahNumber) {
        throw const FormatException('Surah payload identity mismatch');
      }
      final rawEntries = payload['entries'];
      if (rawEntries is! List || rawEntries.length != asset.ayahCount) {
        throw const FormatException('Surah payload ayah count mismatch');
      }

      final entries = <TafsirEntry>[];
      for (var index = 0; index < rawEntries.length; index++) {
        final rawEntry = rawEntries[index];
        if (rawEntry is! Map) {
          throw const FormatException('Tafsir entry must be an object');
        }
        final entry = Map<String, dynamic>.from(rawEntry);
        final ayahNumber = entry['ayah_number'];
        final translation = entry['translation'];
        final footnotes = entry['footnotes'];
        if (ayahNumber != index + 1 ||
            translation is! String ||
            footnotes is! String) {
          throw FormatException(
            'Invalid Zakaria entry for $surahNumber:${index + 1}',
          );
        }
        entries.add(
          TafsirEntry(
            sourceId: manifest.sourceId,
            sourceName: manifest.name,
            language: manifest.language,
            version: manifest.version,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber as int,
            text: combinedTafsirText(
              translation: translation,
              footnotes: footnotes,
            ),
            attribution: manifest.attribution,
            license: manifest.license,
          ),
        );
      }

      _cachedSurahNumber = surahNumber;
      _cachedEntries = List.unmodifiable(entries);
      return _cachedEntries!;
    } catch (error) {
      if (error is BundledTafsirIntegrityException) rethrow;
      throw BundledTafsirIntegrityException(
        'Bundled Zakaria Surah $surahNumber is missing or invalid: $error',
      );
    }
  }
}

class _BundledManifest {
  const _BundledManifest({
    required this.sourceId,
    required this.name,
    required this.language,
    required this.version,
    required this.surahs,
    this.attribution,
    this.license,
  });

  factory _BundledManifest.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('manifest $key must be a non-empty string');
      }
      return value;
    }

    final rawSurahs = json['surahs'];
    if (rawSurahs is! Map || rawSurahs.isEmpty) {
      throw const FormatException('manifest surahs must be a non-empty object');
    }
    final surahs = <int, _BundledSurahAsset>{};
    for (final entry in rawSurahs.entries) {
      final surahNumber = int.tryParse(entry.key.toString());
      if (surahNumber == null || entry.value is! Map) {
        throw const FormatException('invalid manifest Surah metadata');
      }
      surahs[surahNumber] = _BundledSurahAsset.fromJson(
        Map<String, dynamic>.from(entry.value as Map),
      );
    }

    return _BundledManifest(
      sourceId: requiredString('source_id'),
      name: requiredString('name'),
      language: requiredString('language'),
      version: requiredString('version'),
      attribution: json['attribution'] as String?,
      license: json['license'] as String?,
      surahs: Map.unmodifiable(surahs),
    );
  }

  final String sourceId;
  final String name;
  final String language;
  final String version;
  final String? attribution;
  final String? license;
  final Map<int, _BundledSurahAsset> surahs;
}

class _BundledSurahAsset {
  const _BundledSurahAsset({
    required this.assetName,
    required this.ayahCount,
    required this.sha256,
  });

  factory _BundledSurahAsset.fromJson(Map<String, dynamic> json) {
    final assetName = json['asset'];
    final ayahCount = json['ayah_count'];
    final sha = json['sha256'];
    if (assetName is! String ||
        assetName.isEmpty ||
        ayahCount is! int ||
        ayahCount <= 0 ||
        sha is! String ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(sha)) {
      throw const FormatException('invalid bundled Surah asset metadata');
    }
    return _BundledSurahAsset(
      assetName: assetName,
      ayahCount: ayahCount,
      sha256: sha,
    );
  }

  final String assetName;
  final int ayahCount;
  final String sha256;
}
