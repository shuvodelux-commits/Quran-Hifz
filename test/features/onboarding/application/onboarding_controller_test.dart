import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/presentation/home_page.dart';
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

  test('useCurrentLocation configures GPS and advances', () async {
    final onboarding = _MemoryOnboardingRepository(
      const OnboardingState(step: OnboardingStep.location, completed: false),
    );
    final preferences = _MemoryPreferencesRepository();
    final prayer = _FakePrayerScheduleRepository();
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        appPreferencesRepositoryProvider.overrideWithValue(preferences),
        prayerScheduleRepositoryProvider.overrideWithValue(prayer),
      ],
    );
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.future);
    await container
        .read(onboardingControllerProvider.notifier)
        .useCurrentLocation();

    expect(prayer.configureCalls, 1);
    expect(prayer.lastSelectedLocation, isNull);
    expect(preferences.value.prayerCityId, isNull);
    expect(onboarding.state.step, OnboardingStep.developerMessage);
  });

  test('useManualLocation persists city and advances', () async {
    final onboarding = _MemoryOnboardingRepository(
      const OnboardingState(step: OnboardingStep.location, completed: false),
    );
    final preferences = _MemoryPreferencesRepository();
    final prayer = _FakePrayerScheduleRepository();
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        appPreferencesRepositoryProvider.overrideWithValue(preferences),
        prayerScheduleRepositoryProvider.overrideWithValue(prayer),
      ],
    );
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.future);
    await container
        .read(onboardingControllerProvider.notifier)
        .useManualLocation('44');

    expect(prayer.configureCalls, 1);
    expect(prayer.lastSelectedLocation, isNotNull);
    expect(preferences.value.prayerCityId, '44');
    expect(onboarding.state.step, OnboardingStep.developerMessage);
  });

  test('location failure does not advance onboarding', () async {
    final onboarding = _MemoryOnboardingRepository(
      const OnboardingState(step: OnboardingStep.location, completed: false),
    );
    final prayer = _FakePrayerScheduleRepository()..fail = true;
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        appPreferencesRepositoryProvider.overrideWithValue(
          _MemoryPreferencesRepository(),
        ),
        prayerScheduleRepositoryProvider.overrideWithValue(prayer),
      ],
    );
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.future);
    await expectLater(
      container
          .read(onboardingControllerProvider.notifier)
          .useCurrentLocation(),
      throwsA(isA<StateError>()),
    );

    expect(onboarding.state.step, OnboardingStep.location);
  });

  test('skipLocation advances without configuring prayer location', () async {
    final onboarding = _MemoryOnboardingRepository(
      const OnboardingState(step: OnboardingStep.location, completed: false),
    );
    final prayer = _FakePrayerScheduleRepository();
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        appPreferencesRepositoryProvider.overrideWithValue(
          _MemoryPreferencesRepository(),
        ),
        prayerScheduleRepositoryProvider.overrideWithValue(prayer),
      ],
    );
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.future);
    await container.read(onboardingControllerProvider.notifier).skipLocation();

    expect(prayer.configureCalls, 0);
    expect(onboarding.state.step, OnboardingStep.developerMessage);
  });
}

class _MemoryOnboardingRepository implements OnboardingRepository {
  _MemoryOnboardingRepository([
    this.state = const OnboardingState(
      step: OnboardingStep.language,
      completed: false,
    ),
  ]);

  OnboardingState state;

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

class _FakePrayerScheduleRepository extends PrayerScheduleRepository {
  _FakePrayerScheduleRepository();

  int configureCalls = 0;
  PrayerLocation? lastSelectedLocation;
  bool fail = false;

  @override
  Future<PrayerLocation> configureLocation(
    PrayerLocation? selectedLocation, {
    AsrSchool school = AsrSchool.hanafi,
  }) async {
    configureCalls++;
    lastSelectedLocation = selectedLocation;
    if (fail) throw StateError('location failed');
    return selectedLocation ??
        const PrayerLocation(name: 'Fixture GPS', latitude: 24, longitude: 90);
  }
}
