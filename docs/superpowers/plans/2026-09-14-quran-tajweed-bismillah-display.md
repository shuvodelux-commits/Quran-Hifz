# Quran Tajweed, Bismillah, and Active-Word Color Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add verified Uthmani Tajweed data/rendering, complete IndoPak content support, canonical Bismillah headers, and the approved active-word green color without regressing reader/Hifz playback.

**Architecture:** Extend the offline Quran content package with Quran Foundation's `text_uthmani_tajweed` at ayah and word level. Parse the API's embedded `<tajweed class=...>` markup into immutable render segments in the presentation layer, keeping the domain model free of Flutter types. Add one reusable Bismillah policy/header used by Study and Hifz. Playback/tap highlighting remains a word-level override and uses the screenshot green `#11AF00`.

**Tech Stack:** Flutter, Riverpod, Drift/SQLite, Dart source import tools, Quran Foundation Content API v4.

**Spec:** Approved in chat on 2026-09-14: authentic IndoPak/Uthmani selection, Tajweed colors, Bismillah on every Surah except At-Tawbah without duplicating Al-Fatihah's ayah 1, and screenshot-matched active-word highlight color.

## Global Constraints

- Do not change the existing single Quran audio controller.
- Do not restore whole-ayah playback highlighting.
- Keep Study and Hifz reading from the same canonical offline Quran database.
- IndoPak must use verified `text_indopak`, never a cosmetic transliteration/substitution.
- Tajweed must use verified `text_uthmani_tajweed` markup from Quran Foundation.
- Surah 1 must not receive a duplicate standalone Bismillah; Surah 9 must receive none; Surahs 2-8 and 10-114 receive one before ayah 1.
- Active word/tap-to-play highlight color is `#11AF00`.

---

### Task 1: Persist Tajweed preference

**Files:**
- Modify: `lib/features/settings/domain/app_preferences.dart`
- Modify: `lib/features/settings/application/app_preferences_controller.dart`
- Modify: `lib/features/settings/data/user_database_app_preferences_repository.dart`
- Modify: `lib/features/settings/presentation/settings_page.dart`
- Test: `test/features/settings/domain/app_preferences_test.dart`
- Test: `test/features/settings/application/app_preferences_controller_test.dart`
- Test: `test/features/settings/presentation/settings_page_test.dart`

**Interfaces:**
- Produces: `showTajweedColorsProvider: Provider<bool>` and `setShowTajweedColors(bool)`.

- [ ] Write failing settings tests for default/persistence/controller/UI toggle.
- [ ] Verify RED on Fedora.
- [ ] Implement preference plumbing and Settings switch.
- [ ] Verify GREEN on Fedora.

### Task 2: Extend verified Quran content with Tajweed markup

**Files:**
- Modify: `tool/quran_content/source_fetcher.dart`
- Modify: `tool/quran_content/models/source_records.dart`
- Modify: `tool/quran_content/schema.sql`
- Modify: `tool/quran_content/build_quran_db.dart`
- Modify: `tool/quran_content/quran_integrity_validator.dart`
- Modify: `lib/features/quran/domain/quran_ayah.dart`
- Modify: `lib/features/quran/domain/quran_word.dart`
- Modify: `lib/features/quran/data/drift_quran_repository.dart`
- Test: `test/tool/quran_content/source_fetcher_test.dart`
- Test: `test/tool/quran_content/source_records_test.dart`
- Test: `test/features/quran/data/drift_quran_repository_test.dart`

**Interfaces:**
- `QuranWord.arabicTajweedMarkup: String?`
- `QuranAyah.arabicTajweedMarkup: String?`

- [ ] Write failing source/repository tests.
- [ ] Verify RED on Fedora.
- [ ] Request/store `text_uthmani_tajweed` and safely read legacy databases without the new columns.
- [ ] Verify GREEN on Fedora.

### Task 3: Parse and render Tajweed markup with playback override

**Files:**
- Create: `lib/features/quran/domain/tajweed_segment.dart`
- Create: `lib/features/quran/application/tajweed_markup_parser.dart`
- Create: `lib/features/quran/presentation/quran_reading_colors.dart`
- Modify: `lib/features/quran/presentation/widgets/quran_word_view.dart`
- Modify: `lib/features/hifz/presentation/hifz_mushaf_surface.dart`
- Test: `test/features/quran/application/tajweed_markup_parser_test.dart`
- Test: `test/features/quran/presentation/quran_word_view_style_test.dart`
- Test: `test/features/hifz/presentation/hifz_mushaf_surface_test.dart`

**Interfaces:**
- `parseTajweedMarkup(String): List<TajweedSegment>`
- `QuranReadingColors.activeWord = Color(0xFF11AF00)`

- [ ] Write failing parser and rendering tests.
- [ ] Verify RED on Fedora.
- [ ] Implement parser/palette and RichText rendering.
- [ ] Preserve word-level playback override as one green color over any Tajweed spans.
- [ ] Verify GREEN on Fedora.

### Task 4: Add canonical Bismillah policy/header

**Files:**
- Create: `lib/features/quran/domain/bismillah_policy.dart`
- Create: `lib/features/quran/presentation/widgets/surah_bismillah_header.dart`
- Modify: `lib/features/quran/presentation/widgets/reader_window.dart`
- Modify: `lib/features/hifz/presentation/hifz_mushaf_surface.dart`
- Test: `test/features/quran/domain/bismillah_policy_test.dart`
- Test: `test/features/quran/presentation/quran_reader_page_test.dart`
- Test: `test/features/hifz/presentation/hifz_mushaf_surface_test.dart`

**Interfaces:**
- `shouldShowStandaloneBismillah(int surahNumber): bool`

- [ ] Write failing policy/widget tests for Surahs 1, 2, 9, and 114.
- [ ] Verify RED on Fedora.
- [ ] Add reusable header only before ayah 1 for applicable Surahs.
- [ ] Verify GREEN on Fedora.

### Task 5: Release regression gate

**Files:**
- Modify: `tool/quran_content/README.md`

- [ ] Document required content regeneration command and verified fields.
- [ ] Run focused tests.
- [ ] Run full `flutter test --concurrency=1`.
- [ ] Run `flutter analyze`.
- [ ] Run `python3 tool/release/check_release_ready.py`.
- [ ] Smoke-test Uthmani, IndoPak, Tajweed, Bismillah, word tap, ayah playback, long-ayah word following, and Hifz on OPPO device.
