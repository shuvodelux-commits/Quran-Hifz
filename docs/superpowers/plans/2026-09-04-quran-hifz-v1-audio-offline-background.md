# Quran Hifz V1 Audio, Offline, and Background Playback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the starter audio service with a single cancellable Riverpod audio controller, connect verified timing-based ayah playback and word highlighting, make audio downloadable/local-first, and support Android background playback.

**Architecture:** `QuranAudioController` owns semantic playback and delegates raw media operations to a small player adapter. Downloads and file resolution are separate repositories backed by the user Drift DB and app-support filesystem. Background media integration reflects the same controller state.

**Tech Stack:** Flutter/Dart, Riverpod, just_audio, audio_service-compatible Android MediaSession integration, Drift/SQLite, filesystem storage, existing Hono backend.

**Spec:** `docs/superpowers/specs/2026-09-04-quran-hifz-v1-architecture-design.md`

## Global Constraints

- Exactly one semantic audio controller.
- Every new playback program cancels the previous session token.
- Main ayah playback uses one Surah audio file plus timing metadata.
- Dedicated word audio remains separate.
- Missing word timing disables highlighting rather than guessing.
- `.part` files are never playable.

---

### Task 1: Introduce player adapter, immutable audio state, and cancellation semantics

**Files:**
- Replace: `lib/core/audio/quran_audio_service.dart`
- Create: `lib/core/audio/audio_player_adapter.dart`
- Create: `lib/core/audio/just_audio_player_adapter.dart`
- Create: `lib/features/audio/domain/quran_audio_state.dart`
- Create: `lib/features/audio/domain/playback_requests.dart`
- Create: `lib/features/audio/application/quran_audio_controller.dart`
- Create: `lib/features/audio/application/audio_providers.dart`
- Create: `test/features/audio/application/quran_audio_controller_test.dart`
- Create: `test/fakes/fake_audio_player_adapter.dart`

**Interfaces:**
- Produces `quranAudioControllerProvider`.
- `AudioPlayerAdapter` exposes load/seek/play/pause/stop/speed/position/completion without Flutter UI dependencies.

- [ ] **Step 1: Write fake-clock controller tests**

Tests must prove:

- `playWord` stops previous program;
- starting ayah B during ayah A repeat invalidates A;
- repeat count N executes exactly N times;
- stop during inter-repeat delay prevents restart;
- auto-next cannot execute from stale session;
- speed updates apply to active player.

- [ ] **Step 2: Run tests and verify failure**

```bash
flutter test test/features/audio/application/quran_audio_controller_test.dart
```

- [ ] **Step 3: Implement adapter and controller**

Use a monotonic integer session token owned by the controller. Every async path captures the token and checks `token == _sessionToken` before/after waits, seeks, and completion.

- [ ] **Step 4: Bind just_audio adapter**

The adapter is the only place importing `package:just_audio`. Do not let reader/Hifz features instantiate `AudioPlayer`.

- [ ] **Step 5: Run tests/analyze and commit**

```bash
dart format lib test
flutter analyze
flutter test test/features/audio/application/quran_audio_controller_test.dart
git add lib test
git commit -m "feat: add cancellable central Quran audio controller"
```

---

### Task 2: Implement verified ayah/word timing resolver and reader highlighting

**Files:**
- Add Drift tables in: `lib/core/database/user_database.dart`
- Create: `lib/features/audio/domain/audio_timing.dart`
- Create: `lib/features/audio/data/drift_timing_repository.dart`
- Create: `lib/features/audio/application/timing_resolver.dart`
- Modify: `lib/features/audio/application/quran_audio_controller.dart`
- Modify: `lib/features/quran/presentation/widgets/quran_word_view.dart`
- Modify: `lib/features/quran/presentation/widgets/ayah_card.dart`
- Create: `test/features/audio/application/timing_resolver_test.dart`
- Create: `test/features/quran/presentation/active_word_highlight_test.dart`

**Interfaces:**
- `TimingRepository.getAyahTiming(reciterId, surah, ayah)`.
- `TimingRepository.getWordTimings(reciterId, surah, ayah)`.
- `TimingResolver.activeWordAt(positionMs, sortedSegments)` returns `int?`.

- [ ] **Step 1: Write boundary/binary-search tests**

Cover before-first, exact start, middle, exact end, gaps, after-last, one segment, and missing segments.

- [ ] **Step 2: Write highlight rebuild contract test**

The widget test must show that changing active word from 2 to 3 updates the affected ayah and does not cause unrelated ayah widgets to rebuild. Use a small rebuild counter test harness.

- [ ] **Step 3: Implement Drift timing tables/repository and binary search**

Store reciter-specific timings in `user_data.sqlite`. The resolver must return `null` for gaps/unverified timing.

- [ ] **Step 4: Integrate ayah seek/end and highlight publication**

The audio controller emits active-word changes only when the resolved word position changes. Do not forward every raw player position as reader state.

- [ ] **Step 5: Run gate and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test test/features/audio test/features/quran/presentation/active_word_highlight_test.dart
git add lib test
git commit -m "feat: synchronize ayah playback with verified word timings"
```

---

### Task 3: Move downloads to Drift-backed repository and make playback local-first

**Files:**
- Refactor: `lib/core/audio/audio_download_manager.dart`
- Refactor: `lib/core/audio/offline_audio_resolver.dart`
- Modify: `lib/features/quran/data/quran_audio_sync_service.dart`
- Add tables: `lib/core/database/user_database.dart`
- Create: `lib/features/downloads/domain/download_job.dart`
- Create: `lib/features/downloads/domain/audio_download_repository.dart`
- Create: `lib/features/downloads/data/file_audio_download_repository.dart`
- Create: `lib/features/downloads/application/download_controller.dart`
- Create: `test/features/downloads/data/file_audio_download_repository_test.dart`
- Create: `test/features/downloads/application/download_controller_test.dart`

**Interfaces:**
- `AudioSourceResolver.resolve(audioKey)` returns final local source when valid, otherwise permitted remote source.
- `DownloadController` supports queue/pause/resume/retry/cancel/delete.

- [ ] **Step 1: Write download-state tests**

Cover:

- success writes `.part` then final;
- failed download never exposes `.part` to resolver;
- restart/retry transitions are deterministic;
- insufficient storage rejects before write;
- deleting a final file updates DB;
- duplicate queue request does not create duplicate jobs.

Use a fake HTTP source and temporary directory.

- [ ] **Step 2: Run tests and confirm failure**

```bash
flutter test test/features/downloads
```

- [ ] **Step 3: Implement Drift tables and repository**

Persist job state and final audio metadata separately. Keep remote URL, local path, byte counts, format, and status.

- [ ] **Step 4: Implement local-first resolver**

Before returning a local path, stat the file and reject zero-byte/missing files. Never treat `.part` as playable.

- [ ] **Step 5: Integrate Quran Foundation metadata sync**

Preserve the existing backend client/proxy concept. Import reciter chapter metadata and verified timing segments into the user DB. Do not expose QF secrets to Flutter.

- [ ] **Step 6: Airplane-mode acceptance test**

Download Al-Fatihah chapter audio and all needed word audio, disable network on a real/emulated device, restart the app, and verify word tap + ayah repeat works from local files.

- [ ] **Step 7: Run gate and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test
git add lib test
git commit -m "feat: add resilient offline Quran audio downloads"
```

---

### Task 4: Add Android background MediaSession playback

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/audio/background_audio_handler.dart`
- Modify: `lib/features/audio/application/audio_providers.dart`
- Modify Android manifest/config files required by the chosen MediaSession package under `android/app/src/main/`
- Create: `test/core/audio/background_audio_handler_test.dart`
- Create manual test checklist: `docs/testing/android-background-audio.md`

**Interfaces:**
- Background handler delegates play/pause/skip/stop to the same controller/player authority and maps state to Android media metadata/notification controls.

- [ ] **Step 1: Add the MediaSession/background package compatible with the current Flutter/Android toolchain**

Use the package's official current Android configuration during implementation. Do not create a second `AudioPlayer` solely for background mode.

- [ ] **Step 2: Write handler delegation tests**

Verify notification play/pause/next/previous/stop commands call the expected controller operations and do not create independent playback state.

- [ ] **Step 3: Implement background handler and Android configuration**

Expose current Surah/Ayah and repeat position in media metadata when available.

- [ ] **Step 4: Implement audio-focus/noisy-output behavior**

Pause on becoming noisy (wired/Bluetooth disconnect). Handle calls/audio focus conservatively; no surprising auto-resume.

- [ ] **Step 5: Run real-device matrix**

Document PASS/FAIL for:

```text
screen lock
Home/background
notification play/pause
notification next/previous
incoming call
Bluetooth disconnect
wired headphone disconnect
network loss during stream
local playback in airplane mode
```

- [ ] **Step 6: Run gate and commit**

```bash
dart format lib test
flutter analyze
flutter test
git add pubspec.yaml pubspec.lock lib android test docs/testing/android-background-audio.md
git commit -m "feat: support Android background Quran playback"
```
