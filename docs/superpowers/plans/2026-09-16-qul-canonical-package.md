# QUL Canonical Package Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the schema-v2 bundled Quran database using public QUL resource-59 Nastaleeq text and Mushaf 3 positions, with provenance and corpus verification.

**Architecture:** Materialize the two ephemeral QUL SQLite inputs from the official chapter-verses API. The existing builder remains the single canonical SQLite writer; its reader consumes the normalized input tables. Extend validation only where the official source requires it, then build and directly inspect the output.

**Tech Stack:** Dart, Flutter tests, sqlite3, official QUL HTTPS API.

**Spec:** `.superpowers/sdd/2026-09-15-hifz-immersive-mushaf/task-8-brief.md`

## Global Constraints

- Offline runtime database; schema version 2.
- Exactly 114 Surahs, 6,236 ayahs, and all pages 1–604.
- Corrected IndoPak text comes from QUL resource 59's `text_indopak_nastaleeq` verse/word field.
- Fixed line data comes from QUL Mushaf ID 3 page and line positions.
- Preserve tanween and a real sukun: official resource 59 uses standard Arabic sukun U+0652, while other IndoPak data may use U+06E1; validation must accept either sukun form but still require U+064B tanween.
- Standalone Bismillah layout rules: Surahs 2–114 except 9; Al-Fatihah Bismillah remains ayah 1; Surah 9 has no Bismillah.
- Record SHA-256 provenance for normalized QUL inputs and output.
- Do not fabricate Quran text and do not bypass QUL authentication.

---

### Task 1: Validate resource-59 diacritics

**Files:**
- Modify: `test/tool/quran_content/quran_integrity_validator_test.dart`
- Modify: `tool/quran_content/quran_integrity_validator.dart`

- [ ] **Step 1: Write the failing test** for a production-style fixture containing U+0652 and U+064B, which must have no `indoPakDiacritics` issue.
- [ ] **Step 2: Run the focused test** and observe the expected failure because the validator only accepts U+06E1.
- [ ] **Step 3: Implement the minimal validator query/message change** accepting U+0652 or U+06E1 and still requiring U+064B.
- [ ] **Step 4: Run the focused test** and confirm it passes.

### Task 2: Materialize official normalized QUL inputs

**Files:**
- Create: `tool/quran_content/materialize_qul_sources.dart`
- Create: `tool/quran_content/fetch_qul_mushaf_sources.dart`
- Create: `test/tool/quran_content/qul_source_materializer_test.dart`
- Modify: `tool/quran_content/README.md`

- [ ] **Step 1: Write failing fixture tests** for marker exclusion, preserved `text_indopak_nastaleeq`, page/line grouping, and Bismillah metadata policy.
- [ ] **Step 2: Run focused tests** and observe imports/normalization are unavailable.
- [ ] **Step 3: Implement the smallest pure materializer** that recognizes only a final numbered API marker, retains every canonical word exactly once, derives line boundaries, and fills immediately preceding physical metadata gaps.
- [ ] **Step 4: Run focused tests** and confirm they pass.
- [ ] **Step 5: Add the thin public-API fetch command and README invocation**, then materialize `/tmp/qul-indopak-59.sqlite` and `/tmp/qul-pdms-layout-3.sqlite` from all 114 official endpoints.

### Task 3: Rebuild and independently verify artifacts

**Files:**
- Modify: `assets/database/quran_content.sqlite`
- Modify: `assets/database/quran_content.sqlite.report.json`
- Modify: `assets/database/quran_content_manifest.json`
- Modify: `assets/database/README.md`
- Create: `.superpowers/sdd/2026-09-15-hifz-immersive-mushaf/task-8-report.md`

- [ ] **Step 1: Run `flutter test test/tool/quran_content`** before and after the change.
- [ ] **Step 2: Build** with the three verified JSON inputs and the two `/tmp` QUL inputs.
- [ ] **Step 3: Query the output** for schema version, counts, layout coverage/order/boundaries, resource-59 representative 2:2 text, U+0652/U+064B, hashes, and Bismillah policy.
- [ ] **Step 4: Update database README and task report** with reproducible provenance, commands, RED/GREEN evidence, outputs, and self-review.
