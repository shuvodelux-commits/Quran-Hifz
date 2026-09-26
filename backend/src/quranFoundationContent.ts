export type QfFetcher<E> = (
  env: E,
  path: string,
  init?: RequestInit,
) => Promise<Response>;

export type ContentResourceGroup = 'translations' | 'tafsirs';

export type ContentResource = {
  id: number;
  name: string;
  author_name?: string | null;
  slug?: string;
  language_name?: string;
  translated_name?: {
    name?: string;
    language_name?: string;
  };
};

export type ContentSnapshotRecord = {
  resource_id: number;
  verse_key: string;
  text: string;
  language_name?: string;
};

export type ContentSnapshot = {
  resource_group: ContentResourceGroup;
  resource_id: number;
  resource_content_id?: number | null;
  records: ContentSnapshotRecord[];
};

export class ContentResourceUpstreamError extends Error {
  readonly statusCode: number;

  constructor(statusCode: number) {
    super('Quran content source is temporarily unavailable.');
    this.name = 'ContentResourceUpstreamError';
    this.statusCode = statusCode;
  }
}

export function validateSnapshotRequest(
  group: string,
  resourceId: number,
): asserts group is ContentResourceGroup {
  if (group !== 'translations' && group !== 'tafsirs') {
    throw new RangeError('Unsupported content resource group');
  }
  if (!Number.isInteger(resourceId) || resourceId <= 0) {
    throw new RangeError('resourceId must be a positive integer');
  }
}

export async function fetchTranslationResources<E>(
  env: E,
  language: string,
  fetcher: QfFetcher<E>,
): Promise<ContentResource[]> {
  const normalizedLanguage = language.trim() || 'en';
  const response = await fetcher(
    env,
    `/content/api/v4/resources/translations?language=${encodeURIComponent(normalizedLanguage)}`,
  );
  const json = await readJson(response);
  const rows = json.translations;
  if (!Array.isArray(rows)) {
    throw new Error('Quran Foundation translation catalog response is invalid.');
  }
  return rows.map(parseResource);
}

export async function fetchContentSnapshot<E>(
  env: E,
  group: string,
  resourceId: number,
  fetcher: QfFetcher<E>,
): Promise<ContentSnapshot> {
  validateSnapshotRequest(group, resourceId);
  const response = await fetcher(
    env,
    `/content/api/v4/resources/snapshots/${group}/${resourceId}`,
  );
  const json = await readJson(response);
  if (
    json.resource_group !== group ||
    json.resource_id !== resourceId ||
    !Array.isArray(json.records)
  ) {
    throw new Error('Quran Foundation content snapshot identity is invalid.');
  }
  return {
    resource_group: group,
    resource_id: resourceId,
    resource_content_id:
      typeof json.resource_content_id === 'number' ||
      json.resource_content_id === null
        ? json.resource_content_id
        : undefined,
    records: json.records.map((record) => parseSnapshotRecord(record, resourceId)),
  };
}

async function readJson(response: Response): Promise<Record<string, unknown>> {
  if (!response.ok) {
    throw new ContentResourceUpstreamError(response.status);
  }
  const value: unknown = await response.json();
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('Quran Foundation content response must be an object.');
  }
  return value as Record<string, unknown>;
}

function parseResource(value: unknown): ContentResource {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('Quran Foundation content resource is invalid.');
  }
  const row = value as Record<string, unknown>;
  if (
    typeof row.id !== 'number' ||
    !Number.isInteger(row.id) ||
    row.id <= 0 ||
    typeof row.name !== 'string' ||
    row.name.trim() === ''
  ) {
    throw new Error('Quran Foundation content resource identity is invalid.');
  }
  const translated = row.translated_name;
  return {
    id: row.id,
    name: row.name,
    author_name:
      row.author_name === null || typeof row.author_name === 'string'
        ? row.author_name
        : undefined,
    slug: typeof row.slug === 'string' ? row.slug : undefined,
    language_name:
      typeof row.language_name === 'string' ? row.language_name : undefined,
    translated_name:
      translated !== null &&
      typeof translated === 'object' &&
      !Array.isArray(translated)
        ? {
            name:
              typeof (translated as Record<string, unknown>).name === 'string'
                ? ((translated as Record<string, unknown>).name as string)
                : undefined,
            language_name:
              typeof (translated as Record<string, unknown>).language_name ===
              'string'
                ? ((translated as Record<string, unknown>)
                    .language_name as string)
                : undefined,
          }
        : undefined,
  };
}

function parseSnapshotRecord(
  value: unknown,
  expectedResourceId: number,
): ContentSnapshotRecord {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('Quran Foundation snapshot record is invalid.');
  }
  const row = value as Record<string, unknown>;
  if (
    row.resource_id !== expectedResourceId ||
    typeof row.verse_key !== 'string' ||
    !/^\d+:\d+$/.test(row.verse_key) ||
    typeof row.text !== 'string'
  ) {
    throw new Error('Quran Foundation snapshot record identity is invalid.');
  }
  return {
    resource_id: expectedResourceId,
    verse_key: row.verse_key,
    text: row.text,
    language_name:
      typeof row.language_name === 'string' ? row.language_name : undefined,
  };
}
