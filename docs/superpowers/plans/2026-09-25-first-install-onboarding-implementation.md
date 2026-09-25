# First-Install Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a resumable first-install flow for language, prayer location, and the developer dedication, ending with “Start Al Quran”, while preserving all existing app data and settings.

**Architecture:** Store onboarding progress in the existing `AppSettings` table through a dedicated repository and Riverpod controller. Gate the normal shell after the existing splash/content bootstrap, reuse the current prayer-location infrastructure, and expose location setup on Home when onboarding location is skipped.

**Tech Stack:** Flutter, Dart, Riverpod 3, Drift, Material 3, existing prayer-location repository/geolocator stack.

**Spec:** `docs/superpowers/specs/2026-09-25-onboarding-visual-system-quran-reader-design.md`

## Global Constraints

- New onboarding must not hardcode “Quran Hifz”; use neutral copy and “Start Al Quran / আল কুরআন শুরু করুন” for the final CTA.
- Main app blue for onboarding controls is `#27687E`; deeper state `#205766`; gold accent approximately `#D5A44B`; warm canvas approximately `#F7F6F1`; cards white.
- Location is optional and must offer Use current location, Choose manually, and Set up later.
- Onboarding completion is stored only from the final CTA.
- App restart during onboarding resumes the unfinished step.
- No new persistence dependency; use existing `UserDatabase/AppSettings`.
- No analytics, ads, telemetry, or data deletion.
- Support email is currently unset; do not display a fake email row.
- Existing language/location settings remain editable from Settings.
- All touch targets remain at least 44 logical pixels.

## Review Focus

- Corrupt/unknown onboarding setting values must fall back to the language step rather than trapping startup.
- A saved `completed=true` state must always enter the normal shell even if the saved step value is stale.
- Location permission denial or disabled GPS must leave the user on the location step with retry/manual/skip paths.
- Closing the app after changing language but before the next step must preserve language and resume at the correct onboarding step.
- Skipping location must never fabricate prayer times; Home must surface “Set location / লোকেশন সেট করুন” at the location area.

---

### Task 1: Onboarding persistence and state controller

**Files:**
- Create: `lib/features/onboarding/domain/onboarding_state.dart`
- Create: `lib/features/onboarding/domain/onboarding_repository.dart`
- Create: `lib/features/onboarding/data/user_database_onboarding_repository.dart`
- Create: `lib/features/onboarding/application/onboarding_controller.dart`
- Create: `test/features/onboarding/data/user_database_onboarding_repository_test.dart`
- Create: `test/features/onboarding/application/onboarding_controller_test.dart`

**Interfaces:**
- Produces: `enum OnboardingStep { language, location, developerMessage, completed }`
- Produces: `OnboardingState(step:, completed:)`
- Produces: `OnboardingRepository.load()`, `saveStep(OnboardingStep)`, `complete()`
- Produces: `onboardingControllerProvider` and controller methods `selectLanguage`, `goToDeveloperMessage`, `complete`

- [ ] **Step 1: Write failing repository tests**

Add tests proving default state, round-trip progress, atomic completion, and corrupt-value normalization:

```dart
test('missing settings start at language and incomplete', () async {
  final db = UserDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final repo = UserDatabaseOnboardingRepository(db);

  expect(
    await repo.load(),
    const OnboardingState(
      step: OnboardingStep.language,
      completed: false,
    ),
  );
});

test('completed flag wins over stale step', () async {
  final db = UserDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await db.saveSetting(
    UserDatabaseOnboardingRepository.stepKey,
    OnboardingStep.location.name,
  );
  await db.saveSetting(
    UserDatabaseOnboardingRepository.completedKey,
    'true',
  );

  final state = await UserDatabaseOnboardingRepository(db).load();
  expect(state.completed, isTrue);
  expect(state.step, OnboardingStep.completed);
});
```

- [ ] **Step 2: Run repository tests to verify RED**

Run:
```bash
flutter test test/features/onboarding/data/user_database_onboarding_repository_test.dart
```

Expected: FAIL because onboarding classes do not exist.

- [ ] **Step 3: Implement domain state and repository**

Use these persistence keys:

```dart
static const stepKey = 'onboarding_step_v1';
static const completedKey = 'onboarding_completed_v1';
```

Normalize unknown values to `OnboardingStep.language`. `complete()` must write both settings in one `UserDatabase.transaction`.

- [ ] **Step 4: Re-run repository tests**

Run:
```bash
flutter test test/features/onboarding/data/user_database_onboarding_repository_test.dart
```

Expected: PASS.

- [ ] **Step 5: Write failing controller tests**

Cover language persistence and progress ordering:

```dart
test('language is saved before advancing to location', () async {
  final container = ProviderContainer(
    overrides: [
      onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepo),
      appPreferencesRepositoryProvider.overrideWithValue(fakePreferencesRepo),
    ],
  );
  addTearDown(container.dispose);

  await container.read(onboardingControllerProvider.future);
  await container
      .read(onboardingControllerProvider.notifier)
      .selectLanguage(AppLanguage.english);

  expect(fakePreferencesRepo.value.language, AppLanguage.english);
  expect(
    container.read(onboardingControllerProvider).requireValue.step,
    OnboardingStep.location,
  );
});
```

Also test that a preferences save failure does not advance the onboarding repository.

- [ ] **Step 6: Run controller tests to verify RED**

Run:
```bash
flutter test test/features/onboarding/application/onboarding_controller_test.dart
```

Expected: FAIL because the controller/provider is missing.

- [ ] **Step 7: Implement the Riverpod controller**

Provider wiring:

```dart
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return UserDatabaseOnboardingRepository(ref.watch(userDatabaseProvider));
});

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
```

`selectLanguage` must:
1. save via `AppPreferencesController.setLanguage`
2. save onboarding step `location`
3. publish the new state only after both writes succeed.

`goToDeveloperMessage` persists `developerMessage`. `complete` calls repository `complete()`.

- [ ] **Step 8: Run both focused test files**

Run:
```bash
flutter test test/features/onboarding/data/user_database_onboarding_repository_test.dart test/features/onboarding/application/onboarding_controller_test.dart
```

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/features/onboarding test/features/onboarding
git commit -m "feat: add onboarding persistence"
```

---

### Task 2: App gate, Islamic hero, and language step

**Files:**
- Create: `lib/features/onboarding/presentation/onboarding_gate.dart`
- Create: `lib/features/onboarding/presentation/onboarding_flow.dart`
- Create: `lib/features/onboarding/presentation/widgets/islamic_onboarding_hero.dart`
- Create: `lib/features/onboarding/presentation/language_onboarding_page.dart`
- Modify: `lib/app/quran_hifz_app.dart`
- Modify: `test/app/app_bootstrap_test.dart`
- Create: `test/features/onboarding/presentation/language_onboarding_page_test.dart`

**Interfaces:**
- Consumes: `onboardingControllerProvider`
- Produces: `OnboardingGate(completedChild: Widget)`
- Produces: `OnboardingFlow`
- Produces: reusable `IslamicOnboardingHero(icon:, arabicLine:)`

- [ ] **Step 1: Write failing bootstrap gate tests**

Add explicit provider overrides so existing bootstrap tests remain deterministic.

New cases:

```dart
testWidgets('incomplete onboarding appears before the normal shell', (tester) async {
  // provide a completed Quran bootstrap and incomplete onboarding state
  await tester.pumpWidget(...);
  await tester.pumpAndSettle();

  expect(find.byType(QuranHifzShell), findsNothing);
  expect(find.text('আপনার ভাষা নির্বাচন করুন'), findsOneWidget);
});

testWidgets('completed onboarding opens the normal shell', (tester) async {
  // same bootstrap, completed onboarding override
  await tester.pumpWidget(...);
  await tester.pumpAndSettle();

  expect(find.byType(QuranHifzShell), findsOneWidget);
});
```

- [ ] **Step 2: Run the bootstrap test to verify RED**

Run:
```bash
flutter test test/app/app_bootstrap_test.dart
```

Expected: new gate assertions fail.

- [ ] **Step 3: Implement `OnboardingGate` and wire app root**

Target structure:

```dart
home: const AppOpeningSplash(
  child: QuranContentBootstrapGate(
    child: OnboardingGate(
      completedChild: QuranHifzShell(),
    ),
  ),
),
```

`OnboardingGate`:
- loading -> centered progress indicator
- error -> localized retry button that invalidates `onboardingControllerProvider`
- completed -> `completedChild`
- incomplete -> `OnboardingFlow`

- [ ] **Step 4: Write failing language-page tests**

Verify:
- Bangla and English options exist
- current language is selected
- tapping English calls controller and changes displayed UI language after provider update
- button/action target is >= 44 px
- no “Quran Hifz” text exists on onboarding

- [ ] **Step 5: Run language-page tests to verify RED**

Run:
```bash
flutter test test/features/onboarding/presentation/language_onboarding_page_test.dart
```

Expected: FAIL.

- [ ] **Step 6: Implement Islamic hero and language page**

Use:
- canvas/surface derived from `#F7F6F1`
- primary `#27687E`
- restrained `#D5A44B` star/accent
- subtle arch geometry via `CustomPainter` or border primitives
- Bismillah line as decorative Arabic
- no product-name text

Required Bangla CTA: `পরবর্তী`; English: `Next`.

- [ ] **Step 7: Run focused tests**

Run:
```bash
flutter test test/app/app_bootstrap_test.dart test/features/onboarding/presentation/language_onboarding_page_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/app/quran_hifz_app.dart lib/features/onboarding/presentation test/app/app_bootstrap_test.dart test/features/onboarding/presentation
git commit -m "feat: add first install language flow"
```

---

### Task 3: Location step, existing location reuse, and Home set-location prompt

**Files:**
- Modify: `lib/features/home/presentation/home_page.dart`
- Modify: `lib/features/home/presentation/prayer_location_page.dart`
- Modify: `lib/features/home/presentation/home_dashboard_page.dart`
- Modify: `lib/features/onboarding/application/onboarding_controller.dart`
- Create: `lib/features/onboarding/presentation/location_onboarding_page.dart`
- Create: `test/features/onboarding/presentation/location_onboarding_page_test.dart`
- Modify: `test/features/home/presentation/home_dashboard_page_test.dart`
- Modify: `test/features/onboarding/application/onboarding_controller_test.dart`

**Interfaces:**
- Produces: `prayerLocationStoreProvider`
- Produces: `savedPrayerLocationProvider`
- Adds controller methods `useCurrentLocation()`, `useManualLocation(String cityId)`, `skipLocation()`
- Extends `PrayerLocationPage` with `manualOnly` and returns `true` when configuration succeeds

- [ ] **Step 1: Write failing provider/controller tests**

Cover:
- current-location success configures repository, clears city ID, invalidates prayer/saved-location providers, advances to developer message
- manual city success stores the city ID and advances
- configuration failure does not advance
- skip advances without calling location repository

- [ ] **Step 2: Run controller tests to verify RED**

Run:
```bash
flutter test test/features/onboarding/application/onboarding_controller_test.dart
```

Expected: FAIL for missing location methods/providers.

- [ ] **Step 3: Extract location-store providers and implement controller actions**

In `home_page.dart`:

```dart
final prayerLocationStoreProvider = Provider<PrayerLocationStore>((ref) {
  return UserDatabasePrayerLocationStore(ref.watch(userDatabaseProvider));
});

final savedPrayerLocationProvider = FutureProvider<PrayerLocation?>((ref) {
  return ref.watch(prayerLocationStoreProvider).load();
});
```

Make `prayerScheduleRepositoryProvider` consume `prayerLocationStoreProvider`.

After successful configuration:

```dart
ref.invalidate(savedPrayerLocationProvider);
ref.invalidate(prayerScheduleProvider);
```

- [ ] **Step 4: Write failing location page tests**

Verify exact top action order:

```dart
expect(find.text('বর্তমান লোকেশন ব্যবহার করুন'), findsOneWidget);
expect(find.text('ম্যানুয়ালি নির্বাচন করুন'), findsOneWidget);
expect(find.text('পরে সেট করুন'), findsOneWidget);
```

Also verify English equivalents and that permission/configuration error leaves all three recovery paths usable.

- [ ] **Step 5: Run location-page tests to verify RED**

Run:
```bash
flutter test test/features/onboarding/presentation/location_onboarding_page_test.dart
```

Expected: FAIL.

- [ ] **Step 6: Implement location onboarding UI and manual-page reuse**

`PrayerLocationPage` constructor:

```dart
const PrayerLocationPage({
  super.key,
  this.manualOnly = false,
});

final bool manualOnly;
```

Hide the GPS list tile when `manualOnly == true`, and on successful selection:

```dart
if (mounted) Navigator.of(context).pop(true);
```

The onboarding manual button pushes `PrayerLocationPage(manualOnly: true)`; on `true`, advance to the developer-message step.

- [ ] **Step 7: Write failing Home prompt test**

When both saved location and city are absent, assert:

```dart
expect(find.text('লোকেশন সেট করুন'), findsOneWidget);
expect(find.text('Set location'), findsNothing);
```

For English override assert `Set location`.

Also assert no concrete prayer time is fabricated from a null schedule.

- [ ] **Step 8: Run Home test to verify RED**

Run:
```bash
flutter test test/features/home/presentation/home_dashboard_page_test.dart
```

Expected: FAIL for old “Location/অবস্থান” fallback.

- [ ] **Step 9: Implement the Home top-location prompt**

At the existing top location InkWell:
- use `savedPrayerLocationProvider`
- when resolved null and no selected city, show `লোকেশন সেট করুন / Set location`
- subtitle explains that location is needed for accurate prayer times
- tap continues to open `PrayerLocationPage`
- do not inject any guessed schedule.

- [ ] **Step 10: Run focused location/Home tests**

Run:
```bash
flutter test test/features/onboarding/application/onboarding_controller_test.dart test/features/onboarding/presentation/location_onboarding_page_test.dart test/features/home/presentation/home_dashboard_page_test.dart
```

Expected: PASS.

- [ ] **Step 11: Commit**

```bash
git add lib/features/onboarding lib/features/home test/features/onboarding test/features/home
git commit -m "feat: add onboarding location setup"
```

---

### Task 4: Developer dedication page and complete lifecycle regression

**Files:**
- Create: `lib/features/onboarding/presentation/onboarding_copy.dart`
- Create: `lib/features/onboarding/presentation/developer_message_page.dart`
- Modify: `lib/features/onboarding/presentation/onboarding_flow.dart`
- Create: `test/features/onboarding/presentation/developer_message_page_test.dart`
- Create: `test/features/onboarding/presentation/onboarding_flow_test.dart`

**Interfaces:**
- Consumes: `onboardingControllerProvider.complete()`
- Produces: centralized dedication/privacy copy
- Produces: `const String? onboardingSupportEmail = null`; email row renders only when non-null/non-empty

- [ ] **Step 1: Write failing developer-page tests**

Verify:
- Bangla dedication includes `মরহুম জারজিস হোসেন প্রামাণিক`
- privacy text does not claim the app is completely offline
- no fake support email is visible when `onboardingSupportEmail == null`
- final CTA is exactly `আল কুরআন শুরু করুন` in Bangla and `Start Al Quran` in English
- tapping final CTA calls completion only once

- [ ] **Step 2: Run developer-page test to verify RED**

Run:
```bash
flutter test test/features/onboarding/presentation/developer_message_page_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement copy and developer page**

Centralized privacy meaning:
- ad-free
- developer does not collect or sell personal information
- local app data stays on device
- internet may be required for location setup and online/downloadable content

Render the dedication as a white card with a narrow gold accent and the approved Islamic hero. Hide the email row while the configured address is null.

- [ ] **Step 4: Write failing full-flow lifecycle test**

Simulate:
1. fresh state -> language page
2. select English -> location step
3. skip location -> developer step
4. rebuild ProviderScope using same in-memory database -> developer step resumes
5. tap `Start Al Quran` -> normal shell
6. rebuild again -> normal shell directly

- [ ] **Step 5: Run lifecycle test to verify RED**

Run:
```bash
flutter test test/features/onboarding/presentation/onboarding_flow_test.dart
```

Expected: FAIL until flow wiring is complete.

- [ ] **Step 6: Complete `OnboardingFlow` step switching**

Use an exhaustive switch:

```dart
return switch (state.step) {
  OnboardingStep.language => const LanguageOnboardingPage(),
  OnboardingStep.location => const LocationOnboardingPage(),
  OnboardingStep.developerMessage => const DeveloperMessagePage(),
  OnboardingStep.completed => completedChild,
};
```

Ensure the gate, not a page-local flag, is the source of truth after completion.

- [ ] **Step 7: Run all onboarding + Home focused tests**

Run:
```bash
flutter test test/features/onboarding test/app/app_bootstrap_test.dart test/features/home/presentation/home_dashboard_page_test.dart
```

Expected: PASS.

- [ ] **Step 8: Run static analysis**

Run:
```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 9: Commit**

```bash
git add lib/features/onboarding lib/app/quran_hifz_app.dart lib/features/home test/features/onboarding test/app/app_bootstrap_test.dart test/features/home/presentation/home_dashboard_page_test.dart
git commit -m "feat: complete first install onboarding"
```
