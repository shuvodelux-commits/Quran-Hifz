import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../data/user_database_onboarding_repository.dart';
import '../domain/onboarding_repository.dart';
import '../domain/onboarding_state.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return UserDatabaseOnboardingRepository(ref.watch(userDatabaseProvider));
});

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

class OnboardingController extends AsyncNotifier<OnboardingState> {
  OnboardingRepository get _repository =>
      ref.read(onboardingRepositoryProvider);

  @override
  Future<OnboardingState> build() => _repository.load();

  Future<void> selectLanguage(AppLanguage language) async {
    await ref
        .read(appPreferencesControllerProvider.notifier)
        .setLanguage(language);
    await _repository.saveStep(OnboardingStep.location);
    state = const AsyncData(
      OnboardingState(step: OnboardingStep.location, completed: false),
    );
  }

  Future<void> goToDeveloperMessage() async {
    await _repository.saveStep(OnboardingStep.developerMessage);
    state = const AsyncData(
      OnboardingState(step: OnboardingStep.developerMessage, completed: false),
    );
  }

  Future<void> complete() async {
    await _repository.complete();
    state = const AsyncData(
      OnboardingState(step: OnboardingStep.completed, completed: true),
    );
  }
}
