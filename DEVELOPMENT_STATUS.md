# Quran Hifz V1 Development Status

Branch: `feat/v1-foundation`

## Completed source work

### M00 Foundation

- Migrated app composition to Riverpod.
- Replaced prototype sqflite storage with Drift-based `UserDatabase` and `QuranContentDatabase` foundations.
- Migrated existing audio download/resolver/sync consumers to `UserDatabase`.
- Added database migration/bootstrap tests.

Commit: `d0ea88c refactor: establish Riverpod and Drift foundation`

### M01 Canonical Quran content tooling

- Added source-neutral normalized source models.
- Added canonical SQLite schema.
- Added production integrity validator with:
  - exactly 114 Surahs;
  - exactly 6236 ayahs;
  - canonical per-Surah ayah counts;
  - Surah metadata count validation;
  - unique and correctly formed verse keys;
  - non-empty Arabic ayah text;
  - unique word positions per ayah;
  - orphan word/translation detection;
  - page 1..604 and Juz 1..30 validation.
- Added deterministic DB builder.
- Added SHA-256 source/database provenance report.
- Added strict normalized JSON parsing.
- Added release/build documentation and tests.

Commit: `9ea3972 feat: add validated Quran content pipeline tooling`

## Deliberately not generated

`assets/database/quran_content.sqlite` is NOT present yet.

The production database must be generated only from approved verified source packages. The project currently does not contain the approved canonical Quran + word metadata + Bangla translation source files or Quran Foundation credentials.

Do not replace this gate with demo or scraped Quran content.

## Environment limitation of this execution

This sandbox has no Flutter/Dart SDK and outbound SDK download is blocked. Therefore the following checks have not been claimed as passing:

```bash
dart format .
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Static checks performed here:

- `git diff --check` passed.
- canonical per-Surah count map contains 114 entries summing to 6236.
- `schema.sql` was executed with SQLite and key integrity constraints were probed successfully.
- no fabricated Quran database was bundled.

## Next executable gate

On a machine with Flutter 3.47.2 / Dart >=3.12:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
```

Then provide/approve normalized source files and run:

```bash
dart run tool/quran_content/build_quran_db.dart \
  --quran <verified-quran-source.json> \
  --words <verified-word-source.json> \
  --translation <verified-bangla-source.json> \
  --out assets/database/quran_content.sqlite
```

Only after the generated DB and report pass the integrity gate should M02/M03 reader installation and runtime wiring consume that artifact.

## M02 Canonical installer + bounded reader infrastructure

Implemented on branch `feat/m02-reader`:

- Added `QuranContentInstaller` with checksum, schema-version and content-version verification.
- Installation uses temporary files and preserves the previous verified DB when replacement validation fails.
- Canonical generated DB schema now sets `PRAGMA user_version = 1` for Drift compatibility.
- Added read-only `QuranContentDatabase.forPath()` and test constructor.
- Added canonical page/window domain contracts and lightweight Surah summaries.
- Added `DriftQuranRepository` using one bounded page join for ayahs + words + selected translation.
- Normalized V1's bundled primary Bangla translation to internal resource id `1`; upstream resource id is retained in provenance metadata.
- Added Riverpod `ReaderController` with previous/current/next page windows only.
- Adjacent page windows are prefetched and reused on navigation instead of being queried again.
- Reading location persists through a dedicated user-DB seam.
- Reader UI now uses lazy slivers, stable ayah/word keys, RTL word layout, translation visibility toggle, and retains long-press word details.
- Demo content remains behind one development provider switch only because the approved production Quran asset is still unavailable. It is a release blocker and must not ship.

Static/SQLite verification performed in this sandbox:

- `git diff --check` passes.
- raw canonical schema reports `user_version = 1`.
- required page/Juz/word/translation indexes are present.
- page query returns words in `(surah, ayah, position)` order.
- no runtime code uses the removed whole-Surah `getSurah()` repository API.

Flutter/Dart compilation, Drift code generation, widget tests and analyzer remain unverified here because this sandbox has no Flutter/Dart SDK.

## M11 Offline Quran Search + optional Tafsir packages

Implemented on branch `feat/v1-offline-search-tafsir`:

- Added local Quran search for exact `surah:ayah`, Surah number, Arabic/English/Bangla Surah names, and Bangla translation phrases.
- Search is fully local and uses parameterized queries against the canonical Quran database.
- Search results return a page number and reader navigation opens the selected Quran page.
- Added user-database schema v8 with an installed-tafsir package registry; v1 migration coverage preserves existing user state.
- Added source-neutral `TafsirPackageManifest` with safe package identity validation.
- Added tafsir package installer with pre-write storage check, exact-size validation, SHA-256 validation, SQLite `quick_check`, required-schema validation, manifest identity validation, canonical ayah-bound validation, `.part` cleanup, and atomic final-file replacement.
- Tafsir content remains physically separate from canonical Quran content and cannot modify the canonical database.
- Added local tafsir repository and attributed tafsir reader UI.
- Added per-ayah `Open tafsir` action without adding database queries to the reader scrolling hot path.
- Removed the old inline/demo `shortTafsir` display path from `AyahCard` so production tafsir comes only from an installed attributed source.
- Added `docs/content/tafsir-package-format.md`.

Source-level/SQLite verification performed in this sandbox:

- `git diff --check` passes.
- All relative Dart imports resolve to files in the repository.
- Search SQL executed successfully against a SQLite fixture for `2:255`, English Surah name and Bangla translation phrase lookup.
- Tafsir package fixture passes SQLite `quick_check`, manifest metadata and canonical ayah-bound checks.
- Search/Tafsir contain no `just_audio` dependency.
- Tafsir contains no canonical-Quran write path.
- User-database source contains schema v8 and the `installed_tafsir_packages` migration.

Still unverified because Flutter/Dart SDK is unavailable in this sandbox:

```bash
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
```

No production tafsir text is bundled. An approved/licensed source and manifest are still required before shipping offline tafsir content.

## Primary Bangla Tafsir source — Abu Bakar Zakaria

Selected and wired the primary Bangla tafsir source as Dr. Abu Bakar Muhammad Zakaria via QuranEnc key `bengali_zakaria`.

- Added deterministic release builder `tool/tafsir/build_zakaria_package.py`.
- Builder preserves QuranEnc `translation` and `footnotes` fields unchanged in an audit table and exposes only non-empty footnotes as tafsir entries.
- Generated packages carry source/version/author/attribution/terms metadata, SQLite integrity, SHA-256 and exact byte size.
- Added backend `/api/tafsir/bn-zakaria/manifest`, which refuses to serve a manifest until HTTPS URL, SHA-256, exact size and verified version are configured.
- Flutter now treats `bn.abubakar_zakaria.quranenc` as the primary Bangla tafsir source and offers its verified offline download from the empty Tafsir screen.
- Installed Zakaria is preferred automatically when multiple tafsir packages are available.

Verified in this sandbox:

- Python Zakaria package-builder tests pass (3/3).
- Node backend manifest tests pass (3/3) with Node type stripping enabled for the isolated TypeScript unit.
- `git diff --check` passes.

Still requires the Flutter/Dart toolchain before release: `dart format`, Drift/build_runner, `flutter analyze`, `flutter test`, and Android device verification.
The production Zakaria SQLite file is intentionally not fabricated in this sandbox; it must be generated from the live official QuranEnc source and the verified canonical Quran DB.

## Android release hardening

Added a fail-fast production release gate independent of the canonical-content fetch:

- Release builds no longer use Flutter's debug signing key.
- `android/key.properties` + private keystore signing is supported without committing secrets.
- Release-task configuration fails fast when signing properties are absent.
- Added `tool/release/check_release_ready.py` to verify:
  - canonical Quran DB + manifest + provenance report;
  - database SHA-256 against the package manifest;
  - dedicated Android release signing + keystore presence;
  - complete Gradle wrapper files;
  - Android foreground/background MediaSession wiring.
- Added isolated Python regression tests for the release checker and signing guard.
- Added Android release/signing documentation.

The current source tree intentionally fails release preflight until the real canonical Quran package, private signing configuration, and materialized Gradle wrapper are supplied on the developer workstation.

## Offline-first reciter and Surah audio foundation source — 2026-09-13

Implemented the source side of the approved first audio-redesign plan:

- Added strict versioned reciter/audio metadata normalization and validation.
- Added build-time Quran Foundation chapter-reciter and chapter-audio generation tooling.
- Generator fetches the reciter catalog once, verifies approved reciter IDs, fetches all 114 Surahs per reciter with timing segments, validates the complete catalog before writing, and replaces only the generated `reciters_v1.json` + `chapters_v1/` targets while preserving hand-maintained `assets/audio/` files.
- Quran Foundation credentials remain build/server-only. No client secret/access token is written into Flutter assets or runtime source.
- Added bundled `AssetBundle` reciter and per-Surah chapter metadata sources. Runtime loads only the requested reciter/Surah chapter document.
- `QuranAudioSyncService`, reader playback preparation, Hifz playback preparation, and reciter catalog providers now consume bundled audio metadata rather than a runtime `QuranBackendClient`.
- Existing filesystem audio download repository, Drift timing/audio metadata, local-path preference, word-audio path, and single Quran audio controller remain intact.
- Reciter UI now exposes selected reciter, current Surah, `Prepare / Stream`, `Download for offline`, active preparation progress, and retry copy.
- Added release preflight enforcement for a verified reciter index, exact 114-Surah metadata coverage per bundled reciter, matching document identity, and public HTTPS audio URLs.
- Added physical-device integration-test source for bundled catalog selection and Surah 1 offline download.

Additional schema hardening:

- Quran Foundation `style` and `qirat` metadata objects are required while their nested `name` values may be null; generated/runtime validation follows that contract.
- Production generator does not fabricate or hand-author reciter metadata.

Verified in this sandbox:

```text
python3 -m unittest \
  tool.release.test_release_preflight \
  tool.release.test_android_debug_install_config \
  tool.release.test_audio_notification_icon -v

12 tests passed, 0 failed.

python3 -m unittest discover -s tool/tafsir/tests -p 'test*.py' -v

3 tests passed, 0 failed.
```

Also verified statically:

- no new unresolved project-relative Dart imports were introduced; the only missing local Dart files are the existing Drift-generated `quran_content_database.g.dart` and `user_database.g.dart`, which are produced by build_runner;
- reciter/Quran/Hifz runtime wiring no longer constructs `QuranBackendClient` for chapter-reciter or Surah-audio preparation;
- no Quran Foundation secret/token identifiers are present under Flutter assets, Android resources, or runtime `lib/` source.

### Deliberately not generated in this sandbox

The following production audio assets are intentionally absent until the credentialed generator is run on the developer workstation:

- `assets/audio/reciters_v1.json`
- `assets/audio/chapters_v1/<reciterId>-<surah>.json`

Do not replace this gate with demo, guessed, scraped, or fabricated reciter metadata.

### Required Fedora GREEN/device gate

This sandbox still has no Flutter/Dart SDK, so Dart/Flutter GREEN results are not claimed here. On the user's Fedora project, preserve the existing generated canonical Quran DB/private signing files and run:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs

dart format .

flutter test \
  test/tool/quran_audio/reciter_catalog_builder_test.dart \
  test/tool/quran_audio/reciter_source_fetcher_test.dart \
  test/tool/quran_audio/reciter_audio_generator_test.dart \
  --reporter expanded

flutter test \
  test/features/reciters/data/bundled_reciter_catalog_source_test.dart \
  test/features/reciters/data/bundled_chapter_audio_source_test.dart \
  test/features/quran/data/quran_audio_sync_service_test.dart \
  test/features/reciters/application/reciter_catalog_controller_test.dart \
  test/features/reciters/presentation/reciter_audio_page_test.dart \
  test/features/settings/presentation/settings_page_test.dart \
  --reporter expanded

flutter analyze
flutter test --concurrency=1 --reporter expanded
```

Then generate real metadata with approved Quran Foundation credentials:

```bash
QF_ENV=production \
QF_CLIENT_ID="$QF_CLIENT_ID" \
QF_CLIENT_SECRET="$QF_CLIENT_SECRET" \
dart run tool/quran_audio/fetch_verified_reciter_audio.dart \
  --reciter-ids <approved-id-list> \
  --out-dir assets/audio
```

Finally run release preflight and the OPPO physical-device E2E, then enable airplane mode and confirm the downloaded Surah replays locally and word tap-to-play still works. The three-skin Surah-first/Mushaf redesign remains blocked until this audio gate is green.
