import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/dua/data/bundled_dua_repository.dart';
import 'package:quran_hifz/features/dua/domain/dua.dart';
import 'package:quran_hifz/features/dua/domain/dua_search.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('production Dua catalog has 100+ strictly sourced entries', () async {
    final repository = BundledDuaRepository(bundle: rootBundle);

    final duas = await repository.loadAll();
    final categories = await repository.loadCategories();

    expect(duas.length, greaterThanOrEqualTo(100));
    expect(duas.map((dua) => dua.id).toSet().length, duas.length);

    for (final dua in duas) {
      expect(dua.arabic.trim(), isNotEmpty, reason: dua.id);
      expect(dua.banglaPronunciation.trim(), isNotEmpty, reason: dua.id);
      expect(dua.banglaPronunciation.contains('আআ'), isFalse, reason: dua.id);
      expect(dua.banglaPronunciation.contains('্ই'), isFalse, reason: dua.id);
      expect(
        RegExp(r'[()]').hasMatch(dua.banglaPronunciation),
        isFalse,
        reason: dua.id,
      );
      expect(
        dua.banglaPronunciation.contains(String.fromCharCode(96)),
        isFalse,
        reason: dua.id,
      );
      expect(dua.banglaMeaning.trim(), isNotEmpty, reason: dua.id);
      expect(dua.englishTransliteration.trim(), isNotEmpty, reason: dua.id);
      expect(dua.englishTransliteration.contains('AA'), isFalse, reason: dua.id);
      expect(
        dua.englishTransliteration.contains(String.fromCharCode(96)),
        isFalse,
        reason: dua.id,
      );
      expect(dua.englishMeaning.trim(), isNotEmpty, reason: dua.id);
      expect(dua.categoryIds, isNotEmpty, reason: dua.id);
      expect(dua.sources, isNotEmpty, reason: dua.id);

      for (final source in dua.sources) {
        switch (source.type) {
          case DuaSourceType.quran:
            expect(
              source.surahNumber,
              inInclusiveRange(1, 114),
              reason: dua.id,
            );
            expect(source.ayahStart, greaterThan(0), reason: dua.id);
          case DuaSourceType.hadith:
            expect(
              source.grade,
              anyOf(HadithGrade.sahih, HadithGrade.hasan),
              reason: dua.id,
            );
            expect(source.collection, isNotEmpty, reason: dua.id);
            expect(source.reference, isNotEmpty, reason: dua.id);
        }
      }
    }

    final categoryIds = categories.map((category) => category.id).toSet();
    expect(
      categoryIds,
      containsAll(<String>{
        'daily',
        'salah',
        'mosque',
        'morning-evening',
        'protection',
        'food',
        'travel',
        'work-market',
        'family',
        'intimacy',
        'illness',
        'weather',
        'moon',
        'janazah',
        'forgiveness',
        'rizq-debt',
        'quran',
        'munajat',
        'sleep',
      }),
    );

    const categoriesThatMustHaveContent = {
      'daily',
      'salah',
      'mosque',
      'morning-evening',
      'protection',
      'food',
      'travel',
      'work-market',
      'family',
      'intimacy',
      'illness',
      'weather',
      'janazah',
      'forgiveness',
      'rizq-debt',
      'quran',
      'munajat',
      'sleep',
    };
    for (final categoryId in categoriesThatMustHaveContent) {
      expect(
        duas.any((dua) => dua.categoryIds.contains(categoryId)),
        isTrue,
        reason: 'Expected content for $categoryId',
      );
    }

    final daily = dailyDuas(duas);
    expect(daily, isNotEmpty);
    for (var index = 1; index < daily.length; index++) {
      final previous = daily[index - 1];
      final current = daily[index];
      expect(
        previous.dailyOrder! < current.dailyOrder! ||
            (previous.dailyOrder == current.dailyOrder &&
                previous.id.compareTo(current.id) <= 0),
        isTrue,
      );
    }

    final prohibitedClaims = RegExp(
      r'guaranteed|most powerful|100% effective|নিশ্চিত ফল|সবচেয়ে শক্তিশালী',
      caseSensitive: false,
    );
    for (final dua in duas) {
      final text = [
        dua.titleBangla,
        dua.titleEnglish,
        ...dua.tagsBangla,
        ...dua.tagsEnglish,
      ].join(' ');
      expect(prohibitedClaims.hasMatch(text), isFalse, reason: dua.id);
    }
  });
}
