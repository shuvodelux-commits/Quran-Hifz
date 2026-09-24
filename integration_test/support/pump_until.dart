import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  required String description,
  Duration timeout = const Duration(seconds: 20),
  Duration step = const Duration(milliseconds: 100),
}) async {
  debugPrint('[E2E] waiting for $description');
  final deadline = DateTime.now().add(timeout);

  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure(
        'Timed out after ${timeout.inSeconds}s waiting for $description.',
      );
    }
    await tester.pump(step);
  }

  // Give one bounded frame window for the destination transition/layout to
  // finish without requiring every animation in the app to become idle.
  await tester.pump(const Duration(milliseconds: 250));
  debugPrint('[E2E] ready: $description');
}

Future<void> disposeTestApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 250));
}
