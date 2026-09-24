# Quran content database builder

This directory builds the immutable SQLite database bundled with the Quran
Hifz app. Runtime code must not edit canonical Quran rows.

## Source policy

Do not feed unreviewed scraped data into this builder. Every source package
must have documented provenance, version, and redistribution/storage rights.
The builder records source names, source versions, and SHA-256 hashes in the
build report.

The normalized JSON contract intentionally separates source adapters from the
canonical SQLite writer. Vendor/source-specific conversion should happen
before invoking this builder.

## Normalized Quran JSON

```json
{
  "source_name": "approved canonical source",
  "source_version": "version string",
  "content_version": "2026.09.04",
  "surahs": [
    {
      "number": 1,
      "name_arabic": "الفاتحة",
      "name_english": "Al-Fatihah",
      "name_bangla": null,
      "revelation_place": "makkah",
      "ayah_count": 7,
      "page_start": 1,
      "page_end": 1,
      "juz_start": 1
    }
  ],
  "ayahs": [
    {
      "surah_number": 1,
      "ayah_number": 1,
      "verse_key": "1:1",
      "arabic_text": "...",
      "arabic_text_indopak": "...",
      "arabic_text_tajweed": "<tajweed class=...>...</tajweed>",
      "page_number": 1,
      "juz_number": 1,
      "hizb_number": null,
      "rub_number": null
    }
  ]
}
```

## Normalized word JSON

```json
{
  "source_name": "approved word source",
  "source_version": "version string",
  "words": [
    {
      "surah_number": 1,
      "ayah_number": 1,
      "position": 1,
      "arabic": "...",
      "arabic_indopak": "...",
      "arabic_tajweed": "<tajweed class=...>...</tajweed>",
      "transliteration": null,
      "bangla_meaning": null,
      "english_meaning": null,
      "root": null,
      "lemma": null,
      "grammar": null,
      "audio_remote_path": null
    }
  ]
}
```

## Normalized translation JSON

```json
{
  "source_name": "approved Bangla translation",
  "source_version": "version string",
  "resource_id": 1,
  "language": "bn",
  "translations": [
    {"surah_number": 1, "ayah_number": 1, "text": "..."}
  ]
}
```

## Build

```bash
dart run tool/quran_content/build_quran_db.dart \
  --quran path/to/verified-quran.json \
  --words path/to/verified-words.json \
  --translation path/to/verified-bangla.json \
  --indopak-db path/to/qul-indopak.sqlite \
  --layout-db path/to/qul-pdms-layout.sqlite \
  --out assets/database/quran_content.sqlite
```

The command writes the SQLite file only after integrity validation succeeds.
It also writes `quran_content.sqlite.report.json`, containing the output hash
and source-file hashes, plus `quran_content_manifest.json`, which is the
runtime installer manifest containing the canonical schema version, content
version, and database SHA-256. The database and manifest are therefore built
from the same validated artifact and can be copied into the app bundle together.

### QUL resource-59 and Mushaf-3 build inputs

QUL's downloadable SQLite archives can require account sign-in. The public
official QUL API is the approved source for this build's two local-only,
normalized SQLite inputs. It requests resource 59's
`text_indopak_nastaleeq` word field and the fixed page/line positions for
Mushaf 3; it never uses credentials or a private endpoint.

```bash
dart run tool/quran_content/fetch_qul_mushaf_sources.dart \
  --indopak-out /tmp/qul-indopak-59.sqlite \
  --layout-out /tmp/qul-pdms-layout-3.sqlite
```

The materializer recognizes and removes only the final Arabic-numbered marker
record returned for each ayah. It retains every preceding canonical word's
`text_indopak_nastaleeq` text. Three source-split `بَعْدَ مَا` phrases are
folded back to the verified source's stable word locations. QUL Resource 59's
U+F600–U+F6FF font-shaping glyphs are preserved for the bundled Nastaleeq face;
they are not ayah markers. The materializer then derives centered `surah_name`
and standalone `basmallah` rows immediately before each Surah's first Quran
word and normalizes line numbers per page. It creates Bismillah lines for
Surahs 2–114 except 9; Al-Fatihah's Bismillah stays in ayah 1.

## Release invariants

Production validation requires:

- 114 Surahs
- 6236 ayahs
- canonical per-Surah ayah counts in both ayah rows and Surah metadata
- unique `verse_key`
- `verse_key == surah:ayah`
- non-empty Uthmani/Madani Arabic text
- verified IndoPak text for every ayah/word in dual-script release builds
- verified Uthmani Tajweed markup for every ayah/word in Tajweed-enabled release builds
- unique word position within each ayah
- no orphan word or translation rows
- pages in 1..604
- all 604 normalized QUL Mushaf pages with contiguous line numbers
- Mushaf ayah boundaries that resolve to stable canonical word locations
- preserved IndoPak sukun (U+0652 or U+06E1) and tanween (U+064B)
- Juz in 1..30

## Fetch verified build sources

The repository does not ship fabricated Quran source JSON. Use the build-time
fetcher to normalize Quran Foundation Content API data plus the QuranEnc
`bengali_zakaria` translation into the three inputs consumed by the SQLite
builder.

The Quran Foundation client secret is used **only by this local build tool**.
Never put it in Flutter assets, Android resources, Dart application code, or
source control.

Create a Quran Foundation backend/content application, then export credentials
in your shell:

```bash
export QF_CLIENT_ID='...'
export QF_CLIENT_SECRET='...'
export QF_ENV='prelive'       # use production only with approved production credentials
```

A canonical release build requires the chapters endpoint to return all 114
Surahs. If your pre-live account returns only a subset (for example Surahs 1
and 2), use pre-live only for importer testing and request/enable production
Content API access before generating the release database. Do not point
pre-live credentials at production endpoints.

QuranEnc currently publishes Dr. Abu Bakr Muhammad Zakaria's Bengali
translation in its public catalog as version 1.1.1 (22/05/2021), while the
translations-list API may omit that older catalog entry. The importer first
uses API metadata when available; otherwise it verifies that the direct
`bengali_zakaria` Surah endpoint is still serving data and records the catalog
version above.

You may instead export a short-lived `QF_ACCESS_TOKEN`; in that case the
fetcher does not require `QF_CLIENT_SECRET` until a token refresh is needed.

Fetch and normalize all 114 Surahs:

```bash
dart run tool/quran_content/fetch_verified_sources.dart \
  --out-dir tool/quran_content/source
```

The fetcher writes atomically only after it has verified 114 Surahs, 6,236
ayahs, complete word coverage, and complete primary Bangla translation
coverage. The SQLite build then rejects a production package unless verified
IndoPak and Uthmani Tajweed fields are also complete:

```text
tool/quran_content/source/verified-quran.json
tool/quran_content/source/verified-words.json
tool/quran_content/source/verified-bangla.json
```

Then build the bundled database:

```bash
dart run tool/quran_content/build_quran_db.dart \
  --quran tool/quran_content/source/verified-quran.json \
  --words tool/quran_content/source/verified-words.json \
  --translation tool/quran_content/source/verified-bangla.json \
  --indopak-db path/to/qul-indopak.sqlite \
  --layout-db path/to/qul-pdms-layout.sqlite \
  --out assets/database/quran_content.sqlite
```

Finally verify that all three runtime artifacts exist:

```bash
ls -lh assets/database/quran_content.sqlite \
       assets/database/quran_content_manifest.json \
       assets/database/quran_content.sqlite.report.json
```

### Source provenance

- Arabic Quran, Uthmani/Madani text, IndoPak text, Uthmani Tajweed markup, Mushaf metadata, word order, English word glosses,
  transliteration, and word-audio paths: Quran Foundation Content API v4.
- Primary Bangla ayah translation: QuranEnc translation key
  `bengali_zakaria`, Dr. Abu Bakr Muhammad Zakaria.
- The fetcher preserves the QuranEnc translation string as returned; it does
  not machine-translate, rewrite, or normalize the translation text.
- The generated JSON records source/version metadata, and the SQLite builder
  hashes each normalized source file into its build report.

QuranEnc redistribution requires source attribution and version tracking. Keep
that attribution visible in the app's content/about metadata when publishing a
release.

### Dual-script release note

The reader can render `Uthmani / Madani` or `IndoPak`. The source fetcher now
requests `text_qpc_hafs`, `text_uthmani`, `text_indopak`, and
`text_uthmani_tajweed` at both verse and word level. Rebuild the verified
source JSON and bundled SQLite package after applying a text-data update;
legacy databases remain readable but do not expose the IndoPak selector or
Tajweed toggle until the verified fields are present.

Tajweed coloring is intentionally tied to Uthmani/Madani text. The app does
not project Uthmani Tajweed character ranges onto IndoPak text because the two
scripts are not byte- or glyph-aligned. IndoPak therefore remains authentic
verified text without fabricated Tajweed coloring.

Before publishing or redistributing a build, verify that your Quran Foundation
content/font usage terms permit the intended storage and distribution model.
Do not copy third-party Quran font binaries into the repository without their
license/permission notice.
