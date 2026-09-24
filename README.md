# Quran Hifz App — Audio Sync Build 0.2

This build extends the first Flutter reader with the offline audio foundation.

## Added

- SQLite offline audio index
- chapter-audio metadata
- ayah timing table
- word timing table
- file-based audio cache
- chapter audio downloader
- dedicated word audio downloader
- local-first audio resolver
- Quran Foundation backend client
- Cloudflare Worker + Hono backend
- backend-only OAuth2 client-credentials flow
- cached access token with one 401 retry
- chapter reciter endpoint
- chapter audio endpoint with word segments

## Setup

### Backend

```bash
cd backend
npm install
cp .dev.vars.example .dev.vars
```

Add Quran Foundation pre-live credentials to `.dev.vars` and run:

```bash
npm run dev
```

### Flutter

The normal app build uses the deployed production Worker by default:

```bash
flutter pub get
flutter run
```

For local Worker development or another environment, override it explicitly:

```bash
flutter run --dart-define=QURAN_BACKEND_URL=http://127.0.0.1:8787
```

The production default is:

```text
https://quran-hifz-api.shoaibadmisec.workers.dev
```

## Current boundary

The reader still uses demo Quran text. The next build should replace the demo
repository with verified verse/word data and assign each word its real
`audioUrl`.

Then the playback flow becomes:

```text
word tap
→ local word file if downloaded
→ otherwise Quran CDN
→ play immediately
```

and:

```text
ayah Play
→ local chapter audio
→ seek to SQLite ayah start_ms
→ stop at end_ms
→ repeat N times
→ next ayah
```
