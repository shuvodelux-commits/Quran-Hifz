# Verified reciter audio metadata

This directory contains build-time tooling for generating the runtime-safe
chapter-reciter catalog used by the Android app. Quran Foundation credentials
are build/server-only and must never be written into Flutter assets, Android
resources, Dart defines, logs, or committed files.

## Generate metadata

Use approved Quran Foundation credentials from environment variables:

```bash
export QF_ENV=production
export QF_CLIENT_ID='...'
export QF_CLIENT_SECRET='...'
# Or use QF_ACCESS_TOKEN instead of QF_CLIENT_SECRET.

dart run tool/quran_audio/fetch_verified_reciter_audio.dart \
  --qf-env production \
  --reciter-ids 7,10 \
  --out-dir assets/audio
```

The command fetches the verified chapter-reciter catalog once, verifies every
requested ID, fetches all 114 Surah documents with timing segments for each
reciter, validates the entire in-memory catalog, writes a staging directory,
and only then replaces the generated `reciters_v1.json` and `chapters_v1/`
targets. Hand-maintained files under `assets/audio/` are preserved.

Generated runtime assets:

- `assets/audio/reciters_v1.json`
- `assets/audio/chapters_v1/<reciterId>-<surah>.json`

A successful run prints only counts and the output path. It never prints the
client secret or access token.

## Verification

```bash
flutter test test/tool/quran_audio/reciter_catalog_builder_test.dart --reporter expanded
flutter test test/tool/quran_audio/reciter_source_fetcher_test.dart --reporter expanded
flutter test test/tool/quran_audio/reciter_audio_generator_test.dart --reporter expanded
```

For a production catalog, the chapter document count must be exactly
`114 × reciter_count` before the generated files are used by the app.
