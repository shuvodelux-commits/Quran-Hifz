import 'package:flutter_test/flutter_test.dart';

import '../../../tool/quran_content/source_fetcher.dart';

void main() {
  group('Quran Foundation normalization', () {
    test('builds normalized ayah and word records and skips end markers', () {
      final result = normalizeQuranFoundationDocuments(
        chapters: [
          {
            'id': 1,
            'name_arabic': 'الفاتحة',
            'name_simple': 'Al-Fatihah',
            'revelation_place': 'makkah',
            'verses_count': 1,
          },
        ],
        versesByChapter: {
          1: [
            {
              'chapter_id': 1,
              'verse_number': 1,
              'verse_key': '1:1',
              'text_qpc_hafs': 'بِسۡمِ ٱللَّهِ',
              'text_indopak': 'بِسۡمِ ٱللَّهِ',
              'text_uthmani_tajweed':
                  'بِسْمِ <tajweed class=ham_wasl>ٱ</tajweed>للَّهِ',
              'page_number': 1,
              'juz_number': 1,
              'hizb_number': 1,
              'rub_el_hizb_number': 1,
              'words': [
                {
                  'position': 1,
                  'char_type_name': 'word',
                  'text_qpc_hafs': 'بِسۡمِ',
                  'text_indopak': 'بِسۡمِ',
                  'text_uthmani_tajweed': 'بِسْمِ',
                  'audio_url': 'wbw/001_001_001.mp3',
                  'translation': {
                    'text': 'In (the) name',
                    'language_name': 'english',
                  },
                  'transliteration': {
                    'text': "bis'mi",
                    'language_name': 'english',
                  },
                },
                {
                  'position': 2,
                  'char_type_name': 'word',
                  'text_qpc_hafs': 'ٱللَّهِ',
                  'text_indopak': 'ٱللَّهِ',
                  'text_uthmani_tajweed':
                      '<tajweed class=ham_wasl>ٱ</tajweed>للَّهِ',
                  'audio_url': 'wbw/001_001_002.mp3',
                  'translation': {
                    'text': '(of) Allah',
                    'language_name': 'english',
                  },
                  'transliteration': {
                    'text': 'l-lahi',
                    'language_name': 'english',
                  },
                },
                {
                  'position': 3,
                  'char_type_name': 'end',
                  'text_qpc_hafs': '١',
                  'text_indopak': '١',
                  'audio_url': null,
                  'translation': {'text': ''},
                  'transliteration': {'text': ''},
                },
              ],
            },
          ],
        },
        contentVersion: '2026.09.13',
        sourceVersion: 'content-api-v4-prelive',
      );

      final quran = result.quran;
      final words = result.words;
      final surahs = quran['surahs'] as List<Object?>;
      final ayahs = quran['ayahs'] as List<Object?>;
      final wordRows = words['words'] as List<Object?>;

      expect(surahs, hasLength(1));
      expect(surahs.single, containsPair('page_start', 1));
      expect(ayahs, hasLength(1));
      expect(ayahs.single, containsPair('arabic_text', 'بِسۡمِ ٱللَّهِ'));
      expect(
        ayahs.single,
        containsPair(
          'arabic_text_tajweed',
          'بِسْمِ <tajweed class=ham_wasl>ٱ</tajweed>للَّهِ',
        ),
      );
      expect(wordRows, hasLength(2));
      expect(
        wordRows.first,
        containsPair('audio_remote_path', 'wbw/001_001_001.mp3'),
      );
      expect(wordRows.first, containsPair('arabic_tajweed', 'بِسْمِ'));
      expect(
        wordRows[1],
        containsPair(
          'arabic_tajweed',
          '<tajweed class=ham_wasl>ٱ</tajweed>للَّهِ',
        ),
      );
      expect(wordRows.first, containsPair('transliteration', "bis'mi"));
      expect(wordRows.first, containsPair('english_meaning', 'In (the) name'));
    });

    test('accepts Quran Foundation verses when chapter_id is omitted', () {
      final result = normalizeQuranFoundationDocuments(
        chapters: [
          {
            'id': 2,
            'name_arabic': 'البقرة',
            'name_simple': 'Al-Baqarah',
            'revelation_place': 'madinah',
            'verses_count': 1,
          },
        ],
        versesByChapter: {
          2: [
            {
              'verse_number': 1,
              'verse_key': '2:1',
              'text_qpc_hafs': 'الٓمٓ',
              'text_indopak': 'الٓمٓ',
              'page_number': 2,
              'juz_number': 1,
              'hizb_number': 1,
              'rub_el_hizb_number': 1,
              'words': [
                {
                  'position': 1,
                  'char_type_name': 'word',
                  'text_qpc_hafs': 'الٓمٓ',
                  'text_indopak': 'الٓمٓ',
                  'audio_url': 'wbw/002_001_001.mp3',
                  'translation': {
                    'text': 'Alif Laam Meem',
                    'language_name': 'english',
                  },
                  'transliteration': {
                    'text': 'alif-lam-meem',
                    'language_name': 'english',
                  },
                },
              ],
            },
          ],
        },
        contentVersion: '2026.09.13',
        sourceVersion: 'content-api-v4-prelive',
      );

      final ayahs = result.quran['ayahs'] as List<Object?>;
      expect(ayahs, hasLength(1));
      expect(ayahs.single, containsPair('surah_number', 2));
      expect(ayahs.single, containsPair('ayah_number', 1));
      expect(ayahs.single, containsPair('verse_key', '2:1'));
    });

    test('rejects chapter metadata that disagrees with fetched verses', () {
      expect(
        () => normalizeQuranFoundationDocuments(
          chapters: [
            {
              'id': 1,
              'name_arabic': 'الفاتحة',
              'name_simple': 'Al-Fatihah',
              'revelation_place': 'makkah',
              'verses_count': 2,
            },
          ],
          versesByChapter: {
            1: [
              {
                'chapter_id': 1,
                'verse_number': 1,
                'verse_key': '1:1',
                'text_qpc_hafs': 'بِسۡمِ',
                'text_indopak': 'بِسۡمِ',
                'page_number': 1,
                'juz_number': 1,
                'hizb_number': 1,
                'rub_el_hizb_number': 1,
                'words': [
                  {
                    'position': 1,
                    'char_type_name': 'word',
                    'text_qpc_hafs': 'بِسۡمِ',
                    'text_indopak': 'بِسۡمِ',
                    'audio_url': 'wbw/001_001_001.mp3',
                  },
                ],
              },
            ],
          },
          contentVersion: '2026.09.13',
          sourceVersion: 'content-api-v4-prelive',
        ),
        throwsFormatException,
      );
    });
  });

  group('QuranEnc normalization', () {
    test('keeps Zakaria translation text byte-for-byte', () {
      const translation = 'আল্লাহর নামে, যিনি পরম করুণাময়।';
      final document = normalizeQuranEncTranslationDocument(
        sourceVersion: '1.2.3',
        chapterPayloads: {
          1: [
            {
              'sura': '1',
              'aya': '1',
              'translation': translation,
              'footnotes': '',
            },
          ],
        },
      );

      final rows = document['translations'] as List<Object?>;
      expect(rows, hasLength(1));
      expect(rows.single, containsPair('text', translation));
      expect(document['resource_id'], 1);
      expect(document['language'], 'bn');
    });
  });

  group('QuranEnc client metadata fallback', () {
    test(
      'uses catalog version when list omits Zakaria but Surah API works',
      () async {
        final client = QuranEncClient(
          transport: _FakeJsonTransport((uri) {
            if (uri.path == '/api/v1/translations/list/bn') {
              return const JsonHttpResponse(
                statusCode: 200,
                body: {
                  'translations': [
                    {
                      'key': 'bengali_other',
                      'version': '1.0.0',
                      'last_update': 1600000000,
                    },
                  ],
                },
              );
            }
            if (uri.path == '/api/v1/translation/sura/bengali_zakaria/1') {
              return const JsonHttpResponse(
                statusCode: 200,
                body: {
                  'result': [
                    {
                      'sura': '1',
                      'aya': '1',
                      'translation': 'test',
                      'footnotes': '',
                    },
                  ],
                },
              );
            }
            throw StateError('Unexpected URI: $uri');
          }),
          baseUri: Uri.parse('https://quranenc.example'),
        );

        expect(
          await client.fetchZakariaSourceVersion(),
          '1.1.1 (catalog 2021-05-22)',
        );
      },
    );
  });

  group('canonical chapter catalog', () {
    test('rejects an incomplete Quran Foundation chapter list immediately', () {
      expect(
        () => validateCanonicalChapterCatalog([
          {'id': 1},
          {'id': 2},
        ]),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('requires all 114'),
          ),
        ),
      );
    });
  });

  group('canonical source validation', () {
    test('requires translation coverage for every fetched ayah', () {
      expect(
        () => validateNormalizedSourceCoverage(
          quran: {
            'surahs': [
              {'number': 1, 'ayah_count': 2},
            ],
            'ayahs': [
              {'surah_number': 1, 'ayah_number': 1},
              {'surah_number': 1, 'ayah_number': 2},
            ],
          },
          words: {
            'words': [
              {'surah_number': 1, 'ayah_number': 1},
              {'surah_number': 1, 'ayah_number': 2},
            ],
          },
          translation: {
            'translations': [
              {'surah_number': 1, 'ayah_number': 1},
            ],
          },
          requireCanonicalQuran: false,
        ),
        throwsStateError,
      );
    });

    test('normalizer preserves IndoPak and Uthmani word text', () {
      final normalized = normalizeQuranFoundationDocuments(
        chapters: [
          {
            'id': 1,
            'verses_count': 1,
            'name_arabic': 'الفاتحة',
            'name_simple': 'Al-Fatihah',
          },
        ],
        versesByChapter: {
          1: [
            {
              'chapter_id': 1,
              'verse_number': 1,
              'verse_key': '1:1',
              'page_number': 1,
              'juz_number': 1,
              'text_qpc_hafs': 'UTHMANI AYAH',
              'text_indopak': 'INDOPAK AYAH',
              'words': [
                {
                  'char_type_name': 'word',
                  'position': 1,
                  'text_qpc_hafs': 'UTHMANI WORD',
                  'text_indopak': 'INDOPAK WORD',
                },
              ],
            },
          ],
        },
        contentVersion: 'test',
        sourceVersion: 'test',
      );

      final ayah = (normalized.quran['ayahs'] as List).single as Map;
      final word = (normalized.words['words'] as List).single as Map;
      expect(ayah['arabic_text'], 'UTHMANI AYAH');
      expect(ayah['arabic_text_indopak'], 'INDOPAK AYAH');
      expect(word['arabic'], 'UTHMANI WORD');
      expect(word['arabic_indopak'], 'INDOPAK WORD');
    });
  });
}

class _FakeJsonTransport implements JsonTransport {
  _FakeJsonTransport(this.handler);

  final JsonHttpResponse Function(Uri uri) handler;

  @override
  Future<JsonHttpResponse> send({
    required String method,
    required Uri uri,
    Map<String, String> headers = const {},
    Map<String, String>? formFields,
    String? basicUsername,
    String? basicPassword,
  }) async {
    return handler(uri);
  }
}
