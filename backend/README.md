# Quran Hifz API

The Cloudflare Worker keeps Quran Foundation OAuth credentials off the mobile
client and exposes only the app-facing Quran API surface.

## Local development

Install dependencies and copy the local environment template:

```bash
npm install
cp .dev.vars.example .dev.vars
```

Set the Quran Foundation values in `.dev.vars`, then run:

```bash
npm run dev
```

The Flutter app already uses the deployed production Worker by default. To use
the local Worker from an Android device connected through ADB:

```bash
adb reverse tcp:8787 tcp:8787
flutter run --dart-define=QURAN_BACKEND_URL=http://127.0.0.1:8787
```

## Production credentials

Store Quran Foundation credentials as Worker secrets rather than committing
them:

```bash
npx wrangler secret put QF_CLIENT_ID
npx wrangler secret put QF_CLIENT_SECRET
```

`QF_ENV` is configured as `production` in `wrangler.jsonc`; use approved
production Quran Foundation credentials for both Worker secrets.

The mobile app's normal production backend is:

```text
https://quran-hifz-api.shoaibadmisec.workers.dev
```

`QURAN_BACKEND_URL` remains available as a compile-time override for local,
staging, or alternate deployments.

## Bangla tafsir package

The app's primary Bangla tafsir is Dr. Abu Bakar Muhammad Zakaria from QuranEnc
(`bengali_zakaria`). Build the verified SQLite package with
`tool/tafsir/build_zakaria_package.py`, upload it to an HTTPS CDN/R2 location,
then configure:

```env
TAFSIR_ZAKARIA_URL=https://YOUR-CDN/tafsir/zakaria-1.1.1.sqlite
TAFSIR_ZAKARIA_SHA256=<64 hex characters from the generated manifest>
TAFSIR_ZAKARIA_SIZE_BYTES=<exact byte count from the generated manifest>
TAFSIR_ZAKARIA_VERSION=1.1.1
```

`GET /api/tafsir/bn-zakaria/manifest` returns `503` until all four values are
valid. Do not bypass that gate with placeholder hashes or sizes.
