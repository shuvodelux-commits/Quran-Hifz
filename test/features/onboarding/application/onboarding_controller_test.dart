import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/onboarding/application/onboarding_controller.dart';
import 'package:quran_hifz/features/onboarding/domain/onboarding_repository.dart';
import 'package:quran_hifz/features/onboarding/domain/onboarding_state.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

void main() {
  test(
    'selectLanguage saves preference before advancing to location',
    () async {
      final onboarding = _MemoryOnboardingRepository();
      final preferences = _MemoryPreferencesRepository();
      final container = ProviderContainer(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(onboarding),
          appPreferencesRepositoryProvider.overrideWithValue(preferences),
        ],
      );
      addTearDown(container.dispose);

      await container.read(onboardingControllerProvider.future);
      await container
          .read(onboardingControllerProvider.notifier)
          .selectLanguage(AppLanguage.english);

      expect(preferences.value.language, AppLanguage.english);
      expect(onboarding.state.step, OnboardingStep.location);
      expect(
        container.read(onboardingControllerProvider).requireValue.step,
        OnboardingStep.location,
      );
    },
  );

  test('language save failure does not advance onboarding', () async {
    final onboarding = _MemoryOnboardingRepository();
    final preferences = _MemoryPreferencesRepository()..failSave = true;
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        appPreferencesRepositoryProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.future);

    await expectLater(
      container
          .read(onboardingControllerProvider.notifier)
          .selectLanguage(AppLanguage.english),
      throwsA(isA<StateError>()),
    );
    expect(onboarding.state.step, OnboardingStep.language);
  });

  test('goToDeveloperMessage persists the next step', () async {
    final onboarding = _MemoryOnboardingRepository();
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        appPreferencesRepositoryProvider.overrideWithValue(
          _MemoryPreferencesRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.future);
    await container
        .read(onboardingControllerProvider.notifier)
        .goToDeveloperMessage();

    expect(onboarding.state.step, OnboardingStep.developerMessage);
    expect(
      container.read(onboardingControllerProvider).requireValue.step,
      OnboardingStep.developerMessage,
    );
  });

  test('complete persists completion and publishes completed state', () async {
    final onboarding = _MemoryOnboardingRepository();
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        appPreferencesRepositoryProvider.overrideWithValue(
          _MemoryPreferencesRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.future);
    await container.read(onboardingControllerProvider.notifier).complete();

    expect(onboarding.state.completed, isTrue);
    expect(
      container.read(onboardingControllerProvider).requireValue.step,
      OnboardingStep.completed,
    );
  });
}

class _MemoryOnboardingRepository implements OnboardingRepository {
  OnboardingState state = const OnboardingState(
    step: OnboardingStep.language,
    completed: false,
  );

  @override
  Future<OnboardingState> load() async => state;

  @override
  Future<void> saveStep(OnboardingStep step) async {
    state = OnboardingState(step: step, completed: false);
  }

  @override
  Future<void> complete() async {
    state = const OnboardingState(
      step: OnboardingStep.completed,
      completed: true,
    );
  }
}

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  AppPreferences value = const AppPreferences.defaults();
  bool failSave = false;

  @override
  Future<AppPreferences> load() async => value;

  @override
  Future<void> save(AppPreferences preferences) async {
    if (failSave) throw StateError('save failed');
    value = preferences;
  }
}
