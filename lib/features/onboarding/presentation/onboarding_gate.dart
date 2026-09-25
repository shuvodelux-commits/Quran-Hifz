import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/onboarding_controller.dart';
import 'onboarding_flow.dart';

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key, required this.completedChild});

  final Widget completedChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(onboardingControllerProvider),
            child: const Text('Retry'),
          ),
        ),
      ),
      data: (value) =>
          value.completed ? completedChild : const OnboardingFlow(),
    );
  }
}
