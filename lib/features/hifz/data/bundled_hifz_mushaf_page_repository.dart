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
      layout.close();
      script.close();
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
      script.close();
      layout.close();
    }
  }

  @override
  Future<bool> isVariantAvailable(HifzMushafVariant variant) async {
    final paths = _pathsFor(variant);
    if (!File(paths.layout).existsSync()) return false;
    final scriptPath = paths.script;
    if (scriptPath == null || !File(scriptPath).existsSync()) return false;

    if (variant == HifzMushafVariant.qpcV4Tajweed) return true;
    return _hasVerifiedDigitalKhattData(
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

  bool _hasVerifiedDigitalKhattData({
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
      if (metadata['script_kind'] != 'digital_khatt_v2' ||
          metadata['script_type'] != 'text_digital_khatt' ||
          metadata['font_family'] != 'digitalkhatt-v2' ||
          metadata['qul_resource_id'] != '48') {
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

      final ranges = layout.select('''
        SELECT first_word_id, last_word_id
        FROM pages
        WHERE line_type = 'ayah'
        ORDER BY first_word_id, last_word_id
        ''');
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

      final stats = script.select('''
        SELECT
          COUNT(*) AS token_count,
          MIN(word_index) AS min_word_index,
          MAX(word_index) AS max_word_index
        FROM words
        ''');
      if (stats.length != 1) return false;
      final statsRow = stats.single;
      if (_optionalInt(statsRow['token_count']) != expectedTokenCount ||
          _optionalInt(statsRow['min_word_index']) != 1 ||
          _optionalInt(statsRow['max_word_index']) != expectedTokenCount) {
        return false;
      }

      final invalidRows = script.select('''
        SELECT COUNT(*) AS invalid_count
        FROM words
        WHERE ayah_key IS NULL
           OR ayah_key = ''
           OR word_position IS NULL
           OR word_position < 1
           OR display IS NULL
           OR display = ''
        ''');
      if (_optionalInt(invalidRows.single['invalid_count']) != 0) {
        return false;
      }

      const canonicalDisplays = <String>[
        'أَوْ',
        'زِدْ',
        'عَلَيْهِ',
        'وَرَتِّلِ',
        'ٱلْقُرْءَانَ',
        'تَرْتِيلًا',
        '۝٤',
      ];
      final canonical = script.select('''
        SELECT word_position, char_type, display
        FROM words
        WHERE ayah_key = '73:4'
        ORDER BY word_position
        ''');
      if (canonical.length != canonicalDisplays.length) return false;
      for (var index = 0; index < canonicalDisplays.length; index++) {
        final row = canonical[index];
        if (_optionalInt(row['word_position']) != index + 1 ||
            row['display']?.toString() != canonicalDisplays[index]) {
          return false;
        }
      }
      if (canonical.last['char_type']?.toString() != 'end') {
        return false;
      }

      return true;
    } on Object {
      return false;
    } finally {
      layout?.close();
      script?.close();
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
