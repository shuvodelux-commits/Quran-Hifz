import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_planner_page.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/data/demo_quran_repository.dart';

void main() {
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
