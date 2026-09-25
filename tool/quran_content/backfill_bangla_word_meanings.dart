import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:sqlite3/sqlite3.dart';

import '../../lib/features/quran/domain/canonical_quran_counts.dart';
import 'quran_integrity_validator.dart';

const banglaWordSourceName = 'Quran.com Content API v4 Bangla word data';
const banglaWordLanguage = 'bn';

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final databaseFile = File(
    options['db'] ?? 'assets/database/quran_content.sqlite',
  );
  final manifestFile = File(
    options['manifest'] ?? 'assets/database/quran_content_manifest.json',
  );
  final reportFile = File(
    options['report'] ?? 'assets/database/quran_content.sqlite.report.json',
  );
  final contentVersion = _required(
    options['content-version'],
    '--content-version',
  );
  final apiHost = options['api-host'] ?? 'api.quran.com';

  for (final file in [databaseFile, manifestFile, reportFile]) {
    if (!file.existsSync()) {
      throw FileSystemException(
        'Required release asset is missing.',
        file.path,
      );
    }
  }

  final client = http.Client();
  late final Map<String, String> meanings;
  try {
    meanings = await fetchAllBanglaWordMeanings(
      client: client,
      apiHost: apiHost,
    );
  } finally {
    client.close();
  }

  if (meanings.length != canonicalQuranWordCount) {
    throw StateError(
      'Expected ' +
          canonicalQuranWordCount.toString() +
          ' Bangla word meanings, found ' +
          meanings.length.toString() +
          '.',
    );
  }

  final stagedDatabase = File(databaseFile.path + '.bnwords.tmp');
  final stagedManifest = File(manifestFile.path + '.bnwords.tmp');
  final stagedReport = File(reportFile.path + '.bnwords.tmp');
  _deleteIfExists(stagedDatabase);
  _deleteIfExists(stagedManifest);
  _deleteIfExists(stagedReport);
  databaseFile.copySync(stagedDatabase.path);

  final database = sqlite3.open(stagedDatabase.path);
  late final QuranIntegrityReport integrity;
  try {
    final canonicalLocations = <String>{};
    for (final row in database.select(
      'SELECT surah_number, ayah_number, position FROM quran_words '
      'ORDER BY surah_number, ayah_number, position',
    )) {
      canonicalLocations.add(
        _location(
          row['surah_number'] as int,
          row['ayah_number'] as int,
          row['position'] as int,
        ),
      );
    }
    if (canonicalLocations.length != canonicalQuranWordCount) {
      throw StateError(
        'Bundled database contains ' +
            canonicalLocations.length.toString() +
            ' canonical word locations, expected ' +
            canonicalQuranWordCount.toString() +
            '.',
      );
    }

    final missing = canonicalLocations.difference(meanings.keys.toSet());
    final extra = meanings.keys.toSet().difference(canonicalLocations);
    if (missing.isNotEmpty || extra.isNotEmpty) {
      throw StateError(
        'Bangla word locations do not match canonical Quran words. Missing: ' +
            missing.length.toString() +
            ', extra: ' +
            extra.length.toString() +
            '.',
      );
    }

    database.execute('BEGIN IMMEDIATE');
    try {
      final update = database.prepare(
        'UPDATE quran_words SET bangla_meaning = ? '
        'WHERE surah_number = ? AND ayah_number = ? AND position = ?',
      );
      try {
        for (final entry in meanings.entries) {
          final parts = entry.key.split(':');
          update.execute([
            entry.value,
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          ]);
        }
      } finally {
        update.close();
      }

      final sourceVersion = _sourceVersion(contentVersion);
      _upsertMetadata(database, 'content_version', contentVersion);
      _upsertMetadata(
        database,
        'bangla_word_source_name',
        banglaWordSourceName,
      );
      _upsertMetadata(database, 'bangla_word_source_version', sourceVersion);
      _upsertMetadata(database, 'bangla_word_language', banglaWordLanguage);
      database.execute('COMMIT');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }

    integrity = validateQuranDatabase(database);
    if (!integrity.isValid) {
      throw StateError(
        'Bundled Quran database failed integrity validation after Bangla '
                'word backfill: ' +
            integrity.errors.join('; '),
      );
    }
    database.execute('VACUUM');
  } finally {
    database.close();
  }

  final databaseHash = sha256
      .convert(stagedDatabase.readAsBytesSync())
      .toString();
  final packageManifest = _readObject(manifestFile);
  packageManifest['content_version'] = contentVersion;
  packageManifest['database_sha256'] = databaseHash;
  stagedManifest.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(packageManifest) + '\n',
    flush: true,
  );

  final report = _readObject(reportFile);
  report['content_version'] = contentVersion;
  report['database_sha256'] = databaseHash;
  report['database_size_bytes'] = stagedDatabase.lengthSync();
  final sources = Map<String, dynamic>.from(
    report['sources'] as Map<String, dynamic>,
  );
  sources['bangla_words'] = {
    'name': banglaWordSourceName,
    'version': _sourceVersion(contentVersion),
    'language': banglaWordLanguage,
    'endpoint': 'https://' + apiHost + '/api/v4/verses/by_chapter/{surah}',
  };
  report['sources'] = sources;
  report['integrity'] = integrity.toJson();
  stagedReport.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(report) + '\n',
    flush: true,
  );

  _replace(stagedDatabase, databaseFile);
  _replace(stagedManifest, manifestFile);
  _replace(stagedReport, reportFile);

  stdout.writeln('Bundled Bangla word meanings: ' + meanings.length.toString());
  stdout.writeln('Content version: ' + contentVersion);
  stdout.writeln('Database SHA-256: ' + databaseHash);
}

Future<Map<String, String>> fetchAllBanglaWordMeanings({
  required http.Client client,
  String apiHost = 'api.quran.com',
}) async {
  final meanings = <String, String>{};
  for (var surah = 1; surah <= 114; surah++) {
    stdout.writeln(
      'Fetching Bangla word meanings Surah ' + surah.toString() + '/114...',
    );
    var page = 1;
    while (true) {
      final uri = Uri.https(
        apiHost,
        '/api/v4/verses/by_chapter/' + surah.toString(),
        {
          'words': 'true',
          'language': 'bn',
          'per_page': '50',
          'page': page.toString(),
        },
      );
      final response = await client
          .get(
            uri,
            headers: const {
              HttpHeaders.acceptHeader: 'application/json',
              HttpHeaders.userAgentHeader: 'quran-hifz-content-builder/1',
            },
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw HttpException(
          'Bangla word source returned HTTP ' +
              response.statusCode.toString() +
              ' for Surah ' +
              surah.toString() +
              ' page ' +
              page.toString() +
              '.',
          uri: uri,
        );
      }

      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final verses = body['verses'];
      if (verses is! List || verses.isEmpty) {
        throw FormatException(
          'Bangla word source returned an empty Surah page.',
        );
      }
      for (final rawVerse in verses) {
        if (rawVerse is! Map) {
          throw const FormatException('Invalid verse payload.');
        }
        final verse = Map<String, dynamic>.from(rawVerse);
        final verseKey = verse['verse_key'];
        if (verseKey is! String) {
          throw const FormatException('Verse key is missing.');
        }
        final verseParts = verseKey.split(':');
        if (verseParts.length != 2 ||
            int.tryParse(verseParts[0]) != surah ||
            int.tryParse(verseParts[1]) == null) {
          throw FormatException(
            'Unexpected verse key ' +
                verseKey +
                ' for Surah ' +
                surah.toString(),
          );
        }
        final ayah = int.parse(verseParts[1]);
        final words = verse['words'];
        if (words is! List) {
          throw FormatException('Words are missing for ' + verseKey + '.');
        }
        for (final rawWord in words) {
          if (rawWord is! Map) continue;
          final word = Map<String, dynamic>.from(rawWord);
          if (word['char_type_name'] != 'word') continue;
          final position = word['position'];
          if (position is! int || position < 1) {
            throw FormatException('Invalid word position in ' + verseKey + '.');
          }
          final translation = word['translation'];
          if (translation is! Map) {
            throw FormatException(
              'Bangla translation is missing at ' +
                  _location(surah, ayah, position) +
                  '.',
            );
          }
          final text = translation['text'];
          if (text is! String) {
            throw FormatException(
              'Bangla translation is invalid at ' +
                  _location(surah, ayah, position) +
                  '.',
            );
          }
          final meaning = text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
          if (meaning.isEmpty) {
            throw FormatException(
              'Bangla translation is empty at ' +
                  _location(surah, ayah, position) +
                  '.',
            );
          }
          final location = _location(surah, ayah, position);
          if (meanings.containsKey(location)) {
            throw StateError(
              'Duplicate Bangla word location ' + location + '.',
            );
          }
          meanings[location] = meaning;
        }
      }

      final pagination = body['pagination'];
      if (pagination is! Map) {
        throw const FormatException('Pagination metadata is missing.');
      }
      final nextPage = pagination['next_page'];
      if (nextPage == null) break;
      if (nextPage is! int || nextPage != page + 1) {
        throw const FormatException('Invalid Bangla word pagination.');
      }
      page = nextPage;
    }
  }
  return meanings;
}

void _upsertMetadata(Database db, String key, String value) {
  db.execute(
    'INSERT INTO quran_metadata(metadata_key, metadata_value) VALUES (?, ?) '
    'ON CONFLICT(metadata_key) DO UPDATE SET metadata_value = excluded.metadata_value',
    [key, value],
  );
}

String _sourceVersion(String contentVersion) {
  return 'content-api-v4-public (' + contentVersion + ')';
}

String _location(int surah, int ayah, int position) {
  return [surah, ayah, position].join(':');
}

Map<String, dynamic> _readObject(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map) {
    throw FormatException(file.path + ' must contain a JSON object.');
  }
  return Map<String, dynamic>.from(decoded);
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var index = 0; index < args.length; index++) {
    final key = args[index];
    if (!key.startsWith('--')) {
      throw FormatException('Unexpected argument ' + key + '.');
    }
    if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
      throw FormatException('Missing value for ' + key + '.');
    }
    result[key.substring(2)] = args[++index];
  }
  return result;
}

String _required(String? value, String name) {
  if (value == null || value.trim().isEmpty) {
    throw FormatException(name + ' is required.');
  }
  return value.trim();
}

void _deleteIfExists(File file) {
  if (file.existsSync()) file.deleteSync();
}

void _replace(File staged, File target) {
  final backup = File(target.path + '.before-bnwords');
  _deleteIfExists(backup);
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
