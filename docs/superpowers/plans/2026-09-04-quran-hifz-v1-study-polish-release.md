# Quran Hifz V1 Study Tools, Settings, and Release Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish V1 study utilities, settings/accessibility, failure UX, performance profiling, upgrade safety, and the small Android release E2E suite.

**Architecture:** Study tools operate through repositories without modifying canonical Quran rows. Settings are persisted in the user DB and consumed through Riverpod. Release hardening focuses on measured reader/audio behavior and upgrade/data-integrity gates rather than feature expansion.

**Tech Stack:** Flutter/Dart, Riverpod, Drift/SQLite, existing reader/audio/Hifz modules.

**Spec:** `docs/superpowers/specs/2026-09-04-quran-hifz-v1-architecture-design.md`

## Global Constraints

- No video editor or account/cloud sync in V1.
- Canonical Quran data is immutable.
- Errors shown to users are domain messages, not raw exceptions.
- Accessibility and low-end Android profiling are release work, not optional polish.

---

### Task 1: Add word details, bookmarks, and notes

**Files:**
- Add tables: `lib/core/database/user_database.dart`
- Create: `lib/features/study/domain/bookmark.dart`
- Create: `lib/features/study/domain/note.dart`
- Create: `lib/features/study/domain/study_repository.dart`
- Create: `lib/features/study/data/drift_study_repository.dart`
- Create: `lib/features/study/application/study_controller.dart`
- Create: `lib/features/study/presentation/word_details_sheet.dart`
- Modify: `lib/features/quran/presentation/widgets/quran_word_view.dart`
- Create: `test/features/study/study_repository_test.dart`
- Create: `test/features/study/word_details_sheet_test.dart`

**Interfaces:**
- Long press opens details for an immutable `QuranWord` plus repository-backed bookmark/note actions.

- [ ] **Step 1: Write repository and widget tests**

Assert notes/bookmarks persist and deleting them never changes canonical Quran rows. Word sheet shows available transliteration/Bangla meaning/root/grammar and gracefully omits absent optional fields.

- [ ] **Step 2: Implement and run**

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test test/features/study
git add lib test
git commit -m "feat: add Quran study bookmarks and notes"
```

---

### Task 2: Add tafsir package discovery/read and basic search

**Files:**
- Create: `lib/features/tafsir/domain/tafsir_source.dart`
- Create: `lib/features/tafsir/domain/tafsir_repository.dart`
- Create: `lib/features/tafsir/data/tafsir_repository_impl.dart`
- Create: `lib/features/tafsir/presentation/tafsir_page.dart`
- Create: `lib/features/search/domain/quran_search_repository.dart`
- Create: `lib/features/search/data/drift_quran_search_repository.dart`
- Create: `lib/features/search/presentation/quran_search_page.dart`
- Create tests under: `test/features/tafsir/` and `test/features/search/`

**Interfaces:**
- Search V1 supports Surah name/number, exact verse reference, and translation text.
- Tafsir is an optional content package with explicit source identity.

- [ ] **Step 1: Write search/tafsir tests**

Test `2:255` exact navigation, Surah name match, Bangla translation search fixture, missing tafsir source, and downloaded tafsir lookup.

- [ ] **Step 2: Implement indexed search path**

Use SQLite indexes/FTS only if measurement shows simple indexed queries are insufficient. Do not introduce a remote search dependency for offline Quran search.

- [ ] **Step 3: Implement tafsir source identity/download integration**

Reuse the download infrastructure for optional tafsir packages; store source/license/version metadata separately from canonical Quran Arabic.

- [ ] **Step 4: Run/commit**

```bash
dart format lib test
flutter analyze
flutter test test/features/search test/features/tafsir
git add lib test
git commit -m "feat: add Quran search and optional tafsir"
```

---

### Task 3: Persist settings and accessibility behavior

**Files:**
- Add preferences table/schema: `lib/core/database/user_database.dart`
- Create: `lib/features/settings/domain/app_preferences.dart`
- Create: `lib/features/settings/data/drift_preferences_repository.dart`
- Create: `lib/features/settings/application/settings_controller.dart`
- Create: `lib/features/settings/presentation/settings_page.dart`
- Modify reader/audio/download providers to consume preferences selectively
- Create: `test/features/settings/settings_controller_test.dart`
- Create: `test/features/settings/settings_page_test.dart`

**Interfaces:**
- Preferences include theme, Arabic font size, translation visibility, selected reciter, playback speed, repeat defaults, Wi-Fi-only download preference, active-word highlight toggle, keep-screen-awake preference.

- [ ] **Step 1: Write persistence and selective-update tests**

Verify settings survive restart and changing one setting does not reset unrelated preferences.

- [ ] **Step 2: Implement settings UI and providers**

Support Light/Dark/System and Android text scaling. Quran text must not clip at supported accessibility font scales.

- [ ] **Step 3: Device accessibility check**

Verify screen reader labels on word actions/player controls, 200% text-size behavior, dark mode, and reduce-motion behavior where animation exists.

- [ ] **Step 4: Run/commit**

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test test/features/settings
git add lib test
git commit -m "feat: add persistent Quran app settings"
```

---

### Task 4: Harden failure/recovery UX and upgrade safety

**Files:**
- Create: `lib/core/errors/app_failure.dart`
- Create: `lib/core/errors/failure_presenter.dart`
- Modify repositories/controllers to map platform/network/database errors
- Create: `test/core/errors/failure_presenter_test.dart`
- Create: `test/core/database/upgrade_preservation_test.dart`
- Create: `docs/testing/upgrade-matrix.md`

**Interfaces:**
- Controllers expose domain failures; widgets never show raw `SocketException`, Drift exception, platform exception, or ExoPlayer error text.

- [ ] **Step 1: Write failure mapping tests**

Cover network unavailable, audio not downloaded, corrupt local file, source unavailable, timing unavailable, insufficient storage, content DB failure, and user DB migration failure.

- [ ] **Step 2: Write upgrade preservation test**

Create an old-schema fixture with reading progress, Hifz, review history, bookmark, note, preference, and valid download row. Upgrade to current schema and assert every sentinel value survives.

- [ ] **Step 3: Implement failure mapping/recovery**

For corrupt local audio, invalidate local metadata and permit remote fallback only when policy/network allows. Timing failure disables highlight but not ayah playback.

- [ ] **Step 4: Run/commit**

```bash
dart format lib test
flutter analyze
flutter test test/core/errors test/core/database/upgrade_preservation_test.dart
git add lib test docs/testing/upgrade-matrix.md
git commit -m "fix: harden Quran app recovery and upgrade safety"
```

---

### Task 5: Build six release E2E flows and performance profile

**Files:**
- Create integration tests under: `integration_test/`
- Create: `docs/testing/v1-release-gate.md`
- Create: `docs/testing/performance-profile.md`

**Interfaces:**
- Release suite covers only six high-value flows from the spec; unit/database suites remain the main correctness safety net.

- [ ] **Step 1: Implement E2E 1 fresh install/read**

Verify bundled Quran DB opens without network, navigate to Al-Fatihah, render expected verse keys and translation.

- [ ] **Step 2: Implement E2E 2 word tap/ayah repeat**

With deterministic local audio fixture/fake test source, verify word command and exact repeat/auto-next state transitions.

- [ ] **Step 3: Implement E2E 3 download/airplane-mode flow**

Use controlled test assets to download, restart offline, and play local word/ayah sources.

- [ ] **Step 4: Implement E2E 4 background playback device checklist**

Automate what the Android integration framework supports; keep lock-screen/notification/audio-route assertions in the real-device checklist where automation is unreliable.

- [ ] **Step 5: Implement E2E 5 Hifz→revision**

Complete Hifz fixture, record result, use injected test clock, assert due revision and subsequent update.

- [ ] **Step 6: Implement E2E 6 upgrade preservation**

Install/build old fixture, seed user state, upgrade APK/database schema, assert preservation.

- [ ] **Step 7: Profile performance on real hardware**

Record:

```text
reader frame/jank evidence on long Surah
local word tap latency sample
local ayah play latency sample
memory while scrolling long Surah
background playback stability
cold/warm startup observations
```

Test at least one low-end/older Android device, one mid-range device, and one current device where available.

- [ ] **Step 8: Final release gate**

```bash
dart format --output=none --set-exit-if-changed lib test integration_test tool
flutter analyze
flutter test
flutter test integration_test
flutter build appbundle --release
```

Also run the Quran content integrity validator against the exact bundled production DB and attach its checksum/report to the release record.

- [ ] **Step 9: Commit release-hardening work**

```bash
git add integration_test docs test lib tool
git commit -m "test: complete Quran Hifz V1 release gates"
```
