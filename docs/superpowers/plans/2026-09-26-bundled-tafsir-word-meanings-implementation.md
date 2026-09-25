# Bundled Zakaria Tafsir and Offline Bangla Word Meanings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship Dr. Abu Bakar Muhammad Zakaria Tafsir and all Bangla Quran word meanings inside the app from first install, while keeping optional Quran Foundation Tafsirs selectable online through the existing Cloudflare backend.

**Architecture:** Build Zakaria as versioned per-Surah gzip assets read directly from Flutter assets, then compose that bundled repository with existing downloaded SQLite Tafsirs and a read-only Quran Foundation remote repository. Populate `quran_words.bangla_meaning` during the canonical Quran content build so tapped word meanings are local-first and require no first-use download.

**Tech Stack:** Flutter/Dart, Riverpod, Drift/SQLite, Python content builder, Hono/Cloudflare Workers, Quran Foundation Content API v4, QuranEnc.

**Spec:** `docs/superpowers/specs/2026-09-26-bundled-tafsir-word-meanings-design.md`

## Global Constraints

- Primary Tafsir source id stays `bn.abubakar_zakaria.quranenc`.
- Fresh install defaults to Zakaria and reads it with no network and no first-run extraction.
- Zakaria source translation and footnote strings must remain unchanged from QuranEnc.
- Production Quran content must contain exactly 114 Surahs, 6,236 ayahs, and 77,429 canonical Quran word rows.
- Every canonical Quran word must have one non-empty Bangla meaning before a production content build succeeds.
- Quran Foundation credentials stay backend-only and never ship in the Flutter app.
- Optional Quran Foundation Tafsirs may be online-only in this implementation.
- Existing downloaded Tafsir packages remain supported and may override bundled Zakaria only when a valid newer package with the same source id exists.
- Existing uncommitted Quran UI work in this worktree must not be staged accidentally by Tafsir/content commits.

## Review Focus

- Corrupt or missing bundled Surah asset must produce a local-content error, not silently return unrelated Tafsir.
- A stale/broken downloaded Zakaria override must fall back to the bundled Zakaria source.
- Duplicate remote/local source ids must never create duplicate selector entries.
- Quran Foundation pagination must not truncate whole-Surah Tafsir after 50 rows.
- A production Quran database with any missing Bangla word meaning must fail release validation.

---
## File Structure

- `tool/tafsir/build_zakaria_assets.py` — build verified per-Surah gzip Zakaria assets and manifest from QuranEnc.
- `tool/tafsir/tests/test_build_zakaria_assets.py` — compact asset schema, coverage, corruption, and preservation tests.
- `assets/tafsir/zakaria/1.1.1/` — generated bundled Zakaria manifest plus `001.json.gz` … `114.json.gz`.
- `lib/features/tafsir/data/bundled_zakaria_tafsir_repository.dart` — immutable asset-backed Zakaria reader.
- `lib/features/tafsir/data/composite_tafsir_repository.dart` — merge bundled, downloaded, and remote sources with fallback rules.
- `lib/features/tafsir/data/remote_quran_foundation_tafsir_repository.dart` — read optional online Tafsirs via the app backend.
- `lib/features/tafsir/data/tafsir_text_normalizer.dart` — shared HTML/plain-text normalization used by all Tafsir repositories.
- `lib/features/tafsir/domain/tafsir_entry.dart` — source-kind/offline metadata.
- `lib/features/tafsir/domain/tafsir_repository.dart` — available-source and read interface.
- `lib/features/tafsir/application/tafsir_providers.dart` — compose repositories and source-selection store.
- `lib/features/tafsir/data/tafsir_source_selection_store.dart` — persist selected source id in `UserDatabase` settings.
- `lib/features/tafsir/presentation/tafsir_reader_page.dart` — local-first default and source selector; no Zakaria download gate.
- `backend/src/index.ts` — Quran Foundation Tafsir catalog, ayah, and whole-Surah proxy routes.
- `backend/test/tafsir_quran_foundation.test.mjs` — backend proxy validation and pagination tests.
- `lib/core/network/quran_backend_client.dart` — typed Tafsir catalog/read calls to Cloudflare.
- `tool/quran_content/source_fetcher.dart` — fetch and merge Bangla word meanings into normalized word rows.
- `tool/quran_content/build_quran_db.dart` and `tool/quran_content/quran_integrity_validator.dart` — enforce complete Bangla word coverage and metadata.
- `assets/database/quran_content.sqlite` plus manifest/report — regenerated production database with 77,429 local Bangla meanings.
- Existing `QuranWord.banglaMeaning`, `DriftQuranRepository`, and reader widgets remain the runtime display path.

### Task 1: Build compact bundled Zakaria Tafsir assets

**Files:**
- Create: `tool/tafsir/build_zakaria_assets.py`
- Create: `tool/tafsir/tests/test_build_zakaria_assets.py`
- Create/generated: `assets/tafsir/zakaria/1.1.1/manifest.json`
- Create/generated: `assets/tafsir/zakaria/1.1.1/001.json.gz` … `114.json.gz`
- Modify: `pubspec.yaml`
- Modify: `docs/content/tafsir-zakaria-source.md`

**Interfaces:**
- Consumes: QuranEnc `bengali_zakaria` rows and canonical Surah ayah bounds.
- Produces: `build_asset_bundle(responses, canonical_bounds, output_dir, version) -> AssetBundleBuildResult`; runtime manifest containing source metadata and 114 asset hashes.

- [ ] **Step 1: Write failing builder tests**

Add tests named:
- `test_builds_114_versioned_gzip_surah_assets`
- `test_preserves_translation_and_footnotes_exactly`
- `test_rejects_missing_or_misaligned_ayah`
- `test_manifest_hashes_detect_corrupt_surah_asset`

Assert 114 Surahs / 6,236 rows, exact source strings, deterministic file names, and SHA-256 coverage.

- [ ] **Step 2: Run tests and verify RED**

Run: `python -m unittest tool.tafsir.tests.test_build_zakaria_assets -v`
Expected: FAIL because `build_zakaria_assets` does not exist.

- [ ] **Step 3: Implement the compact builder**

Create `build_asset_bundle(...)` using gzip level 9. Each Surah payload contains `source_id`, `version`, `surah_number`, and ordered entries with `ayah_number`, `translation`, `footnotes`. Reuse source constants/validation from `build_zakaria_package.py`; do not rewrite source text.

- [ ] **Step 4: Run builder tests and verify GREEN**

Run the command from Step 2.
Expected: all asset-builder tests PASS.

- [ ] **Step 5: Generate and validate production assets**

Run the builder against canonical bounds and QuranEnc version `1.1.1`, then verify 114 gzip files, manifest hashes, total 6,236 entries, and compressed asset size.

- [ ] **Step 6: Register the asset directory and commit**

Stage only Task 1 files.
Commit: `feat: bundle compact Zakaria tafsir assets`

---
### Task 2: Read bundled Zakaria and compose it with downloaded Tafsirs

**Files:**
- Create: `lib/features/tafsir/data/bundled_zakaria_tafsir_repository.dart`
- Create: `lib/features/tafsir/data/composite_tafsir_repository.dart`
- Create: `lib/features/tafsir/data/tafsir_text_normalizer.dart`
- Modify: `lib/features/tafsir/data/local_tafsir_repository.dart`
- Modify: `lib/features/tafsir/domain/tafsir_entry.dart`
- Modify: `lib/features/tafsir/domain/tafsir_repository.dart`
- Create: `test/features/tafsir/data/bundled_zakaria_tafsir_repository_test.dart`
- Create: `test/features/tafsir/data/composite_tafsir_repository_test.dart`
- Modify: `test/features/tafsir/data/local_tafsir_repository_test.dart`

**Interfaces:**
- Produces: `enum TafsirSourceKind { bundled, downloaded, remote }`.
- Produces: `TafsirRepository.listSources() -> Future<List<TafsirSource>>`.
- Produces: `BundledZakariaTafsirRepository(AssetBundle bundle, {String manifestAssetPath})`.
- Produces: `CompositeTafsirRepository({required TafsirRepository bundled, required TafsirRepository downloaded, TafsirRepository? remote})`.
- Consumes later: Task 3 and Task 5 use `listSources/readAyah/readSurah`.

- [ ] **Step 1: Write failing bundled-repository tests**

Cover:
- bundled source is listed without any installed package;
- ayah read combines translation + blank line + footnotes using current normalization;
- whole-Surah read preserves canonical order;
- corrupt gzip/hash mismatch throws a packaged-content integrity exception.

- [ ] **Step 2: Run bundled tests and verify RED**

Run: `flutter test test/features/tafsir/data/bundled_zakaria_tafsir_repository_test.dart`
Expected: FAIL because the repository does not exist.

- [ ] **Step 3: Extract shared Tafsir text normalization**

Move the existing `_plainTafsirText` and translation/footnote combining behavior from `local_tafsir_repository.dart` into public, focused helpers in `tafsir_text_normalizer.dart`.

- [ ] **Step 4: Implement `BundledZakariaTafsirRepository`**

Load/validate the manifest once, verify the requested Surah asset hash before decoding, decode only that Surah, and retain a bounded one-Surah cache.

- [ ] **Step 5: Verify bundled tests GREEN**

Run the command from Step 2.
Expected: PASS.

- [ ] **Step 6: Write failing composite-repository tests**

Cover:
- bundled Zakaria + another downloaded source are both listed;
- same source id is de-duplicated;
- a valid dotted-version downloaded Zakaria newer than bundled wins;
- missing/corrupt downloaded Zakaria falls back to bundled;
- a downloaded Zakaria older/equal to bundled does not hide the bundled asset.

- [ ] **Step 7: Run composite tests and verify RED**

Run: `flutter test test/features/tafsir/data/composite_tafsir_repository_test.dart`
Expected: FAIL because composition/source-kind/version precedence is missing.

- [ ] **Step 8: Implement the composite repository and domain changes**

Use source id as the de-duplication key. Compare dot-separated integer versions only for the primary Zakaria source. Preserve all other installed sources.

- [ ] **Step 9: Run Tafsir data tests GREEN and commit**

Run: `flutter test test/features/tafsir/data`
Expected: all Tafsir data tests PASS.

Commit: `feat: add bundled Zakaria tafsir repository`

---

### Task 3: Make Zakaria the persistent first-install default

**Files:**
- Create: `lib/features/tafsir/data/tafsir_source_selection_store.dart`
- Modify: `lib/features/tafsir/application/tafsir_providers.dart`
- Modify: `lib/features/tafsir/presentation/tafsir_reader_page.dart`
- Modify: `test/features/tafsir/presentation/primary_bangla_tafsir_test.dart`
- Modify: `test/features/tafsir/presentation/ayah_tafsir_action_test.dart`
- Modify: `test/features/tafsir/presentation/whole_surah_tafsir_test.dart`

**Interfaces:**
- Produces: `TafsirSourceSelectionStore.read() -> Future<String?>`.
- Produces: `TafsirSourceSelectionStore.write(String sourceId) -> Future<void>`.
- Uses setting key `selected_tafsir_source_v1`.
- Consumes: Task 2 composite repository.

- [ ] **Step 1: Write failing selection/default tests**

Assert:
- no saved preference resolves to `bn.abubakar_zakaria.quranenc`;
- a saved available source is restored;
- a saved missing source falls back to bundled Zakaria;
- changing the selector persists the source id;
- fresh-install Zakaria view contains no “Download tafsir” CTA and never calls `TafsirPackageInstaller`.

- [ ] **Step 2: Run presentation tests and verify RED**

Run: `flutter test test/features/tafsir/presentation`
Expected: relevant new assertions FAIL against the current in-memory/download-gated behavior.

- [ ] **Step 3: Implement the selection store and provider wiring**

Back the store with `UserDatabase.getSetting/saveSetting`; do not add a schema migration.

- [ ] **Step 4: Update `TafsirReaderPage`**

Load the persisted source before reading content, default to bundled Zakaria, persist selector changes, and remove the primary-Zakaria install empty state. Keep downloaded-package installation infrastructure for optional offline sources.

- [ ] **Step 5: Run presentation tests GREEN and commit**

Run: `flutter test test/features/tafsir/presentation`
Expected: PASS.

Commit: `feat: default tafsir to bundled Zakaria`

---
### Task 4: Add optional Quran Foundation Tafsir sources through Cloudflare

**Files:**
- Create: `backend/src/quranFoundationTafsir.ts`
- Modify: `backend/src/index.ts`
- Create: `backend/test/tafsir_quran_foundation.test.mjs`
- Modify: `lib/core/network/quran_backend_client.dart`
- Create: `lib/features/tafsir/data/remote_quran_foundation_tafsir_repository.dart`
- Modify: `lib/features/tafsir/data/composite_tafsir_repository.dart`
- Create: `test/features/tafsir/data/remote_quran_foundation_tafsir_repository_test.dart`
- Modify: `test/features/tafsir/data/composite_tafsir_repository_test.dart`
- Modify: `lib/features/tafsir/presentation/tafsir_reader_page.dart`

**Interfaces:**
- Backend `GET /api/tafsir/resources?language=bn`.
- Backend `GET /api/tafsir/:resourceId/ayah/:surah/:ayah`.
- Backend `GET /api/tafsir/:resourceId/surah/:surah`.
- Backend uses Quran Foundation v4 resource catalog and paginated Tafsir endpoint; whole-Surah proxy loops `per_page=50` until `next_page == null`.
- Flutter remote source ids use `qf.<resourceId>`.
- Remote sources have `TafsirSourceKind.remote` and `availableOffline == false`.

- [ ] **Step 1: Write failing backend tests**

Cover:
- resource catalog is proxied with requested language;
- invalid resource/surah/ayah ids return 400 before upstream call;
- single-ayah response is normalized to one entry;
- whole-Surah route follows upstream pagination beyond 50 rows and returns all rows in ayah order;
- upstream non-2xx is propagated as a safe backend error without exposing backend credentials.

- [ ] **Step 2: Run backend tests and verify RED**

Run: `cd backend && npm test`
Expected: new route tests FAIL because routes/helpers do not exist.

- [ ] **Step 3: Implement backend Tafsir proxy helpers/routes**

Use the existing `qfFetch` authentication path. Prefer the generic Quran Foundation Tafsir endpoint with `chapter_number` or `verse_key` filters so one upstream contract serves both routes.

- [ ] **Step 4: Run backend tests GREEN**

Run: `cd backend && npm test`
Expected: PASS.

- [ ] **Step 5: Write failing Flutter remote-repository tests**

Assert:
- resource JSON maps to `qf.<id>` source ids;
- HTML Tafsir text is normalized through `tafsir_text_normalizer.dart`;
- ayah and whole-Surah backend responses map to `TafsirEntry`;
- backend/catalog failure does not remove bundled Zakaria from composite `listSources()`.

- [ ] **Step 6: Run Flutter remote tests RED**

Run: `flutter test test/features/tafsir/data/remote_quran_foundation_tafsir_repository_test.dart test/features/tafsir/data/composite_tafsir_repository_test.dart`
Expected: FAIL because remote repository/client methods are missing.

- [ ] **Step 7: Implement Flutter backend client + remote repository**

Add typed client methods for the three backend routes. Keep network errors source-scoped: local sources still list/read when the remote catalog is unavailable.

- [ ] **Step 8: Update source selector behavior**

Display all available sources in the existing selector. Mark remote sources as online-only in compact helper text; selecting one persists through Task 3’s store. Do not auto-switch away from Zakaria merely because remote sources exist.

- [ ] **Step 9: Run Tafsir + backend tests and commit**

Run:
- `cd backend && npm test`
- `flutter test test/features/tafsir`

Expected: PASS.

Commit: `feat: add Quran Foundation tafsir sources`

---

### Task 5: Populate all Bangla word meanings during the canonical Quran build

**Files:**
- Modify: `tool/quran_content/source_fetcher.dart`
- Modify: `tool/quran_content/fetch_verified_sources.dart`
- Modify: `tool/quran_content/models/source_records.dart`
- Modify: `tool/quran_content/quran_integrity_validator.dart`
- Modify: `tool/quran_content/build_quran_db.dart`
- Modify: `tool/quran_content/README.md`
- Modify: `test/tool/quran_content/source_fetcher_test.dart`
- Modify: `test/tool/quran_content/quran_integrity_validator_test.dart`
- Modify: `test/tool/quran_content/source_records_test.dart`
- Modify: `test/tool/quran_content/build_report_test.dart`

**Interfaces:**
- Produces: `mergeBanglaWordMeanings({required Map<String,dynamic> words, required Map<int,List<Map<String,dynamic>>> banglaVersesByChapter}) -> Map<String,dynamic>`.
- Extend `QuranFoundationClient.fetchChapterVerses(int chapter, {String language = 'en'})`.
- Normalized word rows must carry non-empty `bangla_meaning` before build output.
- Build metadata records Bangla word source/version.

- [ ] **Step 1: Write failing normalization tests**

Cover:
- Bangla word translation text merges by exact Surah/ayah/word position;
- end markers are ignored consistently;
- missing, duplicate, extra, or empty Bangla word meanings throw;
- canonical mode requires exactly 77,429 matched word meanings.

- [ ] **Step 2: Run source/integrity tests and verify RED**

Run: `flutter test test/tool/quran_content/source_fetcher_test.dart test/tool/quran_content/quran_integrity_validator_test.dart test/tool/quran_content/source_records_test.dart`
Expected: FAIL because Bangla merge/coverage does not exist.

- [ ] **Step 3: Implement Bangla fetch + merge**

Fetch the same canonical chapters with `language=bn`, extract only `char_type_name == word` translation text, and merge into the already-normalized canonical word rows by stable location. Do not alter Arabic/QUL fields.

- [ ] **Step 4: Strengthen production integrity validation**

Reject output when any canonical `bangla_meaning` is null/empty or coverage is not exactly the canonical word set.

- [ ] **Step 5: Run source/integrity tests GREEN**

Run the Step 2 command.
Expected: PASS.

- [ ] **Step 6: Add build-report provenance and commit**

Record Bangla word source/version/hash metadata in the normalized source/build report.

Commit: `feat: build Bangla Quran word meanings offline`

---
### Task 6: Remove first-use Bangla word download behavior and use local meanings by default

**Files:**
- Modify: `lib/features/quran/data/bengali_word_meanings.dart`
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Modify: `lib/features/quran/presentation/widgets/quran_word_view.dart`
- Modify: `test/features/quran/data/bengali_word_meanings_offline_test.dart`
- Modify: `test/features/quran/presentation/quran_reader_page_test.dart`
- Modify: `test/features/quran/presentation/quran_word_view_style_test.dart`

**Interfaces:**
- Runtime primary path remains `QuranWord.banglaMeaning`.
- Network-backed `BengaliWordMeanings.meaningFor` remains only as a compatibility fallback for legacy/development databases with missing local data.
- Production reader no longer exposes per-Surah Bangla word download controls.

- [ ] **Step 1: Write failing local-first tests**

Assert:
- when `QuranWord.banglaMeaning` is present, tapping the word renders that value and never invokes the fallback provider;
- the Quran reader download sheet no longer shows “বাংলা word download”;
- a legacy word with no local meaning may still invoke the fallback service;
- disabling “Tap to show Bangla word meaning” still suppresses the tooltip.

- [ ] **Step 2: Run Quran presentation/data tests and verify RED**

Run: `flutter test test/features/quran/data/bengali_word_meanings_offline_test.dart test/features/quran/presentation/quran_reader_page_test.dart`
Expected: the new download-sheet assertion FAILS against the existing UI.

- [ ] **Step 3: Remove word-download state/actions from the reader**

Delete `_wordDownloadActive`, `_wordDownloaded`, progress state, `_refreshWordDownloadStatus`, `_downloadBanglaWords`, and the Bangla word download list tile. Keep audio-offline downloads separate.

- [ ] **Step 4: Preserve compatibility fallback only for missing local rows**

Do not issue a network request when a non-empty local `banglaMeaning` exists.

- [ ] **Step 5: Run Quran tests GREEN and commit**

Run: `flutter test test/features/quran/data test/features/quran/presentation`
Expected: PASS.

Commit: `feat: use bundled Bangla word meanings by default`

---

### Task 7: Regenerate production content and prove clean-install offline behavior

**Files:**
- Modify/generated: `assets/database/quran_content.sqlite`
- Modify/generated: `assets/database/quran_content_manifest.json`
- Modify/generated: `assets/database/quran_content.sqlite.report.json`
- Modify: `assets/database/README.md`
- Create: `test/features/tafsir/data/bundled_zakaria_production_asset_test.dart`
- Modify: `test/core/database/quran_content_bootstrap_test.dart`
- Modify: `test/app/app_bootstrap_test.dart`

**Interfaces:**
- Consumes: Tasks 1 and 5 generated content.
- Produces: production APK assets with complete local Zakaria + Bangla word meanings.

- [ ] **Step 1: Write failing production-asset tests**

Assert against actual bundled assets:
- Zakaria manifest exists, contains 114 Surah assets, and totals 6,236 entries;
- actual bundled Quran DB has 114 Surahs, 6,236 ayahs, 77,429 words, and zero null/empty `bangla_meaning` rows;
- canonical manifest SHA matches the regenerated DB;
- bootstrap opens the regenerated database without network.

- [ ] **Step 2: Run production-asset tests and verify RED**

Run: `flutter test test/features/tafsir/data/bundled_zakaria_production_asset_test.dart test/core/database/quran_content_bootstrap_test.dart`
Expected: FAIL until generated production assets are replaced.

- [ ] **Step 3: Fetch verified source material and regenerate the Quran database**

Use the documented production Quran Foundation content credentials/source snapshot; run the verified-source fetcher, QUL materializers, and canonical DB builder. Do not commit temporary source credential files or raw build secrets.

- [ ] **Step 4: Run production-asset tests GREEN**

Run the Step 2 command.
Expected: PASS with exact canonical counts and zero missing Bangla meanings.

- [ ] **Step 5: Run complete verification**

Run:
- `python -m unittest discover tool/tafsir/tests -v`
- `cd backend && npm test`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- `git diff --check`

Expected: all commands exit 0.

- [ ] **Step 6: Measure storage assumptions**

Record:
- Zakaria bundled compressed asset total;
- Quran DB size delta before/after Bangla meanings;
- final debug APK size;
- installed app-data size after first launch with no Tafsir extraction.

Acceptance target: no 16–29 MB first-run Zakaria copy is created.

- [ ] **Step 7: Real-device clean/offline acceptance**

Install the APK, start once, disable network before opening Quran/Tafsir content, then verify:
1. Quran page opens.
2. Tapping sampled words across multiple Surahs immediately shows Bangla meanings.
3. Zakaria ayah Tafsir opens.
4. Whole-Surah Zakaria Tafsir opens.
5. Zakaria is selected by default.
6. No Tafsir/word-meaning network dependency appears in logs.

Then restore network and verify another Quran Foundation Tafsir can be selected and read online.

- [ ] **Step 8: Commit generated release assets and acceptance updates**

Commit: `feat: ship offline tafsir and Bangla word content`

---

## Final Review Gate

After Task 7:
- Compare implementation against every section of the approved spec.
- Review all commits from the pre-plan base through HEAD.
- Re-run the full verification commands from Task 7.
- Any Critical/Important review finding gets one TDD fix pass before completion.
- Do not push, merge, or deploy without explicit user approval.
