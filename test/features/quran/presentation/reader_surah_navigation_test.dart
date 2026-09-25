import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/reader_surah_navigation.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('chooser lists localized Surahs and selects one', (tester) async {
    QuranSurahSummary? selected;
    final surahs = [
      _surah(1, 'Al-Fatihah', 'আল-ফাতিহা'),
      _surah(2, 'Al-Baqarah', 'আল-বাকারা'),
      _surah(3, "Ali 'Imran", 'আলে ইমরান'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderSurahNavigation(
            surahs: surahs,
            current: surahs[1],
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
    expect(find.byKey(const ValueKey('reader-surah-choice-2')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reader-surah-choice-3')));
    expect(selected?.number, 3);
  });

  testWidgets('chooser uses canonical Bangla names when absent', (
    tester,
  ) async {
    final surah = _surah(2, 'Al-Baqarah', null);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderSurahNavigation(
            surahs: [surah],
            current: surah,
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
