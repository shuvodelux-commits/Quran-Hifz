import assert from 'node:assert/strict';
import test from 'node:test';

import {
  TafsirUpstreamError,
  fetchAyahTafsir,
  fetchSurahTafsir,
  fetchTafsirResources,
  validateTafsirCoordinates,
} from '../src/quranFoundationTafsir.ts';

const env = {
  QF_CLIENT_ID: 'test-client',
  QF_CLIENT_SECRET: 'test-secret',
  QF_ENV: 'prelive',
};

function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}

test('tafsir resource catalog is requested with selected language', async () => {
  const paths = [];
  const result = await fetchTafsirResources(
    env,
    'bn',
    async (_env, path) => {
      paths.push(path);
      return jsonResponse({
        tafsirs: [
          {
            id: 169,
            name: 'Tafsir Ibn Kathir',
            author_name: 'Hafiz Ibn Kathir',
            slug: 'en-tafsir-ibn-kathir',
            language_name: 'english',
            translated_name: {
              name: 'তাফসীর ইবনে কাসীর',
              language_name: 'bengali',
            },
          },
        ],
      });
    },
  );

  assert.deepEqual(paths, [
    '/content/api/v4/resources/tafsirs?language=bn',
  ]);
  assert.equal(result[0].id, 169);
  assert.equal(result[0].translated_name.name, 'তাফসীর ইবনে কাসীর');
});

test('invalid tafsir coordinates are rejected before an upstream call', () => {
  assert.throws(
    () => validateTafsirCoordinates({ resourceId: 0, surah: 1, ayah: 1 }),
    RangeError,
  );
  assert.throws(
    () => validateTafsirCoordinates({ resourceId: 169, surah: 115 }),
    RangeError,
  );
  assert.throws(
    () => validateTafsirCoordinates({ resourceId: 169, surah: 2, ayah: 0 }),
    RangeError,
  );
});

test('single ayah tafsir is normalized to one entry', async () => {
  const entry = await fetchAyahTafsir(
    env,
    169,
    2,
    255,
    async (_env, path) => {
      assert.match(path, /^\/content\/api\/v4\/tafsirs\/169\?/);
      assert.match(path, /verse_key=2%3A255/);
      return jsonResponse({
        tafsirs: [
          {
            resource_id: 169,
            resource_name: 'Tafsir Ibn Kathir',
            language_name: 'english',
            text: '<p>Ayat al-Kursi tafsir</p>',
            verse_key: '2:255',
            chapter_id: 2,
            verse_number: 255,
          },
        ],
        pagination: {
          per_page: 50,
          current_page: 1,
          next_page: null,
          total_pages: 1,
          total_records: 1,
        },
      });
    },
  );

  assert.equal(entry.resource_id, 169);
  assert.equal(entry.verse_key, '2:255');
  assert.equal(entry.text, '<p>Ayat al-Kursi tafsir</p>');
});

test('whole Surah fetch follows pagination past 50 rows', async () => {
  const seenPages = [];
  const entries = await fetchSurahTafsir(
    env,
    169,
    2,
    async (_env, path) => {
      const uri = new URL(path, 'https://example.test');
      const page = Number(uri.searchParams.get('page'));
      seenPages.push(page);
      const start = page === 1 ? 1 : 51;
      const count = page === 1 ? 50 : 2;
      return jsonResponse({
        tafsirs: Array.from({ length: count }, (_, index) => {
          const ayah = start + index;
          return {
            resource_id: 169,
            resource_name: 'Test Tafsir',
            language_name: 'english',
            text: `<p>Entry ${ayah}</p>`,
            verse_key: `2:${ayah}`,
            chapter_id: 2,
            verse_number: ayah,
          };
        }),
        pagination: {
          per_page: 50,
          current_page: page,
          next_page: page === 1 ? 2 : null,
          total_pages: 2,
          total_records: 52,
        },
      });
    },
  );

  assert.deepEqual(seenPages, [1, 2]);
  assert.equal(entries.length, 52);
  assert.equal(entries[0].verse_key, '2:1');
  assert.equal(entries[51].verse_key, '2:52');
});

test('upstream failure becomes a safe TafsirUpstreamError', async () => {
  await assert.rejects(
    () =>
      fetchAyahTafsir(
        env,
        169,
        1,
        1,
        async () =>
          jsonResponse(
            {
              message: 'QF_CLIENT_SECRET=test-secret',
              type: 'unauthorized',
            },
            401,
          ),
      ),
    (error) => {
      assert.ok(error instanceof TafsirUpstreamError);
      assert.equal(error.statusCode, 401);
      assert.doesNotMatch(error.message, /test-secret/);
      return true;
    },
  );
});
