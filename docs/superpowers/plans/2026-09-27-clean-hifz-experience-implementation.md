# Clean Hifz Experience Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore a reliable Hifz subsystem and ship the approved Focused Mushaf experience, while keeping normal Quran reading independent from Hifz-only QCF V2/V4 rendering.

**Architecture:** Keep Quran content/assets and generic QCF rendering infrastructure under `features/quran`, but make Hifz the only product flow that chooses QCF Mushaf variants. Restore Hifz persistence and session logic as a dedicated `features/hifz` subsystem, add forward-only database migration from schema v12, then build a new Surah-first Hifz home/setup/reader UI rather than restoring the old Hifz presentation. Normal Quran remains adaptive Unicode and never routes through the strict QCF reader.

**Tech Stack:** Flutter/Dart, Riverpod, Drift/SQLite, `webview_flutter`, bundled Quran/QCF SQLite assets, Quran Foundation page fonts, Flutter widget/unit/integration tests.

**Spec:** `docs/superpowers/specs/2026-09-27-clean-hifz-experience-design.md`

## Global Constraints

- Work only on the GitHub feature branch; do not use Remote Desktop Commander.
- Preserve current Quran Foundation translation package support, Tafsir behavior, current Quran Surah/list behavior, and current QCF assets.
- Do not revert the repository to an old Hifz commit; historical Hifz code is behavioral reference only.
- The new Hifz UI must follow the approved **Focused Mushaf** direction, not the previous Hifz visual design.
- QCF V2 and QCF V4 Tajweed are Hifz Mushaf skins, not normal Quran font choices.
- Normal Quran preferences and Hifz appearance preferences must persist independently.
- Hifz font size must be user-controlled from **20–56** and must never be silently shrunk to preserve a printed-page fit.
- Hifz line height must be user-controlled from **1.20–2.40**.
- Default Hifz skin is **QCF V4 Tajweed**; default Hifz font size is **32**; default line height is **1.35**.
- Fresh databases and databases upgraded from schema v12 must contain all restored Hifz tables without deleting Tafsir/translation data.
- Raw SQLite/Drift exceptions must never be shown directly in Hifz UI.
- Follow TDD: failing test first, verify the expected failure, minimal implementation, then full relevant regression suite.
- Because development is GitHub-only, use repository CI/GitHub Actions as the execution evidence for `flutter test`, `flutter analyze`, and the Android debug build. If no Flutter CI workflow exists, Task 1 adds one as test infrastructure.

## Review Focus

1. **v12 upgrade with current translation data:** migration must recreate Hifz tables and preserve installed translation/Tafsir rows — covered in Task 2 migration tests.
2. **Legacy global QCF preference:** an existing `quran_font=qcfV2` or `qcfV4Tajweed` value must normalize to the normal Quran default without corrupting the new Hifz skin setting — covered in Task 3 repository tests.
3. **Narrow phone + 56px Hifz text:** QCF text must remain requested size, wrap/consume vertical space, and scroll rather than overflow horizontally or shrink — covered in Task 5 renderer/widget tests.
4. **Missing/unavailable QCF skin asset or page font:** Hifz must show a readable retry/fallback state while normal Quran remains unaffected — covered in Task 5 reader tests.
5. **Surah start defaults with/without progress:** no progress starts at ayah 1; reliable progress starts at the next unfinished ayah while keeping a valid same-Surah end range — covered in Task 6 flow tests.

---

### Task 1: Add GitHub-only Flutter verification harness

**Files:**
- Create: `.github/workflows/hifz-repair-ci.yml`

**Interfaces:**
- Consumes: repository `pubspec.yaml`, Flutter test/analyze/build commands.
- Produces: branch/PR CI that runs `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build apk --debug`.

- [ ] **Step 1: Add the CI workflow**

Pin a stable Flutter channel/version compatible with the repository, cache pub packages, then run:
`flutter pub get` → `flutter analyze` → `flutter test` → `flutter build apk --debug`.

- [ ] **Step 2: Push only the workflow change and verify the workflow starts**

Expected: the workflow is visible on the feature branch and reaches the existing baseline tests. Record any pre-existing failure before product changes.

- [ ] **Step 3: Commit**

Commit message: `ci: add Flutter verification for Hifz repair`.

---

### Task 2: Restore Hifz persistence with a forward v13 migration

**Files:**
- Modify: `lib/core/database/user_database.dart` — restore Hifz tables/indexes; bump schema 12 → 13; add forward migration.
- Regenerate: `lib/core/database/user_database.g.dart`.
- Create: `lib/features/hifz/domain/hifz_plan.dart`
- Create: `lib/features/hifz/domain/hifz_preset.dart`
- Create: `lib/features/hifz/domain/hifz_progress.dart`
- Create: `lib/features/hifz/domain/hifz_repository.dart`
- Create: `lib/features/hifz/domain/hifz_session.dart`
- Create: `lib/features/hifz/data/drift_hifz_plan_repository.dart`
- Create: `lib/features/hifz/data/drift_hifz_repository.dart`
- Modify: `test/core/database/user_database_migration_test.dart`
- Create: `test/features/hifz/data/drift_hifz_plan_repository_test.dart`
- Create: `test/features/hifz/data/drift_hifz_repository_test.dart`
- Delete: `test/architecture/hifz_feature_removal_test.dart`

**Interfaces:**
- Produces `HifzPlanRepository.watchPlans(String)`, `createPlan(...)`, `deletePlan(int)`.
- Produces `HifzRepository.loadProgress(...)`, `saveProgress(...)`, `markRangeLearning(...)`, checkpoint persistence.
- Produces restored Drift tables: `HifzProgressEntries`, `HifzReviewHistoryRows`, `HifzSessionCheckpoints`, `HifzPlans`, `ReadingPageVisits`, `DailyGoals`.

- [ ] **Step 1: Write failing migration tests**

Add tests asserting:
- fresh DB exposes all six restored tables;
- a v12 DB containing one installed translation package, one installed Tafsir package, and a sentinel setting upgrades to v13 with those rows preserved;
- the same v12 upgrade can insert into `hifz_plans` immediately after open;
- an unusual dev DB where a Hifz table already exists does not fail the v13 upgrade.

- [ ] **Step 2: Run the migration tests in CI and verify RED**

Expected: failure because schema 12 has no Hifz tables / v13 migration.

- [ ] **Step 3: Restore table definitions and implement schema v13**

Restore the old table shapes and indexes, but replace the old deletion behavior with a forward v13 `CREATE TABLE/INDEX IF NOT EXISTS` path. Keep installed translation package tables untouched.

- [ ] **Step 4: Regenerate Drift code and verify migration tests GREEN**

Expected: migration tests pass and generated schema contains restored Hifz accessors.

- [ ] **Step 5: Write repository tests first**

Test plan create/watch/delete ordering, invalid cross-Surah ranges, progress upsert, range-marking, and checkpoint round-trip.

- [ ] **Step 6: Restore/adapt Hifz domain + Drift repositories**

Use the pre-removal Hifz repository behavior as reference, but compile against current database and Quran types.

- [ ] **Step 7: Run targeted and database regression tests**

Run:
`flutter test test/core/database/user_database_migration_test.dart test/features/hifz/data/`

Expected: PASS.

- [ ] **Step 8: Commit**

Commit message: `fix: restore Hifz persistence safely`.

---

### Task 3: Separate normal Quran fonts from Hifz QCF skins

**Files:**
- Modify: `lib/features/quran/domain/quran_font_preference.dart`
- Modify: `lib/features/quran/domain/quran_mushaf_variant.dart`
- Modify: `lib/features/quran/data/quran_foundation_page_font_repository.dart`
- Modify: `lib/features/quran/application/quran_mushaf_providers.dart`
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Modify: `lib/features/settings/domain/app_preferences.dart`
- Modify: `lib/features/settings/data/user_database_app_preferences_repository.dart`
- Modify: `lib/features/settings/application/app_preferences_controller.dart`
- Modify: `lib/features/settings/presentation/settings_page.dart`
- Modify: `test/features/quran/domain/quran_font_preference_test.dart`
- Modify: `test/features/quran/presentation/quran_reader_page_test.dart`
- Modify: `test/features/settings/domain/app_preferences_test.dart`
- Modify: `test/features/settings/data/user_database_app_preferences_repository_test.dart`
- Modify: `test/features/settings/application/app_preferences_controller_test.dart`

**Interfaces:**
- `QuranFontPreference.values` becomes only `qpcHafs` and `indoPak`.
- `QuranMushafVariant` becomes independent of `QuranFontPreference` and owns QCF V2/V4 labels + Mushaf IDs.
- `QuranFoundationPageFontRepository` accepts `QuranMushafVariant variant`, not a normal Quran font.
- `AppPreferences` adds `hifzMushafVariant`, `hifzFontSize`, `hifzLineHeight`, `hifzShowTajweedColors`.
- Controller adds `setHifzMushafVariant`, `setHifzFontSize`, `setHifzLineHeight`, `setHifzShowTajweedColors` and corresponding providers.

- [ ] **Step 1: Write failing isolation tests**

Assert:
- normal Quran font catalog contains only QPC Hafs and IndoPak;
- Settings normal Quran font dropdown has no QCF V2/V4 entries;
- normal Quran reader never creates `QuranStrictMushafSurface`;
- Hifz preferences default to QCF V4 / 32 / 1.35 / Tajweed enabled;
- changing Hifz skin does not change `quranFont`;
- changing normal Quran font does not change Hifz skin;
- legacy persisted `quran_font=qcfV2` and `qcfV4Tajweed` load as `qpcHafs`, while an explicit `hifz_mushaf_variant` still loads independently.

- [ ] **Step 2: Run targeted tests and verify RED**

Expected: failures from the current four-item Quran font enum and strict-reader branch.

- [ ] **Step 3: Decouple QCF variant/font infrastructure**

Make page-font URL/cache selection variant-based. Keep QCF repositories/assets reusable by Hifz.

- [ ] **Step 4: Remove the strict branch from normal Quran reader**

Delete the `quranFont.isStrict` rendering decision and strict-reader-only callbacks from the normal Quran page. Keep the current adaptive Quran reader behavior and page anchor behavior.

- [ ] **Step 5: Add/persist independent Hifz appearance preferences**

Use keys:
- `hifz_mushaf_variant_v2`
- `hifz_font_size_v2`
- `hifz_line_height_v2`
- `hifz_tajweed_colors_v2`

Validate ranges on load and setter calls.

- [ ] **Step 6: Run targeted tests GREEN**

Run:
`flutter test test/features/quran/domain/quran_font_preference_test.dart test/features/quran/presentation/quran_reader_page_test.dart test/features/settings/`

Expected: PASS.

- [ ] **Step 7: Commit**

Commit message: `fix: isolate Hifz Mushaf appearance from Quran`.

---

### Task 4: Restore the Hifz memorization engine without old presentation code

**Files:**
- Create: `lib/features/hifz/domain/hifz_audio_port.dart`
- Create: `lib/features/hifz/domain/hifz_step.dart`
- Create: `lib/features/hifz/domain/memorization_result.dart`
- Create: `lib/features/hifz/application/hifz_sequence_builder.dart`
- Create: `lib/features/hifz/application/hifz_session_controller.dart`
- Create: `lib/features/hifz/application/progressive_hide_generator.dart`
- Create: `lib/features/hifz/data/quran_audio_hifz_port.dart`
- Create: `lib/features/hifz/application/hifz_plan_providers.dart`
- Create: `test/features/hifz/application/hifz_sequence_builder_test.dart`
- Create: `test/features/hifz/application/hifz_session_controller_test.dart`
- Create: `test/features/hifz/application/progressive_hide_generator_test.dart`
- Create: `test/features/hifz/data/quran_audio_hifz_port_test.dart`

**Interfaces:**
- Consumes Task 2 `HifzRepository` + `HifzPlanRepository`.
- Produces `HifzSessionController.start(HifzSessionConfig)`, pause/resume/stop, current step/repetition state, and audio bridge.
- Produces Riverpod providers for plan repository, plan stream, progress repository, and session controller.

- [ ] **Step 1: Restore the old engine tests as failing behavioral specifications**

Keep tests for repeat counts, combined range progression, pause/resume, stop, checkpoint resume, audio completion, and progressive hide generation. Remove tests that assert old visual modes.

- [ ] **Step 2: Verify RED**

Expected: missing Hifz engine classes/providers.

- [ ] **Step 3: Restore/adapt engine code**

Bring back only behavior needed by the approved flow. Do not restore `HifzReadingMode`, old layout-mode switching, old planner UI, or old appearance UI.

- [ ] **Step 4: Verify targeted engine tests GREEN**

Run:
`flutter test test/features/hifz/application/ test/features/hifz/data/quran_audio_hifz_port_test.dart`

- [ ] **Step 5: Commit**

Commit message: `feat: restore Hifz memorization engine`.

---

### Task 5: Make the QCF renderer genuinely resizable for Hifz

**Files:**
- Modify: `lib/features/quran/presentation/mushaf/mushaf_webview_driver.dart`
- Modify: `lib/features/quran/presentation/mushaf/quran_strict_mushaf_surface.dart`
- Modify: `assets/mushaf/renderer/mushaf.js`
- Modify: `assets/mushaf/renderer/mushaf.css`
- Modify: `test/features/quran/presentation/mushaf/mushaf_webview_driver_test.dart`
- Modify: `test/features/quran/presentation/quran_strict_mushaf_surface_test.dart`
- Create: `test/assets/hifz_mushaf_responsive_css_test.dart`

**Interfaces:**
- `MushafRenderPayload` adds `fontSize`, `lineHeight`, and `showTajweedColors`.
- `MushafWebViewDriver` adds `setTypography({required double fontSize, required double lineHeight, required bool showTajweedColors})`.
- `QuranStrictMushafSurface` requires Hifz typography values and updates the live renderer without replacing the normal Quran preference.

- [ ] **Step 1: Write failing payload/driver tests**

Assert renderer JSON includes exact typography values and driver emits a safe encoded `setTypography` call.

- [ ] **Step 2: Write failing responsive CSS/renderer tests**

Assert:
- Hifz page/root can scroll vertically;
- ayah lines can wrap when necessary;
- font size comes from an explicit CSS custom property rather than `clamp(...vw...)`;
- there is no shrink-to-fit transform;
- Tajweed-off uses a monochrome-on-light palette while QCF V2 remains readable.

- [ ] **Step 3: Verify RED**

Expected: current fixed 15-row renderer uses viewport-clamped font sizes and hidden overflow.

- [ ] **Step 4: Add live typography contract**

JS stores typography state, validates 20–56 / 1.20–2.40, applies CSS variables, and updates Tajweed mode. Dart driver exposes the same validated contract.

- [ ] **Step 5: Convert the renderer from fixed shrink/fill behavior to Hifz-readable flow**

At normal sizes preserve canonical line order and centering; at larger sizes allow tokens/lines to wrap and increase vertical page height. Keep Surah header, Bismillah, ayah markers, selection, active ayah, and active word semantics intact.

- [ ] **Step 6: Add surface update tests**

Pump at 24 then 48/56 and assert the typography call changes while page/range identity remains unchanged; test a font-load failure reaches the readable fallback + retry state.

- [ ] **Step 7: Run renderer tests GREEN**

Run:
`flutter test test/features/quran/presentation/mushaf/ test/features/quran/presentation/quran_strict_mushaf_surface_test.dart test/assets/hifz_mushaf_responsive_css_test.dart`

- [ ] **Step 8: Commit**

Commit message: `feat: make Hifz QCF Mushaf typography responsive`.

---

### Task 6: Build the new Focused Mushaf Hifz reader

**Files:**
- Create: `lib/features/hifz/presentation/hifz_reader_page.dart`
- Create: `lib/features/hifz/presentation/hifz_appearance_sheet.dart`
- Create: `lib/features/hifz/presentation/hifz_controls_bar.dart`
- Create: `test/features/hifz/presentation/hifz_reader_page_test.dart`
- Create: `test/features/hifz/presentation/hifz_appearance_sheet_test.dart`
- Create: `test/features/hifz/presentation/hifz_controls_bar_test.dart`

**Interfaces:**
- `HifzReaderPage({required HifzSessionConfig config, required int initialPage, required String planTitle})`.
- Consumes Task 3 Hifz appearance providers, Task 4 session controller, Task 5 strict QCF surface.
- Appearance sheet edits only Hifz skin/font size/line height/Tajweed.
- Bottom bar owns play/pause, repeat/pattern access, hide/reveal, and finish/stop actions.

- [ ] **Step 1: Write reader shell tests**

Assert compact top chrome, Quran surface occupying the main viewport, one compact bottom control region, no normal Quran translation/bookmark toolbar, and no old `Audio & Hifz`/reading-mode selector UI.

- [ ] **Step 2: Write appearance tests**

Assert QCF V2/V4 are the only skin choices; slider range is 20–56; changing size updates Hifz surface live and persists; reset returns V4/32/1.35; normal Quran preference remains unchanged.

- [ ] **Step 3: Write range/playback/fallback tests**

Assert selected start/end range is passed to the QCF surface; active playback highlighting is forwarded; unavailable QCF font/page shows compact readable fallback + retry without leaving Hifz.

- [ ] **Step 4: Verify RED**

Expected: new Hifz reader widgets do not exist.

- [ ] **Step 5: Implement Focused Mushaf reader**

Use current Quran page data/repositories for page loading and old Hifz audio/session behavior for memorization. Keep advanced controls in sheets.

- [ ] **Step 6: Verify widget tests GREEN**

Run:
`flutter test test/features/hifz/presentation/hifz_reader_page_test.dart test/features/hifz/presentation/hifz_appearance_sheet_test.dart test/features/hifz/presentation/hifz_controls_bar_test.dart`

- [ ] **Step 7: Commit**

Commit message: `feat: add focused Hifz Mushaf reader`.

---

### Task 7: Build Surah-first Hifz home, search, setup, and saved plans

**Files:**
- Create: `lib/features/hifz/presentation/hifz_home_page.dart`
- Create: `lib/features/hifz/presentation/hifz_surah_picker_sheet.dart`
- Create: `lib/features/hifz/presentation/hifz_setup_sheet.dart`
- Create: `lib/features/hifz/application/hifz_start_defaults.dart`
- Modify: `lib/features/home/presentation/more_page.dart`
- Modify: `test/app/quran_hifz_shell_test.dart`
- Create: `test/features/hifz/application/hifz_start_defaults_test.dart`
- Create: `test/features/hifz/presentation/hifz_home_page_test.dart`
- Create: `test/features/hifz/presentation/hifz_surah_picker_sheet_test.dart`
- Create: `test/features/hifz/presentation/hifz_setup_sheet_test.dart`

**Interfaces:**
- `HifzStartDefaults.forSurah({required QuranSurahSummary surah, required List<HifzProgress> progress}) -> HifzStartRange`.
- `HifzHomePage` opens `HifzSurahPickerSheet`, then `HifzSetupSheet`, creates/resumes a plan, then pushes `HifzReaderPage`.
- Saved-plan row tap reconstructs `HifzSessionConfig` and resumes the correct Surah/range.

- [ ] **Step 1: Write start-default tests**

Assert no progress → ayah 1; completed/learning progress → next unfinished ayah where determinable; end ayah is never below start or beyond Surah ayah count.

- [ ] **Step 2: Write Surah search tests**

Search by Surah number, English/Bangla name, and show Arabic name + ayah count. Empty query shows all Surahs.

- [ ] **Step 3: Write Hifz home state tests**

Assert:
- first primary action is `সূরা থেকে হিফজ শুরু করুন` / localized English equivalent;
- empty state is compact and has no retry button;
- repository load error shows inline retry while Surah-start remains usable;
- saved plans are compact rows, not large cards/FABs;
- raw repository/SQLite exception text is not rendered.

- [ ] **Step 4: Write full Surah → setup → plan → reader widget test**

Select Al-Fatihah, choose range, tap `হিফজ শুরু করুন`, assert plan is saved and reader receives correct config/page.

- [ ] **Step 5: Verify RED**

Expected: new home/picker/setup components are absent.

- [ ] **Step 6: Implement the new entry flow**

Use restrained light surfaces/dividers, existing app blue/teal only for active/primary action, 44px+ practical tap targets, and bottom-sheet-safe insets.

- [ ] **Step 7: Restore Hifz entry in More**

Add a localized Hifz tile that opens `HifzHomePage`; update shell test to expect Hifz again.

- [ ] **Step 8: Run targeted tests GREEN**

Run:
`flutter test test/features/hifz/application/hifz_start_defaults_test.dart test/features/hifz/presentation/ test/app/quran_hifz_shell_test.dart`

- [ ] **Step 9: Commit**

Commit message: `feat: add Surah-first Hifz planning flow`.

---

### Task 8: Restore progress/revision support required by the Hifz workflow

**Files:**
- Restore/adapt: `lib/features/progress/domain/progress_summary.dart`
- Restore/adapt: `lib/features/progress/domain/progress_repository.dart`
- Restore/adapt: `lib/features/progress/data/drift_progress_repository.dart`
- Restore/adapt: `lib/features/progress/application/progress_controller.dart`
- Restore/adapt: `lib/features/revision/domain/revision_item.dart`
- Restore/adapt: `lib/features/revision/domain/revision_policy.dart`
- Restore/adapt: `lib/features/revision/domain/revision_repository.dart`
- Restore/adapt: `lib/features/revision/data/drift_revision_repository.dart`
- Restore/adapt: `lib/features/revision/application/revision_scheduler.dart`
- Restore/adapt: `lib/features/revision/application/todays_revision_controller.dart`
- Restore/adapt tests under: `test/features/progress/`, `test/features/revision/`

**Interfaces:**
- Consumes restored Task 2 Hifz progress/review tables.
- Produces progress summaries and due-revision scheduling used by saved-plan progress/status and future Hifz progress surfaces.
- No old dashboard/presentation is restored in this task.

- [ ] **Step 1: Restore behavioral tests first**

Cover progress aggregation, daily goal counts, revision due ordering, result application, and review-history persistence.

- [ ] **Step 2: Verify RED**

Expected: progress/revision modules are absent.

- [ ] **Step 3: Restore/adapt only domain/data/application layers**

Do not restore the old progress/revision page designs.

- [ ] **Step 4: Run targeted tests GREEN**

Run:
`flutter test test/features/progress/ test/features/revision/`

- [ ] **Step 5: Commit**

Commit message: `feat: restore Hifz progress and revision services`.

---

### Task 9: End-to-end regression, visual lock, and integration cleanup

**Files:**
- Create/adapt: `integration_test/reader_hifz_smoke_test.dart`
- Modify as needed: `integration_test/app_navigation_test.dart`
- Modify only if tests prove necessary: current Quran/translation tests.
- Update: `docs/superpowers/specs/2026-09-27-clean-hifz-experience-design.md` status to implemented after verification.

**Interfaces:**
- Consumes every prior task.
- Produces final branch-level proof that Hifz works without regressing normal Quran/translation behavior.

- [ ] **Step 1: Add integration regression for the reported failure path**

Automate: More → Hifz → Surah selection → setup → save plan → reader → change Hifz size → switch QCF V2/V4 → back to normal Quran. Assert normal Quran remains adaptive and Hifz plan reopens.

- [ ] **Step 2: Add regression for translation preservation**

Exercise installed translation selection/loading after the database migration/Hifz flow.

- [ ] **Step 3: Run the complete GitHub CI suite**

Required successful jobs:
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

Report every failing test by name; do not claim completion with a red job.

- [ ] **Step 4: Perform visual QA against the approved Focused Mushaf lock**

Capture/check at a representative Android phone viewport:
- Hifz empty state;
- Surah picker;
- setup sheet;
- Hifz reader at 32px;
- Hifz reader at 56px;
- QCF V2 and QCF V4.

Reject P0/P1/P2 drift: oversized empty areas, card-heavy layout, large floating actions, raw errors, clipped 56px Quran text, or normal Quran showing Hifz QCF skin.

- [ ] **Step 5: Run `git diff --check` equivalent in CI and request code review**

Use `superpowers:requesting-code-review` before merge.

- [ ] **Step 6: Commit any verification-only fixes**

Commit message: `test: cover restored Hifz experience`.

- [ ] **Step 7: Finish branch**

Use `superpowers:verification-before-completion`, then `superpowers:finishing-a-development-branch`. Merge only after branch CI and review are clean.
