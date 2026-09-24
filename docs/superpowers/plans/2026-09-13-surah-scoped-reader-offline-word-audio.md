# Surah-Scoped Reader and Offline Word Audio Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Quran Read Surah-first and make explicit Surah offline downloads include word pronunciation audio.

**Architecture:** Add a Surah-library route as the Quran tab root. Reuse the existing page-window reader internally but scope rendering/pagination to the selected Surah. Add a Drift-backed word-audio catalog and extend the existing chapter-audio preparer so explicit offline downloads cache all word audio with limited concurrency.

**Tech Stack:** Flutter, Riverpod, Drift, existing FileAudioDownloadRepository and QuranAudioController.

**Spec:** `docs/superpowers/specs/2026-09-13-surah-scoped-reader-offline-word-audio-design.md`

## Global Constraints

- Keep one Quran audio controller/player.
- Do not change working chapter download, ayah timing, word tap online playback, Tafsir, or Hifz behavior.
- Word audio continues to use `https://audio.qurancdn.com/` when the stored path is relative.
- Explicit offline package downloads use bounded concurrency.

---

### Task 1: Surah library route

**Files:**
- Create: `lib/features/quran/presentation/quran_surah_list_page.dart`
- Modify: `lib/features/quran/application/quran_providers.dart`
- Modify: `lib/app/quran_hifz_shell.dart`
- Test: `test/features/quran/presentation/quran_surah_list_page_test.dart`

- [ ] Write widget tests for list rendering, search and revelation filters.
- [ ] Implement the FutureProvider and Surah library UI.
- [ ] Make the Quran shell destination use the Surah library.
- [ ] Verify tests.

### Task 2: Scope continuous reader to one Surah

**Files:**
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Modify: `lib/features/quran/application/reader_controller.dart`
- Test: `test/features/quran/presentation/quran_reader_page_test.dart`

- [ ] Write a test where a Quran page contains ayahs from two Surahs and assert only the selected Surah renders.
- [ ] Make `QuranReaderPage` require a `QuranSurahSummary`.
- [ ] Open the selected Surah's starting page and clamp pagination to its page range.
- [ ] Filter mixed boundary pages to the selected Surah and remove page-boundary chrome.
- [ ] Preserve exact selected-Surah reading location when opening a mixed boundary page.
- [ ] Verify reader tests.

### Task 3: Download word audio with the Surah package

**Files:**
- Create: `lib/features/quran/domain/word_audio_source.dart`
- Create: `lib/features/quran/data/drift_word_audio_catalog.dart`
- Modify: `lib/features/quran/application/quran_providers.dart`
- Modify: `lib/features/reciters/application/reciter_catalog_controller.dart`
- Modify: `lib/features/reciters/presentation/reciter_audio_page.dart`
- Test: `test/features/reciters/application/reciter_catalog_controller_test.dart`

- [ ] Write a failing preparer test proving `downloadAudio: true` caches every word source and `false` does not.
- [ ] Add Drift word-audio catalog ordered by ayah/word position.
- [ ] Extend the existing preparer to cache words in batches of four after chapter download succeeds.
- [ ] Treat a null local word path as an explicit offline-package failure.
- [ ] Update download completion copy to mention word audio.
- [ ] Verify focused tests.

### Task 4: Regression gate

- [ ] Run `dart format` on changed Dart files.
- [ ] Run focused Quran/reciter/audio tests.
- [ ] Run `flutter analyze`.
- [ ] Run the full Flutter test suite.
- [ ] On OPPO, download one Surah, enable airplane mode, verify ayah playback and an untapped word both play offline.
