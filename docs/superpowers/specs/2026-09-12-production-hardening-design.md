# Quran Hifz V1 Production Hardening Design

**Date:** 2026-09-12
**Status:** Approved by execution request
**Baseline:** `quran_hifz_v1_active_word_regression_fixed.zip`
**Parent architecture:** `docs/superpowers/specs/2026-09-04-quran-hifz-v1-architecture-design.md`

## Goal

Close the remaining release blockers without changing the approved V1 product scope. The app must boot from a verified bundled canonical Quran database, use Drift-backed Quran data in release composition, expose the real V1 modules through one app shell, validate canonical content more strictly, keep Hifz aligned with canonical Quran bounds and reader audio sync behavior, support local-first word audio caching, restore Android platform files with background MediaSession playback, and add an executable integration test layer.

## Constraints

- Preserve the existing two-database architecture: immutable/read-mostly Quran content and mutable user data.
- Keep `QuranAudioController` as the semantic playback authority.
- Never fabricate canonical Quran text, word metadata, translation, tafsir, or production audio metadata.
- A production build without the approved canonical `assets/database/quran_content.sqlite` must fail visibly rather than silently fall back to demo Quran data.
- Demo Quran data may remain only for explicit tests/development overrides and must not be the default app composition.
- Hifz ranges remain same-Surah in V1.
- Existing user database migrations and user data must be preserved.
- Word audio remains dedicated per-word audio, resolved local-first. Download/caching writes go through the existing download repository.
- Android background playback must use the same just_audio session/controller, not a parallel player.

## Architecture decisions

### 1. Canonical bootstrap

Introduce an asynchronous bootstrap boundary before the reader repository is exposed. Startup flow is:

`rootBundle asset manifest -> QuranContentInstaller.ensureInstalled() -> verified installed path -> QuranContentDatabase.forPath(path) -> DriftQuranRepository`.

The app shell renders a bootstrap/loading state until this succeeds and a fatal retry UI if canonical content cannot be verified. The default repository provider reads the bootstrapped Drift repository. Tests can override the bootstrap/repository providers.

The package manifest is loaded from a bundled JSON sidecar. The database asset and sidecar are declared in `pubspec.yaml`. This project does not fabricate the missing canonical database; test assets provide a fixture for automated bootstrap tests.

### 2. App shell and navigation

Use one Material 3 shell with six release destinations: Quran, Hifz, Revision, Progress, Test, Bookmarks. Quran remains the initial destination. Existing feature pages are reused. Bookmarks receives a focused list page backed by the existing study repository. Settings remains reachable from Quran/reader actions rather than becoming a seventh primary destination.

### 3. Canonical validation

The developer-side validator gains two release-gate checks:

- every canonical ayah has at least one word row;
- primary Bangla translation resource id 1 has exactly one non-empty row for every canonical ayah.

The checks are count/coverage based and do not alter canonical content.

### 4. Settings consistency

UI dropdown options and controller validation continue to derive from `AppPreferences.supportedRepeatCounts` and `supportedPlaybackSpeeds`. Tests must assert every rendered option is accepted and unsupported values are rejected using correct synchronous-exception expectations.

### 5. Hifz canonical bounds and lazy sync

Move canonical ayah-count knowledge into a reusable runtime domain constant independent from developer tooling. `HifzSequenceBuilder` validates Surah 1..114 and start/end ayahs against that Surah's canonical count.

`DriftHifzPlaybackRequestResolver` receives `QuranAudioSyncService`. Missing chapter metadata or ayah timing triggers the same lazy chapter sync used by reader playback, then re-reads both records before resolving. Failure after sync remains explicit.

### 6. Word audio offline cache

`DriftReaderPlaybackRequestResolver.resolveWord` registers/caches the word audio through the existing download repository using a deterministic word key/path. The resolver remains local-first because `OfflineAudioResolver` chooses completed local files before remote URLs. Immediate tap playback may use remote audio while cache download runs only when configured as a cache action; explicit offline download can await completion. Tests cover key construction, local-path precedence, and no `.part` playback.

### 7. Android/background audio

Generate standard Android Flutter platform scaffolding. Add `audio_service`/`just_audio_background` style MediaSession integration with Android notification/service declarations and initialize it before `runApp`. The existing `JustAudioPlayerAdapter` remains the player adapter. Background initialization is idempotent and testable behind an initialization seam.

### 8. Integration and deep verification

Add `integration_test/` covering canonical bootstrap + app shell navigation with test overrides, and a reader/Hifz smoke flow that does not require network. Native Android build verification includes debug APK compilation. Real-device-only assertions are documented and not falsely claimed when no Android device is attached.

Deep verification order: format -> codegen -> analyzer -> unit/widget tests -> backend tests -> Python tooling tests -> integration tests available in host mode -> Android debug build -> dependency/config scans -> zip/diff verification.
