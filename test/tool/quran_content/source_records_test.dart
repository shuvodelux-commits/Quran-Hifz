import 'package:flutter_test/flutter_test.dart';

import '../../../tool/quran_content/models/source_records.dart';

void main() {
  group('normalized Quran source records', () {
    test('keeps verified Tajweed markup when present', () {
      final ayah = AyahSourceRecord.fromJson({
        'surah_number': 1,
        'ayah_number': 1,
        'verse_key': '1:1',
        'arabic_text': 'بِسْمِ',
        'arabic_text_indopak': 'بِسۡمِ',
        'arabic_text_tajweed': '<tajweed class=ham_wasl>ٱ</tajweed>',
        'page_number': 1,
        'juz_number': 1,
      });
      final word = WordSourceRecord.fromJson({
        'surah_number': 1,
        'ayah_number': 1,
        'position': 1,
        'arabic': 'ٱللَّهِ',
        'arabic_indopak': 'اللهِ',
        'arabic_tajweed': '<tajweed class=ham_wasl>ٱ</tajweed>للَّهِ',
      });

      expect(ayah.arabicTextTajweed, contains('ham_wasl'));
      expect(word.arabicTajweed, contains('ham_wasl'));
    });

    test('rejects fractional values for required integer fields', () {
      expect(
        () => SurahSourceRecord.fromJson({
          'number': 1.5,
          'name_arabic': 'الفاتحة',
          'name_english': 'Al-Fatihah',
          'ayah_count': 7,
          'page_start': 1,
          'page_end': 1,
          'juz_start': 1,
        }),
        throwsFormatException,
      );
    });

    test('rejects fractional values for optional integer fields', () {
      expect(
        () => AyahSourceRecord.fromJson({
          'surah_number': 1,
          'ayah_number': 1,
          'verse_key': '1:1',
          'arabic_text': 'بِسْمِ',
          'arabic_text_indopak': 'بِسْمِ',
          'page_number': 1,
          'juz_number': 1,
          'hizb_number': 1.25,
        }),
        throwsFormatException,
      );
    });
  });
}
