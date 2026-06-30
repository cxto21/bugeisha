---
name: devex
description: >
  Set up logging, error handling, and environment configuration for a Nesa service.
  Use this when adding structured logging, consistent error responses, typed
  environment bindings, or local development configuration with `.dev.vars`.
---

# Skill: devex

Logger, error handler, env config — developer experience essentials.

## Structured logger

```ts
export function log(request: Request, status: number, start: number): void {
  const url = new URL(request.url);
  const duration = Date.now() - start;
  console.log(JSON.stringify({
    method: request.method,
    path: url.pathname,
    status,
    duration_ms: duration,
    ip: request.headers.get('CF-Connecting-IP'),
    ua: request.headers.get('User-Agent')?.slice(0, 50),
  }));
}
```

## Consistent error responses

```ts
export function err(status: number, message: string, details?: object): Response {
  return Response.json(
    { error: { status, message, ...(details && { details }) } },
    { status }
  );
}

// Usage in handlers
router.get('/users/:id', async (request, env) => {
  const user = await env.DB.prepare('SELECT * FROM users WHERE id = ?')
    .bind(request.params.id).first();
  if (!user) return err(404, 'User not found');
  return user;
});
```

## Environment config

```ts
// types.ts
export interface Env {
  API_KEY: string;
  CACHE: KVNamespace;
  DB: D1Database;
}

// .dev.vars (local secrets, never committed)
API_KEY=local-dev-key
```

## Gotchas

- `console.log` goes to `wrangler tail` — not visible in browser
- Never log secrets — use redaction for sensitive fields
- Error responses should be generic for 5xx (don't leak internals)
- `.dev.vars` is for local only — production uses `wrangler secret put`
- Structured JSON logs work with log pipelines (Datadog, Logflare, etc.)
