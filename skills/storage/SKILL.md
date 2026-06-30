---
name: storage
description: >
  Add Cloudflare KV and D1 persistence to a Bugeisha service. Use this when
  implementing caching, sessions, feature flags (KV), or relational data
  storage with SQL queries (D1). Covers bindings, CRUD operations, and
  when to use each storage type.
---

# Skill: storage

KV for fast reads, D1 for relational data — Cloudflare edge persistence.

## KV (eventual consistency, fast reads)

```ts
// In wrangler.toml: [[kv_namespaces]] binding = "CACHE" id = "..."

// Read
const value = await env.CACHE.get('key');           // string | null
const json = await env.CACHE.get('key', 'json');    // parsed object

// Write
await env.CACHE.put('key', 'value', { expirationTtl: 3600 });

// Delete
await env.CACHE.delete('key');
```

## D1 (strong consistency, SQL)

```ts
// In wrangler.toml: [[d1_databases]] binding = "DB" database_name = "..."

// Single row
const user = await env.DB.prepare('SELECT * FROM users WHERE id = ?')
  .bind(userId)
  .first();

// Multiple rows
const { results } = await env.DB.prepare('SELECT * FROM users LIMIT ?')
  .bind(10)
  .all();

// Write
await env.DB.prepare('INSERT INTO users (name, email) VALUES (?, ?)')
  .bind(name, email)
  .run();
```

## When to use what

| Use case | KV | D1 |
|----------|----|----|
| Cache / session | ✅ | ❌ |
| Feature flags | ✅ | ❌ |
| Rate limit counters | ✅ | ❌ |
| User data | ❌ | ✅ |
| Relational queries | ❌ | ✅ |
| Audit logs | ❌ | ✅ |

## Gotchas

- KV is eventually consistent — ~60s propagation across regions
- D1 queries are strongly consistent within a region
- KV `put` with `expirationTtl` is in seconds, not milliseconds
- D1 `.run()` returns `{ success, meta }` — check `success` for write operations
- Both require `wrangler.toml` bindings — types come from `@cloudflare/workers-types`
- KV `get` returns `null` for missing keys, not `undefined`
