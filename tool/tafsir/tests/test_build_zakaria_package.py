import hashlib
import json
import sqlite3
import tempfile
import unittest
from pathlib import Path

from tool.tafsir.build_zakaria_package import (
    SOURCE_ID,
    TRANSLATION_KEY,
    build_package,
    write_manifest,
)


class ZakariaPackageBuilderTest(unittest.TestCase):
    def test_preserves_source_fields_and_uses_only_footnotes_as_tafsir(self):
        responses = {
            1: [
                {
                    "sura": "1",
                    "aya": "1",
                    "translation": " অনুবাদ ১ ",
                    "footnotes": "[১] তাফসীর ১\nদ্বিতীয় লাইন ",
                },
                {
                    "sura": "1",
                    "aya": "2",
                    "translation": "অনুবাদ ২",
                    "footnotes": "",
                },
            ],
            2: [
                {
                    "sura": "2",
                    "aya": "1",
                    "translation": "<b>অনুবাদ ৩</b>",
                    "footnotes": "  [১] <i>তাফসীর ৩</i>  ",
                },
            ],
        }

        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "zakaria.sqlite"
            result = build_package(
                responses=responses,
                canonical_bounds={1: 2, 2: 1},
                output_path=output,
                version="1.1.1",
            )

            self.assertEqual(result.source_id, SOURCE_ID)
            self.assertEqual(result.version, "1.1.1")
            self.assertEqual(result.total_source_entries, 3)
            self.assertEqual(result.tafsir_entries, 2)

            db = sqlite3.connect(output)
            try:
                source_rows = db.execute(
                    "SELECT surah_number, ayah_number, translation, footnotes "
                    "FROM source_entries ORDER BY surah_number, ayah_number"
                ).fetchall()
                self.assertEqual(
                    source_rows,
                    [
                        (1, 1, " অনুবাদ ১ ", "[১] তাফসীর ১\nদ্বিতীয় লাইন "),
                        (1, 2, "অনুবাদ ২", ""),
                        (2, 1, "<b>অনুবাদ ৩</b>", "  [১] <i>তাফসীর ৩</i>  "),
                    ],
                )

                tafsir_rows = db.execute(
                    "SELECT surah_number, ayah_number, text "
                    "FROM tafsir_entries ORDER BY surah_number, ayah_number"
                ).fetchall()
                self.assertEqual(
                    tafsir_rows,
                    [
                        (1, 1, "[১] তাফসীর ১\nদ্বিতীয় লাইন "),
                        (2, 1, "  [১] <i>তাফসীর ৩</i>  "),
                    ],
                )

                metadata = dict(
                    db.execute(
                        "SELECT metadata_key, metadata_value FROM tafsir_metadata"
                    ).fetchall()
                )
                self.assertEqual(metadata["source_id"], SOURCE_ID)
                self.assertEqual(metadata["translation_key"], TRANSLATION_KEY)
                self.assertEqual(metadata["language"], "bn")
                self.assertEqual(metadata["version"], "1.1.1")
                self.assertIn("QuranEnc.com", metadata["attribution"])
            finally:
                db.close()

    def test_rejects_missing_or_misaligned_ayahs(self):
        responses = {
            1: [
                {
                    "sura": "1",
                    "aya": "2",
                    "translation": "wrong index",
                    "footnotes": "note",
                }
            ]
        }

        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaisesRegex(ValueError, "expected ayah 1:1"):
                build_package(
                    responses=responses,
                    canonical_bounds={1: 1},
                    output_path=Path(tmp) / "bad.sqlite",
                    version="1.1.1",
                )

    def test_manifest_matches_built_package_bytes(self):
        responses = {
            1: [
                {
                    "sura": "1",
                    "aya": "1",
                    "translation": "translation",
                    "footnotes": "tafsir",
                }
            ]
        }

        with tempfile.TemporaryDirectory() as tmp:
            package = Path(tmp) / "zakaria.sqlite"
            manifest = Path(tmp) / "zakaria.manifest.json"
            result = build_package(
                responses=responses,
                canonical_bounds={1: 1},
                output_path=package,
                version="1.1.1",
            )
            write_manifest(
                result=result,
                download_url="https://cdn.example.test/tafsir/zakaria-1.1.1.sqlite",
                output_path=manifest,
            )

            payload = json.loads(manifest.read_text(encoding="utf-8"))
            self.assertEqual(payload["source_id"], SOURCE_ID)
            self.assertEqual(payload["version"], "1.1.1")
            self.assertEqual(payload["size_bytes"], package.stat().st_size)
            self.assertEqual(
                payload["sha256"],
                hashlib.sha256(package.read_bytes()).hexdigest(),
            )
            self.assertEqual(payload["translation_key"], TRANSLATION_KEY)
            self.assertIn("QuranEnc.com", payload["attribution"])


if __name__ == "__main__":
    unittest.main()
