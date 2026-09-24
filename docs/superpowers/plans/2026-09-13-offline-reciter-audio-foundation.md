# Offline-first Reciter and Surah Audio Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the runtime dependency on `QURAN_BACKEND_URL` for reciter discovery and Surah audio preparation so the app can list reciters from bundled verified metadata, download Surah audio directly, and replay downloaded Surahs offline.

**Architecture:** Extend the existing build-time Quran Foundation client so a credentialed developer command generates two runtime-safe asset layers: a small `reciters_v1.json` catalog and one per-reciter/per-Surah chapter metadata JSON file containing the public audio URL and timing segments. Runtime loads reciters and chapter metadata from `AssetBundle`; `QuranAudioSyncService` consumes a `ChapterAudioSource` instead of `QuranBackendClient`, while the existing `FileAudioDownloadRepository`, user database, timing tables, and audio resolver remain unchanged.

**Tech Stack:** Flutter/Dart, Riverpod 3, Drift/SQLite, `rootBundle`, existing `dart:io` content-fetch tooling, Quran Foundation Content API v4, `just_audio`/`just_audio_background`.

**Spec:** `docs/superpowers/specs/2026-09-13-quran-reader-audio-redesign-design.md`

## Global Constraints

- Quran Foundation secrets are build/server-only and never enter Flutter assets, Android resources, APK/AAB metadata, or Dart defines shipped to users.
- Runtime basic reciter selection and supported Surah download must work with `QURAN_BACKEND_URL` unset.
- Existing word tap playback and the validated Android foreground-notification icon fix must remain intact.
- Existing resumable `FileAudioDownloadRepository` remains the transfer/storage implementation.
- Audio files stay on the filesystem, never SQLite BLOBs.
- Bundled catalog validation rejects duplicate reciter IDs and incomplete 114-Surah coverage for every bundled reciter.
- The mobile app loads timing metadata only for the requested reciter/Surah, not for the whole catalog at startup.
- Generated audio metadata records provenance and schema version and contains no credentials.
- Physical-device verification uses the side-by-side debug application ID `com.quranhifz.app.debug`.

---

### Task 1: Define and validate the generated audio-asset schema

**Files:**
- Create: `tool/quran_audio/reciter_catalog_builder.dart`
- Create: `test/tool/quran_audio/reciter_catalog_builder_test.dart`

**Interfaces:**
- Consumes: raw Quran Foundation chapter-reciter rows and `/chapter_recitations/{id}/{chapter}?segments=true` payloads.
- Produces: `Map<String, dynamic> buildReciterIndex(...)`, `Map<String, dynamic> buildChapterAudioDocument(...)`, and `validateGeneratedAudioCatalog(...)`.

- [ ] **Step 1: Write the failing schema tests**

Cover these exact behaviours:

```dart
test('reciter index rejects duplicate ids', () {
  expect(
    () => buildReciterIndex(
      sourceVersion: 'test',
      generatedAtUtc: DateTime.utc(2026, 9, 13),
      reciters: [_reciter(7, 'A'), _reciter(7, 'B')],
    ),
    throwsFormatException,
  );
});

test('chapter document requires matching chapter and public audio url', () {
  final document = buildChapterAudioDocument(
    reciterId: 7,
    surahNumber: 1,
    raw: _chapterAudio(1, 'https://download.quranicaudio.com/test/001.mp3'),
  );
  expect(document['reciter_id'], 7);
  expect(document['surah_number'], 1);
  expect(document['audio_url'], startsWith('https://'));
});

test('catalog validation requires 114 chapter documents per reciter', () {
  expect(
    () => validateGeneratedAudioCatalog(
      reciterIndex: buildReciterIndex(
        sourceVersion: 'test',
        generatedAtUtc: DateTime.utc(2026, 9, 13),
        reciters: [_reciter(7, 'A')],
      ),
      chaptersByReciter: {7: {1: _validChapterDocument(7, 1)}},
    ),
    throwsStateError,
  );
});
```

- [ ] **Step 2: Run the tests and verify RED**

Run:

```bash
flutter test test/tool/quran_audio/reciter_catalog_builder_test.dart --reporter expanded
```

Expected: FAIL because the builder functions do not exist.

- [ ] **Step 3: Implement strict normalized documents**

`reciters_v1.json` shape:

```json
{
  "schema_version": 1,
  "source_name": "Quran Foundation Content API v4",
  "source_version": "content-api-v4-production (...)",
  "generated_at_utc": "2026-09-13T00:00:00.000Z",
  "reciters": [
    {
      "id": 7,
      "name": "...",
      "style": {"name": "Murattal", "language_name": "English"},
      "qirat": {"name": "Hafs", "language_name": "English"}
    }
  ]
}
```

Per-Surah `assets/audio/chapters_v1/<reciterId>-<surah>.json` shape:

```json
{
  "schema_version": 1,
  "reciter_id": 7,
  "surah_number": 1,
  "audio_file_id": 457,
  "audio_url": "https://download.quranicaudio.com/.../001.mp3",
  "format": "mp3",
  "file_size": 710784,
  "timestamps": [
    {
      "verse_key": "1:1",
      "timestamp_from": 0,
      "timestamp_to": 6493,
      "duration": 6493,
      "segments": [[1, 0, 500]]
    }
  ]
}
```

Validation must require HTTPS URLs, chapter number 1–114, matching `chapter_id`, unique reciter IDs, unique `verse_key`s, monotonic/non-negative timestamp bounds after normalizing legacy negative `duration`, and exact 114-chapter coverage for every generated reciter.

- [ ] **Step 4: Run the builder tests and verify GREEN**

```bash
flutter test test/tool/quran_audio/reciter_catalog_builder_test.dart --reporter expanded
```

Expected: PASS.

### Task 2: Add credentialed build-time Quran Foundation audio fetcher

**Files:**
- Modify: `tool/quran_content/source_fetcher.dart`
- Create: `tool/quran_audio/fetch_verified_reciter_audio.dart`
- Create: `test/tool/quran_audio/reciter_source_fetcher_test.dart`
- Create: `tool/quran_audio/README.md`

**Interfaces:**
- Consumes: existing `QuranFoundationClient`, `QF_CLIENT_ID`, plus either `QF_CLIENT_SECRET` or `QF_ACCESS_TOKEN`.
- Produces: `assets/audio/reciters_v1.json` and `assets/audio/chapters_v1/<reciterId>-<surah>.json`.

- [ ] **Step 1: Add failing transport tests**

Verify `QuranFoundationClient.fetchChapterReciters()` calls `/content/api/v4/resources/chapter_reciters?language=en`, and `fetchChapterAudio(reciterId, surah, segments: true)` calls `/content/api/v4/chapter_recitations/<id>/<surah>?segments=true` with the existing authenticated headers/retry path.

- [ ] **Step 2: Run the transport tests and verify RED**

```bash
flutter test test/tool/quran_audio/reciter_source_fetcher_test.dart --reporter expanded
```

Expected: FAIL because the audio-fetch methods do not exist.

- [ ] **Step 3: Implement public audio fetch methods on `QuranFoundationClient`**

Add:

```dart
Future<List<Map<String, dynamic>>> fetchChapterReciters({String language = 'en'});
Future<Map<String, dynamic>> fetchChapterAudio({
  required int reciterId,
  required int surahNumber,
  bool segments = true,
});
```

Both reuse `_authenticatedGet`; do not duplicate OAuth logic.

- [ ] **Step 4: Implement the generator command**

Support:

```bash
dart run tool/quran_audio/fetch_verified_reciter_audio.dart \
  --qf-env production \
  --reciter-ids 7,10 \
  --out-dir assets/audio
```

The command must:

1. fetch the reciter list once;
2. require every requested ID to exist in that list;
3. fetch all 114 Surahs with `segments=true` for each requested reciter;
4. normalize and validate all documents in memory;
5. write a staging directory;
6. atomically replace `reciters_v1.json` and `chapters_v1/` only after the complete catalog validates;
7. print reciter count, chapter-file count, and output path;
8. never print client secret or access token.

- [ ] **Step 5: Run tests and generator against production credentials**

```bash
flutter test test/tool/quran_audio/reciter_source_fetcher_test.dart --reporter expanded
QF_ENV=production \
QF_CLIENT_ID="$QF_CLIENT_ID" \
QF_CLIENT_SECRET="$QF_CLIENT_SECRET" \
dart run tool/quran_audio/fetch_verified_reciter_audio.dart \
  --reciter-ids <approved-id-list> \
  --out-dir assets/audio
```

Expected: tests PASS; generator reports exactly `114 × reciter_count` chapter documents.

### Task 3: Load bundled reciters and chapter metadata at runtime

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/features/reciters/data/bundled_reciter_catalog_source.dart`
- Create: `lib/features/reciters/domain/chapter_audio_source.dart`
- Create: `lib/features/reciters/data/bundled_chapter_audio_source.dart`
- Create: `test/features/reciters/data/bundled_reciter_catalog_source_test.dart`
- Create: `test/features/reciters/data/bundled_chapter_audio_source_test.dart`

**Interfaces:**
- Consumes: generated Flutter assets.
- Produces: existing `ReciterCatalogSource.fetchChapterReciters()` and new `ChapterAudioSource.loadChapterAudio(reciterId:, surahNumber:)`.

- [ ] **Step 1: Write failing asset-loader tests**

Use an in-memory/fake `AssetBundle` and assert:

```dart
final rows = await source.fetchChapterReciters();
expect(rows.single['id'], 7);

final chapter = await chapterSource.loadChapterAudio(
  reciterId: 7,
  surahNumber: 67,
);
expect(chapter['audio_file']['audio_url'], startsWith('https://'));
```

Also test malformed JSON, schema-version mismatch, reciter mismatch, and Surah mismatch.

- [ ] **Step 2: Run loaders and verify RED**

```bash
flutter test test/features/reciters/data/bundled_*_test.dart --reporter expanded
```

Expected: FAIL because the bundle loaders do not exist.

- [ ] **Step 3: Add assets and strict bundle loaders**

Add to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/database/
    - assets/audio/
    - assets/audio/chapters_v1/
```

`BundledReciterCatalogSource` loads `assets/audio/reciters_v1.json` and returns its validated `reciters` list. `BundledChapterAudioSource` loads exactly one `assets/audio/chapters_v1/$reciterId-$surahNumber.json` and returns a backend-compatible envelope:

```dart
{'audio_file': normalizedChapterMap}
```

- [ ] **Step 4: Run loaders and verify GREEN**

```bash
flutter test test/features/reciters/data/bundled_*_test.dart --reporter expanded
```

Expected: PASS.

### Task 4: Remove backend dependency from runtime reciter and chapter-audio preparation

**Files:**
- Modify: `lib/features/reciters/application/reciter_catalog_controller.dart`
- Modify: `lib/features/quran/data/quran_audio_sync_service.dart`
- Modify: `test/features/reciters/application/reciter_catalog_controller_test.dart`
- Create: `test/features/quran/data/quran_audio_sync_service_test.dart`

**Interfaces:**
- Consumes: `BundledReciterCatalogSource`, `BundledChapterAudioSource`, existing user settings database, existing `AudioDownloadRepository`.
- Produces: unchanged `ReciterCatalogController` public API and unchanged `ChapterAudioSyncResult`.

- [ ] **Step 1: Write failing provider/sync tests**

Add a service test where a fake `ChapterAudioSource` returns one chapter document and assert that `syncChapter(downloadAudio: true)`:

- never needs `QuranBackendClient`;
- replaces timing rows;
- registers `chapter:<reciterId>:<surah>`;
- enqueues `reciters/<reciterId>/<surah>.mp3`;
- returns the downloaded local path.

Add a provider test that overrides only the asset bundle/user DB dependencies and proves the catalog can build without `quranBackendClientProvider`.

- [ ] **Step 2: Run tests and verify RED**

```bash
flutter test \
  test/features/quran/data/quran_audio_sync_service_test.dart \
  test/features/reciters/application/reciter_catalog_controller_test.dart \
  --reporter expanded
```

Expected: FAIL because the runtime still constructs backend sources.

- [ ] **Step 3: Inject bundled sources**

Change `QuranAudioSyncService` constructor from `QuranBackendClient backend` to `ChapterAudioSource chapterAudioSource`. In `syncChapter`, replace `_backend.getChapterAudio(...)` with `_chapterAudioSource.loadChapterAudio(...)` and keep all database/download logic intact.

Change `reciterRepositoryProvider` to use `BundledReciterCatalogSource`; change `chapterAudioPreparerProvider` to use `BundledChapterAudioSource`. Do not delete `QuranBackendClient` because tafsir remote-refresh code still uses it.

- [ ] **Step 4: Run targeted and regression tests**

```bash
flutter test \
  test/features/quran/data/quran_audio_sync_service_test.dart \
  test/features/reciters/application/reciter_catalog_controller_test.dart \
  test/features/reciters/data/quran_reciter_repository_test.dart \
  test/features/downloads/data/file_audio_download_repository_test.dart \
  test/features/audio/application/quran_audio_controller_test.dart \
  --reporter expanded
```

Expected: PASS.

### Task 5: Make reciter/download UX actionable offline-first

**Files:**
- Modify: `lib/features/reciters/presentation/reciter_audio_page.dart`
- Modify: `test/features/settings/presentation/settings_page_test.dart`
- Create: `test/features/reciters/presentation/reciter_audio_page_test.dart`

**Interfaces:**
- Consumes: unchanged `ReciterCatalogController` methods `select()` and `prepareChapter()`.
- Produces: clear selected-reciter, stream/prepare, download, retry/progress UI states.

- [ ] **Step 1: Write failing widget tests**

Test that a bundled catalog renders while the backend URL is invalid, selecting a reciter updates selection, and tapping Download current Surah calls `prepareChapter(downloadAudio: true)`.

- [ ] **Step 2: Run and verify RED**

```bash
flutter test test/features/reciters/presentation/reciter_audio_page_test.dart --reporter expanded
```

- [ ] **Step 3: Implement UI state copy and controls**

Replace the dead-end “Reciter catalog is unavailable” path for ordinary backend absence with bundled data. Keep a true bundled-asset corruption error explicit. Show:

- selected reciter indicator;
- current Surah number;
- `Prepare/Stream` action (`downloadAudio: false`);
- `Download for offline` action (`downloadAudio: true`);
- progress/busy state for the active Surah;
- retry after failed download.

Do not redesign the full screen to the final three-skin UI yet; this task restores functionality first.

- [ ] **Step 4: Run widget tests and affected settings tests**

```bash
flutter test \
  test/features/reciters/presentation/reciter_audio_page_test.dart \
  test/features/settings/presentation/settings_page_test.dart \
  --reporter expanded
```

Expected: PASS.

### Task 6: Add release preflight and physical-device audio gates

**Files:**
- Modify: `tool/release/check_release_ready.py`
- Modify: `tool/release/test_release_preflight.py`
- Create: `integration_test/offline_reciter_audio_test.dart`

**Interfaces:**
- Consumes: generated `assets/audio` catalog, Android debug/release builds.
- Produces: release blocker for missing/malformed reciter assets and a physical-device E2E for reciter selection + Surah download.

- [ ] **Step 1: Write failing preflight tests**

Assert the preflight fails when:

- `assets/audio/reciters_v1.json` is missing;
- no `chapters_v1` directory exists;
- any bundled reciter has fewer than 114 chapter files;
- a chapter document contains `example.invalid` or a non-HTTPS audio URL.

- [ ] **Step 2: Run and verify RED**

```bash
python3 -m unittest tool.release.test_release_preflight -v
```

- [ ] **Step 3: Implement preflight checks**

The script parses the reciter index, checks unique positive IDs, verifies exactly 114 `<id>-<surah>.json` files per reciter, validates URL scheme/host, and never reads secrets.

- [ ] **Step 4: Add device E2E**

The integration test must:

1. launch with no backend define;
2. open reciter UI;
3. assert catalog is non-empty;
4. select a reciter;
5. prepare/download Surah 1;
6. assert no “Reciter catalog is unavailable” message appears.

- [ ] **Step 5: Run full verification**

```bash
flutter analyze
flutter test --concurrency=1 --reporter expanded
python3 tool/release/check_release_ready.py
DEVICE="4SR4SGMR65RGWS8T"
flutter test integration_test/offline_reciter_audio_test.dart -d "$DEVICE" --reporter expanded
```

Then manually enable airplane mode and replay the downloaded Surah. Expected: local playback succeeds without a network connection and word tap still works without process termination.

---

## Completion Gate

This phase is complete only when the generated bundled catalog exists, release preflight passes, the full Flutter test suite passes, the physical-device reciter E2E passes, one Surah downloads successfully on the OPPO device, that Surah replays in airplane mode, and word tap-to-play remains functional.

The subsequent implementation plan is the approved three-skin Surah-first/Mushaf UI. It must not start until this audio foundation gate is green because the new reader/player depends on these reciter contracts.
