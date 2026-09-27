import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_setup_sheet.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';

const _surah = QuranSurahSummary(
  number: 1,
  nameArabic: 'الفاتحة',
  nameEnglish: 'Al-Fatihah',
  ayahCount: 7,
  pageStart: 1,
  pageEnd: 1,
  juzStart: 1,
);

void main() {
  testWidgets('setup returns the selected ayah range and repetition preset', (
    tester,
  ) async {
    HifzSetupResult? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  result = await showModalBottomSheet<HifzSetupResult>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => HifzSetupSheet(
                      surah: _surah,
                      initialStartAyah: 1,
                      initialEndAyah: 5,
                      initialPreset: HifzPresets.progressive(),
                    ),
                  );
                },
                child: const Text('Open setup'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open setup'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('hifz-start-ayah')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-3')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('hifz-end-ayah')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-5')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('hifz-setup-start')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.startAyah, 3);
    expect(result!.endAyah, 5);
    expect(result!.preset.ayahRepeatCount, 5);
  });

  testWidgets('setup keeps end ayah at or after the selected start', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HifzSetupSheet(
            surah: _surah,
            initialStartAyah: 6,
            initialEndAyah: 7,
            initialPreset: HifzPresets.newMemorization,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('hifz-start-ayah')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-7')));
    await tester.pumpAndSettle();

    expect(find.text('Ayah 7–7'), findsOneWidget);
  });
}
