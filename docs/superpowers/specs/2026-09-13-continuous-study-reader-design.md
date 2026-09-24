# Continuous Study Reader Design

## Goal

Make the Quran tab a continuous ayah-by-ayah Study reader optimized for Arabic, Bangla translation, inline tafsir, word interaction, and audio-follow scrolling. Keep the existing Hifz destination separate; a dedicated Mushaf-style Hifz page reader is not part of this change.

## Reader behavior

- `QuranReaderPage` is labeled `Quran · Read` and no longer presents previous/next page controls.
- Quran content is rendered as one continuous scroll across incrementally loaded Quran page windows.
- Small page-boundary labels may remain for orientation, but pages must not behave as separate screens.
- The controller preloads the current page and adjacent windows, then can append/prepend one page window without changing the logical `currentPage` target.
- Scrolling near the bottom loads the next Quran page window. Scrolling near the top loads the previous page window and preserves the user's viewport position after prepending.
- Search can still open a Quran page; after the controller opens the target page, the continuous reader scrolls to that page boundary.

## Audio-follow behavior

- Existing single `QuranAudioController` remains authoritative.
- Word tap playback remains independent and must not move the reader.
- Ayah/sentence playback continues to expose `activeAyahPlaybackKeyProvider`.
- The `ReaderWindow` containing the active ayah calls `Scrollable.ensureVisible` when auto-next changes the ayah.
- Every `AyahCard` visually highlights itself while its ayah is the active ayah playback target. Word-level highlighting continues independently.

## Translation and tafsir

- Existing translation preference continues to hide/show Bangla translation.
- Each ayah card includes a lazy inline tafsir expansion.
- Inline tafsir prefers `primaryBanglaTafsirSourceId` (`তাফসীরে আবু বকর যাকারিয়া`) when installed, otherwise uses the first installed source.
- Tafsir text is loaded only when the inline panel is expanded.
- If no tafsir package is installed, the panel explains that setup/download is required and provides a button to open the existing `TafsirReaderPage` installation flow.
- Existing full-screen tafsir action remains available.

## Out of scope

- Dedicated Mushaf/Hifz page rendering.
- New audio player or playback architecture.
- Exact search-to-ayah targeting beyond the current page result contract.
- New persistence format for reading position.

## Regression requirements

- Word tap audio still works.
- Ayah play/repeat/auto-next still works.
- Offline chapter audio still works.
- Active ayah auto-scroll works in the continuous reader.
- Active word highlighting remains isolated to the matching ayah.
- Existing Hifz session screen remains unchanged.
