# Offline Tafsir Package Format

Tafsir content is intentionally separate from the canonical Quran database.
The application does not ship an unapproved tafsir source.

## Manifest

Each downloadable package is described by trusted metadata containing:

- `source_id`: stable safe identifier, e.g. `bn.publisher.work`
- `name`: reader-facing source name
- `language`: BCP-47-style language tag used by the application, e.g. `bn`
- `version`: immutable package version
- `download_url`: HTTPS package URL
- `sha256`: exact 64-character SHA-256 of the package file
- `size_bytes`: exact package size
- `attribution`: required attribution text when applicable
- `license`: redistribution/use terms when applicable

## SQLite schema

```sql
CREATE TABLE tafsir_metadata (
  metadata_key TEXT PRIMARY KEY,
  metadata_value TEXT NOT NULL
);

CREATE TABLE tafsir_entries (
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  text TEXT NOT NULL,
  PRIMARY KEY (surah_number, ayah_number)
);
```

Required metadata rows:

- `source_id`
- `version`
- `language`

## Install gate

A package is accepted only after all of these checks pass:

1. free storage is sufficient before bytes are written;
2. HTTP status and size metadata are acceptable;
3. exact downloaded byte count equals the manifest;
4. SHA-256 equals the manifest;
5. SQLite `PRAGMA quick_check` returns `ok`;
6. both required tables exist;
7. source id, version, and language match the manifest;
8. every `(surah_number, ayah_number)` exists inside canonical Quran bounds;
9. every tafsir entry contains non-empty text.

Installation uses a `.part` file. Registry state is written only after a
validated package has been atomically moved into its final location. Updating
one source never modifies the canonical Quran database.
