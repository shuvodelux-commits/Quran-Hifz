import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_planner_page.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/data/demo_quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';

void main() {
  testWidgets('starts Hifz from a chosen Surah without creating a plan', (
    tester,
  ) async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(database),
          quranRepositoryProvider.overrideWithValue(
            _QuickStartQuranRepository(),
          ),
        ],
        child: const MaterialApp(home: HifzPlannerPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('hifz-start-without-plan')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('hifz-start-without-plan')));
    await tester.pumpAndSettle();

    expect(find.text('Choose Surah'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('hifz-quick-start-surah-2')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('hifz-quick-start-surah-2')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('hifz-surah-selector')), findsOneWidget);
    expect(find.textContaining('Al-Baqarah'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('hifz-close')));
    await tester.pumpAndSettle();

    expect(find.text('Plan your Hifz'), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-plan-list')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('creates and deletes persistent Hifz plans', (tester) async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(database),
          quranRepositoryProvider.overrideWithValue(DemoQuranRepository()),
        ],
        child: const MaterialApp(home: HifzPlannerPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Plan your Hifz'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hifz-create-first-plan')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('hifz-plan-title')),
      'Morning Hifz',
    );
    await tester.tap(find.byKey(const ValueKey('hifz-save-plan')));
    await tester.pumpAndSettle();

    expect(find.text('Morning Hifz'), findsOneWidget);
    expect(find.textContaining('Al-Fatihah · Ayah 1–1'), findsOneWidget);
    expect(find.text('Start Hifz'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hifz-delete-plan-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Morning Hifz'), findsNothing);
    expect(find.text('Plan your Hifz'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

class _QuickStartQuranRepository extends DemoQuranRepository {
  @override
  Future<List<QuranSurahSummary>> listSurahs() async => const [
    QuranSurahSummary(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      ayahCount: 7,
      pageStart: 1,
      pageEnd: 1,
      juzStart: 1,
    ),
    QuranSurahSummary(
      number: 2,
      nameArabic: 'البقرة',
      nameEnglish: 'Al-Baqarah',
      ayahCount: 286,
      pageStart: 2,
      pageEnd: 49,
      juzStart: 1,
    ),
  ];
}
