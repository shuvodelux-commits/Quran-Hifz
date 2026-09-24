#!/usr/bin/env python3
"""Build a verified offline Tafsir Abu Bakar Zakaria package.

The source contract is QuranEnc translation key ``bengali_zakaria``.  The
source's ``translation`` and ``footnotes`` fields are stored byte-for-byte as
Unicode strings received from JSON.  Only non-empty ``footnotes`` become
runtime tafsir entries; the complete source fields are retained in
``source_entries`` for provenance and audit.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sqlite3
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Mapping

SOURCE_ID = "bn.abubakar_zakaria.quranenc"
SOURCE_NAME = "তাফসীরে আবু বকর যাকারিয়া"
FULL_TITLE = "কুরআনুল কারীম — বাংলা অনুবাদ ও সংক্ষিপ্ত তাফসীর"
AUTHOR = "ড. আবু বকর মুহাম্মাদ যাকারিয়া"
PUBLISHER = "QuranEnc.com / King Fahd Complex edition"
LANGUAGE = "bn"
TRANSLATION_KEY = "bengali_zakaria"
SOURCE_PAGE = "https://quranenc.com/bn/browse/bengali_zakaria"
API_BASE = "https://quranenc.com/api/v1/translation/sura"
TERMS_URL = "https://quranenc.com/bn/home/about/terms-and-conditions"
ATTRIBUTION = (
    "ড. আবু বকর মুহাম্মাদ যাকারিয়া; source: QuranEnc.com; "
    "content republished without modification."
)
LICENSE_NOTE = (
    "QuranEnc republication terms apply: preserve content unchanged, credit "
    "publisher/source, retain version information, and update when the source "
    "publishes a newer version."
)


@dataclass(frozen=True)
class PackageBuildResult:
    source_id: str
    version: str
    output_path: Path
    sha256: str
    size_bytes: int
    total_source_entries: int
    tafsir_entries: int


def _as_int(value: object, label: str) -> int:
    if isinstance(value, bool):
        raise ValueError(f"{label} must be an integer")
    try:
        return int(str(value))
    except (TypeError, ValueError) as error:
        raise ValueError(f"{label} must be an integer") from error


def _validate_version(version: str) -> str:
    version = version.strip()
    if not version or any(ch not in "0123456789." for ch in version):
        raise ValueError("version must contain only digits and dots")
    return version


def _normalise_response(payload: object) -> list[dict[str, object]]:
    if isinstance(payload, dict) and "result" in payload:
        payload = payload["result"]
    if not isinstance(payload, list):
        raise ValueError("QuranEnc surah response must contain a result list")
    rows: list[dict[str, object]] = []
    for item in payload:
        if not isinstance(item, dict):
            raise ValueError("QuranEnc surah response contains a non-object row")
        rows.append(item)
    return rows


def build_package(
    *,
    responses: Mapping[int, Iterable[Mapping[str, object]]],
    canonical_bounds: Mapping[int, int],
    output_path: Path,
    version: str,
) -> PackageBuildResult:
    version = _validate_version(version)
    bounds = {int(surah): int(count) for surah, count in canonical_bounds.items()}
    if not bounds:
        raise ValueError("canonical ayah bounds are required")

    expected_surahs = sorted(bounds)
    if expected_surahs != list(range(expected_surahs[0], expected_surahs[-1] + 1)):
        raise ValueError("canonical ayah bounds must be contiguous")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    if output_path.exists():
        output_path.unlink()

    db = sqlite3.connect(output_path)
    source_count = 0
    tafsir_count = 0
    try:
        db.executescript(
            """
            PRAGMA journal_mode = DELETE;
            PRAGMA synchronous = FULL;

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

            CREATE TABLE source_entries (
              surah_number INTEGER NOT NULL,
              ayah_number INTEGER NOT NULL,
              translation TEXT NOT NULL,
              footnotes TEXT NOT NULL,
              PRIMARY KEY (surah_number, ayah_number)
            );
            """
        )

        metadata = {
            "source_id": SOURCE_ID,
            "name": SOURCE_NAME,
            "full_title": FULL_TITLE,
            "author": AUTHOR,
            "publisher": PUBLISHER,
            "language": LANGUAGE,
            "version": version,
            "translation_key": TRANSLATION_KEY,
            "source_page": SOURCE_PAGE,
            "terms_url": TERMS_URL,
            "attribution": ATTRIBUTION,
            "license": LICENSE_NOTE,
            "content_mapping": "translation=source_entries.translation; footnotes=tafsir_entries.text",
        }
        db.executemany(
            "INSERT INTO tafsir_metadata(metadata_key, metadata_value) VALUES (?, ?)",
            metadata.items(),
        )

        for surah in expected_surahs:
            if surah not in responses:
                raise ValueError(f"missing QuranEnc response for surah {surah}")
            rows = [dict(row) for row in responses[surah]]
            expected_count = bounds[surah]
            if len(rows) != expected_count:
                raise ValueError(
                    f"surah {surah} expected {expected_count} ayahs, got {len(rows)}"
                )

            for expected_ayah, row in enumerate(rows, start=1):
                actual_surah = _as_int(row.get("sura"), "sura")
                actual_ayah = _as_int(row.get("aya"), "aya")
                if actual_surah != surah or actual_ayah != expected_ayah:
                    raise ValueError(
                        f"expected ayah {surah}:{expected_ayah}, "
                        f"got {actual_surah}:{actual_ayah}"
                    )

                translation = row.get("translation")
                footnotes = row.get("footnotes")
                if not isinstance(translation, str) or not isinstance(footnotes, str):
                    raise ValueError(
                        f"ayah {surah}:{expected_ayah} must contain string "
                        "translation and footnotes fields"
                    )

                db.execute(
                    "INSERT INTO source_entries"
                    "(surah_number, ayah_number, translation, footnotes) "
                    "VALUES (?, ?, ?, ?)",
                    (surah, expected_ayah, translation, footnotes),
                )
                source_count += 1

                # Whitespace is inspected only to decide whether a tafsir exists.
                # The inserted text is the original source string, unchanged.
                if footnotes.strip():
                    db.execute(
                        "INSERT INTO tafsir_entries"
                        "(surah_number, ayah_number, text) VALUES (?, ?, ?)",
                        (surah, expected_ayah, footnotes),
                    )
                    tafsir_count += 1

        db.commit()
        quick_check = db.execute("PRAGMA quick_check").fetchone()
        if quick_check is None or quick_check[0] != "ok":
            raise ValueError("generated SQLite package failed quick_check")
    except Exception:
        db.close()
        if output_path.exists():
            output_path.unlink()
        raise
    else:
        db.close()

    package_bytes = output_path.read_bytes()
    return PackageBuildResult(
        source_id=SOURCE_ID,
        version=version,
        output_path=output_path,
        sha256=hashlib.sha256(package_bytes).hexdigest(),
        size_bytes=len(package_bytes),
        total_source_entries=source_count,
        tafsir_entries=tafsir_count,
    )


def write_manifest(
    *,
    result: PackageBuildResult,
    download_url: str,
    output_path: Path,
) -> None:
    if not download_url.startswith("https://"):
        raise ValueError("production tafsir download URL must use HTTPS")
    payload = {
        "source_id": result.source_id,
        "name": SOURCE_NAME,
        "language": LANGUAGE,
        "version": result.version,
        "download_url": download_url,
        "sha256": result.sha256,
        "size_bytes": result.size_bytes,
        "attribution": ATTRIBUTION,
        "license": LICENSE_NOTE,
        "translation_key": TRANSLATION_KEY,
        "source_page": SOURCE_PAGE,
        "terms_url": TERMS_URL,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def read_canonical_bounds(canonical_db: Path) -> dict[int, int]:
    db = sqlite3.connect(f"file:{canonical_db}?mode=ro", uri=True)
    try:
        rows = db.execute(
            "SELECT number, ayah_count FROM surahs ORDER BY number"
        ).fetchall()
    finally:
        db.close()
    bounds = {int(number): int(count) for number, count in rows}
    if len(bounds) != 114 or sum(bounds.values()) != 6236:
        raise ValueError("canonical database must contain 114 surahs and 6236 ayahs")
    return bounds


def fetch_surahs(bounds: Mapping[int, int], *, timeout: float = 30.0) -> dict[int, list[dict[str, object]]]:
    responses: dict[int, list[dict[str, object]]] = {}
    headers = {
        "Accept": "application/json",
        "User-Agent": "QuranHifzContentBuilder/1.0 (+QuranEnc attribution)",
    }
    for surah in sorted(bounds):
        request = urllib.request.Request(
            f"{API_BASE}/{TRANSLATION_KEY}/{surah}",
            headers=headers,
        )
        with urllib.request.urlopen(request, timeout=timeout) as response:
            if response.status != 200:
                raise RuntimeError(f"QuranEnc returned HTTP {response.status} for surah {surah}")
            payload = json.loads(response.read().decode("utf-8"))
        responses[surah] = _normalise_response(payload)
    return responses


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build the approved Abu Bakar Zakaria Bangla tafsir package from QuranEnc."
    )
    parser.add_argument("--canonical-db", type=Path, required=True)
    parser.add_argument("--version", required=True, help="Verified QuranEnc source version, e.g. 1.1.1")
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--manifest-out", type=Path, required=True)
    parser.add_argument("--download-url", required=True)
    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    bounds = read_canonical_bounds(args.canonical_db)
    responses = fetch_surahs(bounds)
    result = build_package(
        responses=responses,
        canonical_bounds=bounds,
        output_path=args.out,
        version=args.version,
    )
    write_manifest(
        result=result,
        download_url=args.download_url,
        output_path=args.manifest_out,
    )
    print(
        json.dumps(
            {
                "source_id": result.source_id,
                "version": result.version,
                "sha256": result.sha256,
                "size_bytes": result.size_bytes,
                "source_entries": result.total_source_entries,
                "tafsir_entries": result.tafsir_entries,
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
