import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua_search.dart';
import 'package:quran_hifz/features/dua/domain/dua.dart';
import 'package:quran_hifz/features/dua/domain/dua_entry.dart';

void main() {
  test('custom search matches title Arabic transliteration meaning and reference', () {
    final duas = [
      _custom(id: 'custom:title', title: 'Morning protection'),
      _custom(id: 'custom:arabic', arabic: 'اللهم بارك لي'),
      _custom(id: 'custom:translit', transliteration: 'Allahumma barik li'),
      _custom(id: 'custom:meaning', meaning: 'Bless me in what You gave'),
      _custom(id: 'custom:reference', reference: 'Notebook ১২৩'),
    ];

    expect(_ids(filterCustomDuas(duas: duas, query: 'morning')), ['custom:title']);
    expect(_ids(filterCustomDuas(duas: duas, query: 'اللهم بارك')), ['custom:arabic']);
    expect(_ids(filterCustomDuas(duas: duas, query: 'barik')), ['custom:translit']);
    expect(_ids(filterCustomDuas(duas: duas, query: 'bless me')), ['custom:meaning']);
    expect(_ids(filterCustomDuas(duas: duas, query: '123')), ['custom:reference']);
  });

  test('empty custom query preserves repository order', () {
    final duas = [
      _custom(id: 'custom:first'),
      _custom(id: 'custom:second'),
    ];

    expect(_ids(filterCustomDuas(duas: duas, query: '  ')), [
      'custom:first',
      'custom:second',
    ]);
  });

  test('dua entry wrapper exposes stable id without flattening verified metadata', () {
    final verified = Dua(
      id: 'verified',
      titleBangla: 'শিরোনাম',
      titleEnglish: 'Title',
      arabic: 'دعاء',
      banglaPronunciation: 'দুয়া',
      banglaMeaning: 'অর্থ',
      englishTransliteration: 'Dua',
      englishMeaning: 'Meaning',
      categoryIds: const ['daily'],
      tagsBangla: const [],
      tagsEnglish: const [],
      sources: const [
        DuaSource(
          type: DuaSourceType.hadith,
          collection: 'Test',
          reference: '1',
          grade: HadithGrade.sahih,
        ),
      ],
    );
    final custom = _custom(id: 'custom:entry');

    final verifiedEntry = VerifiedDuaEntry(verified);
    final customEntry = CustomDuaEntry(custom);

    expect(verifiedEntry.id, 'verified');
    expect(verifiedEntry.dua.sources.single.grade, HadithGrade.sahih);
    expect(customEntry.id, 'custom:entry');
    expect(customEntry.dua.reference, 'Reference');
  });
}

List<String> _ids(List<CustomDua> values) =>
    values.map((dua) => dua.id).toList();

CustomDua _custom({
  required String id,
  String title = 'Title',
  String arabic = 'دعاء',
  String transliteration = 'Dua',
  String meaning = 'Meaning',
  String reference = 'Reference',
}) => CustomDua(
  id: id,
  title: title,
  arabic: arabic,
  transliteration: transliteration,
  meaning: meaning,
  reference: reference,
  createdAt: DateTime.utc(2026, 9, 24),
  updatedAt: DateTime.utc(2026, 9, 24),
);
