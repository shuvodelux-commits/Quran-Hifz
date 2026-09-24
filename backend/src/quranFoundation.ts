import type { TafsirManifestEnv } from "./tafsir";

export type Env = {
  QF_CLIENT_ID: string;
  QF_CLIENT_SECRET: string;
  QF_ENV?: "prelive" | "production";
} & TafsirManifestEnv;

type CachedToken = {
  value: string;
  expiresAt: number;
};

let cachedToken: CachedToken | null = null;
let inflight: Promise<string> | null = null;

function urls(env: Env) {
  const mode = env.QF_ENV ?? "prelive";

  if (mode === "production") {
    return {
      authBase: "https://oauth2.quran.foundation",
      apiBase: "https://apis.quran.foundation",
    };
  }

  return {
    authBase: "https://prelive-oauth2.quran.foundation",
    apiBase: "https://apis-prelive.quran.foundation",
  };
}

async function requestToken(env: Env): Promise<string> {
  const { authBase } = urls(env);
  const basic = btoa(`${env.QF_CLIENT_ID}:${env.QF_CLIENT_SECRET}`);

  const response = await fetch(`${authBase}/oauth2/token`, {
    method: "POST",
    headers: {
      Authorization: `Basic ${basic}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "client_credentials",
      scope: "content",
    }),
  });

  if (!response.ok) {
    throw new Error(`Quran Foundation token request failed: ${response.status}`);
  }

  const json = await response.json<{
    access_token: string;
    expires_in: number;
  }>();

  cachedToken = {
    value: json.access_token,
    expiresAt: Date.now() + json.expires_in * 1000,
  };

  return json.access_token;
}

async function getToken(env: Env): Promise<string> {
  if (cachedToken && Date.now() < cachedToken.expiresAt - 30_000) {
    return cachedToken.value;
  }

  inflight ??= requestToken(env).finally(() => {
    inflight = null;
  });

  return inflight;
}

export async function qfFetch(
  env: Env,
  path: string,
  init?: RequestInit,
): Promise<Response> {
  const { apiBase } = urls(env);

  const makeRequest = async () => {
    const token = await getToken(env);

    return fetch(`${apiBase}${path}`, {
      ...init,
      headers: {
        ...(init?.headers ?? {}),
        "x-auth-token": token,
        "x-client-id": env.QF_CLIENT_ID,
        Accept: "application/json",
      },
    });
  };

  let response = await makeRequest();

  if (response.status === 401) {
    cachedToken = null;
    response = await makeRequest();
  }

  return response;
}
