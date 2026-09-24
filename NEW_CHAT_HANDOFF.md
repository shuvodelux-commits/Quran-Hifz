# Quran Hifz V1 — New Chat Handoff

Date: 2026-09-13

## Current verified status

- Physical Android device: OPPO CPH2179, Android 10 (API 29).
- Debug package is configured as `com.quranhifz.app.debug` so debug and release can coexist.
- The foreground-audio crash was root-caused to an invalid AudioService notification with no small icon.
- A dedicated `drawable/ic_stat_quran` notification icon is configured.
- User verified on the real Android device that the app opens and **tap-a-word audio now works without crashing**.
- Hifz physical-device smoke test passed after hardening the integration-test hit-testing/wait logic.
- Canonical Quran bootstrap/provider scope was corrected to use a single root provider container.
- Earlier user verification reported `flutter analyze` clean and 161 tests passing after canonical Quran DB generation.

## Local-only generated files not contained in this handoff ZIP

The user's Fedora project has generated/private files that were never available to this sandbox and therefore are intentionally not included here:

- `assets/database/quran_content.sqlite` (about 12 MB)
- `assets/database/quran_content_manifest.json`
- canonical provenance/report output if generated locally
- `android/key.properties`
- private upload keystore (`.jks`/`.keystore`)
- generated Gradle wrapper binary/scripts if they only exist on the user's workstation

Do not replace or delete those local files when applying this source tree over the existing Fedora project.

Known canonical DB SHA-256 from the user's successful build:

`cdcee15ae4c51f1c9ad650d96fc74e363dd12713429abddfe4635e4113996e28`

## Approved product/UI direction

The redesign is approved. Primary design sources are in `docs/ui/reference/`.

Requirements:

- Surah-first entry flow instead of opening directly into a page.
- Continue Reading card and saved Surah/ayah position.
- Quran-like Arabic-only Reading/Hifz mode with roughly 9–10 comfortable lines on a phone.
- Individual word tap = immediate word audio.
- Long press = word details with pronunciation, Bangla meaning, grammar/root/lemma when verified data exists, ayah translation, and tafsir entry.
- Persistent bottom Quran audio player.
- Reciter selection, repeat count, repeat range, speed, pause between repeats, auto-next, download/offline controls.
- Playing ayah highlighted; active word highlighted when verified timing data exists.
- Search result navigation must carry Surah + ayah + page, scroll to the exact ayah, and highlight it temporarily.
- Hifz selection should be integrated into the Quran reader rather than a separate numeric-entry-only workflow.
- Three UI skins using the same component system:
  - Normal: soft green/teal
  - Dark: deep charcoal/emerald
  - Pink: rose/blush, intended as the feminine skin
- English UI typography: Inter.
- Bangla UI typography: Noto Sans Bengali or an equally clean, well-rendering Bengali sans font after device validation.
- Arabic must remain Quran-focused and highly legible; do not substitute a generic Latin/Bangla font for Quran Arabic.

Approved design/spec:

`docs/superpowers/specs/2026-09-13-quran-reader-audio-redesign-design.md`

Current first implementation plan:

`docs/superpowers/plans/2026-09-13-offline-reciter-audio-foundation.md`

## Reciter/offline audio root cause and implemented replacement

Word audio works because it can use a public Quran audio source directly.

The prior chapter-reciter/Surah-download path depended on `QURAN_BACKEND_URL`; its default is `https://example.invalid`. The source in this handoff now removes that runtime dependency for reciter discovery and Surah audio preparation by using generated, bundled Quran Foundation metadata. Real production metadata still has to be generated with approved build-time credentials before the feature can pass release/device gates.

Approved architecture:

1. Quran Foundation credentials are used at build time only.
2. Fetch verified chapter reciter metadata and chapter audio/timing metadata.
3. Generate bundled reciter/index metadata assets.
4. Android app reads the bundled catalog without credentials or a mandatory backend.
5. User may stream a Surah or download it.
6. Downloaded Surah audio is preferred locally and works offline.
7. Never embed Quran Foundation client secret in the APK.

## Current TDD checkpoint

The authoritative first implementation plan remains:

`docs/superpowers/plans/2026-09-13-offline-reciter-audio-foundation.md`

### Audio foundation source now implemented

Tasks 1–6 have source implementations and regression tests staged in this handoff:

- strict reciter/index + 114-Surah chapter metadata builder;
- authenticated Quran Foundation chapter-reciter/chapter-audio fetch methods;
- credentialed production generator with staging/rollback and target-only replacement;
- bundled reciter and per-Surah `AssetBundle` sources;
- runtime `ChapterAudioSource` injection into reciter, reader, and Hifz paths;
- offline-first reciter controls for prepare/stream and explicit download;
- release preflight checks for generated audio assets;
- physical-device integration-test source for Surah 1 download.

Quran Foundation schema hardening also accepts nullable `style.name` / `qirat.name` while requiring both metadata objects and their language labels.

### Verification performed in this sandbox

The Python release regression suite is green:

```text
12 tests passed, 0 failed
```

The Tafsir Python suite is also green:

```text
3 tests passed, 0 failed
```

Static checks found no new unresolved project-relative Dart imports. The only absent local Dart imports are the two normal Drift-generated `.g.dart` files that build_runner materializes on the developer workstation.

The sandbox has no Flutter/Dart SDK. Therefore **do not claim the Dart/Flutter tests, analyzer, generator, or device gate are green yet**.

## Immediate next commands on Fedora

First preserve the local-only canonical Quran DB, manifest/provenance files, signing files, and Gradle wrapper. Apply the source changes without deleting those local files.

Then run:

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
```

If green, generate the real production audio metadata. Do not put credentials into Dart defines, source, assets, chat, or Git:

```bash
QF_ENV=production \
QF_CLIENT_ID="$QF_CLIENT_ID" \
QF_CLIENT_SECRET="$QF_CLIENT_SECRET" \
dart run tool/quran_audio/fetch_verified_reciter_audio.dart \
  --reciter-ids <approved-id-list> \
  --out-dir assets/audio
```

The generator must report exactly `114 × reciter_count` chapter documents.

Then run:

```bash
flutter test --concurrency=1 --reporter expanded
python3 tool/release/check_release_ready.py
DEVICE="4SR4SGMR65RGWS8T"
flutter test integration_test/offline_reciter_audio_test.dart \
  -d "$DEVICE" \
  --reporter expanded
```

Manual final audio gate:

1. download one Surah on the OPPO CPH2179;
2. enable airplane mode;
3. replay that downloaded Surah successfully from local storage;
4. confirm word tap-to-play still works without process termination.

Only after those checks are green should work move to Surah-first navigation and the approved Mushaf-style Normal/Dark/Pink UI redesign.

## Release/signing state

Release hardening source is included. Preflight validates the canonical Quran package, dedicated private signing, complete Gradle wrapper, Android background-audio notification wiring, and now the verified reciter/114-Surah audio metadata catalog.

Do not put `android/key.properties`, the keystore, Quran Foundation credentials, or generated private signing material into Git or share them in chat.

## Superpowers workflow requirement

Continue with Superpowers. New behavior remains TDD: RED -> minimal GREEN -> regression verification. Bugs use systematic debugging. Do not claim Flutter/device success without fresh output from the Fedora/Android environment.
