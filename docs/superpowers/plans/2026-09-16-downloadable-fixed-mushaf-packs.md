# Downloadable Fixed Mushaf Packs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add optional, verified, offline Fixed Mushaf page packs without enlarging the bundled application or shrinking live Quran text.

**Architecture:** Define a versioned manifest and repository boundary, reuse the app's existing streamed-download/checksum/storage patterns, and install page packs atomically under application support storage. Render installed WebP pages in a zoomable paged viewer; word interaction is enabled only when a validated coordinate index exists.

**Tech Stack:** Flutter, Dart IO, Riverpod, crypto, path_provider, archive package, flutter_test

**Spec:** `docs/superpowers/specs/2026-09-16-hifz-free-flow-downloadable-mushaf-design.md`

## Global Constraints

- Only licensed packs with attribution and redistribution terms may appear in the catalog.
- Free Flow remains usable when downloads fail or packs are removed.
- A pack is selectable only after complete checksum verification and atomic extraction.
- The first real catalog entry requires a user-approved licensed IndoPak source.
- The workspace has no Git metadata; replace commit steps with passing verification checkpoints.

---

### Task 1: Pack manifest and catalog domain

**Files:**
- Create: `lib/features/hifz/domain/mushaf_pack_manifest.dart`
- Create: `lib/features/hifz/domain/mushaf_pack_repository.dart`
- Create: `test/features/hifz/domain/mushaf_pack_manifest_test.dart`

**Interfaces:**
- Produces: `MushafPackManifest.fromJson(Map<String,Object?>)` with `id`, `name`, `script`, `version`, `pageCount`, `sizeBytes`, `sha256`, `downloadUrl`, `attribution`, `license`, `pageFilePattern`, and optional `coordinatesFile`.
- Produces: `MushafPackRepository.list()`, `install(id)`, `cancel(id)`, `delete(id)`, and `installedPack(id)`.

- [x] Write manifest validation tests for HTTPS URL, 64-character checksum, pages `1..604`, nonempty license/attribution, and safe relative page patterns.
- [x] Run the manifest test and verify RED.
- [x] Implement immutable manifest parsing and explicit `FormatException` messages.
- [x] Define repository state types `MushafPackStatus` and `MushafPackProgress`.
- [x] Run the domain tests and verify GREEN.

### Task 2: Atomic pack installer

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/features/hifz/data/mushaf_pack_installer.dart`
- Create: `test/features/hifz/data/mushaf_pack_installer_test.dart`

**Interfaces:**
- Consumes: `MushafPackManifest`, injected `MushafPackTransport`, root-directory callback, and `StorageCapacity`.
- Produces: `Future<InstalledMushafPack> install(MushafPackManifest, {required void Function(int,int) onProgress, required bool Function() isCancelled})`.

- [ ] Add `archive` as the only new runtime dependency and resolve packages.
- [ ] Write failing tests for streamed success, insufficient storage, cancellation, size mismatch, SHA mismatch, zip-slip path rejection, missing pages, and rollback when extraction fails.
- [ ] Implement download to `<id>/<version>.zip.part`, streamed SHA-256 verification, extraction into `<version>.installing`, and atomic rename to `<version>`.
- [ ] Validate every expected WebP page and optional coordinate JSON before activation.
- [ ] Run installer tests and verify GREEN with no temporary directories left behind.

### Task 3: Installed-pack persistence and controller

**Files:**
- Modify: `lib/core/database/user_database.dart`
- Regenerate: `lib/core/database/user_database.g.dart`
- Create: `lib/features/hifz/data/file_mushaf_pack_repository.dart`
- Create: `lib/features/hifz/application/mushaf_pack_controller.dart`
- Create: `test/features/hifz/application/mushaf_pack_controller_test.dart`

**Interfaces:**
- Produces: Drift `InstalledMushafPacks` rows keyed by pack id.
- Produces: Riverpod `mushafPackControllerProvider` exposing catalog/install/update/delete progress.

- [ ] Write failing migration/repository/controller tests, including app restart restoration and unavailable selected-pack fallback.
- [ ] Add the Drift table and schema migration; regenerate code with `dart run build_runner build --delete-conflicting-outputs`.
- [ ] Implement repository and controller using the installer boundary.
- [ ] Verify focused database/controller tests pass.

### Task 4: Catalog and appearance integration

**Files:**
- Create: `lib/features/hifz/presentation/mushaf_pack_catalog_sheet.dart`
- Modify: `lib/features/hifz/presentation/hifz_appearance_sheet.dart`
- Modify: `lib/features/settings/domain/app_preferences.dart`
- Modify: `lib/features/settings/application/app_preferences_controller.dart`
- Create: `test/features/hifz/presentation/mushaf_pack_catalog_sheet_test.dart`

**Interfaces:**
- Produces: catalog rows with preview, size, attribution/license, progress, Download/Update/Delete actions.
- Produces: selected pack id preference; `null` means Free Flow.

- [ ] Write failing UI tests for empty catalog, download progress, retry, installed selection, deletion fallback, and license visibility.
- [ ] Implement catalog sheet and selection persistence.
- [ ] Restore a two-mode appearance control only when at least one Fixed Mushaf pack is installed; otherwise show `Download Mushaf` without a dead Fixed mode.
- [ ] Run appearance/catalog/preferences tests and verify GREEN.

### Task 5: Zoomable page viewer and optional word map

**Files:**
- Create: `lib/features/hifz/domain/mushaf_word_region.dart`
- Create: `lib/features/hifz/presentation/downloaded_mushaf_viewer.dart`
- Modify: `lib/features/hifz/presentation/hifz_page.dart`
- Create: `test/features/hifz/presentation/downloaded_mushaf_viewer_test.dart`

**Interfaces:**
- Consumes: installed pack root, `pageFilePattern`, page number, optional normalized word regions.
- Produces: `DownloadedMushafViewer` using `PageView.builder`, `InteractiveViewer`, and adjacent-page image precaching.

- [ ] Write failing tests for page order, missing page error, pinch/double-tap zoom reset, adjacent prefetch, RTL navigation, and coordinate hit-testing.
- [ ] Implement the viewer with bounded zoom and page caching.
- [ ] Parse coordinate rectangles in normalized page coordinates and expose word callbacks only when the index validates against canonical Quran word locations.
- [ ] Route Hifz to the viewer when an installed pack is selected; otherwise use Free Flow.
- [ ] Run viewer and Hifz interaction tests and verify GREEN.

### Task 6: End-to-end pack acceptance

**Files:**
- Create: `tool/mushaf_pack/build_pack.dart`
- Create: `test/tool/mushaf_pack/build_pack_test.dart`
- Modify: `docs/content/mushaf-pack-format.md`

**Interfaces:**
- Produces: deterministic ZIP + manifest from an already-rendered licensed WebP page directory; it does not convert or redistribute an unapproved PDF.

- [ ] Write a failing tool test using three synthetic WebP fixtures and assert deterministic order/checksum/manifest output.
- [ ] Implement pack assembly, page completeness validation, and SHA-256 emission.
- [ ] Document the exact manifest schema, filenames, coordinate schema, conversion recommendations, and licensing checklist.
- [ ] Build and install one synthetic development pack; verify download, offline restart, paging, zoom, deletion, and Free Flow fallback on the connected Android device.
- [ ] Run complete verification: formatting, analyzer, all tests, debug APK build, and Android smoke test.
