import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/presentation/home_page.dart';
import 'package:quran_hifz/features/home/presentation/prayer_location_page.dart';
import 'package:quran_hifz/features/onboarding/application/onboarding_controller.dart';
import 'package:quran_hifz/features/onboarding/data/user_database_onboarding_repository.dart';
import 'package:quran_hifz/features/onboarding/domain/onboarding_state.dart';
import 'package:quran_hifz/features/onboarding/presentation/location_onboarding_page.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('location page shows current manual and later in order', (
    tester,
  ) async {
    final fixture = await _pump(tester);

    final current = find.byKey(const ValueKey('onboarding-location-current'));
    final manual = find.byKey(const ValueKey('onboarding-location-manual'));
    final later = find.byKey(const ValueKey('onboarding-location-later'));

    expect(find.text('লোকেশন সেট করুন'), findsOneWidget);
    expect(current, findsOneWidget);
    expect(manual, findsOneWidget);
    expect(later, findsOneWidget);
    expect(
      tester.getTopLeft(current).dy,
      lessThan(tester.getTopLeft(manual).dy),
    );
    expect(tester.getTopLeft(manual).dy, lessThan(tester.getTopLeft(later).dy));

    await tester.tap(later);
    await tester.pumpAndSettle();

    expect(
      fixture.container.read(onboardingControllerProvider).requireValue.step,
      OnboardingStep.developerMessage,
    );
  });

  testWidgets('current location configures and advances', (tester) async {
    final fixture = await _pump(tester);

    await tester.tap(find.byKey(const ValueKey('onboarding-location-current')));
    await tester.pumpAndSettle();

    expect(fixture.prayer.configureCalls, 1);
    expect(
      fixture.container.read(onboardingControllerProvider).requireValue.step,
      OnboardingStep.developerMessage,
    );
  });

  testWidgets('manual location opens manual-only Bangladesh selector', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.byKey(const ValueKey('onboarding-location-manual')));
    await tester.pumpAndSettle();

    expect(find.byType(PrayerLocationPage), findsOneWidget);
    expect(find.text('GPS অবস্থান ব্যবহার করুন'), findsNothing);
    expect(find.text('Use GPS location'), findsNothing);
  });

  testWidgets('location error leaves retry manual and skip available', (
    tester,
  ) async {
    final fixture = await _pump(tester, failLocation: true);

    await tester.tap(find.byKey(const ValueKey('onboarding-location-current')));
    await tester.pumpAndSettle();

    expect(find.textContaining('আবার চেষ্টা'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('onboarding-location-current')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('onboarding-location-manual')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('onboarding-location-later')),
      findsOneWidget,
    );
    expect(
      fixture.container.read(onboardingControllerProvider).requireValue.step,
      OnboardingStep.location,
    );
  });
}

Future<({ProviderContainer container, _FakePrayerRepository prayer})> _pump(
  WidgetTester tester, {
  bool failLocation = false,
}) async {
  final db = UserDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prayer = _FakePrayerRepository()..fail = failLocation;
  await db.saveSetting(
    UserDatabaseOnboardingRepository.stepKey,
    OnboardingStep.location.name,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userDatabaseProvider.overrideWithValue(db),
        prayerScheduleRepositoryProvider.overrideWithValue(prayer),
      ],
      child: const MaterialApp(home: LocationOnboardingPage()),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(LocationOnboardingPage)),
  );
  await container.read(onboardingControllerProvider.future);

  return (container: container, prayer: prayer);
}

class _FakePrayerRepository extends PrayerScheduleRepository {
  int configureCalls = 0;
  bool fail = false;

  @override
  Future<PrayerLocation> configureLocation(
    PrayerLocation? selectedLocation, {
    AsrSchool school = AsrSchool.hanafi,
  }) async {
    configureCalls++;
    if (fail) throw StateError('location failed');
    return selectedLocation ??
        const PrayerLocation(name: 'Fixture GPS', latitude: 24, longitude: 90);
  }
}
