export type TafsirManifestEnv = {
  TAFSIR_ZAKARIA_URL?: string;
  TAFSIR_ZAKARIA_SHA256?: string;
  TAFSIR_ZAKARIA_SIZE_BYTES?: string;
  TAFSIR_ZAKARIA_VERSION?: string;
};

export class TafsirManifestConfigError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "TafsirManifestConfigError";
  }
}

const SOURCE_ID = "bn.abubakar_zakaria.quranenc";
const SOURCE_NAME = "তাফসীরে আবু বকর যাকারিয়া";
const TRANSLATION_KEY = "bengali_zakaria";
const SOURCE_PAGE = "https://quranenc.com/bn/browse/bengali_zakaria";
const TERMS_URL = "https://quranenc.com/bn/home/about/terms-and-conditions";
const ATTRIBUTION =
  "ড. আবু বকর মুহাম্মাদ যাকারিয়া; source: QuranEnc.com; content republished without modification.";
const LICENSE =
  "QuranEnc republication terms apply: preserve content unchanged, credit publisher/source, retain version information, and update when the source publishes a newer version.";

export function buildZakariaManifest(env: TafsirManifestEnv) {
  const downloadUrl = env.TAFSIR_ZAKARIA_URL?.trim() ?? "";
  const sha256 = env.TAFSIR_ZAKARIA_SHA256?.trim().toLowerCase() ?? "";
  const version = env.TAFSIR_ZAKARIA_VERSION?.trim() ?? "";
  const sizeBytes = Number(env.TAFSIR_ZAKARIA_SIZE_BYTES);

  if (!downloadUrl.startsWith("https://")) {
    throw new TafsirManifestConfigError(
      "TAFSIR_ZAKARIA_URL must be an HTTPS URL",
    );
  }
  if (!/^[0-9a-f]{64}$/.test(sha256)) {
    throw new TafsirManifestConfigError(
      "TAFSIR_ZAKARIA_SHA256 must be a 64-character hexadecimal SHA-256",
    );
  }
  if (!Number.isSafeInteger(sizeBytes) || sizeBytes <= 0) {
    throw new TafsirManifestConfigError(
      "TAFSIR_ZAKARIA_SIZE_BYTES must be a positive integer",
    );
  }
  if (!/^[0-9]+(?:\.[0-9]+)*$/.test(version)) {
    throw new TafsirManifestConfigError(
      "TAFSIR_ZAKARIA_VERSION must contain only dot-separated integers",
    );
  }

  return {
    source_id: SOURCE_ID,
    name: SOURCE_NAME,
    language: "bn",
    version,
    download_url: downloadUrl,
    sha256,
    size_bytes: sizeBytes,
    attribution: ATTRIBUTION,
    license: LICENSE,
    translation_key: TRANSLATION_KEY,
    source_page: SOURCE_PAGE,
    terms_url: TERMS_URL,
  } as const;
}
