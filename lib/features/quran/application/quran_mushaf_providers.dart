import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/bundled_quran_mushaf_page_repository.dart';
import '../data/quran_foundation_page_font_repository.dart';
import '../domain/quran_font_preference.dart';
import '../domain/quran_mushaf_page.dart';
import '../domain/quran_mushaf_page_repository.dart';
import '../domain/quran_mushaf_variant.dart';
import '../domain/quran_page_font_repository.dart';

final quranMushafPageRepositoryProvider = Provider<QuranMushafPageRepository>((
  ref,
) {
  return _MaterializedMushafPageRepository();
});

final quranPageFontRepositoryProvider =
    Provider.family<QuranPageFontRepository, QuranFontPreference>((ref, font) {
      return QuranFoundationPageFontRepository(font: font);
    });

class _MaterializedMushafPageRepository implements QuranMushafPageRepository {
  Future<BundledQuranMushafPageRepository>? _delegate;

  @override
  Future<bool> isVariantAvailable(QuranMushafVariant variant) async {
    return (await _repository()).isVariantAvailable(variant);
  }

  @override
  Future<QcfMushafPage> loadPage({
    required QuranMushafVariant variant,
    required int page,
  }) async {
    return (await _repository()).loadPage(variant: variant, page: page);
  }

  Future<BundledQuranMushafPageRepository> _repository() {
    return _delegate ??= _buildRepository();
  }

  Future<BundledQuranMushafPageRepository> _buildRepository() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(p.join(support.path, 'mushaf', 'data'));
    await directory.create(recursive: true);

    final qcfV4Layout = await _materialize(
      assetPath: 'assets/mushaf/layouts/qpc-v4-tajweed-15-lines.sqlite',
      directory: directory,
    );
    final qcfV4Script = await _materialize(
      assetPath: 'assets/mushaf/scripts/qpc-v4-words.sqlite',
      directory: directory,
    );
    final qcfV2Layout = await _materializeOptional(
      assetPath: 'assets/mushaf/layouts/qcf-v2-15-lines.sqlite',
      directory: directory,
    );
    final qcfV2Script = await _materializeOptional(
      assetPath: 'assets/mushaf/scripts/qcf-v2-words.sqlite',
      directory: directory,
    );

    return BundledQuranMushafPageRepository.forFiles(
      qcfV4LayoutPath: qcfV4Layout.path,
      qcfV4ScriptPath: qcfV4Script.path,
      qcfV2LayoutPath: qcfV2Layout?.path ?? '',
      qcfV2ScriptPath: qcfV2Script?.path ?? '',
    );
  }

  Future<File> _materialize({
    required String assetPath,
    required Directory directory,
  }) async {
    final data = await rootBundle.load(assetPath);
    final bytes = Uint8List.sublistView(data);
    final digest = sha256.convert(bytes).toString();
    final name = p.basename(assetPath);
    final target = File(p.join(directory.path, name));
    final sidecar = File('${target.path}.sha256');

    if (await target.exists() &&
        await sidecar.exists() &&
        (await sidecar.readAsString()).trim() == digest) {
      return target;
    }

    final part = File('${target.path}.part');
    final sidecarPart = File('${sidecar.path}.part');
    await _deleteIfExists(part);
    await _deleteIfExists(sidecarPart);

    try {
      await part.writeAsBytes(bytes, flush: true);
      await sidecarPart.writeAsString(digest, flush: true);
      await _replaceFile(part, target);
      await _replaceFile(sidecarPart, sidecar);
      return target;
    } finally {
      await _deleteIfExists(part);
      await _deleteIfExists(sidecarPart);
    }
  }

  Future<File?> _materializeOptional({
    required String assetPath,
    required Directory directory,
  }) async {
    try {
      return await _materialize(assetPath: assetPath, directory: directory);
    } on FlutterError {
      return null;
    }
  }

  Future<void> _replaceFile(File source, File target) async {
    final backup = File('${target.path}.bak');
    await _deleteIfExists(backup);
    final hadTarget = await target.exists();
    if (hadTarget) {
      await target.rename(backup.path);
    }

    try {
      await source.rename(target.path);
      await _deleteIfExists(backup);
    } catch (_) {
      await _deleteIfExists(target);
      if (hadTarget && await backup.exists()) {
        await backup.rename(target.path);
      }
      rethrow;
    }
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
