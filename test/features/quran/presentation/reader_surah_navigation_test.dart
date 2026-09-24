import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/reader_surah_navigation.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('shows localized previous current and next Surahs', (
    tester,
  ) async {
    QuranSurahSummary? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderSurahNavigation(
            previous: _surah(1, 'Al-Fatihah', 'আল-ফাতিহা'),
            current: _surah(2, 'Al-Baqarah', 'আল-বাকারা'),
            next: _surah(3, "Ali 'Imran", 'আলে ইমরান'),
            language: AppLanguage.bangla,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('reader-surah-navigation')),
      findsOneWidget,
    );
    expect(find.text('১. আল-ফাতিহা'), findsOneWidget);
    expect(find.text('২. আল-বাকারা'), findsOneWidget);
    expect(find.text('৩. আলে ইমরান'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('reader-surah-navigation')))
          .height,
      lessThanOrEqualTo(44),
    );

    await tester.tap(find.text('৩. আলে ইমরান'));
    expect(selected?.number, 3);
  });

  testWidgets('does not expose absent neighboring Surahs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderSurahNavigation(
            previous: null,
            current: _surah(1, 'Al-Fatihah', 'আল-ফাতিহা'),
            next: null,
            language: AppLanguage.english,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Previous Surah'), findsNothing);
    expect(find.byTooltip('Next Surah'), findsNothing);
  });

  testWidgets('uses canonical Bangla names when database names are absent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderSurahNavigation(
            previous: null,
            current: _surah(2, 'Al-Baqarah', null),
            next: null,
            language: AppLanguage.bangla,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('২. আল-বাকারা'), findsOneWidget);
    expect(find.textContaining('Al-Baqarah'), findsNothing);
  });
}

QuranSurahSummary _surah(int number, String english, String? bangla) =>
    QuranSurahSummary(
      number: number,
      nameArabic: 'Arabic $number',
      nameEnglish: english,
      nameBangla: bangla,
      ayahCount: 7,
      pageStart: number,
      pageEnd: number,
      juzStart: 1,
    );
