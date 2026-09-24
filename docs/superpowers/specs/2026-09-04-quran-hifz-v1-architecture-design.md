# Quran Hifz V1 Architecture Design

**Date:** 2026-09-04  
**Status:** Approved architecture baseline  
**Product:** Android-first Quran learning, memorization, revision, and offline reading application  
**Baseline:** `quran_hifz_audio_sync_v0_2.zip`

## 1. V1 Goal

V1 must make this workflow reliable on Android:

1. Install and open the app without requiring an account or network for Quran text.
2. Read verified Quran text from a prebuilt local SQLite database.
3. Tap any word and hear dedicated word audio with minimal latency.
4. Long-press a word to see compact study details.
5. Play an ayah directly below that ayah.
6. Highlight the currently recited word when verified timing metadata exists.
7. Repeat an ayah N times with configurable pause and optional auto-next.
8. Download Surah recitation plus word audio for offline use.
9. Continue repeat/Hifz playback with screen locked using Android background media playback.
10. Create a Hifz range, execute a deterministic practice sequence, record memorization status, and schedule revision.
11. Preserve reading, Hifz, revision, bookmarks, notes, downloads, and settings across app upgrades.

Video creation, AI recitation grading, accounts, cloud sync, classroom features, and social features are excluded from V1.

## 2. Approved Technology and Architecture Decisions

- Flutter/Dart, Android first.
- Feature-based lightweight Clean Architecture.
- Riverpod for dependency injection and state management.
- Drift + SQLite for structured local data.
- Two SQLite lifecycles:
  - read-mostly canonical Quran content database;
  - read/write user database.
- Full verified Quran content database bundled with the application.
- Quran reader uses page/window loading with adjacent prefetch. It never eagerly renders an entire long Surah.
- Main recitation uses one full Surah audio file plus ayah and word timestamps.
- Dedicated word audio remains separate for instant word-tap playback.
- One central `QuranAudioController` owns playback semantics.
- `just_audio` is the playback engine.
- Android background playback uses a MediaSession-capable integration behind the same controller, not a second competing playback engine.
- Cloudflare Workers + Hono remains the minimal V1 backend for Quran Foundation authentication/proxy, content metadata, reciter discovery, tafsir discovery, and update manifest.
- No user account or cloud state synchronization in V1.
- Testing uses a focused pyramid: strong unit/database coverage for correctness-critical logic, selective widget tests, and a small real-Android release E2E suite.

## 3. System Shape

```text
Flutter app
├── app shell / navigation
├── Quran reader
├── audio playback
├── downloads
├── Hifz
├── revision
├── progress
├── study tools
└── settings
       │
       ▼
Riverpod application controllers
       │
       ▼
Domain contracts and immutable models
       │
       ▼
Repositories
├── QuranContentDatabase (read-mostly)
├── UserDatabase (read/write)
├── filesystem audio storage
└── remote content metadata client
       │
       ▼
Platform / infrastructure
├── just_audio
├── Android MediaSession/background service
└── Hono/Cloudflare Worker → Quran Foundation
```

This is a modular monolith. Do not introduce mobile microservices, internal event buses, or a generic command framework.

## 4. Feature Folder Contract

Each substantial feature uses only the layers it needs:

```text
lib/features/<feature>/
├── data/
├── domain/
├── application/
└── presentation/
```

Rules:

- Presentation cannot directly query Drift tables, manipulate files, or call remote Quran APIs.
- Application controllers orchestrate domain operations and expose small immutable states.
- Domain owns stable models and repository contracts.
- Data owns Drift queries, filesystem implementation, and network adapters.
- Avoid `usecases/`, mapper hierarchies, repository-implementation naming layers, or interfaces for trivial helpers unless a real seam is required for testing or platform replacement.

## 5. Core Boundaries

Keep these concerns separate:

- Canonical Quran content vs user-generated state.
- Main Surah recitation vs dedicated word pronunciation.
- Playback mechanics vs Hifz sequence planning.
- Download lifecycle vs playback lifecycle.
- Hifz current state vs immutable review history.
- Progress aggregation vs state mutation.

There must be no circular feature dependency.

## 6. Database Architecture

### 6.1 Quran content database

File: `quran_content.sqlite`.

It contains verified, versioned, read-mostly data:

- `surahs`
- `ayahs`
- `words`
- `translations`
- `pages`
- `quran_metadata`

Minimum identifiers:

```text
surahs: surah_number
ayahs: (surah_number, ayah_number), verse_key
words: (surah_number, ayah_number, position)
translations: (resource_id, surah_number, ayah_number)
```

The content DB is created by a deterministic developer-side import tool, validated, then bundled as an asset. On first startup it is copied atomically to app-support storage and opened read-mostly. It is not rebuilt from JSON on the device.

Required indexes:

- unique `(surah_number, ayah_number)` on ayahs;
- `(surah_number, ayah_number, position)` on words;
- `page_number` on ayahs;
- `juz_number` on ayahs;
- translation lookup by resource/surah/ayah.

### 6.2 User database

File: `user_data.sqlite`.

Tables include:

- `reading_progress`
- `hifz_progress`
- `hifz_review_history`
- `bookmarks`
- `notes`
- `audio_downloads`
- `download_jobs`
- `reciter_ayah_timings`
- `reciter_word_timings`
- `daily_goals`
- `preferences`
- `content_sync_state`

Drift schema migrations must preserve existing rows. Deleting and recreating `user_data.sqlite` as an upgrade strategy is forbidden.

### 6.3 Quran content integrity release gate

Every generated or updated Quran content DB must pass all of these before packaging:

- exactly 114 Surahs;
- exactly 6236 ayahs for the selected canonical numbering scheme used by the application;
- expected per-Surah ayah counts;
- unique verse keys;
- no empty canonical Arabic text;
- strictly valid word positions inside each ayah;
- no duplicate word positions;
- all translation rows reference existing ayahs;
- page and Juz numbers are within supported ranges;
- every included audio path references an existing word;
- deterministic content checksum is emitted with the build artifact.

The app must never silently mutate canonical Quran text.

## 7. Reader Architecture

The reader loads a page/window rather than a complete long Surah.

`ReaderController` owns:

- current navigation location;
- previous/current/next window identifiers;
- translation visibility;
- reading-position persistence.

`QuranRepository` exposes reader-ready queries that return ayahs with words and selected translation in batched form. Avoid N+1 queries.

A reader window should be bounded by page or a small page group. Adjacent windows may be prefetched after the current window is visible.

The UI uses lazy slivers/list construction and stable keys. Audio position changes must never rebuild the entire reader page.

## 8. Audio Architecture

### 8.1 Single authority

`QuranAudioController` is the single semantic playback authority.

Public operations:

```dart
Future<void> playWord(WordPlaybackRequest request);
Future<void> playAyah(AyahPlaybackRequest request);
Future<void> playRange(RangePlaybackRequest request);
Future<void> pause();
Future<void> resume();
Future<void> stop();
Future<void> skipToNext();
Future<void> skipToPrevious();
Future<void> setSpeed(double speed);
```

Playback modes:

```text
idle
word
ayah
surah
hifzRange
revision
```

### 8.2 Cancellation

Every playback program receives a monotonic session token. Starting new word, ayah, range, Hifz, revision, or stop invalidates the previous token. Every asynchronous repeat/range loop checks the token before seeking, after completion, after delays, and before auto-next.

No stale loop may restart playback after the user has started another action.

### 8.3 Main audio

One reciter Surah file is used for Surah and ayah playback. Reciter-specific timing records provide ayah and verified word boundaries.

Ayah playback:

1. Resolve final local file if available, otherwise permitted remote source.
2. Resolve exact ayah start/end timing.
3. Seek to start.
4. Play until end.
5. Execute repeat/next policy under the same session token.

Do not split the downloaded Surah file into thousands of permanent ayah files.

### 8.4 Word audio

Dedicated word files are used for single taps. A word tap interrupts current playback and uses local-first resolution. Incomplete `.part` files are never playable.

### 8.5 Highlighting

Word timing segments are sorted. `TimingResolver` uses binary search to map playback position to active word. State is published only when the active word changes, not on every raw position event.

If verified word timing is absent, ayah playback works without synchronized highlighting. Do not guess timings.

## 9. Offline Download Architecture

Audio files live in app-support storage, not SQLite BLOBs.

```text
quran_audio/
├── reciters/<reciterId>/<surah>.source-extension
└── words/<surah>/<ayah>/<word>.source-extension
```

SQLite stores download metadata, final local path, remote URL, byte counts, status, checksum when available, and timestamps.

Download safety:

1. Validate storage before starting a large job.
2. Write to `filename.part`.
3. Support pause/resume where the origin supports byte ranges; otherwise cleanly restart the item while preserving queue state.
4. Verify non-zero final file and available integrity metadata.
5. Atomically rename to final filename.
6. Transactionally mark the database row downloaded.
7. Playback resolver recognizes only final files.

V1 user download scopes:

- current Surah;
- selected Surahs;
- current Juz;
- selected same-Surah Hifz range;
- entire Quran for a chosen reciter/word-audio package when storage permits.

Keep Quran Foundation source audio unchanged unless the applicable content rights explicitly permit transcoding/redistribution.

## 10. Android Background Playback

Background playback is in V1.

Requirements:

- continue normal/Hifz/revision playback with screen locked;
- MediaSession and notification controls for previous, play/pause, next, stop;
- use the same audio controller state as foreground UI;
- handle Android audio focus;
- pause on wired/Bluetooth output disconnect;
- handle interruption conservatively and avoid surprising auto-resume after calls;
- preserve active playback when Flutter presentation widgets are not mounted.

## 11. Hifz Architecture

`HifzSessionController` is a session planner/orchestrator. It does not own a second audio engine.

Built-in V1 presets:

- New Memorization: each new ayah ×5, progressive combined range ×3, one-second pause, auto-next.
- Strong Memorization: each ayah ×2, selected range ×2.
- Revision: each ayah ×1, selected range ×1 by default with user-adjustable repeat count.

V1 Hifz ranges are constrained to one Surah. Cross-Surah range sessions are excluded.

The sequence builder produces immutable steps such as:

```text
Ayah(67:1) ×5
Ayah(67:2) ×5
Range(67:1-2) ×3
Ayah(67:3) ×5
Range(67:1-3) ×3
```

The audio controller executes those steps.

## 12. Hifz and Revision State

Primary Hifz states:

```text
NOT_STARTED
LEARNING
MEMORIZED
NEEDS_REVISION
STRONG
```

Current state and review history are separate tables. Historical `memorized_at` is not erased merely because an ayah becomes weak again.

V1 deterministic review intervals:

```text
1, 2, 4, 7, 14, 30, 60 days
```

Results:

- Perfect: advance one interval and increase strength.
- Small Mistake: retain interval and slightly reduce strength.
- Difficult: move back one interval, reduce strength, mark revision-needed.
- Forgot: return to short interval, substantially reduce strength, mark learning.

Tests use an injected clock. Revision logic must not depend directly on `DateTime.now()`.

## 13. Progress Architecture

Progress is read-only aggregation over reading progress, Hifz state, revision history, and goals. It does not directly mutate Hifz state.

V1 dashboard metrics:

- reading pages/ayahs and last position;
- learning/memorized/revision-due/strong ayah counts;
- today's new-Hifz, revision, and reading goals;
- simple seven-day and thirty-day activity summaries.

No XP, coins, levels, leaderboards, or competitive social gamification.

## 14. Study Tools

V1 includes:

- word long-press detail sheet;
- bookmarks;
- notes;
- optional downloaded tafsir source;
- basic Surah/reference/translation search.

Study tools must never modify canonical Quran rows.

## 15. Performance Targets

Targets are engineering goals measured on a representative mid-range Android device with local content:

- local word tap to audible playback: under 150 ms target;
- local ayah play command to audible playback: under 250 ms target;
- normal reader scrolling: 60 FPS target with no persistent jank;
- reader must not instantiate every word of Al-Baqarah at once;
- opening an already-copied local Quran page/window should require only bounded indexed queries;
- audio position events must not trigger full-page rebuilds;
- only active-word transitions should update word-highlight state.

Low-end-device profiling is a release requirement even when exact latency targets cannot be met on every device.

## 16. Failure and Recovery Policy

- Quran content DB fails integrity/open: show a blocking content error and never render partially trusted Quran text.
- User DB migration fails: keep the original DB untouched when possible, log the failure, and do not silently recreate it.
- Local audio file missing/corrupt: mark local copy invalid and fall back to remote only when network use is allowed.
- Timing missing: play audio without highlighting.
- Network lost during stream: surface recoverable playback state; downloaded content remains available.
- Download interrupted: preserve job state and `.part` file only when safe resume is supported.
- Insufficient storage: reject/pause the new download before corrupting existing files.
- Background service unavailable: foreground playback remains functional and the UI states that background playback is unavailable.
- A new playback action always cancels stale playback programs.

User-facing errors use domain messages, never raw platform/socket exceptions.

## 17. Test Strategy

### Unit tests

Strong coverage for:

- Quran integrity validation;
- timing lookup;
- playback cancellation and repeat sequencing;
- Hifz sequence generation;
- Hifz state transitions;
- revision interval calculation;
- date-boundary behavior;
- download state machine.

### Database/repository tests

Use temporary SQLite files for:

- Drift migrations;
- user-data preservation;
- reader-window queries;
- indexes/uniqueness constraints;
- atomic download-state updates.

### Widget tests

Only high-value contracts:

- correct Quran word order/RTL presentation;
- translation toggle;
- word tap dispatches the expected audio request;
- active word highlight changes only in affected ayah;
- Hifz status/revision result controls;
- download state rendering.

### Android integration/release flows

1. Fresh install → open/read bundled Quran offline.
2. Word tap → ayah repeat and auto-next.
3. Download Surah/word audio → airplane mode → same playback works.
4. Screen lock/background → playback and notification controls work.
5. Memorize ayah → review result → due revision is scheduled.
6. Upgrade from prior user DB → reading/Hifz/bookmarks/download state preserved.

## 18. Module Order and Gates

- M00 Project Foundation
- M01 Canonical Quran Content Pipeline
- M02 Quran Reader
- M03 Audio Core
- M04 Reader + Audio Integration
- M05 Offline Downloads
- M06 Background Playback
- M07 Hifz Engine
- M08 Memorization Test
- M09 Revision Engine
- M10 Progress
- M11 Study Tools
- M12 Settings + Production Hardening

No downstream module starts production implementation before its dependency gate is green.

Global module gate:

```text
format passes
flutter analyze passes
module tests pass
existing tests pass
no new unhandled exceptions in acceptance flow
```

Additional release gates:

- Quran: canonical integrity checks pass.
- Audio: no stale/overlapping playback.
- Offline: core Hifz works in airplane mode.
- Upgrade: user data preserved.
- Android: background behavior tested on real devices.

## 19. Current v0.2 Migration Notes

The existing starter has useful pieces but does not yet match the approved architecture:

- `sqflite` `AppDatabase` must be replaced by Drift-backed content/user DBs.
- `DemoQuranRepository` must be removed once the canonical content pipeline is integrated.
- `QuranAudioService` must evolve into one Riverpod-managed `QuranAudioController` with cancellation semantics.
- Current `AudioDownloadManager`/`OfflineAudioResolver` behavior should be preserved conceptually but moved behind repository contracts and the user DB.
- Existing Hono/Quran Foundation proxy is retained and hardened rather than replaced.
- `QuranHifzApp` moves from manually created services to `ProviderScope` and feature providers.

## 20. V1 Acceptance Criteria

V1 is not complete until all of the following are demonstrated on a production-profile Android build:

1. Full verified Quran text is bundled and opens with no network.
2. Al-Fatihah and a long Surah render correctly with bounded lazy loading.
3. Local word tap starts dedicated word audio without starting the full ayah.
4. Ayah playback seeks/stops at verified boundaries.
5. Verified word highlighting stays synchronized without full-reader rebuilds.
6. Repeat count is exact, cancellation is immediate, and auto-next cannot revive a stale session.
7. Downloaded Surah + word audio works in airplane mode.
8. Background Hifz repeat continues with screen locked and notification controls operate correctly.
9. Hifz range sequence, status persistence, test result, and revision scheduling are deterministic.
10. App upgrade preserves reading progress, Hifz state/history, bookmarks, notes, settings, and valid download records.
11. Quran integrity release gate passes for the packaged content DB.
12. `flutter analyze`, correctness-critical tests, and six Android release flows pass.
