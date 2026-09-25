export type QfFetcher<E> = (
  env: E,
  path: string,
  init?: RequestInit,
) => Promise<Response>;

export type TafsirResource = {
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

export type TafsirRow = {
  resource_id: number;
  resource_name?: string;
  language_name?: string;
  text: string;
  verse_key: string;
  chapter_id?: number;
  verse_number?: number;
};

export class TafsirUpstreamError extends Error {
  readonly statusCode: number;

  constructor(statusCode: number) {
    super('Tafsir source is temporarily unavailable.');
    this.name = 'TafsirUpstreamError';
    this.statusCode = statusCode;
  }
}

export function validateTafsirCoordinates({
  resourceId,
  surah,
  ayah,
}: {
  resourceId: number;
  surah: number;
  ayah?: number;
}) {
  if (!Number.isInteger(resourceId) || resourceId <= 0) {
    throw new RangeError('resourceId must be a positive integer');
  }
  if (!Number.isInteger(surah) || surah < 1 || surah > 114) {
    throw new RangeError('surah must be between 1 and 114');
  }
  if (ayah !== undefined && (!Number.isInteger(ayah) || ayah <= 0)) {
    throw new RangeError('ayah must be a positive integer');
  }
}

export async function fetchTafsirResources<E>(
  env: E,
  language: string,
  fetcher: QfFetcher<E>,
): Promise<TafsirResource[]> {
  const normalizedLanguage = language.trim() || 'en';
  const params = new URLSearchParams({ language: normalizedLanguage });
  const response = await fetcher(
    env,
    `/content/api/v4/resources/tafsirs?${params.toString()}`,
  );
  const json = await readJson(response);
  const rows = json.tafsirs;
  if (!Array.isArray(rows)) {
    throw new Error('Quran Foundation Tafsir catalog response is invalid.');
  }
  return rows.map(parseResource);
}

export async function fetchAyahTafsir<E>(
  env: E,
  resourceId: number,
  surah: number,
  ayah: number,
  fetcher: QfFetcher<E>,
): Promise<TafsirRow | null> {
  validateTafsirCoordinates({ resourceId, surah, ayah });
  const params = new URLSearchParams({
    verse_key: `${surah}:${ayah}`,
    per_page: '50',
    fields: 'resource_name,language_name,chapter_id,verse_number,verse_key',
  });
  const response = await fetcher(
    env,
    `/content/api/v4/tafsirs/${resourceId}?${params.toString()}`,
  );
  const json = await readJson(response);
  const rows = json.tafsirs;
  if (!Array.isArray(rows)) {
    throw new Error('Quran Foundation Tafsir ayah response is invalid.');
  }
  if (rows.length === 0) return null;
  return parseRow(rows[0]);
}

export async function fetchSurahTafsir<E>(
  env: E,
  resourceId: number,
  surah: number,
  fetcher: QfFetcher<E>,
): Promise<TafsirRow[]> {
  validateTafsirCoordinates({ resourceId, surah });
  const entries: TafsirRow[] = [];
  let page = 1;
  while (true) {
    const params = new URLSearchParams({
      chapter_number: `${surah}`,
      page: `${page}`,
      per_page: '50',
      fields: 'resource_name,language_name,chapter_id,verse_number,verse_key',
    });
    const response = await fetcher(
      env,
      `/content/api/v4/tafsirs/${resourceId}?${params.toString()}`,
    );
    const json = await readJson(response);
    const rows = json.tafsirs;
    if (!Array.isArray(rows)) {
      throw new Error('Quran Foundation Tafsir Surah response is invalid.');
    }
    entries.push(...rows.map(parseRow));

    const pagination = json.pagination;
    if (
      pagination === null ||
      typeof pagination !== 'object' ||
      Array.isArray(pagination)
    ) {
      throw new Error('Quran Foundation Tafsir pagination is invalid.');
    }
    const nextPage = (pagination as Record<string, unknown>).next_page;
    if (nextPage === null || nextPage === undefined) break;
    if (
      typeof nextPage !== 'number' ||
      !Number.isInteger(nextPage) ||
      nextPage <= page
    ) {
      throw new Error('Quran Foundation Tafsir pagination did not advance.');
    }
    page = nextPage;
  }

  entries.sort((a, b) => {
    const aVerse = a.verse_number ?? parseVerseNumber(a.verse_key);
    const bVerse = b.verse_number ?? parseVerseNumber(b.verse_key);
    return aVerse - bVerse;
  });
  return entries;
}

async function readJson(response: Response): Promise<Record<string, unknown>> {
  if (!response.ok) {
    throw new TafsirUpstreamError(response.status);
  }
  const value: unknown = await response.json();
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('Quran Foundation Tafsir response must be an object.');
  }
  return value as Record<string, unknown>;
}

function parseResource(value: unknown): TafsirResource {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('Quran Foundation Tafsir resource is invalid.');
  }
  const row = value as Record<string, unknown>;
  if (
    typeof row.id !== 'number' ||
    !Number.isInteger(row.id) ||
    row.id <= 0 ||
    typeof row.name !== 'string' ||
    row.name.trim() === ''
  ) {
    throw new Error('Quran Foundation Tafsir resource identity is invalid.');
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

function parseRow(value: unknown): TafsirRow {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('Quran Foundation Tafsir row is invalid.');
  }
  const row = value as Record<string, unknown>;
  if (
    typeof row.resource_id !== 'number' ||
    !Number.isInteger(row.resource_id) ||
    typeof row.text !== 'string' ||
    typeof row.verse_key !== 'string' ||
    !/^\d+:\d+$/.test(row.verse_key)
  ) {
    throw new Error('Quran Foundation Tafsir row identity is invalid.');
  }
  return {
    resource_id: row.resource_id,
    resource_name:
      typeof row.resource_name === 'string' ? row.resource_name : undefined,
    language_name:
      typeof row.language_name === 'string' ? row.language_name : undefined,
    text: row.text,
    verse_key: row.verse_key,
    chapter_id:
      typeof row.chapter_id === 'number' ? row.chapter_id : undefined,
    verse_number:
      typeof row.verse_number === 'number' ? row.verse_number : undefined,
  };
}

function parseVerseNumber(verseKey: string): number {
  return Number(verseKey.split(':')[1]);
}
