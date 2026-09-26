import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/number_quick_scroll_rail.dart';

void main() {
  testWidgets('tap stays quiet and long-press drag previews then commits', (
    tester,
  ) async {
    int? previewed;
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 400,
              child: NumberQuickScrollRail(
                count: 10,
                semanticLabel: 'Ayah',
                current: 3,
                onPreview: (value) => previewed = value,
                onSelected: (value) => selected = value,
              ),
            ),
          ),
        ),
      ),
    );

    final rail = find.byKey(const ValueKey('number-quick-scroll-rail'));
    final thumb = find.byKey(const ValueKey('number-quick-scroll-thumb'));
    expect(find.text('1'), findsNothing);
    expect(find.text('10'), findsNothing);
    await tester.tap(rail);
    await tester.pump();
    expect(previewed, isNull);
    expect(selected, isNull);

    final initialThumbTop = tester.getTopLeft(thumb).dy;
    final gesture = await tester.startGesture(tester.getCenter(rail));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 20));
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();

    expect(previewed, inInclusiveRange(7, 9));
    expect(tester.getTopLeft(thumb).dy, greaterThan(initialThumbTop));
    expect(find.byKey(const ValueKey('number-quick-scroll-bubble')), findsOne);

    await gesture.up();
    await tester.pump();
    expect(selected, previewed);
    expect(tester.getTopLeft(thumb).dy, greaterThan(initialThumbTop));
    expect(
      find.byKey(const ValueKey('number-quick-scroll-bubble')),
      findsNothing,
    );
  });

  testWidgets('thumb follows the attached scroll controller', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              ListView.builder(
                controller: controller,
                itemExtent: 80,
                itemCount: 30,
                itemBuilder: (_, index) => Text('Item $index'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 400,
                  child: NumberQuickScrollRail(
                    count: 30,
                    semanticLabel: 'Surah',
                    scrollController: controller,
                    onPreview: (_) {},
                    onSelected: (_) {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final thumb = find.byKey(const ValueKey('number-quick-scroll-thumb'));
    final rail = find.byKey(const ValueKey('number-quick-scroll-rail'));
    final initialTop = tester.getTopLeft(thumb).dy;

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    expect(tester.getTopLeft(thumb).dy, greaterThan(initialTop));
    expect(
      tester.getBottomRight(thumb).dy,
      closeTo(tester.getBottomRight(rail).dy - 8, 2),
    );
  });

  testWidgets('current value positions a thin teal thumb', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1699A3)),
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 400,
              child: NumberQuickScrollRail(
                count: 10,
                semanticLabel: 'Ayah',
                current: 10,
                onPreview: (_) {},
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final rail = find.byKey(const ValueKey('number-quick-scroll-rail'));
    final thumb = find.byKey(const ValueKey('number-quick-scroll-thumb'));
    expect(tester.getSize(thumb).width, inInclusiveRange(3, 4));
    expect(
      tester.getBottomRight(thumb).dy,
      closeTo(tester.getBottomRight(rail).dy - 8, 2),
    );
  });
}
