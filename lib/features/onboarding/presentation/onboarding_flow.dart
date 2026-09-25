import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/onboarding_controller.dart';
import '../domain/onboarding_state.dart';
import 'developer_message_page.dart';
import 'language_onboarding_page.dart';
import 'location_onboarding_page.dart';

class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      data: (value) => switch (value.step) {
        OnboardingStep.language => const LanguageOnboardingPage(),
        OnboardingStep.location => const LocationOnboardingPage(),
        OnboardingStep.developerMessage => const DeveloperMessagePage(),
        OnboardingStep.completed => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      },
    );
  }
}
