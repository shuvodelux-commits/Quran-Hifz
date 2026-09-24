# Surah-Scoped Read Mode and Offline Word Audio Design

## Goal

Match the approved Quran app mockup for the Quran reading flow while preserving the working audio architecture.

## Quran navigation

The Quran tab is a Surah library, not an always-open global page reader. It shows search plus All/Makki/Madani filters and the canonical Surah list. Selecting a Surah pushes a dedicated reader route. The reader is continuous-scroll, but only for the selected Surah. Quran pages are an internal loading boundary only and are not shown as navigation controls. Reaching the end of the Surah never renders the next Surah. The user returns with Back and selects another Surah from the library.

The reader keeps the current working features: word tap playback, word long-press details, ayah playback/repeat/speed, auto-next within the same Surah, active ayah/word highlighting, Bangla translation, inline Tafsir, bookmarks, and reciter settings.

## Offline audio

"Download for offline" means the current Surah is fully usable for listening while offline. The package contains the selected reciter's chapter MP3 and every available per-word pronunciation audio source from the canonical Quran database for that Surah. Word files remain independent files under the existing word-audio key scheme and are resolved by `OfflineAudioResolver` before the remote URL.

Word downloads use limited concurrency to avoid opening hundreds of simultaneous HTTP connections. A failed word download fails the explicit offline-package operation; already-completed files remain reusable and a retry resumes through the existing download repository.

Ordinary online word taps retain the existing best-effort background cache behavior.

## Non-goals

This change does not build the separate Mushaf/Hifz page renderer, redesign the global bottom navigation, change reciter metadata, change ayah timing, or alter the working audio player architecture.

## Acceptance criteria

1. Quran tab opens the Surah list with search and All/Makki/Madani filters.
2. Tapping a Surah opens a continuous reader containing only that Surah.
3. Scrolling cannot reveal the next or previous Surah.
4. Back returns to the Surah list, where another Surah can be selected.
5. Ayah playback, auto-next, auto-scroll, translation, Tafsir and word details continue working.
6. Downloading a Surah for offline also downloads all available word pronunciation files for that Surah.
7. In airplane mode, tapping any downloaded word in that Surah plays from local storage.
