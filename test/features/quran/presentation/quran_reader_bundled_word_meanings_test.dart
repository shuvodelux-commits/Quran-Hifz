import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quran reader has no first-use Bangla word download flow', () {
    final source = File(
      'lib/features/quran/presentation/quran_reader_page.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('বাংলা word download')));
    expect(source, isNot(contains('_downloadBanglaWords')));
    expect(source, isNot(contains('_refreshWordDownloadStatus')));
    expect(source, isNot(contains('_wordDownloadActive')));
  });
}
