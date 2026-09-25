import 'onboarding_state.dart';

abstract class OnboardingRepository {
  Future<OnboardingState> load();
  Future<void> saveStep(OnboardingStep step);
  Future<void> complete();
}
