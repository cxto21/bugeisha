---
name: core
description: >
  Set up an Itty Router app with middleware pipeline for Cloudflare Workers.
  Use this when creating a new Nesa service, adding routes, or configuring
  request/response middleware. Covers Router setup, route registration,
  middleware ordering, and the fetch handler export.
---

# Skill: core

Itty Router + middleware pipeline. The foundation of every Nesa app.

```ts
import { Router, error, json } from 'itty-router';
import type { NesaRequest, Env } from './types';

const router = Router({
  before: [middleware1, middleware2],  // Request middleware (runs in order)
  catch: (err) => error(err),         // Error handler
  finally: [json],                    // Response transforms
});

// Route registration — explicit, no magic
router.get('/path', handler);
router.post('/path', handler);
router.all('*', () => error(404, 'Not found'));

// Always bind fetch to router
export default { fetch: router.fetch.bind(router) };
```

## Middleware rules

- Return `Response` to stop the pipeline (short-circuit)
- Return `void` to continue to next middleware/handler
- `before`: runs before handlers (auth, CORS, rate limit)
- `finally`: runs after handlers (response transforms, headers)

## Gotchas

- Always bind `fetch` — forgetting `.bind(router)` causes `this` context loss
- `catch` receives the error, not `(err, request)` — itty-router v5 simplified the signature
- Route order matters — `router.all('*', ...)` must be LAST or it catches everything
- `error()` from itty-router returns a Response, not throws — no try/catch needed

## Scaffold a new project

```bash
bash scripts/new.sh my-app
cd my-app && npm install && npm run dev
```

## Factory pattern

Use `createNesa()` for custom instances with different middleware stacks:

```ts
import { createNesa } from './router';
const adminRouter = createNesa({ middlewares: [auth, rateLimit] });
```
