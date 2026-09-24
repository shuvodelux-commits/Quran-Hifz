import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('canonical schema v2 stores normalized Mushaf line locations', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);
    db.execute(File('tool/quran_content/schema.sql').readAsStringSync());

    expect(db.select('PRAGMA user_version').single.values.single, 2);
    final columns = db
        .select('PRAGMA table_info(mushaf_lines)')
        .map((row) => row['name'])
        .toSet();
    expect(
      columns,
      containsAll([
        'page_number',
        'line_number',
        'line_type',
        'is_centered',
        'surah_number',
        'first_word_location',
        'last_word_location',
      ]),
    );
  });
}
