import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_pattern_controls.dart';

void main() {
  testWidgets('pattern sheet previews progressive 1-5 sequence', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HifzPatternSheet(
            surahNumber: 1,
            startAyah: 1,
            endAyah: 5,
            initialSelection: HifzPatternSelection(
              ayahRepeatCount: 5,
              combinedRepeatCount: 3,
              finalRangeRepeatCount: 0,
            ),
          ),
        ),
      ),
    );

    final preview = tester.widget<Text>(
      find.byKey(const ValueKey('hifz-sequence-preview')),
    );
    expect(preview.data, contains('1×5  →  2×5  →  1–2×3  →  3×5  →  1–3×3'));
    expect(preview.data, contains('5×5  →  1–5×3'));
  });

  testWidgets('final full-range review adds one final sequence step', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HifzPatternSheet(
            surahNumber: 1,
            startAyah: 1,
            endAyah: 3,
            initialSelection: HifzPatternSelection(
              ayahRepeatCount: 5,
              combinedRepeatCount: 3,
              finalRangeRepeatCount: 3,
            ),
          ),
        ),
      ),
    );

    final preview = tester.widget<Text>(
      find.byKey(const ValueKey('hifz-sequence-preview')),
    );
    expect(preview.data, endsWith('1–3×3'));
  });
}
