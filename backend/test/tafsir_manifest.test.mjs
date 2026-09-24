import assert from 'node:assert/strict';
import test from 'node:test';

import {
  buildZakariaManifest,
  TafsirManifestConfigError,
} from '../src/tafsir.ts';

test('buildZakariaManifest exposes the approved Zakaria source identity', () => {
  const manifest = buildZakariaManifest({
    TAFSIR_ZAKARIA_URL: 'https://cdn.example.test/zakaria-1.1.1.sqlite',
    TAFSIR_ZAKARIA_SHA256: 'a'.repeat(64),
    TAFSIR_ZAKARIA_SIZE_BYTES: '12345',
    TAFSIR_ZAKARIA_VERSION: '1.1.1',
  });

  assert.equal(manifest.source_id, 'bn.abubakar_zakaria.quranenc');
  assert.equal(manifest.language, 'bn');
  assert.equal(manifest.version, '1.1.1');
  assert.equal(manifest.translation_key, 'bengali_zakaria');
  assert.equal(manifest.size_bytes, 12345);
  assert.match(manifest.attribution, /QuranEnc\.com/);
});

test('buildZakariaManifest refuses non-HTTPS package URLs', () => {
  assert.throws(
    () => buildZakariaManifest({
      TAFSIR_ZAKARIA_URL: 'http://cdn.example.test/zakaria.sqlite',
      TAFSIR_ZAKARIA_SHA256: 'a'.repeat(64),
      TAFSIR_ZAKARIA_SIZE_BYTES: '12345',
      TAFSIR_ZAKARIA_VERSION: '1.1.1',
    }),
    TafsirManifestConfigError,
  );
});

test('buildZakariaManifest refuses invalid checksum or size', () => {
  assert.throws(
    () => buildZakariaManifest({
      TAFSIR_ZAKARIA_URL: 'https://cdn.example.test/zakaria.sqlite',
      TAFSIR_ZAKARIA_SHA256: 'bad',
      TAFSIR_ZAKARIA_SIZE_BYTES: '0',
      TAFSIR_ZAKARIA_VERSION: '1.1.1',
    }),
    TafsirManifestConfigError,
  );
});
