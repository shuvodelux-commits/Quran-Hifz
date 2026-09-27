import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_surah_picker_sheet.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

const _surahs = [
  QuranSurahSummary(
    number: 1,
    nameArabic: 'الفاتحة',
    nameEnglish: 'Al-Fatihah',
    nameBangla: 'আল-ফাতিহা',
    ayahCount: 7,
    pageStart: 1,
    pageEnd: 1,
    juzStart: 1,
  ),
  QuranSurahSummary(
    number: 2,
    nameArabic: 'البقرة',
    nameEnglish: 'Al-Baqarah',
    nameBangla: 'আল-বাকারা',
    ayahCount: 286,
    pageStart: 2,
    pageEnd: 49,
    juzStart: 1,
  ),
];

void main() {
  testWidgets('Surah picker remains clean on a narrow phone viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWithValue(AppLanguage.english),
        ],
        child: const MaterialApp(
          home: Scaffold(body: HifzSurahPickerSheet(surahs: _surahs)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('hifz-surah-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-surah-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Surah picker searches number, English, Bangla, and Arabic', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWithValue(AppLanguage.english),
        ],
        child: const MaterialApp(
          home: Scaffold(body: HifzSurahPickerSheet(surahs: _surahs)),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('hifz-surah-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-surah-2')), findsOneWidget);
    expect(find.text('الفاتحة'), findsOneWidget);
    expect(find.text('7 ayahs'), findsOneWidget);

    final search = find.byKey(const ValueKey('hifz-surah-search'));

    await tester.enterText(search, '2');
    await tester.pump();
    expect(find.byKey(const ValueKey('hifz-surah-1')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-surah-2')), findsOneWidget);

    await tester.enterText(search, 'fati');
    await tester.pump();
    expect(find.byKey(const ValueKey('hifz-surah-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-surah-2')), findsNothing);

    await tester.enterText(search, 'আল-ফাতিহা');
    await tester.pump();
    expect(find.byKey(const ValueKey('hifz-surah-1')), findsOneWidget);

    await tester.enterText(search, 'الفاتحة');
    await tester.pump();
    expect(find.byKey(const ValueKey('hifz-surah-1')), findsOneWidget);

    await tester.enterText(search, '');
    await tester.pump();
    expect(find.byKey(const ValueKey('hifz-surah-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-surah-2')), findsOneWidget);
  });
}
