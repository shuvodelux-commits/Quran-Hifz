import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/mushaf_page_font_repository.dart';

typedef MushafFontSupportDirectory = Future<Directory> Function();

Uri qpcV4FontUri(int page) => Uri.parse(
  'https://static-cdn.tarteel.ai/qul/fonts/quran_fonts/v4-tajweed/woff2/'
  'p$page.woff2?v=3.1',
);

bool isWoff2(List<int> bytes) =>
    bytes.length >= 4 &&
    bytes[0] == 0x77 &&
    bytes[1] == 0x4f &&
    bytes[2] == 0x46 &&
    bytes[3] == 0x32;

class QpcV4PageFontRepository implements MushafPageFontRepository {
  QpcV4PageFontRepository({
    http.Client? client,
    MushafFontSupportDirectory? supportDirectory,
  }) : _client = client ?? http.Client(),
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  final http.Client _client;
  final MushafFontSupportDirectory _supportDirectory;
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
    if (!await file.exists()) return false;
    try {
      return isWoff2(await file.readAsBytes());
    } on FileSystemException {
      return false;
    }
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
    if (await finalFile.exists()) {
      try {
        final bytes = await finalFile.readAsBytes();
        if (isWoff2(bytes)) return finalFile.uri;
      } on FileSystemException {
        // Treat unreadable cache as stale and attempt a verified refresh.
      }
    }

    final response = await _client.get(qpcV4FontUri(page));
    if (response.statusCode != 200) {
      throw HttpException(
        'QPC V4 page $page font download returned '
        'HTTP ${response.statusCode}.',
        uri: qpcV4FontUri(page),
      );
    }
    if (!isWoff2(response.bodyBytes)) {
      throw const FormatException('Downloaded QPC V4 font is not WOFF2.');
    }

    await finalFile.parent.create(recursive: true);
    final partFile = File('${finalFile.path}.part');
    await _deleteIfExists(partFile);
    try {
      await partFile.writeAsBytes(response.bodyBytes, flush: true);
      if (!isWoff2(await partFile.readAsBytes())) {
        throw const FormatException('Temporary QPC V4 font is not WOFF2.');
      }
      await _replaceAtomically(finalFile: finalFile, partFile: partFile);
      return finalFile.uri;
    } finally {
      await _deleteIfExists(partFile);
    }
  }

  Future<File> _fontFile(int page) async {
    final support = await _supportDirectory();
    return File(p.join(support.path, 'mushaf', 'qpc-v4', 'p$page.woff2'));
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

  void _validatePage(int page) {
    if (page < 1 || page > 604) {
      throw RangeError.range(page, 1, 604, 'page');
    }
  }
}
