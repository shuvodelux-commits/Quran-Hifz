import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/quran_font_preference.dart';
import '../domain/quran_page_font_repository.dart';

typedef QuranFontSupportDirectory = Future<Directory> Function();

Uri quranFoundationPageFontUri(QuranFontPreference font, int page) {
  _validateStrictFont(font);
  _validatePage(page);
  return Uri.parse(switch (font) {
    QuranFontPreference.qcfV2 =>
      'https://verses.quran.foundation/fonts/quran/hafs/v2/woff2/p$page.woff2',
    QuranFontPreference.qcfV4Tajweed =>
      'https://verses.quran.foundation/fonts/quran/hafs/v4/colrv1/woff2/p$page.woff2',
    _ => throw ArgumentError.value(font, 'font', 'Strict QCF font required'),
  });
}

bool isWoff2(List<int> bytes) =>
    bytes.length >= 4 &&
    bytes[0] == 0x77 &&
    bytes[1] == 0x4f &&
    bytes[2] == 0x46 &&
    bytes[3] == 0x32;

class QuranFoundationPageFontRepository implements QuranPageFontRepository {
  QuranFoundationPageFontRepository({
    required QuranFontPreference font,
    http.Client? client,
    QuranFontSupportDirectory? supportDirectory,
  }) : _font = font,
       _client = client ?? http.Client(),
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory {
    _validateStrictFont(font);
  }

  final QuranFontPreference _font;
  final http.Client _client;
  final QuranFontSupportDirectory _supportDirectory;
  final Map<int, Future<Uri>> _inFlight = <int, Future<Uri>>{};

  @override
  Future<Uri> ensurePageFont(int page) {
    _validatePage(page);
    final existing = _inFlight[page];
    if (existing != null) return existing;

    late final Future<Uri> future;
    future = _ensurePageFont(page).whenComplete(() {
      if (identical(_inFlight[page], future)) {
        _inFlight.remove(page);
      }
    });
    _inFlight[page] = future;
    return future;
  }

  @override
  Future<bool> isCached(int page) async {
    _validatePage(page);
    final file = await _fontFile(page);
    return _hasValidWoff2(file);
  }

  @override
  Future<void> prefetchNeighbors(int page) async {
    _validatePage(page);
    for (final neighbor in <int>[page - 1, page + 1]) {
      if (neighbor < 1 || neighbor > 604) continue;
      unawaited(
        ensurePageFont(neighbor).then<void>((_) {}).catchError((Object _) {}),
      );
    }
  }

  Future<Uri> _ensurePageFont(int page) async {
    final finalFile = await _fontFile(page);
    final recovered = await _recoverValidCache(finalFile);
    if (recovered != null) return recovered.uri;

    final partFile = File('${finalFile.path}.part');
    await _deleteIfExists(partFile);

    final uri = quranFoundationPageFontUri(_font, page);
    late final http.Response response;
    try {
      response = await _client.get(uri);
    } on Object catch (error) {
      await _deleteIfExists(partFile);
      throw QuranPageFontUnavailableException(
        page: page,
        message: 'Quran Foundation page font is unavailable.',
        cause: error,
      );
    }

    if (response.statusCode != 200) {
      throw QuranPageFontUnavailableException(
        page: page,
        message:
            'Quran Foundation page font returned HTTP ${response.statusCode}.',
      );
    }
    if (!isWoff2(response.bodyBytes)) {
      throw const FormatException(
        'Downloaded Quran Foundation page font is not WOFF2.',
      );
    }

    await finalFile.parent.create(recursive: true);
    try {
      await partFile.writeAsBytes(response.bodyBytes, flush: true);
      if (!isWoff2(await partFile.readAsBytes())) {
        throw const FormatException('Temporary page font is not WOFF2.');
      }
      await _replaceAtomically(finalFile: finalFile, partFile: partFile);
      return finalFile.uri;
    } finally {
      await _deleteIfExists(partFile);
    }
  }

  Future<File?> _recoverValidCache(File finalFile) async {
    if (await _hasValidWoff2(finalFile)) {
      final backup = File('${finalFile.path}.bak');
      await _deleteIfExists(backup);
      return finalFile;
    }

    final backup = File('${finalFile.path}.bak');
    if (!await _hasValidWoff2(backup)) {
      return null;
    }

    await _deleteIfExists(finalFile);
    await backup.rename(finalFile.path);
    return finalFile;
  }

  Future<bool> _hasValidWoff2(File file) async {
    if (!await file.exists()) return false;
    try {
      return isWoff2(await file.readAsBytes());
    } on FileSystemException {
      return false;
    }
  }

  Future<File> _fontFile(int page) async {
    final support = await _supportDirectory();
    return File(
      p.join(
        support.path,
        'quran',
        'page-fonts',
        _font == QuranFontPreference.qcfV2 ? 'qcf-v2' : 'qcf-v4-tajweed',
        'p$page.woff2',
      ),
    );
  }

  Future<void> _replaceAtomically({
    required File finalFile,
    required File partFile,
  }) async {
    final backup = File('${finalFile.path}.bak');
    await _deleteIfExists(backup);
    final hadFinal = await finalFile.exists();
    if (hadFinal) {
      await finalFile.rename(backup.path);
    }

    try {
      await partFile.rename(finalFile.path);
      await _deleteIfExists(backup);
    } catch (_) {
      await _deleteIfExists(finalFile);
      if (hadFinal && await backup.exists()) {
        await backup.rename(finalFile.path);
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

void _validateStrictFont(QuranFontPreference font) {
  if (font != QuranFontPreference.qcfV2 &&
      font != QuranFontPreference.qcfV4Tajweed) {
    throw ArgumentError.value(font, 'font', 'Strict QCF font required');
  }
}

void _validatePage(int page) {
  if (page < 1 || page > 604) {
    throw RangeError.range(page, 1, 604, 'page');
  }
}
