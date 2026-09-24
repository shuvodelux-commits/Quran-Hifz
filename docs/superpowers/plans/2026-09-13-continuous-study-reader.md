# Continuous Study Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the Quran tab from page-by-page navigation into a continuous Study reader with incremental page loading, stable audio-follow scrolling, active-ayah highlighting, and lazy inline tafsir.

**Architecture:** Keep `ReaderController` as the source of Quran page windows and add append/prepend operations that do not change the selected navigation target. `QuranReaderPage` owns the scroll controller and pagination thresholds, while each `ReaderWindow` remains responsible for scrolling its active ayah into view. `AyahCard` adds a lazy `InlineTafsirPanel` and consumes an ayah-specific audio-active provider for visual highlighting.

**Tech Stack:** Flutter, Riverpod, existing Drift Quran repository, existing local tafsir repository, existing `QuranAudioController`.

**Spec:** `docs/superpowers/specs/2026-09-13-continuous-study-reader-design.md`

## Global Constraints

- Keep one shared Quran audio controller; do not introduce another player.
- Word-tap playback must not trigger reader auto-scroll.
- Do not alter Hifz session behavior in this change.
- Inline tafsir must prefer `primaryBanglaTafsirSourceId` when installed.
- Page metadata can remain visible only as lightweight orientation, not page-screen navigation.

---

### Task 1: Incremental reader windows

**Files:**
- Modify: `lib/features/quran/application/reader_controller.dart`
- Test: `test/features/quran/application/reader_controller_test.dart`

**Interfaces:**
- Produces: `Future<void> loadNextWindow()` and `Future<void> loadPreviousWindow()`.
- Both methods append/prepend exactly one missing page window and leave `ReaderState.currentPage` unchanged.

- [ ] Write controller tests proving next/previous window loading extends `loadedPages` without changing `currentPage`.
- [ ] Run the focused controller test and verify it fails because the methods do not exist.
- [ ] Implement the two methods using `quranRepositoryProvider` and the current `translationResourceId`.
- [ ] Run the controller test and verify it passes.

### Task 2: Continuous Quran scroll

**Files:**
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Modify: `test/features/quran/presentation/quran_reader_page_test.dart`

**Interfaces:**
- Consumes: `ReaderState.loadedPages`, `ReaderController.loadNextWindow()`, and `ReaderController.loadPreviousWindow()`.
- Produces: a single `CustomScrollView` rendering all loaded windows in sorted order.

- [ ] Update widget tests to assert `Quran · Read`, absence of page navigation buttons, and presence of consecutive page boundary labels.
- [ ] Add a search regression asserting the selected result exposes `Page 42` in the continuous reader.
- [ ] Replace `_PageControls` with a stateful scroll reader using one `ScrollController`.
- [ ] Trigger `loadNextWindow()` near the bottom and `loadPreviousWindow()` near the top.
- [ ] Preserve viewport position after prepending by adjusting the scroll offset by the max-scroll-extent delta.
- [ ] Add keyed page boundary slivers and scroll to `currentPage` after an explicit page open/search result.

### Task 3: Stable active-ayah highlighting

**Files:**
- Modify: `lib/features/audio/application/audio_providers.dart`
- Modify: `lib/features/quran/presentation/widgets/ayah_card.dart`
- Test: `test/features/quran/presentation/active_word_highlight_test.dart`

**Interfaces:**
- Produces: `isAyahPlaybackActiveProvider(String ayahKey) -> bool`.

- [ ] Add a provider-isolation test showing only the old/new ayah active booleans change when playback advances.
- [ ] Implement the family provider by selecting `QuranAudioMode.ayah` and matching `ayahKey`.
- [ ] Add an active card border/container treatment in `AyahCard` without changing word-highlight behavior.

### Task 4: Inline tafsir

**Files:**
- Create: `lib/features/quran/presentation/widgets/inline_tafsir_panel.dart`
- Modify: `lib/features/quran/presentation/widgets/ayah_card.dart`
- Create: `test/features/quran/presentation/inline_tafsir_panel_test.dart`

**Interfaces:**
- `InlineTafsirPanel(surahNumber, ayahNumber)` lazily reads `tafsirRepositoryProvider` only after expansion.
- Prefers `primaryBanglaTafsirSourceId`; falls back to first installed source.

- [ ] Write a widget test with a fake installed primary Bangla tafsir and assert its text appears only after expanding `Tafsir`.
- [ ] Write a widget test for no installed sources and assert the setup action is shown.
- [ ] Implement lazy loading and the compact expansion UI.
- [ ] Keep the existing full-screen tafsir action available.

### Task 5: Regression gate and packaging

**Files:**
- Verify all changed files.

- [ ] Run `dart format` on changed Dart files.
- [ ] Run focused Flutter tests for reader controller, Quran reader page, auto-scroll, active highlighting, inline tafsir, reader audio actions, and ayah tafsir action.
- [ ] Run `flutter analyze`.
- [ ] Package only changed source/test/spec/plan files with repository-relative paths.
