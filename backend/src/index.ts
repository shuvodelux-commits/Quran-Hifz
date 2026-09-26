import { Hono } from "hono";
import { cors } from "hono/cors";
import { qfFetch, type Env } from "./quranFoundation";
import {
  ContentResourceUpstreamError,
  fetchContentSnapshot,
  fetchTranslationResources,
} from "./quranFoundationContent";
import {
  TafsirUpstreamError,
  fetchAyahTafsir,
  fetchSurahTafsir,
  fetchTafsirResources,
} from "./quranFoundationTafsir";
import { buildZakariaManifest, TafsirManifestConfigError } from "./tafsir";

const app = new Hono<{ Bindings: Env }>();

app.use(
  "/api/*",
  cors({
    origin: "*",
    allowMethods: ["GET", "OPTIONS"],
  }),
);

app.get("/health", (c) => c.json({ ok: true }));

app.get("/api/quran/chapter-reciters", async (c) => {
  const response = await qfFetch(
    c.env,
    "/content/api/v4/resources/chapter_reciters?language=en",
  );

  return new Response(response.body, {
    status: response.status,
    headers: {
      "content-type":
        response.headers.get("content-type") ?? "application/json",
      "cache-control": "public, max-age=86400",
    },
  });
});

app.get("/api/quran/translations/resources", async (c) => {
  const language = c.req.query("language")?.trim() || "en";
  if (!/^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{2,8})*$/.test(language)) {
    return c.json({ error: "Invalid language" }, 400);
  }
  try {
    const translations = await fetchTranslationResources(
      c.env,
      language,
      qfFetch,
    );
    return c.json({ translations }, 200, {
      "cache-control": "public, max-age=86400",
    });
  } catch (error) {
    if (error instanceof ContentResourceUpstreamError) {
      return c.json({ error: error.message }, 502);
    }
    throw error;
  }
});

app.get("/api/quran/content/:group/:resourceId/snapshot", async (c) => {
  const group = c.req.param("group");
  const resourceId = Number(c.req.param("resourceId"));
  try {
    const snapshot = await fetchContentSnapshot(
      c.env,
      group,
      resourceId,
      qfFetch,
    );
    return c.json(snapshot, 200, {
      "cache-control": "no-store",
    });
  } catch (error) {
    if (error instanceof RangeError) {
      return c.json({ error: "Invalid content resource" }, 400);
    }
    if (error instanceof ContentResourceUpstreamError) {
      return c.json({ error: error.message }, 502);
    }
    throw error;
  }
});

app.get("/api/quran/chapter-audio", async (c) => {
  const reciterId = Number(c.req.query("reciterId"));
  const surah = Number(c.req.query("surah"));
  const segments = c.req.query("segments") !== "false";

  if (!Number.isInteger(reciterId) || reciterId <= 0) {
    return c.json({ error: "Invalid reciterId" }, 400);
  }

  if (!Number.isInteger(surah) || surah < 1 || surah > 114) {
    return c.json({ error: "Surah must be between 1 and 114" }, 400);
  }

  const response = await qfFetch(
    c.env,
    `/content/api/v4/chapter_recitations/${reciterId}/${surah}?segments=${segments}`,
  );

  return new Response(response.body, {
    status: response.status,
    headers: {
      "content-type":
        response.headers.get("content-type") ?? "application/json",
      "cache-control": "public, max-age=86400",
    },
  });
});

app.get("/api/tafsir/resources", async (c) => {
  const language = c.req.query("language")?.trim() || "bn";
  if (!/^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{2,8})*$/.test(language)) {
    return c.json({ error: "Invalid language" }, 400);
  }
  try {
    const tafsirs = await fetchTafsirResources(c.env, language, qfFetch);
    return c.json({ tafsirs }, 200, {
      "cache-control": "public, max-age=86400",
    });
  } catch (error) {
    if (error instanceof TafsirUpstreamError) {
      return c.json({ error: error.message }, 502);
    }
    throw error;
  }
});

app.get("/api/tafsir/:resourceId/ayah/:surah/:ayah", async (c) => {
  const resourceId = Number(c.req.param("resourceId"));
  const surah = Number(c.req.param("surah"));
  const ayah = Number(c.req.param("ayah"));
  try {
    const entry = await fetchAyahTafsir(
      c.env,
      resourceId,
      surah,
      ayah,
      qfFetch,
    );
    return c.json({ entry }, 200, {
      "cache-control": "public, max-age=86400",
    });
  } catch (error) {
    if (error instanceof RangeError) {
      return c.json({ error: "Invalid Tafsir coordinates" }, 400);
    }
    if (error instanceof TafsirUpstreamError) {
      return c.json({ error: error.message }, 502);
    }
    throw error;
  }
});

app.get("/api/tafsir/:resourceId/surah/:surah", async (c) => {
  const resourceId = Number(c.req.param("resourceId"));
  const surah = Number(c.req.param("surah"));
  try {
    const entries = await fetchSurahTafsir(
      c.env,
      resourceId,
      surah,
      qfFetch,
    );
    return c.json({ entries }, 200, {
      "cache-control": "public, max-age=86400",
    });
  } catch (error) {
    if (error instanceof RangeError) {
      return c.json({ error: "Invalid Tafsir coordinates" }, 400);
    }
    if (error instanceof TafsirUpstreamError) {
      return c.json({ error: error.message }, 502);
    }
    throw error;
  }
});

app.get("/api/tafsir/bn-zakaria/manifest", (c) => {
  try {
    return c.json(buildZakariaManifest(c.env), 200, {
      "cache-control": "public, max-age=300",
    });
  } catch (error) {
    if (error instanceof TafsirManifestConfigError) {
      return c.json({ error: "Bangla tafsir package is not configured." }, 503);
    }
    throw error;
  }
});

export default app;
