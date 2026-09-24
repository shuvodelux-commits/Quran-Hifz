# Canonical Quran content asset

Production release packaging includes these verified files:

- `quran_content.sqlite`
- `quran_content_manifest.json`
- `quran_content.sqlite.report.json`

The current schema-v2 package was generated on 2026-09-16 from the verified
Quran Foundation/QuranEnc JSON inputs plus QUL's official public API:

- IndoPak script: Resource 59, `text_indopak_nastaleeq`
- fixed Mushaf layout: Mushaf ID 3
- normalized script SHA-256: `6b4ca5897ac0c637dbd8dcca206e7d563ca7aed9be5f7ffbd9165c0c4127f0f5`
- normalized layout SHA-256: `12ea15c8bd19989478a230481bb7bb3be6adc4bc108586bbb24b5e3149f1d59e`
- packaged database SHA-256: `05d22441ddbc52ed856944cc8a1688bafefbf821555b4db8c722b87f4e243f41`

The generated report records complete source provenance and integrity counts.
Regenerate only through `tool/quran_content/build_quran_db.dart`; the runtime
database is immutable.
