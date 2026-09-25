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

    test('keeps Bangla word source provenance on the word bundle', () {
      final bundle = WordSourceBundle.fromJson({
        'source_name': 'Canonical word source',
        'source_version': 'v1',
        'bangla_word_source_name': 'Bangla word source',
        'bangla_word_source_version': 'bn-v2',
        'bangla_word_language': 'bn',
        'words': [
          {
            'surah_number': 1,
            'ayah_number': 1,
            'position': 1,
            'arabic': 'بِسْمِ',
            'arabic_indopak': 'بِسْمِ',
            'bangla_meaning': 'নামে',
          },
        ],
      });

      expect(bundle.banglaWordSourceName, 'Bangla word source');
      expect(bundle.banglaWordSourceVersion, 'bn-v2');
      expect(bundle.banglaWordLanguage, 'bn');
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
