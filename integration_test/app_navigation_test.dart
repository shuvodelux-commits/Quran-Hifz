import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_hifz/app/quran_hifz_shell.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/dua/presentation/dua_page.dart';
import 'package:quran_hifz/features/home/presentation/home_dashboard_page.dart';
import 'package:quran_hifz/features/home/presentation/home_page.dart';
import 'package:quran_hifz/features/home/presentation/more_page.dart';
import 'package:quran_hifz/features/home/presentation/prayer_calendar_page.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/quran/data/demo_quran_repository.dart';
import 'package:quran_hifz/features/quran/presentation/quran_surah_list_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shell reaches every current primary destination', (tester) async {
    final userDatabase = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await userDatabase.close();
    });

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
    await tester.pump();

    expect(find.byType(HomeDashboardPage), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));

    final destinations = <String, Finder>{
      'দোয়া': find.byType(DuaPage),
      'কুরআন': find.byType(QuranSurahListPage),
      'ক্যালেন্ডার': find.byType(PrayerCalendarPage),
      'আরও': find.byType(MorePage),
      'হোম': find.byType(HomeDashboardPage),
    };

    for (final destination in destinations.entries) {
      await tester.tap(find.text(destination.key).last);
      await tester.pump();
      expect(
        destination.value,
        findsOneWidget,
        reason: '${destination.key} destination should render',
      );
    }
  });
}

class _NoopLocationStore implements ReadingLocationStore {
  @override
  Future<ReadingLocation?> load() async => null;

  @override
  Future<void> save(ReadingLocation location) async {}
}
