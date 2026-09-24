#!/usr/bin/env python3
"""Fail-fast release prerequisite checker for Quran Hifz Android builds."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse


class CheckResult:
    def __init__(self) -> None:
        self.failures: list[str] = []
        self.passes: list[str] = []

    def ok(self, message: str) -> None:
        self.passes.append(message)

    def fail(self, message: str) -> None:
        self.failures.append(message)


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def _load_manifest(path: Path, result: CheckResult) -> dict[str, object] | None:
    try:
        value = json.loads(path.read_text(encoding='utf-8'))
    except Exception as error:
        result.fail(f'Invalid Quran manifest JSON: {error}')
        return None
    if not isinstance(value, dict):
        result.fail('Quran manifest must contain a JSON object.')
        return None
    return value


def _check_quran_assets(root: Path, result: CheckResult) -> None:
    database = root / 'assets/database/quran_content.sqlite'
    manifest_path = root / 'assets/database/quran_content_manifest.json'
    report = root / 'assets/database/quran_content.sqlite.report.json'

    for path, label in (
        (database, 'canonical Quran database'),
        (manifest_path, 'canonical Quran manifest'),
        (report, 'canonical Quran provenance report'),
    ):
        if not path.is_file():
            result.fail(f'Missing {label}: {path.relative_to(root)}')
        elif path.stat().st_size == 0:
            result.fail(f'Empty {label}: {path.relative_to(root)}')
        else:
            result.ok(f'{label} present')

    if not database.is_file() or not manifest_path.is_file():
        return

    manifest = _load_manifest(manifest_path, result)
    if manifest is None:
        return

    content_version = manifest.get('content_version')
    schema_version = manifest.get('schema_version')
    expected_hash = manifest.get('database_sha256') or manifest.get('sha256')
    if not isinstance(content_version, str) or not content_version.strip():
        result.fail('Quran manifest content_version is missing or empty.')
    if not isinstance(schema_version, int) or schema_version <= 0:
        result.fail('Quran manifest schema_version must be a positive integer.')
    if not isinstance(expected_hash, str) or not re.fullmatch(r'[0-9a-fA-F]{64}', expected_hash):
        result.fail('Quran manifest database_sha256 must be a 64-character SHA-256 digest.')
        return

    actual_hash = _sha256(database)
    if actual_hash.lower() != expected_hash.lower():
        result.fail(
            'Canonical Quran database SHA-256 does not match '
            'quran_content_manifest.json.'
        )
    else:
        result.ok('canonical Quran database checksum matches manifest')


def _check_reciter_audio_assets(root: Path, result: CheckResult) -> None:
    index_path = root / 'assets/audio/reciters_v1.json'
    chapters_dir = root / 'assets/audio/chapters_v1'

    if not index_path.is_file():
        result.fail('Missing verified reciter index: assets/audio/reciters_v1.json')
        return
    if index_path.stat().st_size == 0:
        result.fail('Verified reciter index is empty: assets/audio/reciters_v1.json')
        return
    if not chapters_dir.is_dir():
        result.fail('Missing verified chapter audio directory: assets/audio/chapters_v1')
        return

    try:
        index = json.loads(index_path.read_text(encoding='utf-8'))
    except Exception as error:
        result.fail(f'Invalid reciter index JSON: {error}')
        return
    if not isinstance(index, dict):
        result.fail('Reciter index must contain a JSON object.')
        return
    if index.get('schema_version') != 1:
        result.fail('Reciter index schema_version must be 1.')
        return

    reciters = index.get('reciters')
    if not isinstance(reciters, list) or not reciters:
        result.fail('Reciter index must contain at least one reciter.')
        return

    reciter_ids: list[int] = []
    seen_ids: set[int] = set()
    for row in reciters:
        if not isinstance(row, dict):
            result.fail('Every reciter index entry must be an object.')
            return
        reciter_id = row.get('id')
        if not isinstance(reciter_id, int) or reciter_id <= 0:
            result.fail('Every reciter index id must be a positive integer.')
            return
        if reciter_id in seen_ids:
            result.fail(f'Duplicate reciter id in reciter index: {reciter_id}')
            return
        seen_ids.add(reciter_id)
        reciter_ids.append(reciter_id)

    expected_files = {
        f'{reciter_id}-{surah}.json'
        for reciter_id in reciter_ids
        for surah in range(1, 115)
    }
    actual_files = {path.name for path in chapters_dir.glob('*.json') if path.is_file()}

    for reciter_id in reciter_ids:
        reciter_files = {
            name for name in actual_files if name.startswith(f'{reciter_id}-')
        }
        if len(reciter_files) != 114:
            result.fail(
                f'Reciter {reciter_id} must have exactly 114 chapter audio files; '
                f'found {len(reciter_files)}.'
            )

    missing_files = sorted(expected_files - actual_files)
    extra_files = sorted(actual_files - expected_files)
    if missing_files:
        result.fail(
            'Verified chapter audio metadata is incomplete. Missing: '
            + ', '.join(missing_files[:5])
            + (' ...' if len(missing_files) > 5 else '')
        )
    if extra_files:
        result.fail(
            'Verified chapter audio metadata contains files not present in the '
            'reciter index: '
            + ', '.join(extra_files[:5])
            + (' ...' if len(extra_files) > 5 else '')
        )
    if missing_files or extra_files:
        return

    for reciter_id in reciter_ids:
        for surah in range(1, 115):
            chapter_path = chapters_dir / f'{reciter_id}-{surah}.json'
            try:
                document = json.loads(chapter_path.read_text(encoding='utf-8'))
            except Exception as error:
                result.fail(
                    f'Invalid chapter audio JSON {chapter_path.relative_to(root)}: {error}'
                )
                return
            if not isinstance(document, dict):
                result.fail(
                    f'Chapter audio metadata must be an object: '
                    f'{chapter_path.relative_to(root)}'
                )
                return
            if document.get('schema_version') != 1:
                result.fail(
                    f'Chapter audio schema_version must be 1: '
                    f'{chapter_path.relative_to(root)}'
                )
                return
            if document.get('reciter_id') != reciter_id or document.get('surah_number') != surah:
                result.fail(
                    f'Chapter audio identity mismatch: {chapter_path.relative_to(root)}'
                )
                return

            audio_url = document.get('audio_url')
            if not isinstance(audio_url, str) or not audio_url.strip():
                result.fail(
                    f'Chapter audio metadata has no public HTTPS audio URL: '
                    f'{chapter_path.relative_to(root)}'
                )
                return
            parsed = urlparse(audio_url)
            host = (parsed.hostname or '').lower()
            if parsed.scheme.lower() != 'https' or not host or host == 'example.invalid':
                result.fail(
                    f'Chapter audio metadata must use a public HTTPS audio URL: '
                    f'{chapter_path.relative_to(root)}'
                )
                return

    result.ok(
        f'verified reciter audio catalog is complete '
        f'({len(reciter_ids)} reciter(s), {len(expected_files)} chapter files)'
    )


def _parse_properties(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding='utf-8').splitlines():
        line = raw_line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        key, value = line.split('=', 1)
        values[key.strip()] = value.strip()
    return values


def _check_android_signing(root: Path, result: CheckResult) -> None:
    build_gradle = root / 'android/app/build.gradle.kts'
    key_properties = root / 'android/key.properties'

    if not build_gradle.is_file():
        result.fail('Missing android/app/build.gradle.kts.')
        return

    gradle_text = build_gradle.read_text(encoding='utf-8')
    if 'signingConfig = signingConfigs.getByName("debug")' in gradle_text:
        result.fail('Android release build still uses the debug signing key.')
    elif 'key.properties' not in gradle_text or 'signingConfigs.getByName("release")' not in gradle_text:
        result.fail('Android release signing is not configured from key.properties.')
    else:
        result.ok('Android release build uses dedicated release signing configuration')

    if not key_properties.is_file():
        result.fail(
            'Missing android/key.properties. Copy android/key.properties.example '
            'and point it to your private upload keystore.'
        )
        return

    values = _parse_properties(key_properties)
    required = ('storePassword', 'keyPassword', 'keyAlias', 'storeFile')
    missing = [key for key in required if not values.get(key)]
    if missing:
        result.fail('android/key.properties is missing: ' + ', '.join(missing))
        return

    store_path = Path(values['storeFile'])
    if not store_path.is_absolute():
        store_path = root / 'android' / store_path
    if not store_path.is_file():
        result.fail(f'Release keystore does not exist: {store_path}')
        return

    result.ok('release keystore is present')

    keytool = shutil.which('keytool')
    if keytool is None:
        result.fail('keytool is unavailable; cannot verify the configured release key alias.')
        return

    store_password = values['storePassword']
    open_store = subprocess.run(
        [keytool, '-list', '-keystore', str(store_path)],
        input=store_password + '\n',
        text=True,
        capture_output=True,
    )
    if open_store.returncode != 0:
        result.fail(
            'Release keystore could not be opened with storePassword from '
            'android/key.properties.'
        )
        return

    alias = values['keyAlias']
    alias_check = subprocess.run(
        [keytool, '-list', '-keystore', str(store_path), '-alias', alias],
        input=store_password + '\n',
        text=True,
        capture_output=True,
    )
    if alias_check.returncode != 0:
        result.fail(f"Key alias '{alias}' was not found in release keystore: {store_path}")
    else:
        result.ok(f"release keystore contains configured alias '{alias}'")


def _check_gradle_wrapper(root: Path, result: CheckResult) -> None:
    required = (
        root / 'android/gradlew',
        root / 'android/gradlew.bat',
        root / 'android/gradle/wrapper/gradle-wrapper.jar',
        root / 'android/gradle/wrapper/gradle-wrapper.properties',
    )
    missing = [path for path in required if not path.is_file()]
    if missing:
        for path in missing:
            result.fail(f'Missing Gradle wrapper file: {path.relative_to(root)}')
    else:
        result.ok('Gradle wrapper is complete')


def _check_background_audio(root: Path, result: CheckResult) -> None:
    manifest = root / 'android/app/src/main/AndroidManifest.xml'
    if not manifest.is_file():
        result.fail('Missing AndroidManifest.xml.')
        return
    text = manifest.read_text(encoding='utf-8')
    required_snippets = {
        'media playback foreground-service permission': 'android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK',
        'AudioService': 'com.ryanheise.audioservice.AudioService',
        'MediaButtonReceiver': 'com.ryanheise.audioservice.MediaButtonReceiver',
        'mediaPlayback foreground service type': 'android:foregroundServiceType="mediaPlayback"',
    }
    missing = [label for label, snippet in required_snippets.items() if snippet not in text]
    if missing:
        result.fail('Android background-audio manifest is missing: ' + ', '.join(missing))
    else:
        result.ok('Android background-audio manifest wiring is present')


def run(project_root: Path) -> int:
    root = project_root.resolve()
    result = CheckResult()

    _check_quran_assets(root, result)
    _check_reciter_audio_assets(root, result)
    _check_android_signing(root, result)
    _check_gradle_wrapper(root, result)
    _check_background_audio(root, result)

    for message in result.passes:
        print(f'[PASS] {message}')
    for message in result.failures:
        print(f'[FAIL] {message}')

    if result.failures:
        print(f'Release preflight: FAIL ({len(result.failures)} blocker(s))')
        return 1

    print('Release preflight: PASS')
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        '--project-root',
        default='.',
        help='Quran Hifz project root (default: current directory)',
    )
    args = parser.parse_args(argv)
    return run(Path(args.project_root))


if __name__ == '__main__':
    sys.exit(main())
