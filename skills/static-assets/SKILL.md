---
name: static-assets
description: >
  Serve static files from a Nesa service on Cloudflare Workers. Use this when
  adding HTML, CSS, JS, or image assets to an API service, or when deciding
  between Workers static assets and Cloudflare Pages for a full site.
---

# Skill: static-assets

Serve static files from Workers. Cloudflare handles the heavy lifting.

## Setup

```toml
# wrangler.toml
[assets]
directory = "public"
binding = "ASSETS"
```

```ts
// In handler
export default {
  async fetch(request: Request, env: Env) {
    // Serve static file
    if (request.url.includes('/static/')) {
      return env.ASSETS.fetch(request);
    }
    // API routes
    return router.handle(request);
  },
};
```

## When to use what

| Scenario | Solution |
|----------|----------|
| API + few static files | Workers + `ASSETS` binding |
| Full static site (SPA) | Cloudflare Pages |
| Dynamic assets (generated) | KV with caching |
| Large files (>10MB) | R2 storage |

## Example HTML

See `assets/example.html` for a starter template with meta tags, structured data (JSON-LD), and responsive design.

## Gotchas

- `[assets]` directory is relative to `wrangler.toml`
- `ASSETS.fetch()` returns 404 for missing files — no error thrown
- For API + static: route `/static/*` to assets, rest to handlers
- Pages is better for full sites — Workers assets are for API-first services
- KV is for dynamic content that needs caching, not static files
