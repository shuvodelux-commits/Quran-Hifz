import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / 'tool' / 'release' / 'check_release_ready.py'


class AndroidReleaseConfigTest(unittest.TestCase):
    def test_release_build_does_not_use_debug_signing(self):
        build_gradle = (ROOT / 'android' / 'app' / 'build.gradle.kts').read_text()
        self.assertNotIn('signingConfig = signingConfigs.getByName("debug")', build_gradle)
        self.assertIn('key.properties', build_gradle)

    def test_sensitive_signing_files_are_ignored(self):
        gitignore = (ROOT / '.gitignore').read_text()
        self.assertIn('android/key.properties', gitignore)
        self.assertIn('android/app/*.jks', gitignore)


class ReleasePreflightTest(unittest.TestCase):

    def _write_audio_assets(self, root: Path):
        audio_root = root / 'assets' / 'audio'
        chapters = audio_root / 'chapters_v1'
        chapters.mkdir(parents=True)
        index = {
            'schema_version': 1,
            'source_name': 'Quran Foundation Content API v4',
            'source_version': 'test',
            'generated_at_utc': '2026-09-13T00:00:00.000Z',
            'reciters': [
                {
                    'id': 7,
                    'name': 'Seven',
                    'style': {'name': 'Murattal', 'language_name': 'English'},
                    'qirat': {'name': 'Hafs', 'language_name': 'English'},
                },
            ],
        }
        (audio_root / 'reciters_v1.json').write_text(json.dumps(index))
        for surah in range(1, 115):
            document = {
                'schema_version': 1,
                'reciter_id': 7,
                'surah_number': surah,
                'audio_file_id': 7000 + surah,
                'audio_url': f'https://download.quranicaudio.com/test/7/{surah}.mp3',
                'format': 'mp3',
                'file_size': 1000 + surah,
                'timestamps': [],
            }
            (chapters / f'7-{surah}.json').write_text(json.dumps(document))

    def _fixture(self, root: Path, *, complete: bool):
        (root / 'assets' / 'database').mkdir(parents=True)
        (root / 'android' / 'gradle' / 'wrapper').mkdir(parents=True)
        (root / 'android' / 'app' / 'src' / 'main').mkdir(parents=True)
        (root / 'android' / 'app').mkdir(parents=True, exist_ok=True)

        (root / 'assets' / 'database' / 'quran_content.sqlite').write_bytes(b'sqlite')
        manifest = {
            'database_file': 'quran_content.sqlite',
            'database_sha256': hashlib.sha256(b'sqlite').hexdigest(),
            'content_version': 'test',
            'schema_version': 1,
        }
        (root / 'assets' / 'database' / 'quran_content_manifest.json').write_text(json.dumps(manifest))
        (root / 'assets' / 'database' / 'quran_content.sqlite.report.json').write_text('{}')
        self._write_audio_assets(root)

        (root / 'android' / 'gradlew').write_text('#!/bin/sh\n')
        (root / 'android' / 'gradlew.bat').write_text('@echo off\n')
        (root / 'android' / 'gradle' / 'wrapper' / 'gradle-wrapper.jar').write_bytes(b'jar')
        (root / 'android' / 'gradle' / 'wrapper' / 'gradle-wrapper.properties').write_text('distributionUrl=https://services.gradle.org/distributions/gradle-9.3.1-all.zip\n')
        (root / 'android' / 'key.properties').write_text(
            'storePassword=test\nkeyPassword=test\nkeyAlias=upload\nstoreFile=app/upload-keystore.jks\n'
        )
        (root / 'android' / 'app' / 'upload-keystore.jks').write_bytes(b'jks')
        (root / 'android' / 'app' / 'build.gradle.kts').write_text(
            'val keystorePropertiesFile = rootProject.file("key.properties")\n'
            'buildTypes { getByName("release") { signingConfig = signingConfigs.getByName("release") } }\n'
        )
        (root / 'android' / 'app' / 'src' / 'main' / 'AndroidManifest.xml').write_text(
            '<manifest><uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>'
            '<application><service android:name="com.ryanheise.audioservice.AudioService" '
            'android:foregroundServiceType="mediaPlayback"/>'
            '<receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"/></application></manifest>'
        )
        if not complete:
            (root / 'android' / 'gradle' / 'wrapper' / 'gradle-wrapper.jar').unlink()

    def _run(self, root: Path, *, aliases: tuple[str, ...] = ('upload',)):
        fake_bin = root / 'fake-bin'
        fake_bin.mkdir(exist_ok=True)
        keytool = fake_bin / 'keytool'
        keytool.write_text(
            '#!/usr/bin/env python3\n'
            'import os, sys\n'
            "alias = sys.argv[sys.argv.index('-alias') + 1] if '-alias' in sys.argv else None\n"
            "allowed = set(filter(None, os.environ.get('TEST_KEYTOOL_ALIASES', '').split(',')))\n"
            "sys.exit(0 if alias is None or alias in allowed else 1)\n"
        )
        keytool.chmod(0o755)
        env = os.environ.copy()
        env['PATH'] = str(fake_bin) + os.pathsep + env.get('PATH', '')
        env['TEST_KEYTOOL_ALIASES'] = ','.join(aliases)
        return subprocess.run(
            [sys.executable, str(SCRIPT), '--project-root', str(root)],
            text=True,
            capture_output=True,
            env=env,
        )

    def test_complete_fixture_passes(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self._fixture(root, complete=True)
            result = self._run(root)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn('Release preflight: PASS', result.stdout)


    def test_missing_keystore_alias_fails_before_release_build(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self._fixture(root, complete=True)
            key_properties = root / 'android' / 'key.properties'
            key_properties.write_text(
                'storePassword=test\nkeyPassword=test\nkeyAlias=sher\nstoreFile=app/upload-keystore.jks\n'
            )
            result = self._run(root, aliases=('upload',))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("Key alias 'sher' was not found in release keystore", result.stdout)


    def test_missing_reciter_index_fails(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self._fixture(root, complete=True)
            (root / 'assets/audio/reciters_v1.json').unlink()
            result = self._run(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('reciters_v1.json', result.stdout)

    def test_missing_chapter_directory_fails(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self._fixture(root, complete=True)
            shutil.rmtree(root / 'assets/audio/chapters_v1')
            result = self._run(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('chapters_v1', result.stdout)

    def test_incomplete_reciter_chapter_coverage_fails(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self._fixture(root, complete=True)
            (root / 'assets/audio/chapters_v1/7-114.json').unlink()
            result = self._run(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('exactly 114', result.stdout)

    def test_non_https_or_placeholder_audio_url_fails(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self._fixture(root, complete=True)
            chapter = root / 'assets/audio/chapters_v1/7-67.json'
            document = json.loads(chapter.read_text())
            document['audio_url'] = 'http://example.invalid/067.mp3'
            chapter.write_text(json.dumps(document))
            result = self._run(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('public HTTPS audio URL', result.stdout)

    def test_missing_wrapper_jar_fails_with_actionable_message(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self._fixture(root, complete=False)
            result = self._run(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('gradle-wrapper.jar', result.stdout)


if __name__ == '__main__':
    unittest.main()
