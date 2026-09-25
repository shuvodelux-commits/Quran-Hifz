import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sqlite3/sqlite3.dart';

import 'build_report.dart';
import 'models/source_records.dart';
import 'qul_mushaf_source.dart';
import 'quran_integrity_validator.dart';

const _schemaVersion = 2;
const _primaryTranslationResourceId = 1;

void main(List<String> args) {
  final options = _parseArgs(args);
  final quranFile = File(_requiredOption(options, 'quran'));
  final wordsFile = File(_requiredOption(options, 'words'));
  final translationFile = File(_requiredOption(options, 'translation'));
  final indoPakFile = File(_requiredOption(options, 'indopak-db'));
  final layoutFile = File(_requiredOption(options, 'layout-db'));
  final outputFile = File(_requiredOption(options, 'out'));

  for (final file in [
    quranFile,
    wordsFile,
    translationFile,
    indoPakFile,
    layoutFile,
  ]) {
    if (!file.existsSync()) {
      throw FileSystemException('Source file does not exist.', file.path);
    }
  }

  final quran = QuranSourceBundle.fromJson(_readObject(quranFile));
  final words = WordSourceBundle.fromJson(_readObject(wordsFile));
  final translation = TranslationSourceBundle.fromJson(
    _readObject(translationFile),
  );
  final qul = QulMushafSource.open(
    scriptPath: indoPakFile.path,
    layoutPath: layoutFile.path,
    requireProductionPageSet: true,
  );
  _validateQulCoverage(words, qul);

  final tempDb = File('${outputFile.path}.tmp');
  final reportFile = File('${outputFile.path}.report.json');
  final manifestFile = File.fromUri(
    outputFile.parent.uri.resolve('quran_content_manifest.json'),
  );
  final tempReport = File('${reportFile.path}.tmp');
  final tempManifest = File('${manifestFile.path}.tmp');
  _deleteIfExists(tempDb);
  _deleteIfExists(tempReport);
  _deleteIfExists(tempManifest);
  outputFile.parent.createSync(recursive: true);

  QuranIntegrityReport? integrityReport;
  final db = sqlite3.open(tempDb.path);
  try {
    db.execute('PRAGMA journal_mode = OFF;');
    db.execute('PRAGMA synchronous = OFF;');
    db.execute(File('tool/quran_content/schema.sql').readAsStringSync());

    db.execute('BEGIN IMMEDIATE;');
    try {
      _insertQuran(db, quran, qul);
      _insertWords(db, words, qul);
      _insertMushafLines(db, qul.lines);
      _insertTranslation(db, translation);
      _insertMetadata(
        db,
        quran,
        words,
        translation,
        indoPakSha256: _sha256File(indoPakFile),
        layoutSha256: _sha256File(layoutFile),
      );
      db.execute('COMMIT;');
    } catch (_) {
      db.execute('ROLLBACK;');
      rethrow;
    }

    integrityReport = validateQuranDatabase(db);
    if (!integrityReport.isValid) {
      throw StateError(
        'Quran database integrity validation failed:\n'
        '${integrityReport.errors.join('\n')}',
      );
    }

    db.execute('VACUUM;');
  } finally {
    db.close();
  }

  final databaseHash = _sha256File(tempDb);
  final reportJson = buildQuranReportDocument(
    schemaVersion: _schemaVersion,
    contentVersion: quran.contentVersion,
    databaseSha256: databaseHash,
    databaseSizeBytes: tempDb.lengthSync(),
    sources: {
      'quran': _sourceDescriptor(
        quranFile,
        quran.sourceName,
        quran.sourceVersion,
      ),
      'words': _sourceDescriptor(
        wordsFile,
        words.sourceName,
        words.sourceVersion,
      ),
      if (words.banglaWordSourceName != null &&
          words.banglaWordSourceVersion != null)
        'bangla_words': {
          ..._sourceDescriptor(
            wordsFile,
            words.banglaWordSourceName!,
            words.banglaWordSourceVersion!,
          ),
          if (words.banglaWordLanguage != null)
            'language': words.banglaWordLanguage!,
        },
      'translation': _sourceDescriptor(
        translationFile,
        translation.sourceName,
        translation.sourceVersion,
      ),
      'indopak_db': _fileSourceDescriptor(indoPakFile, 'QUL IndoPak script'),
      'layout_db': _fileSourceDescriptor(layoutFile, 'QUL PDMS layout'),
    },
    translationResourceId: _primaryTranslationResourceId,
    translationLanguage: translation.language,
    integrity: integrityReport,
  );
  tempReport.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(reportJson)}\n',
    flush: true,
  );
  final manifestJson = buildQuranPackageManifest(
    schemaVersion: _schemaVersion,
    contentVersion: quran.contentVersion,
    databaseSha256: databaseHash,
  );
  tempManifest.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(manifestJson)}\n',
    flush: true,
  );

  _replaceValidatedOutput(tempDb, outputFile);
  _replaceValidatedOutput(tempReport, reportFile);
  _replaceValidatedOutput(tempManifest, manifestFile);

  stdout.writeln('Built ${outputFile.path}');
  stdout.writeln('Manifest: ${manifestFile.path}');
  stdout.writeln('SHA-256: $databaseHash');
}

void _insertQuran(Database db, QuranSourceBundle source, QulMushafSource qul) {
  final surahs = [...source.surahs]
    ..sort((a, b) => a.number.compareTo(b.number));
  final ayahs = [...source.ayahs]
    ..sort((a, b) {
      final surahOrder = a.surahNumber.compareTo(b.surahNumber);
      return surahOrder != 0
          ? surahOrder
          : a.ayahNumber.compareTo(b.ayahNumber);
    });

  for (final surah in surahs) {
    db.execute(
      'INSERT INTO surahs '
      '(number, name_arabic, name_english, name_bangla, revelation_place, '
      'ayah_count, page_start, page_end, juz_start) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        surah.number,
        surah.nameArabic,
        surah.nameEnglish,
        surah.nameBangla,
        surah.revelationPlace,
        surah.ayahCount,
        surah.pageStart,
        surah.pageEnd,
        surah.juzStart,
      ],
    );
  }

  for (final ayah in ayahs) {
    db.execute(
      'INSERT INTO ayahs '
      '(surah_number, ayah_number, verse_key, arabic_text, '
      'arabic_text_indopak, arabic_text_tajweed, page_number, juz_number, hizb_number, rub_number) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        ayah.surahNumber,
        ayah.ayahNumber,
        ayah.verseKey,
        ayah.arabicText,
        qul.indoPakAyahText(ayah.surahNumber, ayah.ayahNumber),
        ayah.arabicTextTajweed,
        ayah.pageNumber,
        ayah.juzNumber,
        ayah.hizbNumber,
        ayah.rubNumber,
      ],
    );
  }
}

void _insertWords(Database db, WordSourceBundle source, QulMushafSource qul) {
  final words = [...source.words]
    ..sort((a, b) {
      final surahOrder = a.surahNumber.compareTo(b.surahNumber);
      if (surahOrder != 0) return surahOrder;
      final ayahOrder = a.ayahNumber.compareTo(b.ayahNumber);
      return ayahOrder != 0 ? ayahOrder : a.position.compareTo(b.position);
    });

  for (final word in words) {
    db.execute(
      'INSERT INTO quran_words '
      '(surah_number, ayah_number, position, arabic, arabic_indopak, arabic_tajweed, '
      'transliteration, bangla_meaning, english_meaning, root, lemma, grammar, '
      'audio_remote_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        word.surahNumber,
        word.ayahNumber,
        word.position,
        word.arabic,
        qul.indoPakWordText(_wordLocation(word)),
        word.arabicTajweed,
        word.transliteration,
        word.banglaMeaning,
        word.englishMeaning,
        word.root,
        word.lemma,
        word.grammar,
        word.audioRemotePath,
      ],
    );
  }
}

void _insertMushafLines(Database db, List<MushafLineSourceRecord> lines) {
  for (final line in lines) {
    db.execute(
      'INSERT INTO mushaf_lines '
      '(page_number, line_number, line_type, is_centered, surah_number, '
      'first_word_location, last_word_location) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        line.pageNumber,
        line.lineNumber,
        line.lineType,
        line.centered ? 1 : 0,
        line.surahNumber,
        line.firstWordLocation,
        line.lastWordLocation,
      ],
    );
  }
}

void _insertTranslation(Database db, TranslationSourceBundle source) {
  final rows = [...source.translations]
    ..sort((a, b) {
      final surahOrder = a.surahNumber.compareTo(b.surahNumber);
      return surahOrder != 0
          ? surahOrder
          : a.ayahNumber.compareTo(b.ayahNumber);
    });

  for (final row in rows) {
    db.execute(
      'INSERT INTO translations '
      '(resource_id, surah_number, ayah_number, language, text) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        _primaryTranslationResourceId,
        row.surahNumber,
        row.ayahNumber,
        source.language,
        row.text,
      ],
    );
  }
}

void _insertMetadata(
  Database db,
  QuranSourceBundle quran,
  WordSourceBundle words,
  TranslationSourceBundle translation, {
  required String indoPakSha256,
  required String layoutSha256,
}) {
  final metadata = <String, String>{
    'schema_version': '$_schemaVersion',
    'content_version': quran.contentVersion,
    'quran_source_name': quran.sourceName,
    'quran_source_version': quran.sourceVersion,
    'word_source_name': words.sourceName,
    'word_source_version': words.sourceVersion,
    if (words.banglaWordSourceName != null)
      'bangla_word_source_name': words.banglaWordSourceName!,
    if (words.banglaWordSourceVersion != null)
      'bangla_word_source_version': words.banglaWordSourceVersion!,
    if (words.banglaWordLanguage != null)
      'bangla_word_language': words.banglaWordLanguage!,
    'translation_source_name': translation.sourceName,
    'translation_source_version': translation.sourceVersion,
    'translation_resource_id': '$_primaryTranslationResourceId',
    'translation_source_resource_id': '${translation.resourceId}',
    'translation_language': translation.language,
    'qul_indopak_sha256': indoPakSha256,
    'qul_layout_sha256': layoutSha256,
  };

  for (final entry in metadata.entries) {
    db.execute(
      'INSERT INTO quran_metadata (metadata_key, metadata_value) VALUES (?, ?)',
      [entry.key, entry.value],
    );
  }
}

void _validateQulCoverage(WordSourceBundle words, QulMushafSource qul) {
  final canonicalLocations = words.words.map(_wordLocation).toSet();
  final qulLocations = qul.wordLocations.toSet();
  if (canonicalLocations.length != words.words.length ||
      canonicalLocations.length != qulLocations.length ||
      !canonicalLocations.containsAll(qulLocations)) {
    throw StateError(
      'QUL word locations must exactly match the canonical word source: '
      '${canonicalLocations.length} canonical, ${qulLocations.length} QUL.',
    );
  }
}

String _wordLocation(WordSourceRecord word) =>
    '${word.surahNumber}:${word.ayahNumber}:${word.position}';

Map<String, dynamic> _readObject(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map) {
    throw FormatException('${file.path} must contain a JSON object.');
  }
  return Map<String, dynamic>.from(decoded);
}

Map<String, Object> _sourceDescriptor(
  File file,
  String sourceName,
  String sourceVersion,
) {
  return {
    'name': sourceName,
    'version': sourceVersion,
    'file_name': file.uri.pathSegments.last,
    'sha256': _sha256File(file),
  };
}

Map<String, Object> _fileSourceDescriptor(File file, String name) {
  return {
    'name': name,
    'version': 'input-file',
    'file_name': file.uri.pathSegments.last,
    'sha256': _sha256File(file),
  };
}

String _sha256File(File file) {
  return sha256.convert(file.readAsBytesSync()).toString();
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (!arg.startsWith('--')) {
      throw FormatException('Unexpected argument "$arg".');
    }
    if (i + 1 >= args.length || args[i + 1].startsWith('--')) {
      throw FormatException('Missing value for "$arg".');
    }
    result[arg.substring(2)] = args[++i];
  }
  return result;
}

String _requiredOption(Map<String, String> options, String name) {
  final value = options[name];
  if (value == null || value.isEmpty) {
    throw FormatException('Missing required option --$name.');
  }
  return value;
}

void _deleteIfExists(File file) {
  if (file.existsSync()) file.deleteSync();
}

void _replaceValidatedOutput(File staged, File target) {
  target.parent.createSync(recursive: true);
  final backup = File('${target.path}.previous');
  _deleteIfExists(backup);

  if (!target.existsSync()) {
    staged.renameSync(target.path);
    return;
  }

  target.renameSync(backup.path);
  try {
    staged.renameSync(target.path);
    backup.deleteSync();
  } catch (_) {
    if (target.existsSync()) target.deleteSync();
    backup.renameSync(target.path);
    rethrow;
  }
}
