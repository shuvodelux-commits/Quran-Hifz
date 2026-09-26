import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pubspec registers only the approved Quran font families', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final families = RegExp(
      r'^\s+- family:\s*(.+)$',
      multiLine: true,
    ).allMatches(pubspec).map((match) => match.group(1)!.trim()).toList();

    expect(families, [
      'Inter',
      'SolaimanLipi',
      'QPC Hafs',
      'IndoPak Nastaleeq',
      'SurahNameV4',
      'QPC V4 Tajweed P1',
    ]);

    for (final requiredAsset in const [
      'assets/fonts/UthmanicHafs1Ver18.ttf',
      'assets/fonts/indopak-nastaleeq-waqf-lazim-v4.2.1.ttf',
      'assets/fonts/surah-name-v4.ttf',
      'assets/fonts/qpc-v4-tajweed-p1.ttf',
    ]) {
      expect(pubspec, contains(requiredAsset), reason: requiredAsset);
    }
    for (final legacyAsset in const [
      'assets/fonts/PDMS-Saleem-QuranFont.ttf',
      'assets/fonts/Indopak-Nastaleeq.ttf',
      'assets/fonts/DigitalKhattIndoPak.otf',
      'assets/fonts/Al-Qalam-Quran-Majeed.ttf',
      'assets/fonts/Muhammadi-Quran.ttf',
      'assets/fonts/NotoNaskhArabic.ttf',
      'assets/fonts/KFGQPC-Uthmanic-Script-HAFS-Regular.otf',
    ]) {
      expect(pubspec, isNot(contains(legacyAsset)), reason: legacyAsset);
    }
  });

  test('product code does not reference deleted Quran font families', () {
    final legacyFamilies = <String>[
      'PDMS Saleem Quran',
      'AlQalam',
      'Muhammadi Quran',
      'Noto Naskh Arabic',
      'DigitalKhatt IndoPak',
      'KFGQPC Hafs Uthmanic',
    ];
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      for (final family in legacyFamilies) {
        expect(
          source,
          isNot(contains(family)),
          reason: '${file.path} still references $family',
        );
      }
    }
  });
}
