import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/features/reciters/application/reciter_catalog_controller.dart';
import 'package:quran_hifz/features/reciters/presentation/reciter_audio_page.dart';

import 'support/pump_until.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'bundled reciter catalog downloads Surah 1 without a Quran backend define',
    (tester) async {
      addTearDown(() => disposeTestApp(tester));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ReciterAudioPage(currentSurahNumber: 1)),
        ),
      );

      await pumpUntilFound(
        tester,
        find.text('Chapter reciter'),
        description: 'bundled reciter catalog',
        timeout: const Duration(seconds: 30),
      );
      expect(find.text('Reciter catalog is unavailable.'), findsNothing);
      expect(
        find.text('Bundled reciter catalog is unavailable or corrupted.'),
        findsNothing,
      );

      final pageContext = tester.element(find.byType(ReciterAudioPage));
      final container = ProviderScope.containerOf(pageContext);
      final state = await container.read(
        reciterCatalogControllerProvider.future,
      );
      expect(state.reciters, isNotEmpty);
      final reciter = state.reciters.first;

      await tester.tap(find.text(reciter.name).first);
      await tester.pumpAndSettle();
      expect(find.text('Selected: ${reciter.name}'), findsOneWidget);

      await tester.tap(find.text('Download for offline'));
      await pumpUntilFound(
        tester,
        find.text('Surah audio downloaded for offline playback.'),
        description: 'offline Surah 1 download completion',
        timeout: const Duration(minutes: 2),
      );

      final database = container.read(userDatabaseProvider);
      final audio = await database.getAudio('chapter:${reciter.id}:1');
      expect(audio, isNotNull);
      expect(audio!.localPath, isNotNull);
      expect(audio.localPath, isNotEmpty);
    },
  );
}
