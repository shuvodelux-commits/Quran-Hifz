import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/application/progressive_hide_generator.dart';
import 'package:quran_hifz/features/hifz/domain/memorization_result.dart';
import 'package:quran_hifz/features/hifz/presentation/memorization_test_page.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';

void main() {
  const ayah = QuranAyah(
    surahNumber: 1,
    ayahNumber: 1,
    words: [
      QuranWord(position: 1, arabic: 'WORD_ONE'),
      QuranWord(position: 2, arabic: 'WORD_TWO'),
      QuranWord(position: 3, arabic: 'WORD_THREE'),
    ],
  );

  testWidgets('Reveal restores exact canonical words before rating', (
    tester,
  ) async {
    MemorizationResult? submitted;

    await tester.pumpWidget(
      MaterialApp(
        home: MemorizationTestPage(
          ayah: ayah,
          mode: MemorizationTestMode.reveal,
          onResult: (result) => submitted = result,
        ),
      ),
    );

    expect(find.text('WORD_ONE'), findsNothing);
    expect(find.text('WORD_TWO'), findsNothing);
    expect(find.text('WORD_THREE'), findsNothing);
    expect(find.text('Perfect'), findsNothing);

    await tester.tap(find.text('Reveal'));
    await tester.pump();

    expect(find.text('WORD_ONE'), findsOneWidget);
    expect(find.text('WORD_TWO'), findsOneWidget);
    expect(find.text('WORD_THREE'), findsOneWidget);
    expect(find.text('Perfect'), findsOneWidget);
    expect(find.text('Small Mistake'), findsOneWidget);
    expect(find.text('Difficult'), findsOneWidget);
    expect(find.text('Forgot'), findsOneWidget);

    await tester.tap(find.text('Perfect'));
    expect(submitted, MemorizationResult.perfect);
  });

  testWidgets('all four rating buttons emit their domain result', (
    tester,
  ) async {
    final submitted = <MemorizationResult>[];

    await tester.pumpWidget(
      MaterialApp(
        home: MemorizationTestPage(
          ayah: ayah,
          mode: MemorizationTestMode.progressiveHide,
          progressiveRound: 1,
          difficulty: ProgressiveHideDifficulty.medium,
          onResult: submitted.add,
        ),
      ),
    );

    await tester.tap(find.text('Reveal'));
    await tester.pump();

    for (final label in const [
      'Perfect',
      'Small Mistake',
      'Difficult',
      'Forgot',
    ]) {
      await tester.tap(find.text(label));
    }

    expect(submitted, const [
      MemorizationResult.perfect,
      MemorizationResult.smallMistake,
      MemorizationResult.difficult,
      MemorizationResult.forgot,
    ]);
  });
}
