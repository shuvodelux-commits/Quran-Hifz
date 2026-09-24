# Quran Library, Juz Reader, Playback Panel, and Bookmarks Design

## Goal

Replace the Quran library's revelation-place filters with a Surah/Juz/Bookmarks experience, add language-independent fuzzy Surah search, support bounded full-Juz reading, present contextual Surah navigation in the reader, expose a persistent bottom playback panel, and make bookmarks navigable and manageable.

## Product Decisions

- The library has three primary tabs: Surah, Juz, and Bookmarks. The existing All/Makki/Madani control is removed.
- The app follows its existing language preference for interface labels. Surah titles use Bangla names in Bangla mode and English names in English mode, with medium-bold weight.
- Surah search remains usable in either app language. English, Bangla, Arabic, numeric, normalized, abbreviated, and approximate queries are accepted.
- Selecting a Juz opens its first ayah and reading continues across Surah boundaries through the final ayah of that Juz.
- Reader navigation shows the previous, current, and next Surah in a teal horizontal strip. Adjacent items and chevrons navigate when a neighboring Surah exists.
- The playback panel appears only for active ayah playback states (loading, playing, or paused). It is dismissible by stopping playback.
- Bookmark names use the existing persisted `category` value so this feature does not require a user-database schema migration. New bookmarks default to a localized date/time-derived name and can be renamed.
- Existing Hifz, Tafsir, offline audio, translation settings, word playback, and saved reading positions remain available.

## Architecture

### Quran Library Shell

`QuranSurahListPage` remains the Quran destination but becomes a tabbed library screen. A small tab state selects Surah, Juz, or Bookmarks without pushing a separate bookmarks route. Existing shortcut actions may remain above the tabs only where they do not duplicate tab behavior; the standalone bookmark shortcut and revelation-place segmented control are removed.

Each tab owns only its presentation:

- Surah renders the searchable list and quick-scroll rail.
- Juz renders 30 canonical Juz summaries.
- Bookmarks renders the embedded bookmark browser and management actions.

The existing standalone `BookmarksPage` reuses the same bookmark-list body so links from Home and elsewhere continue to work without duplicating behavior.

### Search and Ranking

Surah matching moves from the page widget into a pure search utility so it can be tested independently. It builds aliases from Surah number, Arabic name, English name, and Bangla name. Normalization:

- lowercases Latin input;
- converts Bangla digits to ASCII digits;
- removes punctuation, apostrophes, hyphens, and whitespace;
- strips common English transliteration prefixes such as `al` and `an` for an additional alias, without discarding the original alias;
- folds common transliteration variants such as `ph/f`, doubled letters, and terminal `h/ah` conservatively;
- retains normalized Arabic and Bangla text.

Ranking is deterministic: exact number or exact alias first, then alias prefix, token-prefix/initial similarity, substring, and finally bounded edit-distance similarity. A short query must meet a stricter similarity threshold to avoid flooding results. The requested `al hah` query ranks Al-Fatihah as a result. Search always evaluates all language aliases regardless of current UI language.

### Juz Metadata and Reading Scope

Add a `QuranJuzSummary` domain type containing Juz number, first and last `StudyTarget`, first and last page, and displayable start/end Surah references. Extend `QuranRepository` with `listJuzs()`. `DriftQuranRepository` derives all 30 summaries from canonical `ayahs` using ordered boundary queries joined to Surah metadata. No hard-coded Juz boundaries are used in production.

Generalize the reader's launch input to a scope object:

- `SurahReaderScope` bounds visible ayahs to one Surah and preserves current behavior.
- `JuzReaderScope` bounds visible ayahs to one Juz and permits cross-Surah page content.

The reader controller continues loading bounded page windows and does not load an entire Juz into memory. Presentation filters each loaded window by the active scope. At a shared boundary page, only ayahs belonging to the selected Juz are shown. Pagination stops at the first and last page of the scope. Reading-location persistence records the actual visible Surah and ayah.

### Reader Navigation Strip

The current large Surah information card is replaced at the top by a teal navigation strip styled after the supplied reference. In Surah scope it shows previous/current/next Surah names; unavailable neighbors occupy no tappable target. The current name is medium-bold. In Bangla mode all three names use Bangla metadata, while English mode uses English metadata.

In Juz scope the center label identifies the Juz and the side labels identify the Surahs surrounding the currently visible Surah. Tapping a Surah label deliberately switches to Surah scope for that Surah. Existing Tafsir/download controls move to a compact toolbar so the functionality is retained.

### Playback Panel

Create a reader-specific bottom playback panel backed by `quranAudioControllerProvider`. Extend `QuranAudioState` with clip-relative `position` and `duration`, updated from the audio adapter during ayah playback. Extend `AudioPlayerAdapter` with the minimum duration/seek support required for an interactive progress slider, and implement it in both the Just Audio adapter and test fake.

The panel includes:

- active verse reference and selected reciter name;
- elapsed and total time with a seek slider;
- pause/resume;
- previous and next ayah actions within the current reader scope;
- playback speed cycling through the app's supported values;
- repeat indication/action using the existing repeat preference;
- stop/dismiss.

Previous/next uses repository ayah lookup and respects Surah or Juz boundaries. Loading disables controls that could start conflicting operations. Errors continue through the existing reader message path, and the panel leaves error details to a concise snackbar rather than permanently occupying the screen.

### Bookmarks

Extract an embeddable `BookmarksView` from `BookmarksPage`. It reads persisted bookmarks newest-first by default and can sort newest/oldest. Each bookmark row resolves its ayah and Surah metadata to show:

- bookmark name (`category`);
- localized `surah:ayah` reference;
- translation excerpt;
- creation date;
- overflow actions for rename and delete.

Selecting a bookmark loads its target ayah, determines its page, opens a Surah-scoped reader, and positions the reader at that ayah. Word bookmarks open the containing ayah and may retain the word reference in their subtitle. Rename saves the same target with the new category through the existing upsert behavior. Delete asks for confirmation and refreshes both embedded and standalone bookmark providers.

The ayah bookmark action requests a name when creating a bookmark. If the user confirms without entering a name, it uses a localized date/time label; cancellation makes no change. Removing an existing bookmark remains a direct toggle with confirmation feedback.

Bookmark row data is hydrated in one repository-level batch query rather than issuing one Quran query per list item. The Quran content database remains read-only and bookmark state remains in the user database.

## State and Data Flow

1. The library loads Surah metadata and Juz summaries through Riverpod providers.
2. Search filters the already-loaded 114 Surah summaries synchronously through the pure ranker.
3. A Surah or Juz selection creates the matching reader scope and opens the initial canonical page.
4. The reader loads only current/adjacent pages, filters ayahs to scope, and updates the visible-context header.
5. Starting ayah playback updates the shared audio controller; the reader observes active state and mounts the bottom panel.
6. Bookmark creation and management write through `StudyRepository`, invalidate bookmark data, and update the visible list.
7. Bookmark selection resolves the stored target to canonical content and navigates to the exact ayah.

## Error and Empty States

- If canonical Juz metadata is incomplete, the Juz tab shows the existing retry pattern and does not fabricate boundaries.
- No Surah search matches produce a localized empty result with a clear-query action.
- An empty bookmark tab explains how to add a bookmark from an ayah.
- A bookmark whose canonical target cannot be resolved stays visible but disabled and offers deletion.
- Playback preparation, download, and timing failures preserve the existing offline/stream decision flow and show actionable feedback.
- Rename rejects blank text after trimming unless the default date-derived label is intentionally selected during creation.

## Visual Direction and Accessibility

- Use the app's existing theme colors and typography rather than copying the reference's device chrome.
- Teal is used for the active tab underline, reader strip, and playback panel; surfaces retain sufficient contrast in light and dark themes.
- Surah names use `FontWeight.w600` (medium-bold), not heavy display weight.
- Controls include tooltips and semantic labels; touch targets remain at least 48 logical pixels.
- Long text truncates safely, and the playback panel respects `SafeArea` and compact-width layouts.

## Testing

Follow test-driven development for each behavior:

- unit tests for normalization, Bangla-digit conversion, ranking, typo tolerance, and `al hah` → Al-Fatihah;
- repository tests proving exactly 30 Juz summaries and correct first/last ayah boundaries from fixtures;
- reader-scope tests proving Surah filtering, cross-Surah Juz continuity, and boundary stops;
- widget tests for the three tabs, localized medium-bold names, cross-language search, and empty states;
- widget tests for the previous/current/next reader strip and navigation;
- controller and widget tests for playback position, seeking, pause/resume, previous/next, speed, repeat, and dismissal;
- bookmark tests for create/name, batch hydration, sort, rename, delete, persistence, and navigation to the exact ayah;
- regression tests for existing reader playback following, offline prompts, Tafsir access, and ayah bookmark behavior.

Final verification runs formatting, focused tests during each red/green cycle, the complete Flutter test suite, and `flutter analyze`.

## Out of Scope

- Cloud bookmark synchronization or multiple user profiles.
- New Quran or translation content sources.
- A global background mini-player outside the Quran reader.
- Playlists, bookmark folders, or bulk bookmark operations beyond selection and sorting.
- Replacing the existing audio download and timing architecture.
