# Canonical Quran content asset

Production release packaging includes these verified files:

- `quran_content.sqlite`
- `quran_content_manifest.json`
- `quran_content.sqlite.report.json`

The schema-v2 canonical Quran base was generated from verified Quran
Foundation/QuranEnc inputs plus QUL's official public API:

- IndoPak script: Resource 59, `text_indopak_nastaleeq`
- fixed Mushaf layout: Mushaf ID 3
- normalized script SHA-256: `6b4ca5897ac0c637dbd8dcca206e7d563ca7aed9be5f7ffbd9165c0c4127f0f5`
- normalized layout SHA-256: `12ea15c8bd19989478a230481bb7bb3be6adc4bc108586bbb24b5e3149f1d59e`

On 2026-09-26 the verified canonical database was augmented with Bangla word
meanings from the public Quran.com Content API v4. The release backfill verifies
that the source locations exactly match all 77,429 canonical Quran words,
updates only `quran_words.bangla_meaning` plus provenance/version metadata,
runs the full Quran integrity validator, and then regenerates the package hash,
manifest, and report.

Current content version: `2026.09.26-bangla-words-v1`

Current packaged database SHA-256:
`97331c60eda1380afa42438f412aff040282f5df4d358e5a7a34f403b1c72d9f`

For a full canonical rebuild, use `tool/quran_content/build_quran_db.dart`
with verified source snapshots. When the canonical base is already verified
and only the release Bangla word meanings need refreshing, use
`tool/quran_content/backfill_bangla_word_meanings.dart`. The runtime database
remains immutable.
