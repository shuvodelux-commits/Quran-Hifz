import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/onboarding/application/onboarding_controller.dart';
import 'package:quran_hifz/features/onboarding/data/user_database_onboarding_repository.dart';
import 'package:quran_hifz/features/onboarding/domain/onboarding_state.dart';
import 'package:quran_hifz/features/onboarding/presentation/developer_message_page.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('Bangla developer note is accurate and completes onboarding', (
    tester,
  ) async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveSetting(
      UserDatabaseOnboardingRepository.stepKey,
      OnboardingStep.developerMessage.name,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [userDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: DeveloperMessagePage()),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(DeveloperMessagePage)),
    );
    await container.read(onboardingControllerProvider.future);

    expect(find.text('ডেভেলপারের পক্ষ থেকে'), findsOneWidget);
    expect(find.textContaining('মরহুম জারজিস হোসেন প্রামাণিক'), findsOneWidget);
    expect(
      find.textContaining('ব্যক্তিগত তথ্য সংগ্রহ বা বিক্রি করেন না'),
      findsOneWidget,
    );
    expect(find.textContaining('ইন্টারনেট প্রয়োজন হতে পারে'), findsOneWidget);
    expect(find.textContaining('[Support email]'), findsNothing);
    expect(find.textContaining('Quran Hifz'), findsNothing);
    expect(find.text('আল কুরআন শুরু করুন'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('onboarding-start-app'))).height,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.byKey(const ValueKey('onboarding-start-app')));
    await tester.pumpAndSettle();

    expect(
      container.read(onboardingControllerProvider).requireValue.step,
      OnboardingStep.completed,
    );
  });

  testWidgets('English developer note uses Start Al Quran', (tester) async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveSetting(
      UserDatabaseOnboardingRepository.stepKey,
      OnboardingStep.developerMessage.name,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(db),
          appLanguageProvider.overrideWithValue(AppLanguage.english),
        ],
        child: const MaterialApp(home: DeveloperMessagePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('From the developer'), findsOneWidget);
    expect(find.text('Start Al Quran'), findsOneWidget);
    expect(find.textContaining('Quran Hifz'), findsNothing);
  });
}
