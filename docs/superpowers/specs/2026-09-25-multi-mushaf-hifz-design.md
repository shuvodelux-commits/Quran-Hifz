# Multi-Mushaf Hifz Design

Date: 2026-09-25  
Status: Design approved in conversation; written-spec review required before implementation planning

## Intent

Add true page-by-page Mushaf reading to the existing Hifz feature without replacing or weakening the current Hifz workflow.

Hifz will support:

1. **Regular Hifz** — the current native Flutter Hifz reader, unchanged in behavior.
2. **QPC V4 Tajweed Mushaf** — QUL Layout #19, 604 pages, 15 lines/page, QPC V4 page-specific color fonts, exact page geometry, Tajweed palettes, word/audio highlighting.
3. **Digital Khatt V2 Mushaf** — the uploaded Digital Khatt 15-line layout, 604 pages, 15 lines/page, bundled DigitalKhattV2 font, exact page geometry, word/audio highlighting.

All modes share the same Hifz session, range selection, reciter, repeat sequence, playback speed, pause/resume, word interaction, and memorization state.

## Source Integrity

Quran text must never be synthesized or approximated just to make a Mushaf mode render.

### QPC V4 Tajweed

Authoritative inputs:

- QUL KFGQPC V4 layout #19
- Quran Foundation/Quran API word-level glyph data using:
  - `mushaf=19`
  - `words=true`
  - `word_fields=code_v2,text_qpc_hafs`
- QUL QPC V4 Tajweed page fonts

A probe verified QUL's public V4 preview for 73:4 and the Quran API return the same V4 glyph sequence.

The API's database `word.id` is **not** the layout's `word_index`. The bundled script generator must create a canonical local `word_index` by walking every returned token in Quran order, including ayah-end tokens.

Verified full-Quran probe:

- Quran word tokens: 77,429
- ayah-end tokens: 6,236
- local token total: 83,665
- pages represented: 1–604
- generated SQLite size: about 3.87 MB

This generated V4 script database is under the user's 5 MB bundle threshold and will be bundled with the app.

### QPC V4 proofreading state

QUL currently marks the V4 Tajweed font set as still being proofread / temporarily disabled as a published font resource.

Therefore this mode must be labeled:

**QPC V4 Tajweed (Preview)**

during development and must not be promoted as the production-default Mushaf until the source is confirmed published/proofread or the project owner explicitly accepts the verified asset set for release.

### Digital Khatt V2

Authoritative inputs:

- uploaded `digital-khatt-15-lines.db.zip`
- QUL DigitalKhattV2 OTF
- QUL Digital Khatt V2 word-by-word Quran script

The uploaded layout has:

- 604 pages
- 15 lines/page
- 9,046 layout rows
- line types: ayah, basmallah, surah_name

The DigitalKhattV2 font probe is approximately 510 KB, therefore it is bundled in the app.

The current app's verified Quran words may be used for location/audio metadata, but must not silently replace the specialized Digital Khatt display script if codepoint/rendering parity is not proven.

**Availability rule:** Digital Khatt mode is enabled only when an exact verified Digital Khatt word-script asset is installed/bundled. Until then the UI may show the mode as unavailable with a concise “script data required” state, but it must not render approximate Quran text.

## Storage Rule

The user's rule is:

> If a required static asset is under 5 MB, include it in the app.

Apply it as follows:

### Bundled

- QPC V4 Layout #19 SQLite (~236 KB uncompressed)
- Digital Khatt layout SQLite (~236 KB uncompressed)
- generated QPC V4 word/glyph SQLite (~3.87 MB)
- DigitalKhattV2 OTF (~510 KB)
- local Mushaf HTML/CSS/JavaScript renderer
- palette CSS and renderer metadata

### Download/cache

The 604 QPC V4 page-specific WOFF2 fonts are not bundled because the complete set is well above 5 MB.

For QPC V4, download only:

- current page font
- previous page font when applicable
- next page font when applicable

Downloaded fonts are cached persistently.

The WebView itself must not make remote network requests. Flutter/Dart downloads the font, validates it, places it in the Mushaf cache, then the WebView loads it locally.

For development, the upstream QUL font URL pattern is:

`.../v4-tajweed/woff2/p{page}.woff2?v=3.1`

For production, the architecture must allow the base URL to move to a project-controlled, pinned CDN/R2 mirror without renderer changes.

## Reading Mode Model

Introduce:

```dart
enum HifzReadingMode {
  regular,
  mushaf,
}

enum HifzMushafVariant {
  qpcV4Tajweed,
  digitalKhattV2,
}

enum HifzMushafPalette {
  light,
  sepia,
  dark,
  black,
  p1,
  p2,
  p3,
  p4,
  p5,
  p6,
}
```

Compatibility:

- Regular Hifz does not consume Mushaf palettes.
- Digital Khatt supports Light, Sepia, Dark, Black.
- QPC V4 supports Light, Sepia, Dark, Black, P1–P6.
- If the saved palette is incompatible with the chosen variant, normalize to Light.

Persist:

- `hifz_reading_mode_v1`
- `hifz_mushaf_variant_v1`
- `hifz_mushaf_palette_v1`

Default:

- Regular Hifz
- QPC V4 Tajweed as the last-selected Mushaf variant only after it has been explicitly chosen
- Light palette

The existing Regular Hifz appearance preferences remain untouched.

## Hifz Mode UI

The existing Hifz screen remains the single entry point.

Top controls add a compact reading-mode selector:

- **Regular**
- **Mushaf**

When Mushaf is selected, expose a secondary selector:

- **QPC V4 Tajweed (Preview)**
- **Digital Khatt V2**

The selector must not replace the existing Surah/page/range controls.

### Regular mode

Render the existing `HifzMushafSurface` / continuous reader exactly as today.

Do not change:

- current font preferences
- current scroll behavior
- current appearance sheet
- range selection
- auto-scroll
- word tap/long press
- audio controls

### Mushaf mode

Use a discrete, single-page reader.

Behavior:

- one Mushaf page is visible at a time
- page is fitted uniformly to the available viewport
- horizontal swipe changes page
- previous/next controls remain accessible
- page number remains visible when controls are shown
- tapping the page toggles Hifz controls as today
- no continuous multi-page scroll in Mushaf mode
- page range is always 1–604

## Renderer Architecture

Use a **local offline WebView** for Mushaf pages.

Reason:

QPC V4's Light/Sepia/Dark/Black/P1–P6 behavior depends on OpenType color palettes via CSS `font-palette`. Flutter's normal `TextStyle` rendering does not expose equivalent CPAL palette selection.

The WebView is only a rendering surface. Hifz state and business logic remain in Flutter.

### Bundled renderer assets

Create a focused renderer package such as:

- `assets/mushaf/renderer/index.html`
- `assets/mushaf/renderer/mushaf.css`
- `assets/mushaf/renderer/mushaf.js`

No framework is required inside the WebView.

### Flutter/WebView boundary

Flutter sends a page payload:

```json
{
  "variant": "qpcV4Tajweed",
  "page": 2,
  "palette": "sepia",
  "lines": [
    {
      "number": 1,
      "type": "surah_name",
      "centered": true,
      "surahNumber": 2,
      "tokens": []
    },
    {
      "number": 3,
      "type": "ayah",
      "centered": true,
      "tokens": [
        {
          "wordIndex": 37,
          "ayahKey": "2:1",
          "wordPosition": 1,
          "charType": "word",
          "display": "…"
        }
      ]
    }
  ]
}
```

The renderer never queries application databases itself.

### JavaScript bridge events

WebView -> Flutter:

- `pageReady(page)`
- `wordTap(ayahKey, wordPosition)`
- `wordLongPress(ayahKey, wordPosition)`
- `rendererError(code, message)`

Flutter -> WebView:

- `renderPage(payload)`
- `setPalette(palette)`
- `setActiveWord(ayahKey, wordPosition)`
- `setActiveAyah(ayahKey)`
- `setRange(startAyahKey, endAyahKey)`
- `clearPlaybackHighlight()`

Do not send audio URLs, secrets, authentication tokens, or database paths into JavaScript.

## WebView Security

The Mushaf WebView is local-content-only.

Required restrictions:

- JavaScript enabled only because the local renderer needs it.
- No arbitrary navigation.
- Block HTTP/HTTPS navigation from renderer content.
- No Content API credentials in the app/WebView.
- No user-provided HTML injection.
- Page payload values are JSON encoded, never concatenated into executable JavaScript.
- Only known bridge message types are accepted.
- External font downloading occurs in Dart, outside the WebView.

## Mushaf Page Repository

Create a variant-neutral domain model:

```dart
class HifzMushafPage {
  final int page;
  final HifzMushafVariant variant;
  final List<HifzMushafLine> lines;
}

class HifzMushafLine {
  final int lineNumber;
  final HifzMushafLineType type;
  final bool centered;
  final int? surahNumber;
  final List<HifzMushafToken> tokens;
}

class HifzMushafToken {
  final int wordIndex;
  final String? ayahKey;
  final int? wordPosition;
  final HifzMushafTokenType type;
  final String display;
}
```

Repository contract:

```dart
abstract interface class HifzMushafPageRepository {
  Future<HifzMushafPage> loadPage({
    required HifzMushafVariant variant,
    required int page,
  });

  Future<int?> pageForAyah({
    required HifzMushafVariant variant,
    required AyahRef ayah,
  });
}
```

The repository owns joining:

- layout line ranges
- script tokens
- ayah/word locations
- special Surah/Bismillah lines

The presentation layer never computes token indexes.

## Layout Database Handling

Both uploaded layout databases share the same schema:

```sql
CREATE TABLE pages (
  page_number INTEGER,
  line_number INTEGER,
  line_type TEXT,
  is_centered INTEGER,
  first_word_id INTEGER,
  last_word_id INTEGER,
  surah_number INTEGER
);
```

and:

```sql
CREATE TABLE info (
  name TEXT,
  number_of_pages INTEGER,
  lines_per_page INTEGER,
  font_name TEXT
);
```

Do not merge the two layouts into one guessed canonical table: their line-centering data differs.

Copy bundled SQLite assets into the application's support/cache directory on first access and open them read-only.

Validate at startup/install time:

- 604 pages
- maximum 15 lines/page
- expected line-type set
- expected layout name/font_name
- page 1 and page 604 exist

A validation failure disables only the affected Mushaf variant and leaves Regular Hifz usable.

## QPC V4 Script Build

Add a build tool under `tool/mushaf/`.

Algorithm:

1. Iterate chapters 1–114.
2. Fetch verses in Quran order with Mushaf #19.
3. Request `code_v2,text_qpc_hafs`.
4. Walk every returned token in verse order.
5. Assign a monotonically increasing local `word_index` starting at 1.
6. Preserve `char_type_name`; ayah-end markers are tokens too.
7. Store:
   - word_index
   - ayah_key
   - position
   - char_type
   - page_number
   - line_number
   - V4 glyph
   - text_qpc_hafs
8. Verify:
   - 77,429 word tokens
   - 6,236 end tokens
   - 83,665 total local tokens
   - 604 pages
9. Verify all Layout #19 ayah line ranges resolve to tokens.
10. Cross-check fixed samples against QUL V4 preview data.
11. Vacuum the SQLite and record SHA-256 metadata.

The committed runtime asset is the generated SQLite, not live API dependency.

Runtime Mushaf reading must work offline except when a missing QPC page font needs to be downloaded.

## Digital Khatt Script Integrity Gate

The Digital Khatt layout and font can be implemented immediately.

Display-script activation requires one of these conditions:

1. exact QUL Digital Khatt V2 word-by-word asset is bundled, or
2. an automated parity fixture proves the chosen existing verified Unicode word source is rendering-compatible for the tested canonical samples.

If neither passes, the Digital Khatt mode remains disabled.

There must be no fallback that silently changes Quran script while labeling it “Digital Khatt V2”.

## Surah Header and Bismillah

The WebView page renderer follows layout line types:

### `surah_name`

Render the appropriate Surah header/banner in that fixed line slot.

Use the app's bundled QUL Surah-name V4 artwork where compatible with the selected Mushaf presentation.

### `basmallah`

Render canonical Bismillah using the variant-compatible script/font.

Do not independently invent Bismillah visibility rules; the layout database controls the fixed Mushaf page slot.

### `ayah`

Render only the tokens included by that line's `first_word_id..last_word_id`.

## Audio and Word Highlighting

Existing Flutter audio/session logic remains authoritative.

The current audio controller exposes:

- active ayah
- `activeWordPosition`

Use:

`ayahKey + wordPosition`

as the cross-renderer identity.

### Active word

When audio reports a word:

```text
active ayah = 2:255
active word position = 3
```

Flutter sends:

```text
setActiveWord("2:255", 3)
```

The renderer highlights the element with matching data attributes.

### Highlight visual

Do **not** overwrite Tajweed foreground colors.

Use a subtle background treatment such as:

- translucent rounded background
- soft outline
- underline/highlight layer behind glyph

The Tajweed glyph's own CPAL colors remain visible.

### Active ayah

Use a lighter secondary background/outline across tokens belonging to the currently playing ayah.

### Page follow

When the active ayah belongs to another page:

1. resolve its page through the selected `HifzMushafPageRepository`
2. move to that page
3. ensure its font is cached
4. render it
5. restore active ayah/word highlight

This replaces reliance on the Regular reader's page metadata when in Mushaf mode.

### Auto-follow preference

Reuse the existing Hifz auto-follow concept.

In Mushaf mode it means:

**Follow playback page automatically**

rather than continuous auto-scroll.

## Hifz Range Interaction

Word/ayah interactions remain Flutter-owned.

- tapping an ayah/token can select Hifz range when playback is stopped
- tapping a word invokes existing word playback
- long-press invokes existing word detail sheet
- playback running disables range mutation as today
- selected range is reflected in WebView through `setRange`

Do not create a second Hifz session controller for Mushaf mode.

## Appearance

### Regular Hifz

Current appearance sheet remains unchanged.

### Mushaf Hifz

Appearance sheet adds a Mushaf-specific section.

Common:

- Light
- Sepia
- Dark
- Black

QPC V4 only:

- P1
- P2
- P3
- P4
- P5
- P6

Use QUL's documented palette definitions for V4 rather than hand-inventing colors.

Digital Khatt themes change page/surface/text presentation, not a nonexistent embedded Tajweed CPAL palette.

## Page Font Cache

Introduce:

```dart
abstract interface class MushafPageFontRepository {
  Future<Uri> ensurePageFont(int page);
  bool isCached(int page);
}
```

QPC V4 behavior:

- cache directory is app support/cache storage
- ensure current page before render
- prefetch previous and next page asynchronously
- do not fail current page because neighbor prefetch failed
- retry current-font failure explicitly
- deduplicate concurrent downloads for the same page
- validate that downloaded bytes are WOFF2 before publishing cache entry
- use atomic temp-file -> final-file rename

Cache can be cleared through a future storage-management feature; no new cache UI is required in this scope.

## Offline Behavior

### Regular Hifz

No change.

### Digital Khatt

Once its verified script asset is bundled, fully offline from first launch because layout + script + font are all under the bundle threshold.

### QPC V4

- layout and glyph data are bundled
- already visited/cached pages are fully offline
- an uncached page requires internet once for that page font
- if offline and missing the font, show a page-local “Font not downloaded” action with Retry; do not substitute another QPC font while claiming V4.

## Error Handling

A Mushaf renderer failure must never block Hifz entirely.

Fallback hierarchy:

1. retry same Mushaf page
2. allow switching Mushaf variant
3. allow returning to Regular Hifz

Never silently switch Quran script/font inside the selected Mushaf variant.

Specific errors:

- invalid layout -> disable affected variant
- script/layout join mismatch -> disable affected variant
- page font unavailable -> page-local retry/offline explanation
- WebView renderer crash -> recreate once, then offer Regular Hifz
- malformed JS bridge event -> ignore + diagnostic log
- missing Digital Khatt verified script -> keep Digital Khatt disabled

## Dependency Addition

Add `webview_flutter` for local Mushaf rendering.

Do not add a JavaScript framework.

Use existing HTTP/storage primitives where practical; add a dependency only if needed for atomic/cache behavior and covered by tests.

## Testing Strategy

Use TDD.

### Data tests

- uploaded Layout #19 opens and identifies 604/15
- uploaded Digital Khatt layout opens and identifies 604/15
- layouts remain separate and preserve their different `is_centered` values
- QPC V4 generator assigns sequential local word_index, ignoring API database IDs
- word/end counts match 77,429 / 6,236
- every QPC V4 layout ayah range resolves
- sample 73:4 glyphs match QUL preview
- invalid/missing rows fail closed

### Repository tests

- load page returns 15 fixed slots or the layout's actual line rows
- Surah/Bismillah lines contain no guessed word ranges
- pageForAyah resolves mode-specific page
- cache deduplicates simultaneous page-font fetches
- failed page-font download never replaces a valid cached file

### Mode tests

- default mode is Regular
- mode choice persists
- incompatible palette normalizes to Light
- Digital Khatt cannot activate without verified script source
- Regular Hifz does not change when Mushaf preferences change

### Renderer tests

Use a small renderer harness / WebView integration boundary to verify:

- page JSON is encoded safely
- correct font URL is local
- palette mapping
- QPC P1–P6 CSS values
- word/ayah highlight commands
- tap/long-press bridge messages
- external navigation blocked

### Hifz integration tests

- same Hifz session config is retained when switching modes
- playback active ayah highlights in Mushaf mode
- active word position maps to exact rendered token
- crossing page boundary changes page
- auto-follow disabled prevents forced page change
- repeat/range/speed/reciter controls still operate
- word tap uses existing play-word flow
- word long-press uses existing word-details flow

### Regression

- full existing Hifz suite
- Quran presentation suite
- full `flutter test`
- `flutter analyze`
- Android debug build
- OPPO real-device QA

## Device QA

On the OPPO test device verify:

### Regular

- identical behavior to current build
- no appearance/layout regression

### QPC V4

- page 1, page 2, middle page, page 604
- fixed 15-line geometry
- correct page-specific font loaded
- Surah header/Bismillah positions
- Light/Sepia/Dark/Black
- P1–P6
- Tajweed colors remain intact beneath word highlight
- word highlight follows audio
- page auto-advance works
- offline cached page works
- uncached offline page reports missing font honestly

### Digital Khatt

Once script integrity gate passes:

- exact fixed page geometry
- DigitalKhattV2 rendering
- Light/Sepia/Dark/Black
- word highlight
- page auto-advance
- fully offline behavior

## Files / Module Boundaries

Expected new units:

```text
lib/features/hifz/domain/
  hifz_reading_mode.dart
  hifz_mushaf_variant.dart
  hifz_mushaf_page.dart
  hifz_mushaf_page_repository.dart

lib/features/hifz/data/
  sqlite_hifz_mushaf_page_repository.dart
  qpc_v4_page_font_repository.dart
  hifz_mushaf_preferences_repository.dart

lib/features/hifz/application/
  hifz_mushaf_controller.dart
  hifz_mushaf_providers.dart

lib/features/hifz/presentation/
  hifz_reading_mode_selector.dart
  hifz_mushaf_page_view.dart
  hifz_mushaf_webview.dart
  hifz_mushaf_appearance_sheet.dart

assets/mushaf/
  layouts/
  scripts/
  fonts/
  renderer/

tool/mushaf/
  build_qpc_v4_script.dart
  validate_mushaf_assets.dart
```

Keep `HifzPage` as the orchestration entry point, but extract Mushaf-specific state/rendering so the file does not absorb WebView/data/cache responsibilities.

## Acceptance Boundary

This implementation is considered complete when:

1. Regular Hifz remains regression-clean.
2. QPC V4 Tajweed (Preview) works page-by-page with exact layout, generated/bundled V4 glyph data, on-demand page fonts, palettes, audio word highlighting, and page following.
3. Digital Khatt renderer/layout/font support is implemented.
4. Digital Khatt is enabled only after its exact display-script integrity gate passes.
5. All shared Hifz controls/session behavior work across modes.
6. Full tests/analyze/build/device QA pass.

If the exact Digital Khatt script asset is still unavailable at implementation time, that is **not** permission to render approximate text; the mode stays disabled while the rest of the multi-Mushaf architecture and QPC V4 mode can be completed.
