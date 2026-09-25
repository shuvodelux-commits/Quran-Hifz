# Visual System and Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the default bright teal visual system with the user-supplied blue/gold/off-white palette and make bottom navigation use one clean outline icon language.

**Architecture:** Centralize the sampled reference colors in one token file, feed them into the existing light theme and `AppPalette`, then update destination icon definitions so selected/unselected states differ by color/indicator rather than filled-vs-outline icon style. Alternate themes remain distinct.

**Tech Stack:** Flutter Material 3, Dart, existing `ThemeData`, `ColorScheme`, `ThemeExtension`.

**Spec:** `docs/superpowers/specs/2026-09-25-onboarding-visual-system-quran-reader-design.md`

## Global Constraints

- Main app/header blue: `#27687E`.
- Deeper/pressed blue: `#205766`.
- Quran Surah information-card blue: `#275F70`.
- Gold accent: approximately `#D5A44B`.
- Warm off-white canvas: approximately `#F7F6F1`.
- Cards: `#FFFFFF`.
- Use gold only for narrow accents/metadata, never as dominant primary action color.
- Do not flood ordinary cards with blue.
- Existing green, women, and dark themes must remain distinct.
- Bottom navigation order/labels/tap behavior must not change.
- Bottom navigation icons must stay outline-style in both selected and unselected states.
- Selected state uses primary blue and subtle tint; unselected state stays neutral.

## Review Focus

- Existing non-default themes must not accidentally inherit the new light-theme blue card/surface roles.
- Selected navigation must remain visually distinguishable even though selected and unselected icons use the same outline glyph.
- Bangla and English typography settings must not regress when color tokens change.
- Contrast of primary blue on white and white on primary must remain readable.
- Existing tests that intentionally depend on theme-derived colors must continue deriving from `ThemeData`, not hardcoded old teal values.

---

### Task 1: Centralize sampled palette and update default light theme

**Files:**
- Create: `lib/core/theme/reference_colors.dart`
- Modify: `lib/core/theme/app_palette.dart`
- Modify: `lib/app/app_theme.dart`
- Modify: `test/app/app_theme_test.dart`

**Interfaces:**
- Produces: `ReferenceColors.appBlue`, `deepBlue`, `quranCardBlue`, `goldAccent`, `warmCanvas`, `cardSurface`, `blueTint`
- Extends: `AppPalette` with `quranHeader` and `goldAccent`

- [ ] **Step 1: Write failing token/theme tests**

Update the light-theme expectations:

```dart
expect(blue.colorScheme.primary, const Color(0xFF27687E));
expect(blue.colorScheme.secondary, const Color(0xFF205766));
expect(blue.scaffoldBackgroundColor, const Color(0xFFF7F6F1));
expect(blue.colorScheme.surfaceContainerLow, Colors.white);

final palette = blue.extension<AppPalette>()!;
expect(palette.accentPressed, const Color(0xFF205766));
expect(palette.quranHeader, const Color(0xFF275F70));
expect(palette.goldAccent, const Color(0xFFD5A44B));
```

Keep assertions proving green/women/dark are still different.

- [ ] **Step 2: Run theme tests to verify RED**

Run:
```bash
flutter test test/app/app_theme_test.dart
```

Expected: FAIL on old teal/surface values and missing palette fields.

- [ ] **Step 3: Add reference color tokens**

Create:

```dart
import 'package:flutter/material.dart';

abstract final class ReferenceColors {
  static const appBlue = Color(0xFF27687E);
  static const deepBlue = Color(0xFF205766);
  static const quranCardBlue = Color(0xFF275F70);
  static const goldAccent = Color(0xFFD5A44B);
  static const warmCanvas = Color(0xFFF7F6F1);
  static const cardSurface = Colors.white;
  static const blueTint = Color(0xFFE8F0F2);
}
```

- [ ] **Step 4: Extend `AppPalette` without breaking alternate themes**

Add:
```dart
final Color quranHeader;
final Color goldAccent;
```

Update constructor, `copyWith`, and `lerp`.

For default light:
- `quranHeader = ReferenceColors.quranCardBlue`
- `goldAccent = ReferenceColors.goldAccent`

For alternate themes:
- `quranHeader = scheme.primary`
- `goldAccent = scheme.tertiary`

- [ ] **Step 5: Apply sampled palette to default light theme**

Change only `AppThemePreference.light` values:
- seed/primary -> `ReferenceColors.appBlue`
- secondary -> `ReferenceColors.deepBlue`
- primary/secondary/tertiary containers -> `ReferenceColors.blueTint`
- surface/scaffold -> `ReferenceColors.warmCanvas`
- surfaceContainerLow -> white
- pressed accent -> `ReferenceColors.deepBlue`

Do not alter green/women/dark seeds.

- [ ] **Step 6: Run theme tests**

Run:
```bash
flutter test test/app/app_theme_test.dart
```

Expected: PASS.

- [ ] **Step 7: Run theme-sensitive regression tests**

Run:
```bash
flutter test test/features/home/presentation/home_dashboard_page_test.dart test/features/home/presentation/prayer_calendar_page_test.dart test/features/dua/presentation/dua_page_test.dart test/features/dua/presentation/dua_detail_page_test.dart
```

Expected: PASS; any tests tied to old hardcoded teal should be corrected to use current theme roles.

- [ ] **Step 8: Commit**

```bash
git add lib/core/theme/reference_colors.dart lib/core/theme/app_palette.dart lib/app/app_theme.dart test/app/app_theme_test.dart test/features/home test/features/dua
git commit -m "style: adopt reference blue color system"
```

---

### Task 2: Make bottom navigation consistently outline-style

**Files:**
- Modify: `lib/app/app_destination.dart`
- Modify: `lib/app/quran_hifz_shell.dart`
- Modify: `test/app/quran_hifz_shell_test.dart`

**Interfaces:**
- Consumes: theme `NavigationBarThemeData`
- Preserves: `AppDestination.values` order and all localized labels

- [ ] **Step 1: Write failing navigation-icon tests**

Add assertions that each selected icon remains an outline glyph:

```dart
expect(AppDestination.home.icon, Icons.home_outlined);
expect(AppDestination.home.selectedIcon, Icons.home_outlined);
expect(AppDestination.quran.icon, Icons.menu_book_outlined);
expect(AppDestination.quran.selectedIcon, Icons.menu_book_outlined);
expect(AppDestination.calendar.selectedIcon, Icons.calendar_month_outlined);
expect(AppDestination.more.selectedIcon, Icons.grid_view_outlined);
```

For Dua, use the same clean outline glyph for both states:
`Icons.volunteer_activism_outlined`.

Also verify the `NavigationBar` still has exactly five destinations and selected indicator uses the theme tint.

- [ ] **Step 2: Run shell tests to verify RED**

Run:
```bash
flutter test test/app/quran_hifz_shell_test.dart
```

Expected: FAIL because selected icons currently use filled rounded variants.

- [ ] **Step 3: Update destination icon definitions**

Use:

```dart
home(
  label: 'Home',
  icon: Icons.home_outlined,
  selectedIcon: Icons.home_outlined,
),
dua(
  label: 'Dua',
  icon: Icons.volunteer_activism_outlined,
  selectedIcon: Icons.volunteer_activism_outlined,
),
quran(
  label: 'Quran',
  icon: Icons.menu_book_outlined,
  selectedIcon: Icons.menu_book_outlined,
),
calendar(
  label: 'Calendar',
  icon: Icons.calendar_month_outlined,
  selectedIcon: Icons.calendar_month_outlined,
),
more(
  label: 'More',
  icon: Icons.grid_view_outlined,
  selectedIcon: Icons.grid_view_outlined,
);
```

Do not change navigation labels or destination order.

- [ ] **Step 4: Keep selected state structural, not icon-filled**

Ensure `NavigationBarThemeData` remains:
- selected icon/text = `scheme.primary`
- unselected = `scheme.onSurfaceVariant`
- indicator = `scheme.primaryContainer`
- height 62
- elevation 0

- [ ] **Step 5: Run shell tests**

Run:
```bash
flutter test test/app/quran_hifz_shell_test.dart
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
git add lib/app/app_destination.dart lib/app/quran_hifz_shell.dart test/app/quran_hifz_shell_test.dart
git commit -m "style: simplify bottom navigation icons"
```
