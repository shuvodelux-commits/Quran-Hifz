import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/onboarding/presentation/onboarding_gate.dart';

void main() {
  testWidgets(
    'onboarding resumes unfinished step and completes only at final CTA',
    (tester) async {
      final db = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      Future<void> pumpGate(Key key) async {
        await tester.pumpWidget(
          ProviderScope(
            key: key,
            overrides: [userDatabaseProvider.overrideWithValue(db)],
            child: const MaterialApp(
              home: OnboardingGate(completedChild: Text('APP_HOME')),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpGate(const ValueKey('first-run'));
      expect(find.text('আপনার ভাষা নির্বাচন করুন'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('language-option-english')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('onboarding-language-next')));
      await tester.pumpAndSettle();
      expect(find.text('Set location'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('onboarding-location-later')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('From the developer'), findsOneWidget);
      expect(find.text('APP_HOME'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await pumpGate(const ValueKey('resumed-run'));
      expect(find.text('From the developer'), findsOneWidget);
      expect(find.text('APP_HOME'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('onboarding-start-app')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text('APP_HOME'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await pumpGate(const ValueKey('completed-run'));
      expect(find.text('APP_HOME'), findsOneWidget);
      expect(find.text('From the developer'), findsNothing);
    },
  );
}
