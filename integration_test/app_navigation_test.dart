import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_hifz/app/quran_hifz_shell.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/quran/data/demo_quran_repository.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';

import 'support/pump_until.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shell fixture reaches every primary module', (tester) async {
    final userDatabase = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await disposeTestApp(tester);
      await userDatabase.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(userDatabase),
          quranRepositoryProvider.overrideWithValue(DemoQuranRepository()),
          readingLocationStoreProvider.overrideWithValue(_NoopLocationStore()),
          showTranslationPreferenceProvider.overrideWithValue(true),
          arabicFontSizeProvider.overrideWithValue(31),
          highlightActiveWordProvider.overrideWithValue(true),
          defaultRepeatCountProvider.overrideWithValue(5),
          defaultPlaybackSpeedProvider.overrideWithValue(1.0),
        ],
        child: const MaterialApp(home: QuranHifzShell()),
      ),
    );

    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('ayah-1:1')),
      description: 'initial Quran reader content',
    );

    final destinations = <String, Finder>{
      'Hifz': find.text('New Memorization'),
      'Revision': find.text("Today's Revision"),
      'Progress': find.text('Last 7 days'),
      'Test': find.text('Memorization Test'),
      'Bookmarks': find.text('No Quran bookmarks yet.'),
      'Quran': find.byKey(const ValueKey('ayah-1:1')),
    };

    for (final expectation in destinations.entries) {
      await tester.tap(find.text(expectation.key).last);
      await pumpUntilFound(
        tester,
        expectation.value,
        description: '${expectation.key} destination',
      );
      expect(expectation.value, findsWidgets);
    }
  });
}

class _NoopLocationStore implements ReadingLocationStore {
  @override
  Future<ReadingLocation?> load() async => null;

  @override
  Future<void> save(ReadingLocation location) async {}
}
