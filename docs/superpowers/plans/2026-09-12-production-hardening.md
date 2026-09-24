# Quran Hifz V1 Production Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the remaining production-release blockers and verify the Android-first Quran Hifz V1 from canonical bootstrap through navigation, Hifz/audio behavior, offline word caching, Android background playback, integration tests, and build gates.

**Architecture:** Preserve the existing modular Flutter/Riverpod/Drift design. Add one asynchronous canonical-content bootstrap provider, wire the production Quran repository exclusively to the verified Drift database, add a small app shell around existing feature pages, reuse reader sync/download infrastructure for Hifz and word audio, and restore Android platform integration without adding a second playback engine.

**Tech Stack:** Flutter/Dart, Riverpod, Drift/SQLite, just_audio, just_audio_background/audio_service-compatible Android MediaSession integration, integration_test, Node/Hono backend tests, Python tafsir tooling tests.

**Spec:** `docs/superpowers/specs/2026-09-12-production-hardening-design.md`

## Global Constraints

- No fabricated Quran/translation/tafsir/audio content.
- No default release fallback to `DemoQuranRepository`.
- Keep user-data migrations non-destructive.
- Hifz remains same-Surah.
- One central Quran audio controller remains playback authority.
- Every production-code behavior change begins with a failing regression test.

---

### Task 1: Canonical bootstrap and release repository composition

**Files:**
- Create: `lib/core/database/quran_content_bootstrap.dart`
- Modify: `lib/core/database/database_providers.dart`
- Modify: `lib/features/quran/application/quran_providers.dart`
- Modify: `lib/app/quran_hifz_app.dart`
- Modify: `pubspec.yaml`
- Test: `test/core/database/quran_content_bootstrap_test.dart`
- Test: `test/features/quran/application/quran_providers_test.dart`
- Test: `test/app/app_bootstrap_test.dart`

**Interfaces:**
- Produces `AsyncValue<QuranContentDatabase>` through `quranContentBootstrapProvider`.
- `quranRepositoryProvider` consumes the bootstrapped database and produces `DriftQuranRepository` only.

- [ ] Write failing bootstrap/provider tests proving installer path -> `forPath()` -> Drift repository and proving default composition does not instantiate `DemoQuranRepository`.
- [ ] Run focused tests and confirm RED.
- [ ] Implement manifest loading, installer orchestration, verified database provider lifetime, and bootstrap UI state.
- [ ] Run focused tests and confirm GREEN.
- [ ] Commit task changes.

### Task 2: Real app shell/navigation

**Files:**
- Create: `lib/app/app_destination.dart`
- Create: `lib/app/quran_hifz_shell.dart`
- Create: `lib/features/study/presentation/bookmarks_page.dart`
- Modify: `lib/app/quran_hifz_app.dart`
- Test: `test/app/quran_hifz_shell_test.dart`

**Interfaces:**
- Six destinations: Quran, Hifz, Revision, Progress, Test, Bookmarks.
- Existing pages remain feature-owned.

- [ ] Write widget tests that tap each destination and assert the expected feature page appears.
- [ ] Run test and confirm RED.
- [ ] Implement destination model, shell, and bookmarks page using existing study repository.
- [ ] Run test and confirm GREEN.
- [ ] Commit task changes.

### Task 3: Strong canonical content validation

**Files:**
- Modify: `tool/quran_content/quran_integrity_validator.dart`
- Test: `test/tool/quran_content/quran_integrity_validator_test.dart`

**Interfaces:**
- Add integrity codes `ayahMissingWords`, `primaryTranslationCoverage`, and `emptyPrimaryTranslation`.
- Production primary translation resource id is 1.

- [ ] Add failing SQLite fixture tests for an ayah without words, missing primary translation, duplicate/missing coverage, and empty primary translation text.
- [ ] Confirm RED.
- [ ] Add SQL coverage checks with exact error counts.
- [ ] Confirm focused tests GREEN.
- [ ] Commit task changes.

### Task 4: Settings/dropdown contract

**Files:**
- Modify: `test/features/settings/application/app_preferences_controller_test.dart`
- Create: `test/features/settings/presentation/settings_page_test.dart`
- Modify production settings files only if tests expose a real mismatch.

**Interfaces:**
- Dropdown options and controller accepted values share `AppPreferences.supportedRepeatCounts` and `supportedPlaybackSpeeds`.

- [ ] Add/repair tests for every supported option and unsupported synchronous errors.
- [ ] Run tests; if production mismatch exists, confirm RED for the mismatch.
- [ ] Make only the minimal production correction required.
- [ ] Confirm GREEN.
- [ ] Commit task changes.

### Task 5: Canonical Hifz range validation

**Files:**
- Create: `lib/features/quran/domain/canonical_quran_counts.dart`
- Modify: `lib/features/hifz/application/hifz_sequence_builder.dart`
- Modify developer validator to import/share the same canonical map where dependency direction permits, otherwise add a consistency test.
- Test: `test/features/hifz/application/hifz_sequence_builder_test.dart`

**Interfaces:**
- `canonicalAyahCountForSurah(int)` returns null outside 1..114.

- [ ] Add failing tests for Surah 0/115, ayah 0, and ayah above exact canonical count, plus boundary-valid last ayah.
- [ ] Confirm RED.
- [ ] Implement runtime canonical count validation.
- [ ] Confirm GREEN.
- [ ] Commit task changes.

### Task 6: Hifz lazy chapter sync

**Files:**
- Modify: `lib/features/hifz/data/quran_audio_hifz_port.dart`
- Modify Hifz providers/controller wiring as required.
- Test: `test/features/hifz/data/quran_audio_hifz_port_test.dart`

**Interfaces:**
- Resolver receives a `QuranAudioSyncService`-compatible sync dependency.
- Missing audio metadata or ayah timing triggers exactly one chapter sync before re-read.

- [ ] Add failing resolver test with initially absent metadata/timing and a fake sync that populates them.
- [ ] Confirm RED.
- [ ] Implement lazy sync and post-sync verification.
- [ ] Confirm GREEN, including existing cancellation/range tests.
- [ ] Commit task changes.

### Task 7: Word-audio offline caching/downloading

**Files:**
- Modify: `lib/features/quran/application/reader_audio_actions.dart`
- Modify: `lib/features/quran/data/quran_audio_sync_service.dart` or add a focused `word_audio_cache_service.dart` if responsibility remains clearer.
- Test: `test/features/quran/application/reader_audio_actions_test.dart`
- Test: `test/core/audio/offline_audio_resolver_test.dart`

**Interfaces:**
- Word audio key: `word:<surah>:<ayah>:<position>`.
- Completed local download wins over remote URL; `.part` never resolves.

- [ ] Add failing tests for cache registration/download call and local-first resolution.
- [ ] Confirm RED.
- [ ] Implement minimal cache/download connection without blocking first network playback unnecessarily.
- [ ] Confirm GREEN.
- [ ] Commit task changes.

### Task 8: Android platform + MediaSession/background audio

**Files:**
- Generate/create: `android/**`
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`
- Create: `lib/core/audio/background_audio_bootstrap.dart`
- Test: `test/core/audio/background_audio_bootstrap_test.dart`

**Interfaces:**
- `initializeBackgroundAudio()` runs once before app start.
- Android manifest declares required foreground/media playback service permissions/components supplied by selected background-audio package.

- [ ] Add failing initialization/idempotence test through an injectable initializer seam.
- [ ] Confirm RED.
- [ ] Add background audio dependency and initialization.
- [ ] Generate/restore Android scaffolding and configure manifest/application metadata.
- [ ] Confirm unit test GREEN and `flutter build apk --debug` passes.
- [ ] Commit task changes.

### Task 9: Integration tests and native smoke coverage

**Files:**
- Modify: `pubspec.yaml`
- Create: `integration_test/app_navigation_test.dart`
- Create: `integration_test/reader_hifz_smoke_test.dart`
- Create: `docs/testing/android-e2e-matrix.md`

**Interfaces:**
- Integration tests use provider overrides and deterministic local fixtures; no production Quran fabrication is introduced.

- [ ] Add integration tests that initially fail because required shell/bootstrap seams are absent or incomplete.
- [ ] Confirm RED where applicable.
- [ ] Add only test harness seams needed for deterministic integration execution.
- [ ] Run integration tests on available Flutter host/device target.
- [ ] Document six real-device release flows and expected assertions.
- [ ] Commit task changes.

### Task 10: Full deep verification and release artifact

**Files:**
- Modify: `DEVELOPMENT_STATUS.md`
- Create: `docs/testing/2026-09-12-production-hardening-verification.md`

**Interfaces:**
- Verification report records exact commands, exit codes, pass/fail counts, and environment limitations.

- [ ] Run `dart format --output=none --set-exit-if-changed .`.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test --concurrency=1` and then normal-concurrency `flutter test`.
- [ ] Run backend Node tests and Python tafsir tooling tests.
- [ ] Run integration tests available in this environment.
- [ ] Run `flutter build apk --debug`.
- [ ] Scan release composition for `DemoQuranRepository`, missing Android files, placeholder assets, accidental canonical writes, `.part` playback, and unresolved TODO/FIXME markers in touched release paths.
- [ ] Record any real-device-only gates as not executed rather than passed.
- [ ] Create full project ZIP plus changed-files ZIP and verify archive integrity.
