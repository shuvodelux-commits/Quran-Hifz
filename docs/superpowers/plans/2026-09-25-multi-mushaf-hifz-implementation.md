# Multi-Mushaf Hifz Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a second, page-by-page Mushaf reading mode to Hifz with QPC V4 Tajweed and Digital Khatt variants while preserving the existing Regular Hifz workflow and sharing the current Hifz/audio session.

**Architecture:** Keep `HifzPage` as the orchestration entry point. Add a higher-level `HifzReadingMode` above the existing Regular Hifz layout preferences, a variant-neutral Mushaf page repository, a local-only WebView renderer, and a QPC V4 page-font cache. Flutter owns all Hifz/audio/business state; the WebView only renders a page and reports word interactions.

**Tech Stack:** Flutter 3.47.5, Dart 3.13.4, Riverpod 3, Drift/sqlite3, `webview_flutter ^4.13.1`, `http`, `path_provider`, existing Quran/Hifz audio controllers.

**Spec:** `docs/superpowers/specs/2026-09-25-multi-mushaf-hifz-design.md`

## Global Constraints

- Regular Hifz must remain behaviorally unchanged.
- The existing `HifzLayoutMode { freeFlow, fixedMushaf }` remains a Regular-Hifz preference; do not repurpose it as the new Regular/Mushaf selector.
- Required static assets under 5 MB are bundled.
- QPC V4 Layout #19 SQLite is bundled.
- Digital Khatt 15-line layout SQLite is bundled.
- Generated QPC V4 word/glyph SQLite must remain under 5 MB and is bundled.
- DigitalKhattV2 OTF is bundled because it is approximately 510 KB.
- QPC V4 page-specific WOFF2 fonts are downloaded per page and cached; do not bundle all 604 fonts.
- QPC V4 is labeled **QPC V4 Tajweed (Preview)** until its upstream proofreading state changes or release acceptance is explicit.
- The Mushaf WebView is local-content-only; it must never receive credentials, raw database paths, remote URLs, or arbitrary HTML.
- HTTP/HTTPS navigation from the renderer must be blocked.
- Flutter owns audio/session/range/reciter/repeat/speed state.
- The renderer must preserve Tajweed foreground colors; playback highlighting is a background/outline layer.
- Do not silently substitute Quran script/font data when a Mushaf variant fails validation.
- Digital Khatt mode is disabled unless exact Digital Khatt display-script integrity is proven.
- Run TDD RED→GREEN for every behavioral task.
- Preserve the project's current Android minimum SDK; use `webview_flutter ^4.13.1` rather than 4.14.x so this feature does not force API 24.
- Final verification must include full Hifz tests, Quran presentation tests, full `flutter test`, `flutter analyze`, Android debug build, and OPPO device QA.

## Execution Preflight

The current worktree already contains a separate, user-approved QUL Surah Name V4 change that is verified but not yet committed. Before Task 1 touches `pubspec.yaml`, keep that work isolated in its own commit.

Run:

```bash
flutter test test/features/quran/presentation/quran_surah_row_test.dart test/features/quran/presentation/quran_reader_page_test.dart test/features/quran/presentation/quran_surah_list_page_test.dart
flutter analyze
git diff --check
```

Expected: tests PASS, analyzer reports no issues, diff check is clean.

Then commit only these existing Surah-name files:

```bash
git add assets/fonts/README.md assets/fonts/surah-name-v4.ttf pubspec.yaml lib/features/quran/presentation/widgets/surah_name_v4_text.dart lib/features/quran/presentation/widgets/quran_surah_row.dart lib/features/quran/presentation/widgets/reader_surah_header.dart test/features/quran/presentation/quran_reader_page_test.dart test/features/quran/presentation/quran_surah_list_page_test.dart test/features/quran/presentation/quran_surah_row_test.dart
git commit -m "style: use QUL v4 surah name font"
```

After this checkpoint, `git status --short` must be clean except for this implementation plan's own committed history.

## Review Focus

1. **Corrupt/stale cached QPC page font** — the current page must reject invalid bytes and recover by re-downloading without deleting a previously valid cache entry. Covered in Task 4.
2. **Rapid audio page crossing while a WebView page is still loading** — only the newest page/highlight request may win; stale renderer-ready events must not move playback backward. Covered in Task 8.
3. **Persisted P1–P6 palette after switching to Digital Khatt** — the effective Digital Khatt palette must normalize to Light without corrupting the saved QPC palette choice. Covered in Task 2 and Task 7.
4. **Malformed/hostile JavaScript bridge payload** — unknown event types, invalid page numbers, and bad word coordinates must be ignored and logged without changing Hifz state. Covered in Task 6.
5. **Layout/script word-count mismatch on a single line** — the affected Mushaf variant must fail closed rather than shifting later words onto the wrong Quran locations. Covered in Task 3.

---

## File Structure

### New focused units

```text
lib/features/hifz/domain/
  hifz_reading_mode.dart
  hifz_mushaf_page.dart
  hifz_mushaf_page_repository.dart
  mushaf_page_font_repository.dart

lib/features/hifz/data/
  bundled_hifz_mushaf_page_repository.dart
  qpc_v4_page_font_repository.dart

lib/features/hifz/application/
  hifz_mushaf_controller.dart
  hifz_mushaf_providers.dart

lib/features/hifz/presentation/
  hifz_reading_mode_selector.dart
  hifz_mushaf_page_view.dart
  hifz_mushaf_webview.dart
  hifz_mushaf_appearance_sheet.dart

assets/mushaf/
  layouts/qpc-v4-tajweed-15-lines.sqlite
  layouts/digital-khatt-15-lines.sqlite
  scripts/qpc-v4-words.sqlite
  fonts/DigitalKhattV2.otf
  renderer/index.html
  renderer/mushaf.css
  renderer/mushaf.js

tool/mushaf/
  build_qpc_v4_script.dart
  validate_mushaf_assets.dart
```

### Existing files changed

```text
pubspec.yaml
lib/features/settings/domain/app_preferences.dart
lib/features/settings/application/app_preferences_controller.dart
lib/features/settings/data/user_database_app_preferences_repository.dart
lib/features/hifz/presentation/hifz_page.dart
lib/features/hifz/presentation/hifz_appearance_sheet.dart
```

---

### Task 1: Bundle and validate authoritative Mushaf assets

**Files:**
- Create: `assets/mushaf/layouts/qpc-v4-tajweed-15-lines.sqlite`
- Create: `assets/mushaf/layouts/digital-khatt-15-lines.sqlite`
- Create: `assets/mushaf/scripts/qpc-v4-words.sqlite`
- Create: `assets/mushaf/fonts/DigitalKhattV2.otf`
- Create: `tool/mushaf/build_qpc_v4_script.dart`
- Create: `tool/mushaf/validate_mushaf_assets.dart`
- Create: `test/tool/mushaf/build_qpc_v4_script_test.dart`
- Create: `test/tool/mushaf/validate_mushaf_assets_test.dart`
- Modify: `pubspec.yaml`

**Interfaces:**
- Consumes: the two user-supplied QUL layout databases, Quran API/Quran Foundation V4 glyph response shape.
- Produces:
  - `assets/mushaf/layouts/qpc-v4-tajweed-15-lines.sqlite`
  - `assets/mushaf/layouts/digital-khatt-15-lines.sqlite`
  - `assets/mushaf/scripts/qpc-v4-words.sqlite`
  - script schema:
    ```sql
    CREATE TABLE words (
      word_index INTEGER PRIMARY KEY,
      ayah_key TEXT,
      word_position INTEGER,
      char_type TEXT NOT NULL,
      page_number INTEGER NOT NULL,
      line_number INTEGER,
      display TEXT NOT NULL,
      unicode_fallback TEXT
    );
    CREATE TABLE metadata (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
    ```
  - `MushafAssetValidationResult validateMushafAssets(...)` in the tool.

- [ ] **Step 1: Write failing generator tests**

Create tests that use a tiny fake Quran API payload and assert the builder assigns **local sequential** `word_index` values independent of remote `id`.

```dart
test('assigns sequential local word indexes including end tokens', () {
  final rows = buildRows([
    FakeVerse('2:1', page: 2, words: [
      FakeWord(id: 11, position: 1, type: 'word', codeV2: 'A'),
      FakeWord(id: 12, position: 2, type: 'end', codeV2: 'B'),
    ]),
    FakeVerse('2:2', page: 2, words: [
      FakeWord(id: 1195, position: 1, type: 'word', codeV2: 'C'),
    ]),
  ]);

  expect(rows.map((row) => row.wordIndex), [1, 2, 3]);
  expect(rows.map((row) => row.remoteId), [11, 12, 1195]);
});
```

Also add:

```dart
test('preserves word and end token counts', () {
  final rows = buildRows(_fixture);
  expect(rows.where((row) => row.charType == 'word'), hasLength(2));
  expect(rows.where((row) => row.charType == 'end'), hasLength(1));
});
```

- [ ] **Step 2: Run the generator tests and verify RED**

Run:

```bash
flutter test test/tool/mushaf/build_qpc_v4_script_test.dart
```

Expected: FAIL because `buildRows` / generator types do not exist.

- [ ] **Step 3: Implement the minimal QPC V4 build tool**

Implement a small parser/model in `build_qpc_v4_script.dart` that:

- requests chapters 1–114 with:
  - `words=true`
  - `word_fields=code_v2,text_qpc_hafs`
  - `mushaf=19`
- walks verses and tokens in canonical Quran order
- assigns `word_index = 1,2,3...`
- stores `word_position = null` for non-word interaction tokens if needed
- stores `char_type_name`
- stores `code_v2` as `display`
- stores `text_qpc_hafs` as `unicode_fallback`
- writes metadata keys for source, generated-at version string, token counts, and SHA-256 of the output payload source description.

Core pure function:

```dart
List<QpcV4BuildRow> buildRows(List<QpcV4VerseInput> verses) {
  var next = 1;
  return [
    for (final verse in verses)
      for (final word in verse.words)
        QpcV4BuildRow(
          wordIndex: next++,
          remoteId: word.id,
          ayahKey: verse.verseKey,
          wordPosition: word.charType == 'word' ? word.position : null,
          charType: word.charType,
          pageNumber: word.pageNumber ?? verse.pageNumber,
          lineNumber: word.lineNumber,
          display: word.codeV2,
          unicodeFallback: word.textQpcHafs,
        ),
  ];
}
```

- [ ] **Step 4: Add failing layout-validator tests**

Use temporary SQLite fixtures and assert:

```dart
test('accepts a 604 page 15 line layout with known line types', () async {
  final result = await validateLayout(fixturePath);
  expect(result.pageCount, 604);
  expect(result.linesPerPage, 15);
  expect(result.lineTypes, containsAll(['ayah', 'basmallah', 'surah_name']));
});
```

and:

```dart
test('rejects a layout missing page 604', () async {
  expect(() => validateLayout(brokenPath), throwsA(isA<FormatException>()));
});
```

- [ ] **Step 5: Run validator tests and verify RED**

Run:

```bash
flutter test test/tool/mushaf/validate_mushaf_assets_test.dart
```

Expected: FAIL because validator functions do not exist.

- [ ] **Step 6: Implement asset validator**

Validate:

- `info.number_of_pages == 604`
- `info.lines_per_page == 15`
- pages 1 and 604 exist
- `line_type` is one of `ayah|basmallah|surah_name`
- line numbers are 1–15
- `first_word_id <= last_word_id` for ayah lines
- non-ayah lines do not require word ranges.

Add QPC V4 script checks:

```dart
if (wordCount != 77429 ||
    endCount != 6236 ||
    totalCount != 83665 ||
    pageCount != 604) {
  throw const FormatException('QPC V4 script integrity check failed.');
}
```

Then join every QPC V4 ayah line's `first_word_id..last_word_id` against local `word_index`; reject any missing range.

- [ ] **Step 7: Materialize authoritative assets into the repo**

Copy the uploaded layout DBs into the exact asset paths above.

Generate the QPC V4 script SQLite using the authenticated project tool path when credentials are available; otherwise use the verified public Quran API only for the build artifact and retain the same deterministic row-building code.

Download the exact DigitalKhattV2 font:

```text
https://static-cdn.tarteel.ai/qul/fonts/dk/DigitalKhattV2.otf
```

Verify its known probe checksum before committing:

```text
0935c48269a57c9808e52dfae47864c189396452901c689977156036a72dd217
```

- [ ] **Step 8: Register assets in `pubspec.yaml`**

Add:

```yaml
  webview_flutter: ^4.13.1
```

and assets:

```yaml
    - assets/mushaf/layouts/
    - assets/mushaf/scripts/
    - assets/mushaf/renderer/
```

Register Digital Khatt:

```yaml
    - family: DigitalKhattV2
      fonts:
        - asset: assets/mushaf/fonts/DigitalKhattV2.otf
```

- [ ] **Step 9: Run Task 1 verification**

Run:

```bash
flutter pub get
flutter test test/tool/mushaf
dart run tool/mushaf/validate_mushaf_assets.dart
```

Expected:
- tool tests PASS
- validator reports both layouts as 604/15
- QPC V4 script reports 77,429 word + 6,236 end = 83,665 tokens
- generated script asset remains < 5,000,000 bytes.

- [ ] **Step 10: Commit**

```bash
git add pubspec.yaml pubspec.lock assets/mushaf tool/mushaf test/tool/mushaf
git commit -m "feat: add verified mushaf assets"
```

---

### Task 2: Add persisted reading mode, variant, and palette preferences

**Files:**
- Create: `lib/features/hifz/domain/hifz_reading_mode.dart`
- Modify: `lib/features/settings/domain/app_preferences.dart`
- Modify: `lib/features/settings/application/app_preferences_controller.dart`
- Modify: `lib/features/settings/data/user_database_app_preferences_repository.dart`
- Modify: `test/features/settings/domain/app_preferences_test.dart`
- Modify: `test/features/settings/application/app_preferences_controller_test.dart`
- Modify: `test/features/settings/data/user_database_app_preferences_repository_test.dart`

**Interfaces:**
- Produces:
  ```dart
  enum HifzReadingMode { regular, mushaf }
  enum HifzMushafVariant { qpcV4Tajweed, digitalKhattV2 }
  enum HifzMushafPalette { light, sepia, dark, black, p1, p2, p3, p4, p5, p6 }

  extension HifzMushafPaletteRules on HifzMushafPalette {
    bool supports(HifzMushafVariant variant);
  }
  ```
- Adds to `AppPreferences`:
  `hifzReadingMode`, `hifzMushafVariant`, `hifzMushafPalette`.
- Adds controller methods:
  `setHifzReadingMode`, `setHifzMushafVariant`, `setHifzMushafPalette`.
- Produces Riverpod providers:
  `hifzReadingModeProvider`, `hifzMushafVariantProvider`, `hifzMushafPaletteProvider`, `effectiveHifzMushafPaletteProvider`.

- [ ] **Step 1: Write failing domain tests**

```dart
test('regular is the default reading mode', () {
  expect(
    const AppPreferences.defaults().hifzReadingMode,
    HifzReadingMode.regular,
  );
});

test('P palettes are not supported by Digital Khatt', () {
  expect(HifzMushafPalette.p4.supports(HifzMushafVariant.digitalKhattV2), false);
  expect(HifzMushafPalette.sepia.supports(HifzMushafVariant.digitalKhattV2), true);
});
```

- [ ] **Step 2: Run and verify RED**

Run:

```bash
flutter test test/features/settings/domain/app_preferences_test.dart
```

Expected: FAIL on missing types/properties.

- [ ] **Step 3: Implement enums and preference fields**

Use exact defaults:

```dart
hifzReadingMode = HifzReadingMode.regular,
hifzMushafVariant = HifzMushafVariant.qpcV4Tajweed,
hifzMushafPalette = HifzMushafPalette.light,
```

Do not remove or change `HifzLayoutMode`.

- [ ] **Step 4: Write failing persistence tests**

Persist keys:

```dart
static const hifzReadingModeKey = 'hifz_reading_mode_v1';
static const hifzMushafVariantKey = 'hifz_mushaf_variant_v1';
static const hifzMushafPaletteKey = 'hifz_mushaf_palette_v1';
```

Tests:

```dart
test('round trips Mushaf mode and QPC palette', () async {
  await repository.save(
    const AppPreferences.defaults().copyWith(
      hifzReadingMode: HifzReadingMode.mushaf,
      hifzMushafVariant: HifzMushafVariant.qpcV4Tajweed,
      hifzMushafPalette: HifzMushafPalette.p6,
    ),
  );
  final restored = await repository.load();
  expect(restored.hifzReadingMode, HifzReadingMode.mushaf);
  expect(restored.hifzMushafPalette, HifzMushafPalette.p6);
});
```

Add the Review Focus regression:

```dart
test('effective palette normalizes unsupported Digital Khatt P palette', () {
  expect(
    effectivePalette(
      HifzMushafVariant.digitalKhattV2,
      HifzMushafPalette.p6,
    ),
    HifzMushafPalette.light,
  );
  // Stored QPC preference remains p6; only effective palette changes.
});
```

- [ ] **Step 5: Run and verify RED**

Run:

```bash
flutter test test/features/settings/data/user_database_app_preferences_repository_test.dart test/features/settings/application/app_preferences_controller_test.dart
```

Expected: FAIL because keys/controller/provider methods do not exist.

- [ ] **Step 6: Implement repository/controller/providers**

Parsing must fail closed to defaults:

```dart
T _enumOr<T extends Enum>(Iterable<T> values, String? raw, T fallback) =>
    values.cast<T>().firstWhere(
      (value) => value.name == raw,
      orElse: () => fallback,
    );
```

Keep saved palette independent of variant. Normalize only in `effectiveHifzMushafPaletteProvider`.

- [ ] **Step 7: Run Task 2 tests**

```bash
flutter test test/features/settings/domain/app_preferences_test.dart test/features/settings/application/app_preferences_controller_test.dart test/features/settings/data/user_database_app_preferences_repository_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/hifz/domain/hifz_reading_mode.dart lib/features/settings test/features/settings
git commit -m "feat: persist hifz reading mode"
```

---

### Task 3: Build the variant-neutral Mushaf page repository

**Files:**
- Create: `lib/features/hifz/domain/hifz_mushaf_page.dart`
- Create: `lib/features/hifz/domain/hifz_mushaf_page_repository.dart`
- Create: `lib/features/hifz/data/bundled_hifz_mushaf_page_repository.dart`
- Create: `test/features/hifz/data/bundled_hifz_mushaf_page_repository_test.dart`

**Interfaces:**
- Consumes: bundled layout DBs, bundled QPC V4 script DB, existing `AyahRef`.
- Produces:
  ```dart
  enum HifzMushafLineType { ayah, basmallah, surahName }
  enum HifzMushafTokenType { word, end, pause, other }

  class HifzMushafToken {
    const HifzMushafToken({
      required this.wordIndex,
      required this.type,
      required this.display,
      this.ayahKey,
      this.wordPosition,
    });
    final int wordIndex;
    final HifzMushafTokenType type;
    final String display;
    final String? ayahKey;
    final int? wordPosition;
  }

  class HifzMushafLine { ... }
  class HifzMushafPage { ... }

  abstract interface class HifzMushafPageRepository {
    Future<HifzMushafPage> loadPage({
      required HifzMushafVariant variant,
      required int page,
    });

    Future<int?> pageForAyah({
      required HifzMushafVariant variant,
      required AyahRef ayah,
    });

    Future<bool> isVariantAvailable(HifzMushafVariant variant);
  }
  ```

- [ ] **Step 1: Write failing QPC repository tests**

Assert page 2:

```dart
test('loads QPC page 2 from layout and script ranges', () async {
  final page = await repository.loadPage(
    variant: HifzMushafVariant.qpcV4Tajweed,
    page: 2,
  );

  expect(page.page, 2);
  expect(page.lines.first.type, HifzMushafLineType.surahName);
  expect(page.lines[1].type, HifzMushafLineType.basmallah);
  expect(page.lines.where((line) => line.type == HifzMushafLineType.ayah),
      isNotEmpty);
  expect(page.tokens.every((token) => token.display.isNotEmpty), true);
});
```

Also assert page range guarding 0/605.

- [ ] **Step 2: Add the word-range mismatch fail-closed test**

Create a temporary layout where an ayah line references a missing local script index:

```dart
test('fails closed when one line references a missing script token', () async {
  expect(
    () => repository.loadPage(
      variant: HifzMushafVariant.qpcV4Tajweed,
      page: 2,
    ),
    throwsA(isA<MushafDataIntegrityException>()),
  );
});
```

This is Review Focus #5.

- [ ] **Step 3: Run and verify RED**

```bash
flutter test test/features/hifz/data/bundled_hifz_mushaf_page_repository_test.dart
```

Expected: FAIL because repository/models do not exist.

- [ ] **Step 4: Implement QPC page joining**

Rules:

- load exact layout rows ordered by `line_number`
- for `ayah`, query script tokens using inclusive local `word_index` range
- preserve script order
- map `char_type` to token type
- preserve `ayah_key + word_position` on word tokens
- for `surah_name` and `basmallah`, create line models without invented token ranges
- throw `MushafDataIntegrityException` if a referenced range has gaps.

- [ ] **Step 5: Add failing `pageForAyah` tests**

```dart
test('resolves QPC ayah page from script data', () async {
  expect(
    await repository.pageForAyah(
      variant: HifzMushafVariant.qpcV4Tajweed,
      ayah: const AyahRef(surahNumber: 2, ayahNumber: 1),
    ),
    2,
  );
});
```

- [ ] **Step 6: Add Digital Khatt availability gate tests**

Digital Khatt must not claim availability until an exact script source is present:

```dart
test('Digital Khatt reports unavailable when exact script asset is absent', () async {
  expect(
    await repository.isVariantAvailable(HifzMushafVariant.digitalKhattV2),
    false,
  );
});
```

When an exact Digital Khatt word script fixture is injected, assert it becomes available and can load page 1.

The test fixture format is:

```sql
CREATE TABLE words (
  word_index INTEGER PRIMARY KEY,
  ayah_key TEXT,
  word_position INTEGER,
  char_type TEXT NOT NULL,
  display TEXT NOT NULL
);
```

- [ ] **Step 7: Implement Digital Khatt gate and repository path**

Use a dedicated asset path:

```text
assets/mushaf/scripts/digital-khatt-v2-words.sqlite
```

The production repository checks that asset/install path plus metadata validation before reporting availability.

Do not use `quran_content.sqlite.arabic` as display text.

- [ ] **Step 8: Run Task 3 tests**

```bash
flutter test test/features/hifz/data/bundled_hifz_mushaf_page_repository_test.dart
```

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/features/hifz/domain/hifz_mushaf_page.dart lib/features/hifz/domain/hifz_mushaf_page_repository.dart lib/features/hifz/data/bundled_hifz_mushaf_page_repository.dart test/features/hifz/data/bundled_hifz_mushaf_page_repository_test.dart
git commit -m "feat: add mushaf page repository"
```

---

### Task 4: Add the verified QPC V4 page-font cache

**Files:**
- Create: `lib/features/hifz/domain/mushaf_page_font_repository.dart`
- Create: `lib/features/hifz/data/qpc_v4_page_font_repository.dart`
- Create: `test/features/hifz/data/qpc_v4_page_font_repository_test.dart`

**Interfaces:**
- Produces:
  ```dart
  abstract interface class MushafPageFontRepository {
    Future<Uri> ensurePageFont(int page);
    Future<void> prefetchNeighbors(int page);
    Future<bool> isCached(int page);
  }
  ```
- QPC URL builder:
  ```dart
  Uri qpcV4FontUri(int page) => Uri.parse(
    'https://static-cdn.tarteel.ai/qul/fonts/quran_fonts/v4-tajweed/woff2/'
    'p$page.woff2?v=3.1',
  );
  ```

- [ ] **Step 1: Write failing cache tests**

Test cache hit avoids HTTP:

```dart
test('returns an existing valid cached WOFF2 without HTTP', () async {
  await file.writeAsBytes(validWoff2Bytes);
  final uri = await repository.ensurePageFont(2);
  expect(uri.toFilePath(), file.path);
  expect(client.requests, isEmpty);
});
```

Test concurrent deduplication:

```dart
test('deduplicates concurrent downloads for the same page', () async {
  await Future.wait([
    repository.ensurePageFont(2),
    repository.ensurePageFont(2),
  ]);
  expect(client.requests.where((r) => r.page == 2), hasLength(1));
});
```

- [ ] **Step 2: Add corrupt-cache Review Focus test**

```dart
test('rejects corrupt cache and atomically replaces it with valid WOFF2', () async {
  await cached.writeAsBytes([1, 2, 3]);
  client.reply(2, validWoff2Bytes);

  final uri = await repository.ensurePageFont(2);

  expect(await File.fromUri(uri).readAsBytes(), validWoff2Bytes);
  expect(await Directory(tempDir.path)
      .list()
      .where((e) => e.path.endsWith('.part'))
      .toList(), isEmpty);
});
```

Also test a failed refresh leaves a previously valid file intact.

- [ ] **Step 3: Run and verify RED**

```bash
flutter test test/features/hifz/data/qpc_v4_page_font_repository_test.dart
```

Expected: FAIL because cache repository does not exist.

- [ ] **Step 4: Implement cache**

Validate WOFF2 signature:

```dart
bool isWoff2(List<int> bytes) =>
    bytes.length >= 4 &&
    bytes[0] == 0x77 &&
    bytes[1] == 0x4F &&
    bytes[2] == 0x46 &&
    bytes[3] == 0x32;
```

Use:

- app support/cache directory
- `qpc-v4/p{page}.woff2`
- `.part` temp path
- flush + atomic rename
- in-memory `Map<int, Future<Uri>>` for concurrent dedupe
- page validation 1–604.

`prefetchNeighbors(page)` calls `ensurePageFont(page - 1)` and `page + 1` unawaited/isolated so neighbor failures do not fail current page.

- [ ] **Step 5: Run Task 4 tests**

```bash
flutter test test/features/hifz/data/qpc_v4_page_font_repository_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/hifz/domain/mushaf_page_font_repository.dart lib/features/hifz/data/qpc_v4_page_font_repository.dart test/features/hifz/data/qpc_v4_page_font_repository_test.dart
git commit -m "feat: cache qpc v4 page fonts"
```

---

### Task 5: Build the local Mushaf HTML/CSS/JS renderer

**Files:**
- Create: `assets/mushaf/renderer/index.html`
- Create: `assets/mushaf/renderer/mushaf.css`
- Create: `assets/mushaf/renderer/mushaf.js`
- Create: `lib/features/hifz/presentation/mushaf_renderer_message.dart`
- Create: `test/features/hifz/presentation/mushaf_renderer_message_test.dart`
- Create: `test/assets/mushaf_renderer_asset_test.dart`

**Interfaces:**
- Consumes: `HifzMushafPage`, a validated font encoded as a `data:font/woff2;base64,...` or `data:font/otf;base64,...` URL, and palette. The renderer never receives an app filesystem path.
- Produces WebView bridge messages:
  ```json
  {"type":"pageReady","page":2,"generation":7}
  {"type":"wordTap","ayahKey":"2:255","wordPosition":3}
  {"type":"wordLongPress","ayahKey":"2:255","wordPosition":3}
  {"type":"ayahTap","ayahKey":"2:255"}
  {"type":"rendererError","code":"FONT_LOAD","message":"..."}
  ```
- Produces Flutter commands:
  - `window.mushaf.renderPage(payload)`
  - `window.mushaf.setPalette(name)`
  - `window.mushaf.setActiveWord(ayahKey, wordPosition)`
  - `window.mushaf.setActiveAyah(ayahKey)`
  - `window.mushaf.setRange(startAyahKey, endAyahKey)`
  - `window.mushaf.clearPlaybackHighlight()`.

- [ ] **Step 1: Write failing Dart bridge parsing tests**

```dart
test('parses a valid word tap and ayah-end tap', () {
  final word = MushafRendererEvent.parse(
    '{"type":"wordTap","ayahKey":"2:255","wordPosition":3}',
  );
  final ayah = MushafRendererEvent.parse(
    '{"type":"ayahTap","ayahKey":"2:255"}',
  );
  expect(word, const MushafWordTapEvent('2:255', 3));
  expect(ayah, const MushafAyahTapEvent('2:255'));
});

test('rejects pageReady outside 1..604', () {
  expect(
    () => MushafRendererEvent.parse(
      '{"type":"pageReady","page":605,"generation":1}',
    ),
    throwsFormatException,
  );
});
```

- [ ] **Step 2: Run and verify RED**

```bash
flutter test test/features/hifz/presentation/mushaf_renderer_message_test.dart
```

Expected: FAIL because parser/event types do not exist.

- [ ] **Step 3: Implement strict bridge event parser**

Accept only known types and validate:

- ayah key regex `^[1-9][0-9]{0,2}:[1-9][0-9]{0,2}$`
- word position > 0
- page 1–604
- generation >= 0
- renderer error code/message strings with sane length caps.

- [ ] **Step 4: Write failing renderer asset tests**

Load assets as text in a unit test and assert:

```dart
expect(css, contains('@font-palette-values --Light'));
expect(css, contains('@font-palette-values --P6'));
expect(css, contains('.word.active-word'));
expect(js, contains('setActiveWord'));
expect(js, contains('data-ayah-key'));
expect(html, contains('Content-Security-Policy'));
```

Also assert the HTML CSP does not allow remote script/style/font origins, `surah_name` rendering uses `surahNNN`, Bismillah renders the canonical `﷽`, centered lines receive the centered class, and non-centered lines receive the justified class.

- [ ] **Step 5: Run and verify RED**

```bash
flutter test test/assets/mushaf_renderer_asset_test.dart
```

Expected: FAIL because renderer assets do not exist.

- [ ] **Step 6: Implement renderer assets**

`index.html` must contain:

```html
<meta
  http-equiv="Content-Security-Policy"
  content="default-src 'none'; img-src data:; style-src 'unsafe-inline'; font-src data:; script-src 'unsafe-inline';"
>
<div id="mushaf-root" dir="rtl"></div>
```

Renderer token DOM distinguishes normal words from ayah-end markers:

```html
<span
  class="word"
  data-ayah-key="2:255"
  data-word-position="3"
>...</span>
<span
  class="ayah-end"
  data-ayah-key="2:255"
>...</span>
```

Normal word click emits `wordTap`; long press emits `wordLongPress`. Ayah-end click emits `ayahTap` so the existing Hifz range selector remains separate from word playback.

Highlight CSS:

```css
.word.active-word {
  background: color-mix(in srgb, var(--active-accent) 22%, transparent);
  border-radius: .35em;
  box-shadow: 0 0 0 .08em color-mix(in srgb, var(--active-accent) 40%, transparent);
}
.word.active-ayah:not(.active-word) {
  background: color-mix(in srgb, var(--active-accent) 8%, transparent);
}
```

For QPC V4, Flutter reads the validated cached WOFF2 bytes and passes a base64 `data:font/woff2` URL; inject per-page `@font-face` and palette rules from that data URL. The palette generator must emit the QUL values below for the page-specific font family:

```css
@font-palette-values --Light {
  base-palette: 0;
  override-colors:
    0 #000000ff, 1 #A5A5A5ff, 2 #A5A5A5ff, 3 #B50000ff,
    4 #FF7B00ff, 5 #CE9E00ff, 6 #09B000ff, 7 #3F48E6ff,
    8 #2FADFFff, 9 #F40000ff, 10 #2CA4ABff, 11 #FF0080ff,
    12 #D8E9D8ff, 13 #000000ff, 14 #000000ff, 15 #A5A5A5ff,
    16 #CC9E00ff, 17 #00B000ff;
}
@font-palette-values --Dark {
  base-palette: 5;
  override-colors:
    0 #E8E8E8ff, 1 #B0B0B0ff, 2 #B0B0B0ff, 3 #FF6B6Bff,
    4 #FFA94Dff, 5 #FFD93Dff, 6 #6BCB77ff, 7 #4D96FFff,
    8 #00D9FFff, 9 #FF4D6Dff, 10 #26C6DAff, 11 #FF80ABff,
    12 #343A40ff, 13 #E8E8E8ff, 14 #E8E8E8ff, 15 #B0B0B0ff,
    16 #FFD700ff, 17 #69F0AEff;
}
@font-palette-values --Sepia {
  base-palette: 2;
  override-colors:
    0 #3D2914ff, 1 #5C4033ff, 2 #5C4033ff, 3 #B84000ff,
    4 #C65D00ff, 5 #8B6914ff, 6 #1E7B1Eff, 7 #2E4A8Fff,
    8 #0077A3ff, 9 #C41E3Aff, 10 #A32952ff, 11 #2D6A4Fff,
    12 #FFF7EAff, 13 #8B0000ff, 14 #3D2914ff, 15 #5C4033ff,
    16 #8B6508ff, 17 #1A6B1Aff;
}
@font-palette-values --Black {
  base-palette: 5;
  override-colors:
    0 #ffffffff, 1 #ffffffff, 2 #ffffffff, 3 #ffffffff,
    4 #ffffffff, 5 #ffffffff, 6 #ffffffff, 7 #ffffffff,
    8 #ffffffff, 9 #ffffffff, 10 #ffffffff, 11 #ffffffff,
    12 #ffffffff, 13 #ffffffff, 14 #ffffffff, 15 #ffffffff,
    16 #ffffffff, 17 #ffffffff, 18 #ffffffff;
}
@font-palette-values --P1 { base-palette: 1; }
@font-palette-values --P2 { base-palette: 2; }
@font-palette-values --P3 { base-palette: 3; }
@font-palette-values --P4 { base-palette: 4; }
@font-palette-values --P5 { base-palette: 5; }
@font-palette-values --P6 { base-palette: 6; }
```

Use page background `#fff` for Light/Sepia/P2/P3/P5/P6 except Sepia's `#fff7ea`; use `#343a40` for Dark, Black, P1 and P4, matching the QUL preview behavior.

For Digital Khatt, Flutter reads the bundled `DigitalKhattV2.otf` bytes and passes a base64 `data:font/otf` URL. Use one `DigitalKhattV2` face and no P1–P6 palette.

For `surah_name` rows, Flutter also passes the bundled `assets/fonts/surah-name-v4.ttf` as a data URL and the renderer writes the ligature key `surahNNN` (for example `surah002`). For `basmallah` rows, render the canonical `﷽` in a bundled Quran fallback font supplied as a data URL; never manufacture a word range for the line.

Line layout follows the database exactly: `is_centered = 1` uses centered flex content; `is_centered = 0` uses a full-width justified row. Preserve `line_number` ordering and do not reflow tokens between layout lines.

- [ ] **Step 7: Run Task 5 tests**

```bash
flutter test test/features/hifz/presentation/mushaf_renderer_message_test.dart test/assets/mushaf_renderer_asset_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add assets/mushaf/renderer lib/features/hifz/presentation/mushaf_renderer_message.dart test/features/hifz/presentation/mushaf_renderer_message_test.dart test/assets/mushaf_renderer_asset_test.dart
git commit -m "feat: add local mushaf renderer"
```

---

### Task 6: Wrap the renderer in a secure Flutter WebView

**Files:**
- Create: `lib/features/hifz/presentation/hifz_mushaf_webview.dart`
- Create: `lib/features/hifz/presentation/mushaf_webview_driver.dart`
- Create: `test/features/hifz/presentation/mushaf_webview_driver_test.dart`

**Interfaces:**
- Consumes: page JSON, local font URI, bridge events.
- Produces:
  ```dart
  abstract interface class MushafWebViewDriver {
    Future<void> loadRenderer();
    Future<void> renderPage(MushafRenderPayload payload);
    Future<void> setPalette(HifzMushafPalette palette);
    Future<void> setActiveWord(String ayahKey, int wordPosition);
    Future<void> setActiveAyah(String ayahKey);
    Future<void> setRange(String? startAyahKey, String? endAyahKey);
    Future<void> clearPlaybackHighlight();
  }
  ```

- [ ] **Step 1: Write failing command-encoding tests**

Use a fake controller/driver boundary:

```dart
test('renderPage JSON-encodes Quran text and never concatenates executable JS', () async {
  final payload = fixture(display: "x');window.evil=true;//");
  await driver.renderPage(payload);

  final js = controller.lastScript!;
  expect(js, contains('JSON.parse'));
  expect(js, isNot(contains("window.evil=true")));
});
```

The implementation should base64-encode the JSON argument or use `jsonEncode` twice so payload text cannot terminate the JS string.

- [ ] **Step 2: Add malformed bridge Review Focus tests**

```dart
test('ignores unknown bridge events without state callbacks', () {
  channel.onMessage('{"type":"openUrl","url":"https://example.com"}');
  expect(callbacks.events, isEmpty);
});

test('ignores invalid word coordinate', () {
  channel.onMessage(
    '{"type":"wordTap","ayahKey":"2:255","wordPosition":0}',
  );
  expect(callbacks.events, isEmpty);
});
```

- [ ] **Step 3: Run and verify RED**

```bash
flutter test test/features/hifz/presentation/mushaf_webview_driver_test.dart
```

Expected: FAIL because driver does not exist.

- [ ] **Step 4: Implement WebView controller wrapper**

Configure:

```dart
final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onNavigationRequest: (request) {
        final uri = Uri.tryParse(request.url);
        if (uri == null) return NavigationDecision.prevent;
        return uri.scheme == 'file' || uri.scheme == 'about'
            ? NavigationDecision.navigate
            : NavigationDecision.prevent;
      },
    ),
  )
  ..addJavaScriptChannel(
    'MushafBridge',
    onMessageReceived: _handleBridgeMessage,
  );
```

Load only the bundled local renderer with `controller.loadFlutterAsset('assets/mushaf/renderer/index.html')`.

The driver converts validated local font bytes to a base64 data URL before calling `renderPage`; no filesystem path or remote font URL is passed into JavaScript.

Do not expose a generic `evaluateJavascript(String)` API to `HifzPage`; keep all commands typed in `MushafWebViewDriver`.

- [ ] **Step 5: Run Task 6 tests**

```bash
flutter test test/features/hifz/presentation/mushaf_webview_driver_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/hifz/presentation/hifz_mushaf_webview.dart lib/features/hifz/presentation/mushaf_webview_driver.dart test/features/hifz/presentation/mushaf_webview_driver_test.dart
git commit -m "feat: add secure mushaf webview bridge"
```

---

### Task 7: Add Mushaf controller, mode selector, and appearance controls

**Files:**
- Create: `lib/features/hifz/application/hifz_mushaf_controller.dart`
- Create: `lib/features/hifz/application/hifz_mushaf_providers.dart`
- Create: `lib/features/hifz/presentation/hifz_reading_mode_selector.dart`
- Create: `lib/features/hifz/presentation/hifz_mushaf_appearance_sheet.dart`
- Create: `test/features/hifz/application/hifz_mushaf_controller_test.dart`
- Create: `test/features/hifz/presentation/hifz_reading_mode_selector_test.dart`
- Create: `test/features/hifz/presentation/hifz_mushaf_appearance_sheet_test.dart`

**Interfaces:**
- Produces:
  ```dart
  sealed class HifzMushafState {
    const HifzMushafState();
  }

  class HifzMushafReady extends HifzMushafState {
    const HifzMushafReady({
      required this.page,
      required this.palette,
      required this.generation,
      required this.fontUri,
    });
  }

  class HifzMushafUnavailable extends HifzMushafState {
    const HifzMushafUnavailable(this.reason);
  }
  ```
- Controller methods:
  ```dart
  Future<void> openPage(int page);
  Future<void> retry();
  Future<void> selectVariant(HifzMushafVariant variant);
  Future<void> setPalette(HifzMushafPalette palette);
  ```

- [ ] **Step 1: Write failing controller tests**

```dart
test('opening QPC page ensures its font then loads page data', () async {
  await controller.openPage(2);
  expect(fontRepo.ensuredPages, [2]);
  expect(pageRepo.loaded, [(HifzMushafVariant.qpcV4Tajweed, 2)]);
  expect(controller.state, isA<HifzMushafReady>());
});
```

Digital gate:

```dart
test('Digital Khatt unavailable state does not call page loader', () async {
  pageRepo.digitalAvailable = false;
  await controller.selectVariant(HifzMushafVariant.digitalKhattV2);
  expect(controller.state, isA<HifzMushafUnavailable>());
  expect(pageRepo.loaded, isEmpty);
});
```

- [ ] **Step 2: Run and verify RED**

```bash
flutter test test/features/hifz/application/hifz_mushaf_controller_test.dart
```

Expected: FAIL because controller/providers do not exist.

- [ ] **Step 3: Implement controller/providers**

QPC:
- ensure current page font
- load page
- increment `generation`
- prefetch neighbors after current page becomes ready.

Digital Khatt:
- no page-font download
- availability gate first.

- [ ] **Step 4: Write failing mode selector tests**

```dart
testWidgets('offers Regular and Mushaf without replacing existing layout mode', (tester) async {
  await tester.pumpWidget(_app(const HifzReadingModeSelector()));
  expect(find.text('Regular'), findsOneWidget);
  expect(find.text('Mushaf'), findsOneWidget);
});
```

Variant copy:
- `QPC V4 Tajweed (Preview)`
- `Digital Khatt V2`.

- [ ] **Step 5: Write failing appearance tests**

Assert:
- QPC shows Light/Sepia/Dark/Black/P1–P6.
- Digital shows only Light/Sepia/Dark/Black.
- opening Digital while saved palette is P6 visually selects Light but does not overwrite stored P6 until the user explicitly selects a Digital-compatible palette.

- [ ] **Step 6: Run UI tests and verify RED**

```bash
flutter test test/features/hifz/presentation/hifz_reading_mode_selector_test.dart test/features/hifz/presentation/hifz_mushaf_appearance_sheet_test.dart
```

Expected: FAIL because widgets do not exist.

- [ ] **Step 7: Implement selector and appearance sheet**

Use compact segmented/menu controls. Do not redesign unrelated Hifz controls.

- [ ] **Step 8: Run Task 7 tests**

```bash
flutter test test/features/hifz/application/hifz_mushaf_controller_test.dart test/features/hifz/presentation/hifz_reading_mode_selector_test.dart test/features/hifz/presentation/hifz_mushaf_appearance_sheet_test.dart
```

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/features/hifz/application/hifz_mushaf_controller.dart lib/features/hifz/application/hifz_mushaf_providers.dart lib/features/hifz/presentation/hifz_reading_mode_selector.dart lib/features/hifz/presentation/hifz_mushaf_appearance_sheet.dart test/features/hifz/application/hifz_mushaf_controller_test.dart test/features/hifz/presentation/hifz_reading_mode_selector_test.dart test/features/hifz/presentation/hifz_mushaf_appearance_sheet_test.dart
git commit -m "feat: add hifz mushaf controls"
```

---

### Task 8: Implement page view, audio word highlight, and playback page following

**Files:**
- Create: `lib/features/hifz/presentation/hifz_mushaf_page_view.dart`
- Create: `test/features/hifz/presentation/hifz_mushaf_page_view_test.dart`
- Modify: `lib/features/hifz/application/hifz_mushaf_controller.dart`
- Modify: `test/features/hifz/application/hifz_mushaf_controller_test.dart`

**Interfaces:**
- Consumes:
  - `activeAyahPlaybackKeyProvider`
  - `activeWordForAyahProvider(ayahKey)`
  - existing word-play and word-detail callbacks from `HifzPage`.
- Produces:
  ```dart
  Future<void> followPlayback({
    required String ayahKey,
    required int? wordPosition,
    required bool autoFollow,
  });
  ```

- [ ] **Step 1: Write failing page-view interaction tests**

Use a fake WebView driver widget boundary rather than a real platform WebView.

Assert:

```dart
testWidgets('active word sends exact ayah + position highlight', (tester) async {
  await tester.pumpWidget(_pageView(activeAyah: '2:255', activeWord: 3));
  expect(driver.activeWords.last, ('2:255', 3));
});
```

Assert word tap:

```dart
bridge.emit(const MushafWordTapEvent('2:255', 3));
expect(interactions.playedWord, ('2:255', 3));
```

Long press must invoke the existing word-details callback.

Assert ayah-end tap remains the range-selection gesture:

```dart
bridge.emit(const MushafAyahTapEvent('2:255'));
expect(interactions.selectedAyah, const AyahRef(surahNumber: 2, ayahNumber: 255));
```

When playback is running, the page view must ignore `ayahTap` for range mutation exactly as Regular Hifz does.

- [ ] **Step 2: Write failing page-boundary follow tests**

```dart
test('moves to active ayah page when auto-follow is enabled', () async {
  pageRepo.pageForAyahResult = 3;
  await controller.followPlayback(
    ayahKey: '2:6',
    wordPosition: 1,
    autoFollow: true,
  );
  expect(controller.currentPage, 3);
});
```

and:

```dart
test('does not force page change when auto-follow is disabled', () async {
  controller.currentPage = 2;
  pageRepo.pageForAyahResult = 3;
  await controller.followPlayback(
    ayahKey: '2:6',
    wordPosition: 1,
    autoFollow: false,
  );
  expect(controller.currentPage, 2);
});
```

- [ ] **Step 3: Add rapid-page-crossing Review Focus test**

Use delayed page 3/page 4 loads:

```dart
test('stale page-ready generation cannot restore an older playback page', () async {
  final first = controller.followPlayback(
    ayahKey: '2:6',
    wordPosition: 1,
    autoFollow: true,
  );
  final second = controller.followPlayback(
    ayahKey: '2:17',
    wordPosition: 1,
    autoFollow: true,
  );

  page4.complete();
  page3.complete();
  await Future.wait([first, second]);

  expect(controller.currentPage, 4);
  expect(controller.generation, greaterThan(0));
});
```

- [ ] **Step 4: Run and verify RED**

```bash
flutter test test/features/hifz/presentation/hifz_mushaf_page_view_test.dart test/features/hifz/application/hifz_mushaf_controller_test.dart
```

Expected: FAIL on missing page view/follow behavior.

- [ ] **Step 5: Implement single-page Mushaf view**

Use `PageView.builder` only as a gesture surface for page turns, but keep one authoritative `currentPage` in controller state.

Page turn rules:
- swipe left/right -> bounded 1–604
- ensure page before display
- show retry state on failure
- tapping blank page area toggles Hifz controls through callback.

- [ ] **Step 6: Implement playback highlight/follow**

When audio changes:
1. send `setActiveAyah`
2. if `activeWordPosition != null`, send `setActiveWord`
3. if page differs and auto-follow enabled, open target page
4. after `pageReady` for the current generation, reapply active ayah/word.

Do not use QPC API remote word IDs.

- [ ] **Step 7: Add renderer-crash recovery test**

```dart
testWidgets('renderer failure recreates once then offers Regular Hifz', (tester) async {
  final driver = FakeDriver()..failRenderCount = 2;
  await tester.pumpWidget(_pageView(driver: driver));

  await driver.emitRendererFailure();
  await tester.pump();
  expect(driver.recreateCalls, 1);

  await driver.emitRendererFailure();
  await tester.pump();
  expect(find.text('Use Regular Hifz'), findsOneWidget);
});
```

Implement one automatic renderer recreation per page-generation. A second renderer failure for the same generation shows Retry and **Use Regular Hifz**; it must not loop.

- [ ] **Step 8: Run Task 8 tests**

```bash
flutter test test/features/hifz/presentation/hifz_mushaf_page_view_test.dart test/features/hifz/application/hifz_mushaf_controller_test.dart
```

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/features/hifz/presentation/hifz_mushaf_page_view.dart lib/features/hifz/application/hifz_mushaf_controller.dart test/features/hifz/presentation/hifz_mushaf_page_view_test.dart test/features/hifz/application/hifz_mushaf_controller_test.dart
git commit -m "feat: follow hifz audio in mushaf pages"
```

---

### Task 9: Integrate Mushaf mode into HifzPage without regressing Regular Hifz

**Files:**
- Modify: `lib/features/hifz/presentation/hifz_page.dart`
- Modify: `lib/features/hifz/presentation/hifz_appearance_sheet.dart`
- Modify: `test/features/hifz/presentation/hifz_page_test.dart`
- Modify: `test/features/hifz/presentation/hifz_appearance_sheet_test.dart`

**Interfaces:**
- Consumes all previous tasks.
- Produces the final in-app Hifz flow:
  - Regular -> current `_buildContinuousReader`
  - Mushaf -> `HifzMushafPageView`.

- [ ] **Step 1: Write failing Regular-mode regression test**

Pin the current behavior before integration:

```dart
testWidgets('Regular mode keeps the existing continuous Hifz reader', (tester) async {
  await _pumpHifzPage(
    tester,
    preferences: const AppPreferences.defaults().copyWith(
      hifzReadingMode: HifzReadingMode.regular,
      hifzLayoutMode: HifzLayoutMode.fixedMushaf,
    ),
  );

  expect(find.byKey(const PageStorageKey('hifz-continuous-reader')), findsOneWidget);
  expect(find.byType(HifzMushafPageView), findsNothing);
});
```

- [ ] **Step 2: Write failing Mushaf-mode test**

```dart
testWidgets('Mushaf mode shows single-page reader and preserves Hifz controls', (tester) async {
  await _pumpHifzPage(
    tester,
    preferences: const AppPreferences.defaults().copyWith(
      hifzReadingMode: HifzReadingMode.mushaf,
    ),
  );

  expect(find.byType(HifzMushafPageView), findsOneWidget);
  expect(find.byKey(const ValueKey('hifz-top-controls')), findsOneWidget);
  expect(find.byKey(const ValueKey('hifz-bottom-controls')), findsOneWidget);
});
```

- [ ] **Step 3: Add shared-session regression**

Start an existing `HifzSessionConfig`, switch Regular -> Mushaf -> Regular, and assert:

- session `config` unchanged
- repeat step unchanged
- playback state not restarted just because view mode changed.

- [ ] **Step 4: Run and verify RED**

```bash
flutter test test/features/hifz/presentation/hifz_page_test.dart
```

Expected: new tests FAIL because mode selection is not integrated.

- [ ] **Step 5: Integrate mode selector and reader branch**

At the top controls:

```dart
HifzReadingModeSelector(
  mode: readingMode,
  variant: variant,
  digitalKhattAvailable: digitalKhattAvailable,
  onModeChanged: ...,
  onVariantChanged: ...,
)
```

Reader branch:

```dart
final reader = switch (readingMode) {
  HifzReadingMode.regular => _buildContinuousReader(...),
  HifzReadingMode.mushaf => HifzMushafPageView(...),
};
```

Keep existing Hifz session/audio controller providers exactly once; do not create mode-specific sessions.

- [ ] **Step 6: Integrate appearance entry**

Existing Hifz settings opens:
- Regular -> existing `HifzAppearanceSheet`
- Mushaf -> `HifzMushafAppearanceSheet`.

Do not remove Regular font/size/line-height controls.

- [ ] **Step 7: Run Hifz presentation tests**

```bash
flutter test test/features/hifz/presentation
```

Expected: all PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/hifz/presentation/hifz_page.dart lib/features/hifz/presentation/hifz_appearance_sheet.dart test/features/hifz/presentation/hifz_page_test.dart test/features/hifz/presentation/hifz_appearance_sheet_test.dart
git commit -m "feat: integrate mushaf hifz mode"
```

---

### Task 10: Digital Khatt exact-script activation path

**Files:**
- Create: `tool/mushaf/import_digital_khatt_script.dart`
- Create: `test/tool/mushaf/import_digital_khatt_script_test.dart`
- Modify: `lib/features/hifz/data/bundled_hifz_mushaf_page_repository.dart`
- Modify: `test/features/hifz/data/bundled_hifz_mushaf_page_repository_test.dart`
- Potential generated asset: `assets/mushaf/scripts/digital-khatt-v2-words.sqlite`

**Interfaces:**
- Consumes an exact QUL Digital Khatt V2 word-by-word source when available.
- Produces the same local sequential schema used by the Digital Khatt layout's `first_word_id..last_word_id`.

- [ ] **Step 1: Write failing importer normalization tests**

For an exact QUL word source:

```dart
test('preserves exact Digital Khatt Unicode and creates end token', () {
  final rows = importVerse(
    verseKey: '73:4',
    words: [
      const SourceWord(position: 1, text: 'أَوْ'),
      const SourceWord(position: 2, text: 'زِدْ'),
      const SourceWord(position: 7, text: '۝٤'),
    ],
  );

  expect(rows[0].display, 'أَوْ');
  expect(rows[1].display, 'زِدْ');
  expect(rows.last.charType, 'end');
});
```

The importer must never Unicode-normalize the source text in a way that changes codepoints.

- [ ] **Step 2: Run and verify RED**

```bash
flutter test test/tool/mushaf/import_digital_khatt_script_test.dart
```

Expected: FAIL because importer does not exist.

- [ ] **Step 3: Implement importer**

Accepted input is a QUL Digital Khatt V2 word-by-word SQLite/JSON export with:
- verse key
- word position
- exact text
- page metadata when present.

Assign local `word_index` in canonical token order including ayah-end token.

- [ ] **Step 4: Add exact-source parity fixture**

Use QUL public preview 73:4 as a fixed canonical fixture:

```text
أَوْ
زِدْ
عَلَيْهِ
وَرَتِّلِ
ٱلْقُرْءَانَ
تَرْتِيلًا
۝٤
```

The generated DB must reproduce these exact codepoints.

- [ ] **Step 5: Activate only if the source asset is present and validates**

If `assets/mushaf/scripts/digital-khatt-v2-words.sqlite` exists and every layout range resolves, `isVariantAvailable(digitalKhattV2)` returns true.

If it is absent or mismatched, return false with reason:

```text
Digital Khatt script data is not installed.
```

- [ ] **Step 6: Run Task 10 tests**

```bash
flutter test test/tool/mushaf/import_digital_khatt_script_test.dart test/features/hifz/data/bundled_hifz_mushaf_page_repository_test.dart
```

Expected: PASS in both states:
- no production Digital script -> unavailable
- fixture/exact script -> available.

- [ ] **Step 7: Commit**

If exact production source is available:

```bash
git add tool/mushaf/import_digital_khatt_script.dart test/tool/mushaf/import_digital_khatt_script_test.dart assets/mushaf/scripts/digital-khatt-v2-words.sqlite lib/features/hifz/data/bundled_hifz_mushaf_page_repository.dart test/features/hifz/data/bundled_hifz_mushaf_page_repository_test.dart
git commit -m "feat: enable digital khatt mushaf script"
```

If exact source is not available, commit the importer + fail-closed gate without the production script asset:

```bash
git add tool/mushaf/import_digital_khatt_script.dart test/tool/mushaf/import_digital_khatt_script_test.dart lib/features/hifz/data/bundled_hifz_mushaf_page_repository.dart test/features/hifz/data/bundled_hifz_mushaf_page_repository_test.dart
git commit -m "feat: gate digital khatt script integrity"
```

This is the only acceptable incomplete-data state; never substitute a different Quran script.

---

### Task 11: Whole-feature regression, build, and device QA

**Files:**
- Modify only if a verified regression requires a TDD fix.
- Update: `assets/mushaf/README.md` with source/provenance/checksums after final assets are fixed.

**Interfaces:**
- Consumes completed implementation.
- Produces release evidence.

- [ ] **Step 1: Write/update provenance README**

Record:
- QUL layout resource IDs/names
- exact layout SHA-256 values
- QPC V4 script generator parameters
- generated script SHA-256
- DigitalKhattV2 font URL + SHA-256
- QPC font CDN pattern
- QPC V4 Preview/proofreading caveat
- exact Digital Khatt script source status.

Do not claim licenses that source pages do not publish.

- [ ] **Step 2: Run focused Hifz suite**

```bash
flutter test test/features/hifz
```

Expected: PASS.

- [ ] **Step 3: Run Quran presentation regression**

```bash
flutter test test/features/quran/presentation
```

Expected: PASS.

- [ ] **Step 4: Run full project tests**

```bash
flutter test
```

Expected: PASS, zero failures.

- [ ] **Step 5: Run analyzer**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Verify diff hygiene**

```bash
git diff --check
git status --short
```

Expected: no whitespace errors; only intended changes.

- [ ] **Step 7: Build Android debug APK**

```bash
flutter build apk --debug
```

Expected: exit 0 and `build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 8: Install and QA on the OPPO device**

Install preserving data:

```bash
adb connect 192.168.10.9:5555
adb -s 192.168.10.9:5555 install -r build/app/outputs/flutter-apk/app-debug.apk
```

Verify **Regular Hifz**:
- current continuous behavior unchanged
- existing appearance settings unchanged
- repeat/range/audio/word details still work.

Verify **QPC V4 Tajweed (Preview)**:
- pages 1, 2, representative middle page, 604
- exactly one page at a time
- 15-line geometry where the layout has all 15 slots
- Surah/Bismillah line placement
- Light, Sepia, Dark, Black
- P1–P6
- current word highlight preserves glyph colors
- active ayah secondary highlight
- automatic page follow
- cached page works offline
- uncached page offline shows honest font-missing retry.

Verify **Digital Khatt V2**:
- if exact script asset is installed: page layout, Light/Sepia/Dark/Black, word highlight, page follow, offline behavior
- if exact script asset is not installed: mode visibly unavailable and Regular/QPC remain usable.

- [ ] **Step 9: Check runtime logs**

```bash
adb -s 192.168.10.9:5555 logcat -d | grep -E 'FATAL EXCEPTION|AndroidRuntime|Mushaf'
```

Expected: no app fatal exception.

- [ ] **Step 10: Run final full verification after any QA fixes**

```bash
flutter analyze && flutter test && flutter build apk --debug
```

Expected: all commands exit 0.

- [ ] **Step 11: Commit final provenance record**

Any product-code QA fix must already have its own RED→GREEN test and focused commit before this step. Commit only the final source/provenance record here:

```bash
git add assets/mushaf/README.md
git commit -m "docs: record mushaf asset provenance"
```

## Completion Contract

Before this plan is considered complete:

- every task was implemented RED→GREEN
- all task-specific tests pass
- Regular Hifz behavior remains intact
- QPC V4 page-by-page mode is operational
- QPC V4 word highlight follows existing audio timing
- QPC page font caching is verified, atomic, and fail-safe
- local WebView navigation/security tests pass
- Digital Khatt is either enabled with exact verified script data or explicitly unavailable without approximation
- full test/analyze/build/device QA evidence is recorded
- no unrelated branch changes are accidentally folded into Mushaf commits.
