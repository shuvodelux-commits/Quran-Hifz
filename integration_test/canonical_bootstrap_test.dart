import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_hifz/app/quran_hifz_app.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/quran/presentation/quran_reader_page.dart';

import 'support/pump_until.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bundled canonical Quran boots and navigates page 1 to page 2', (
    tester,
  ) async {
    addTearDown(() => disposeTestApp(tester));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readingLocationStoreProvider.overrideWithValue(_NoopLocationStore()),
        ],
        child: const QuranHifzApp(),
      ),
    );

    await _waitForCanonicalReader(tester);

    expect(find.text('Quran · Page 1'), findsOneWidget);
    expect(find.byKey(const ValueKey('word-1:1:1')), findsOneWidget);
    expect(find.textContaining('Demo tafsir placeholder'), findsNothing);

    await tester.tap(find.byTooltip('Next page'));
    await pumpUntilFound(
      tester,
      find.text('Quran · Page 2'),
      description: 'canonical Quran page 2',
      timeout: const Duration(seconds: 30),
    );

    expect(find.byKey(const ValueKey('ayah-2:1')), findsOneWidget);
  });
}

Future<void> _waitForCanonicalReader(WidgetTester tester) async {
  final ayah = find.byKey(const ValueKey('ayah-1:1'));
  final readerError = find.text('Quran content could not be loaded.');
  final deadline = DateTime.now().add(const Duration(seconds: 30));

  debugPrint(
    '[E2E] waiting for canonical Quran ayah 1:1 after verified DB bootstrap',
  );

  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));

    if (ayah.evaluate().isNotEmpty) {
      debugPrint('[E2E] ready: canonical Quran ayah 1:1');
      return;
    }

    if (readerError.evaluate().isNotEmpty) {
      final readerPage = find.byType(QuranReaderPage);
      if (readerPage.evaluate().isEmpty) {
        throw TestFailure(
          'Reader showed an error state, but QuranReaderPage was not found.',
        );
      }

      final context = tester.element(readerPage.first);
      final container = ProviderScope.containerOf(context);
      final reader = container.read(readerControllerProvider);
      final details = reader.when(
        data: (_) =>
            'Reader unexpectedly reported data while the error UI was visible.',
        loading: () =>
            'Reader unexpectedly reported loading while the error UI was visible.',
        error: (error, stackTrace) => '$error\n$stackTrace',
      );

      throw TestFailure(
        'Canonical reader entered AsyncError on device:\n$details',
      );
    }
  }

  throw TestFailure(
    'Timed out after 30s waiting for canonical Quran ayah 1:1 after verified DB bootstrap.',
  );
}

class _NoopLocationStore implements ReadingLocationStore {
  @override
  Future<ReadingLocation?> load() async => null;

  @override
  Future<void> save(ReadingLocation location) async {}
}
