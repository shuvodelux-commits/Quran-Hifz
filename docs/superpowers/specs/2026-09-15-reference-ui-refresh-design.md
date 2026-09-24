# Reference UI Refresh Design

## Goal

Refresh the existing Quran Hifz application to match the supplied Quran-app reference: a compact white interface, restrained teal interaction color, soft charcoal typography, pale blue-gray surfaces, thin borders, small outline icons, and disciplined spacing. Preserve every current feature and workflow.

## Scope and invariants

- Restyle the shared app shell and all existing presentation screens; do not add, remove, rename, or reorder product features.
- Preserve navigation, prayer calculations, tracking, Quran content, translation behavior, Tafsir, Hifz, revision, progress, bookmarks, downloads, audio playback, settings, and persistence.
- Preserve `SolaimanLipi` for Bangla and all existing Quran Arabic fonts.
- Use `Inter` for English UI text and bundle it locally so typography works offline.
- The reference palette becomes the default light theme. Existing green, dark, and women theme choices retain their hue identity but use the same typography, density, shapes, borders, icon hierarchy, and semantic color roles.
- Do not use pure black for normal text or icons. Do not use teal decoratively where it competes with actionable or selected states.
- Keep touch targets accessible even when visual spacing is compact: interactive controls remain at least 44 logical pixels in either their widget bounds or surrounding tappable area.

## Design tokens

Create centralized tokens rather than repeating literal values across screens.

### Color

Default light theme:

| Role | Value | Usage |
| --- | --- | --- |
| Accent | `#1699A3` | selected navigation, primary buttons, active states, progress |
| Accent pressed | `#117E87` | pressed/strong accent states |
| Accent tint | `#EAF7F8` | selected chips, icon wells, quiet highlighted areas |
| Canvas | `#FAFCFC` | scaffold background |
| Card | `#FFFFFF` | cards, sheets, dialogs |
| Primary text | `#273238` | headings and important values |
| Secondary text | `#77868D` | labels, metadata, inactive icons |
| Border | `#DDE8EA` | card outlines and separators |
| Disabled | `#A9B5BA` | unavailable controls |
| Error | `#B94A52` | failures and destructive/cancel emphasis only |

Use solid surfaces by default. Gradients are removed from information cards unless they communicate state that cannot be expressed more quietly. Shadows are either absent or limited to a very low-opacity, small-blur elevation.

### Typography

The theme selects the family by language: `SolaimanLipi` for Bangla and `Inter` for English. Quran Arabic rendering continues to use its dedicated text styles.

| Role | Size | Weight | Line height |
| --- | ---: | ---: | ---: |
| Screen title | 20 | 600 | 1.20 |
| Section title | 16 | 600 | 1.25 |
| Card title / emphasized value | 14 | 500 | 1.30 |
| Body | 13 | 400 | 1.40 |
| Supporting text | 12 | 400 | 1.35 |
| Caption / navigation label | 10–11 | 400–500 | 1.25 |
| Compact numeric highlight | 18 | 600 | 1.15 |

Avoid weight 700 in ordinary UI. Use hierarchy from size, spacing, and color before adding weight. Bengali and English may use the same semantic roles, but Bengali text can receive natural line height where glyphs require it. Bengali numerals inherit `SolaimanLipi`.

### Spacing, shapes, and icons

- Base spacing unit: 4 logical pixels.
- Screen horizontal padding: 12.
- Top/bottom list padding: 8–16 depending on safe-area needs.
- Adjacent section gap: 8; major section gap: 12.
- Card padding: 10–12.
- Dense row visual height: 44–48; prayer rows may use 48 to keep two time values readable.
- Card radius: 12; compact controls and chips: 8; dialogs/sheets: 16.
- Border: 1 logical pixel using the border token.
- Icons: primarily outlined, 18–22 pixels. Active icons use accent; inactive icons use secondary text. Filled icons are reserved for selected navigation or clear state changes.

## Shared components

`ThemeData` owns the color scheme, language-specific font, complete text theme, icon themes, card/dialog/input/button/list-tile styles, dividers, chips, and compact navigation styling. A small immutable theme-token extension may expose spacing-independent visual colors that Material semantic roles cannot represent cleanly.

Cards share one quiet treatment: white background, 1-pixel cool-gray outline, 12-pixel radius, and no visible shadow under normal conditions. Inputs use compact filled or outlined fields with pale tint and a clear teal focus state. Buttons use medium-weight labels without oversized padding.

The bottom navigation remains five destinations but becomes visually shorter (about 60–64 pixels), with small icons and 10–11 pixel labels. The selected state uses teal or a pale teal indicator; inactive states are gray. Existing destination selection logic remains untouched.

## Screen behavior and layout

### Home

- Reduce outer padding from 16 to 12 and collapse section gaps to 8–10.
- Keep the location header on one compact row with a small supporting Qibla line.
- Replace the large gradient date hero with a compact teal/tinted summary card. Retain Hijri, Gregorian, Bangla dates, sunrise, and sunset, but tighten columns and separators.
- Present next-prayer information as a compact white outlined card with a pale teal icon well and one emphasized countdown/value; avoid multiple competing large text values.
- Reduce prayer rows to approximately 48 pixels, with prayer name and time range clearly aligned. Active prayer receives a pale teal state rather than a high-contrast filled row.
- Keep prohibited times, fasting, and today’s dua. Use compact headers, short rows, and the existing info dialog for explanatory text.
- Keep all current tap, refresh, location, prayer-check, and navigation behavior.

### Quran list and reader

- Use a clean white Surah list with thin row separators. Each compact row presents the Surah number, English/localized name, revelation place plus verse count as small uppercase-style metadata, and the Arabic Surah name as real text on the trailing side. Render the Arabic name with the existing Quran Arabic font in teal; do not substitute an image.
- Search, filters, bookmarks, Hifz, Tafsir, and quick-scroll actions remain available with smaller controls and consistent icon treatment.
- Replace the reader’s strong gradient Surah hero and dark action bars with solid teal or pale-teal/white treatments matching the reference.
- Remove Kaaba, Masjid Nabawi, or other revelation-place vector artwork from Surah rows and the reader header. Revelation place remains available as concise text metadata, so no information is lost.
- Preserve Arabic type size controls and Quran text rendering. Only UI chrome and translation/metadata typography adopt the compact scale.
- Ayah action controls use small outlined icons, muted inactive states, and teal for the active/playback state. Translation continues to appear immediately when globally enabled, with no per-Ayah “Show translation” buttons.
- Replace the permanently numbered quick-scroll rail with a thin edge scrollbar matching the reference. Its teal thumb reflects the currently visible Quran page and remains visually quiet when idle. A normal tap must not jump unexpectedly. Pressing and holding activates scrub mode; dragging previews the mapped page number in a compact bubble and releasing commits the existing page jump. Cancelling or releasing hides the bubble. Preserve a translucent touch target of at least 44 logical pixels even though the visible rail is only 3–4 pixels wide.

### Prayer, calendar, Hifz, revision, progress, study, search, Tafsir, reciters, settings, and more

- Apply the shared text roles, 12-pixel page margins, 8–12 pixel section rhythm, white outlined cards, and restrained icon colors.
- Keep charts, Quran text, and domain-specific visualizations semantically intact; change only their surrounding UI chrome and palette where contrast remains accessible.
- Settings use compact section labels and dense controls without changing available values.
- Empty, loading, error, and disabled states use the same typography and semantic colors.

### Dialogs, sheets, and downloads

- Use white 16-radius surfaces, 12–16 pixel padding, concise 16-pixel titles, and 13-pixel body text.
- Actions wrap responsively on narrow devices. Download progress remains dismissible to background and cancellable.
- Progress uses the teal accent, while cancellation/error uses the error token.

## Accessibility and responsiveness

- Normal text must reach WCAG AA contrast against its background; large text and icons must remain readily distinguishable without relying on hue alone.
- Selected states combine color with fill, shape, or icon state.
- Text scaling must not clip at common accessibility scales. Compactness comes from removing unused space, not truncating essential text.
- Layouts must remain free of overflow at a 320-pixel logical width, including dialogs, navigation labels, cards, bilingual content, and the quick-scroll preview bubble.
- RTL Quran content and mixed Arabic/Bangla/English directionality remain unchanged.

## Testing and acceptance

- Add theme tests for exact default-light tokens, Inter English selection, SolaimanLipi Bangla selection, text roles, card shape, and navigation density.
- Add or update widget tests for compact Home spacing/prayer rows, responsive download actions, reader action styling, long-press quick scrolling, and critical secondary-screen shared styling.
- Existing functional tests must continue to pass without behavioral assertion changes unless a test directly asserts superseded visual values.
- Run `dart format`, focused widget tests during each red-green cycle, the full `flutter test` suite, `flutter analyze`, and `flutter build apk --debug`.
- Install the verified APK on the connected ADB device and inspect representative Home, Quran list/reader, settings, and download UI for overflow and density.

## Out of scope

- New product features, content sources, or navigation destinations.
- Changes to prayer-time calculation, Quran data, playback/download persistence, or translation logic.
- A pixel-for-pixel copy of the reference’s iOS device chrome or promotional artwork.
- Decorative Kaaba/Masjid Nabawi artwork in Surah presentation; Surah identity is typographic.
- Replacing Quran Arabic fonts or altering Quran text for aesthetic reasons.
