# Immersive Hifz Mushaf Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver an offline, immersive Hifz reader with selectable Free Flow and Fixed Mushaf layouts, corrected QUL IndoPak text, PDMS Bismillah, and Al-Qalam ayah ornaments.

**Architecture:** Persist a Hifz-only layout choice. Free Flow wraps the selected Surah at the exact chosen size; Fixed Mushaf renders normalized QUL line records at a page-safe fitted size. Isolate Android system-UI lifecycle behind an injectable service.

**Tech Stack:** Flutter, Dart, Riverpod, Drift, sqlite3, Flutter widget tests

**Spec:** `docs/superpowers/specs/2026-09-15-hifz-immersive-mushaf-design.md`

> **Approved correction — 2026-09-16:** QUL layout ID 3, fixed 15-line rendering, fit-safe shrinking, and the “Maximum for this screen” UI are superseded. Existing line-import/repository code may remain compatible but is not used by Hifz. Task 5 now means flowing selected-Surah rendering; Task 8 imports corrected QUL script resource 59 only.

> **Final approved correction — 2026-09-16:** Keep both modes. Free Flow remains the default and applies size/spacing exactly. Fixed Mushaf restores QUL layout ID 3 and automatic page-safe fitting; it ignores Free Flow size/spacing. This paragraph supersedes the preceding correction.

## Global Constraints

- Runtime Quran reading remains fully offline.
- Use QUL script resource 59 and QUL Mushaf layout ID 3.
- Preserve exactly 114 Surahs, 6,236 ayahs, and 604 pages.
- All seven Quran faces are available in both regular and Hifz settings. Hifz defaults to PDMS Saleem; the regular reader defaults to Indopak Nastaleeq.
- Global and Hifz typography are persisted independently; neither reader watches the other's font, size, or line-height providers.
- Standalone Bismillah uses PDMS Saleem for Surahs 2–114 except 9; Al-Fatihah renders Bismillah as numbered ayah 1, and Surah 9 omits it.
- Ayah ornaments always use `AlQalamQuranMajeed` and scale with effective Hifz text size.
- Free Flow uses the exact selected size and wraps; Fixed Mushaf preserves canonical lines and fits them without horizontal scrolling.
- Quicksand is removed because it has no runtime consumer.
- Font licensing/attribution must be confirmed before public distribution.
- The current workspace has no `.git` metadata. Run each listed commit step only after repository metadata is restored.

---

## File Structure

- `lib/features/quran/domain/quran_font_preference.dart`: shared selectable font catalog and compatible script mapping.
- `lib/features/quran/domain/quran_mushaf_line.dart`: immutable line type and stable word-location models.
- `lib/features/hifz/application/hifz_text_layout.dart`: interactive Hifz word metadata.
- `lib/features/hifz/presentation/hifz_appearance_sheet.dart`: dedicated preview and typography controls.
- `lib/features/hifz/presentation/hifz_mushaf_line.dart`: one fixed interactive Mushaf line plus ornaments.
- `lib/features/hifz/presentation/hifz_system_ui.dart`: injectable immersive/restore boundary.
- `tool/quran_content/qul_mushaf_source.dart`: reads QUL SQLite exports and normalizes global IDs.
- Existing preference, canonical database, repository, Hifz page/surface, and tests are modified in place.

### Task 1: Register the Quran Font Catalog and Remove Quicksand

**Files:**
- Create: `lib/features/quran/domain/quran_font_preference.dart`
- Modify: `lib/features/quran/domain/quran_script.dart`
- Modify: `pubspec.yaml`
- Delete: `assets/fonts/Quicksand.ttf`
- Delete: `assets/fonts/OFL-Quicksand.txt`
- Modify: `test/features/quran/presentation/quran_word_view_style_test.dart`
- Create: `test/features/quran/domain/quran_font_preference_test.dart`

**Interfaces:**
- Produces: shared `enum QuranFontPreference`, `String fontFamily`, `String label`, and `QuranScriptPreference script`.
- Changes: `QuranScriptPreference.indoPak.preferredFontFamily` returns `Indopak Nastaleeq`.

- [ ] **Step 1: Write failing font-selection tests**

```dart
test('PDMS is the default Hifz font and maps to IndoPak text', () {
  expect(QuranFontPreference.defaultHifz, QuranFontPreference.pdmsSaleem);
  expect(QuranFontPreference.defaultGlobal, QuranFontPreference.indopakNastaleeq);
  expect(QuranFontPreference.pdmsSaleem.fontFamily, 'PDMS Saleem Quran');
  expect(QuranFontPreference.pdmsSaleem.script, QuranScriptPreference.indoPak);
});

test('every supplied Quran face selects its compatible Quran script', () {
  expect(QuranFontPreference.values.map((font) => font.fontFamily), containsAll([
    'PDMS Saleem Quran',
    'Indopak Nastaleeq',
    'Quran DigitalKhatt IndoPak',
    'AlQalamQuranMajeed',
    'Muhammadi Quranic',
    'KFGQPC Hafs Uthmanic',
    'Noto Naskh Arabic',
  ]));
  expect(QuranFontPreference.kfgqpcHafs.script, QuranScriptPreference.uthmaniMadani);
  expect(QuranFontPreference.notoNaskhArabic.script, QuranScriptPreference.uthmaniMadani);
});
```

- [ ] **Step 2: Run the tests and confirm RED**

Run: `flutter test test/features/quran/domain/quran_font_preference_test.dart test/features/quran/presentation/quran_word_view_style_test.dart`

Expected: compilation fails because `QuranFontPreference` does not exist and the regular IndoPak face is still DigitalKhatt.

- [ ] **Step 3: Add the minimal font catalog**

```dart
enum QuranFontPreference {
  pdmsSaleem('PDMS Saleem Quran', 'PDMS Saleem Quran', QuranScriptPreference.indoPak),
  indopakNastaleeq('Indopak Nastaleeq', 'Indopak Nastaleeq', QuranScriptPreference.indoPak),
  digitalKhatt('DigitalKhatt IndoPak', 'Quran DigitalKhatt IndoPak', QuranScriptPreference.indoPak),
  alQalam('Al Qalam Quran Majeed', 'AlQalamQuranMajeed', QuranScriptPreference.indoPak),
  muhammadi('Muhammadi Quran', 'Muhammadi Quranic', QuranScriptPreference.indoPak),
  kfgqpcHafs('KFGQPC Hafs', 'KFGQPC Hafs Uthmanic', QuranScriptPreference.uthmaniMadani),
  notoNaskhArabic('Noto Naskh Arabic', 'Noto Naskh Arabic', QuranScriptPreference.uthmaniMadani);

  const QuranFontPreference(this.label, this.fontFamily, this.script);
  static const defaultGlobal = QuranFontPreference.indopakNastaleeq;
  static const defaultHifz = QuranFontPreference.pdmsSaleem;
  final String label;
  final String fontFamily;
  final QuranScriptPreference script;
}
```

Register every supplied file in `pubspec.yaml` under the exact aliases above. Change the normal IndoPak family to `Indopak Nastaleeq`, remove the Quicksand declaration, and delete both unused Quicksand files.

- [ ] **Step 4: Run tests and verify GREEN**

Run: `flutter test test/features/quran/domain/quran_font_preference_test.dart test/features/quran/presentation/quran_word_view_style_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml assets/fonts lib/features/quran/domain/quran_font_preference.dart lib/features/quran/domain/quran_script.dart test/features/quran/domain/quran_font_preference_test.dart test/features/quran/presentation/quran_word_view_style_test.dart
git commit -m "feat: register shared Quran font catalog"
```

### Task 2: Persist Dedicated Hifz Typography

**Files:**
- Modify: `lib/features/settings/domain/app_preferences.dart`
- Modify: `lib/features/settings/application/app_preferences_controller.dart`
- Modify: `lib/features/settings/data/user_database_app_preferences_repository.dart`
- Modify: `lib/features/settings/presentation/settings_page.dart`
- Modify: `lib/features/quran/presentation/quran_text_style.dart`
- Modify: `lib/features/quran/presentation/widgets/quran_word_view.dart`
- Modify: `test/features/settings/domain/app_preferences_test.dart`
- Modify: `test/features/settings/application/app_preferences_controller_test.dart`
- Modify: `test/features/settings/data/user_database_app_preferences_repository_test.dart`

**Interfaces:**
- Adds: independent `QuranFontPreference quranFont` and `QuranFontPreference hifzQuranFont`, plus `double hifzFontSize` and `double hifzLineHeight`.
- Adds: `setQuranFont`, `setHifzQuranFont`, `setHifzFontSize`, `setHifzLineHeight`, and four Riverpod value providers.

- [ ] **Step 1: Write failing defaults, validation, and round-trip tests**

```dart
test('Hifz appearance defaults are independent and readable', () {
  const value = AppPreferences.defaults();
  expect(value.quranFont, QuranFontPreference.indopakNastaleeq);
  expect(value.hifzQuranFont, QuranFontPreference.pdmsSaleem);
  expect(value.hifzFontSize, 32);
  expect(value.hifzLineHeight, 1.65);
});

test('unknown persisted Hifz font falls back to PDMS', () async {
  await database.saveSetting('hifz_quran_font', 'removed_font');
  final value = await repository.load();
  expect(value.hifzQuranFont, QuranFontPreference.pdmsSaleem);
});
```

Add controller tests proving font size outside `20..56` and line height outside `1.20..2.40` throw `ArgumentError`, while valid values persist through the real in-memory repository. Also prove changing the global font does not alter Hifz font/size/spacing and changing the Hifz font does not alter global font/size/line height.

- [ ] **Step 2: Run focused tests and confirm RED**

Run: `flutter test test/features/settings/domain/app_preferences_test.dart test/features/settings/application/app_preferences_controller_test.dart test/features/settings/data/user_database_app_preferences_repository_test.dart`

Expected: compilation fails on missing Hifz preference fields.

- [ ] **Step 3: Implement preferences and providers**

Add keys `quran_font`, `hifz_quran_font`, `hifz_font_size`, and `hifz_line_height`. Parse values through `QuranFontPreference`; use `defaultGlobal` and `defaultHifz` for malformed storage. When `quran_font` is absent, migrate the existing `quran_script` choice to Indopak Nastaleeq or Noto Naskh Arabic. The regular settings page exposes all seven faces and derives the compatible script from the selection. `QuranWordView` and its text style consume the global font provider; Hifz code must consume only the dedicated Hifz providers. Clamp malformed numeric storage to defaults. Add:

```dart
final quranFontProvider = Provider<QuranFontPreference>((ref) =>
  ref.watch(appPreferencesControllerProvider).value?.quranFont ??
  QuranFontPreference.defaultGlobal);
final hifzQuranFontProvider = Provider<QuranFontPreference>((ref) =>
  ref.watch(appPreferencesControllerProvider).value?.hifzQuranFont ??
  QuranFontPreference.defaultHifz);
final hifzFontSizeProvider = Provider<double>((ref) =>
  ref.watch(appPreferencesControllerProvider).value?.hifzFontSize ?? 32);
final hifzLineHeightProvider = Provider<double>((ref) =>
  ref.watch(appPreferencesControllerProvider).value?.hifzLineHeight ?? 1.65);
```

- [ ] **Step 4: Run focused tests and verify GREEN**

Run: `flutter test test/features/settings/domain/app_preferences_test.dart test/features/settings/application/app_preferences_controller_test.dart test/features/settings/data/user_database_app_preferences_repository_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/settings test/features/settings
git commit -m "feat: persist dedicated Hifz typography"
```

### Task 3: Normalize QUL IndoPak Text and PDMS Layout

**Files:**
- Create: `tool/quran_content/qul_mushaf_source.dart`
- Modify: `tool/quran_content/models/source_records.dart`
- Modify: `tool/quran_content/build_quran_db.dart`
- Modify: `tool/quran_content/schema.sql`
- Modify: `tool/quran_content/quran_integrity_validator.dart`
- Create: `test/tool/quran_content/qul_mushaf_source_test.dart`
- Modify: `test/tool/quran_content/quran_integrity_validator_test.dart`

**Interfaces:**
- Produces: `QulMushafSource.open({required String scriptPath, required String layoutPath})`.
- Produces: `String indoPakAyahText(int surah, int ayah)`, `String indoPakWordText(String location)`, and `List<MushafLineSourceRecord> get lines`.
- Changes CLI: `build_quran_db.dart` requires `--indopak-db` and `--layout-db` in addition to current inputs.

- [ ] **Step 1: Write SQLite-fixture tests for normalization**

Create temporary QUL-shaped databases with documented tables `words(id, location, surah, ayah, word, text)` and `pages(page_number, line_number, line_type, is_centered, first_word_id, last_word_id, surah_number)`. Assert:

```dart
expect(source.indoPakWordText('2:1:1'), 'الٓمّٓ');
expect(source.lines.single.firstWordLocation, '2:1:1');
expect(source.lines.single.lastWordLocation, '2:1:3');
expect(source.lines.single.centered, isFalse);
```

Add failure cases for an unknown boundary ID, duplicate location, a non-604 production page set, and a missing word. Assert a fixture containing `لَمۡ` and `هُدًى` retains U+06E1 and U+064B.

- [ ] **Step 2: Run normalization tests and confirm RED**

Run: `flutter test test/tool/quran_content/qul_mushaf_source_test.dart test/tool/quran_content/quran_integrity_validator_test.dart`

Expected: compilation fails because `QulMushafSource` and layout integrity codes do not exist.

- [ ] **Step 3: Implement the QUL reader and schema v2**

Read both SQLite files read-only. Map each global word ID to `location`. For `ayah` lines, convert inclusive first/last IDs to locations; for `surah_name` and `basmallah`, require null word boundaries and a valid Surah number. On only the final word of an ayah, remove a trailing QUL private-use ayah-number code point in U+E000..U+F8FF; preserve all preceding Quranic U+06xx pause and diacritic marks. Reject any PUA code point occurring inside a non-final word or anywhere except the validated trailing marker position.

Add `mushaf_lines` to `schema.sql`:

```sql
CREATE TABLE mushaf_lines (
  page_number INTEGER NOT NULL CHECK (page_number BETWEEN 1 AND 604),
  line_number INTEGER NOT NULL,
  line_type TEXT NOT NULL CHECK (line_type IN ('ayah','surah_name','basmallah')),
  is_centered INTEGER NOT NULL CHECK (is_centered IN (0,1)),
  surah_number INTEGER,
  first_word_location TEXT,
  last_word_location TEXT,
  PRIMARY KEY (page_number, line_number)
);
CREATE INDEX idx_mushaf_line_page ON mushaf_lines(page_number, line_number);
```

Set `PRAGMA user_version = 2`, set `_schemaVersion = 2`, merge QUL IndoPak values by exact location while inserting ayahs/words, insert normalized line rows, and include both QUL input checksums in the report.

- [ ] **Step 4: Add canonical integrity checks**

Add error codes for `mushafPageCoverage`, `mushafLineOrder`, `mushafBoundary`, and `indoPakDiacritics`. Production validation must query 604 distinct pages, reject duplicate/gapped line numbers, ensure boundaries resolve to `quran_words`, and assert the imported corpus contains both sukun and tanween.

- [ ] **Step 5: Run focused tests and verify GREEN**

Run: `flutter test test/tool/quran_content/qul_mushaf_source_test.dart test/tool/quran_content/quran_integrity_validator_test.dart test/tool/quran_content/source_records_test.dart test/tool/quran_content/build_report_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add tool/quran_content test/tool/quran_content
git commit -m "feat: import verified QUL IndoPak Mushaf data"
```

### Task 4: Expose Mushaf Lines Through the Quran Repository

**Files:**
- Create: `lib/features/quran/domain/quran_mushaf_line.dart`
- Modify: `lib/features/quran/domain/quran_page_window.dart`
- Modify: `lib/core/database/quran_content_database.dart`
- Regenerate: `lib/core/database/quran_content_database.g.dart`
- Modify: `lib/features/quran/data/drift_quran_repository.dart`
- Modify: `test/features/quran/data/drift_quran_repository_test.dart`

**Interfaces:**
- Produces: `enum QuranMushafLineType { ayah, surahName, bismillah }`.
- Produces: `QuranWordLocation.parse(String)` and `QuranMushafLine` with ordered `wordLocations`.
- Changes: `QuranPageWindow.lines`, defaulting to `const []` for existing fakes.

- [ ] **Step 1: Write failing repository behavior tests**

Insert a page containing two ayahs and line boundaries that split the second ayah. Assert `loadPageWindow` returns ordered lines and expands inclusive boundary locations to literal locations such as `['2:1:1', '2:1:2']`; assert a legacy test database without `mushaf_lines` returns `lines.isEmpty` for readable fallback.

- [ ] **Step 2: Run and confirm RED**

Run: `flutter test test/features/quran/data/drift_quran_repository_test.dart`

Expected: compilation fails because `QuranPageWindow.lines` does not exist.

- [ ] **Step 3: Implement models, Drift schema, and query**

Add dual-script/tajweed columns already present in `schema.sql` to the Drift table declarations while raising `QuranContentDatabase.schemaVersion` to 2. Add `MushafLines` to `@DriftDatabase`, regenerate with:

Run: `dart run build_runner build --delete-conflicting-outputs`

Query lines by page, expand each inclusive range against the page's ordered ayah words, and return immutable `wordLocations`. Detect the table with `sqlite_master` so legacy test fixtures continue to use `const []`.

- [ ] **Step 4: Run tests and verify GREEN**

Run: `flutter test test/features/quran/data/drift_quran_repository_test.dart test/core/database/quran_content_bootstrap_test.dart test/core/database/quran_content_installer_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/database lib/features/quran test/features/quran test/core/database
git commit -m "feat: expose fixed Mushaf page lines"
```

### Task 5: Build the Two-Mode Hifz Renderer

**Files:**
- Create: `lib/features/hifz/application/hifz_text_layout.dart`
- Create: `lib/features/hifz/presentation/hifz_mushaf_line.dart`
- Modify: `lib/features/hifz/presentation/hifz_mushaf_surface.dart`
- Modify: `test/features/hifz/presentation/hifz_mushaf_surface_test.dart`
- Create: `test/features/hifz/application/hifz_text_layout_test.dart`

**Interfaces:**
- Produces: `double fitSafeFontSize({required double requestedSize, required double availableWidth, required double widestLineWidth})`.
- Produces: `List<HifzLineWord> resolveMushafLine(QuranPageWindow, QuranMushafLine)`.
- Consumes: Hifz preference providers and `QuranPageWindow.lines`.

- [ ] **Step 1: Write failing pure layout tests**

```dart
expect(fitSafeFontSize(requestedSize: 40, availableWidth: 300, widestLineWidth: 400), 30);
expect(fitSafeFontSize(requestedSize: 32, availableWidth: 400, widestLineWidth: 300), 32);
```

Create a line spanning the end of ayah 1 and start of ayah 2; assert the resolver returns the exact ordered locations and flags both verse endings without moving words when font or line-height inputs change.

- [ ] **Step 2: Write failing renderer tests**

Assert a page with line records renders all Surahs on the page, contains no translation, uses the selected body font, renders marker text containing `\u06DD` plus Arabic-Indic digits in `AlQalamQuranMajeed`, renders standalone PDMS Bismillah for Surah 2, renders Al-Fatihah Bismillah as selectable ayah 1 with ornament 1, omits Bismillah for Surah 9, and falls back to the old reflow surface when `lines` is empty.

- [ ] **Step 3: Run focused tests and confirm RED**

Run: `flutter test test/features/hifz/application/hifz_text_layout_test.dart test/features/hifz/presentation/hifz_mushaf_surface_test.dart`

Expected: compilation fails on missing fixed-line APIs.

- [ ] **Step 4: Implement safe sizing and fixed lines**

Measure each composed line with `TextPainter` using the selected font/script at requested size. Compute one effective size for the whole page, then render every Quran line as an RTL `Row`: `MainAxisAlignment.center` for centered lines and `MainAxisAlignment.spaceBetween` otherwise. Use compact interactive word widgets and append this dedicated marker span at each ayah end:

```dart
Text(
  '\u06DD${toArabicIndic(ayah.ayahNumber)}',
  key: ValueKey('hifz-ayah-marker-${ayah.key}'),
  style: TextStyle(
    fontFamily: 'AlQalamQuranMajeed',
    fontSize: effectiveFontSize * 0.78,
  ),
)
```

Use `shouldShowStandaloneBismillah`: render layout Bismillah lines for Surahs 2–114 except 9 in `PDMS Saleem Quran`; render Al-Fatihah's Bismillah from its canonical ayah-1 words with ornament 1; render none for Surah 9. Retain the current reflow implementation as a private fallback widget.

- [ ] **Step 5: Run focused tests and verify GREEN**

Run: `flutter test test/features/hifz/application/hifz_text_layout_test.dart test/features/hifz/presentation/hifz_mushaf_surface_test.dart test/features/quran/presentation/active_word_highlight_test.dart`

Expected: PASS with no overflow exceptions.

- [ ] **Step 6: Commit**

```bash
git add lib/features/hifz test/features/hifz
git commit -m "feat: render fixed resizable Hifz Mushaf lines"
```

### Task 6: Add the Dedicated Hifz Appearance Sheet

**Files:**
- Create: `lib/features/hifz/presentation/hifz_appearance_sheet.dart`
- Modify: `lib/features/hifz/presentation/hifz_page.dart`
- Create: `test/features/hifz/presentation/hifz_appearance_sheet_test.dart`

**Interfaces:**
- Consumes: Hifz preference providers/controller methods.
- Produces: `HifzAppearanceSheet(maximumEffectiveFontSize: double)`.

- [ ] **Step 1: Write failing appearance tests**

Pump the real sheet with an in-memory preference repository. Select Muhammadi and assert the preview's Quran text uses `Muhammadi Quranic`; drag font size and line spacing, dismiss/reopen, and assert persisted values. Select size 56 and assert Free Flow renders at 56 without a screen-maximum warning. Select Fixed Mushaf and assert the Free Flow sliders are hidden and canonical lines are fitted.

- [ ] **Step 2: Run and confirm RED**

Run: `flutter test test/features/hifz/presentation/hifz_appearance_sheet_test.dart`

Expected: compilation fails because the sheet does not exist.

- [ ] **Step 3: Implement the sheet**

Use a scroll-controlled modal sheet with a live two-line Quran preview, seven-option `DropdownButtonFormField<QuranFontPreference>`, transient size slider `20..56`, transient line-height slider `1.20..2.40`, and Reset action setting PDMS/32/1.65. Persist only on slider end to avoid database writes for every frame.

- [ ] **Step 4: Run and verify GREEN**

Run: `flutter test test/features/hifz/presentation/hifz_appearance_sheet_test.dart test/features/settings/application/app_preferences_controller_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/hifz/presentation/hifz_appearance_sheet.dart lib/features/hifz/presentation/hifz_page.dart test/features/hifz/presentation/hifz_appearance_sheet_test.dart
git commit -m "feat: add Hifz appearance controls"
```

### Task 7: Make the Hifz Route Immersive and Tap-Controlled

**Files:**
- Create: `lib/features/hifz/presentation/hifz_system_ui.dart`
- Modify: `lib/features/hifz/presentation/hifz_page.dart`
- Modify: `lib/features/hifz/presentation/hifz_active_player.dart`
- Modify: `test/features/hifz/presentation/hifz_page_test.dart`

**Interfaces:**
- Produces: `abstract interface class HifzSystemUi { Future<void> enter(); Future<void> restore(); }`.
- Produces: `hifzSystemUiProvider` with production `SystemChrome` implementation.
- Changes: Hifz controls initially visible; page-background taps toggle them; page swipes work from 1 through 604.

- [ ] **Step 1: Write failing lifecycle and gesture tests**

Use a recording `HifzSystemUi` fake. Assert `enter()` runs once after Hifz mounts and `restore()` runs once after route disposal. Assert keys `hifz-top-controls` and `hifz-bottom-controls` initially exist; page-background tap removes them; the next tap restores them; tapping a word while visible invokes word audio without hiding controls.

Add swipe tests proving page 1 cannot go backward, page 604 cannot go forward, and a page containing two Surahs renders both while header metadata follows the first visible Surah.

- [ ] **Step 2: Run and confirm RED**

Run: `flutter test test/features/hifz/presentation/hifz_page_test.dart`

Expected: tests fail because the current page always renders an app bar and has no immersive lifecycle.

- [ ] **Step 3: Implement system UI lifecycle**

```dart
class FlutterHifzSystemUi implements HifzSystemUi {
  @override
  Future<void> enter() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  @override
  Future<void> restore() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}
```

Call `enter` after the first frame and `unawaited(restore())` in `dispose`. Replace the fixed `AppBar`/FAB/column chrome with a `Stack`: full-page Mushaf, animated top controls, animated bottom controls, and gesture layer. Use child gesture handlers to stop page-background toggling. Add horizontal drag threshold navigation and keep Close as `Navigator.maybePop`.

- [ ] **Step 4: Run focused tests and verify GREEN**

Run: `flutter test test/features/hifz/presentation/hifz_page_test.dart test/features/hifz/presentation/hifz_pattern_controls_test.dart test/features/hifz/presentation/memorization_test_page_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/hifz/presentation test/features/hifz/presentation
git commit -m "feat: add immersive distraction-free Hifz reader"
```

### Task 8: Rebuild and Verify the Canonical Quran Package

**Files:**
- Modify: `assets/database/quran_content.sqlite`
- Modify: `assets/database/quran_content.sqlite.report.json`
- Modify: `assets/database/quran_content_manifest.json`
- Modify: `assets/database/README.md`

**Interfaces:**
- Consumes: downloaded QUL resource 59 SQLite and QUL layout ID 3 SQLite.
- Produces: schema-v2 bundled Quran package with corrected IndoPak text and fixed line data.

- [ ] **Step 1: Download the exact QUL IndoPak and layout SQLite exports**

Use the SQLite download actions on:

- `https://qul.tarteel.ai/resources/quran-script/59`
- `https://qul.tarteel.ai/mushaf_layouts/3`

Save them outside source control as `/tmp/qul-indopak-59.sqlite` and `/tmp/qul-pdms-layout-3.sqlite`. Record their SHA-256 values in the generated build report.

- [ ] **Step 2: Run the schema/source tests before rebuilding**

Run: `flutter test test/tool/quran_content`

Expected: PASS.

- [ ] **Step 3: Rebuild with the existing verified base inputs**

Run the extended builder using the exact normalized base Quran, word, and translation inputs documented by `tool/quran_content/README.md`, plus:

```bash
dart run tool/quran_content/build_quran_db.dart \
  --quran tool/quran_content/source/verified-quran.json \
  --words tool/quran_content/source/verified-words.json \
  --translation tool/quran_content/source/verified-bangla.json \
  --indopak-db /tmp/qul-indopak-59.sqlite \
  --layout-db /tmp/qul-pdms-layout-3.sqlite \
  --out assets/database/quran_content.sqlite
```

Expected: schema version 2, 114 Surahs, 6,236 ayahs, 604 fixed-layout pages, corrected IndoPak words, no integrity errors, and new manifest/report checksums.

- [ ] **Step 4: Verify representative data directly**

Run:

```bash
sqlite3 assets/database/quran_content.sqlite "PRAGMA user_version; SELECT COUNT(DISTINCT page_number) FROM mushaf_lines; SELECT arabic_indopak FROM quran_words WHERE surah_number=2 AND ayah_number=2 ORDER BY position;"
```

Expected: schema `2`, `604` layout pages, and fully marked IndoPak words containing the expected sukun/tanween characters.

- [ ] **Step 5: Commit**

```bash
git add assets/database
git commit -m "data: bundle verified IndoPak Mushaf layout"
```

### Task 9: Full Verification and Android Visual Acceptance

**Files:**
- Modify only files required by failures found during this task.

- [ ] **Step 1: Format and analyze**

Run: `dart format lib test tool`

Run: `flutter analyze`

Expected: no issues.

- [ ] **Step 2: Run the full automated suite**

Run: `flutter test`

Expected: all tests pass with no overflow or uncaught framework exceptions.

- [ ] **Step 3: Build and install Android debug APK**

Run: `flutter build apk --debug`

Run: `adb -s 4SR4SGMR65RGWS8T install -r build/app/outputs/flutter-apk/app-debug.apk`

Expected: successful build and install.

- [ ] **Step 4: Perform visual acceptance**

On the device, verify Hifz page 3 against the clean reference, controls-visible state against the supplied reader reference, PDMS Bismillah, Al-Qalam ornaments, all seven selectable fonts, max-size clamping, line-spacing extremes, tap toggle, swipe navigation, and system-bar restoration after Close.

- [ ] **Step 5: Commit verification fixes**

```bash
git add lib test tool assets pubspec.yaml
git commit -m "fix: polish immersive Hifz visual behavior"
```
