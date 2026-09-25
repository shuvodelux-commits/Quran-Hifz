import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('production bundled content is complete and offline-ready', () {
    final tafsirRoot = Directory('assets/tafsir/zakaria/1.1.1');
    final tafsirManifest =
        jsonDecode(File('${tafsirRoot.path}/manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    final surahs = tafsirManifest['surahs'] as Map<String, dynamic>;

    expect(tafsirManifest['source_id'], 'bn.abubakar_zakaria.quranenc');
    expect(tafsirManifest['total_entries'], 6236);
    expect(tafsirManifest['surah_count'], 114);
    expect(surahs.length, 114);
    for (var surah = 1; surah <= 114; surah++) {
      final metadata = surahs['$surah'] as Map<String, dynamic>;
      expect(
        File('${tafsirRoot.path}/${metadata['asset']}').existsSync(),
        isTrue,
        reason: 'Missing bundled Zakaria Surah $surah',
      );
    }

    final dbFile = File('assets/database/quran_content.sqlite');
    final db = sqlite3.open(dbFile.path, mode: OpenMode.readOnly);
    addTearDown(db.close);

    expect(db.select('SELECT COUNT(*) AS c FROM surahs').single['c'], 114);
    expect(db.select('SELECT COUNT(*) AS c FROM ayahs').single['c'], 6236);
    expect(
      db.select('SELECT COUNT(*) AS c FROM quran_words').single['c'],
      77429,
    );
    expect(
      db
          .select(
            "SELECT COUNT(*) AS c FROM quran_words "
            "WHERE TRIM(COALESCE(bangla_meaning, '')) = ''",
          )
          .single['c'],
      0,
    );

    final packageManifest =
        jsonDecode(
              File(
                'assets/database/quran_content_manifest.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final contentVersion =
        db
                .select(
                  "SELECT metadata_value FROM quran_metadata "
                  "WHERE metadata_key = 'content_version'",
                )
                .single['metadata_value']
            as String;
    expect(packageManifest['content_version'], contentVersion);
    expect(
      packageManifest['database_sha256'],
      sha256.convert(dbFile.readAsBytesSync()).toString(),
    );

    final report =
        jsonDecode(
              File(
                'assets/database/quran_content.sqlite.report.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(report['database_sha256'], packageManifest['database_sha256']);
    expect(
      (report['sources'] as Map<String, dynamic>)['bangla_words'],
      isNotNull,
    );
    expect(((report['integrity'] as Map<String, dynamic>)['valid']), isTrue);
  });
}
