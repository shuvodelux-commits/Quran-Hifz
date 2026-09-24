import 'dart:convert';
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/quran_hifz_app.dart';
import 'package:quran_hifz/app/quran_hifz_shell.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/quran_content_bootstrap.dart';
import 'package:quran_hifz/core/database/quran_content_database.dart';
import 'package:quran_hifz/core/database/quran_content_installer.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/main.dart' as app;

void main() {
  test('buildRootApp wraps QuranHifzApp in ProviderScope', () {
    final root = app.buildRootApp();

    expect(root, isA<ProviderScope>());
    final scope = root as ProviderScope;
    expect(scope.child, isA<QuranHifzApp>());
  });

  testWidgets('provider-scoped app renders through canonical bootstrap', (
    tester,
  ) async {
    final database = QuranContentDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final bootstrap = QuranContentBootstrap(
      manifestLoader: () async => jsonEncode({
        'content_version': 'test',
        'schema_version': 1,
        'database_sha256':
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      }),
      install: (_) async => const QuranContentInstallResult(
        databasePath: '/fixture/quran.sqlite',
        contentVersion: 'test',
        installedNow: false,
      ),
      openDatabase: (_) => database,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranContentBootstrapperProvider.overrideWithValue(bootstrap),
          readingLocationStoreProvider.overrideWithValue(_NoopLocationStore()),
          themePreferenceProvider.overrideWithValue(AppThemePreference.light),
          showTranslationPreferenceProvider.overrideWithValue(true),
          arabicFontSizeProvider.overrideWithValue(31),
          highlightActiveWordProvider.overrideWithValue(true),
          defaultRepeatCountProvider.overrideWithValue(5),
          defaultPlaybackSpeedProvider.overrideWithValue(1.0),
        ],
        child: const QuranHifzApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(QuranHifzShell), findsOneWidget);
  });

  testWidgets('opening artwork fills upward before revealing the app', (
    tester,
  ) async {
    final pendingManifest = Completer<String>();
    final bootstrap = QuranContentBootstrap(
      manifestLoader: () => pendingManifest.future,
      install: (_) => throw StateError('unreachable'),
      openDatabase: (_) => throw StateError('unreachable'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranContentBootstrapperProvider.overrideWithValue(bootstrap),
          themePreferenceProvider.overrideWithValue(AppThemePreference.light),
        ],
        child: const QuranHifzApp(),
      ),
    );
    await tester.pump();

    const splashKey = ValueKey('app-opening-splash');
    const fillKey = ValueKey('opening-logo-color-fill');
    const glowKey = ValueKey('opening-noor-glow');
    expect(find.byKey(splashKey), findsOneWidget);
    expect(find.byKey(fillKey), findsOneWidget);
    expect(find.byKey(glowKey), findsOneWidget);
    final startHeight = tester.getSize(find.byKey(fillKey)).height;
    final startGlow = tester
        .widget<FadeTransition>(find.byKey(glowKey))
        .opacity
        .value;

    await tester.pump(const Duration(milliseconds: 900));
    final middleHeight = tester.getSize(find.byKey(fillKey)).height;
    final middleGlow = tester
        .widget<FadeTransition>(find.byKey(glowKey))
        .opacity
        .value;
    expect(middleHeight, greaterThan(startHeight));
    expect(middleHeight, lessThan(320));
    expect(middleGlow, greaterThan(startGlow));

    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byKey(splashKey), findsNothing);
    expect(find.text('Preparing verified Quran content…'), findsOneWidget);
  });

  testWidgets('bootstrap failure is visible and retryable', (tester) async {
    var attempts = 0;
    final bootstrap = QuranContentBootstrap(
      manifestLoader: () async {
        attempts++;
        throw StateError('canonical asset missing');
      },
      install: (_) => throw StateError('unreachable'),
      openDatabase: (_) => throw StateError('unreachable'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranContentBootstrapperProvider.overrideWithValue(bootstrap),
          themePreferenceProvider.overrideWithValue(AppThemePreference.light),
        ],
        child: const QuranHifzApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verified Quran content is unavailable.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
  });
}

class _NoopLocationStore implements ReadingLocationStore {
  @override
  Future<ReadingLocation?> load() async => null;

  @override
  Future<void> save(ReadingLocation location) async {}
}
