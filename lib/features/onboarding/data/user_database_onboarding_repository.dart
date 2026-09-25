import '../../../core/database/user_database.dart';
import '../domain/onboarding_repository.dart';
import '../domain/onboarding_state.dart';

class UserDatabaseOnboardingRepository implements OnboardingRepository {
  UserDatabaseOnboardingRepository(this._database);

  static const stepKey = 'onboarding_step_v1';
  static const completedKey = 'onboarding_completed_v1';

  final UserDatabase _database;

  @override
  Future<OnboardingState> load() async {
    final completed = await _database.getSetting(completedKey) == 'true';
    if (completed) {
      return const OnboardingState(
        step: OnboardingStep.completed,
        completed: true,
      );
    }

    final rawStep = await _database.getSetting(stepKey);
    final step = OnboardingStep.values
        .where((value) => value != OnboardingStep.completed)
        .cast<OnboardingStep?>()
        .firstWhere((value) => value?.name == rawStep, orElse: () => null);

    return OnboardingState(
      step: step ?? OnboardingStep.language,
      completed: false,
    );
  }

  @override
  Future<void> saveStep(OnboardingStep step) async {
    if (step == OnboardingStep.completed) {
      throw ArgumentError.value(step, 'step', 'Use complete() for completion.');
    }
    await _database.transaction(() async {
      await _database.saveSetting(stepKey, step.name);
      await _database.saveSetting(completedKey, 'false');
    });
  }

  @override
  Future<void> complete() async {
    await _database.transaction(() async {
      await _database.saveSetting(stepKey, OnboardingStep.completed.name);
      await _database.saveSetting(completedKey, 'true');
    });
  }
}
