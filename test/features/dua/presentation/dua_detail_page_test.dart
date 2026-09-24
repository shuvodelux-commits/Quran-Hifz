import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/features/dua/domain/dua.dart';
import 'package:quran_hifz/features/dua/presentation/dua_detail_page.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets(
    'Bangla detail follows Arabic pronunciation meaning source order',
    (tester) async {
      await _pump(tester, AppLanguage.bangla, _hadithDua);

      expect(find.text('বাংলা উচ্চারণ'), findsOneWidget);
      expect(find.text(_hadithDua.banglaPronunciation), findsOneWidget);
      expect(find.text('বাংলা অর্থ'), findsOneWidget);
      expect(find.text(_hadithDua.banglaMeaning), findsOneWidget);
      expect(find.textContaining('Sahih al-Bukhari'), findsOneWidget);
      expect(find.textContaining('সহিহ'), findsOneWidget);

      final arabicY = tester.getTopLeft(find.text(_hadithDua.arabic)).dy;
      final pronunciationY = tester.getTopLeft(find.text('বাংলা উচ্চারণ')).dy;
      final meaningY = tester.getTopLeft(find.text('বাংলা অর্থ')).dy;
      final sourceY = tester
          .getTopLeft(find.byKey(const ValueKey('dua-source-section')))
          .dy;
      expect(arabicY, lessThan(pronunciationY));
      expect(pronunciationY, lessThan(meaningY));
      expect(meaningY, lessThan(sourceY));
    },
  );

  testWidgets(
    'English detail shows transliteration meaning and Quran reference',
    (tester) async {
      await _pump(tester, AppLanguage.english, _quranDua);

      expect(find.text('Transliteration'), findsOneWidget);
      expect(find.text(_quranDua.englishTransliteration), findsOneWidget);
      expect(find.text('Meaning'), findsOneWidget);
      expect(find.text(_quranDua.englishMeaning), findsOneWidget);
      expect(find.textContaining("Qur'an 2:201"), findsOneWidget);
    },
  );

  testWidgets('Arabic block is RTL and long content scrolls without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pump(
      tester,
      AppLanguage.english,
      Dua(
        id: _quranDua.id,
        titleBangla: _quranDua.titleBangla,
        titleEnglish: _quranDua.titleEnglish,
        arabic: List.filled(12, _quranDua.arabic).join(' '),
        banglaPronunciation: _quranDua.banglaPronunciation,
        banglaMeaning: _quranDua.banglaMeaning,
        englishTransliteration: List.filled(
          8,
          _quranDua.englishTransliteration,
        ).join(' '),
        englishMeaning: List.filled(8, _quranDua.englishMeaning).join(' '),
        categoryIds: _quranDua.categoryIds,
        tagsBangla: _quranDua.tagsBangla,
        tagsEnglish: _quranDua.tagsEnglish,
        sources: _quranDua.sources,
      ),
      textScaler: const TextScaler.linear(1.3),
    );

    final directionality = tester.widget<Directionality>(
      find.byKey(const ValueKey('dua-arabic-block')),
    );
    expect(directionality.textDirection, TextDirection.rtl);
    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('source metadata uses theme variant text color', (tester) async {
    final theme = appTheme(
      AppThemePreference.green,
      language: AppLanguage.english,
    );
    await _pump(
      tester,
      AppLanguage.english,
      _hadithDua,
      theme: AppThemePreference.green,
    );

    final metadata = tester.widget<Text>(
      find.byKey(const ValueKey('dua-source-primary')),
    );
    expect(metadata.style?.color, theme.colorScheme.onSurfaceVariant);
  });
}

Future<void> _pump(
  WidgetTester tester,
  AppLanguage language,
  Dua dua, {
  AppThemePreference theme = AppThemePreference.light,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appLanguageProvider.overrideWithValue(language)],
      child: MaterialApp(
        theme: appTheme(theme, language: language),
        home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: DuaDetailPage(dua: dua),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

const _quranDua = Dua(
  id: 'quran',
  titleBangla: 'রব্বানা আতিনা',
  titleEnglish: 'Our Lord, grant us good',
  arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
  banglaPronunciation: 'রব্বানা আতিনা ফিদ্দুনইয়া হাসানাহ',
  banglaMeaning: 'হে আমাদের রব, দুনিয়াতে আমাদের কল্যাণ দিন।',
  englishTransliteration: 'Rabbana atina fid-dunya hasanah',
  englishMeaning: 'Our Lord, grant us good in this world.',
  categoryIds: ['quran'],
  tagsBangla: [],
  tagsEnglish: [],
  sources: [
    DuaSource(
      type: DuaSourceType.quran,
      surahNumber: 2,
      ayahStart: 201,
      ayahEnd: 201,
    ),
  ],
);

const _hadithDua = Dua(
  id: 'hadith',
  titleBangla: 'ঘুম থেকে ওঠার দোয়া',
  titleEnglish: 'Upon waking',
  arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا',
  banglaPronunciation: 'আলহামদু লিল্লাহিল্লাযী আহইয়ানা',
  banglaMeaning: 'সমস্ত প্রশংসা আল্লাহর, যিনি আমাদের জীবন দিয়েছেন।',
  englishTransliteration: 'Alhamdu lillahil-ladhi ahyana',
  englishMeaning: 'Praise is for Allah who gave us life.',
  categoryIds: ['daily'],
  tagsBangla: [],
  tagsEnglish: [],
  sources: [
    DuaSource(
      type: DuaSourceType.hadith,
      collection: 'Sahih al-Bukhari',
      reference: '6324',
      grade: HadithGrade.sahih,
    ),
  ],
);
