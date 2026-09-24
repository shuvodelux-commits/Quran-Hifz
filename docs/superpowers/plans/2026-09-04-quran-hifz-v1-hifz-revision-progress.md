# Quran Hifz V1 Hifz, Revision, and Progress Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add deterministic same-Surah Hifz practice, memorization tests, persistent state/history, spaced revision, and read-only progress aggregation on top of the proven audio/offline foundation.

**Architecture:** Hifz plans immutable playback steps and delegates execution to `QuranAudioController`. Current Hifz state and immutable review history are persisted in `UserDatabase`. Revision uses an injected clock and deterministic intervals. Progress only aggregates repositories.

**Tech Stack:** Flutter/Dart, Riverpod, Drift/SQLite, existing QuranAudioController.

**Spec:** `docs/superpowers/specs/2026-09-04-quran-hifz-v1-architecture-design.md`

## Global Constraints

- V1 Hifz ranges stay inside one Surah.
- Hifz does not instantiate an audio player.
- Canonical Quran words are never modified to implement hiding tests.
- Review intervals are exactly 1, 2, 4, 7, 14, 30, 60 days.
- Revision tests use an injected clock.

---

### Task 1: Build immutable Hifz sequence engine

**Files:**
- Create: `lib/features/hifz/domain/hifz_preset.dart`
- Create: `lib/features/hifz/domain/hifz_step.dart`
- Create: `lib/features/hifz/domain/hifz_session.dart`
- Create: `lib/features/hifz/application/hifz_sequence_builder.dart`
- Create: `test/features/hifz/application/hifz_sequence_builder_test.dart`

**Interfaces:**
- `HifzSequenceBuilder.build(HifzSessionConfig config) -> List<HifzStep>`.
- Steps are `AyahStep` or `RangeStep` with explicit repeat count/pause policy.

- [ ] **Step 1: Write exact sequence tests**

For Al-Mulk 1–3 New Memorization, assert exact ordered steps:

```text
67:1 ×5
67:2 ×5
67:1-2 ×3
67:3 ×5
67:1-3 ×3
```

Also test single ayah, invalid reverse range, and cross-Surah rejection.

- [ ] **Step 2: Run failure**

```bash
flutter test test/features/hifz/application/hifz_sequence_builder_test.dart
```

- [ ] **Step 3: Implement presets and pure builder**

No database/audio imports in the sequence builder.

- [ ] **Step 4: Run/commit**

```bash
dart format lib test
flutter analyze
flutter test test/features/hifz/application/hifz_sequence_builder_test.dart
git add lib test
git commit -m "feat: add deterministic Hifz sequence engine"
```

---

### Task 2: Persist Hifz state and execute sessions through audio controller

**Files:**
- Add tables: `lib/core/database/user_database.dart`
- Refactor existing: `lib/features/hifz/domain/hifz_progress.dart`
- Create: `lib/features/hifz/domain/hifz_repository.dart`
- Create: `lib/features/hifz/data/drift_hifz_repository.dart`
- Create: `lib/features/hifz/application/hifz_session_controller.dart`
- Create: `lib/features/hifz/presentation/hifz_page.dart`
- Create: `test/features/hifz/application/hifz_session_controller_test.dart`
- Create: `test/features/hifz/data/drift_hifz_repository_test.dart`

**Interfaces:**
- `HifzSessionController.start(config)`, `pause()`, `resume()`, `stop()`.
- Repository persists current status plus resume checkpoint independently from audio implementation.

- [ ] **Step 1: Write controller tests with fake QuranAudioController port**

Verify step order, cancellation, resume checkpoint, end-of-range completion, and no direct media-player dependency.

- [ ] **Step 2: Write repository migration/persistence tests**

Insert learning state/history, close DB, reopen, assert exact preservation.

- [ ] **Step 3: Implement tables/repository/controller/UI**

The UI selects Surah, start/end ayah, preset, and starts a session. Prevent cross-Surah selection in the UI and domain validation.

- [ ] **Step 4: Run gate and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test test/features/hifz
git add lib test
git commit -m "feat: persist and execute Hifz sessions"
```

---

### Task 3: Add reveal and progressive-hide memorization tests

**Files:**
- Create: `lib/features/hifz/domain/memorization_result.dart`
- Create: `lib/features/hifz/application/progressive_hide_generator.dart`
- Create: `lib/features/hifz/presentation/memorization_test_page.dart`
- Create: `test/features/hifz/application/progressive_hide_generator_test.dart`
- Create: `test/features/hifz/presentation/memorization_test_page_test.dart`

**Interfaces:**
- `ProgressiveHideGenerator.maskFor(words, round, difficulty) -> List<bool>` where `true` means render the original canonical word and `false` means render a neutral placeholder.

- [ ] **Step 1: Write purity/determinism tests**

Assert the generator never changes input `QuranWord` objects or Arabic strings and returns deterministic masks for the same seed/configuration.

- [ ] **Step 2: Write widget test**

Verify Reveal shows the original words from repository state and the four result buttons produce domain results `perfect`, `smallMistake`, `difficult`, `forgot`.

- [ ] **Step 3: Implement and run tests**

```bash
dart format lib test
flutter analyze
flutter test test/features/hifz
git add lib test
git commit -m "feat: add Hifz memorization test modes"
```

---

### Task 4: Implement deterministic revision scheduler and history

**Files:**
- Create: `lib/core/time/clock.dart`
- Create: `lib/features/revision/domain/revision_policy.dart`
- Create: `lib/features/revision/domain/revision_item.dart`
- Create: `lib/features/revision/domain/revision_repository.dart`
- Create: `lib/features/revision/data/drift_revision_repository.dart`
- Create: `lib/features/revision/application/revision_scheduler.dart`
- Create: `lib/features/revision/application/todays_revision_controller.dart`
- Create: `lib/features/revision/presentation/todays_revision_page.dart`
- Create: `test/features/revision/application/revision_scheduler_test.dart`
- Create: `test/features/revision/data/drift_revision_repository_test.dart`

**Interfaces:**
- `AppClock.now()` is injected.
- `RevisionScheduler.recordResult(ayahKey, result)` computes/persists state/history/next date transactionally.

- [ ] **Step 1: Write table-driven scheduling tests**

For each result type, assert old interval index, new interval index, next date, status, and strength adjustment. Include month/year rollover and overdue review cases using `FakeClock`.

- [ ] **Step 2: Write repository transaction test**

If history insertion fails, current Hifz state must not partially update. Use a test hook/constraint violation to prove rollback.

- [ ] **Step 3: Implement scheduler/repository/today grouping**

Group contiguous due ayahs within a Surah for display, while preserving individual persistence rows.

- [ ] **Step 4: Run gate and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test test/features/revision test/features/hifz
git add lib test
git commit -m "feat: schedule deterministic Quran revision"
```

---

### Task 5: Add read-only progress aggregation and daily goals

**Files:**
- Add tables: `lib/core/database/user_database.dart`
- Create: `lib/features/progress/domain/progress_summary.dart`
- Create: `lib/features/progress/domain/progress_repository.dart`
- Create: `lib/features/progress/data/drift_progress_repository.dart`
- Create: `lib/features/progress/application/progress_controller.dart`
- Create: `lib/features/progress/presentation/progress_page.dart`
- Create: `test/features/progress/data/drift_progress_repository_test.dart`
- Create: `test/features/progress/application/progress_controller_test.dart`

**Interfaces:**
- `ProgressRepository.loadSummary(DateTime day)` returns reading/Hifz/revision/goal aggregates and has no mutation methods for Hifz state.

- [ ] **Step 1: Write aggregate tests**

Seed mixed Hifz statuses, revision due dates, reading activity, and goals. Assert exact summary counts for day, trailing seven days, and trailing thirty days.

- [ ] **Step 2: Implement repository/controller/page**

Keep V1 charts simple and lightweight. Do not add a charting dependency unless the default Flutter primitives are insufficient for the approved UI.

- [ ] **Step 3: Run Gate C**

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test
```

Then manually demonstrate:

```text
start Hifz 67:1-3
complete session
submit memorization result
see persisted state
advance fake/test date or use test fixture
see due item in Today's Revision
submit review
see Progress totals update
```

- [ ] **Step 4: Commit**

```bash
git add lib test
git commit -m "feat: add Hifz progress dashboard"
```
