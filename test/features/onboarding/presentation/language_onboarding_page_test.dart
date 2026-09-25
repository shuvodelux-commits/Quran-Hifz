import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/onboarding/application/onboarding_controller.dart';
import 'package:quran_hifz/features/onboarding/domain/onboarding_state.dart';
import 'package:quran_hifz/features/onboarding/presentation/language_onboarding_page.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('language page is neutral, bilingual, and advances on Next', (
    tester,
  ) async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [userDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: LanguageOnboardingPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('আপনার ভাষা নির্বাচন করুন'), findsOneWidget);
    expect(find.text('বাংলা'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.textContaining('Quran Hifz'), findsNothing);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('onboarding-language-next')))
          .height,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.byKey(const ValueKey('language-option-english')));
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsOneWidget);
    expect(
      ProviderScope.containerOf(
        tester.element(find.byType(LanguageOnboardingPage)),
      ).read(appLanguageProvider),
      AppLanguage.english,
    );

    await tester.tap(find.byKey(const ValueKey('onboarding-language-next')));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(LanguageOnboardingPage)),
    );
    expect(
      container.read(onboardingControllerProvider).requireValue.step,
      OnboardingStep.location,
    );
  });
}
