# Clean Hifz Experience Design

**Date:** 2026-09-27
**Status:** Implemented
**Repository:** `shuvodelux-commits/Quran-Hifz`
**Working branch:** `fix/restore-hifz-skin`

## 1. Goal

Rebuild the Hifz experience as a dedicated, clean memorization workspace without restoring the old visual design.

The previous Hifz implementation is a **behavioral reference only** for proven workflows such as saved plans, range selection, repetition, audio, progress, persistence, and Hifz-specific preferences. The UI must be redesigned around a cleaner **Focused Mushaf** direction.

The normal Quran reader and the Hifz reader must be clearly separated. Hifz-only Mushaf choices such as QCF V2 and QCF V4 must not change the normal Quran reading experience.

## 2. Current Regressions to Repair

The latest development introduced three connected regressions:

1. The Hifz planner cannot save a plan because the database no longer contains `hifz_plans`.
2. The recent cleanup removed the Hifz feature implementation, preferences, progress/session code, and Hifz database structures.
3. QCF V2 / QCF V4 are currently exposed as global Quran fonts. Selecting them switches the normal Quran reader into the strict Mushaf rendering path. That strict page-oriented rendering belongs to the Hifz experience, not the normal Quran reading screen.

These are treated as root-cause architectural regressions, not isolated visual bugs.

## 3. Product Direction: Focused Mushaf

The new Hifz experience should feel like a dedicated Quran memorization tool rather than a settings-heavy planner.

### Design principles

- Quran content is the visual focus.
- Light mode remains the primary presentation.
- Use the app's existing blue/teal primary color sparingly for active state and primary action.
- Avoid large floating controls, excessive cards, heavy shadows, decorative gradients, and unused empty space.
- Use dividers, sections, compact rows, and bottom sheets instead of wrapping every section in a card.
- Keep touch targets at least 44 logical pixels where practical.
- Bangla UI copy should remain compact and readable.
- Quran typography is controlled independently from app UI typography.
- Hifz controls should disappear or collapse while reading so the Mushaf gets maximum screen area.

## 4. Hifz Entry Screen

The Hifz entry screen replaces the current mostly empty planner screen.

### App bar

- Back action.
- Centered title: `হিফজ` / `Hifz`.
- Optional compact history/progress action on the right only when useful.

### Primary action area

The first meaningful control is:

`সূরা থেকে হিফজ শুরু করুন`

It opens a searchable Surah selector.

The user should not need to create an abstract plan before seeing Quran content.

### Surah selection

The Surah selector must support:

- Search by Surah number.
- Search by Bangla/English transliterated name where available.
- Arabic Surah name display.
- Ayah count.
- Existing Hifz progress indicator when progress exists.

After choosing a Surah, open the Hifz setup/range sheet rather than the normal Quran reader.

### Saved plans

Existing plans appear below the primary action as compact rows.

Each row shows only useful information:

- Plan title or Surah name.
- Selected ayah range.
- Progress/status.
- Last activity or continuation hint when available.

Tap continues the Hifz plan.

Secondary actions such as rename/delete belong in an overflow menu or long-press sheet, not permanent buttons.

### Empty state

When there are no saved plans:

- Do not show a large blank screen.
- Do not show a centered `Retry plans` button unless a real load error occurred.
- Show a small explanatory empty state beneath the primary Surah action.

A real database/network error may show a compact inline retry row with the actual localized error state.

## 5. Start-Hifz Setup Flow

After selecting a Surah, open a bottom sheet.

The sheet contains:

- Selected Surah.
- Start ayah.
- End ayah.
- Memorization/repetition preset.
- Primary action: `হিফজ শুরু করুন`.

Defaults should minimize work:

- Start ayah defaults to ayah 1 or the next unfinished ayah when reliable progress exists.
- End ayah may default to a small practical range based on the existing preset behavior.
- User can change both before starting.

Saving/starting creates or resumes a persisted Hifz plan.

The same Surah selection flow should be reusable when changing the active Hifz Surah from inside the reader.

## 6. Dedicated Hifz Reader

The Hifz reader is a separate presentation surface from the normal Quran reader.

### Top bar

Keep it compact:

- Back.
- Surah name.
- Current page / selected range progress as secondary text where useful.
- Appearance/settings action.

Do not reproduce the normal Quran reader's translation/bookmark/settings toolbar unless a Hifz interaction explicitly needs it.

### Quran surface

The Quran occupies the majority of the viewport.

Supported Hifz Mushaf skins:

- QCF V2 Madani.
- QCF V4 Tajweed.

The Hifz skin must support:

- Current Surah/page navigation.
- Correct Surah header/Bismillah behavior.
- Ayah markers.
- Selection of start/end ayah.
- Active playback highlighting.
- Word interactions required by existing audio/study behavior.
- Light/background presentation consistent with the app.
- Continuous or vertically scrollable reading where the selected size makes a fixed viewport impractical.

### Bottom controls

Use one compact control region.

Primary functions:

- Play/pause.
- Repeat pattern.
- Hide/reveal memorization mode.
- Start/finish current memorization sequence.

Advanced controls belong in sheets, not permanently occupying reader height.

## 7. Hifz Appearance

Hifz owns separate appearance preferences.

The Hifz appearance sheet must include:

- Mushaf skin: QCF V2 / QCF V4 Tajweed.
- Quran font size.
- Line spacing where technically applicable.
- Tajweed color behavior for QCF V4 where supported.
- Reset to Hifz defaults.

### Resizable Quran text

Font-size changes must visibly change the Hifz Quran text.

The implementation must not silently clamp the user back to a fixed visual size merely to preserve a printed-page fit.

When the selected size no longer fits the original line width:

- Preserve the Quran token order.
- Preserve ayah boundaries and Surah/Bismillah structure.
- Allow additional vertical space / wrapping / scrolling as needed.
- Never shrink the requested size behind the user's back.

The goal is readable Hifz text, not pixel-perfect printed-page dimensions.

## 8. Isolation From Normal Quran Reader

This is a hard product boundary.

### Normal Quran reader

The normal Quran reader keeps its normal adaptive reading layout and its existing translation/tafsir/audio interactions.

Global Quran font choices must not route the normal Quran screen into the Hifz strict Mushaf skin.

QCF V2 and QCF V4 are removed from the **normal Quran font selector** and exposed under **Hifz appearance** instead.

The normal Quran font preference remains independent from Hifz.

### Hifz reader

Hifz owns:

- Hifz Mushaf skin.
- Hifz font size.
- Hifz line spacing.
- Hifz reading controls.
- Hifz selected Surah/range.

Changing Hifz appearance must not mutate the normal Quran reader's font/layout preference.

## 9. Data Model Restoration

Restore Hifz persistence without rolling back newer Quran/translation work.

Required persisted concepts:

- Hifz plans.
- Hifz progress.
- Review history.
- Session checkpoint.
- Reading/revision progress data required by the existing Hifz workflow.

Create a **new forward migration** from the current schema rather than reverting the database version.

The migration must safely recreate missing Hifz tables/indexes when upgrading an app that passed through the removal migration.

Requirements:

- Fresh installs contain all required Hifz tables.
- Existing installs upgraded from the current schema recreate Hifz tables.
- Existing unrelated data, including installed Tafsir and translation packages, remains untouched.
- Migration is idempotent at the schema level and must not fail if a Hifz table already exists in an unusual development database.
- No migration should delete current Quran translation package data.

## 10. Preserve Newer Quran/Translation Development

This repair must not revert the current translation work introduced after the old Hifz implementation.

Preserve:

- Quran Foundation translation backend/client support.
- Installed translation package data.
- Bangla/English translation source selection.
- Current Tafsir work.
- Current Quran Surah/list improvements that are unrelated to Hifz.
- Current font assets and QCF V2/V4 Mushaf assets.

Old Hifz files may be used as behavioral references, but implementation must be reconciled with the current repository instead of copying an old commit wholesale.

## 11. Error Handling

### Hifz plan load failure

Show a compact inline error with retry.

Do not leave the rest of the page empty when Surah selection can still function.

### Hifz plan save failure

Show a user-readable localized message.

The raw Drift/SQLite exception must not be dumped into the primary UI as in the current screenshot.

Diagnostic details may remain in logs/debug output.

### Mushaf page/font failure

Provide a retry path and, where safe, fall back to the other installed Hifz skin or a readable Hifz text surface without changing the normal Quran preference.

## 12. Accessibility and Mobile Interaction

- Minimum practical 44px touch targets.
- Icon-only controls require semantic labels/tooltips.
- Bottom sheets must remain usable with large system text.
- Surah search should use the correct keyboard behavior and remain usable without hardware keyboard.
- Controls must not overlap Android system navigation.
- Quran size controls must work across typical phone widths.
- Hifz reader should preserve scroll position when opening/closing appearance controls.

## 13. Visual Reference Lock

**Primary direction:** Focused Mushaf.

**Preserve:**

- Light canvas.
- Compact top chrome.
- Quran-first screen composition.
- Restrained blue/teal accent.
- Dense but readable controls.
- Minimal borders/shadows.
- Strong distinction between Hifz UI and normal Quran UI.

**Borrow only from previous Hifz implementation:**

- Working workflow logic.
- Saved-plan behavior.
- Range/repetition/session behavior.
- Progress persistence.
- Audio interactions.

**Reject:**

- Previous Hifz visual styling as a target.
- Large empty planner canvas.
- Large floating add-plan button.
- Oversized retry button as normal empty state.
- Card-heavy dashboard layout.
- Global QCF font choice changing normal Quran layout.
- Fixed Hifz font size.
- Raw SQLite errors presented to users.

## 14. Acceptance Criteria

The repair is complete only when all of the following are true:

1. Opening Hifz shows the new Focused Mushaf entry design, not the previous Hifz UI.
2. A user can select a Surah and start a Hifz range.
3. A Hifz plan can be created and reopened without `no such table: hifz_plans`.
4. Existing installs receive the missing Hifz tables through a forward migration.
5. QCF V2 and QCF V4 are Hifz appearance choices and no longer switch the normal Quran reader into the Hifz strict layout.
6. Normal Quran font/layout preferences remain independent from Hifz preferences.
7. Hifz QCF V2 and QCF V4 both render Quran content correctly.
8. The Hifz font-size control produces a visible size change at multiple values.
9. Large Hifz text is allowed to consume more vertical space rather than being silently reduced.
10. Surah headers, Bismillah rules, ayah markers, audio highlighting, and selected range remain correct after resizing.
11. Saved Hifz plans appear as compact rows and can resume the correct Surah/range.
12. Empty Hifz state contains a clear Surah-start action and no meaningless retry button.
13. Raw SQLite exceptions are not displayed directly to end users.
14. Current translation/Tafsir functionality remains intact.
15. Automated regression tests cover database migration, plan creation, Quran/Hifz preference isolation, Surah-to-Hifz navigation, QCF skin selection, and Hifz font resizing.

## 15. Testing Strategy

Implementation will follow TDD.

Required regression categories:

- Database migration from current schema to restored Hifz schema.
- Fresh database creation with Hifz tables.
- Hifz plan repository create/watch/delete.
- Hifz entry empty/error/loaded states.
- Surah selector -> setup sheet -> Hifz reader navigation.
- Normal Quran font selector excludes Hifz-only QCF skins.
- Changing Hifz QCF skin leaves normal Quran preferences unchanged.
- Hifz font-size slider persists and visibly changes rendered Quran text.
- Large-size rendering does not use a shrink-to-fit path.
- QCF V2 and QCF V4 Hifz rendering smoke tests.
- Preservation of installed translation package behavior.

## 16. Non-Goals

This repair does not redesign the entire Quran application.

It does not:

- Replace the current normal Quran Surah list.
- Redesign Tafsir.
- Redesign audio/reciter management globally.
- Introduce cloud Hifz synchronization.
- Add social/gamification features.
- Revert the repository to an older Hifz commit.
