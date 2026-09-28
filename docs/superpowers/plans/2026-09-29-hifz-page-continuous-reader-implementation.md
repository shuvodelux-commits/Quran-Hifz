# Hifz Page + Continuous Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add reliable Page and Continuous Hifz reading modes, playback highlighting/follow, anchored Bangla word meanings, large-text vertical growth, and precise silent-reading auto-scroll while preserving the approved Mushaf appearance and all existing Hifz behavior.

**Architecture:** Keep the existing strict QCF Mushaf renderer as the single visual rendering path. Extend its Flutter↔WebView protocol with page metrics and playback-target geometry, then compose the same rendered logical pages either in the existing horizontal Page mode or a new vertically scrolling Continuous mode. Persist Hifz-only reader preferences through `AppPreferences`; audio-follow and silent auto-scroll remain separate state machines.

**Tech Stack:** Flutter, Dart, Riverpod, Drift settings persistence, `webview_flutter`, bundled HTML/CSS/JavaScript Mushaf renderer, Flutter widget/unit tests.

**Spec:** `docs/superpowers/specs/2026-09-29-hifz-page-continuous-reader-design.md`

## Global Constraints

- Do not redesign the current Hifz Mushaf appearance.
- Preserve QCF V2 / QCF V4 Tajweed selection, Hifz font-size range `20..56`, Hifz line-height range `1.20..2.40`, Tajweed behavior, Surah/Bismillah rules, ayah markers, selected-range treatment, repeat/session logic, and hide/reveal.
- Page mode remains the default.
- Normal Quran reader layout, settings, translation behavior, and existing playback-follow behavior must remain unchanged.
- Continuous mode shows complete canonical Mushaf pages, not selected-ayah cards.
- Continuous auto-scroll is silent-reading only. Any audio playback turns it Off and it does not automatically resume after audio ends.
- Manual dragging does **not** turn Continuous auto-scroll Off. It temporarily suspends automatic motion and auto-scroll resumes from the user's new position after the gesture ends.
- The existing `showPlaybackBanglaWordMeaning` preference controls Hifz playback/tapped-word meaning bubbles too.
- Use existing `QuranAudioState.ayahKey` and `activeWordPosition`; do not create a second audio timing engine.
- Missing Bangla word meaning must not block playback.
- Use TDD for every behavior change. For bugs, use `superpowers:systematic-debugging` before editing production code.
- At execution start, create an isolated worktree/branch from the latest `main`; never implement directly on `main`.
- Before claiming completion, run fresh targeted tests, `flutter analyze`, `git diff --check`, release build, and a full-suite comparison against the pre-change baseline.
- Current recent full-suite history contains one unrelated Bismillah-size failure; re-establish the baseline before Task 1 and do not introduce any additional failures.

## Review Focus

- **Android WebView lifecycle:** returning to an already-created PageView child or switching modes must not leave a blank renderer; Task 3 adds lifecycle/readiness tests and the real-device acceptance pass.
- **Stale async renderer events:** metrics or playback geometry from a previous generation/page must never resize or scroll the current surface; Tasks 2 and 5 test generation rejection.
- **Rapid playback + page boundary:** word timing may advance while the target page is loading; Task 6 tests page load → ready → follow ordering.
- **Manual drag during auto-scroll:** user gesture must win without clearing the enabled preference, then automatic motion must resume from the new position; Task 7 tests this explicitly.
- **Large font + long pages:** reported content height must grow without clipping, shrink-to-fit, horizontal overflow, or changing the idle visual style; Tasks 2, 4, and 5 cover this and the real-device pass rechecks it.

---

### Task 1: Persist Hifz reader mode and precise auto-scroll preferences

**Files:**
- Create: `lib/features/hifz/domain/hifz_reader_mode.dart`
- Modify: `lib/features/settings/domain/app_preferences.dart`
- Modify: `lib/features/settings/application/app_preferences_controller.dart`
- Modify: `lib/features/settings/data/user_database_app_preferences_repository.dart`
- Test: `test/features/settings/domain/app_preferences_test.dart`
- Test: `test/features/settings/application/app_preferences_controller_test.dart`
- Test: `test/features/settings/data/user_database_app_preferences_repository_test.dart`

**Interfaces:**
- Produces: `enum HifzReaderMode { page, continuous }`
- Produces: `AppPreferences.hifzReaderMode`, `hifzContinuousAutoScrollEnabled`, `hifzAutoScrollSpeed`
- Produces: `setHifzReaderMode(HifzReaderMode)`, `setHifzContinuousAutoScrollEnabled(bool)`, `setHifzAutoScrollSpeed(double)`
- Produces providers: `hifzReaderModeProvider`, `hifzContinuousAutoScrollEnabledProvider`, `hifzAutoScrollSpeedProvider`
- Persists keys: `hifz_reader_mode_v1`, `hifz_continuous_auto_scroll_v1`, `hifz_auto_scroll_speed_v1`

- [ ] **Step 1: Establish the pre-change test baseline**

Run:
```bash
flutter test --fail-fast
```

Expected: record the exact pass/fail count and confirm whether the known unrelated Bismillah-size failure is still the only failure. Save this in the execution ledger before editing code.

- [ ] **Step 2: Write failing preference-domain tests**

Add assertions that defaults are:

```dart
expect(preferences.hifzReaderMode, HifzReaderMode.page);
expect(preferences.hifzContinuousAutoScrollEnabled, isFalse);
expect(preferences.hifzAutoScrollSpeed, 0.35);
```

Extend `copyWith` independence tests to prove changing the new Hifz fields does not change normal Quran typography/preferences.

- [ ] **Step 3: Run domain tests and confirm RED**

Run:
```bash
flutter test test/features/settings/domain/app_preferences_test.dart
```

Expected: FAIL because the new enum/fields do not exist.

- [ ] **Step 4: Implement the preference model and controller APIs**

Add `HifzReaderMode`, the three fields/defaults/copyWith parameters, providers, setters, and validation:

```dart
Future<void> setHifzAutoScrollSpeed(double value)
```

must reject non-finite values and values outside `0.0..1.0`.

- [ ] **Step 5: Write and run controller tests**

Add tests that:
- mode changes independently;
- enable/disable changes independently;
- exact slider values such as `0.173` are preserved;
- `double.nan`, `-0.01`, and `1.01` throw `ArgumentError`.

Run:
```bash
flutter test test/features/settings/application/app_preferences_controller_test.dart
```

Expected: PASS.

- [ ] **Step 6: Write persistence tests RED, then implement repository keys**

Test:
- all three values round-trip;
- missing keys return defaults;
- unknown mode falls back to Page;
- malformed/non-finite/out-of-range speed falls back to `0.35`.

Run before implementation:
```bash
flutter test test/features/settings/data/user_database_app_preferences_repository_test.dart
```

Expected: FAIL on missing persistence.

Implement load/save in `UserDatabaseAppPreferencesRepository`, then rerun.

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/features/hifz/domain/hifz_reader_mode.dart lib/features/settings test/features/settings
git commit -m "feat: persist Hifz reader behavior preferences"
```

---

### Task 2: Extend the Mushaf bridge with page metrics and playback-target geometry

**Files:**
- Modify: `lib/features/quran/presentation/mushaf/mushaf_renderer_message.dart`
- Modify: `lib/features/quran/presentation/mushaf/mushaf_webview_driver.dart`
- Modify: `assets/mushaf/renderer/mushaf.js`
- Modify: `assets/mushaf/renderer/mushaf.css`
- Test: `test/features/quran/presentation/mushaf/mushaf_renderer_message_test.dart`
- Test: `test/features/quran/presentation/mushaf/mushaf_webview_driver_test.dart`

**Interfaces:**
- Produces: `MushafPageMetricsEvent(page, generation, contentHeight)`
- Produces: `MushafPlaybackTargetEvent(page, generation, ayahKey, wordPosition, top, bottom)`
- Changes: `MushafWebViewDriver.setActiveWord(String ayahKey, int wordPosition, {String? banglaMeaning})`
- Renderer emits fresh page metrics after initial render and every typography change.
- Renderer emits playback-target geometry after active ayah/word changes.

- [ ] **Step 1: Write failing renderer-message parsing tests**

Add exact parsing/validation tests for:
- valid `pageMetrics`;
- valid `playbackTarget` with and without `wordPosition`;
- content height must be finite and > 0;
- top/bottom must be finite and `bottom >= top`;
- page must be `1..604`, generation non-negative;
- invalid/stale-like malformed payloads are rejected at parse time.

Run:
```bash
flutter test test/features/quran/presentation/mushaf/mushaf_renderer_message_test.dart
```

Expected: FAIL with unknown event types.

- [ ] **Step 2: Implement Dart event types and parser validation**

Keep the existing event classes unchanged; add only the two new event classes and validation helpers needed by the tests.

- [ ] **Step 3: Write failing driver test for active-word meaning encoding**

Assert:

```dart
await driver.setActiveWord('2:255', 3, banglaMeaning: 'আল্লাহ');
```

encodes `['2:255', 3, 'আল্লাহ']` without literal interpolation into JavaScript.

Run:
```bash
flutter test test/features/quran/presentation/mushaf/mushaf_webview_driver_test.dart
```

Expected: FAIL because the current signature accepts only two arguments.

- [ ] **Step 4: Update driver API and allowed command encoding**

Change only the `setActiveWord` method signature/encoded arguments. Preserve every existing allowed method and security property.

- [ ] **Step 5: Implement renderer metrics + anchored meaning bubble**

In `mushaf.js`:
- after `document.fonts.ready`, compute `.mushaf-page` rendered height and post `pageMetrics`;
- after `setTypography`, schedule a post-layout metrics measurement;
- after `setActiveAyah` / `setActiveWord`, measure the matched target and post `playbackTarget`;
- make `setActiveWord` accept optional Bangla meaning;
- create/update exactly one overlay bubble anchored to the matched word;
- remove the bubble in `clearPlaybackHighlight` and when meaning is absent.

In `mushaf.css`, add only bubble styling and any positioning hooks needed. Do not change idle line/font/page styling.

- [ ] **Step 6: Run renderer protocol tests**

Run:
```bash
flutter test test/features/quran/presentation/mushaf/mushaf_renderer_message_test.dart test/features/quran/presentation/mushaf/mushaf_webview_driver_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/features/quran/presentation/mushaf assets/mushaf/renderer test/features/quran/presentation/mushaf
git commit -m "feat: expose Mushaf page and playback metrics"
```

---

### Task 3: Root-cause and fix the intermittent blank Hifz page

**Files:**
- Modify: `lib/features/quran/presentation/mushaf/quran_strict_mushaf_surface.dart`
- Modify if root cause requires it: `lib/features/quran/presentation/mushaf/quran_mushaf_webview.dart`
- Modify if root cause requires it: `lib/features/quran/presentation/mushaf/quran_strict_reader_body.dart`
- Test: create `test/features/quran/presentation/mushaf/quran_strict_mushaf_surface_test.dart`
- Test: `test/features/hifz/presentation/hifz_reader_page_test.dart`

**Interfaces:**
- Consumes: `MushafPageReadyEvent` from existing bridge.
- Produces: deterministic visible-page readiness: the currently visible page/generation gets one successful render path without requiring PageView movement.
- Must preserve existing retry/fallback behavior.

- [ ] **Step 1: Reproduce before fixing**

Use `superpowers:systematic-debugging`. Instrument the existing lifecycle only as needed to determine whether the blank state is caused by:
- page/window availability;
- font future readiness;
- WebView driver readiness;
- render dispatch;
- `pageReady` delivery;
- visible PageView slot lifecycle.

Do not modify the production control flow until the first missing readiness transition is identified.

- [ ] **Step 2: Add the smallest failing regression test that matches the confirmed cause**

The test must prove the exact failing lifecycle. At minimum it must simulate:
- surface created;
- font future completes;
- driver becomes ready;
- render is requested for the current generation;
- page-ready arrives;
- no page swipe/rebuild is needed.

If the confirmed cause is PageView/offstage lifecycle, add the corresponding Hifz reader widget test that leaves the initial page stationary.

Run the specific new test.

Expected: RED and directly reproduce the confirmed missing transition.

- [ ] **Step 3: Implement the minimal readiness fix**

Examples of acceptable fixes depending on evidence:
- replay latest render payload when a newly visible driver becomes ready;
- keep an explicit pending-render generation until `pageReady`;
- ignore stale completion from a prior generation;
- force render dispatch on PageView reattachment without recreating typography state.

Do not add blind delays, forced page jumps, or synthetic swipes.

- [ ] **Step 4: Add stale-generation coverage**

Prove that a late `pageReady`/metrics event from an old generation does not mark or resize the current generation.

- [ ] **Step 5: Verify targeted lifecycle tests**

Run:
```bash
flutter test test/features/quran/presentation/mushaf/quran_strict_mushaf_surface_test.dart test/features/hifz/presentation/hifz_reader_page_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/quran/presentation/mushaf test/features/quran/presentation/mushaf test/features/hifz/presentation/hifz_reader_page_test.dart
git commit -m "fix: render initial Hifz Mushaf page reliably"
```

---

### Task 4: Keep Page mode unchanged while making tall pages scroll safely

**Files:**
- Modify: `lib/features/quran/presentation/mushaf/quran_strict_reader_body.dart`
- Modify: `lib/features/quran/presentation/mushaf/quran_strict_mushaf_surface.dart`
- Test: `test/features/hifz/presentation/hifz_reader_page_test.dart`
- Test: `test/features/quran/presentation/mushaf/quran_strict_mushaf_surface_test.dart`

**Interfaces:**
- Consumes: page content metrics from Task 2.
- Produces: Page mode stays horizontal at the outer level while a logical page can vertically scroll when rendered height exceeds the available viewport.
- Produces: callback/notification sufficient for Task 6 to position playback within the current page without changing idle layout.

- [ ] **Step 1: Write failing Page-mode regression tests**

Assert:
- Page mode remains a `PageView`;
- existing Hifz QCF variant, font size, line height, Tajweed flags are forwarded unchanged;
- a reported page height larger than viewport creates vertical scroll capacity instead of scaling text down;
- a height at/below viewport keeps the existing non-scrolling visual fit;
- changing size/line height does not reset current logical page.

Run:
```bash
flutter test test/features/hifz/presentation/hifz_reader_page_test.dart test/features/quran/presentation/mushaf/quran_strict_mushaf_surface_test.dart
```

Expected: RED on the new tall-page behavior.

- [ ] **Step 2: Implement height-aware Page host behavior**

Keep PageView navigation and the existing strict surface. Add only a page-local scroll host or equivalent sizing path needed for overflow. Never alter the requested Hifz typography values.

- [ ] **Step 3: Verify both QCF variants through widget fixtures**

Extend tests to assert both `qcfV2` and `qcfV4Tajweed` still receive the same selected values and no exception at 56 px.

- [ ] **Step 4: Commit**

```bash
git add lib/features/quran/presentation/mushaf test/features/quran/presentation/mushaf test/features/hifz/presentation/hifz_reader_page_test.dart
git commit -m "feat: allow tall Hifz pages to scroll vertically"
```

---

### Task 5: Add Continuous mode using the same strict Mushaf pages

**Files:**
- Create: `lib/features/hifz/presentation/hifz_continuous_reader.dart`
- Modify: `lib/features/hifz/presentation/hifz_reader_page.dart`
- Modify: `lib/features/quran/presentation/mushaf/quran_strict_mushaf_surface.dart` only if a sizing callback is needed
- Test: create `test/features/hifz/presentation/hifz_continuous_reader_test.dart`
- Test: `test/features/hifz/presentation/hifz_reader_page_test.dart`

**Interfaces:**
- Consumes: `HifzReaderMode`, existing `ReaderState.windows`, QCF settings, page metrics.
- Produces: `HifzContinuousReader` with outer `ScrollController`, stable page keys, lazy page loading callback, and current-page anchor callback.
- Produces callbacks for Task 6: page key lookup and target positioning using page-local metrics.

- [ ] **Step 1: Write failing Continuous-mode widget tests**

Test:
- Page remains default;
- selecting Continuous swaps only the navigation container, not the page renderer;
- full logical pages appear in canonical vertical order;
- QCF V2/V4 and typography arguments match Page mode exactly;
- reported content height determines each page host height;
- only visible/nearby pages are mounted initially;
- scrolling near the next/previous boundary requests that page;
- switching Page → Continuous and Continuous → Page preserves the current logical page;
- stale metrics with wrong page/generation are ignored.

Run:
```bash
flutter test test/features/hifz/presentation/hifz_continuous_reader_test.dart test/features/hifz/presentation/hifz_reader_page_test.dart
```

Expected: FAIL because Continuous mode does not exist.

- [ ] **Step 2: Implement `HifzContinuousReader`**

Use one vertical Flutter scrollable that owns page positioning. Each logical page uses the same strict surface and actual reported content height; do not enable nested WebView scrolling in Continuous mode.

Load neighboring `QuranPageWindow`/font data incrementally through the existing Hifz page-loading path.

- [ ] **Step 3: Integrate mode selection into `HifzReaderPage`**

Branch only at the reader container:
- `HifzReaderMode.page` → current Page path;
- `HifzReaderMode.continuous` → `HifzContinuousReader`.

Keep top bar, Hifz controls, hide/reveal, session state, Surah change, and appearance entry unchanged.

- [ ] **Step 4: Verify targeted Continuous tests**

Run the same command from Step 1.

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/hifz/presentation/hifz_continuous_reader.dart lib/features/hifz/presentation/hifz_reader_page.dart test/features/hifz/presentation
git commit -m "feat: add continuous Hifz Mushaf reader"
```

---

### Task 6: Add Hifz playback highlight, page/word follow, and Bangla meaning bubble

**Files:**
- Modify: `lib/features/hifz/presentation/hifz_reader_page.dart`
- Modify: `lib/features/hifz/presentation/hifz_continuous_reader.dart`
- Modify: `lib/features/quran/presentation/mushaf/quran_strict_reader_body.dart`
- Modify: `lib/features/quran/presentation/mushaf/quran_strict_mushaf_surface.dart`
- Modify: `assets/mushaf/renderer/mushaf.js`
- Modify: `assets/mushaf/renderer/mushaf.css`
- Test: `test/features/hifz/presentation/hifz_reader_page_test.dart`
- Test: `test/features/hifz/presentation/hifz_continuous_reader_test.dart`
- Test: `test/features/quran/presentation/mushaf/quran_strict_mushaf_surface_test.dart`

**Interfaces:**
- Consumes: `QuranAudioState.ayahKey`, `activeWordPosition`, `showPlaybackBanglaWordMeaningProvider`, `MushafPlaybackTargetEvent`.
- Produces: active ayah + stronger active word renderer state in Hifz.
- Produces: Page-mode page switching/follow and Continuous-mode safe-zone follow.
- Produces: active/tapped word Bangla meaning passed to renderer.

- [ ] **Step 1: Write failing playback visual-state tests**

Assert that Hifz forwards:
- active ayah key;
- active word position;
- matching `QuranWord.banglaMeaning` only when the existing preference is On.

Add the missing-meaning case: highlight/audio remain, meaning argument is null.

- [ ] **Step 2: Write failing tap-to-play meaning test**

Existing word-tap test currently checks only the audio request. Extend it so after tapping a word with a fixture Bangla meaning:
- the tapped word becomes the active word through the test audio state;
- the renderer receives that meaning for the exact word.

Do not change long-press word details.

- [ ] **Step 3: Write failing safe-zone follow tests**

For Page mode:
- active ayah on another logical page triggers `_openPage(targetPage)`;
- follow waits for target page readiness;
- no vertical adjustment when target is already in the safe zone;
- off-screen target gets one smooth correction.

For Continuous mode:
- same-page visible target → no movement;
- target above/below safe zone → move using outer ScrollController;
- wrong generation/page target event → ignored;
- playback crosses page boundary while page is not yet loaded → load, render-ready, then follow.

Use the normal Quran reader behavior as the reference: word-first follow; approximately 260 ms word correction and 320 ms ayah/page correction with `Curves.easeOutCubic`.

- [ ] **Step 4: Implement active meaning resolution in Hifz**

Resolve the current word from the already loaded/available Quran data using `ayahKey + wordPosition`. Do not add a network dependency. Pass meaning through `setActiveWord(..., banglaMeaning: ...)`.

- [ ] **Step 5: Implement Page and Continuous follow**

Create one small Hifz follow helper if needed so both modes share the safe-zone calculation rather than duplicating magic numbers.

Audio-follow only corrects position when needed; it must not run a continuous scrolling loop.

- [ ] **Step 6: Strengthen renderer highlight without changing metrics**

If the current `.active-ayah` style is too subtle to meet the approved requirement, adjust only color/opacity/outline properties. Add a renderer/widget assertion that active styling does not change layout metrics.

Do not change idle Mushaf styles.

- [ ] **Step 7: Verify playback tests**

Run:
```bash
flutter test test/features/hifz/presentation/hifz_reader_page_test.dart test/features/hifz/presentation/hifz_continuous_reader_test.dart test/features/quran/presentation/mushaf/quran_strict_mushaf_surface_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/hifz/presentation lib/features/quran/presentation/mushaf assets/mushaf/renderer test/features/hifz/presentation test/features/quran/presentation/mushaf
git commit -m "feat: follow Hifz playback with word meanings"
```

---

### Task 7: Add precise Continuous silent-reading auto-scroll

**Files:**
- Create: `lib/features/hifz/presentation/hifz_auto_scroll_driver.dart`
- Modify: `lib/features/hifz/presentation/hifz_continuous_reader.dart`
- Test: create `test/features/hifz/presentation/hifz_auto_scroll_driver_test.dart`
- Test: `test/features/hifz/presentation/hifz_continuous_reader_test.dart`

**Interfaces:**
- Produces: `double hifzAutoScrollPixelsPerSecond(double normalizedSpeed)`
- Produces a frame-driven auto-scroll driver that takes current scroll metrics and elapsed time.
- Mapping: `0.0 → 8 px/s`, `1.0 → 72 px/s`, linear.
- Consumes: Continuous mode, enabled preference, audio playing state, user-scroll notifications.

- [ ] **Step 1: Write failing pure speed-mapping tests**

Assert:
```dart
expect(hifzAutoScrollPixelsPerSecond(0), 8);
expect(hifzAutoScrollPixelsPerSecond(1), 72);
expect(hifzAutoScrollPixelsPerSecond(0.5), 40);
```

Also assert invalid normalized values throw.

Run:
```bash
flutter test test/features/hifz/presentation/hifz_auto_scroll_driver_test.dart
```

Expected: FAIL because helper does not exist.

- [ ] **Step 2: Implement mapping and frame-delta driver**

Use elapsed frame time × pixels/second. Clamp every step to current `maxScrollExtent`. Do not schedule one long `animateTo`.

- [ ] **Step 3: Write failing runtime behavior tests**

Prove:
- mode Page → no auto-scroll;
- Continuous + disabled → no auto-scroll;
- Continuous + enabled + no audio → advances;
- slider change while running changes rate without recreating reader;
- audio status becomes playing → preference is turned Off immediately and movement stops;
- audio completion/idle does not re-enable it;
- manual drag start suspends automatic frame movement but leaves preference On;
- manual drag end resumes from the user's new position;
- reaching bottom stops movement but leaves preference On;
- after manual movement upward from bottom, enabled auto-scroll can continue.

- [ ] **Step 4: Implement Continuous integration**

Use `NotificationListener<ScrollNotification>` or equivalent to distinguish user drag from programmatic movement. Keep a transient `_userScrollActive` flag; never write `false` to the preference because of manual drag.

Listen to Quran audio state; when any audio playback starts, call:

```dart
setHifzContinuousAutoScrollEnabled(false)
```

exactly once per transition.

- [ ] **Step 5: Verify auto-scroll tests**

Run:
```bash
flutter test test/features/hifz/presentation/hifz_auto_scroll_driver_test.dart test/features/hifz/presentation/hifz_continuous_reader_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/hifz/presentation test/features/hifz/presentation
git commit -m "feat: add precise Hifz silent auto-scroll"
```

---

### Task 8: Add Page/Continuous and auto-scroll controls to Hifz appearance

**Files:**
- Modify: `lib/features/hifz/presentation/hifz_appearance_sheet.dart`
- Test: `test/features/hifz/presentation/hifz_appearance_sheet_test.dart`

**Interfaces:**
- Consumes: Task 1 preference/controller APIs.
- Existing controls remain unchanged.
- Adds keys:
  - `hifz-reader-mode-page`
  - `hifz-reader-mode-continuous`
  - `hifz-continuous-auto-scroll-switch`
  - `hifz-auto-scroll-speed-slider`

- [ ] **Step 1: Write failing appearance-sheet tests**

Assert:
- existing Mushaf skin/size/line spacing/Tajweed controls still exist and keep current ranges;
- Page is initially selected;
- Continuous controls are hidden in Page mode;
- selecting Continuous reveals the auto-scroll switch;
- speed slider appears when Continuous mode is selected and uses `min: 0`, `max: 1`, `divisions: null`;
- a precise slider value persists;
- Reset restores QCF V4, 32 px, 1.35 line height, Tajweed On, Page mode, auto-scroll Off, speed `0.35`;
- enlarged system text still scrolls without overflow.

Run:
```bash
flutter test test/features/hifz/presentation/hifz_appearance_sheet_test.dart
```

Expected: FAIL on missing controls.

- [ ] **Step 2: Implement the reading-behavior section**

Place it after existing Tajweed control and before Reset. Do not reorder or restyle existing controls unnecessarily.

Use a continuous Slider with no divisions for speed.

- [ ] **Step 3: Verify appearance tests**

Run the same command.

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/features/hifz/presentation/hifz_appearance_sheet.dart test/features/hifz/presentation/hifz_appearance_sheet_test.dart
git commit -m "feat: expose Hifz reader and auto-scroll controls"
```

---

### Task 9: Whole-feature regression verification and Android acceptance

**Files:**
- Modify tests only if a genuine uncovered regression is found.
- No unrelated production refactors.

**Interfaces:**
- Consumes all prior tasks.
- Produces final evidence that the feature satisfies the spec without changing normal Quran behavior.

- [ ] **Step 1: Run all Hifz tests**

```bash
flutter test test/features/hifz
```

Expected: PASS.

- [ ] **Step 2: Run strict Mushaf tests**

```bash
flutter test test/features/quran/presentation/mushaf
```

Expected: PASS.

- [ ] **Step 3: Run normal Quran reader regressions**

```bash
flutter test test/features/quran/presentation/quran_reader_page_test.dart
```

Expected: PASS, including existing normal Quran playback-follow behavior.

- [ ] **Step 4: Run settings preference regressions**

```bash
flutter test test/features/settings/domain/app_preferences_test.dart test/features/settings/application/app_preferences_controller_test.dart test/features/settings/data/user_database_app_preferences_repository_test.dart test/features/hifz/presentation/hifz_appearance_sheet_test.dart
```

Expected: PASS.

- [ ] **Step 5: Run static verification**

```bash
flutter analyze
git diff --check
```

Expected: no analyze errors and no whitespace errors.

- [ ] **Step 6: Run the full suite and compare to Task 1 baseline**

```bash
flutter test --fail-fast
```

Expected: no new failure compared with the baseline. If the pre-existing Bismillah-size failure still exists, document it explicitly; do not call the suite fully green.

- [ ] **Step 7: Build release APK**

```bash
flutter build apk --release
```

Expected: exit code 0 and `build/app/outputs/flutter-apk/app-release.apk` created.

- [ ] **Step 8: Run real-device acceptance on the connected Android device**

Verify all 14 acceptance checks from the spec, with special repetition of the blank-page case:

- open Hifz/reader repeatedly at least 10 times without swiping;
- switch Surah/page and return;
- Page mode idle appearance comparison for QCF V2 and V4;
- 56 px large text with vertical page scrolling;
- Continuous full-page order;
- precise auto-scroll at low/mid/high slider positions;
- manual drag while enabled: movement pauses during gesture, preference remains On, then resumes;
- starting audio: auto-scroll switch becomes Off immediately;
- playback completion: auto-scroll remains Off;
- page-boundary playback follow;
- active ayah + word highlight;
- active/tapped Bangla word meaning above exact word;
- setting Off removes meaning only;
- hide/reveal, repeat pattern, Surah change, stop/finish remain functional.

Capture screenshots/logs only where they materially prove layout or blank-page behavior.

- [ ] **Step 9: Final whole-branch review**

Use `superpowers:requesting-code-review` (fresh reviewer if available) against the spec, this plan, and the complete merge-base..HEAD diff. Critical/Important findings require one TDD fix pass before integration.

- [ ] **Step 10: Final verification after any review fixes**

Repeat Steps 1–7 after the final fix pass.

- [ ] **Step 11: Finish the development branch**

Use `superpowers:finishing-a-development-branch`. Do not merge until the final verification evidence and real-device checks are recorded.
