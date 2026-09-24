import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/dua/domain/dua.dart';
import 'package:quran_hifz/features/dua/domain/dua_search.dart';

void main() {
  const categories = [
    DuaCategory(id: 'daily', banglaLabel: 'দৈনন্দিন', englishLabel: 'Daily'),
    DuaCategory(id: 'sleep', banglaLabel: 'ঘুম', englishLabel: 'Sleep'),
  ];

  final duas = [
    _dua(
      id: 'wake',
      titleBn: 'ঘুম থেকে ওঠার দোয়া',
      titleEn: 'Upon waking',
      pronunciationBn: 'আলহামদু লিল্লাহিল্লাযী',
      transliterationEn: 'Alhamdu lillahil-ladhi',
      meaningBn: 'যিনি আমাদের জীবিত করেছেন',
      meaningEn: 'Who gave us life',
      categories: const ['daily'],
      tagsBn: const ['সকাল'],
      tagsEn: const ['morning'],
      dailyOrder: 20,
    ),
    _dua(
      id: 'sleep',
      titleBn: 'ঘুমানোর দোয়া',
      titleEn: 'Before sleeping',
      pronunciationBn: 'বিসমিকা আল্লাহুম্মা',
      transliterationEn: 'Bismika Allahumma',
      meaningBn: 'আপনার নামেই আমি মরি ও বাঁচি',
      meaningEn: 'In Your name I die and live',
      categories: const ['sleep'],
      tagsBn: const ['রাত'],
      tagsEn: const ['night'],
      dailyOrder: 90,
    ),
    _dua(
      id: 'wake-short',
      titleBn: 'ঘুম দোয়া',
      titleEn: 'Wake',
      pronunciationBn: 'রব্বানা',
      transliterationEn: 'Rabbana',
      meaningBn: 'আরেকটি অর্থ',
      meaningEn: 'Another meaning',
      categories: const ['daily'],
      tagsBn: const ['সকাল'],
      tagsEn: const ['morning'],
      dailyOrder: 20,
    ),
    _dua(
      id: 'other',
      titleBn: 'সফরের দোয়া',
      titleEn: 'Travel dua',
      pronunciationBn: 'সুবহানাল্লাযী',
      transliterationEn: 'Subhanalladhi',
      meaningBn: 'যিনি এটিকে বশীভূত করেছেন',
      meaningEn: 'Who subjected this',
      categories: const ['daily'],
      tagsBn: const ['১২৩'],
      tagsEn: const ['123'],
    ),
  ];

  test('normalizes Bangla and ASCII digits equivalently', () {
    expect(normalizeDuaQuery('  ১২৩! '), '123');
    expect(normalizeDuaQuery('123'), '123');
  });

  test('searches Bangla title and meaning', () {
    expect(
      _ids(filterDuas(duas: duas, categories: categories, query: 'ঘুমানোর')),
      ['sleep'],
    );
    expect(
      _ids(filterDuas(duas: duas, categories: categories, query: 'জীবিত')),
      ['wake'],
    );
  });

  test('searches Bangla pronunciation', () {
    expect(
      _ids(filterDuas(duas: duas, categories: categories, query: 'আলহামদু')),
      ['wake'],
    );
  });

  test('searches English title meaning and transliteration', () {
    expect(
      _ids(filterDuas(duas: duas, categories: categories, query: 'travel')),
      ['other'],
    );
    expect(
      _ids(
        filterDuas(duas: duas, categories: categories, query: 'gave us life'),
      ),
      ['wake'],
    );
    expect(
      _ids(filterDuas(duas: duas, categories: categories, query: 'bismika')),
      ['sleep'],
    );
  });

  test('punctuation-only query preserves catalog order', () {
    expect(
      _ids(
        filterDuas(
          duas: duas,
          categories: categories,
          query: '... --- ، ؛ ؟ ۔ ।',
        ),
      ),
      ['wake', 'sleep', 'wake-short', 'other'],
    );
  });

  test('category filter composes with text search', () {
    expect(
      _ids(
        filterDuas(
          duas: duas,
          categories: categories,
          query: 'ঘুম',
          categoryId: 'daily',
        ),
      ),
      ['wake', 'wake-short'],
    );
  });

  test('favorites-only ignores orphan stored ids', () {
    expect(
      _ids(
        filterDuas(
          duas: duas,
          categories: categories,
          query: '',
          favoriteIds: const {'sleep', 'missing-id'},
          favoritesOnly: true,
        ),
      ),
      ['sleep'],
    );
  });

  test('exact title ranks before prefix and substring matches', () {
    final rankingDuas = [
      _dua(id: 'substring', titleEn: 'My morning wake prayer'),
      _dua(id: 'exact', titleEn: 'Wake'),
      _dua(id: 'prefix', titleEn: 'Wake up'),
    ];

    expect(
      _ids(
        filterDuas(duas: rankingDuas, categories: categories, query: 'wake'),
      ),
      ['exact', 'prefix', 'substring'],
    );
  });

  test('searches localized category labels and tags with digit folding', () {
    expect(
      _ids(filterDuas(duas: duas, categories: categories, query: 'Sleep')),
      ['sleep'],
    );
    expect(_ids(filterDuas(duas: duas, categories: categories, query: '১২৩')), [
      'other',
    ]);
  });

  test('daily duas are sorted by order then id and omit unordered entries', () {
    expect(_ids(dailyDuas(duas)), ['wake', 'wake-short', 'sleep']);
  });
}

List<String> _ids(List<Dua> values) => values.map((dua) => dua.id).toList();

Dua _dua({
  required String id,
  String titleBn = 'দোয়া',
  String titleEn = 'Dua',
  String pronunciationBn = 'রব্বানা',
  String transliterationEn = 'Rabbana',
  String meaningBn = 'অর্থ',
  String meaningEn = 'Meaning',
  List<String> categories = const ['daily'],
  List<String> tagsBn = const [],
  List<String> tagsEn = const [],
  int? dailyOrder,
}) {
  return Dua(
    id: id,
    titleBangla: titleBn,
    titleEnglish: titleEn,
    arabic: 'رَبَّنَا',
    banglaPronunciation: pronunciationBn,
    banglaMeaning: meaningBn,
    englishTransliteration: transliterationEn,
    englishMeaning: meaningEn,
    categoryIds: categories,
    tagsBangla: tagsBn,
    tagsEnglish: tagsEn,
    sources: const [
      DuaSource(
        type: DuaSourceType.hadith,
        collection: 'Sahih al-Bukhari',
        reference: '1',
        grade: HadithGrade.sahih,
      ),
    ],
    dailyOrder: dailyOrder,
  );
}
