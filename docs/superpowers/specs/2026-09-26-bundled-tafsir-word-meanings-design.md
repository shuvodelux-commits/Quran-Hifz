# Quran Hifz — Bundled Zakaria Tafsir and Offline Bangla Word Meanings

Date: 2026-09-26  
Status: Approved design

## Intent

A fresh install must provide the primary Bangla Tafsir and tapped-word Bangla meanings without any network download.

The primary Tafsir remains Dr. Abu Bakar Muhammad Zakaria from the existing QuranEnc source. It must behave like the current downloaded Tafsir: each ayah shows the source translation plus its optional Tafsir footnotes, with the same attribution and source identity.

Cloudflare and Quran Foundation remain available only for optional additional Tafsir sources and future content updates. They are not required for the default reading experience.

## Success criteria

On a clean install with the device offline:

- Quran reading opens from the bundled canonical Quran database.
- “Tap to show Bangla word meaning” works for every canonical Quran word.
- Dr. Abu Bakar Muhammad Zakaria appears as an installed Tafsir source.
- Zakaria is the default Tafsir source.
- Opening ayah Tafsir and whole-Surah Tafsir requires no download.
- Surah and ayah Tafsir output matches the existing Zakaria content mapping.
- No first-run Tafsir extraction creates a 16–29 MB duplicate database in app storage.

## Current state

The canonical Quran asset already contains 114 Surahs, 6,236 ayahs, and 77,429 Quran word rows. Its `quran_words.bangla_meaning` column exists but is currently empty for all 77,429 rows.

Bangla word meanings are currently fetched at runtime from the Quran.com Content API and may be cached per Surah in the user database. Therefore the tap-to-meaning feature is not guaranteed offline on first install.

Zakaria Tafsir is currently distributed as a downloadable SQLite package. The package is registered in `installed_tafsir_packages` only after Cloudflare manifest retrieval, download, checksum verification, and installation.

The current Zakaria package builder stores the original QuranEnc translation and footnotes in `source_entries`, then stores non-empty footnotes again in `tafsir_entries`. That duplicates the large Tafsir text.

Measured against the current QuranEnc Zakaria source:

- 6,236 source ayahs.
- Translation UTF-8 text: about 2.08 MiB.
- Tafsir footnotes UTF-8 text: about 10.83 MiB.
- Non-empty footnotes: 3,608 ayahs.
- Full translation + footnotes as per-Surah compressed payloads: about 2.6 MiB.
- Complete Bangla word meanings: 77,429 records, about 2.16 MiB raw text and about 0.61 MiB gzip-compressed.

## Non-goals

This change does not replace the canonical Quran text, change Quran fonts, change Tafsir wording, or merge Tafsir into Quran translation UI.

This change does not require users to download every optional Tafsir. Only the primary Zakaria Tafsir and Bangla word meanings are bundled by default.

## Architecture

The Tafsir layer becomes a composite repository with two backing sources:

1. **Bundled Zakaria repository** — reads immutable compressed assets shipped inside the APK.
2. **Installed Tafsir repository** — keeps the existing SQLite package registry for optional downloaded sources.

The public `TafsirRepository` interface remains the reader-facing boundary. The UI does not need to know whether a source is bundled or downloaded.

The stable Zakaria source id remains `bn.abubakar_zakaria.quranenc`. The composite repository exposes that source exactly once.

If a valid downloaded package with the same source id exists, it may override the bundled copy only when it represents an explicitly installed newer source version. If it is missing, corrupt, or removed, the bundled source remains the fallback.

Fresh installs have no registry dependency for Zakaria. Absence of an `installed_tafsir_packages` row must not make the bundled source disappear.

## Bundled Zakaria asset format

Zakaria content is built at release time from the approved QuranEnc `bengali_zakaria` source.

The builder emits one compressed asset per Surah under a versioned directory, for example:

`assets/tafsir/zakaria/1.1.1/001.json.gz`

Each Surah payload contains:

- source id and version;
- Surah number;
- all ayah numbers in canonical order;
- original QuranEnc `translation` text;
- original QuranEnc `footnotes` text.

The payload is compressed as part of the build artifact and read directly from the Flutter asset bundle. It is not unpacked into a second permanent SQLite file on first launch.

At runtime, the bundled repository decodes only the requested Surah and keeps at most a small in-memory cache. Whole-Surah Tafsir therefore requires one compressed asset read, while single-ayah Tafsir may reuse the same decoded Surah cache.

The reader-facing Tafsir text keeps the existing behavior:

- plain translation only when footnotes are empty;
- translation, then a blank line, then footnotes when both exist;
- HTML-like source markup is normalized using the same plain-text rules already used by `LocalTafsirRepository`.

The builder retains source attribution, version, source page, terms URL, publisher, and content mapping in a bundled manifest so the UI can show the same source metadata as the current downloaded package.

## Zakaria build verification

The release builder must fail unless all of these conditions are true:

- canonical Quran database contains exactly 114 Surahs and 6,236 ayahs;
- the QuranEnc response contains exactly the expected ayah count for every Surah;
- each source `sura` and `aya` matches the canonical position;
- `translation` and `footnotes` are strings;
- every generated Surah payload can be decompressed and parsed;
- generated source id and version match the bundled manifest;
- a deterministic SHA-256 is recorded for every bundled payload or for the bundled package manifest.

The source strings are not rewritten during content generation.

## Offline Bangla word meanings

Bangla word meanings become part of the canonical Quran content build rather than a first-use network feature.

The production content builder fetches Bangla word translations from the same Quran.com / Quran Foundation content source currently used by `QuranComBengaliWordMeanings`.

For each canonical `quran_words` row, the builder writes the validated Bangla meaning into `quran_words.bangla_meaning`.

The build gate requires:

- exactly 77,429 canonical Quran word rows;
- exactly one matching Bangla meaning for every canonical word position;
- matching Surah, ayah, and word position;
- non-empty normalized display text;
- no extra word records outside canonical bounds.

If any canonical word lacks a meaning, the production content build fails. The app must not silently ship partial offline coverage.

At runtime, `DriftQuranRepository` continues returning `QuranWord.banglaMeaning`. Existing Quran reader and study UI therefore use local data first without a new presentation API.

The existing network-backed `BengaliWordMeanings` service may remain as a compatibility fallback for old development databases, but a production build must not require it for normal tapped-word behavior.

## First-install and upgrade flow

The existing Quran content bootstrap remains responsible for installing the canonical Quran database from the APK asset into the app data directory.

Because Bangla word meanings are stored in that database, no additional first-run word-meaning migration or download is required.

The bundled Zakaria Tafsir is read directly from APK assets and does not require registration in `installed_tafsir_packages`.

On app upgrade, a new canonical Quran manifest/hash causes the normal Quran content installer to replace the old canonical database with the new verified database containing Bangla meanings.

Existing users who previously downloaded Zakaria keep that package record. The composite repository de-duplicates the source id and prefers a valid newer downloaded Zakaria package over the bundled version; otherwise it falls back to the bundled version.

## Default Tafsir selection

A fresh install selects `bn.abubakar_zakaria.quranenc` by default.

The selected Tafsir source id is persisted in user settings so a user who later chooses another source keeps that choice across app restarts.

Selection resolution is deterministic:

1. use the persisted source when that source is currently available;
2. otherwise use bundled Zakaria;
3. otherwise use the first available installed source only as a defensive fallback.

Because bundled Zakaria is a release asset, step 2 should always succeed in production.

The Tafsir reader no longer presents “Download Tafsir” as the empty-state path for Zakaria. The primary source is immediately readable.

## Optional additional Tafsirs

Cloudflare and Quran Foundation are optional source/catalog paths, not bootstrap dependencies.

The existing Cloudflare-backed package mechanism remains valid for downloadable offline Tafsirs.

A Quran Foundation integration may expose additional Tafsir resources through the application backend. Mobile code must not embed private Quran Foundation credentials.

Additional sources are shown in the Tafsir source selector separately from the built-in Zakaria source.

Selecting or downloading another Tafsir must never delete, disable, or mutate the bundled Zakaria assets.

The first implementation of this spec does not require every Quran Foundation Tafsir to be downloadable offline. The architecture only requires that optional remote/downloaded sources can coexist behind the same `TafsirRepository` source-selection model.

## Error handling

Bundled Zakaria read failures are treated as packaged-content integrity errors, not network errors.

If a bundled Surah asset is missing, corrupt, has the wrong source id/version, or cannot be decoded, the Tafsir reader shows a local-content error with retry/restart guidance. It must not silently substitute unrelated Tafsir text.

Downloaded optional Tafsir failures remain isolated to that source. If the selected downloaded source becomes unavailable, source resolution falls back to bundled Zakaria.

Tapped Bangla word meaning uses `QuranWord.banglaMeaning` immediately. A missing meaning in a production database is an integrity defect; the UI may show the existing unavailable state, but no production release may intentionally depend on a network request to fill the gap.

## Storage and performance

The design optimizes both APK size and post-install storage:

- Zakaria is kept compressed in APK assets and is not permanently expanded into a large SQLite copy.
- Only one requested Surah is decoded at a time, with a small bounded memory cache.
- Bangla word meanings reuse the existing canonical Quran SQLite file rather than creating a second word-meaning database.
- Existing user settings no longer need per-Surah Bangla word JSON on fresh production installs.

The release pipeline must report the APK/AAB size delta and installed app-data delta so the compact-content assumption is measured rather than inferred.

## Privacy and networking

Opening the default Tafsir or tapping a Quran word must generate no network request after this change.

Network access is allowed only for explicitly optional actions such as browsing additional Tafsir sources, downloading another Tafsir, or fetching a content update.

No Quran Foundation private credential is stored in the APK. Credentialed Quran Foundation calls go through the app backend.

## Source provenance

Zakaria source identity, author, publisher, version, source URL, terms URL, attribution, and content mapping remain visible in the bundled manifest.

Bangla word-meaning source/version metadata is recorded in the canonical Quran content manifest so the release can identify exactly which upstream word-translation snapshot was bundled.

## UI behavior

The Tafsir reader keeps its existing reading layout.

For a fresh install:

- Zakaria appears immediately in the source selector.
- Zakaria is already selected.
- There is no download CTA before first reading.
- Whole-Surah and single-ayah Tafsir work offline.
- If additional sources are available later, the existing source selector exposes them without changing the default bundled source.

The Quran reader keeps the current “Tap to show Bangla word meaning” preference. The default remains enabled. Tapping a word displays the bundled Bangla meaning immediately.

No separate “download Bangla words” action is shown in production once complete local coverage ships.

## Testing strategy

Automated tests must cover the following release-critical behaviors.

### Content builder tests

- Zakaria source: 114 Surahs and 6,236 ayahs.
- Zakaria payload round-trip preserves translation and footnote strings.
- Corrupt/missing source rows fail the build.
- Each generated Surah payload decompresses and validates.
- Bangla word source maps exactly to all 77,429 canonical word positions.
- Missing, duplicate, extra, or empty Bangla word meanings fail the build.
- Canonical database reports zero empty `bangla_meaning` rows after generation.

### Repository tests

- Bundled Zakaria is listed when no downloaded Tafsir exists.
- Single-ayah and whole-Surah reads reproduce current Zakaria combined text.
- A valid newer installed Zakaria package overrides the bundled copy without duplicating the source list.
- Missing/corrupt installed override falls back to bundled Zakaria.
- Another downloaded Tafsir coexists with bundled Zakaria.

### Bootstrap and UI tests

- Fresh-install Tafsir view defaults to Zakaria without invoking the package installer.
- Default Tafsir reading succeeds with network clients unavailable.
- Persisted alternative source selection is restored when that source exists.
- Missing persisted source falls back to Zakaria.
- Tapping a Quran word with production content reads local `bangla_meaning` and performs no HTTP request.
- Existing tap-to-show preference still controls visibility.
- Existing Tafsir source selector still works with more than one source.

### Upgrade tests

- Existing downloaded Zakaria package records remain readable.
- The composite repository de-duplicates bundled and downloaded copies of the same source id.
- Canonical Quran content upgrade replaces an older database that lacks Bangla meanings.
- User preferences and unrelated downloaded content survive the Quran database upgrade.

## Expected code boundaries

Implementation should keep responsibilities separated:

- `tool/tafsir/` — verified Zakaria source fetch/build and compact bundled payload generation.
- `assets/tafsir/zakaria/` — immutable built-in Tafsir assets and manifest.
- `lib/features/tafsir/data/` — bundled repository plus composition with existing local/downloaded repository.
- `lib/features/tafsir/application/` — provider wiring and selected-source persistence.
- `tool/quran_content/` — Bangla word-meaning source fetch, validation, and DB population.
- `assets/database/quran_content.sqlite` and manifest — canonical Quran plus local Bangla word meanings.
- Existing Quran presentation widgets remain consumers of `QuranWord.banglaMeaning`; they should not gain content-download logic.

## Release acceptance

A release is acceptable only when a clean-install test can place the device offline before first Quran/Tafsir use and still demonstrate:

1. Quran reading works.
2. Every tested word meaning opens locally.
3. Zakaria single-ayah Tafsir works.
4. Zakaria whole-Surah Tafsir works.
5. Zakaria is the selected default.
6. No Tafsir or word-meaning network request is observed.

