# Hifz Page + Continuous Reader Design

**Date:** 2026-09-29  
**Status:** Proposed for user review  
**Repository:** `shuvodelux-commits/Quran-Hifz`

## 1. Goal

Repair and extend the current Hifz reader without changing the approved Mushaf appearance.

The Hifz reader must keep the current QCF V2 / QCF V4 Tajweed skins, Hifz Quran-size control, line-spacing control, Tajweed control, selected-range presentation, Hifz session/repetition logic, and current compact controls. The work adds reader behavior around that existing Mushaf rather than redesigning the Mushaf itself.

The requested outcomes are:

1. eliminate the intermittent blank Hifz page that becomes visible only after a left/right swipe;
2. make Hifz playback visibly highlight the current ayah and current word;
3. automatically keep the playing ayah/word in a comfortable viewing area when audio playback moves outside the viewport;
4. allow large Hifz font sizes to use additional vertical height and scroll instead of clipping or shrinking;
5. keep the existing **Page** reader as the default;
6. add a **Continuous** reader that vertically stacks the same full Mushaf pages;
7. add an independent silent-reading auto-scroll for Continuous mode with a precise variable-speed slider;
8. stop silent-reading auto-scroll immediately when any Quran/Hifz audio starts;
9. show the current/tapped word's Bangla meaning above that exact Arabic word in the Hifz Mushaf, controlled by the existing playback-meaning preference.

## 2. Hard Non-Regression Boundary

This change must **not** redesign the current Mushaf.

Preserve exactly:

- Hifz QCF V2 and QCF V4 Tajweed choices;
- current Hifz page typography and font-size range;
- current Hifz line-spacing range;
- current Tajweed-color behavior;
- Surah header and Bismillah rules;
- ayah markers;
- selected Hifz range treatment;
- Hifz repeat-pattern/session behavior;
- hide/reveal behavior;
- normal Quran reader UI and preferences;
- normal Quran playback-follow behavior.

The implementation may change renderer plumbing only where required for readiness, height reporting, playback targeting, word-meaning overlays, and Continuous composition. Those plumbing changes must not visually alter an idle Mushaf page.

## 3. Reader Modes

Introduce a Hifz-only reader-mode preference:

```dart
enum HifzReaderMode { page, continuous }
```

### 3.1 Page mode

Page mode remains the default.

Behavior:

- horizontal left/right navigation remains;
- the current strict Mushaf page appearance remains unchanged;
- page progress remains canonical to the selected Surah page range;
- if enlarged Quran text makes a logical page taller than the available reader viewport, that logical page is vertically scrollable;
- font size must never be silently reduced to preserve a one-screen page;
- when audio moves to an ayah on another Mushaf page, Page mode automatically opens that page;
- once on the correct page, audio-follow adjusts vertical position only when the active ayah/word is outside the safe viewing zone;
- audio-follow must not continuously chase the word when it is already comfortably visible.

### 3.2 Continuous mode

Continuous mode vertically presents the **same complete logical Mushaf pages** in canonical order.

It does **not** convert the Hifz range into ayah cards and does not show only the selected ayahs. The full page content remains visible so spatial Mushaf memory is preserved.

Each logical page:

- uses the same QCF variant as Page mode;
- uses the same Hifz font size and line spacing;
- uses the same Tajweed setting;
- preserves the same Surah/Bismillah/page content;
- may grow vertically as required by the selected Hifz typography;
- has a stable page anchor for follow/navigation.

Continuous mode should lazily mount/render nearby pages instead of eagerly keeping every Surah page WebView alive.

## 4. Blank-Page Regression

The existing intermittent blank-page behavior must be treated as a root-cause bug, not hidden with a forced swipe or blind rebuild.

Observed symptom:

- Hifz page sometimes opens blank;
- swiping left/right causes the Quran page to appear.

Implementation must first establish which readiness boundary is failing. Investigation must cover at minimum:

- initial `PageView` position versus loaded `QuranPageWindow`;
- strict page/font future completion;
- WebView controller initialization;
- renderer asset load;
- `renderPage` dispatch;
- `pageReady` event delivery;
- switching pages before/while renderer initialization;
- page returning to the viewport after being built offstage.

The fix must guarantee that the initially selected logical page renders without requiring a user swipe.

If the renderer fails, existing retry/fallback behavior remains available; a genuine renderer failure must not be mistaken for the transient blank-page bug.

## 5. Strict Mushaf Renderer Extension

Reuse the current strict Mushaf renderer. Do not create a second visual Quran implementation.

The renderer needs narrowly scoped capabilities shared by Page and Continuous modes:

### 5.1 Content-height reporting

After initial render and after typography changes, the renderer reports the rendered document/page height to Flutter.

Suggested event:

```dart
MushafPageMetricsEvent({
  required int page,
  required int generation,
  required double contentHeight,
})
```

This allows Continuous mode to size each page host to its actual rendered height and avoids nested WebView vertical scrolling.

Page mode may continue to use its current internal vertical scrolling behavior where needed.

### 5.2 Playback target metrics

When active playback changes, the renderer must be able to identify the active ayah/word geometry.

Suggested event:

```dart
MushafPlaybackTargetEvent({
  required int page,
  required int generation,
  required String ayahKey,
  int? wordPosition,
  required double top,
  required double bottom,
})
```

The coordinates are page-local logical CSS pixels after the active class is applied.

This event lets Flutter make one viewport correction only when the target leaves the safe area.

### 5.3 Active word meaning

Extend playback sync so the renderer can display an optional Bangla meaning for the active word.

Suggested driver API:

```dart
Future<void> setActiveWord(
  String ayahKey,
  int wordPosition, {
  String? banglaMeaning,
})
```

The renderer anchors the popup directly above the matching `.word` element.

The popup must:

- remain visually attached to the current Arabic word;
- move to the next word as playback advances;
- use a compact, polished, high-contrast bubble;
- avoid changing line metrics or reflowing the Quran text;
- disappear when there is no active word or when the setting is disabled;
- stay within the visible page width, shifting horizontally when near an edge;
- not replace or modify any full-ayah Bangla translation elsewhere in the app.

## 6. Hifz Playback Highlighting

During Hifz ayah playback:

- the current ayah receives a clearly visible but soft highlight;
- the current word receives the stronger existing active-word highlight;
- selected-range styling remains visible without overpowering playback state;
- highlight application must not change text metrics, line height, or word spacing.

The current `QuranAudioState.ayahKey` and `activeWordPosition` remain the source of truth.

Do not create a second Hifz-only timing engine. Continue using the existing Quran audio controller and Hifz audio/session port.

## 7. Audio Follow Behavior

Audio Follow is separate from silent-reading auto-scroll.

It reuses the behavior already proven in the normal Quran reader:

1. prefer the current active word when a word position is available;
2. otherwise follow the current active ayah;
3. do nothing while the target is already inside a safe viewport;
4. only correct position when the target leaves that safe viewport;
5. use a short smooth animation rather than a jump.

Target timing should remain close to the normal Quran reader behavior:

- word correction: approximately 260 ms, `Curves.easeOutCubic`;
- ayah/page correction: approximately 320 ms, `Curves.easeOutCubic`.

### Page mode

If playback changes to another page:

1. open the required logical page;
2. wait for that page's renderer readiness;
3. position the active word/ayah if it is outside the page's safe vertical area.

### Continuous mode

Use the page GlobalKey plus page-local playback-target metrics to calculate the active target position in the outer Continuous scrollable.

Scroll only enough to bring the target into the safe viewing zone.

Audio Follow must work even when Continuous silent auto-scroll is off.

## 8. Bangla Word Meaning in Hifz

The existing global preference:

`showPlaybackBanglaWordMeaning`

continues to control whether playback word meanings are shown.

Hifz behavior:

- ayah playback: when an active word has a Bangla meaning, display the meaning bubble above that exact Arabic word;
- single-word tap playback: display the tapped/playing word's Bangla meaning above that same word;
- when the preference is off: audio/highlighting still work but no meaning bubble is shown;
- long press keeps the existing word-details behavior.

The meaning must come from the matching `QuranWord.banglaMeaning` in the loaded Quran data. Do not invent or fetch another meaning source.

## 9. Continuous Silent-Reading Auto-scroll

Continuous Auto-scroll is a **silent-reading tool**, not an audio-follow feature.

It exists only in Continuous mode.

### 9.1 Controls

Add to Hifz appearance/settings:

- **Continuous auto-scroll** — On/Off;
- **Auto-scroll speed** — a continuous slider styled like the current Hifz Quran-size slider.

The speed control must not use fixed Slow/Medium/Fast presets.

Store a normalized Hifz-only value:

```dart
double hifzAutoScrollSpeed; // 0.0 .. 1.0
```

Initial default:

`0.35`

The slider has no discrete divisions, allowing fine adjustment.

Runtime speed maps linearly to:

- minimum: **8 logical px/second**;
- maximum: **72 logical px/second**.

The UI may display a percentage value for accessibility/feedback while keeping the visual control compact.

### 9.2 Runtime rules

Auto-scroll runs only when all are true:

- Hifz reader mode is Continuous;
- user has turned Continuous auto-scroll on;
- no Quran/Hifz audio is playing;
- the reader is mounted and has scroll extent remaining.

When any audio playback starts:

- Continuous auto-scroll stops immediately;
- the auto-scroll enabled state becomes Off;
- it does **not** automatically resume after playback ends;
- the user must explicitly turn it on again for silent reading.

This follows the product rule: Continuous auto-scroll works only when the user turns it on for silent reading.

When the user manually drags the Continuous reader while auto-scroll is active:

- auto-scroll stops;
- the enabled state becomes Off;
- it does not fight the user's manual navigation.

Reaching the bottom also turns the runtime auto-scroll state Off.

### 9.3 Motion

Use frame/ticker-based scrolling rather than a single long `animateTo` call so that:

- speed changes take effect immediately;
- audio start can stop scrolling immediately;
- user drag can stop scrolling immediately;
- newly measured page heights can extend the scroll range safely.

## 10. Hifz Preferences

Add Hifz-only preferences without changing normal Quran preferences:

```dart
HifzReaderMode hifzReaderMode;          // default page
bool hifzContinuousAutoScrollEnabled;   // default false
double hifzAutoScrollSpeed;             // default 0.35
```

Persist them through the existing `AppPreferences` repository path.

Validation:

- `hifzAutoScrollSpeed` must be finite and within `0.0..1.0`;
- old installations missing the keys receive defaults;
- resetting Hifz appearance resets reader mode to Page, auto-scroll to Off, and speed to 0.35 in addition to the existing Hifz appearance defaults.

## 11. Hifz Appearance Sheet

Keep every current control unchanged and add a small reading-behavior section.

Order:

1. Mushaf skin — existing;
2. Quran size — existing;
3. Line spacing — existing;
4. Tajweed colors — existing;
5. **Reader view:** Page / Continuous;
6. when Continuous is selected:
   - Continuous auto-scroll switch;
   - precise Auto-scroll speed slider;
7. Reset Hifz appearance — existing action extended to reset the new Hifz reader preferences.

No normal Quran settings move into this sheet.

## 12. Data and Page Loading

Continuous mode must use existing Quran repositories and page windows.

Requirements:

- initial logical page remains the same page the Hifz session opens today;
- load neighboring pages incrementally as the user scrolls;
- do not load all Surah pages and all page fonts eagerly;
- preserve canonical Surah first/last page boundaries;
- a page becoming active through audio-follow must be loadable even if it is not yet mounted;
- page/font load errors retain retry/fallback behavior.

Switching Page ↔ Continuous should preserve the current logical page as the anchor.

Changing font size, line spacing, or QCF variant should preserve the current logical page and, where feasible, the currently visible ayah/word anchor.

## 13. Error Handling

- A transient renderer-readiness delay shows loading state, not a permanent blank surface.
- Renderer/font failures continue to expose retry/fallback behavior.
- Auto-scroll must fail closed: if the controller loses clients or scroll metrics are unavailable, stop auto-scroll instead of throwing.
- Playback-follow must ignore stale metrics from an old page generation.
- A missing Bangla word meaning must simply omit the popup; playback continues.

## 14. Testing Strategy

Implementation uses TDD and must protect existing Hifz behavior.

### Blank-page regression

Tests must prove:

- initial Hifz page renders after driver readiness without a swipe;
- `pageReady` for the initial generation completes the visible surface;
- stale page/generation events cannot blank or overwrite the current page;
- changing page while another renderer is initializing does not leave the new page permanently empty.

A real-device regression check is required because Android WebView lifecycle behavior cannot be fully proven by widget tests.

### Existing Page mode

Tests must prove:

- Page is the default reader mode;
- horizontal page navigation remains;
- current QCF variant/font size/line height/Tajweed settings are forwarded unchanged;
- large font can use vertical page scrolling and is not clamped/shrunk;
- switching appearance does not lose the current page.

### Continuous mode

Tests must prove:

- full logical Mushaf pages appear in vertical canonical order;
- page hosts use reported content heights;
- nearby pages are lazy loaded;
- switching modes preserves current page;
- QCF V2 and V4 use the same strict page renderer as Page mode.

### Playback

Tests must prove:

- current ayah receives playback highlight;
- current word receives stronger highlight;
- playback crossing a page boundary opens/follows the correct page;
- follow makes no movement while target is already inside the safe viewport;
- follow adjusts smoothly when target is above/below the safe viewport;
- stale playback-target metrics are ignored.

### Bangla word meaning

Tests must prove:

- active/tapped word meaning is anchored above that exact word;
- setting Off removes only the meaning popup, not audio/highlight;
- missing meaning produces no popup and no error;
- full normal Quran translation behavior is unaffected.

### Silent auto-scroll

Tests must prove:

- auto-scroll exists only in Continuous mode;
- switch defaults Off;
- slider persists exact continuous values;
- speed mapping is 8..72 logical px/sec;
- audio start turns auto-scroll Off immediately;
- playback follow still works after auto-scroll stops;
- playback end does not auto-resume silent auto-scroll;
- manual user drag turns auto-scroll Off;
- reaching the end turns it Off;
- changing speed while running changes movement rate without restarting the reader.

### Regression verification

At minimum run:

- all Hifz application/data/presentation tests;
- strict Mushaf renderer/driver tests;
- normal Quran reader playback-follow tests;
- Settings/AppPreferences persistence tests;
- `flutter analyze`;
- full `flutter test --fail-fast`;
- `git diff --check`.

Known pre-existing failures, if any, must be identified before implementation and must not be silently attributed to this work.

## 15. Real-Device Acceptance Checks

On the connected Android device verify:

1. Hifz opens repeatedly without a blank page or needing a swipe.
2. Page mode looks the same as before at the existing default size.
3. QCF V2 and QCF V4 both remain visually unchanged when idle.
4. Increasing Quran size makes tall pages vertically scrollable without clipping.
5. Continuous mode shows the same full Mushaf pages vertically.
6. Silent auto-scroll works without audio and responds smoothly to precise slider changes.
7. Starting audio immediately stops silent auto-scroll.
8. Audio does not automatically restart silent auto-scroll after playback completes.
9. Playback highlights the ayah and active word.
10. Playback moves to/follows off-screen content only when necessary.
11. Tapping a word plays it and shows its Bangla meaning directly above that word when the existing setting is On.
12. Turning the playback-meaning setting Off hides the popup but preserves playback/highlighting.
13. Page ↔ Continuous switching preserves the user's logical reading page.
14. Hifz repeat pattern, hide/reveal, Surah change, and finish/stop controls continue to work.

## 16. Non-Goals

This work does not:

- redesign the current Mushaf appearance;
- change the Hifz repetition algorithm;
- change reciter selection or audio-download architecture;
- change the normal Quran reader layout;
- add translations/tafsir to the Hifz page;
- replace QCF V2/V4 with another Quran font system;
- alter global app theme design;
- make Continuous auto-scroll an audio synchronization feature.

## 17. Completion Definition

The work is complete only when the Hifz reader can be used in both Page and Continuous modes with the existing Mushaf appearance intact, the blank-page regression is fixed at its root cause, large typography remains readable, playback highlighting/follow and Bangla word meaning work correctly, and Continuous silent-reading auto-scroll is independently user-controlled with precise speed adjustment and always stops when audio or manual scrolling begins.
