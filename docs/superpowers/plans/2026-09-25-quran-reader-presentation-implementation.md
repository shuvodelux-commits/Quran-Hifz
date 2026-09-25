# Quran Surah and Reader Presentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the Quran Surah list and reader to match the supplied reference: calligraphic Surah names, a compact clean reader top bar, a blue Surah information card, and a white rounded Bismillah card—without changing Quran data or reader behavior.

**Architecture:** Keep Quran repositories, reader controller, audio, settings, and ayah rendering untouched. Restrict changes to presentation widgets, using theme extension roles for Quran header blue/gold and fixed decorative fonts only for Surah-name artwork; user-selected Quran fonts continue to drive ayah/Bismillah rendering where already supported.

**Tech Stack:** Flutter Material 3, Riverpod, existing Quran domain/repository/controller stack, bundled KFGQPC/AlQalam/Noto/IndoPak fonts.

**Spec:** `docs/superpowers/specs/2026-09-25-onboarding-visual-system-quran-reader-design.md`

## Global Constraints

- Quran Surah information card uses the sampled `#275F70` role for default light theme through `AppPalette.quranHeader`.
- Gold accent uses approximately `#D5A44B` through `AppPalette.goldAccent`.
- Do not alter Quran text, translations, Tajweed markup, source/authenticity rules, Bismillah policy, reader scope, audio, bookmarks, downloads, or reading-position storage.
- Do not force the decorative Surah-name font onto ayah text.
- Preserve user Quran font, Arabic size, Arabic line height, Tajweed, translation, tap-to-translation, word meaning, audio/reciter, and Hifz behavior.
- Al-Fatihah must not get a duplicate standalone Bismillah; At-Tawbah must not get one.
- All existing reader actions remain reachable.
- Keep RTL handling for Arabic and prevent clipping at normal Android text scales.

## Review Focus

- Large text scaling must not clip the decorative Arabic Surah name or app-bar title.
- Juz reader must still identify/switch the active Surah when page boundaries cross Surahs.
- Moving translation/bookmark/settings controls must not make any existing action unreachable.
- Alternate themes must use their own `AppPalette.quranHeader` instead of forcing the default blue everywhere.
- Bismillah styling must never replace canonical `BismillahText` or disable Tajweed/script selection.

---

### Task 1: Refresh Surah rows with decorative Arabic naming

**Files:**
- Modify: `lib/features/quran/presentation/widgets/quran_surah_row.dart`
- Modify: `test/features/quran/presentation/quran_surah_row_test.dart`
- Modify: `test/features/quran/presentation/quran_surah_list_page_test.dart`

**Interfaces:**
- Consumes: existing `QuranSurahSummary.nameArabic`
- Preserves: `QuranSurahRow(surah:, language:, onTap:)`

- [ ] **Step 1: Write failing font/presentation tests**

Add:

```dart
testWidgets('Arabic Surah artwork uses the fixed calligraphic face', (tester) async {
  await tester.pumpWidget(_app(
    QuranSurahRow(
      surah: surah,
      language: AppLanguage.english,
      onTap: () {},
    ),
  ));

  final arabic = tester.widget<Text>(find.text('سورة البقرة'));
  expect(
    arabic.style?.fontFamily,
    anyOf('KFGQPC Hafs Uthmanic', 'AlQalamQuranMajeed'),
  );
});
```

Keep the existing 1.8 text-scale no-overflow test and current tap/localization assertions.

- [ ] **Step 2: Run Surah-row tests to verify RED**

Run:
```bash
flutter test test/features/quran/presentation/quran_surah_row_test.dart
```

Expected: FAIL if the chosen locked face differs from current rendering or if new layout keys are absent.

- [ ] **Step 3: Implement the reference-style Arabic name treatment**

Use one bundled face after device comparison:
- preferred first: `KFGQPC Hafs Uthmanic`
- fallback decision if visual QA shows closer match: `AlQalamQuranMajeed`

Keep:
- `Directionality(textDirection: TextDirection.rtl)`
- single-line fitted rendering
- the localized English/Bangla title and revelation/verse metadata
- the compact row height target.

Do not read `quranFontProvider` here; this is Surah-name chrome, not Quran ayah text.

- [ ] **Step 4: Run Surah list/row tests**

Run:
```bash
flutter test test/features/quran/presentation/quran_surah_row_test.dart test/features/quran/presentation/quran_surah_list_page_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/quran/presentation/widgets/quran_surah_row.dart test/features/quran/presentation/quran_surah_row_test.dart test/features/quran/presentation/quran_surah_list_page_test.dart
git commit -m "style: refine Quran surah names"
```

---

### Task 2: Replace reader chrome with the compact reference top bar

**Files:**
- Create: `lib/features/quran/presentation/widgets/reader_top_bar.dart`
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Modify: `lib/features/quran/presentation/widgets/reader_surah_navigation.dart`
- Modify: `test/features/quran/presentation/quran_reader_page_test.dart`
- Modify: `test/features/quran/presentation/reader_surah_navigation_test.dart`

**Interfaces:**
- Produces: `ReaderTopBar(current:, language:, onBack:, onBookmarks:, onSettings:, onChooseSurah:)`
- Preserves: ability to choose previous/current/next/any Surah
- Preserves: bookmarks and Settings/reciter access
- Moves translation quick control into reader settings access while `SettingsPage` continues to expose `Show translation`

- [ ] **Step 1: Write failing top-bar tests**

Required shape:

```dart
expect(find.byKey(const ValueKey('reader-top-bar')), findsOneWidget);
expect(find.text('1. Al-Fatihah'), findsOneWidget);
expect(find.byTooltip('Bookmarks'), findsOneWidget);
expect(find.byTooltip('Reader settings'), findsOneWidget);
expect(find.byKey(const ValueKey('reader-surah-navigation')), findsNothing);
```

For Bangla, assert localized number/name. For Juz, assert the top bar updates to the active Surah name as loaded page changes.

- [ ] **Step 2: Write failing Surah chooser/navigation tests**

The centered title/chevron must open a Surah chooser and allow navigation:

```dart
await tester.tap(find.byKey(const ValueKey('reader-surah-title')));
await tester.pumpAndSettle();
expect(find.text('Al-Baqarah'), findsWidgets);

await tester.tap(find.text('Al-Baqarah').last);
await tester.pumpAndSettle();
expect(find.byKey(const ValueKey('ayah-2:1')), findsOneWidget);
```

Keep an explicit test that previous/next Surahs remain reachable through the chooser/navigation UI.

- [ ] **Step 3: Run reader navigation tests to verify RED**

Run:
```bash
flutter test test/features/quran/presentation/quran_reader_page_test.dart test/features/quran/presentation/reader_surah_navigation_test.dart
```

Expected: FAIL.

- [ ] **Step 4: Implement `ReaderTopBar`**

Visual rules:
- white/surface background
- 56–58 px height
- back arrow left
- centered `<number>. <localized name>` plus small chevron
- outlined book icon -> existing Bookmarks page
- outlined tune/sliders icon -> existing `SettingsPage(currentSurahNumber: ...)`
- no heavy blue strip.

All icon buttons must use 44 px touch targets and tooltips.

- [ ] **Step 5: Convert `ReaderSurahNavigation` into the chooser source**

Do not leave the old blue fixed row visible.

Reuse its labeling/navigation logic in a bottom sheet/dialog invoked by `reader-surah-title`, listing Surahs with the current one selected. The chooser calls existing `_openSurahScope`.

For Juz scope, top-bar label may include the Juz/Para context in a small secondary line if needed, but the primary title remains the active Surah.

- [ ] **Step 6: Rewire `QuranReaderPage` without changing reader state logic**

The active Surah must still be derived from:

```dart
final activeSurahNumber =
    windows[state.currentPage]?.ayahs.firstOrNull?.surahNumber ??
    windows.values.first.ayahs.first.surahNumber;
```

Feed `activeSurah` into the new fixed top bar and keep `CustomScrollView`, window loading, quick-scroll rail, audio player, and page-position logic unchanged.

- [ ] **Step 7: Verify all existing actions remain reachable**

Keep:
- Bookmarks from top bar
- Settings/reciters/translation/font/Tajweed from Settings
- Surah Play/Tafsir/Download from `ReaderSurahHeader`
- ayah play/favorite/bookmark/share/copy controls.

Update tests only when control placement changes; do not delete behavior assertions.

- [ ] **Step 8: Run focused reader tests**

Run:
```bash
flutter test test/features/quran/presentation/quran_reader_page_test.dart test/features/quran/presentation/reader_surah_navigation_test.dart
```

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/features/quran/presentation/quran_reader_page.dart lib/features/quran/presentation/widgets/reader_top_bar.dart lib/features/quran/presentation/widgets/reader_surah_navigation.dart test/features/quran/presentation/quran_reader_page_test.dart test/features/quran/presentation/reader_surah_navigation_test.dart
git commit -m "style: add compact Quran reader top bar"
```

---

### Task 3: Restyle the Surah information header card

**Files:**
- Modify: `lib/features/quran/presentation/widgets/reader_surah_header.dart`
- Modify: `test/features/quran/presentation/quran_reader_page_test.dart`

**Interfaces:**
- Consumes: `Theme.of(context).extension<AppPalette>()!.quranHeader`
- Consumes: `goldAccent`
- Preserves: `ReaderSurahHeader` callbacks `onPlay`, `onTafsir`, `onDownload`

- [ ] **Step 1: Write failing header-card tests**

Assert:
- header key still exists
- card/background uses `AppPalette.quranHeader`
- Arabic name uses fixed decorative Surah-name font
- English/Bangla metadata remains visible
- Play, Tafsir, Download are still present.

Example:

```dart
final decorated = tester.widget<Container>(
  find.byKey(const ValueKey('reader-surah-info-card')),
);
final decoration = decorated.decoration! as BoxDecoration;
expect(
  decoration.color,
  appTheme(AppThemePreference.light)
      .extension<AppPalette>()!
      .quranHeader,
);
expect(find.byTooltip('Play Surah'), findsOneWidget);
expect(find.byTooltip('Open Tafsir'), findsOneWidget);
expect(find.byTooltip('Downloads'), findsOneWidget);
```

- [ ] **Step 2: Run reader header test to verify RED**

Run:
```bash
flutter test test/features/quran/presentation/quran_reader_page_test.dart --plain-name "reader shows a localized Surah information header"
```

Expected: FAIL on new card key/style.

- [ ] **Step 3: Implement the reference card**

Replace the current neutral card layout with:
- margin `EdgeInsets.fromLTRB(12, 12, 12, 8)`
- ~12 px radius
- `palette.quranHeader` background
- left metadata column
- right calligraphic Arabic name
- white main text
- `palette.goldAccent` only for selected metadata/name emphasis
- responsive `FittedBox`/constraints to avoid Arabic clipping.

Keep action controls underneath the metadata within the same widget, using high-contrast tonal/outlined styles derived from the colored surface.

- [ ] **Step 4: Run full reader tests**

Run:
```bash
flutter test test/features/quran/presentation/quran_reader_page_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/quran/presentation/widgets/reader_surah_header.dart test/features/quran/presentation/quran_reader_page_test.dart
git commit -m "style: redesign Quran surah header card"
```

---

### Task 4: Redesign Bismillah as a clean rounded card without changing Quran rules

**Files:**
- Modify: `lib/features/quran/presentation/widgets/surah_bismillah_header.dart`
- Modify: `test/features/quran/presentation/surah_bismillah_header_test.dart`
- Run without modification unless regression found: `test/features/quran/domain/bismillah_policy_test.dart`

**Interfaces:**
- Consumes: `BismillahText.plainFor(script)`
- Consumes: `BismillahText.uthmaniTajweedMarkup`
- Consumes: `shouldShowStandaloneBismillah`
- Preserves: user `quranFontProvider`, `arabicFontSizeProvider`, `arabicLineHeightProvider`, Tajweed provider behavior

- [ ] **Step 1: Write failing card-style test**

Add:

```dart
testWidgets('Bismillah is rendered in a simple rounded surface card', (tester) async {
  await tester.pumpWidget(_app(2));
  await tester.pumpAndSettle();

  final card = tester.widget<Container>(
    find.byKey(const ValueKey('surah-bismillah-card-2')),
  );
  final decoration = card.decoration! as BoxDecoration;
  expect(decoration.borderRadius, BorderRadius.circular(11));
  expect(decoration.color, Colors.white);
  expect(find.text(BismillahText.uthmani), findsOneWidget);
});
```

Also retain the existing IndoPak font/no-synthetic-bold and Al-Fatihah/At-Tawbah tests.

- [ ] **Step 2: Run Bismillah tests to verify RED**

Run:
```bash
flutter test test/features/quran/presentation/surah_bismillah_header_test.dart
```

Expected: FAIL on missing card key/style.

- [ ] **Step 3: Implement rounded Bismillah surface**

Wrap the existing `DefaultTextStyle + QuranTajweedText` content in a white/surface container:
- key `surah-bismillah-card-$surahNumber`
- radius ~11
- centered content
- modest vertical padding
- no heavy border
- no hardcoded Arabic text
- keep current script/font/Tajweed calculations exactly.

- [ ] **Step 4: Run Bismillah and policy tests**

Run:
```bash
flutter test test/features/quran/presentation/surah_bismillah_header_test.dart test/features/quran/domain/bismillah_policy_test.dart
```

Expected: PASS.

- [ ] **Step 5: Run complete Quran presentation regression**

Run:
```bash
flutter test test/features/quran/presentation
```

Expected: PASS.

- [ ] **Step 6: Run static analysis**

Run:
```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/quran/presentation/widgets/surah_bismillah_header.dart test/features/quran/presentation/surah_bismillah_header_test.dart
git commit -m "style: redesign Quran bismillah header"
```

---

### Task 5: Whole-feature regression and real-device visual QA

**Files:**
- Modify only if a regression is proven by a failing test or visible reference drift.
- No speculative refactors.

**Interfaces:**
- Validates all three implementation plans together.

- [ ] **Step 1: Run targeted cross-feature regression**

Run:
```bash
flutter test test/features/onboarding test/app/app_theme_test.dart test/app/quran_hifz_shell_test.dart test/app/app_bootstrap_test.dart test/features/home/presentation/home_dashboard_page_test.dart test/features/quran/presentation
```

Expected: PASS.

- [ ] **Step 2: Run full suite**

Run:
```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Run analysis**

Run:
```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Build a debug APK for device QA**

Run:
```bash
flutter build apk --debug
```

Expected: build succeeds.

- [ ] **Step 5: Install/update debug APK on the connected OPPO**

Run:
```bash
adb -s 192.168.10.9:5555 install -r build/app/outputs/flutter-apk/app-debug.apk
```

Expected: `Success`.

- [ ] **Step 6: Verify onboarding visually on device**

Check:
- Islamic hero is clean, not busy
- `#27687E` primary matches supplied reference
- gold remains subtle
- Language -> Set location -> Developer message sequence works
- skip location shows “Set location” at Home top location area
- final CTA says “Start Al Quran / আল কুরআন শুরু করুন”
- relaunch after completion bypasses onboarding.

- [ ] **Step 7: Verify Quran UI visually on device**

Check:
- outline bottom navigation
- Surah list Arabic names use the chosen calligraphic face
- reader top bar matches the supplied white/clean reference
- Surah information card uses the `#275F70` role
- Bismillah is centered in a white rounded card
- no clipping at current device text scale.

- [ ] **Step 8: Functional Quran regression on device**

Confirm:
- translation show/hide
- bookmarks
- settings
- reciter/audio
- Play Surah
- Tafsir
- Downloads
- ayah audio/action controls
- Tajweed
- Quran font
- Arabic font size
- Arabic line height
- last-read/resume
all still function.

- [ ] **Step 9: Final clean-tree check**

Run:
```bash
git status --short
```

Expected: no uncommitted product changes after final fixes are committed.
