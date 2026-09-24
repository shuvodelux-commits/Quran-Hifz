# Quran Reader, Reciter, Offline Audio, and Hifz UX Redesign

**Date:** 2026-09-13
**Status:** Approved design, written specification pending user review

## 1. Goal

Restructure Quran Hifz V1 around a Surah-first Quran reading experience with a Mushaf-like Arabic reader, reliable offline-first reciter metadata and Surah audio downloads, exact ayah navigation/highlighting, word tap audio, richer Bangla word details, persistent reading position, and integrated Hifz controls.

The app must remain usable for Quran reading without a network connection after installation. Runtime mobile code must never contain Quran Foundation client secrets.

## 2. Confirmed Current-State Findings

- Canonical Quran SQLite content boots and Quran reading/navigation work on the physical Android device.
- Word tap-to-play works on the physical Android device after fixing the Android foreground-service notification icon.
- Search currently navigates by page rather than by exact ayah target.
- The reciter catalog and chapter-audio metadata currently depend on `QURAN_BACKEND_URL`.
- The default backend URL is `https://example.invalid`, so a normal mobile build cannot load the reciter catalog or prepare chapter downloads without an explicitly deployed backend.
- Word audio is independent of that backend because it resolves Quran word-audio paths against `https://audio.qurancdn.com/`.
- The current reader is ayah-card based rather than Mushaf-like.
- Current imported Quran words do not yet provide sufficient Bangla word-by-word meaning/morphology for the requested long-press experience.

## 3. Source and Security Rules

Quran Foundation Content API credentials are build/server secrets only. They must never be embedded in Flutter assets, Dart defines shipped to the app, Android resources, or APK/AAB metadata.

The build/import pipeline may authenticate to Quran Foundation and materialize a verified runtime-safe audio catalog containing only public metadata required by the app, such as reciter IDs/names, Surah numbers, public audio URLs, formats, sizes when available, and timing/segment data required for ayah playback and highlighting.

The app must not depend on a live authenticated Quran Foundation request for basic reciter selection or already-supported reciter playback.

## 4. Delivery Decomposition

This redesign is split into four independently testable subprojects.

### A. Offline-first reciter and chapter-audio foundation

This is the first implementation phase.

Build-time tooling generates a versioned bundled reciter manifest from verified Quran Foundation data. Runtime loads this bundle immediately, so the reciter screen is never empty merely because a backend is absent.

For every V1-supported reciter, the generated metadata must be sufficient to:

- show the reciter offline;
- select and persist the reciter;
- identify each of the 114 Surah audio files;
- download a selected Surah directly from its verified public audio URL;
- resume interrupted downloads through the existing file downloader;
- store the resulting local file path in the user database;
- play downloaded audio without network access;
- expose timing metadata required by ayah repeat, auto-next, and highlighting.

The runtime catalog source order is:

1. bundled verified catalog, always available;
2. locally cached newer catalog/package, when present;
3. optional remote refresh path, when configured;
4. bundled catalog remains the fallback if refresh fails.

The placeholder backend URL must never be a blocking runtime path. A production build must not show “Reciter catalog is unavailable” merely because no backend URL was defined.

The existing `FileAudioDownloadRepository` remains the file transfer/storage component. Audio is stored as files, not SQLite BLOBs.

### B. Surah-first navigation and exact reading position

The Quran tab opens a Surah Library rather than opening an arbitrary Quran page directly.

Each Surah row displays:

- Surah number;
- Arabic name;
- localized name;
- ayah count;
- reading progress when available.

A Continue Reading card appears when a saved location exists. Selecting a Surah with saved progress offers:

- Continue from the saved ayah/position;
- Start from the beginning.

A navigation target is no longer represented by page number alone. The reader target contains at minimum:

- `surahNumber`;
- `ayahNumber`;
- `pageNumber` when known;
- optional `wordPosition` for future deep links.

Search results carry this exact target. Tapping a search result opens the reader at the exact ayah, scrolls it into view, and temporarily highlights it. Back returns to search results.

### C. Mushaf-style interactive Quran reader and bottom player

Replace the current card-first presentation with an Arabic-first Quran surface.

Reading mode requirements:

- Arabic text is the dominant content;
- ayah-end markers remain inline;
- individual words remain tappable;
- long press opens word details;
- roughly 9–10 comfortable Arabic lines should be visible on a typical phone viewport, while respecting canonical line metadata where available;
- translation is optional/secondary and does not break the primary Arabic layout;
- current ayah receives a subtle playback highlight;
- current spoken word receives a stronger highlight when timing data supports it.

The reader owns one persistent bottom audio player rather than embedding a separate player in every ayah card.

Collapsed player shows:

- current ayah;
- selected reciter;
- previous/play-pause/next;
- current repeat setting.

Expanded player exposes:

- reciter selection;
- repeat count: 1, 2, 3, 5, 10, infinite;
- pause between repetitions;
- playback speed;
- auto-next;
- range repeat;
- download current Surah;
- offline/download state.

Direct word tap remains independent: one tap immediately plays that word without requiring chapter playback to be active.

### D. Integrated Hifz and richer word details

Hifz mode uses the same Quran renderer rather than requiring the learner to reason primarily through numeric form fields.

The learner selects a start/end ayah in context, chooses a Hifz preset and reciter, then starts the session. Hifz uses the same local/remote chapter-audio resolver as Reading mode.

A persisted running Hifz session resumes after closing and reopening the app.

Long-press word details must eventually show, when verified source data is available:

- Arabic word;
- pronunciation/transliteration;
- Bangla word meaning;
- English meaning when available;
- root;
- lemma;
- grammar/morphology;
- ayah reference;
- Zakaria Bangla ayah translation;
- action to open Zakaria tafsir;
- word-audio action;
- bookmark/note actions.

Bangla word meanings and morphology must come from an identified source with acceptable licensing/provenance. The app must not fabricate Quran word meanings with generated translation.

## 5. Reciter Metadata Packaging

The build pipeline produces a deterministic versioned artifact, for example:

`assets/audio/reciter_catalog_v1.json`

The manifest records a schema version, source/provenance metadata, generation timestamp, and supported reciters. Each supported reciter includes 114 chapter records.

A chapter record includes the stable identifiers and fields required by runtime. Timing data may be represented inline or as per-reciter/per-Surah generated files if that materially reduces startup memory use. Runtime must not parse timing data for all 114 Surahs simply to render the reciter selector.

The generated artifact receives a SHA-256 manifest/check in the same spirit as the canonical Quran database build. The release preflight verifies the audio catalog exists and is structurally valid.

No audio MP3 is bundled in the APK in V1 unless explicitly chosen later. The APK bundles metadata; users download Surah audio on demand.

## 6. Download and Playback State

Chapter audio lifecycle:

`notDownloaded -> queued -> downloading -> downloaded`

Failure states retain an actionable error code and allow retry. Partial `.part` files remain resumable through the current downloader.

A Surah is considered offline-ready for a selected reciter only when the final audio file is valid and its database record points to the local path.

Playback resolution order:

1. valid local chapter file;
2. verified remote chapter URL from bundled/cached manifest;
3. explicit error state if neither exists.

The user should never need to know whether metadata came from the bundled or refreshed catalog.

## 7. Error Handling and UX

Reciter catalog errors and audio download errors are distinct.

- Bundled catalog parse failure is a release/build defect and is covered by tests/preflight.
- Optional remote refresh failure does not hide the bundled catalog.
- Download failure displays the actual category where possible: network, insufficient storage, HTTP status, invalid file, cancellation, or unknown.
- Hifz does not start chapter playback without a selected usable reciter, but the UI presents reciter selection directly rather than a dead-end message.
- Download progress is visible and cancellable.

## 8. Android Audio Requirements

The validated Android notification fix remains mandatory:

- AudioService notification has a valid small icon;
- background audio uses the media notification channel;
- word tap must not crash the process;
- chapter playback and downloaded audio must use the same background-audio integration;
- lock-screen/media controls are tested on a physical device.

Debug and release use separate application IDs so both builds can coexist during device testing.

## 9. Persistence

User database persists at minimum:

- selected reciter ID;
- reading location by Surah/ayah;
- latest global reading location for Continue Reading;
- audio source/local path/download status;
- Hifz checkpoint;
- bookmarks and notes already supported by the application.

Persisted IDs must remain stable across catalog refreshes. If a selected reciter disappears from a future supported catalog, the app asks the user to choose another reciter and does not silently select an unrelated one.

## 10. Testing Strategy

Every phase uses unit/widget tests before physical-device E2E.

Audio foundation tests cover:

- bundled catalog loads with network/backend unavailable;
- selected reciter persists;
- all supported reciters have valid IDs and chapter coverage;
- every supported reciter has exactly 114 chapter mappings;
- invalid or duplicate manifest data is rejected;
- direct chapter download request uses manifest URL, not `example.invalid`;
- completed local file wins over remote URL;
- failed remote refresh falls back to bundle;
- resume/cancel/storage behavior of existing downloader remains green.

Navigation/reader tests cover:

- Surah Library is Quran entry screen;
- Continue Reading restores exact location;
- search opens exact ayah and back restores search;
- playing ayah highlights the right ayah;
- playing a word highlights/plays the selected word;
- Hifz selection works from Quran context.

Physical Android release QA covers:

- cold launch and canonical DB;
- Surah selection and resume;
- word tap without process crash;
- reciter selection with no backend configured;
- Surah download over network;
- downloaded Surah playback in airplane mode;
- repeat/auto-next;
- background playback and lock-screen controls;
- Hifz pause/close/reopen/resume;
- search exact-ayah navigation;
- Zakaria translation/tafsir availability.

## 11. Release Gates

A release is blocked if any of these are true:

- canonical Quran DB validation fails;
- bundled reciter catalog is missing or malformed;
- no supported reciter has complete 114-Surah metadata;
- Android background-audio notification configuration is invalid;
- release signing preflight fails;
- analyzer/unit/widget/integration tests fail;
- physical-device word tap crashes;
- downloaded Surah cannot play in airplane mode.

## 12. Implementation Order

1. Offline-first reciter/audio foundation.
2. Surah-first navigation and exact reading position.
3. Mushaf-style reader and persistent bottom audio player.
4. Integrated Hifz and richer Bangla word details.
5. Full release regression and physical-device production matrix.

This order intentionally makes audio reliable before the new UI depends on it.
