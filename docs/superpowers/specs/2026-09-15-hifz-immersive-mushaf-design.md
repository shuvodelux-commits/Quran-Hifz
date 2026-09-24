# Immersive Hifz Mushaf and Quran Surah Row Design

**Date:** 2026-09-15

## Goal

Build a distraction-free Hifz reader with selectable Free Flow and Fixed Mushaf layouts, dedicated Hifz typography controls, and redesigned Quran Surah rows without removing library features.

## Scope

This work includes:

- a corrected IndoPak Quran text source;
- a Free Flow layout with unrestricted selected sizing and wrapping;
- an optional fixed 604-page, 15-line Mushaf layout;
- an immersive Hifz screen with tap-controlled overlays;
- separate, persistent Hifz font, font-size, and line-spacing settings;
- registration of the supplied Quran font assets;
- removal of the unused Quicksand font;
- a visual redesign of only the regular Quran library's Surah rows.

Search, Surah/Juz/Bookmarks tabs, Last Read, Hifz and Tafsir actions, audio behavior, word details, bookmarks, translations, and the normal Quran reader structure remain in scope only where compatibility must be preserved. They are not otherwise redesigned.

## Source Data and Provenance

### IndoPak Quran text

Use the Quranic Universal Library (QUL) “Indopak Nastaleeq script - Word by Word” resource:

- <https://qul.tarteel.ai/resources/quran-script/59>
- upstream notice: <https://github.com/marwan/indopak-quran-text>

The upstream repository no longer carries its old data files and directs consumers to the QUL resource. Import the QUL word-by-word Unicode text into the existing canonical-content build pipeline. Replace the current `arabic_indopak` word and ayah content for both the regular Quran reader and Hifz. Preserve the app's stable `surah:ayah:position` identity model.

### Selectable Hifz layouts (final correction, 2026-09-16)

Hifz persists a layout choice independently from global Quran settings. `Free Flow` is the default: it renders the selected Surah in an RTL wrapping layout and applies the chosen font size and spacing exactly. `Fixed Mushaf` uses QUL layout ID 3, “Indopak (PDMS font),” to preserve its 604-page, 15-line composition. Fixed mode automatically fits canonical lines to the viewport and ignores the Free Flow size and spacing values; the selected Quran font still applies.

- <https://qul.tarteel.ai/mushaf_layouts/3>
- catalog: <https://qul.tarteel.ai/mushaf_layouts>

### Content integrity

The content builder must reject output unless it verifies:

- exactly 114 Surahs and 6,236 ayahs;
- exactly 604 fixed-layout pages with ordered, non-duplicated lines;
- valid first/last word locations and complete fixed-line word coverage;
- complete coverage of the imported IndoPak word records;
- representative IndoPak diacritics, including sukun and tanween, remain present after import;
- a regenerated manifest checksum matches the produced database.

The bundled Quran package carries normalized fixed-line records. The user database needs no schema migration because the layout choice and appearance values use the existing key-value settings table.

## Font Assets and Script Compatibility

Register the supplied assets with stable Flutter family aliases:

| Asset | Flutter family alias | Quran text variant |
|---|---|---|
| `PDMS-Saleem-QuranFont.ttf` | `PDMS Saleem Quran` | IndoPak |
| `Indopak-Nastaleeq.ttf` | `Indopak Nastaleeq` | IndoPak |
| `DigitalKhattIndoPak.otf` | `Quran DigitalKhatt IndoPak` | IndoPak |
| `Al-Qalam-Quran-Majeed.ttf` | `AlQalamQuranMajeed` | IndoPak |
| `Muhammadi-Quran.ttf` | `Muhammadi Quranic` | IndoPak |
| `KFGQPC-Uthmanic-Script-HAFS-Regular.otf` | `KFGQPC Hafs Uthmanic` | Uthmani |
| `NotoNaskhArabic.ttf` | `Noto Naskh Arabic` | Uthmani |

Use one shared Quran-font catalog for both readers. The regular Quran settings and the Hifz appearance sheet each expose all seven registered faces. Selecting a face also selects its compatible Quran text variant, so an IndoPak face cannot render Uthmani text or vice versa.

The two selections are persisted independently: regular-reader font changes never affect Hifz, and Hifz font changes never affect the regular reader. The regular reader defaults to `Indopak Nastaleeq`; Hifz defaults to `PDMS Saleem Quran`.

Remove `Quicksand.ttf`, `OFL-Quicksand.txt`, and the Quicksand declaration from `pubspec.yaml`. Quicksand has no code or theme consumers.

Font binaries supplied by the project owner are treated as authorized project inputs. Preserve or add their applicable license and attribution files before public distribution.

## Hifz Appearance Preferences

Hifz appearance is independent of normal Quran-reader typography. Add these persisted settings:

- Hifz font family, default `PDMS Saleem Quran`;
- Hifz layout mode, default `Free Flow`;
- requested Hifz font size;
- Hifz line spacing.

The regular reader separately persists its selected Quran face and continues to use its existing global Arabic size and line-height controls. Both selectors reuse the shared catalog, but no Hifz renderer may watch the global Quran font, size, or line-height providers.

The appearance sheet shows a live Quran preview and provides:

- a seven-option font selector;
- a Free Flow / Fixed Mushaf selector;
- font-size and line-spacing sliders shown only in Free Flow;
- a reset-to-default action.

The default font size and line spacing must visually match the supplied clean Mushaf reference at a typical phone portrait width. The line-spacing control changes vertical distance between wrapped lines.

### Free font enlargement

In Free Flow, the selected Hifz font size is the rendered size. Free Flow never silently shrinks it and does not show a screen-maximum warning. Large text wraps naturally without horizontal scrolling; vertical scrolling exposes the additional content. Fixed Mushaf instead computes its page-safe size automatically.

## Two Hifz Renderers

Free Flow renders canonical ayahs from the selected Surah in an RTL wrapping layout. Fixed Mushaf renders complete ordered line records, including all Surahs represented on that page, centered metadata lines, PDMS Bismillah, and ornamental Surah headers. Missing or invalid fixed records fall back safely to Free Flow.

Ayah markers remain attached to their verse content and use the ornament policy below. Word tap, word long-press, active-word highlighting, active-ayah highlighting, and Hifz range selection remain available when controls are visible.

The page uses a warm, low-contrast paper surface matching the reference image and adapts foreground/background contrast for supported themes. It is vertically scrollable when the selected spacing, device height, Surah headers, or Bismillah lines require more height.

In Free Flow, selected font size and spacing determine wrapped height. In Fixed Mushaf, a page-wide fit calculation preserves canonical line membership. Both surfaces scroll vertically when needed.

## Bismillah Policy

Render a centered, calligraphic Bismillah at the beginning of every Surah except Surah At-Tawbah (Surah 9). For Surahs 2–114 except 9, the standalone Bismillah uses PDMS Saleem at a dedicated display size regardless of the selected Hifz body font, has no ayah number, and is not selectable. In Al-Fatihah, Bismillah is ayah 1: render its canonical words in the flowing Quran text, keep it selectable, and attach ayah ornament 1 rather than duplicating it as a standalone header.

## Ayah Number Ornament Policy

Render every Hifz ayah number as a Quranic end-of-ayah ornament rather than a Flutter-drawn circle. Compose the marker from the Unicode end-of-ayah sign (U+06DD) and localized Arabic-Indic digits, and render it with the supplied `Al-Qalam-Quran-Majeed.ttf` through the `AlQalamQuranMajeed` Flutter family alias. The font has verified coverage for U+06DD and Arabic-Indic digits.

The ornament font remains Al Qalam regardless of the selected Hifz body font so every page has the approved numbering style. Its size scales proportionally with the selected Hifz body font size. The whole ornament remains the ayah-range tap target; selection and active playback may change its color or add a subtle highlight but must not replace the ornamental glyph with a geometric badge.

## Immersive Hifz Interaction

Entering Hifz immediately requests `SystemUiMode.immersiveSticky`. The first rendered state keeps Hifz controls visible, matching the supplied controlled-reader reference.

### Controls-visible state

The top overlay contains:

- page number;
- current Surah name;
- Juz number;
- Hifz appearance/settings action;
- a prominent Close action.

The bottom overlay contains:

- active reciter and audio playback controls when a Hifz session is active;
- Hifz setup/range controls;
- previous-page and next-page navigation.

Tapping the Quran background hides both overlays and the Android system bars. Interacting with a visible word, ayah marker, button, slider, or player control performs that control's action and does not also toggle the overlay.

### Clean state

The clean state contains only the complete Mushaf page and its small printed footer metadata, matching the supplied distraction-free reference. The app bar, controls, floating action button, status bar, and navigation bar are absent. The first tap anywhere reveals the Hifz overlays. Horizontal page swipes remain active in both states.

### Lifecycle

Closing Hifz or disposing its route restores the app's normal system-UI mode and orientation behavior. Route transitions, bottom sheets, and temporary overlays must not leave the rest of the app immersive. The back action exits Hifz safely from either visual state.

## Page Navigation and Selection

Previous/next controls and horizontal swipes navigate through Quran pages. Bounds are pages 1 and 604. Header metadata follows the selected Surah and visible page. Free Flow filters the page window to the selected Surah; Fixed Mushaf renders the full canonical page.

Hifz session ranges remain valid within a single Surah. Selecting an ayah marker belonging to a newly visible Surah updates the selection context before choosing the range endpoint. Existing audio-follow behavior may move to another page without leaving immersive mode.

## Regular Quran Surah Row Redesign

Redesign only the Surah rows. Preserve search, Surah/Juz/Bookmarks tabs, Last Read, Hifz and Tafsir actions, number quick-scroll, theming, localization, and navigation.

Each row follows the supplied Surah-list reference:

- no elevated card wrapper;
- generous vertical spacing and a clean page background;
- a pale rounded-square leading container;
- an outlined eight-point Islamic medallion drawn as vector paths;
- the localized Surah number centered in the medallion;
- a bold localized Surah name in the center column;
- localized revelation place and verse count below it;
- `سورة` plus the Arabic name on the right in a Quranic face;
- one-line truncation and semantic labels that remain usable at large system text scale.

Normalize source values such as `Makkah` and `Madinah` to the displayed forms `Makki` and `Madani` in English and their existing localized equivalents in Bangla.

## Component Boundaries

Keep responsibilities separate:

- content tooling imports and validates QUL script and layout inputs;
- Quran repository models expose canonical ayahs, words, and optional fixed lines;
- the shared Quran-font catalog owns font/script mapping, while global and Hifz preferences own separate selections;
- the Hifz renderer selects either exact-size wrapping or fitted canonical lines;
- the Hifz route owns overlay visibility and system-UI lifecycle;
- the Surah-row widget owns only row presentation.

Do not add network fetching to the runtime app. All Quran text and fonts remain bundled and available offline.

## Error Handling

- Content generation fails loudly on incomplete, mismatched, or malformed QUL inputs.
- Unsupported persisted Hifz font values fall back to PDMS Saleem.
- Unsupported persisted global Quran font values fall back to Indopak Nastaleeq, with legacy script-only preferences migrated to the matching default face.
- Invalid persisted font-size or line-spacing values are clamped to supported ranges.
- Font selection never changes Quran text to an incompatible script variant.
- System UI restoration executes during route disposal even if audio or repository operations fail.

## Testing and Acceptance

Implementation follows test-driven development. Add tests before production changes for:

- parsing and validation of QUL IndoPak records;
- canonical Quran counts and page metadata;
- preservation of representative sukun and tanween code points;
- default and persisted Hifz font, font-size, and line-spacing values;
- every shared font's compatible IndoPak/Uthmani text selection in both global and Hifz settings;
- independence of global and Hifz font, size, and line-spacing preferences;
- fallback from unknown font identifiers to PDMS Saleem;
- exact Free Flow font-size rendering at phone, landscape, and tablet widths;
- natural RTL wrapping and vertical scrolling for large sizes;
- fixed line membership and page-safe fitting in Fixed Mushaf;
- standalone Bismillah for Surahs 2–114 except 9, canonical numbered ayah 1 for Al-Fatihah, and no Bismillah for Surah 9;
- U+06DD ayah ornaments rendered in `AlQalamQuranMajeed`, with Arabic-Indic digits and proportional resizing;
- ayah ornament tap selection without a Flutter-drawn circular marker;
- selected-Surah filtering in Free Flow and complete-page rendering in Fixed Mushaf;
- controls initially visible, tap-to-hide, tap-to-show, and child-control gesture isolation;
- system bars requested immersive on entry and restored on exit;
- page swipe bounds and metadata updates;
- redesigned Surah-row number, names, revelation type, verse count, and tap navigation;
- normal Quran IndoPak rendering using `Indopak Nastaleeq`;
- absence of Quicksand from assets and `pubspec.yaml`.

Verification consists of formatting, focused tests, the full Flutter test suite, `flutter analyze`, and an Android visual pass. Compare Hifz controls-visible, Hifz clean, Bismillah, and Quran Surah-row screens against the supplied references at a representative portrait phone size. Verify diacritics using both code-point assertions and visual inspection with the matched IndoPak font.

## Out of Scope

- redesigning Juz or Bookmark rows;
- changing the normal Quran reader into the immersive Hifz layout;
- arbitrary horizontal zoom or horizontal Quran-page scrolling;
- downloading fonts or Quran content at runtime;
- changing Hifz repetition/session algorithms;
- creating a page-image renderer.
