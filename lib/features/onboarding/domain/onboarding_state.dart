enum OnboardingStep { language, location, developerMessage, completed }

class OnboardingState {
  const OnboardingState({required this.step, required this.completed});

  final OnboardingStep step;
  final bool completed;

  OnboardingState copyWith({OnboardingStep? step, bool? completed}) {
    return OnboardingState(
      step: step ?? this.step,
      completed: completed ?? this.completed,
    );
  }
}
