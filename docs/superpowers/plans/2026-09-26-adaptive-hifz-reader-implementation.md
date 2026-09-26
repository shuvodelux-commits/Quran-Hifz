# Adaptive Hifz Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the approved adaptive Hifz Mushaf UI, a four-font Quran Foundation-backed Quran body-font catalog shared by Quran and Hifz modes with independent settings, and the existing three-stage 1×–5× Hifz repetition workflow.

**Architecture:** Keep one shared Quran body-font catalog in the Quran domain, but persist Quran-reader and Hifz typography independently. Unicode QPC Hafs and IndoPak use the adaptive Flutter text path; QCF V2 and QCF V4 Tajweed use the strict page/glyph renderer with Quran Foundation page fonts. Reuse the existing Hifz session/audio domain and progressively refactor the strict Mushaf renderer into shared Quran infrastructure rather than building a second playback or page engine.

**Tech Stack:** Flutter/Dart, Riverpod, Drift settings storage, SQLite bundled Quran/Mushaf data, WebView-based QCF page renderer, `http`, `just_audio`, existing Android/ADB workflow.

**Spec:** `docs/superpowers/specs/2026-09-26-adaptive-hifz-reader-design.md`

## Global Constraints

- Execute in a clean isolated worktree created at implementation time with `superpowers:using-git-worktrees`. The execution base must include the already-approved Quran reader/Bismillah changes that are currently uncommitted in this worktree; first establish an explicit clean baseline commit containing only those desired changes, then create the implementation worktree from that baseline. Do not carry unrelated deleted/modified Hifz, progress, revision, backend, or settings files, and do not silently discard approved uncommitted UI assets.
- Use the approved shared Quran body-font catalog only: QPC Hafs/Uthmani, IndoPak Nastaleeq, QCF V2 Madani, QCF V4 Tajweed.
- Quran mode and Hifz mode expose the same catalog but persist font, size, line spacing, and rendering-style state independently.
- QPC Hafs uses Quran Foundation `text_qpc_hafs`; IndoPak uses `text_indopak`; QCF V2 uses `code_v2` with Mushaf ID 1; QCF V4 uses `code_v2` with Mushaf ID 19.
- Bundle the Quran Foundation Unicode TTFs from the documented CDN:
  - `https://verses.quran.foundation/fonts/quran/hafs/uthmanic_hafs/UthmanicHafs1Ver18.ttf`
  - `https://verses.quran.foundation/fonts/quran/hafs/nastaleeq/indopak/indopak-nastaleeq-waqf-lazim-v4.2.1.ttf`
- QCF page-font URLs must use Quran Foundation only:
  - V2: `https://verses.quran.foundation/fonts/quran/hafs/v2/woff2/p{PAGE}.woff2`
  - V4: `https://verses.quran.foundation/fonts/quran/hafs/v4/colrv1/woff2/p{PAGE}.woff2`
- Keep Inter for English UI, SolaimanLipi for Bangla UI, SurahNameV4 for Surah calligraphy, and the approved dedicated Bismillah glyph/font; these are not selectable Quran body fonts.
- Remove legacy user-selectable Quran body fonts and their unused asset files: PDMS Saleem, old IndoPak file, DigitalKhatt IndoPak, Al Qalam, Muhammadi, Noto Naskh Quran option, old KFGQPC body-font file, and DigitalKhatt V2 Mushaf option when no longer referenced.
- Do not add new package dependencies unless a failing platform requirement proves one is necessary.
- Preserve canonical 604-page anchors, Surah/Bismillah rules, word/ayah taps, active playback highlighting, range selection, auto-follow, and existing Hifz checkpoint semantics.
- Adaptive Hifz default target is approximately 30–32 logical px with font-relative line height around 1.8–2.0; tune on the connected Android device rather than hard-coding an unverified visual result.
- Enlarging adaptive text must grow vertically and reflow; never shrink to preserve 15 lines, horizontally scroll, or stretch Arabic into visibly unnatural gaps.
- Hifz repetition has three independent stages, each 1×–5×; defaults are New Ayah 5×, Accumulated Revision 3×, Final Full Range 3×.
- Hifz audio itself stays at 1.0× playback speed.
- Core Hifz reading must remain usable offline. If an uncached strict QCF page font is unavailable offline, show a readable Unicode fallback for that page rather than a blank/broken page, and retry strict rendering when the font becomes available.
- Add an accessible in-app credit equivalent to “Quran fonts provided by Quran Foundation” because bundled/cached Quran Foundation fonts are used.

## Review Focus

- **Legacy saved font names:** old persisted enum names must migrate to a supported font without crashing or resetting unrelated settings; pin this in Task 2 repository tests.
- **Adaptive ↔ strict font switching at the current location:** changing QPC/IndoPak/QCF must preserve the visible ayah/page anchor instead of jumping to Surah start; pin this in Tasks 6 and 7 widget tests.
- **Offline uncached QCF page:** strict selection must fall back to readable Unicode, never blank/squares, and must recover after cache availability; pin this in Tasks 3 and 5 tests.
- **Large font/system scale:** 38–40 px and Android text scaling must not cause horizontal overflow or diacritic clipping; pin this in Task 6 layout/widget tests and real-device checks.
- **Pattern changes during active playback:** changing 5×/3×/3× settings must not mutate the in-flight step halfway through; apply the new pattern on the next sequence start and pin this in Task 8 controller/widget tests.

---

## File Structure

The implementation should converge on these responsibilities:

- `lib/features/quran/domain/quran_font_preference.dart` — the only user-selectable Quran body-font catalog and renderer metadata.
- `lib/features/quran/domain/quran_mushaf_variant.dart` — strict QCF variant identity shared by Quran and Hifz.
- `lib/features/quran/data/quran_foundation_page_font_repository.dart` — QCF page-font URL mapping, cache validation, atomic writes, neighbor prefetch.
- `lib/features/quran/presentation/mushaf/` — shared low-level WebView payload/driver/view primitives for strict QCF rendering.
- `lib/features/settings/domain/app_preferences.dart` and repository/controller — independent Quran/Hifz typography persistence and legacy migration.
- `lib/features/hifz/presentation/hifz_mushaf_surface.dart` — adaptive/free-flow variable-height Hifz page section with stable page anchors; the strict renderer remains separate.
- Existing `HifzSequenceBuilder`, session controller, and audio port — remain the single Hifz playback engine.
- Existing Quran reader and Hifz page widgets — choose adaptive vs strict renderer from the selected `QuranFontPreference`.

### Task 0: Establish the Clean Approved Execution Baseline

**Files:**
- SCM/preflight only; do not edit product files in this task.
- Inspect the current worktree's Quran-reader/Bismillah diffs and untracked assets.
- Leave unrelated Hifz/progress/revision/backend/settings deletions and modifications untouched in the original worktree.

**Interfaces:**
- Produces: one clean baseline commit containing only already-approved Quran reader/Bismillah UI work that this feature must preserve.
- Produces: one new isolated implementation worktree created from that clean baseline.
- Does not stage, revert, delete, or overwrite unrelated current-worktree changes.

- [ ] **Step 1: Inventory the dirty worktree before touching Git state**

Run `git status --short`, then inspect diffs only for the approved Quran reader/Bismillah paths and the known untracked assets such as `assets/fonts/qpc-v4-tajweed-p1.ttf`, `bismillah_v4_glyph.dart`, and `reader_surah_strip.dart`.

- [ ] **Step 2: Prove the approved baseline subset is self-consistent**

Run the existing focused Quran/Bismillah tests covering the files selected for the baseline. Do not include unrelated dirty Hifz/progress/revision/backend/settings files just to make the baseline green.

- [ ] **Step 3: Stage only the reviewed approved baseline subset**

Before committing, run `git diff --cached --name-status` and require every staged path to belong to the already-approved Quran reader/Bismillah work. If any unrelated path is staged, unstage it before proceeding.

- [ ] **Step 4: Commit the approved baseline**

Use a focused commit such as:

```bash
git commit -m "feat: preserve approved Quran reader visuals"
```

- [ ] **Step 5: Create the isolated implementation worktree**

Invoke `superpowers:using-git-worktrees` and create the implementation branch/worktree from the new clean baseline commit. Confirm `git status --short` is empty inside the new worktree before Task 1.

### Task 1: Replace the Quran Body-Font Catalog and Assets

**Files:**
- Modify: `lib/features/quran/domain/quran_font_preference.dart`
- Modify: `lib/features/quran/domain/quran_script.dart`
- Modify: `pubspec.yaml`
- Modify: `assets/fonts/README.md`
- Modify: `lib/features/home/presentation/more_page.dart`
- Create: `assets/fonts/UthmanicHafs1Ver18.ttf`
- Create: `assets/fonts/indopak-nastaleeq-waqf-lazim-v4.2.1.ttf`
- Preserve from approved baseline: `assets/fonts/qpc-v4-tajweed-p1.ttf`
- Remove: `assets/fonts/PDMS-Saleem-QuranFont.ttf`
- Remove: `assets/fonts/Indopak-Nastaleeq.ttf`
- Remove: `assets/fonts/DigitalKhattIndoPak.otf`
- Remove: `assets/fonts/Al-Qalam-Quran-Majeed.ttf`
- Remove: `assets/fonts/Muhammadi-Quran.ttf`
- Remove: `assets/fonts/NotoNaskhArabic.ttf`
- Remove: `assets/fonts/KFGQPC-Uthmanic-Script-HAFS-Regular.otf`
- Test: `test/features/quran/domain/quran_font_preference_test.dart`
- Create test: `test/assets/quran_font_asset_test.dart`

**Interfaces:**
- Produces: `enum QuranFontRenderKind { adaptiveUnicode, strictQcfV2, strictQcfV4Tajweed }`
- Produces: `QuranFontPreference.qpcHafs`, `.indoPak`, `.qcfV2`, `.qcfV4Tajweed`
- Produces per option: `label`, `script`, `renderKind`, `mushafId`, nullable static `fontFamily`
- Produces: `QuranFontPreference.defaultGlobal == qpcHafs` and `defaultHifz == qpcHafs`

- [ ] **Step 1: Write failing catalog tests**

Update `quran_font_preference_test.dart` to assert exactly four enum values in the approved order and these fixed mappings:

```dart
expect(QuranFontPreference.values, [
  QuranFontPreference.qpcHafs,
  QuranFontPreference.indoPak,
  QuranFontPreference.qcfV2,
  QuranFontPreference.qcfV4Tajweed,
]);
expect(QuranFontPreference.qpcHafs.mushafId, 5);
expect(QuranFontPreference.indoPak.mushafId, 3);
expect(QuranFontPreference.qcfV2.mushafId, 1);
expect(QuranFontPreference.qcfV4Tajweed.mushafId, 19);
```

Also assert QPC/IndoPak are adaptive and both QCF options are strict.

- [ ] **Step 2: Write failing asset-manifest test**

In `quran_font_asset_test.dart`, assert `pubspec.yaml` registers only the two Quran Foundation Unicode body-font families plus Inter, SolaimanLipi, SurahNameV4, and the approved Bismillah asset/family; assert all seven legacy body-font filenames are absent.

- [ ] **Step 3: Run the targeted tests and verify they fail**

Run:

```bash
flutter test test/features/quran/domain/quran_font_preference_test.dart test/assets/quran_font_asset_test.dart
```

Expected: FAIL because the current seven-entry catalog and legacy assets still exist.

- [ ] **Step 4: Implement the four-entry domain catalog**

Replace the old enum with the interfaces above. Keep script fallback metadata only for safety; fallback families must not become selectable options.

- [ ] **Step 5: Replace Unicode body-font files with the documented Quran Foundation TTFs**

Download the two exact documented TTFs into the new asset paths, record their Quran Foundation source URLs and retrieval date in `assets/fonts/README.md`, and remove the obsolete body-font files and `pubspec.yaml` registrations.

- [ ] **Step 6: Add Quran Foundation credit copy**

Add the exact visible credit string to `lib/features/home/presentation/more_page.dart` without creating a new screen: `Quran fonts provided by Quran Foundation`.

- [ ] **Step 7: Run targeted tests**

Expected: both targeted files PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/quran/domain/quran_font_preference.dart lib/features/quran/domain/quran_script.dart pubspec.yaml assets/fonts test/features/quran/domain/quran_font_preference_test.dart test/assets/quran_font_asset_test.dart lib/features/home/presentation/more_page.dart
git commit -m "refactor: use Quran Foundation font catalog"
```

### Task 2: Migrate and Isolate Quran vs Hifz Typography Preferences

**Files:**
- Modify: `lib/features/settings/domain/app_preferences.dart`
- Modify: `lib/features/settings/application/app_preferences_controller.dart`
- Modify: `lib/features/settings/data/user_database_app_preferences_repository.dart`
- Modify: `lib/features/hifz/application/hifz_appearance_controller.dart`
- Modify: `lib/features/hifz/presentation/hifz_appearance_sheet.dart`
- Remove: `lib/features/hifz/domain/hifz_font_preference.dart`
- Test: `test/features/settings/domain/app_preferences_test.dart`
- Test: `test/features/settings/application/app_preferences_controller_test.dart`
- Test: `test/features/settings/data/user_database_app_preferences_repository_test.dart`
- Test: `test/features/hifz/presentation/hifz_appearance_sheet_test.dart`

**Interfaces:**
- Consumes: Task 1 `QuranFontPreference`
- Keeps: `quranFont`, `arabicFontSize`, `arabicLineHeight`
- Keeps independently: `hifzQuranFont`, `hifzFontSize`, `hifzLineHeight`, `hifzLayoutMode`
- Produces: `setQuranFont(QuranFontPreference)` and `setHifzQuranFont(QuranFontPreference)` that never mutate the other mode's font/size/spacing

- [ ] **Step 1: Write legacy migration tests**

Seed settings with old names and assert deterministic migration:

```text
pdmsSaleem / indopakNastaleeq / digitalKhatt / alQalam / muhammadi -> indoPak
kfgqpcHafs / notoNaskhArabic -> qpcHafs
unknown -> mode default
```

Verify unrelated size, theme, language, and audio settings survive migration.

- [ ] **Step 2: Strengthen independence tests**

Assert:
- changing Quran font/size/line height leaves all Hifz typography unchanged;
- changing Hifz font/size/line height leaves Quran typography unchanged;
- concurrent updates remain serialized by the existing controller queue.

- [ ] **Step 3: Run preference tests and verify failure**

Run:

```bash
flutter test test/features/settings/domain/app_preferences_test.dart test/features/settings/application/app_preferences_controller_test.dart test/features/settings/data/user_database_app_preferences_repository_test.dart test/features/hifz/presentation/hifz_appearance_sheet_test.dart
```

- [ ] **Step 4: Implement legacy-name parsing in the settings repository**

Replace generic enum-name fallback with an explicit compatibility mapper so deleted enum values still load safely. Continue writing only new enum names after migration.

- [ ] **Step 5: Remove the separate Hifz-only font enum**

Make `HifzAppearanceSheet` and `HifzAppearanceOverride` consume `QuranFontPreference` directly and display `QuranFontPreference.values`, so Quran and Hifz expose the identical catalog.

- [ ] **Step 6: Keep mode-specific controls separate**

Hifz preview/size/line-height controls must write only Hifz keys. Normal Settings page controls continue writing only Quran-reader keys.

- [ ] **Step 7: Run tests**

Expected: all targeted preference and Hifz appearance tests PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/settings lib/features/hifz/application/hifz_appearance_controller.dart lib/features/hifz/presentation/hifz_appearance_sheet.dart lib/features/hifz/domain/hifz_font_preference.dart test/features/settings test/features/hifz/presentation/hifz_appearance_sheet_test.dart
git commit -m "refactor: isolate Quran and Hifz font settings"
```

### Task 3: Replace Tarteel Page-Font Downloads with Quran Foundation QCF Cache

**Files:**
- Create: `lib/features/quran/domain/quran_page_font_repository.dart`
- Create: `lib/features/quran/data/quran_foundation_page_font_repository.dart`
- Modify/remove: `lib/features/hifz/domain/mushaf_page_font_repository.dart`
- Modify/remove: `lib/features/hifz/data/qpc_v4_page_font_repository.dart`
- Modify: `lib/features/hifz/application/hifz_mushaf_providers.dart`
- Create test: `test/features/quran/data/quran_foundation_page_font_repository_test.dart`
- Modify/remove test: `test/features/hifz/data/qpc_v4_page_font_repository_test.dart`

**Interfaces:**
- Produces: `Uri quranFoundationPageFontUri(QuranFontPreference font, int page)`
- Produces: `QuranFoundationPageFontRepository({required QuranFontPreference font, ...})`
- Produces: `Future<Uri> ensurePageFont(int page)`, `Future<bool> isCached(int page)`, `Future<void> prefetchNeighbors(int page)`
- Accepts only `qcfV2` and `qcfV4Tajweed`; adaptive fonts throw `ArgumentError`

- [ ] **Step 1: Write failing URL/cache tests**

Pin:
- QCF V2 page 440 URL -> `.../hafs/v2/woff2/p440.woff2`
- QCF V4 page 440 URL -> `.../hafs/v4/colrv1/woff2/p440.woff2`
- cache roots are separate for V2 and V4;
- invalid WOFF2, HTTP failure, and interrupted atomic replacement preserve a valid previous cache;
- page 0/605 throws.

- [ ] **Step 2: Add the Review Focus offline test**

With the HTTP client throwing and no cache, assert `ensurePageFont` fails with a typed/recognizable error while leaving no corrupt `.part` file. The renderer fallback is tested in Task 5.

- [ ] **Step 3: Run test and verify failure**

Run:

```bash
flutter test test/features/quran/data/quran_foundation_page_font_repository_test.dart
```

- [ ] **Step 4: Generalize the existing verified cache implementation**

Move the interface and cache implementation into Quran shared infrastructure, retain WOFF2 magic validation, in-flight deduplication, neighbor prefetch, and atomic replacement, but use only Quran Foundation URLs.

- [ ] **Step 5: Rewire Hifz providers**

Strict Hifz rendering requests the page-font repository for the selected strict `QuranFontPreference`; remove the hard-coded Tarteel QPC V4 URL.

- [ ] **Step 6: Run targeted tests**

Expected: PASS and no source reference to `static-cdn.tarteel.ai/qul/fonts/quran_fonts` remains.

- [ ] **Step 7: Commit**

```bash
git add lib/features/quran/domain/quran_page_font_repository.dart lib/features/quran/data/quran_foundation_page_font_repository.dart lib/features/hifz test/features/quran/data/quran_foundation_page_font_repository_test.dart test/features/hifz/data/qpc_v4_page_font_repository_test.dart
git commit -m "refactor: source QCF page fonts from Quran Foundation"
```

### Task 4: Make Strict QCF Mushaf Variants Shared and Remove DigitalKhatt

**Files:**
- Create: `lib/features/quran/domain/quran_mushaf_variant.dart`
- Create: `tool/mushaf/build_quran_foundation_qcf_assets.dart`
- Create test: `test/tool/mushaf/build_quran_foundation_qcf_assets_test.dart`
- Create generated asset: `assets/mushaf/scripts/qcf-v2-words.sqlite`
- Create generated asset: `assets/mushaf/layouts/qcf-v2-15-lines.sqlite`
- Modify: `lib/features/hifz/domain/hifz_reading_mode.dart`
- Modify: `lib/features/hifz/domain/hifz_mushaf_page.dart`
- Modify: `lib/features/hifz/domain/hifz_mushaf_page_repository.dart`
- Modify: `lib/features/hifz/data/bundled_hifz_mushaf_page_repository.dart`
- Modify: `lib/features/hifz/application/hifz_mushaf_controller.dart`
- Modify: `lib/features/hifz/application/hifz_mushaf_providers.dart`
- Modify: `lib/features/settings/domain/app_preferences.dart`
- Modify: `lib/features/settings/application/app_preferences_controller.dart`
- Modify: `lib/features/settings/data/user_database_app_preferences_repository.dart`
- Remove: `assets/mushaf/fonts/DigitalKhattV2.otf`
- Remove: `assets/mushaf/layouts/digital-khatt-15-lines.sqlite`
- Test: `test/features/hifz/data/bundled_hifz_mushaf_page_repository_test.dart`
- Test: `test/features/hifz/application/hifz_mushaf_controller_test.dart`
- Test: `test/features/hifz/domain/mushaf_pack_manifest_test.dart`
- Test: `test/features/settings/domain/app_preferences_test.dart`
- Test: `test/features/settings/data/user_database_app_preferences_repository_test.dart`

**Interfaces:**
- Produces: `enum QuranMushafVariant { qcfV2, qcfV4Tajweed }`
- Produces mapping `QuranFontPreference.qcfV2 -> QuranMushafVariant.qcfV2`, `qcfV4Tajweed -> qcfV4Tajweed`
- Changes persisted `hifzMushafVariant` type from `HifzMushafVariant` to `QuranMushafVariant`; legacy `qpcV4Tajweed` migrates to `qcfV4Tajweed`, legacy `digitalKhattV2` migrates to `qcfV2`
- Removes user-facing/runtime DigitalKhatt variant
- Preserves page range 1–604 and current page/ayah lookup contract

- [ ] **Step 1: Write failing variant tests**

Assert only two strict variants exist, adaptive fonts have no strict variant, and the strict variants retain 604-page navigation.

- [ ] **Step 2: Add QCF V2 asset/data fixture coverage**

Implement `tool/mushaf/build_quran_foundation_qcf_assets.dart` to materialize the existing verified Mushaf script/layout schema from Quran Foundation Mushaf ID 1 into exactly:
- `assets/mushaf/scripts/qcf-v2-words.sqlite`
- `assets/mushaf/layouts/qcf-v2-15-lines.sqlite`

The generator must request `code_v2,text_qpc_hafs,page_number,line_number` for Mushaf 1, read credentials only from environment variables, never write credentials to disk/logs, and reject output unless pages 1–604 and all referenced word locations validate. `test/tool/mushaf/build_quran_foundation_qcf_assets_test.dart` uses fixtures/fake HTTP, not live credentials.

- [ ] **Step 3: Validate V4 source semantics**

Keep/regenerate the V4 script/layout for Mushaf ID 19 and pin page 440 structure: lines 1–3 ayah, line 4 Surah name 36, line 5 Bismillah, lines 6–15 ayah.

- [ ] **Step 4: Run targeted tests and verify failures**

Run:

```bash
flutter test test/tool/mushaf/build_quran_foundation_qcf_assets_test.dart test/features/hifz/data/bundled_hifz_mushaf_page_repository_test.dart test/features/hifz/application/hifz_mushaf_controller_test.dart test/features/hifz/domain/mushaf_pack_manifest_test.dart test/features/settings/domain/app_preferences_test.dart test/features/settings/data/user_database_app_preferences_repository_test.dart
```

- [ ] **Step 5: Replace Hifz-only variant identity with shared QCF variants**

Keep controller/session behavior unchanged; replace the old Hifz variant type in preferences/providers with `QuranMushafVariant`, add the explicit legacy-name migration above, and derive the strict variant from the selected strict `QuranFontPreference`.

- [ ] **Step 6: Remove DigitalKhatt assets and registrations once no references remain**

Run `git grep -n "DigitalKhatt\|digitalKhatt"` and require zero product references before deletion.

- [ ] **Step 7: Run targeted tests**

Expected: PASS for both QCF variants and page-440 structure.

- [ ] **Step 8: Commit**

```bash
git add lib/features/quran/domain/quran_mushaf_variant.dart lib/features/hifz lib/features/settings tool/mushaf assets/mushaf test/features/hifz test/features/settings test/tool/mushaf
git commit -m "refactor: share Quran Foundation QCF variants"
```

### Task 5: Extract a Shared Strict QCF Renderer with Offline Unicode Fallback

**Files:**
- Create directory: `lib/features/quran/presentation/mushaf/`
- Move/refactor from Hifz:
  - `mushaf_renderer_message.dart`
  - `mushaf_webview_driver.dart`
  - `hifz_mushaf_webview.dart`
- Create: `lib/features/quran/presentation/mushaf/quran_mushaf_webview.dart`
- Create: `lib/features/quran/presentation/mushaf/quran_strict_mushaf_surface.dart`
- Modify: `lib/features/hifz/presentation/hifz_mushaf_page_view.dart`
- Modify assets: `assets/mushaf/renderer/index.html`, `mushaf.css`, `mushaf.js`
- Move/update tests:
  - `test/features/hifz/presentation/mushaf_renderer_message_test.dart`
  - `test/features/hifz/presentation/mushaf_webview_driver_test.dart`
  - `test/features/hifz/presentation/hifz_mushaf_page_view_test.dart`
- Create: `test/features/quran/presentation/quran_strict_mushaf_surface_test.dart`

**Interfaces:**
- Produces reusable strict surface accepting page data, variant, page-font bytes/URI, active ayah/word, selected range, and interaction callbacks.
- Produces a fallback builder that receives the corresponding `QuranPageWindow` and adaptive `QuranFontPreference.qpcHafs` when strict font loading fails offline.
- Hifz wrapper retains `onWordTap`, `onWordLongPress`, `onAyahSelected`, auto-follow, and range highlighting.

- [ ] **Step 1: Write shared-renderer tests**

Assert:
- V2 and V4 payloads use distinct font family/version names;
- renderer event parsing remains unchanged;
- navigation blocks non-file/non-about URLs;
- end markers use the Unicode Hafs family per Quran Foundation guidance;
- active highlight and selected range updates do not require a full page reload.

- [ ] **Step 2: Write the offline fallback test**

Simulate page-font loader failure. Assert the page still renders readable Unicode Quran text, page number, Surah boundary/Bismillah, and a retry path; assert no square/empty glyph placeholder surface is shown.

- [ ] **Step 3: Run targeted tests and verify failure**

- [ ] **Step 4: Extract low-level renderer primitives into Quran shared infrastructure**

Do not move Hifz session logic. The shared strict renderer knows only Quran page rendering and interaction events.

- [ ] **Step 5: Update JS/CSS for V2/V4 selection**

Keep exact canonical line grouping for strict mode; use the supplied font version/palette and retain existing tap/long-press bridge messages.

- [ ] **Step 6: Wire Hifz strict page view to the shared renderer**

Preserve current page controller, generation recovery, auto-follow, and fallback behavior.

- [ ] **Step 7: Run renderer/Hifz tests**

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/quran/presentation/mushaf lib/features/hifz/presentation assets/mushaf/renderer test/features/quran/presentation test/features/hifz/presentation
git commit -m "refactor: share strict QCF Mushaf renderer"
```

### Task 6: Build the Adaptive Hifz Mushaf-Like Reading Surface

**Files:**
- Modify: `lib/features/hifz/presentation/hifz_page.dart`
- Modify: `lib/features/hifz/presentation/hifz_mushaf_surface.dart`
- Modify: `lib/features/hifz/application/hifz_flow_composer.dart`
- Modify: `lib/features/hifz/presentation/hifz_flow_line.dart`
- Modify: `lib/features/hifz/application/hifz_text_layout.dart`
- Reuse: `lib/features/quran/presentation/widgets/surah_name_v4_text.dart`
- Reuse: `lib/features/quran/presentation/widgets/bismillah_v4_glyph.dart`
- Test: `test/features/hifz/application/hifz_flow_composer_test.dart`
- Test: `test/features/hifz/application/hifz_text_layout_test.dart`
- Test: `test/features/hifz/presentation/hifz_mushaf_surface_test.dart`
- Test: `test/features/hifz/presentation/hifz_page_test.dart`

**Interfaces:**
- `HifzMushafSurface` remains the adaptive/free-flow page widget receiving `QuranPageWindow`, Surah summaries, Hifz font/size/line-height, current selection/playback, and existing callbacks; `HifzMushafPageView` remains the separate strict QCF renderer.
- Adaptive Unicode font rendering supports QPC Hafs and IndoPak only.
- Strict QCF font selection routes to Task 5 instead of trying to reflow glyph fonts.

- [ ] **Step 1: Write layout tests for natural reflow**

Assert at 31 px and 38–40 px:
- no `FittedBox` or font-size shrinking;
- no horizontal scrolling;
- row gaps remain at natural/minimum spacing rather than stretching to fill width;
- larger size produces more vertical extent while keeping the same page identity.

- [ ] **Step 2: Add Surah/Bismillah/page-anchor tests**

Use page 440 and assert:
- Surah 36 divider appears at the canonical transition;
- Bismillah appears once beneath it;
- page footer remains Page 440;
- switching font size keeps the same logical page/ayah content.

- [ ] **Step 3: Add interaction/highlight tests**

Pin word tap, word long-press, ayah-range selection, active ayah, active word, and hide/reveal styling without changing line metrics.

- [ ] **Step 4: Run targeted tests and verify failure**

Run:

```bash
flutter test test/features/hifz/application/hifz_flow_composer_test.dart test/features/hifz/application/hifz_text_layout_test.dart test/features/hifz/presentation/hifz_mushaf_surface_test.dart test/features/hifz/presentation/hifz_page_test.dart
```

- [ ] **Step 5: Implement the adaptive paper surface**

Use warm ivory outer background, near-white page surface, restrained Surah divider, centered Bismillah, continuous RTL Quran flow, subtle inline ayah markers, and a compact footer with available Juz/Hizb/Page metadata.

- [ ] **Step 6: Remove fixed-line shrink behavior from adaptive mode**

Remove `fitRenderedFontSize` from the adaptive `HifzMushafSurface` path. If `git grep` shows no remaining strict Flutter caller after Task 5, delete the helper entirely; otherwise keep it only in the strict caller and add a test proving adaptive mode never invokes it.

- [ ] **Step 7: Preserve visible anchor when size/font changes**

Before rebuilding typography, capture current visible page/ayah and restore scroll position to that logical anchor after layout.

- [ ] **Step 8: Run targeted tests**

Expected: PASS with no overflow exceptions.

- [ ] **Step 9: Commit**

```bash
git add lib/features/hifz test/features/hifz
git commit -m "feat: add adaptive Hifz Mushaf reader"
```

### Task 7: Show the Same Four Fonts in Quran Mode and Route Each Correctly

**Files:**
- Modify: `lib/features/settings/presentation/settings_page.dart`
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Modify: `lib/features/quran/presentation/quran_text_style.dart`
- Modify: `lib/features/quran/presentation/widgets/quran_word_view.dart`
- Modify: `lib/features/quran/presentation/widgets/reader_window.dart` if it owns the body switch
- Test: `test/features/quran/presentation/quran_reader_page_test.dart`
- Test: `test/features/quran/presentation/quran_word_view_style_test.dart`
- Test: `test/features/quran/presentation/quran_surah_list_page_test.dart`
- Test: `test/features/settings/application/app_preferences_controller_test.dart`

**Interfaces:**
- Consumes: Task 1 four-font catalog, Task 5 strict renderer.
- Adaptive QPC uses `QuranWord.arabic` / `text_qpc_hafs`.
- Adaptive IndoPak uses `QuranWord.arabicIndopak` / `text_indopak`.
- QCF V2/V4 switch the Quran body to strict page rendering while keeping Quran-mode preferences independent of Hifz.

- [ ] **Step 1: Write selector parity test**

Render normal Settings and Hifz Appearance Sheet under the same preferences and assert both expose exactly the same four labels in the same order.

- [ ] **Step 2: Write Quran adaptive script-pairing tests**

Assert QPC never renders IndoPak text and IndoPak never renders QPC text. If IndoPak data is absent in a legacy content package, use the existing verified QPC fallback and expose no invented text.

- [ ] **Step 3: Write strict selection/anchor test**

Start the Quran reader at a known ayah/page, switch to QCF V2 and then V4, and assert the strict renderer opens the same canonical page/ayah anchor instead of resetting to Surah start. Switch back to QPC and assert the same anchor is retained.

- [ ] **Step 4: Run targeted tests and verify failure**

- [ ] **Step 5: Update normal Quran font selector**

Use `QuranFontPreference.values`; remove legacy script/font copy and show concise renderer-aware helper text for adaptive vs strict choices.

- [ ] **Step 6: Route adaptive and strict Quran body rendering**

Keep translations, Tafsir, word meanings, and audio state in Quran mode; only the Quran body surface changes. Strict view events must still resolve back to the same ayah actions.

- [ ] **Step 7: Verify Quran/Hifz independence after switching**

Changing Quran to QCF V4 must not change Hifz font/size/layout. Changing Hifz to IndoPak must not change Quran mode.

- [ ] **Step 8: Run targeted tests**

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/features/settings/presentation/settings_page.dart lib/features/quran test/features/quran test/features/settings/application/app_preferences_controller_test.dart
git commit -m "feat: share Quran Foundation font choices across readers"
```

### Task 8: Finalize Hifz Pattern Controls, Compact Player, and Bangla Typography

**Files:**
- Modify: `lib/features/hifz/domain/hifz_preset.dart`
- Modify: `lib/features/hifz/presentation/hifz_pattern_controls.dart`
- Modify: `lib/features/hifz/presentation/hifz_active_player.dart`
- Modify: `lib/features/hifz/presentation/hifz_setup_sheet.dart`
- Create: `lib/features/hifz/presentation/hifz_typography.dart`
- Test: `test/features/hifz/application/hifz_sequence_builder_test.dart`
- Test: `test/features/hifz/presentation/hifz_pattern_controls_test.dart`
- Create/modify: `test/features/hifz/presentation/hifz_active_player_test.dart`
- Test: `test/features/hifz/presentation/hifz_page_test.dart`

**Interfaces:**
- Keeps: `HifzPreset.ayahRepeatCount`, `.combinedRepeatCount`, `.finalRangeRepeatCount`
- New-session default: `HifzPresets.progressive(ayahRepeatCount: 5, combinedRepeatCount: 3, finalRangeRepeatCount: 3)`
- Pattern selectors: each exact values `[1, 2, 3, 4, 5]`
- Active-player summary: `New 5× · Build 3× · Final 3×` (localized appropriately)
- Hifz audio request speed: always `1.0`

- [ ] **Step 1: Extend sequence tests across all stage counts**

For each stage value 1–5, assert only that stage's step repeat counts change. Pin default 1–3 sequence:

```text
1×5 → 2×5 → 1–2×3 → 3×5 → 1–3×3 → final 1–3×3
```

Assert no accumulated `1–1` step is inserted.

- [ ] **Step 2: Pin one-ayah behavior**

Pin the existing deterministic contract: a one-ayah progressive session with final review enabled plays the individual ayah step, then one explicit `HifzStepPhase.finalReview` range step for the same ayah. It must never create an accumulated `1–1` step. Example with defaults: `1×5 → final 1–1×3`.

- [ ] **Step 3: Write active-pattern mutation test**

While a step is running, change pattern settings in the sheet. Assert the current `HifzSessionConfig` and repeat index do not mutate mid-step; the new pattern is applied only when the user starts/restarts a sequence.

- [ ] **Step 4: Write Hifz speed test**

Assert Hifz playback requests always use `speed: 1.0` regardless of the normal Quran reader's saved playback speed.

- [ ] **Step 5: Write UI/font tests**

Assert:
- three labeled selectors are present;
- each contains 1×–5×;
- default selection is 5/3/3;
- Bangla titles/subtitles/pattern copy use `fontFamily: 'SolaimanLipi'`;
- English player chrome remains Inter/theme default;
- active player shows phase + repeat progress and compact pattern summary without a seekable fake timeline.

- [ ] **Step 6: Run targeted tests and verify failure**

Run:

```bash
flutter test test/features/hifz/application/hifz_sequence_builder_test.dart test/features/hifz/presentation/hifz_pattern_controls_test.dart test/features/hifz/presentation/hifz_active_player_test.dart test/features/hifz/presentation/hifz_page_test.dart
```

- [ ] **Step 7: Implement only the missing behavior/UI**

Reuse the existing three-field sequence model. Do not add another repeat engine.

- [ ] **Step 8: Run targeted tests**

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/features/hifz test/features/hifz
git commit -m "feat: polish progressive Hifz playback controls"
```

### Task 9: Full Regression, Asset Audit, Build, and Real-Device Verification

**Files:**
- Verification only; no planned product-code modifications.
- Test: existing full Flutter suite and Android integration smoke coverage.

If verification fails, return the defect to the owning earlier task and make a focused test-first fix there rather than patching opportunistically in this task.

**Interfaces:**
- Consumes all previous tasks.
- Produces no new public interface; this task is the shipping gate.

- [ ] **Step 1: Audit stale font and CDN references**

Run:

```bash
git grep -n -E "PDMS|AlQalam|Muhammadi|Noto Naskh Arabic|DigitalKhatt IndoPak|static-cdn\.tarteel\.ai/qul/fonts/quran_fonts|KFGQPC Hafs Uthmanic"
```

Expected: no product references except intentional migration-test strings/documentation history.

- [ ] **Step 2: Run formatting and static analysis**

Run:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
```

Expected: PASS with no new warnings/errors.

- [ ] **Step 3: Run the full Flutter test suite**

Run:

```bash
flutter test
```

Expected: PASS.

- [ ] **Step 4: Run Mushaf/content validation tools**

Run the existing Mushaf asset validation plus any new Quran Foundation QCF data validator from Task 4. Require:
- pages 1–604 present;
- page 440 transition structure correct;
- no missing word locations;
- no invalid page-font URL/version mapping.

- [ ] **Step 5: Build debug APK**

Run:

```bash
flutter build apk --debug
```

Expected: successful APK build.

- [ ] **Step 6: Install on the connected Android device**

Use the current ADB device and install the new debug APK. Do not uninstall first unless testing first-install behavior is explicitly required.

- [ ] **Step 7: Perform real-device visual checks**

Verify at minimum:
- Quran Settings and Hifz Settings show the same four font choices.
- Changing Quran font/size/spacing does not change Hifz.
- Changing Hifz font/size/spacing does not change Quran.
- QPC Hafs and IndoPak render at default, comfortable-large, and large sizes without horizontal overflow/diacritic collision.
- Page 440 keeps its logical page identity and Surah Ya-Sin transition while enlarged.
- QCF V2 and QCF V4 open the correct page and survive page turns.
- Disable network with an uncached QCF page: readable Unicode fallback appears, not a blank/broken page.
- Re-enable network/cache: strict QCF rendering recovers.
- Hifz player sequence for ayahs 1–3 with defaults is 5× / 3× / 3× as specified.
- Pattern sheet exposes 1×, 2×, 3×, 4×, 5× for all three stages.
- Hifz audio remains normal 1.0× speed.
- Bangla Hifz labels visibly use SolaimanLipi.
- Current word/ayah highlighting, hide/reveal, taps, and long-press still work.

- [ ] **Step 8: Run `git diff --check` and inspect scope**

Ensure no unrelated dirty files or deletions are staged.

- [ ] **Step 9: Commit any verification-only fixes separately**

Use a focused message such as:

```bash
git commit -m "fix: resolve adaptive Hifz regression"
```

Do not push, merge, or deploy without explicit approval.
