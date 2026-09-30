# Bangladesh Hijri Calendar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Bangladesh-oriented Hijri date handling with HJCoSA-minus-one baseline, Maghrib/midnight rollover, month-scoped manual correction, and consistent Home/calendar display.

**Architecture:** Keep prayer-time calculation untouched. Add a focused Hijri-date resolver/repository: pure code determines the effective Gregorian source day; an HJCoSA client converts it and falls back to hijri_core. Persist only user choices in AppPreferences and feed resolved dates into Home and calendar.

**Tech Stack:** Flutter, Dart, Riverpod, http, hijri_core, Drift AppSettings.

**Spec:** `docs/superpowers/specs/2026-09-30-bangladesh-hijri-calendar.md`

## Global Constraints
- Do not change Mushaf/Hifz behavior.
- Do not change prayer-time calculation.
- Bangla and English Settings copy are required.
- Maghrib is the default Hijri day boundary.
- Bangladesh default is HJCoSA minus one day.
- Keep manual correction because 100% Bangladesh accuracy is not established.
- Do not rely on GitHub Actions for verification.

## Review Focus
- Exactly-at-Maghrib rollover.
- Midnight mode after Maghrib but before 00:00.
- Correction crossing Hijri month/year boundaries.
- Non-zero correction expiring when the baseline Hijri month changes.
- HJCoSA network failure falling back without changing prayer times.

### Task 1: Hijri preferences and persistence
**Files:** modify AppPreferences/controller/repository; test settings persistence/defaults.
**Interfaces:** Produces `HijriDayBoundary`, `hijriDayBoundary`, `hijriDateCorrection`, `hijriCorrectionScope`, setters/providers.
- [ ] Write failing preference tests.
- [ ] Run them and confirm the expected failures.
- [ ] Implement fields, defaults, copyWith, persistence, controller setters/providers.
- [ ] Run tests and confirm pass.
- [ ] Commit.

### Task 2: Bangladesh Hijri resolver and HJCoSA repository
**Files:** create `lib/features/home/data/bangladesh_hijri_date.dart`; add unit tests.
**Interfaces:** Produces pure source-day resolution and async HJCoSA conversion with hijri_core fallback.
- [ ] Write failing resolver/repository tests for boundary, -1 baseline, correction, month scope, fallback.
- [ ] Run and confirm failures.
- [ ] Implement minimal resolver/repository.
- [ ] Run tests and confirm pass.
- [ ] Commit.

### Task 3: Settings UI
**Files:** modify SettingsPage and its widget tests.
**Interfaces:** Consumes Task 1 preferences/setters.
- [ ] Write failing widget test for Calendar & Hijri Date, Maghrib/12 AM, and correction choices.
- [ ] Run and confirm failure.
- [ ] Implement section in existing Settings style.
- [ ] Run and confirm pass.
- [ ] Commit.

### Task 4: Home and calendar integration
**Files:** modify HomeDashboardPage, HomePage if reachable, PrayerCalendarPage; widget tests.
**Interfaces:** Consumes Task 2 resolver/repository and Task 1 providers.
- [ ] Write failing tests proving corrected Hijri display and icon removal.
- [ ] Run and confirm failures.
- [ ] Wire the central date source into Home/calendar and remove only decorative Today’s Ayah/Current Salah icons.
- [ ] Run and confirm pass.
- [ ] Commit.

### Task 5: Verification
- [ ] Run targeted tests.
- [ ] Run full `flutter test`.
- [ ] Run `flutter analyze`.
- [ ] Review the branch against the spec and report any environment limitation rather than claiming unverified success.
