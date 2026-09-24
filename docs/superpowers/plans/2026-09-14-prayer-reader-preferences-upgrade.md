# Prayer, Reader, and Preferences Upgrade Implementation Plan

**Goal:** Give the existing Quran app Bangladesh prayer settings, Bangla/English presentation, a subtle women’s theme, faster Quran navigation, and reliable reader audio/word meanings.

**Architecture:** Persist user choices through the existing `AppPreferences` repository. Keep AlAdhan method 1 (University of Islamic Sciences, Karachi), varying only the Asr school between Ahle Hadith (standard, shadow factor 1) and Hanafi (factor 2). Use a curated Bangladesh location catalog for manual selection, with GPS as the default. Reuse existing reading-progress storage for last-read prompts; retrieve Bengali word glosses on demand because the bundled 77,429 canonical word rows contain no Bengali glosses.

**Tech stack:** Flutter, Riverpod, Drift/SQLite, HTTP, existing audio controller and Quran repository.

**References:** User screenshots supplied in this conversation; [Quran Foundation words API](https://api-docs.quran.com/docs/content_apis_versioned/4.0.0/verses-by-chapter-number/); [AlAdhan API](https://aladhan.com/prayer-times-api).

## Global constraints

- Preserve the bundled canonical Quran text and the existing user database.
- Keep prayer calculation method 1, with Ahle Hadith/standard Asr as school 0 and Hanafi Asr as school 1.
- Manual prayer locations must be in Bangladesh; the selected location applies to both home and calendar.
- Default to Bangla UI and Hanafi prayer times for existing users; allow English and Ahle Hadith.
- Bengali word meanings fetched from Quran Foundation are displayed within the app and are not repackaged into the bundled database.
- Use the existing Quran audio controller for play/stop state and the existing reading-progress store for last-read behavior.

---

### Task 1: Playback control and word popup

**Files:** `lib/features/quran/presentation/widgets/ayah_card.dart`, `lib/features/quran/presentation/widgets/quran_word_view.dart`, new `lib/features/quran/data/bengali_word_meanings.dart`; corresponding reader/widget and data tests.

**Interface:** `BengaliWordMeanings.loadAyah(String ayahKey)` returns a position-to-meaning map; `AyahCard` consumes the current audio status.

- [ ] Add a widget test: a playing ayah shows Stop and tapping it stops playback; completed/idle state shows Play.
- [ ] Run the test and confirm it fails for the missing behavior.
- [ ] Bind the action icon, tooltip, and tap handler to the audio mode/status/ayah key; retain playback options.
- [ ] Add a data test for Bengali gloss parsing by ayah key/word position and a word-tap widget test for loaded/failed responses.
- [ ] Run the tests red, implement an on-demand Quran API request with timeout, and run green.

### Task 2: Prayer school and Bangladesh location

**Files:** `lib/features/settings/domain/app_preferences.dart`, application/data preference files, `lib/features/home/data/prayer_schedule.dart`, new Bangladesh location catalog and location picker, home/calendar providers, settings page; corresponding tests.

**Interface:** `AsrSchool.standard` emits AlAdhan `school=0`; `AsrSchool.hanafi` emits `school=1`. A nullable selected Bangladesh city replaces GPS coordinates only when chosen.

- [ ] Add tests for persisted school/location and request URI parameters; verify red.
- [ ] Implement the preferences and make daily/monthly prayer requests observe them.
- [ ] Add a searchable Bangladesh city picker in Settings and a location action on Home; use GPS choice to clear the override.
- [ ] Verify that changing school or city refreshes home and calendar schedules.

### Task 3: Language, dates, and women’s theme

**Files:** preference model/controller/storage, app theme, settings, shared localization helpers, home dashboard, calendar, prayer tracker, shell, Quran list; corresponding tests.

**Interface:** `AppLanguage.bangla/english`; `AppThemePreference.women` is a light rose palette. Shared localized digit/date/time/prayer-name helpers prevent duplicated formatting.

- [ ] Add tests for language/theme persistence and localized home prayer/date presentation; verify red.
- [ ] Add Bangla and English choices in Settings, defaulting to Bangla; localize the primary app flow and all home dates/times.
- [ ] Add the women’s theme choice and apply a restrained rose seed and surfaces across the app.
- [ ] Verify settings take effect without restarting.

### Task 4: Quran landing and reading progress

**Files:** Quran surah list, reader page, existing reading location store, search/bookmark/Tafsir/Hifz routes; corresponding widget tests.

**Interface:** The Quran landing page has Hifz, Tafsir, Search, and Bookmark shortcuts, plus Last Read and quick links. Entering a surah with saved progress for that surah offers “Continue” or “Start”; choosing Continue opens the saved page.

- [ ] Add tests for landing shortcuts, last-read prompt, and selected start page; verify red.
- [ ] Implement the landing cards and route actions using existing pages.
- [ ] Preserve and reuse saved page/ayah across reader entry and scroll.
- [ ] Add a subtle draggable 1–114 index alongside the surah list; dragging changes position and shows the selected number.
- [ ] Run Quran reader/list tests and check narrow-screen layout.

### Task 5: Review and delivery

- [ ] Recheck every requested behavior against this plan and the supplied screenshots.
- [ ] Run `dart format`, focused tests, the full Flutter test suite, `flutter analyze --no-pub`, and `flutter build apk --debug --no-pub`.
- [ ] Install and launch the new build on the already-authorized connected Oppo phone if it remains available; report the package actually opened.
