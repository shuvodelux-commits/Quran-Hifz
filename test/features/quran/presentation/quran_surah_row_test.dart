import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/quran_surah_row.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  const surah = QuranSurahSummary(
    number: 2,
    nameArabic: 'البقرة',
    nameEnglish: 'Al-Baqarah',
    nameBangla: 'আল-বাকারা',
    revelationPlace: 'Madinah',
    ayahCount: 286,
    pageStart: 2,
    pageEnd: 49,
    juzStart: 1,
  );

  testWidgets('shows reference content and handles tap in English', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _app(
        QuranSurahRow(
          surah: surah,
          language: AppLanguage.english,
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('Madani · 286 Verses'), findsOneWidget);
    expect(find.text('سورة البقرة'), findsOneWidget);
    final englishName = tester.widget<Text>(find.text('Al-Baqarah'));
    expect(englishName.style?.fontSize, 18);
    expect(find.byType(Card), findsNothing);
    expect(
      tester.getSize(find.byType(QuranSurahRow)).height,
      lessThanOrEqualTo(80),
    );
    await tester.tap(find.text('Al-Baqarah'));
    expect(tapped, isTrue);
  });

  testWidgets('localizes Bangla labels and digits', (tester) async {
    await tester.pumpWidget(
      _app(
        QuranSurahRow(surah: surah, language: AppLanguage.bangla, onTap: () {}),
      ),
    );

    expect(find.text('২'), findsOneWidget);
    expect(find.text('আল-বাকারা'), findsOneWidget);
    expect(find.text('মাদানী · ২৮৬ আয়াত'), findsOneWidget);
  });

  test('normalizes revelation labels and handles unknown values', () {
    expect(localizedRevelationLabel('Mecca', AppLanguage.english), 'Makki');
    expect(localizedRevelationLabel('Makki', AppLanguage.bangla), 'মাক্কী');
    expect(localizedRevelationLabel('Medina', AppLanguage.english), 'Madani');
    expect(localizedRevelationLabel(null, AppLanguage.bangla), 'অজানা');
    expect(localizedRevelationLabel('other', AppLanguage.english), 'Unknown');
  });

  testWidgets('does not overflow at 1.8 text scale', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
        child: _app(
          QuranSurahRow(
            surah: surah,
            language: AppLanguage.english,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

Widget _app(Widget child) => MaterialApp(
  theme: appTheme(AppThemePreference.light, language: AppLanguage.english),
  home: Scaffold(
    body: Center(child: SizedBox(width: 380, child: child)),
  ),
);
