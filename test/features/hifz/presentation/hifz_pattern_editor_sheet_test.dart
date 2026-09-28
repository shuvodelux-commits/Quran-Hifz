import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_pattern_editor_sheet.dart';

void main() {
  testWidgets('pattern editor changes every repeat stage and pause', (
    tester,
  ) async {
    HifzPreset? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  result = await showModalBottomSheet<HifzPreset>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => HifzPatternEditorSheet(
                      initialPreset: HifzPresets.progressive(),
                    ),
                  );
                },
                child: const Text('Edit pattern'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit pattern'));
    await tester.pumpAndSettle();

    expect(find.text('Repeat pattern'), findsOneWidget);
    expect(find.text('Each new ayah'), findsOneWidget);
    expect(find.text('Combined ayahs'), findsOneWidget);
    expect(find.text('Full selected range'), findsOneWidget);
    expect(find.text('Pause between repeats'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hifz-pattern-ayah-3')));
    await tester.tap(find.byKey(const ValueKey('hifz-pattern-combined-2')));
    await tester.tap(find.byKey(const ValueKey('hifz-pattern-final-1')));
    await tester.tap(find.byKey(const ValueKey('hifz-pattern-pause-500')));
    await tester.pump();

    expect(
      find.text('Each ayah ×3 → Combined ×2 → Full range ×1'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('hifz-pattern-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.ayahRepeatCount, 3);
    expect(result!.combinedRepeatCount, 2);
    expect(result!.finalRangeRepeatCount, 1);
    expect(result!.pauseBetweenRepeats, const Duration(milliseconds: 500));
  });

  testWidgets('pattern editor can turn final full-range repeat off', (
    tester,
  ) async {
    HifzPreset? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showModalBottomSheet<HifzPreset>(
                  context: context,
                  builder: (_) => HifzPatternEditorSheet(
                    initialPreset: HifzPresets.progressive(
                      finalRangeRepeatCount: 3,
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hifz-pattern-final-0')));
    await tester.tap(find.byKey(const ValueKey('hifz-pattern-save')));
    await tester.pumpAndSettle();

    expect(result!.finalRangeRepeatCount, 0);
  });
}
