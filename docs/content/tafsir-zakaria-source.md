# Primary Bangla Tafsir — Abu Bakar Zakaria

V1's approved primary Bangla tafsir source is **Dr. Abu Bakar Muhammad Zakaria**.

## Authoritative digital source

- QuranEnc translation key: `bengali_zakaria`
- Stable app package id: `bn.abubakar_zakaria.quranenc`
- Language: `bn`
- Work: *কুরআনুল কারীম — বাংলা অনুবাদ ও সংক্ষিপ্ত তাফসীর*
- Author/translator: ড. আবু বকর মুহাম্মাদ যাকারিয়া
- Source page: `https://quranenc.com/bn/browse/bengali_zakaria`
- API family: `https://quranenc.com/api/v1/translation/sura/{translation_key}/{surah}`
- Version verified from QuranEnc on 2026-09-12: **1.1.1**

Before every production content build, verify the latest QuranEnc version again.
Do not silently ship an older package when QuranEnc has published a newer source version.

## Field mapping

QuranEnc returns each ayah with separate `translation` and `footnotes` fields.
The app does not concatenate or rewrite them.

- `translation` is retained unchanged in `source_entries.translation` for provenance/audit.
- `footnotes` is retained unchanged in `source_entries.footnotes`.
- only non-empty `footnotes` are exposed as runtime `tafsir_entries.text`.

This keeps normal Quran translation and tafsir as different presentation layers.
An ayah with no Zakaria footnote has no tafsir entry; the app must not relabel the translation as tafsir.

## Republishing requirements

The release pipeline is designed around QuranEnc's stated terms: preserve the content without modification, clearly credit the publisher/source, retain the source version/transcript information, report source notes back to QuranEnc, and update when QuranEnc issues a newer version. The app should not place inappropriate advertising around this content.

The generated SQLite package stores source identity, author, version, QuranEnc source page, terms URL, attribution, and content mapping in `tafsir_metadata`.

## Build

The production canonical Quran DB must already exist and pass its 114-Surah / 6236-ayah integrity gate.
Then run:

```bash
python tool/tafsir/build_zakaria_package.py \
  --canonical-db assets/database/quran_content.sqlite \
  --version 1.1.1 \
  --out build/content/zakaria-1.1.1.sqlite \
  --manifest-out build/content/zakaria-1.1.1.manifest.json \
  --download-url https://YOUR-CDN/tafsir/zakaria-1.1.1.sqlite
```

The builder fetches all 114 Surahs from QuranEnc, verifies every source ayah against the canonical database, runs SQLite `quick_check`, and emits SHA-256 and exact-size manifest metadata.

After uploading the generated SQLite file, copy the generated URL/hash/size/version into the backend's `TAFSIR_ZAKARIA_*` release configuration. Flutter retrieves that trusted manifest and then re-verifies the package locally before installation.

## Bundled compact assets

The production app bundles Zakaria Tafsir as verified per-Surah gzip assets
under `assets/tafsir/zakaria/1.1.1/`. The builder is
`tool/tafsir/build_zakaria_assets.py`.

Each Surah payload stores the QuranEnc `translation` and `footnotes`
strings unchanged. `manifest.json` records the source identity, attribution,
version, per-Surah ayah counts, byte sizes, and SHA-256 hashes. Runtime code
reads the requested compressed Surah directly from Flutter assets; it does not
extract a second 16–29 MB SQLite copy on first launch.

The legacy downloadable SQLite builder remains available for optional
Cloudflare-delivered updates and backwards compatibility.
