import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/onboarding/data/user_database_onboarding_repository.dart';
import 'package:quran_hifz/features/onboarding/domain/onboarding_state.dart';

void main() {
  test('missing settings start at language and incomplete', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = UserDatabaseOnboardingRepository(db);

    final state = await repo.load();

    expect(state.step, OnboardingStep.language);
    expect(state.completed, isFalse);
  });

  test('unknown persisted step falls back to language', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveSetting(
      UserDatabaseOnboardingRepository.stepKey,
      'removed-step',
    );

    final state = await UserDatabaseOnboardingRepository(db).load();

    expect(state.step, OnboardingStep.language);
    expect(state.completed, isFalse);
  });

  test('saveStep persists progress without completing onboarding', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = UserDatabaseOnboardingRepository(db);

    await repo.saveStep(OnboardingStep.location);
    final restored = await repo.load();

    expect(restored.step, OnboardingStep.location);
    expect(restored.completed, isFalse);
  });

  test('completed flag wins over stale step', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveSetting(
      UserDatabaseOnboardingRepository.stepKey,
      OnboardingStep.location.name,
    );
    await db.saveSetting(UserDatabaseOnboardingRepository.completedKey, 'true');

    final state = await UserDatabaseOnboardingRepository(db).load();

    expect(state.completed, isTrue);
    expect(state.step, OnboardingStep.completed);
  });

  test('complete writes completed step and flag', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = UserDatabaseOnboardingRepository(db);

    await repo.complete();

    expect(
      await db.getSetting(UserDatabaseOnboardingRepository.stepKey),
      OnboardingStep.completed.name,
    );
    expect(
      await db.getSetting(UserDatabaseOnboardingRepository.completedKey),
      'true',
    );
  });
}
