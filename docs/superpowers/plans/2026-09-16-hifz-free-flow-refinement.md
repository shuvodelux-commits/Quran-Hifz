# Hifz Free Flow Refinement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the bundled Hifz reader match the supplied IndoPak reference with continuous compact lines, centered Bismillah, scalable aligned ayah markers, and preserved word interaction.

**Architecture:** Extract row composition from the presentation widget, then render each composed row as baseline-aligned inline spans with capped spacing. Normalize Al-Fatihah's first ayah into the standalone Bismillah header, while preserving At-Tawbah as the exception. Temporarily expose only Free Flow until a downloaded fixed pack is installed by the separate Mushaf-pack plan.

**Tech Stack:** Flutter, Dart, Riverpod, flutter_test

**Spec:** `docs/superpowers/specs/2026-09-16-hifz-free-flow-downloadable-mushaf-design.md`

## Global Constraints

- Hifz typography remains independent from global Quran typography.
- Word tap/meaning/audio and word-only highlighting must remain functional.
- Blank-space tap alone toggles controls.
- At-Tawbah must not receive an inserted Bismillah.
- The workspace has no Git metadata; replace commit steps with passing verification checkpoints.

---

### Task 1: Testable Free Flow row composition

**Files:**
- Create: `lib/features/hifz/application/hifz_flow_composer.dart`
- Create: `test/features/hifz/application/hifz_flow_composer_test.dart`
- Modify: `lib/features/hifz/presentation/hifz_mushaf_surface.dart`

**Interfaces:**
- Produces: `HifzFlowComposer.compose({required List<QuranAyah> ayahs, required double availableWidth, required double minimumGap, required double maximumGap, required double Function(QuranAyah, QuranWord) measureWord, required double Function(QuranAyah) measureMarker}) -> List<HifzFlowRow>`.
- Produces: immutable `HifzFlowRow.tokens`, `HifzFlowRow.gap`, and `HifzFlowRow.isTerminal`.
- Consumes: canonical `QuranAyah` and `QuranWord` objects.

- [ ] **Step 1: Write failing composer tests**

Cover: maximum words packed without overflow, final word stays with its ayah marker, non-terminal gap is clamped to `4..12`, a large remainder never creates a huge gap, and the terminal row uses the minimum gap.

```dart
final rows = HifzFlowComposer.compose(
  ayahs: ayahs,
  availableWidth: 300,
  minimumGap: 4,
  maximumGap: 12,
  measureWord: (_, __) => 60,
  measureMarker: (_) => 30,
);
expect(rows.first.gap, inInclusiveRange(4, 12));
expect(rows.expand((row) => row.tokens).where((token) => token.isMarker), hasLength(ayahs.length));
```

- [ ] **Step 2: Verify RED**

Run: `flutter test test/features/hifz/application/hifz_flow_composer_test.dart`

Expected: FAIL because `HifzFlowComposer` does not exist.

- [ ] **Step 3: Implement immutable tokens, rows, and greedy composition**

Use measured widths plus the minimum gap for packing. When a marker does not fit, move its ayah's final word with it. Compute justified gap only when `tokenCount > 1 && !isTerminal`:

```dart
final naturalWidth = tokens.fold<double>(0, (sum, token) => sum + token.width);
final gap = ((availableWidth - naturalWidth) / (tokens.length - 1))
    .clamp(minimumGap, maximumGap)
    .toDouble();
```

- [ ] **Step 4: Replace `_FlowToken` and `_packRows` with the composer**

Keep font measurement in the presentation layer and pass measurement callbacks into the composer.

- [ ] **Step 5: Verify GREEN**

Run: `flutter test test/features/hifz/application/hifz_flow_composer_test.dart test/features/hifz/presentation/hifz_mushaf_surface_test.dart`

Expected: all tests pass with no overflow exception.

### Task 2: Continuous baseline-aligned Quran lines

**Files:**
- Create: `lib/features/hifz/presentation/hifz_flow_line.dart`
- Modify: `lib/features/hifz/presentation/hifz_mushaf_surface.dart`
- Modify: `test/features/hifz/presentation/hifz_mushaf_surface_test.dart`

**Interfaces:**
- Consumes: `HifzFlowRow`, `QuranFontPreference`, font size, line height, selected ayahs, and word callbacks.
- Produces: `HifzFlowLine`, keyed `hifz-flow-line-N`, with one bottom divider and baseline-aligned token children.

- [ ] **Step 1: Write failing widget tests**

Assert that a row uses `RichText` with inline spans rather than `Wrap`, has a bottom border, positions all word spans on a shared alphabetic baseline, and keeps the configured row gap at or below 12 logical pixels.

- [ ] **Step 2: Verify RED**

Run: `flutter test test/features/hifz/presentation/hifz_mushaf_surface_test.dart --plain-name 'flow rows render continuous baseline-aligned Quran text'`

Expected: FAIL because rows still use `Wrap`.

- [ ] **Step 3: Implement `HifzFlowLine`**

Build a `RichText(textDirection: TextDirection.rtl)` whose children alternate baseline-aligned `WidgetSpan`s and exact-width `SizedBox` gaps. Word spans use the existing `HifzMushafWord` callbacks and active-word provider; marker spans use the marker widget. Set `PlaceholderAlignment.baseline` and `TextBaseline.alphabetic` for every span.

- [ ] **Step 4: Render composed rows with `HifzFlowLine`**

Remove `WrapAlignment.spaceBetween/start` logic. Preserve the subtle row divider and current line-height-derived vertical padding.

- [ ] **Step 5: Verify GREEN and interaction behavior**

Run: `flutter test test/features/hifz/presentation/hifz_mushaf_surface_test.dart test/features/hifz/presentation/hifz_page_test.dart`

Expected: compact lines pass; word tap still highlights one word and does not reveal controls.

### Task 3: Centered standalone Bismillah at Surah boundaries

**Files:**
- Modify: `lib/features/hifz/presentation/hifz_mushaf_surface.dart`
- Modify: `test/features/hifz/presentation/hifz_mushaf_surface_test.dart`

**Interfaces:**
- Produces: `_flowAyahs()` that excludes Al-Fatihah ayah 1 after promotion to the standalone header.
- Consumes: `BismillahText.indoPak`, PDMS Saleem Quran, and `shouldShowStandaloneBismillah` for Surahs other than Al-Fatihah.

- [ ] **Step 1: Write failing Bismillah tests**

Assert: Al-Fatihah displays exactly one centered standalone Bismillah and its first ayah words do not also occur in a normal row; a normal Surah displays one header; At-Tawbah displays none.

- [ ] **Step 2: Verify RED**

Run: `flutter test test/features/hifz/presentation/hifz_mushaf_surface_test.dart --plain-name 'every applicable Surah uses one centered standalone Bismillah'`

Expected: FAIL for Al-Fatihah.

- [ ] **Step 3: Implement Bismillah promotion**

Render `_StandaloneBismillah` when `surahNumber == 1 || shouldShowStandaloneBismillah(surahNumber)`. Filter Al-Fatihah ayah 1 from the row composer. Keep Surah 9 unchanged.

- [ ] **Step 4: Match reference presentation**

Use centered PDMS Saleem Quran at `fontSize * 0.92`, horizontal padding 16, vertical padding 6, and a divider beneath the header.

- [ ] **Step 5: Verify GREEN**

Run the full Hifz surface test file and confirm no duplicated Bismillah text.

### Task 4: Scalable baseline-aligned ayah markers

**Files:**
- Modify: `lib/features/hifz/presentation/hifz_mushaf_line.dart`
- Modify: `test/features/hifz/presentation/hifz_mushaf_surface_test.dart`

**Interfaces:**
- Produces: `HifzAyahMarker` whose diameter, ornament font, numeral font, baseline, and hit target derive from `fontSize`.

- [ ] **Step 1: Write failing marker scale tests**

Pump markers at font sizes 24 and 48. Assert the larger rendered ornament and numeral are approximately twice the smaller sizes and that their centers differ by no more than one logical pixel.

- [ ] **Step 2: Verify RED**

Run the marker-specific tests; expect failure because the digit currently uses an undersized ratio.

- [ ] **Step 3: Implement proportional geometry**

Use `diameter = fontSize * .92`, ornament `fontSize * .76`, numeral `fontSize * .38`, and a centered stack without a hard-coded vertical translation. Keep the minimum tap target outside layout measurement via translucent gesture behavior rather than visual padding.

- [ ] **Step 4: Verify GREEN**

Run: `flutter test test/features/hifz/presentation/hifz_mushaf_surface_test.dart`

Expected: markers scale, align, and never overflow rows.

### Task 5: Free Flow-only transition and device acceptance

**Files:**
- Modify: `lib/features/hifz/presentation/hifz_appearance_sheet.dart`
- Modify: `lib/features/hifz/presentation/hifz_mushaf_surface.dart`
- Modify: `test/features/hifz/presentation/hifz_appearance_sheet_test.dart`
- Modify: `test/features/settings/application/app_preferences_controller_test.dart`

**Interfaces:**
- Produces: appearance sheet with font size and line spacing always visible and no shrinking Fixed Mushaf selector.

- [ ] **Step 1: Write failing appearance tests**

Assert that `Fixed Mushaf` is absent, font/spacing controls are present, and a persisted `fixedMushaf` preference renders Free Flow.

- [ ] **Step 2: Verify RED**

Run the appearance and preference tests; expect the existing Fixed Mushaf segment assertion to fail.

- [ ] **Step 3: Remove the dynamic Fixed Mushaf path from Hifz presentation**

Do not delete persisted enum decoding yet because the downloadable-pack plan migrates it. Always render the refined Free Flow surface and remove the layout segmented button.

- [ ] **Step 4: Run complete verification**

Run:

```bash
dart format --output=none --set-exit-if-changed lib tool test
flutter analyze
flutter test
flutter build apk --debug
```

Expected: formatting unchanged, no analyzer issues, all tests pass, APK builds.

- [ ] **Step 5: Install and visually verify**

Install with `adb -s 192.168.10.9:5555 install -r build/app/outputs/flutter-apk/app-debug.apk`. Verify Al-Fatihah and a later Surah at default, minimum, and maximum Hifz size; compare screenshots with the supplied reference; verify blank/word taps and unchanged control-mode coordinates.

