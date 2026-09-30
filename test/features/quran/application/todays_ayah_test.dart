import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/application/todays_ayah.dart';
import 'package:quran_hifz/features/quran/data/demo_quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_translation_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_translation_source.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test(
    'selectTodaysAyah returns the same locally stored ayah all day',
    () async {
      final repository = DemoQuranRepository();

      final morning = await selectTodaysAyah(
        repository: repository,
        date: DateTime(2026, 9, 17, 8),
        translationResourceId: 1,
      );
      final evening = await selectTodaysAyah(
        repository: repository,
        date: DateTime(2026, 9, 17, 20),
        translationResourceId: 1,
      );

      expect(morning, isNotNull);
      expect(morning!.key, evening!.key);
      expect(morning.translation, isNotEmpty);
    },
  );

  test(
    'English UI uses an installed English translation for today’s ayah',
    () async {
      const ayah = QuranAyah(
        surahNumber: 2,
        ayahNumber: 255,
        words: [],
        arabicText: 'الله لا إله إلا هو',
        translation: 'বাংলা অনুবাদ',
      );
      final localized = await localizeTodaysAyah(
        ayah: ayah,
        translationRepository: _FakeTranslationRepository(),
        language: AppLanguage.english,
      );

      expect(localized?.translation, 'English translation');
      expect(localized?.arabicText, ayah.arabicText);
    },
  );

  test('Bangla UI keeps the bundled Bangla translation', () async {
    const ayah = QuranAyah(
      surahNumber: 1,
      ayahNumber: 1,
      words: [],
      arabicText: 'بسم الله',
      translation: 'বাংলা অনুবাদ',
    );
    final localized = await localizeTodaysAyah(
      ayah: ayah,
      translationRepository: _FakeTranslationRepository(),
      language: AppLanguage.bangla,
    );

    expect(localized?.translation, 'বাংলা অনুবাদ');
  });
}

class _FakeTranslationRepository implements QuranTranslationRepository {
  @override
  Future<List<QuranTranslationSource>> listInstalledSources() async => const [
    QuranTranslationSource(
      sourceId: 'qf.translation.20',
      resourceId: 20,
      name: 'Sahih International',
      language: 'english',
      version: 'test',
      kind: QuranTranslationSourceKind.downloaded,
    ),
  ];

  @override
  Future<QuranTranslationEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async => QuranTranslationEntry(
    sourceId: sourceId,
    sourceName: 'Sahih International',
    language: 'english',
    surahNumber: surahNumber,
    ayahNumber: ayahNumber,
    text: 'English translation',
  );
}
