import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../domain/hifz_mushaf_page.dart';
import '../domain/hifz_mushaf_page_repository.dart';
import '../domain/hifz_reading_mode.dart';
import '../domain/hifz_session.dart';

class BundledHifzMushafPageRepository implements HifzMushafPageRepository {
  BundledHifzMushafPageRepository.forFiles({
    required String qpcLayoutPath,
    required String qpcScriptPath,
    required String digitalKhattLayoutPath,
    String? digitalKhattScriptPath,
  }) : _qpcLayoutPath = qpcLayoutPath,
       _qpcScriptPath = qpcScriptPath,
       _digitalKhattLayoutPath = digitalKhattLayoutPath,
       _digitalKhattScriptPath = digitalKhattScriptPath;

  final String _qpcLayoutPath;
  final String _qpcScriptPath;
  final String _digitalKhattLayoutPath;
  final String? _digitalKhattScriptPath;

  @override
  Future<HifzMushafPage> loadPage({
    required HifzMushafVariant variant,
    required int page,
  }) async {
    if (page < 1 || page > 604) {
      throw RangeError.range(page, 1, 604, 'page');
    }
    if (!await isVariantAvailable(variant)) {
      throw MushafVariantUnavailableException(variant);
    }

    final paths = _pathsFor(variant);
    final layout = sqlite3.open(paths.layout, mode: OpenMode.readOnly);
    final script = sqlite3.open(paths.script!, mode: OpenMode.readOnly);
    try {
      final rows = layout.select(
        '''
        SELECT
          line_number,
          line_type,
          is_centered,
          first_word_id,
          last_word_id,
          surah_number
        FROM pages
        WHERE page_number = ?
        ORDER BY line_number
        ''',
        [page],
      );
      if (rows.isEmpty) {
        throw MushafDataIntegrityException(
          'Mushaf page $page has no layout rows.',
        );
      }

      final lines = <HifzMushafLine>[];
      for (final row in rows) {
        final lineNumber = _requiredInt(row['line_number'], 'line_number');
        final type = _lineType(row['line_type']?.toString());
        final tokens = switch (type) {
          HifzMushafLineType.ayah => _loadTokens(
            script,
            firstWordId: _requiredInt(row['first_word_id'], 'first_word_id'),
            lastWordId: _requiredInt(row['last_word_id'], 'last_word_id'),
            page: page,
            lineNumber: lineNumber,
          ),
          HifzMushafLineType.basmallah ||
          HifzMushafLineType.surahName => const <HifzMushafToken>[],
        };
        lines.add(
          HifzMushafLine(
            lineNumber: lineNumber,
            type: type,
            isCentered: _requiredInt(row['is_centered'], 'is_centered') == 1,
            surahNumber: _optionalInt(row['surah_number']),
            tokens: List.unmodifiable(tokens),
          ),
        );
      }

      return HifzMushafPage(
        page: page,
        variant: variant,
        lines: List.unmodifiable(lines),
      );
    } on MushafDataIntegrityException {
      rethrow;
    } on SqliteException catch (error) {
      throw MushafDataIntegrityException(
        'Could not load Mushaf page $page: ${error.message}',
      );
    } finally {
      layout.dispose();
      script.dispose();
    }
  }

  @override
  Future<int?> pageForAyah({
    required HifzMushafVariant variant,
    required AyahRef ayah,
  }) async {
    if (!await isVariantAvailable(variant)) return null;

    final paths = _pathsFor(variant);
    final script = sqlite3.open(paths.script!, mode: OpenMode.readOnly);
    final layout = sqlite3.open(paths.layout, mode: OpenMode.readOnly);
    try {
      final tokenRows = script.select(
        'SELECT MIN(word_index) AS first_index FROM words WHERE ayah_key = ?',
        [ayah.verseKey],
      );
      if (tokenRows.isEmpty || tokenRows.first['first_index'] == null) {
        return null;
      }
      final wordIndex = _requiredInt(
        tokenRows.first['first_index'],
        'first_index',
      );
      final pageRows = layout.select(
        '''
        SELECT page_number
        FROM pages
        WHERE line_type = 'ayah'
          AND first_word_id <= ?
          AND last_word_id >= ?
        ORDER BY page_number, line_number
        LIMIT 1
        ''',
        [wordIndex, wordIndex],
      );
      if (pageRows.isEmpty) return null;
      return _requiredInt(pageRows.first['page_number'], 'page_number');
    } on SqliteException catch (error) {
      throw MushafDataIntegrityException(
        'Could not resolve page for ${ayah.verseKey}: ${error.message}',
      );
    } finally {
      script.dispose();
      layout.dispose();
    }
  }

  @override
  Future<bool> isVariantAvailable(HifzMushafVariant variant) async {
    final paths = _pathsFor(variant);
    if (!File(paths.layout).existsSync()) return false;
    final scriptPath = paths.script;
    if (scriptPath == null || !File(scriptPath).existsSync()) return false;

    if (variant == HifzMushafVariant.qpcV4Tajweed) return true;
    return _hasVerifiedDigitalKhattSchema(scriptPath);
  }

  List<HifzMushafToken> _loadTokens(
    Database script, {
    required int firstWordId,
    required int lastWordId,
    required int page,
    required int lineNumber,
  }) {
    if (firstWordId > lastWordId) {
      throw MushafDataIntegrityException(
        'Invalid word range $firstWordId..$lastWordId '
        'on page $page line $lineNumber.',
      );
    }
    final rows = script.select(
      '''
      SELECT word_index, ayah_key, word_position, char_type, display
      FROM words
      WHERE word_index BETWEEN ? AND ?
      ORDER BY word_index
      ''',
      [firstWordId, lastWordId],
    );
    final expectedCount = lastWordId - firstWordId + 1;
    if (rows.length != expectedCount) {
      throw MushafDataIntegrityException(
        'Missing Mushaf script token on page $page line $lineNumber.',
      );
    }

    final tokens = <HifzMushafToken>[];
    for (var offset = 0; offset < rows.length; offset++) {
      final row = rows[offset];
      final expectedIndex = firstWordId + offset;
      final actualIndex = _requiredInt(row['word_index'], 'word_index');
      if (actualIndex != expectedIndex) {
        throw MushafDataIntegrityException(
          'Expected word_index $expectedIndex but found $actualIndex '
          'on page $page line $lineNumber.',
        );
      }
      final display = row['display']?.toString() ?? '';
      if (display.isEmpty) {
        throw MushafDataIntegrityException(
          'Empty Mushaf display token at word_index $actualIndex.',
        );
      }
      tokens.add(
        HifzMushafToken(
          wordIndex: actualIndex,
          type: _tokenType(row['char_type']?.toString()),
          display: display,
          ayahKey: row['ayah_key']?.toString(),
          wordPosition: _optionalInt(row['word_position']),
        ),
      );
    }
    return tokens;
  }

  bool _hasVerifiedDigitalKhattSchema(String path) {
    Database? database;
    try {
      database = sqlite3.open(path, mode: OpenMode.readOnly);
      final metadata = database.select(
        "SELECT value FROM metadata WHERE key = 'script_kind' LIMIT 1",
      );
      if (metadata.length != 1 ||
          metadata.first['value']?.toString() != 'digital_khatt_v2') {
        return false;
      }
      final columns = database
          .select('PRAGMA table_info(words)')
          .map((row) => row['name']?.toString())
          .toSet();
      return const {
        'word_index',
        'ayah_key',
        'word_position',
        'char_type',
        'display',
      }.every(columns.contains);
    } on Object {
      return false;
    } finally {
      database?.dispose();
    }
  }

  _MushafPaths _pathsFor(HifzMushafVariant variant) {
    return switch (variant) {
      HifzMushafVariant.qpcV4Tajweed => _MushafPaths(
        layout: _qpcLayoutPath,
        script: _qpcScriptPath,
      ),
      HifzMushafVariant.digitalKhattV2 => _MushafPaths(
        layout: _digitalKhattLayoutPath,
        script: _digitalKhattScriptPath,
      ),
    };
  }

  HifzMushafLineType _lineType(String? raw) {
    return switch (raw) {
      'ayah' => HifzMushafLineType.ayah,
      'basmallah' => HifzMushafLineType.basmallah,
      'surah_name' => HifzMushafLineType.surahName,
      _ => throw MushafDataIntegrityException(
        'Unsupported Mushaf line type: $raw.',
      ),
    };
  }

  HifzMushafTokenType _tokenType(String? raw) {
    return switch (raw) {
      'word' => HifzMushafTokenType.word,
      'end' => HifzMushafTokenType.end,
      'pause' => HifzMushafTokenType.pause,
      _ => HifzMushafTokenType.other,
    };
  }

  int _requiredInt(Object? value, String name) {
    final parsed = _optionalInt(value);
    if (parsed == null) {
      throw MushafDataIntegrityException('$name must be an integer.');
    }
    return parsed;
  }

  int? _optionalInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

class _MushafPaths {
  const _MushafPaths({required this.layout, required this.script});

  final String layout;
  final String? script;
}
