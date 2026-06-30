---
name: security
description: >
  Add CORS headers, rate limiting, and JWT authentication to a Bugeisha service.
  Use this when building protected endpoints, handling OPTIONS preflight,
  implementing token-based auth, or protecting against abuse on Cloudflare Workers.
---

# Skill: security

CORS, rate limiting, JWT auth — security primitives for edge APIs.

```ts
import { cors } from './middleware/cors';
import { rateLimit } from './middleware/rate-limit';

const router = Router({
  before: [cors, rateLimit({ windowMs: 60_000, max: 100 })],
});
```

## CORS

```ts
export function cors(request: Request): Response | void {
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });
  }
  // Continue — headers added to actual response
}
```

## Rate limiting (per-isolate)

```ts
const hits = new Map<string, { count: number; reset: number }>();

export function rateLimit(max = 100, windowMs = 60_000) {
  return (request: Request): Response | void => {
    const ip = request.headers.get('CF-Connecting-IP') ?? 'unknown';
    const now = Date.now();
    const record = hits.get(ip);

    if (!record || now > record.reset) {
      hits.set(ip, { count: 1, reset: now + windowMs });
      return;
    }

    record.count++;
    if (record.count > max) {
      return new Response('Too many requests', { status: 429 });
    }
  };
}
```

## JWT auth (Web Crypto, no deps)

```ts
export async function signJWT(payload: object, secret: string): Promise<string> {
  const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const body = btoa(JSON.stringify(payload));
  const signature = await crypto.subtle.sign(
    'HMAC',
    await crypto.subtle.importKey('raw', new TextEncoder().encode(secret),
      { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']),
    new TextEncoder().encode(`${header}.${body}`)
  );
  return `${header}.${body}.${btoa(String.fromCharCode(...new Uint8Array(signature)))}`;
}
```

## Gotchas

- CORS `*` is fine for dev, replace with specific origins in production
- Rate limit is per-isolate — resets on cold start, use KV/D1 for distributed
- JWT secret via `wrangler secret put JWT_SECRET`, never in code
- Rate limit `Map` grows unbounded — add periodic cleanup in production
- CORS middleware must return on OPTIONS before hitting rate limit
