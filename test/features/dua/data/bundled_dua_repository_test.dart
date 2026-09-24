import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/dua/data/bundled_dua_repository.dart';
import 'package:quran_hifz/features/dua/domain/dua.dart';

void main() {
  test('parses Quran and Hasan hadith source metadata', () async {
    final repository = _repository(
      _catalog([
        _dua(
          id: 'quran-rabbana',
          sources: [
            {
              'type': 'quran',
              'surah_number': 2,
              'ayah_start': 201,
              'ayah_end': 201,
            },
          ],
        ),
        _dua(
          id: 'waking-up',
          sources: [
            {
              'type': 'hadith',
              'collection': 'Jami at-Tirmidhi',
              'reference': '3391',
              'grade': 'hasan',
              'grading_authority': 'At-Tirmidhi',
            },
          ],
        ),
      ]),
    );

    final duas = await repository.loadAll();

    expect(duas, hasLength(2));
    expect(duas.first.sources.single.type, DuaSourceType.quran);
    expect(duas.first.sources.single.surahNumber, 2);
    expect(duas.first.sources.single.ayahStart, 201);
    expect(duas.last.sources.single.type, DuaSourceType.hadith);
    expect(duas.last.sources.single.grade, HadithGrade.hasan);
    expect(duas.last.sources.single.gradingAuthority, 'At-Tirmidhi');
  });

  test('rejects duplicate dua ids', () async {
    final repository = _repository(
      _catalog([_dua(id: 'same'), _dua(id: 'same')]),
    );

    await expectLater(repository.loadAll(), throwsFormatException);
  });

  test('rejects a missing required localized or source field', () async {
    final invalid = _dua(id: 'missing-arabic')..remove('arabic');
    final repository = _repository(_catalog([invalid]));

    await expectLater(repository.loadAll(), throwsFormatException);
  });

  test('rejects hadith grades outside Sahih and Hasan', () async {
    final repository = _repository(
      _catalog([
        _dua(
          id: 'weak-entry',
          sources: [
            {
              'type': 'hadith',
              'collection': 'Example',
              'reference': '1',
              'grade': 'daif',
            },
          ],
        ),
      ]),
    );

    await expectLater(repository.loadAll(), throwsFormatException);
  });

  test('rejects unknown category references', () async {
    final row = _dua(id: 'unknown-category')..['category_ids'] = ['missing'];
    final repository = _repository(_catalog([row]));

    await expectLater(repository.loadAll(), throwsFormatException);
  });

  test('rejects malformed JSON', () async {
    final repository = BundledDuaRepository(
      bundle: _MapAssetBundle({
        BundledDuaRepository.defaultAssetPath: '{bad-json',
      }),
    );

    await expectLater(repository.loadAll(), throwsFormatException);
  });

  test('rejects the whole catalog when any record is invalid', () async {
    final invalid = _dua(id: 'invalid')..['meaning_en'] = '   ';
    final repository = _repository(_catalog([_dua(id: 'valid'), invalid]));

    await expectLater(repository.loadAll(), throwsFormatException);
  });

  test('rejects invalid Quran source bounds', () async {
    final repository = _repository(
      _catalog([
        _dua(
          id: 'invalid-quran',
          sources: [
            {'type': 'quran', 'surah_number': 115, 'ayah_start': 0},
          ],
        ),
      ]),
    );

    await expectLater(repository.loadAll(), throwsFormatException);
  });

  test('retries asset loading after a transient failure', () async {
    final bundle = _FlakyAssetBundle(
      jsonEncode(_catalog([_dua(id: 'retry-success')])),
    );
    final repository = BundledDuaRepository(bundle: bundle);

    await expectLater(repository.loadAll(), throwsFlutterError);
    final duas = await repository.loadAll();

    expect(duas.single.id, 'retry-success');
    expect(bundle.loadCount, 2);
  });

  test('returns an unmodifiable catalog', () async {
    final repository = _repository(_catalog([_dua(id: 'immutable')]));

    final duas = await repository.loadAll();

    expect(() => duas.add(duas.single), throwsUnsupportedError);
  });
}

BundledDuaRepository _repository(Map<String, Object?> catalog) {
  return BundledDuaRepository(
    bundle: _MapAssetBundle({
      BundledDuaRepository.defaultAssetPath: jsonEncode(catalog),
    }),
  );
}

Map<String, Object?> _catalog(List<Map<String, Object?>> duas) => {
  'schema_version': 1,
  'categories': [
    {'id': 'daily', 'bn': 'দৈনন্দিন', 'en': 'Daily Routine'},
  ],
  'duas': duas,
};

Map<String, Object?> _dua({
  required String id,
  List<Map<String, Object?>>? sources,
}) => {
  'id': id,
  'title_bn': 'পরীক্ষার দোয়া',
  'title_en': 'Test dua',
  'arabic': 'رَبَّنَا',
  'pronunciation_bn': 'রব্বানা',
  'meaning_bn': 'হে আমাদের রব',
  'transliteration_en': 'Rabbana',
  'meaning_en': 'Our Lord',
  'category_ids': ['daily'],
  'tags_bn': ['পরীক্ষা'],
  'tags_en': ['test'],
  'daily_order': 10,
  'sources':
      sources ??
      [
        {
          'type': 'hadith',
          'collection': 'Sahih al-Bukhari',
          'reference': '6324',
          'grade': 'sahih',
        },
      ],
};

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) throw FlutterError('Missing fake asset: $key');
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.sublistView(bytes);
  }
}

class _FlakyAssetBundle extends CachingAssetBundle {
  _FlakyAssetBundle(this.asset);

  final String asset;
  int loadCount = 0;

  @override
  Future<ByteData> load(String key) async {
    loadCount++;
    if (loadCount == 1) throw FlutterError('Transient fake asset failure');
    final bytes = Uint8List.fromList(utf8.encode(asset));
    return ByteData.sublistView(bytes);
  }
}
