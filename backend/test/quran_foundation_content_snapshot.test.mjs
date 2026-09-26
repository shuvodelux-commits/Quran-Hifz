import assert from 'node:assert/strict';
import test from 'node:test';

import {
  ContentResourceUpstreamError,
  fetchContentSnapshot,
  fetchTranslationResources,
  validateSnapshotRequest,
} from '../src/quranFoundationContent.ts';

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

test('translation catalog is requested with localized resource names', async () => {
  const paths = [];
  const rows = await fetchTranslationResources(env, 'bn', async (_env, path) => {
    paths.push(path);
    return jsonResponse({
      translations: [
        {
          id: 20,
          name: 'Sahih International',
          author_name: 'Saheeh International',
          slug: 'en-sahih-international',
          language_name: 'english',
          translated_name: {
            name: 'সহীহ ইন্টারন্যাশনাল',
            language_name: 'bengali',
          },
        },
      ],
    });
  });

  assert.deepEqual(paths, [
    '/content/api/v4/resources/translations?language=bn',
  ]);
  assert.equal(rows[0].id, 20);
  assert.equal(rows[0].name, 'Sahih International');
  assert.equal(rows[0].language_name, 'english');
});

test('snapshot request accepts only translations and tafsirs', () => {
  assert.doesNotThrow(() => validateSnapshotRequest('translations', 20));
  assert.doesNotThrow(() => validateSnapshotRequest('tafsirs', 169));
  assert.throws(() => validateSnapshotRequest('recitations', 20), RangeError);
  assert.throws(() => validateSnapshotRequest('translations', 0), RangeError);
});

test('translation snapshot keeps all records and identity', async () => {
  const snapshot = await fetchContentSnapshot(
    env,
    'translations',
    20,
    async (_env, path) => {
      assert.equal(
        path,
        '/content/api/v4/resources/snapshots/translations/20',
      );
      return jsonResponse({
        resource_group: 'translations',
        resource_id: 20,
        resource_content_id: 20,
        records: [
          {
            resource_id: 20,
            verse_key: '1:1',
            text: 'In the Name of Allah...',
            language_name: 'english',
          },
          {
            resource_id: 20,
            verse_key: '1:2',
            text: 'All praise is for Allah...',
            language_name: 'english',
          },
        ],
      });
    },
  );

  assert.equal(snapshot.resource_group, 'translations');
  assert.equal(snapshot.resource_id, 20);
  assert.equal(snapshot.records.length, 2);
  assert.equal(snapshot.records[1].verse_key, '1:2');
});

test('tafsir snapshot keeps tafsir records', async () => {
  const snapshot = await fetchContentSnapshot(
    env,
    'tafsirs',
    169,
    async () =>
      jsonResponse({
        resource_group: 'tafsirs',
        resource_id: 169,
        resource_content_id: 169,
        records: [
          {
            resource_id: 169,
            verse_key: '1:1',
            text: '<p>Tafsir text</p>',
            language_name: 'english',
          },
        ],
      }),
  );

  assert.equal(snapshot.resource_group, 'tafsirs');
  assert.equal(snapshot.records[0].resource_id, 169);
});

test('snapshot upstream errors never expose credentials', async () => {
  await assert.rejects(
    () =>
      fetchContentSnapshot(env, 'translations', 20, async () =>
        jsonResponse(
          { message: 'QF_CLIENT_SECRET=test-secret' },
          401,
        ),
      ),
    (error) => {
      assert.ok(error instanceof ContentResourceUpstreamError);
      assert.equal(error.statusCode, 401);
      assert.doesNotMatch(error.message, /test-secret/);
      return true;
    },
  );
});
