import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/app/quran_hifz_shell.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/home/presentation/home_page.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/quran/data/demo_quran_repository.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('all primary destinations render in every app theme', (
    tester,
  ) async {
    final userDatabase = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(userDatabase.close);

    for (final theme in AppThemePreference.values) {
      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey(theme),
          overrides: [
            userDatabaseProvider.overrideWithValue(userDatabase),
            prayerScheduleProvider.overrideWith(
              (ref) async => throw StateError('Location unavailable in test'),
            ),
            quranRepositoryProvider.overrideWithValue(DemoQuranRepository()),
            readingLocationStoreProvider.overrideWithValue(
              _NoopLocationStore(),
            ),
            themePreferenceProvider.overrideWithValue(theme),
            showTranslationPreferenceProvider.overrideWithValue(true),
            arabicFontSizeProvider.overrideWithValue(31),
            highlightActiveWordProvider.overrideWithValue(true),
            defaultRepeatCountProvider.overrideWithValue(5),
            defaultPlaybackSpeedProvider.overrideWithValue(1.0),
          ],
          child: MaterialApp(
            theme: appTheme(theme),
            home: const QuranHifzShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navigation = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigation.height, inInclusiveRange(60, 64));
      expect(navigation.elevation, 0);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      expect(find.text('হোম'), findsOneWidget, reason: '$theme home');
      expect(
        find.text('এখন সলাতের সময় নয়'),
        findsOneWidget,
        reason: '$theme home',
      );
      await tester.tap(find.text('সলাত').last);
      await tester.pumpAndSettle();
      expect(
        find.text('সলাত ট্র্যাকার'),
        findsOneWidget,
        reason: '$theme prayer',
      );
      await tester.tap(find.text('ক্যালেন্ডার').last);
      await tester.pump();
      await tester.pump();
      expect(find.text('ক্যালেন্ডার'), findsWidgets, reason: '$theme calendar');
      await tester.tap(find.text('কুরআন').last);
      await tester.pumpAndSettle();
      expect(find.text('কুরআন'), findsWidgets, reason: '$theme Quran');
      await tester.tap(find.text('আরও').last);
      await tester.pumpAndSettle();
      expect(find.text('হিফজ'), findsOneWidget, reason: '$theme more');
      expect(find.text('সেটিংস'), findsOneWidget, reason: '$theme more');
      expect(tester.takeException(), isNull, reason: '$theme raised an error');
    }
  });

  testWidgets('opening the Hifz planner removes the shell navigation bar', (
    tester,
  ) async {
    final userDatabase = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(userDatabase.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(userDatabase),
          prayerScheduleProvider.overrideWith(
            (ref) async => throw StateError('Location unavailable in test'),
          ),
          quranRepositoryProvider.overrideWithValue(DemoQuranRepository()),
          readingLocationStoreProvider.overrideWithValue(_NoopLocationStore()),
        ],
        child: const MaterialApp(home: QuranHifzShell()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('আরও').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('হিফজ').last);
    await tester.pumpAndSettle();

    expect(find.text('হিফজ পরিকল্পনা'), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-add-plan')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('system back confirms before closing the root app', (
    tester,
  ) async {
    final userDatabase = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(userDatabase.close);
    final platformCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        platformCalls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(userDatabase),
          prayerScheduleProvider.overrideWith(
            (ref) async => throw StateError('Location unavailable in test'),
          ),
          quranRepositoryProvider.overrideWithValue(DemoQuranRepository()),
          readingLocationStoreProvider.overrideWithValue(_NoopLocationStore()),
        ],
        child: const MaterialApp(home: QuranHifzShell()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('অ্যাপ বন্ধ করবেন?'), findsOneWidget);

    await tester.tap(find.text('বাতিল'));
    await tester.pumpAndSettle();
    expect(find.text('অ্যাপ বন্ধ করবেন?'), findsNothing);
    expect(
      platformCalls.where((call) => call.method == 'SystemNavigator.pop'),
      isEmpty,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('বন্ধ করুন'));
    await tester.pumpAndSettle();
    expect(
      platformCalls.where((call) => call.method == 'SystemNavigator.pop'),
      hasLength(1),
    );
  });
}

class _NoopLocationStore implements ReadingLocationStore {
  @override
  Future<ReadingLocation?> load() async => null;

  @override
  Future<void> save(ReadingLocation location) async {}
}
