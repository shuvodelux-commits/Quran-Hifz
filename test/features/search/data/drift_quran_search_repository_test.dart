import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/quran_content_database.dart';
import 'package:quran_hifz/features/search/data/drift_quran_search_repository.dart';
import 'package:quran_hifz/features/search/domain/quran_search_result.dart';

void main() {
  late QuranContentDatabase database;
  late DriftQuranSearchRepository repository;

  setUp(() async {
    database = QuranContentDatabase.forTesting(NativeDatabase.memory());
    repository = DriftQuranSearchRepository(database);

    await database
        .into(database.surahs)
        .insert(
          SurahsCompanion.insert(
            number: const Value(1),
            nameArabic: 'الفاتحة',
            nameEnglish: 'Al-Fatihah',
            nameBangla: const Value('আল-ফাতিহা'),
            ayahCount: 7,
            pageStart: 1,
            pageEnd: 1,
            juzStart: 1,
          ),
        );
    await database
        .into(database.surahs)
        .insert(
          SurahsCompanion.insert(
            number: const Value(2),
            nameArabic: 'البقرة',
            nameEnglish: 'Al-Baqarah',
            nameBangla: const Value('আল-বাকারা'),
            ayahCount: 286,
            pageStart: 2,
            pageEnd: 49,
            juzStart: 1,
          ),
        );
    await database
        .into(database.ayahs)
        .insert(
          AyahsCompanion.insert(
            surahNumber: 2,
            ayahNumber: 255,
            verseKey: '2:255',
            arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
            arabicTextIndopak: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
            pageNumber: 42,
            juzNumber: 3,
          ),
        );
    await database
        .into(database.ayahs)
        .insert(
          AyahsCompanion.insert(
            surahNumber: 2,
            ayahNumber: 256,
            verseKey: '2:256',
            arabicText: 'لَا إِكْرَاهَ فِي الدِّينِ',
            arabicTextIndopak: 'لَا إِكْرَاهَ فِي الدِّينِ',
            pageNumber: 42,
            juzNumber: 3,
          ),
        );
    await database
        .into(database.translations)
        .insert(
          TranslationsCompanion.insert(
            resourceId: 1,
            surahNumber: 2,
            ayahNumber: 255,
            language: 'bn',
            textValue: 'আল্লাহ, তিনি ছাড়া কোনো উপাস্য নেই।',
          ),
        );
    await database
        .into(database.translations)
        .insert(
          TranslationsCompanion.insert(
            resourceId: 1,
            surahNumber: 2,
            ayahNumber: 256,
            language: 'bn',
            textValue: 'দ্বীনের ব্যাপারে কোনো জবরদস্তি নেই।',
          ),
        );
  });

  tearDown(() => database.close());

  test('exact verse reference returns one navigable ayah result', () async {
    final results = await repository.search('2:255', translationResourceId: 1);

    expect(results, hasLength(1));
    expect(results.single.type, QuranSearchResultType.ayah);
    expect(results.single.surahNumber, 2);
    expect(results.single.ayahNumber, 255);
    expect(results.single.pageNumber, 42);
    expect(results.single.verseKey, '2:255');
  });

  test('Surah number and names resolve locally', () async {
    final byNumber = await repository.search('2', translationResourceId: 1);
    final byEnglish = await repository.search(
      'baqarah',
      translationResourceId: 1,
    );
    final byBangla = await repository.search(
      'বাকারা',
      translationResourceId: 1,
    );

    for (final results in [byNumber, byEnglish, byBangla]) {
      expect(results.first.type, QuranSearchResultType.surah);
      expect(results.first.surahNumber, 2);
      expect(results.first.pageNumber, 2);
    }
  });

  test(
    'Bangla translation phrase returns matching ayah without network',
    () async {
      final results = await repository.search(
        'জবরদস্তি',
        translationResourceId: 1,
      );

      expect(results, hasLength(1));
      expect(results.single.verseKey, '2:256');
      expect(results.single.matchText, contains('জবরদস্তি'));
    },
  );

  test('empty query returns no results', () async {
    expect(await repository.search('   ', translationResourceId: 1), isEmpty);
  });
}
