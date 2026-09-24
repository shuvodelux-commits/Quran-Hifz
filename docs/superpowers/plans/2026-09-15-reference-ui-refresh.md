# Reference UI Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the existing Quran Hifz app to match the approved compact white-and-teal reference while preserving every current behavior.

**Architecture:** Centralize palette, typography, shape, and component density in `ThemeData` and `AppPalette`, then remove screen-local styling that conflicts with those roles. Apply targeted compact layouts to Home and Quran surfaces, and let secondary screens inherit the shared component system. Replace the reader edge rail interaction with a tested long-press scrubber that previews and commits the existing numbered jump.

**Tech Stack:** Flutter, Dart, Material 3, Riverpod, flutter_test, locally bundled Inter/SolaimanLipi/Quran fonts

**Spec:** `docs/superpowers/specs/2026-09-15-reference-ui-refresh-design.md`

## Global Constraints

- Preserve all application features, data flows, persistence, navigation destinations, and screen actions.
- Default light colors are accent `#1699A3`, pressed accent `#117E87`, tint `#EAF7F8`, canvas `#FAFCFC`, card `#FFFFFF`, primary text `#273238`, secondary text `#77868D`, border `#DDE8EA`, disabled `#A9B5BA`, and error `#B94A52`.
- English uses locally bundled Inter; Bangla remains SolaimanLipi; Quran Arabic fonts and Quran text sizing remain unchanged.
- Avoid ordinary UI weights above 600 and reserve teal for actions, progress, and selected/active state.
- Use 12-pixel screen margins, 8-pixel normal section gaps, 10–12-pixel card padding, 12-pixel card radius, and thin borders as the default rhythm.
- Visual density must not reduce interactive hit targets below 44 logical pixels.
- No overflow at 320 logical pixels or common accessibility text scales.
- The workspace currently has no `.git` metadata; do not initialize a repository. Replace each plan commit step with a diff/status checkpoint unless Git metadata is restored by the user.

---

### Task 1: Bundle Inter and establish the shared design system

**Files:**
- Create: `assets/fonts/Inter.ttf`
- Create: `assets/fonts/OFL-Inter.txt`
- Modify: `pubspec.yaml`
- Modify: `lib/core/theme/app_palette.dart`
- Modify: `lib/app/app_theme.dart`
- Test: `test/app/app_theme_test.dart`

**Interfaces:**
- Consumes: `AppThemePreference`, `AppLanguage`
- Produces: `ThemeData appTheme(AppThemePreference preference, {AppLanguage language = AppLanguage.bangla})`
- Produces: `AppPalette` fields `readerAccent`, `accentPressed`, `accentTint`, `cardSurface`, `secondaryText`, and `subtleBorder`

- [ ] **Step 1: Extend the theme test with the approved token contract**

Add assertions equivalent to:

```dart
final light = appTheme(AppThemePreference.light);
final english = appTheme(
  AppThemePreference.light,
  language: AppLanguage.english,
);

expect(light.colorScheme.primary, const Color(0xFF1699A3));
expect(light.colorScheme.surface, const Color(0xFFFAFCFC));
expect(light.colorScheme.surfaceContainerLow, Colors.white);
expect(light.colorScheme.onSurface, const Color(0xFF273238));
expect(light.colorScheme.onSurfaceVariant, const Color(0xFF77868D));
expect(light.colorScheme.outlineVariant, const Color(0xFFDDE8EA));
expect(light.textTheme.bodyMedium?.fontFamily, 'SolaimanLipi');
expect(english.textTheme.bodyMedium?.fontFamily, 'Inter');
expect(english.textTheme.bodyMedium?.fontSize, 13);
expect(english.textTheme.titleLarge?.fontSize, 20);
expect(english.textTheme.titleLarge?.fontWeight, FontWeight.w600);
expect(light.cardTheme.elevation, 0);
expect(light.cardTheme.shape, isA<RoundedRectangleBorder>());
expect(light.navigationBarTheme.height, inInclusiveRange(60, 64));
```

- [ ] **Step 2: Run the theme test and verify RED**

Run:

```bash
flutter test test/app/app_theme_test.dart
```

Expected: failures report the old `#3AC2CA` palette, Quicksand English family, old text sizes, or missing component theme values.

- [ ] **Step 3: Add the official Inter variable font and OFL license**

Download `Inter[opsz,wght].ttf` and `OFL.txt` from the Google Fonts `ofl/inter` directory, save them under the filenames above, and register the variable range:

```yaml
- family: Inter
  fonts:
    - asset: assets/fonts/Inter.ttf
```

Use the font file's variable `wght` axis for the theme's 400, 500, and 600 requests; do not register the same asset repeatedly as fake static files.

Keep the existing SolaimanLipi, Arabic, and Quicksand assets until the full app has been verified; unused Quicksand removal is a later cleanup decision, not part of this task.

- [ ] **Step 4: Extend `AppPalette` with non-Material reference roles**

Implement constructor, fields, `copyWith`, and `lerp` for:

```dart
final Color readerAccent;
final Color accentPressed;
final Color accentTint;
final Color cardSurface;
final Color secondaryText;
final Color subtleBorder;
```

- [ ] **Step 5: Implement the complete theme contract**

Build a language-aware `TextTheme` with sizes 20/16/14/13/12/10–11 and weights 600/500/400. Configure card, dialog, app bar, navigation bar, list tile, divider, input, chip, filled button, text button, icon button, bottom sheet, progress indicator, and scrollbar themes from semantic colors. Use `VisualDensity.compact` only where the resulting hit target remains at least 44 pixels.

- [ ] **Step 6: Run the theme test and verify GREEN**

Run:

```bash
flutter test test/app/app_theme_test.dart
```

Expected: all assertions pass.

- [ ] **Step 7: Format and record the Task 1 checkpoint**

Run:

```bash
dart format lib/core/theme/app_palette.dart lib/app/app_theme.dart test/app/app_theme_test.dart
git diff -- lib/core/theme/app_palette.dart lib/app/app_theme.dart pubspec.yaml test/app/app_theme_test.dart 2>/dev/null || true
```

If Git metadata exists at execution time, commit with `style: establish compact reference design system`; otherwise retain the explicit file list as the checkpoint.

---

### Task 2: Compact the app shell and navigation

**Files:**
- Modify: `lib/app/quran_hifz_shell.dart`
- Test: `test/app/quran_hifz_shell_test.dart`

**Interfaces:**
- Consumes: the `NavigationBarThemeData` produced by Task 1
- Produces: the same five `AppDestination` selections and callbacks with compact presentation

- [ ] **Step 1: Add navigation density assertions**

After pumping `QuranHifzShell`, assert:

```dart
final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
expect(navigation.height, inInclusiveRange(60, 64));
expect(navigation.elevation, 0);
expect(find.byType(NavigationDestination), findsNWidgets(5));
```

Retain the existing destination-navigation assertions to prove behavior is unchanged.

- [ ] **Step 2: Run the shell test and verify RED**

Run:

```bash
flutter test test/app/quran_hifz_shell_test.dart
```

Expected: the explicit current height of 70 violates the compact range.

- [ ] **Step 3: Remove local shell colors and adopt themed compact navigation**

Set height to 62, keep elevation 0, allow the theme to supply background/indicator/icon/label styles, and preserve `_selectedIndex`, callbacks, labels, and destination order exactly.

- [ ] **Step 4: Run the shell test and verify GREEN**

Run the command from Step 2 and expect all destination and focus-mode tests to pass.

- [ ] **Step 5: Format and record the Task 2 checkpoint**

Run `dart format lib/app/quran_hifz_shell.dart test/app/quran_hifz_shell_test.dart`. If Git is available, commit with `style: compact primary navigation`; otherwise inspect the two-file diff.

---

### Task 3: Recompose Home into the compact dashboard

**Files:**
- Modify: `lib/features/home/presentation/home_dashboard_page.dart`
- Test: `test/features/home/presentation/home_dashboard_page_test.dart`

**Interfaces:**
- Consumes: `PrayerSchedule`, localized display helpers, prayer check callbacks, and Task 1 theme roles
- Produces: unchanged Home actions and content in a denser visual hierarchy

- [ ] **Step 1: Add failing compact-layout and semantic-color tests**

Use the existing 360×780 fixture and add keys to production widgets only where a stable public finder is needed. Assert:

```dart
final list = tester.widget<ListView>(find.byType(ListView));
expect(list.padding, const EdgeInsets.fromLTRB(12, 8, 12, 16));

final fajrRow = tester.getSize(find.byKey(const ValueKey('prayer-row-Fajr')));
expect(fajrRow.height, inInclusiveRange(44, 50));

final hero = tester.widget<Container>(
  find.byKey(const ValueKey('home-date-summary')),
);
final decoration = hero.decoration! as BoxDecoration;
expect(decoration.gradient, isNull);
expect(decoration.borderRadius, BorderRadius.circular(12));
```

Keep assertions for location, next prayer, full prayer ranges, toggling, prohibited-time dialog, fasting, and dua.

- [ ] **Step 2: Run the Home test and verify RED**

Run:

```bash
flutter test test/features/home/presentation/home_dashboard_page_test.dart
```

Expected: current list padding, 58-pixel rows, gradient hero, or missing keys fail.

- [ ] **Step 3: Apply the compact Home composition**

Change the list padding to 12/8/12/16 and gaps to 8–10. Convert `_DateHero` to a solid accent or tint card with 12 radius, no prominent shadow, 10–12 padding, smaller 18–20 icons, and reference text roles. Convert `_NextPrayerCard`, `_Panel`, prohibited times, fasting, and dua to white outlined surfaces using theme colors rather than hard-coded dark/blue values.

Set `_PrayerRow` to a 48-pixel visual row with 14-pixel name/value typography and a pale-teal active fill. Keep the whole row tappable at 48 pixels and preserve sunrise non-interactivity and prayer completion behavior.

- [ ] **Step 4: Remove conflicting Home literals**

Replace hard-coded `#25898E`, `#2A2D38`, `#78908B`, and `#71827E` with `colorScheme`/`AppPalette` roles. Replace ordinary 600/700 weights with the approved 400/500 roles while retaining 600 only for the most important compact numeric value.

- [ ] **Step 5: Run the Home test and verify GREEN**

Run the command from Step 2. Also run at 320×700 inside the test or a dedicated test and assert `tester.takeException()` is null.

- [ ] **Step 6: Format and record the Task 3 checkpoint**

Run `dart format` on the production and test files. If Git is available, commit with `style: compact home dashboard`; otherwise inspect the two-file diff.

---

### Task 4: Implement the reference edge scrollbar interaction

**Files:**
- Modify: `lib/features/quran/presentation/widgets/number_quick_scroll_rail.dart`
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Test: `test/features/quran/presentation/number_quick_scroll_rail_test.dart`
- Test: `test/features/quran/presentation/quran_reader_page_test.dart`

**Interfaces:**
- Consumes: `count`, `current`, `semanticLabel`, `onPreview`, `onSelected`
- Produces: the same constructor and callbacks; `onPreview` fires during an activated long-press drag and `onSelected` fires once on long-press release

- [ ] **Step 1: Replace the current immediate-drag test with long-press behavior tests**

Test these real interactions:

```dart
expect(find.text('1'), findsNothing);
expect(find.text('10'), findsNothing);

final rail = find.byKey(const ValueKey('number-quick-scroll-rail'));
await tester.tap(rail);
await tester.pump();
expect(previewed, isNull);
expect(selected, isNull);

final gesture = await tester.startGesture(tester.getCenter(rail));
await tester.pump(kLongPressTimeout + const Duration(milliseconds: 20));
await gesture.moveBy(const Offset(0, 80));
await tester.pump();
expect(previewed, isNotNull);
expect(find.byKey(const ValueKey('number-quick-scroll-bubble')), findsOneWidget);
await gesture.up();
await tester.pump();
expect(selected, previewed);
expect(find.byKey(const ValueKey('number-quick-scroll-bubble')), findsNothing);
```

Add a cancellation test and verify a `current` value positions a visible 3–4-pixel teal thumb within the track.

- [ ] **Step 2: Run the rail test and verify RED**

Run:

```bash
flutter test test/features/quran/presentation/number_quick_scroll_rail_test.dart
```

Expected: a normal tap currently previews and commits immediately, endpoint numbers remain visible, and no current-position thumb exists.

- [ ] **Step 3: Implement long-press-only scrub mode**

Use `GestureDetector` long-press callbacks (`onLongPressStart`, `onLongPressMoveUpdate`, `onLongPressEnd`, `onLongPressCancel`) over a 44-pixel translucent hit region. Do not mutate or invoke callbacks from ordinary taps. Map local Y to `1..count`, show a compact rounded teal preview bubble only while active, call `onPreview` as the value changes, and call `onSelected` exactly once when the active gesture ends.

Render a quiet border-colored track and a 3–4-pixel teal thumb. Thumb Y is `(current - 1) / (count - 1)` clamped to track extent, with defined zero-division behavior when `count == 1`. Remove permanent endpoint labels.

- [ ] **Step 4: Connect current page/ayah state without changing jump behavior**

Pass the best current visible Ayah value already tracked by the reader rather than only `_jumpTargetAyah`. Keep `_chooseAyah(number)` as the commit path so page loading, position persistence, and current navigation behavior stay intact.

- [ ] **Step 5: Run rail and reader tests and verify GREEN**

Run:

```bash
flutter test test/features/quran/presentation/number_quick_scroll_rail_test.dart test/features/quran/presentation/quran_reader_page_test.dart
```

Expected: long-press tests and all existing reader actions pass without overflow.

- [ ] **Step 6: Format and record the Task 4 checkpoint**

Run `dart format` for all four files. If Git is available, commit with `feat: add long-press Quran scrubber`; otherwise inspect the four-file diff.

---

### Task 5: Restyle Quran list, reader chrome, and Ayah controls

**Files:**
- Modify: `lib/features/quran/presentation/quran_surah_list_page.dart`
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Modify: `lib/features/quran/presentation/widgets/ayah_card.dart`
- Modify: `lib/features/quran/presentation/widgets/reader_window.dart`
- Modify: `lib/features/quran/presentation/widgets/inline_tafsir_panel.dart`
- Delete: `lib/features/quran/presentation/widgets/surah_place_artwork.dart` if no non-Surah consumer remains
- Test: `test/features/quran/presentation/quran_surah_list_page_test.dart`
- Test: `test/features/quran/presentation/quran_reader_page_test.dart`

**Interfaces:**
- Consumes: existing Quran providers, reader state, translation preference, Tafsir and audio callbacks
- Produces: identical list/filter/search/open-reader and Ayah action behavior with reference styling

- [ ] **Step 1: Add failing visual-contract assertions**

Assert the Surah list and reader use 12-pixel horizontal content margins, solid card/header decoration without a gradient, 12-pixel radii, theme border colors, compact metadata text, and no ordinary `FontWeight.w700`. For a known row, assert its number, English/localized name, revelation place, verse count, and Arabic name are rendered as `Text`; assert `SurahPlaceArtwork` is absent from both list and reader. Preserve all current behavioral assertions for filters, search, bookmarks, Tafsir, Hifz, translations, downloads, playback, and word interaction.

- [ ] **Step 2: Run Quran presentation tests and verify RED**

Run:

```bash
flutter test test/features/quran/presentation/quran_surah_list_page_test.dart test/features/quran/presentation/quran_reader_page_test.dart
```

Expected: the reader gradient, 18-pixel radius, strong action bar, or conflicting literal colors fail.

- [ ] **Step 3: Apply typographic Surah rows and reference reader chrome**

Use white list rows with thin separators and compact 10–12 padding. Structure each row as number, an expanded name/metadata column, and a trailing RTL Arabic-name `Text` using the existing Quran Arabic font and teal color. Keep revelation place and verse count in small secondary-gray metadata. Remove `SurahPlaceArtwork` imports/usages from the list and reader, then delete the widget file only if `rg "SurahPlaceArtwork" lib test` finds no remaining consumer. Replace the reader hero gradient with a solid theme role and show revelation metadata text instead of decorative place artwork. Keep all Quran verse `TextStyle` sources untouched. Make toolbar and Ayah actions outlined and visually small while retaining accessible tap bounds.

- [ ] **Step 4: Verify translation and download invariants**

Confirm the global translation toggle reveals translation immediately without rendering per-Ayah “Show translation” buttons. Confirm header download options, background download, cancellation, playback, bookmarks, copy/share, and Tafsir actions remain present and invoke their existing callbacks.

- [ ] **Step 5: Run tests and verify GREEN**

Run the command from Step 2 and the offline prompt test:

```bash
flutter test test/features/quran/presentation/reader_offline_audio_prompt_test.dart
```

- [ ] **Step 6: Format and record the Task 5 checkpoint**

Format all modified files. If Git is available, commit with `style: refine Quran surfaces and controls`; otherwise inspect the scoped diff.

---

### Task 6: Apply the shared system to secondary screens and overlays

**Files:**
- Modify as needed: `lib/features/home/presentation/prayer_tracker_page.dart`
- Modify as needed: `lib/features/home/presentation/prayer_calendar_page.dart`
- Modify as needed: `lib/features/home/presentation/prayer_location_page.dart`
- Modify as needed: `lib/features/home/presentation/more_page.dart`
- Modify as needed: `lib/features/hifz/presentation/*.dart`
- Modify as needed: `lib/features/progress/presentation/progress_page.dart`
- Modify as needed: `lib/features/revision/presentation/todays_revision_page.dart`
- Modify as needed: `lib/features/study/presentation/bookmarks_page.dart`
- Modify as needed: `lib/features/search/presentation/quran_search_page.dart`
- Modify as needed: `lib/features/tafsir/presentation/tafsir_reader_page.dart`
- Modify as needed: `lib/features/reciters/presentation/reciter_audio_page.dart`
- Modify as needed: `lib/features/settings/presentation/settings_page.dart`
- Test: existing presentation tests under `test/features/**/presentation/`

**Interfaces:**
- Consumes: Task 1 component themes and every existing screen controller/provider
- Produces: unchanged secondary-screen behaviors with consistent reference styling

- [ ] **Step 1: Add one shared-style integration assertion to representative tests**

In existing Settings, Hifz, progress, and prayer tests, verify rendered `Card`, `ListTile`, `InputDecoration`, buttons, dialogs, or sheets resolve to the Task 1 theme. Add a 320-pixel-width smoke pump for representative content and assert `tester.takeException()` is null.

- [ ] **Step 2: Run the representative tests and verify RED where local overrides conflict**

Run:

```bash
flutter test test/features/settings/presentation test/features/hifz/presentation test/features/progress/presentation test/features/home/presentation
```

Expected: assertions identify remaining local large spacing, heavy weights, strong shadows, or literal colors.

- [ ] **Step 3: Remove conflicting local visual overrides**

Replace repeated 16-pixel outer margins with 12, 20–24 section gaps with 8–12, heavy section-title weights with theme `titleMedium`, and decorative colors with semantic roles. Preserve domain visuals, Quran Arabic styles, charts, field values, callbacks, provider reads/writes, and route structure.

Use white outlined grouping surfaces rather than adding new nested cards. Ensure settings controls remain legible and selectable, Hifz focus mode remains distraction-free, and status/error colors retain their semantics.

- [ ] **Step 4: Normalize dialogs, sheets, and download overlays**

Ensure all overlays inherit the 16-radius white surface, compact title/body roles, responsive wrapped actions, teal progress, and error-colored cancel action. Keep download background/cancel behavior unchanged.

- [ ] **Step 5: Run all presentation tests and verify GREEN**

Run:

```bash
flutter test test/features
```

Expected: all existing behavior tests and new visual-contract tests pass.

- [ ] **Step 6: Scan for conflicting UI literals**

Run:

```bash
rg -n "FontWeight\.w700|Color\(0xFF(25898E|2CA4AB|3AC2CA|2A2D38|3B3F50)\)|EdgeInsets\.fromLTRB\(16" lib/app lib/features --glob '*.dart'
```

Review every result. Keep a match only when it belongs to Quran text/domain visualization or has a documented semantic reason; otherwise replace it with the approved theme role.

- [ ] **Step 7: Format and record the Task 6 checkpoint**

Run `dart format lib test`. If Git is available, commit with `style: unify secondary screens and overlays`; otherwise inspect the complete scoped diff.

---

### Task 7: Full verification and ADB visual inspection

**Files:**
- Verify: all modified source, tests, assets, and `pubspec.yaml`
- Output: `build/app/outputs/flutter-apk/app-debug.apk`

**Interfaces:**
- Consumes: Tasks 1–6
- Produces: a verified debug APK installed on the connected Android device

- [ ] **Step 1: Verify font registration and stale references**

Run:

```bash
flutter pub get
rg -n "fontFamily: 'Quicksand'|#3AC2CA|#25898E" lib test pubspec.yaml || true
find assets/fonts -maxdepth 1 -type f -printf '%f\n' | sort
```

Confirm English theme selection is Inter, Bangla selection is SolaimanLipi, and both font/license assets are packaged.

- [ ] **Step 2: Run static analysis**

Run `flutter analyze` and require exit code 0 with “No issues found”.

- [ ] **Step 3: Run the full test suite**

Run `flutter test` and require exit code 0 with zero failed tests.

- [ ] **Step 4: Build the Android debug APK**

Run `flutter build apk --debug` and require the APK path above to be produced successfully.

- [ ] **Step 5: Install and launch on the connected device**

Resolve the device with `adb devices -l`, install with `adb -s <device> install -r build/app/outputs/flutter-apk/app-debug.apk`, launch `com.quranhifz.app.debug/com.ryanheise.audioservice.AudioServiceActivity`, and verify both `pidof com.quranhifz.app.debug` and `mResumedActivity`.

- [ ] **Step 6: Inspect representative screens**

Capture and inspect Home, Quran list, reader, Settings, and an active download dialog. Confirm white/pale surfaces, restrained teal, charcoal typography, compact Home density, consistent icons, readable prayer times, the thin reader rail, long-press number preview, and no overflow. If a visual defect is found, add a failing widget test before correcting it.

- [ ] **Step 7: Report exact evidence**

Report test count, analyzer result, APK path, device serial, running PID, screens inspected, and any warnings that do not affect correctness. If Git metadata exists, commit with `style: complete reference UI refresh`; otherwise do not initialize Git and state that no commit was created.
