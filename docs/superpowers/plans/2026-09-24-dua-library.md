# Dua Library Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Salat Tracker bottom tab with a fully offline, searchable, theme-aware Dua library containing at least 100 verified Qur'an/Sahih-Hasan supplications with persistent Favorites.

**Architecture:** Add a self-contained `features/dua` module with immutable domain models, a strict bundled JSON repository, pure local search/filtering, and a lightweight Favorites repository persisted through the existing `AppSettings` key/value store. The UI uses Riverpod and the existing Material 3 theme, while the shell replaces the Prayer destination with Dua and removes tracker-only code without altering prayer schedule/calendar functionality.

**Tech Stack:** Flutter, Dart 3.12+, Material 3, flutter_riverpod 3.4.3, Drift-backed `UserDatabase` settings storage, bundled JSON assets, flutter_test.

**Spec:** `docs/superpowers/specs/2026-09-24-dua-library-design.md`

## Global Constraints

- The production catalog contains at least 100 verified entries.
- Accepted religious content is limited to Qur'anic supplications and Hadith supplications graded Sahih or Hasan.
- Weak, fabricated, popularity-only, or unsourced Duas are excluded.
- Bangla mode renders Arabic → Bangla pronunciation → Bangla meaning → source/reference.
- English mode renders Arabic → English transliteration → English meaning → source/reference.
- Dua v1 is fully offline and has no audio, checklist/streak, remote sync, or remote catalog.
- Favorites persist locally and store only stable Dua IDs.
- Existing prayer schedule, current-prayer calculation, prohibited-time display, mosque times, and Prayer Calendar remain intact.
- The Salat Tracker is removed from the user-facing app and its tracker-only code is deleted when no longer referenced.
- All Dua colors come from `Theme.of(context).colorScheme`; no hard-coded brand-color surfaces.
- Support light, dark, green, and women themes, 360px Android width, RTL Arabic text, and elevated system text scaling.
- Follow TDD: production behavior is added only after the corresponding test is observed failing for the intended reason.

## Reference Lock

Live Refero lookup was attempted but unavailable because the connected Refero subscription is inactive. The implementation therefore locks to the app's existing production UI rather than inventing a new visual system.

- **Primary direction:** current Home/Quran/More Material 3 UI.
- **Preserve:** compact 12–16px page padding; 12–16px rounded surfaces; `primaryContainer` for low-emphasis accents; system/theme typography; sparse elevation; full theme-awareness.
- **Borrow only:** Quran reader's Arabic font handling for long Arabic text and More/Home compact card density.
- **Role rules:** `primary` is for active/accent states, `primaryContainer` for chips/icon wells, `surface`/card surfaces for content, `onSurfaceVariant` for metadata.
- **Reject:** hard-coded green/blue/pink cards, oversized decorative hero sections, gradient-heavy Dua cards, dense dashboard-style grids, and duplicate theme tokens.
- **Media strategy:** none; v1 is text-centric and needs no decorative bitmap imagery.

## Review Focus

- Malformed or partially valid bundled JSON must fail catalog loading atomically rather than exposing a partial religious-content list.
- Bangla/English normalization must not allow empty or punctuation-only queries to reorder/filter the catalog unexpectedly.
- A Favorite ID that no longer exists in the catalog must not crash Favorites view or detail navigation.
- Long Arabic/transliteration/source text must wrap at 360px width and increased text scale without overflow.
- Removing the tracker must not remove or break shared prayer schedule providers used by Home and Calendar.

---

### Task 1: Dua Domain Model and Strict Bundled Catalog Loader

**Files:**
- Create: `lib/features/dua/domain/dua.dart`
- Create: `lib/features/dua/domain/dua_repository.dart`
- Create: `lib/features/dua/data/bundled_dua_repository.dart`
- Create: `test/features/dua/data/bundled_dua_repository_test.dart`
- Modify: `pubspec.yaml`
- Create initially as test fixture: `test/fixtures/dua/valid_catalog.json`

**Interfaces:**
- Produces: `Dua`, `DuaCategory`, `DuaSource`, `DuaSourceType`, `HadithGrade`.
- Produces: `abstract interface class DuaRepository { Future<List<Dua>> loadAll(); }`.
- Produces: `BundledDuaRepository({required AssetBundle bundle, String assetPath = defaultAssetPath})`.

- [ ] **Step 1: Write failing parser/model tests**

Create tests that load a small in-memory `AssetBundle` fixture and assert:
- a valid Qur'an source parses Surah/Ayah metadata;
- a valid Hasan Hadith source parses collection/reference/grading authority;
- duplicate Dua IDs throw `FormatException`;
- missing Arabic/Bangla/English/category/source fields throw `FormatException`;
- Hadith grade values outside `sahih`/`hasan` throw `FormatException`;
- unknown category IDs throw `FormatException`;
- malformed JSON throws `FormatException`;
- one invalid record causes the whole `loadAll()` call to fail.

Use a fixture shape like:

```json
{
  "schema_version": 1,
  "categories": [
    {"id":"daily","bn":"দৈনন্দিন","en":"Daily Routine"}
  ],
  "duas": [
    {
      "id":"waking-up",
      "title_bn":"ঘুম থেকে ওঠার দোয়া",
      "title_en":"Upon waking",
      "arabic":"...",
      "pronunciation_bn":"...",
      "meaning_bn":"...",
      "transliteration_en":"...",
      "meaning_en":"...",
      "category_ids":["daily"],
      "tags_bn":["ঘুম"],
      "tags_en":["sleep","wake"],
      "daily_order":10,
      "sources":[
        {
          "type":"hadith",
          "collection":"Sahih al-Bukhari",
          "reference":"6324",
          "grade":"sahih"
        }
      ]
    }
  ]
}
```

Run:

```bash
flutter test test/features/dua/data/bundled_dua_repository_test.dart
```

Expected: FAIL because the Dua domain/repository classes do not exist.

- [ ] **Step 2: Implement the immutable domain types**

Use const constructors and equality-by-value-friendly plain Dart fields. Required signatures:

```dart
enum DuaSourceType { quran, hadith }
enum HadithGrade { sahih, hasan }

class DuaSource {
  const DuaSource({
    required this.type,
    this.surahNumber,
    this.ayahStart,
    this.ayahEnd,
    this.collection,
    this.reference,
    this.grade,
    this.gradingAuthority,
  });
  // fields...
}

class DuaCategory {
  const DuaCategory({
    required this.id,
    required this.banglaLabel,
    required this.englishLabel,
  });
  // fields...
}

class Dua {
  const Dua({
    required this.id,
    required this.titleBangla,
    required this.titleEnglish,
    required this.arabic,
    required this.banglaPronunciation,
    required this.banglaMeaning,
    required this.englishTransliteration,
    required this.englishMeaning,
    required this.categoryIds,
    required this.tagsBangla,
    required this.tagsEnglish,
    required this.sources,
    this.dailyOrder,
    this.noteBangla,
    this.noteEnglish,
  });
  // fields...
}
```

- [ ] **Step 3: Implement the strict bundled loader**

`BundledDuaRepository.loadAll()` must:
1. read `assets/dua/duas_v1.json`;
2. require object root and `schema_version == 1`;
3. parse all categories first and reject duplicate category IDs;
4. parse all Dua rows into a temporary list;
5. validate all references/categories/IDs before returning anything;
6. reject blank required strings after `trim()`;
7. require Hadith grade to be Sahih/Hasan;
8. require Qur'an source Surah 1–114 and positive Ayah bounds;
9. return an unmodifiable list.

- [ ] **Step 4: Register the production asset directory**

Modify `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/database/
    - assets/audio/
    - assets/audio/chapters_v1/
    - assets/images/
    - assets/dua/
```

Do not add production content yet; create an empty-directory-safe placeholder only if Flutter tooling requires a file, then remove it when Task 6 writes the real catalog.

- [ ] **Step 5: Run the focused tests and formatting**

```bash
dart format lib/features/dua/domain lib/features/dua/data test/features/dua/data
flutter test test/features/dua/data/bundled_dua_repository_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit Task 1**

```bash
git add pubspec.yaml lib/features/dua test/features/dua test/fixtures/dua
git commit -m "feat: add verified dua catalog model"
```

### Task 2: Local Search, Category Filtering, and Daily Ordering

**Files:**
- Create: `lib/features/dua/domain/dua_search.dart`
- Create: `test/features/dua/domain/dua_search_test.dart`

**Interfaces:**
- Consumes: `Dua`, `DuaCategory` from Task 1.
- Produces:
  ```dart
  String normalizeDuaQuery(String input)
  List<Dua> filterDuas({
    required List<Dua> duas,
    required List<DuaCategory> categories,
    required String query,
    String? categoryId,
    Set<String>? favoriteIds,
    bool favoritesOnly = false,
  })
  List<Dua> dailyDuas(List<Dua> duas)
  ```

- [ ] **Step 1: Write failing pure-function tests**

Cover:
- Bangla title/meaning search;
- Bangla pronunciation search;
- English title/meaning/transliteration search;
- Bangla digits and ASCII digits normalize equivalently;
- punctuation/extra whitespace are ignored;
- empty/punctuation-only query leaves catalog order unchanged;
- category filter composes with text search;
- Favorites-only ignores stored IDs absent from catalog;
- exact title match ranks before prefix/substring matches;
- `dailyDuas` returns only entries with `dailyOrder`, sorted by order then ID for deterministic ties.

Run:

```bash
flutter test test/features/dua/domain/dua_search_test.dart
```

Expected: FAIL because search functions do not exist.

- [ ] **Step 2: Implement conservative normalization**

Normalization must:
- lowercase Latin text;
- map Bangla digits `০১২৩৪৫৬৭৮৯` to `0123456789`;
- collapse whitespace;
- remove punctuation used only as separators;
- preserve Bangla and Arabic letters;
- never transliterate or guess Arabic spelling.

- [ ] **Step 3: Implement deterministic filtering/ranking**

Ranking order:
1. exact normalized title;
2. title prefix;
3. token prefix;
4. substring in title/pronunciation/transliteration;
5. substring in meaning/tags/category label/source text.

Within equal rank preserve original catalog order. Category and Favorites filters are applied before rank sorting.

- [ ] **Step 4: Verify focused tests**

```bash
dart format lib/features/dua/domain test/features/dua/domain
flutter test test/features/dua/domain/dua_search_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit Task 2**

```bash
git add lib/features/dua/domain/dua_search.dart test/features/dua/domain/dua_search_test.dart
git commit -m "feat: add offline dua search"
```

### Task 3: Persistent Dua Favorites via Existing User Settings

**Files:**
- Create: `lib/features/dua/domain/dua_favorites_repository.dart`
- Create: `lib/features/dua/data/user_database_dua_favorites_repository.dart`
- Create: `lib/features/dua/application/dua_providers.dart`
- Create: `test/features/dua/data/user_database_dua_favorites_repository_test.dart`
- Create: `test/features/dua/application/dua_providers_test.dart`

**Interfaces:**
- Consumes: `UserDatabase.getSetting/saveSetting`, `DuaRepository`.
- Produces:
  ```dart
  abstract interface class DuaFavoritesRepository {
    Future<Set<String>> load();
    Future<void> save(Set<String> ids);
  }
  ```
- Persistence key: `dua_favorites_v1`.
- JSON encoding: sorted array of stable string IDs.
- Produces Riverpod providers for catalog, categories, query, selected category, favorites-only state, Favorite IDs, and filtered results.

- [ ] **Step 1: Write failing Favorites repository tests**

Using `UserDatabase.forTesting(NativeDatabase.memory())`, assert:
- missing key loads an empty set;
- save/load survives repository recreation;
- duplicate IDs are collapsed;
- IDs are stored in deterministic sorted JSON;
- malformed persisted JSON safely returns an empty set rather than crashing the app.

Run:

```bash
flutter test test/features/dua/data/user_database_dua_favorites_repository_test.dart
```

Expected: FAIL because the repository does not exist.

- [ ] **Step 2: Implement persistence without a schema migration**

Use the existing `AppSettings` table because it is already durable, tested, and used by prayer tracker/preferences. Do not change `UserDatabase.schemaVersion` or generated Drift files for v1 Favorites.

Repository behavior:

```dart
static const settingKey = 'dua_favorites_v1';

Future<Set<String>> load() async {
  final raw = await database.getSetting(settingKey);
  if (raw == null || raw.isEmpty) return <String>{};
  try {
    final value = jsonDecode(raw);
    if (value is! List) return <String>{};
    return value.whereType<String>().where((id) => id.trim().isNotEmpty).toSet();
  } on FormatException {
    return <String>{};
  }
}
```

Save sorted IDs with `jsonEncode`.

- [ ] **Step 3: Write failing provider/controller tests**

Assert:
- bundled repository provider can be overridden with a fake catalog;
- Favorite toggle persists then refreshes state;
- query + category + Favorites-only compose correctly;
- an orphan stored Favorite ID is not emitted as a fake Dua.

- [ ] **Step 4: Implement Riverpod state**

Use small focused providers rather than one monolithic notifier:
- `duaRepositoryProvider`;
- `duaCatalogProvider` as `FutureProvider`;
- `duaFavoritesRepositoryProvider`;
- `duaFavoriteIdsProvider` as async state with a toggle controller;
- simple local StateProviders/Notifiers for query/category/favorites-only as appropriate for Riverpod 3;
- `filteredDuasProvider` deriving from catalog + filters.

- [ ] **Step 5: Verify Task 3**

```bash
dart format lib/features/dua test/features/dua
flutter test test/features/dua/data/user_database_dua_favorites_repository_test.dart test/features/dua/application/dua_providers_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit Task 3**

```bash
git add lib/features/dua test/features/dua
git commit -m "feat: persist dua favorites"
```

### Task 4: Dua Landing Page and Detail Reading UI

**Files:**
- Create: `lib/features/dua/presentation/dua_page.dart`
- Create: `lib/features/dua/presentation/dua_detail_page.dart`
- Create: `lib/features/dua/presentation/widgets/dua_card.dart`
- Create: `lib/features/dua/presentation/widgets/dua_category_filter.dart`
- Create: `test/features/dua/presentation/dua_page_test.dart`
- Create: `test/features/dua/presentation/dua_detail_page_test.dart`

**Interfaces:**
- Consumes: Task 3 providers and `appLanguageProvider`.
- Produces: `const DuaPage()`.
- Produces: `DuaDetailPage({required Dua dua})`.

- [ ] **Step 1: Write failing landing-page widget tests**

Use a small fake catalog and in-memory Favorites repository. At 360×780 assert:
- app bar/title shows `দোয়া` in Bangla and `Dua` in English;
- search field is present;
- Daily Duas are in `dailyOrder`;
- category chips filter content;
- Favorites control shows only Favorited rows;
- tapping Favorite toggles icon/semantics immediately;
- no-results search shows localized empty state and clear-search action;
- empty Favorites shows localized guidance;
- no `RenderFlex overflow` occurs at textScaleFactor 1.3.

Run:

```bash
flutter test test/features/dua/presentation/dua_page_test.dart
```

Expected: FAIL because `DuaPage` does not exist.

- [ ] **Step 2: Implement the compact landing page**

Structure:
- `Scaffold` + compact `AppBar`;
- 12px horizontal page padding;
- search field;
- compact Favorites filter button;
- single-row horizontal category chips using theme colors;
- optional `Daily Duas` heading/list when no search/category/Favorites filter is active;
- main results list;
- loading/error/empty states.

Do not duplicate the same Dua twice on screen when Daily Duas and the all-results section are both visible; either show Daily Duas followed by “Browse all” excluding already-rendered IDs, or use Daily Duas as the initial result section and categories/search to switch modes. Prefer the latter for v1 simplicity.

`DuaCard` shows localized title, 1–2 lines of Arabic preview, localized meaning preview, source summary, and Favorite icon.

- [ ] **Step 3: Write failing detail-page tests**

Assert in Bangla:
1. Arabic text;
2. `বাংলা উচ্চারণ`;
3. pronunciation;
4. `বাংলা অর্থ`;
5. meaning;
6. source/reference;
7. grading when Hadith.

Assert in English:
1. Arabic;
2. `Transliteration`;
3. transliteration;
4. `Meaning`;
5. meaning;
6. source/reference.

Also assert Arabic text direction is RTL, long content scrolls, and source metadata uses `onSurfaceVariant`-style hierarchy rather than a hard-coded color.

- [ ] **Step 4: Implement the detail page**

Use:
- app's existing Quran-capable Arabic font, preferring `Noto Naskh Arabic` for compact readable prose unless existing app Quran font preference is already trivially reusable;
- `Directionality(textDirection: TextDirection.rtl)` for Arabic block;
- theme text styles and `colorScheme`;
- source card/section with explicit Qur'an or Hadith label and Sahih/Hasan grade;
- no audio controls or share actions in v1.

- [ ] **Step 5: Theme matrix widget test**

Pump the landing/detail screens with every `AppThemePreference` and assert no exception, readable key labels, and active category/Favorite surfaces use theme `primaryContainer`/related scheme colors.

- [ ] **Step 6: Verify Task 4**

```bash
dart format lib/features/dua/presentation test/features/dua/presentation
flutter test test/features/dua/presentation
```

Expected: PASS.

- [ ] **Step 7: Commit Task 4**

```bash
git add lib/features/dua/presentation test/features/dua/presentation
git commit -m "feat: add dua library interface"
```

### Task 5: Replace Prayer Destination and Remove Salat Tracker

**Files:**
- Modify: `lib/app/app_destination.dart`
- Modify: `lib/app/quran_hifz_shell.dart`
- Modify: `lib/features/home/presentation/home_dashboard_page.dart`
- Delete: `lib/features/home/presentation/prayer_tracker_page.dart`
- Delete: `lib/features/home/application/prayer_tracker_providers.dart`
- Delete: `lib/features/home/data/prayer_tracker_repository.dart`
- Delete: `test/features/home/data/prayer_tracker_repository_test.dart`
- Modify: `test/app/quran_hifz_shell_test.dart`
- Modify: `test/features/home/presentation/home_dashboard_page_test.dart`

**Interfaces:**
- Consumes: `const DuaPage()`.
- Changes enum case `AppDestination.prayer` → `AppDestination.dua`.
- Changes `HomeDashboardPage` constructor to require only `onMore`; current-prayer card becomes informational instead of navigation.

- [ ] **Step 1: Write/update failing shell test**

Change the primary-destination test to assert:
- second destination label is `দোয়া` in Bangla;
- no `সলাত` bottom-nav destination exists;
- tapping `দোয়া` renders the Dua page;
- Home, Quran, Calendar, and More still render for all themes.

Run:

```bash
flutter test test/app/quran_hifz_shell_test.dart
```

Expected: FAIL because shell still exposes Prayer.

- [ ] **Step 2: Write/update failing Home test**

Update Home widget construction to `HomeDashboardPage(onMore: _noop)`. Add a test that the current-prayer card has no tap action/navigator side effect while its prayer content remains visible.

Run:

```bash
flutter test test/features/home/presentation/home_dashboard_page_test.dart
```

Expected: FAIL because `onPrayer` is still required and the card is tappable.

- [ ] **Step 3: Replace the destination**

`app_destination.dart`:

```dart
dua(
  label: 'Dua',
  icon: Icons.volunteer_activism_outlined,
  selectedIcon: Icons.volunteer_activism_rounded,
),
```

If the rounded icon is unavailable in the project SDK, use the closest existing Material icon pair and pin it in the shell test.

`quran_hifz_shell.dart`:
- import `DuaPage`;
- remove `PrayerTrackerPage` import;
- render `AppDestination.dua => const DuaPage()`;
- localize label as `দোয়া` / `Dua`;
- remove Home `onPrayer` callback.

- [ ] **Step 4: Make Home current-prayer card informational**

Remove `onPrayer` from `HomeDashboardPage` and `_CurrentPrayerCard`. Replace the outer `InkWell` with a non-interactive container/row while keeping the current visual hierarchy unchanged.

- [ ] **Step 5: Delete tracker-only files/tests after reference scan**

Run:

```bash
rg -n "PrayerTrackerPage|prayerTrackerRepositoryProvider|dailyPrayerChecksProvider|PrayerTrackerRepository|salat_tracker_" lib test
```

Only after shell/Home references are gone, delete the three tracker files and their repository test. Do **not** delete `prayer_schedule.dart`, `home_page.dart` prayer schedule provider, calendar code, mosque-time code, or shared prayer localization helpers.

- [ ] **Step 6: Verify navigation/Home regressions**

```bash
dart format lib/app lib/features/home test/app test/features/home
flutter test test/app/quran_hifz_shell_test.dart test/features/home/presentation/home_dashboard_page_test.dart test/features/home/presentation/prayer_calendar_page_test.dart test/features/home/data/prayer_schedule_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit Task 5**

```bash
git add -A lib/app lib/features/home test/app test/features/home
git commit -m "feat: replace salat tab with dua"
```

### Task 6: Build and Audit the 100+ Entry Production Dua Catalog

**Files:**
- Create: `assets/dua/duas_v1.json`
- Create: `test/features/dua/data/production_dua_catalog_test.dart`
- Optionally create for deterministic audit tooling: `tool/dua/audit_dua_catalog.dart`

**Interfaces:**
- Consumes: Task 1 JSON schema.
- Produces: production catalog with `schema_version: 1`, localized category metadata, and >=100 qualifying Dua records.

- [ ] **Step 1: Write the failing production-catalog validation test**

Load `assets/dua/duas_v1.json` through `BundledDuaRepository(rootBundle)` and assert:
- `duas.length >= 100`;
- every ID is unique;
- every Dua has at least one valid source;
- every Hadith source grade is Sahih or Hasan;
- every Qur'an source has valid Surah/Ayah metadata;
- every category reference resolves;
- Bangla pronunciation/meaning and English transliteration/meaning are non-empty;
- `dailyOrder` entries sort deterministically;
- catalog includes qualifying entries/categories for waking, clothing/home, food, Salah, mosque, travel, family/intimacy, illness, weather/moon if qualifying, Janazah, forgiveness, debt/provision, Qur'anic Dua, Munajat, and sleep/night;
- no title/tag contains prohibited marketing claims such as `guaranteed`, `most powerful`, or Bangla equivalents used as efficacy claims.

Run:

```bash
flutter test test/features/dua/data/production_dua_catalog_test.dart
```

Expected: FAIL because the production asset is missing or has fewer than 100 entries.

- [ ] **Step 2: Establish authoritative source rules before copying content**

For each production record:
- Qur'an: verify Arabic wording and exact Surah/Ayah using an authoritative Quran text/source.
- Hadith: verify Arabic wording, collection/reference, and Sahih/Hasan grading from a reliable Hadith source or recognized grading reference.
- Do not copy modern copyrighted English/Bangla translations verbatim. Write concise app translations/meanings from the source sense.
- Record grading authority when the collection/reference alone is not sufficient to establish the agreed grade.
- Exclude disputed/weak popular items rather than adding a warning-only weak entry.

Maintain a working audit table during implementation with columns:
`id | topic | source type | canonical reference | grade | grading authority | Arabic checked | bn meaning checked | en meaning checked`.

- [ ] **Step 3: Populate the catalog in reviewed batches**

Populate at least these content families with only qualifying records:
- waking/sleep and bathroom/Wudu;
- clothing/home/food;
- mosque and Salah supplications;
- morning/evening protection and remembrance;
- travel/vehicle;
- family/children and marital intimacy;
- illness/distress/protection;
- rain/wind/weather and moon sighting only where the exact narration meets the rule;
- Janazah;
- forgiveness/Tawbah;
- debt/provision;
- Qur'anic prophetic supplications;
- Munajat grouping using the same authenticated entries/tags rather than invented formulas.

Use multiple category IDs on one Dua instead of duplicating identical Arabic content.

- [ ] **Step 4: Run catalog validation after every batch**

```bash
flutter test test/features/dua/data/production_dua_catalog_test.dart
```

Expected during assembly: fail only the minimum-count/category-coverage assertions until the final qualifying batch is complete. Parser/source-integrity assertions must stay green throughout.

- [ ] **Step 5: Final content audit**

Search for:
- duplicate normalized Arabic;
- duplicate IDs;
- blank pronunciations/transliterations;
- Hadith grades other than Sahih/Hasan;
- source entries missing canonical reference;
- unsupported efficacy claims;
- raw HTML/entities/control characters.

If `tool/dua/audit_dua_catalog.dart` is added, run:

```bash
dart run tool/dua/audit_dua_catalog.dart assets/dua/duas_v1.json
```

Expected: exit 0 and print the total count and zero validation errors.

- [ ] **Step 6: Verify production asset test**

```bash
flutter test test/features/dua/data/production_dua_catalog_test.dart
```

Expected: PASS with >=100 entries.

- [ ] **Step 7: Commit Task 6**

```bash
git add assets/dua test/features/dua/data/production_dua_catalog_test.dart tool/dua
git commit -m "content: add verified offline dua catalog"
```

If `tool/dua` was not created, omit that path.

### Task 7: Whole-App Regression, APK Build, and Device Visual QA

**Files:**
- Modify only if verification exposes defects in code from Tasks 1–6.
- No unrelated cleanup.

**Interfaces:**
- Validates the complete feature and existing app.

- [ ] **Step 1: Run formatting and static analysis**

```bash
dart format lib test tool
flutter analyze
```

Expected: no analyzer issues.

- [ ] **Step 2: Run the complete test suite**

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Build the debug APK**

```bash
flutter build apk --debug
```

Expected: `build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 4: Install and launch on the connected Android phone**

```bash
adb connect 192.168.10.9:5555
adb -s 192.168.10.9:5555 install -r -t build/app/outputs/flutter-apk/app-debug.apk
adb -s 192.168.10.9:5555 shell monkey -p com.quranhifz.app.debug -c android.intent.category.LAUNCHER 1
```

- [ ] **Step 5: Perform device visual QA**

Capture/screens inspect:
- Dua landing default daily journey;
- search results using Bangla text;
- a filtered category;
- Favorites empty and populated state;
- long Arabic Dua detail;
- Bangla detail;
- English detail;
- green, women, dark, and light themes;
- bottom navigation showing Home · Dua · Quran · Calendar · More;
- Home current-prayer card remaining readable and non-tracker;
- Quran, Calendar, and More regression screens.

Check specifically for clipped Arabic, white-on-white text, hard-coded blue/green chip leakage, overflow at 360px, and unsafe bottom spacing.

- [ ] **Step 6: Fix only observed feature regressions using RED→GREEN TDD**

For every discovered behavioral defect:
1. add a failing focused test;
2. run it and confirm expected failure;
3. make minimal fix;
4. rerun focused + related regression tests.

- [ ] **Step 7: Final verification and commit**

```bash
flutter analyze
flutter test
git status --short
```

Expected: analyzer clean, complete test suite green, only intended implementation changes present.

Commit any QA fixes:

```bash
git add <only-intended-files>
git commit -m "fix: polish dua library integration"
```

If no QA fix was needed, do not create an empty commit.
