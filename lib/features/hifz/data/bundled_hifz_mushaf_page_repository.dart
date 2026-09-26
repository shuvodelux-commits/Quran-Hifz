import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../domain/hifz_mushaf_page.dart';
import '../domain/hifz_mushaf_page_repository.dart';
import '../domain/hifz_reading_mode.dart';
import '../domain/hifz_session.dart';

class BundledHifzMushafPageRepository implements HifzMushafPageRepository {
  BundledHifzMushafPageRepository.forFiles({
    required String qcfV4LayoutPath,
    required String qcfV4ScriptPath,
    required String qcfV2LayoutPath,
    required String qcfV2ScriptPath,
  }) : _qcfV4LayoutPath = qcfV4LayoutPath,
       _qcfV4ScriptPath = qcfV4ScriptPath,
       _qcfV2LayoutPath = qcfV2LayoutPath,
       _qcfV2ScriptPath = qcfV2ScriptPath;

  final String _qcfV4LayoutPath;
  final String _qcfV4ScriptPath;
  final String _qcfV2LayoutPath;
  final String _qcfV2ScriptPath;

  @override
  Future<HifzMushafPage> loadPage({
    required QuranMushafVariant variant,
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
      layout.close();
      script.close();
    }
  }

  @override
  Future<int?> pageForAyah({
    required QuranMushafVariant variant,
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
      script.close();
      layout.close();
    }
  }

  @override
  Future<bool> isVariantAvailable(QuranMushafVariant variant) async {
    final paths = _pathsFor(variant);
    if (!File(paths.layout).existsSync()) return false;
    final scriptPath = paths.script;
    if (scriptPath == null || !File(scriptPath).existsSync()) return false;

    if (variant == QuranMushafVariant.qcfV4Tajweed) return true;
    return _hasVerifiedQcfV2Data(
      layoutPath: paths.layout,
      scriptPath: scriptPath,
    );
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
      SELECT word_index, ayah_key, word_position, char_type, display, unicode_fallback
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
          unicodeFallback: row['unicode_fallback']?.toString(),
          ayahKey: row['ayah_key']?.toString(),
          wordPosition: _optionalInt(row['word_position']),
        ),
      );
    }
    return tokens;
  }

  bool _hasVerifiedQcfV2Data({
    required String layoutPath,
    required String scriptPath,
  }) {
    Database? layout;
    Database? script;
    try {
      layout = sqlite3.open(layoutPath, mode: OpenMode.readOnly);
      script = sqlite3.open(scriptPath, mode: OpenMode.readOnly);
      final metadata = <String, String>{
        for (final row in script.select('SELECT key, value FROM metadata'))
          if (row['key'] != null && row['value'] != null)
            row['key'].toString(): row['value'].toString(),
      };
      if (metadata['mushaf_id'] != '1' ||
          metadata['script_kind'] != 'qcf_v2' ||
          metadata['page_count'] != '604') {
        return false;
      }

      final columns = script
          .select('PRAGMA table_info(words)')
          .map((row) => row['name']?.toString())
          .toSet();
      if (!const {
        'word_index',
        'ayah_key',
        'word_position',
        'char_type',
        'display',
      }.every(columns.contains)) {
        return false;
      }

      final pages = layout
          .select(
            'SELECT COUNT(DISTINCT page_number) AS count, '
            'MIN(page_number) AS min_page, MAX(page_number) AS max_page '
            'FROM pages',
          )
          .single;
      if (_optionalInt(pages['count']) != 604 ||
          _optionalInt(pages['min_page']) != 1 ||
          _optionalInt(pages['max_page']) != 604) {
        return false;
      }

      final ranges = layout.select(
        "SELECT first_word_id, last_word_id FROM pages "
        "WHERE line_type = 'ayah' ORDER BY first_word_id, last_word_id",
      );
      if (ranges.isEmpty) return false;
      var expectedFirst = 1;
      for (final row in ranges) {
        final first = _optionalInt(row['first_word_id']);
        final last = _optionalInt(row['last_word_id']);
        if (first == null ||
            last == null ||
            first != expectedFirst ||
            last < first) {
          return false;
        }
        expectedFirst = last + 1;
      }
      final expectedTokenCount = expectedFirst - 1;
      if (int.tryParse(metadata['token_count'] ?? '') != expectedTokenCount) {
        return false;
      }

      final stats = script
          .select(
            'SELECT COUNT(*) AS count, MIN(word_index) AS min_id, '
            'MAX(word_index) AS max_id FROM words',
          )
          .single;
      if (_optionalInt(stats['count']) != expectedTokenCount ||
          _optionalInt(stats['min_id']) != 1 ||
          _optionalInt(stats['max_id']) != expectedTokenCount) {
        return false;
      }

      final invalid = script
          .select(
            "SELECT COUNT(*) AS count FROM words WHERE ayah_key IS NULL "
            "OR ayah_key = '' OR display IS NULL OR display = '' "
            "OR (char_type = 'word' AND "
            "(word_position IS NULL OR word_position < 1))",
          )
          .single;
      return _optionalInt(invalid['count']) == 0;
    } on Object {
      return false;
    } finally {
      layout?.close();
      script?.close();
    }
  }

  _MushafPaths _pathsFor(QuranMushafVariant variant) {
    return switch (variant) {
      QuranMushafVariant.qcfV4Tajweed => _MushafPaths(
        layout: _qcfV4LayoutPath,
        script: _qcfV4ScriptPath,
      ),
      QuranMushafVariant.qcfV2 => _MushafPaths(
        layout: _qcfV2LayoutPath,
        script: _qcfV2ScriptPath,
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
