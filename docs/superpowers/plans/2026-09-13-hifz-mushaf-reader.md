# Hifz Mushaf Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the numeric Hifz form with an Arabic-first page-stable Mushaf memorization reader backed by the existing Hifz/audio systems.

**Architecture:** Keep the Study reader untouched. Add a focused reusable Mushaf page surface under Hifz presentation and make `HifzPage` coordinate Surah/page loading, range selection, reciter choice, existing Hifz session controls, word actions, and audio-driven page following.

**Tech Stack:** Flutter, Riverpod, Drift-backed Quran repository, existing QuranAudioController and HifzSessionController.

**Spec:** `docs/superpowers/specs/2026-09-13-hifz-mushaf-reader-design.md`

## Global Constraints

- Quran text comes only from the canonical repository.
- Hifz remains single-Surah in V1.
- Study reader/audio/download/Tafsir behavior must not change.
- Reuse the existing single Quran audio controller.

---

### Task 1: Mushaf page surface

**Files:**
- Create: `lib/features/hifz/presentation/hifz_mushaf_surface.dart`
- Test: `test/features/hifz/presentation/hifz_mushaf_surface_test.dart`

**Interfaces:**
- Consumes: `QuranPageWindow`, `QuranSurahSummary`, word/ayah audio state.
- Produces: `HifzMushafSurface` with ayah selection and word callbacks.

- [ ] Write tests for Arabic-only page rendering and ayah-marker selection.
- [ ] Implement the page-stable surface with active/selected ayah styling.
- [ ] Verify the focused widget tests.

### Task 2: Hifz page orchestration

**Files:**
- Modify: `lib/features/hifz/presentation/hifz_page.dart`

**Interfaces:**
- Consumes: `quranSurahListProvider`, `quranRepositoryProvider`, `reciterCatalogControllerProvider`, `hifzSessionControllerProvider`, `readerAudioActionsProvider`.
- Produces: page-based Hifz UI with range/session controls.

- [ ] Replace numeric text inputs with Surah and page navigation.
- [ ] Wire ayah marker selection to `HifzSessionConfig`.
- [ ] Wire reciter selection and existing session controls.
- [ ] Follow active Hifz ayah across Quran page boundaries.
- [ ] Keep word tap/long-press behavior available.

### Task 3: Regression gate

- [ ] Run `flutter test test/features/hifz --reporter expanded`.
- [ ] Run `flutter analyze`.
- [ ] Run full test suite with concurrency 1.
- [ ] Smoke-test on the physical OPPO device.
