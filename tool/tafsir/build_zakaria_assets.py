#!/usr/bin/env python3
"""Build compact, verified per-Surah Zakaria Tafsir assets."""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Mapping

from .build_zakaria_package import (
    ATTRIBUTION,
    AUTHOR,
    FULL_TITLE,
    LANGUAGE,
    LICENSE_NOTE,
    PUBLISHER,
    SOURCE_ID,
    SOURCE_NAME,
    SOURCE_PAGE,
    TERMS_URL,
    TRANSLATION_KEY,
    _as_int,
    _validate_version,
    fetch_surahs,
    read_canonical_bounds,
)


@dataclass(frozen=True)
class AssetBundleBuildResult:
    source_id: str
    version: str
    output_dir: Path
    total_entries: int
    surah_assets: int
    size_bytes: int


def _json_bytes(payload: object) -> bytes:
    return json.dumps(
        payload,
        ensure_ascii=False,
        separators=(",", ":"),
        sort_keys=True,
    ).encode("utf-8")


def _write_deterministic_gzip(path: Path, payload: object) -> str:
    compressed = gzip.compress(_json_bytes(payload), compresslevel=9, mtime=0)
    path.write_bytes(compressed)
    return hashlib.sha256(compressed).hexdigest()


def build_asset_bundle(
    *,
    responses: Mapping[int, Iterable[Mapping[str, object]]],
    canonical_bounds: Mapping[int, int],
    output_dir: Path,
    version: str,
) -> AssetBundleBuildResult:
    version = _validate_version(version)
    bounds = {int(surah): int(count) for surah, count in canonical_bounds.items()}
    if not bounds:
        raise ValueError("canonical ayah bounds are required")
    expected_surahs = sorted(bounds)
    if expected_surahs != list(range(expected_surahs[0], expected_surahs[-1] + 1)):
        raise ValueError("canonical ayah bounds must be contiguous")

    output_dir.mkdir(parents=True, exist_ok=True)
    for stale in output_dir.glob("*.json.gz"):
        stale.unlink()
    manifest_path = output_dir / "manifest.json"
    if manifest_path.exists():
        manifest_path.unlink()

    manifest_surahs: dict[str, dict[str, object]] = {}
    total_entries = 0
    total_size = 0

    for surah in expected_surahs:
        if surah not in responses:
            raise ValueError(f"missing QuranEnc response for surah {surah}")
        rows = [dict(row) for row in responses[surah]]
        expected_count = bounds[surah]
        if len(rows) != expected_count:
            raise ValueError(
                f"surah {surah} expected {expected_count} ayahs, got {len(rows)}"
            )

        entries: list[dict[str, object]] = []
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
            entries.append(
                {
                    "ayah_number": expected_ayah,
                    "translation": translation,
                    "footnotes": footnotes,
                }
            )

        asset_name = f"{surah:03d}.json.gz"
        asset_path = output_dir / asset_name
        payload = {
            "source_id": SOURCE_ID,
            "version": version,
            "surah_number": surah,
            "entries": entries,
        }
        digest = _write_deterministic_gzip(asset_path, payload)
        size = asset_path.stat().st_size
        manifest_surahs[str(surah)] = {
            "asset": asset_name,
            "ayah_count": expected_count,
            "sha256": digest,
            "size_bytes": size,
        }
        total_entries += expected_count
        total_size += size

    manifest = {
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
        "content_mapping": "translation=entries.translation; footnotes=entries.footnotes",
        "total_entries": total_entries,
        "surah_count": len(expected_surahs),
        "surahs": manifest_surahs,
    }
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )

    verify_asset_bundle(output_dir)
    return AssetBundleBuildResult(
        source_id=SOURCE_ID,
        version=version,
        output_dir=output_dir,
        total_entries=total_entries,
        surah_assets=len(expected_surahs),
        size_bytes=total_size + manifest_path.stat().st_size,
    )


def verify_asset_bundle(output_dir: Path) -> None:
    manifest_path = output_dir / "manifest.json"
    manifest = json.loads(manifest_path.read_text("utf-8"))
    if manifest.get("source_id") != SOURCE_ID:
        raise ValueError("manifest source_id does not match Zakaria source")
    version = manifest.get("version")
    if not isinstance(version, str) or not version:
        raise ValueError("manifest version is missing")
    surahs = manifest.get("surahs")
    if not isinstance(surahs, dict) or not surahs:
        raise ValueError("manifest has no Surah assets")

    total_entries = 0
    for key, metadata in surahs.items():
        if not isinstance(metadata, dict):
            raise ValueError(f"manifest Surah {key} metadata is invalid")
        surah = int(key)
        asset_name = metadata.get("asset")
        expected_sha = metadata.get("sha256")
        expected_count = metadata.get("ayah_count")
        if not isinstance(asset_name, str) or not isinstance(expected_sha, str):
            raise ValueError(f"manifest Surah {surah} asset metadata is incomplete")
        asset_path = output_dir / asset_name
        data = asset_path.read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        if digest != expected_sha:
            raise ValueError(f"SHA-256 mismatch for Surah {surah}")
        try:
            payload = json.loads(gzip.decompress(data).decode("utf-8"))
        except Exception as error:
            raise ValueError(f"Surah {surah} asset cannot be decoded") from error
        if (
            payload.get("source_id") != SOURCE_ID
            or payload.get("version") != version
            or payload.get("surah_number") != surah
        ):
            raise ValueError(f"Surah {surah} asset identity does not match manifest")
        entries = payload.get("entries")
        if not isinstance(entries, list) or len(entries) != expected_count:
            raise ValueError(f"Surah {surah} entry count does not match manifest")
        for expected_ayah, entry in enumerate(entries, start=1):
            if (
                not isinstance(entry, dict)
                or entry.get("ayah_number") != expected_ayah
                or not isinstance(entry.get("translation"), str)
                or not isinstance(entry.get("footnotes"), str)
            ):
                raise ValueError(f"Surah {surah} contains invalid ayah {expected_ayah}")
        total_entries += len(entries)

    if manifest.get("total_entries") != total_entries:
        raise ValueError("manifest total_entries does not match Surah assets")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build compact bundled Abu Bakar Zakaria Tafsir assets."
    )
    parser.add_argument("--canonical-db", type=Path, required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    bounds = read_canonical_bounds(args.canonical_db)
    responses = fetch_surahs(bounds)
    result = build_asset_bundle(
        responses=responses,
        canonical_bounds=bounds,
        output_dir=args.out_dir,
        version=args.version,
    )
    print(
        json.dumps(
            {
                "source_id": result.source_id,
                "version": result.version,
                "surah_assets": result.surah_assets,
                "total_entries": result.total_entries,
                "size_bytes": result.size_bytes,
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
