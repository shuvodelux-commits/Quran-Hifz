# Quran Surah Row Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle only the Quran library's Surah rows to match the approved reference while preserving all library behavior.

**Architecture:** Extract the row into a focused public widget with a vector-painted number medallion and pure revelation-label formatting. The parent page retains search, tabs, Last Read, quick-scroll, Hifz/Tafsir actions, localization, and navigation unchanged.

**Tech Stack:** Flutter, Dart, Flutter widget tests

**Spec:** `docs/superpowers/specs/2026-09-15-hifz-immersive-mushaf-design.md`

## Global Constraints

- Redesign only Surah rows.
- Preserve search, Surah/Juz/Bookmarks tabs, Last Read, Hifz/Tafsir actions, quick-scroll, localization, themes, and navigation.
- Use no new raster asset for the number medallion.
- Support large system text without overlap or clipped Arabic.
- The current workspace has no `.git` metadata. Run commit steps only after repository metadata is restored.

---

### Task 1: Build and Test the Reference-Style Surah Row

**Files:**
- Create: `lib/features/quran/presentation/widgets/quran_surah_row.dart`
- Modify: `lib/features/quran/presentation/quran_surah_list_page.dart`
- Modify: `pubspec.yaml`
- Create: `test/features/quran/presentation/quran_surah_row_test.dart`
- Modify: `test/features/quran/presentation/quran_surah_list_page_test.dart`

**Interfaces:**
- Produces: `QuranSurahRow({required QuranSurahSummary surah, required AppLanguage language, required VoidCallback onTap})`.
- Produces: `String localizedRevelationLabel(String? source, AppLanguage language)`.

- [ ] **Step 1: Write failing row-content and navigation tests**

```dart
testWidgets('Surah row shows reference metadata and opens on tap', (tester) async {
  var taps = 0;
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuranSurahRow(
    surah: const QuranSurahSummary(
      number: 2,
      nameArabic: 'البقرة',
      nameEnglish: 'Al-Baqarah',
      revelationPlace: 'Madinah',
      ayahCount: 286,
      pageStart: 2,
      pageEnd: 49,
      juzStart: 1,
    ),
    language: AppLanguage.english,
    onTap: () => taps++,
  ))));
  expect(find.text('2'), findsOneWidget);
  expect(find.text('Al-Baqarah'), findsOneWidget);
  expect(find.text('Madani · 286 Verses'), findsOneWidget);
  expect(find.text('سورة البقرة'), findsOneWidget);
  await tester.tap(find.byType(QuranSurahRow));
  expect(taps, 1);
});
```

Add a Bangla case and a `textScaler: const TextScaler.linear(1.8)` case asserting no overflow exception. Keep the existing library test proving search/tabs/navigation still work.

- [ ] **Step 2: Run tests and confirm RED**

Run: `flutter test test/features/quran/presentation/quran_surah_row_test.dart test/features/quran/presentation/quran_surah_list_page_test.dart`

Expected: compilation fails because `QuranSurahRow` does not exist.

- [ ] **Step 3: Implement the row and medallion**

Ensure `pubspec.yaml` registers `assets/fonts/Al-Qalam-Quran-Majeed.ttf` with the family alias `AlQalamQuranMajeed`; keep an existing identical declaration unchanged when the Hifz font task has already run.

Use a transparent `Material`/`InkWell`, minimum height 96, 16-pixel horizontal padding, and a `Row` containing:

```dart
SizedBox.square(
  dimension: 64,
  child: DecoratedBox(
    decoration: BoxDecoration(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
    ),
    child: CustomPaint(
      painter: SurahNumberMedallionPainter(color: scheme.outlineVariant),
      child: Center(child: Text(localDigits('${surah.number}', language))),
    ),
  ),
)
```

Give the center metadata column `Expanded(flex: 5)`, Arabic `Flexible(flex: 3)`, and use `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight)` only for the Arabic Surah-name label. Paint two rotated squares plus an inset octagonal outline for the medallion; `shouldRepaint` returns true only when color changes.

Normalize `Makkah|Mecca|Makki` to `Makki`, `Madinah|Medina|Madani` to `Madani`, and return `Unknown`/`অজানা` only for missing unrecognized metadata. Use `AlQalamQuranMajeed` for `سورة ${surah.nameArabic}`.

- [ ] **Step 4: Replace only `_SurahTile`**

Import `quran_surah_row.dart` and replace `_SurahTile(...)` calls with `QuranSurahRow(...)`. Delete the private `_SurahTile` class; do not change `_QuickActions`, tabs, list filtering, rail, or navigation callbacks.

- [ ] **Step 5: Run focused and regression tests**

Run: `flutter test test/features/quran/presentation/quran_surah_row_test.dart test/features/quran/presentation/quran_surah_list_page_test.dart`

Expected: PASS with no overflow exceptions.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml lib/features/quran/presentation test/features/quran/presentation
git commit -m "feat: redesign Quran Surah rows"
```

### Task 2: Verify the Surah List on Android

**Files:**
- Modify only row files if visual acceptance exposes spacing or scaling defects.

- [ ] **Step 1: Run quality checks**

Run: `dart format lib/features/quran/presentation test/features/quran/presentation`

Run: `flutter analyze`

Run: `flutter test`

Expected: no issues and all tests pass.

- [ ] **Step 2: Build and install**

Run: `flutter build apk --debug`

Run: `adb -s 4SR4SGMR65RGWS8T install -r build/app/outputs/flutter-apk/app-debug.apk`

Expected: successful build and install.

- [ ] **Step 3: Compare against the supplied Surah reference**

Verify rows 1–8 at portrait phone width: medallions align, localized names remain bold and readable, Makki/Madani plus verse counts are correct, Arabic names do not clip, the quick-scroll rail remains usable, and search/navigation still work.

- [ ] **Step 4: Commit visual adjustments**

```bash
git add lib/features/quran/presentation/widgets/quran_surah_row.dart test/features/quran/presentation/quran_surah_row_test.dart
git commit -m "fix: polish Quran Surah row layout"
```
