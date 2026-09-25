import gzip
import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from tool.tafsir.build_zakaria_assets import (
    SOURCE_ID,
    build_asset_bundle,
    verify_asset_bundle,
)


def _row(surah: int, ayah: int, translation: str, footnotes: str):
    return {
        "sura": str(surah),
        "aya": str(ayah),
        "translation": translation,
        "footnotes": footnotes,
    }


class BuildZakariaAssetsTest(unittest.TestCase):
    def test_builds_114_versioned_gzip_surah_assets(self):
        bounds = {surah: 1 for surah in range(1, 115)}
        responses = {
            surah: [_row(surah, 1, f"translation-{surah}", f"footnote-{surah}")]
            for surah in bounds
        }
        with tempfile.TemporaryDirectory() as tmp:
            result = build_asset_bundle(
                responses=responses,
                canonical_bounds=bounds,
                output_dir=Path(tmp),
                version="1.1.1",
            )

            self.assertEqual(result.source_id, SOURCE_ID)
            self.assertEqual(result.total_entries, 114)
            self.assertEqual(result.surah_assets, 114)
            manifest = json.loads((Path(tmp) / "manifest.json").read_text("utf-8"))
            self.assertEqual(manifest["source_id"], SOURCE_ID)
            self.assertEqual(manifest["version"], "1.1.1")
            self.assertEqual(len(manifest["surahs"]), 114)
            self.assertEqual(manifest["total_entries"], 114)
            self.assertEqual(manifest["surahs"]["1"]["asset"], "001.json.gz")
            self.assertEqual(manifest["surahs"]["114"]["asset"], "114.json.gz")
            self.assertTrue((Path(tmp) / "001.json.gz").is_file())
            self.assertTrue((Path(tmp) / "114.json.gz").is_file())

    def test_preserves_translation_and_footnotes_exactly(self):
        translation = "  বাংলা <b>অনুবাদ</b>\nদ্বিতীয় লাইন  "
        footnotes = "  <p>টীকা &amp; ব্যাখ্যা</p>\n "
        with tempfile.TemporaryDirectory() as tmp:
            build_asset_bundle(
                responses={1: [_row(1, 1, translation, footnotes)]},
                canonical_bounds={1: 1},
                output_dir=Path(tmp),
                version="1.1.1",
            )
            with gzip.open(Path(tmp) / "001.json.gz", "rt", encoding="utf-8") as fh:
                payload = json.load(fh)

            entry = payload["entries"][0]
            self.assertEqual(entry["translation"], translation)
            self.assertEqual(entry["footnotes"], footnotes)
            self.assertEqual(payload["source_id"], SOURCE_ID)
            self.assertEqual(payload["surah_number"], 1)

    def test_rejects_missing_or_misaligned_ayah(self):
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaisesRegex(ValueError, "expected 2 ayahs"):
                build_asset_bundle(
                    responses={1: [_row(1, 1, "a", "")]},
                    canonical_bounds={1: 2},
                    output_dir=Path(tmp),
                    version="1.1.1",
                )

        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaisesRegex(ValueError, "expected ayah 1:2"):
                build_asset_bundle(
                    responses={
                        1: [
                            _row(1, 1, "a", ""),
                            _row(1, 3, "b", ""),
                        ]
                    },
                    canonical_bounds={1: 2},
                    output_dir=Path(tmp),
                    version="1.1.1",
                )

    def test_manifest_hashes_detect_corrupt_surah_asset(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            build_asset_bundle(
                responses={1: [_row(1, 1, "a", "b")]},
                canonical_bounds={1: 1},
                output_dir=root,
                version="1.1.1",
            )
            verify_asset_bundle(root)
            asset = root / "001.json.gz"
            asset.write_bytes(asset.read_bytes() + b"corruption")

            with self.assertRaisesRegex(ValueError, "SHA-256"):
                verify_asset_bundle(root)


if __name__ == "__main__":
    unittest.main()
