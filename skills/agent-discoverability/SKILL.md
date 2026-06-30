---
name: agent-discoverability
description: >
  Make a Bugeisha service findable by AI agents. Use this when configuring robots.txt
  for bot directives, creating llms.txt for service descriptions, generating sitemap.xml
  for endpoint discovery, or optimizing for agent readiness scoring (isitagentready.com).
---

# Skill: agent-discoverability

Make your Bugeisha service findable by AI agents. Built-in handlers: `robots`, `llms`, `sitemap`.

## Routes (registered by default)

```ts
router.get('/robots.txt', robots);    // Bot rules + sitemap directive
router.get('/llms.txt', llms);        // Service description for agents
router.get('/sitemap.xml', sitemap);  // Endpoint discovery
```

## robots.txt

```
User-agent: GPTBot
Allow: /
Allow: /agent/*

User-agent: ClaudeBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: *
Disallow: /private/

Sitemap: https://your-domain.workers.dev/sitemap.xml
```

## llms.txt

Standard format for agent-friendly service description:

```markdown
# My Service

> Agent-native API for [purpose]

## Endpoints
- GET / — Service overview
- GET /health — Health check
- GET /agent/info — Capabilities
- GET /agent/tools — Tool definitions

## Auth
Bearer token via Authorization header.

## Rate limits
100 requests/minute per IP.
```

## Priority

1. **robots.txt** — easy win, tells bots what to crawl
2. **llms.txt** — agent understanding, what your service does
3. **sitemap.xml** — endpoint discovery, all routes listed

## Gotchas

- Google ignores llms.txt (June 2026 official stance)
- Other agents (Perplexity, Claude, ChatGPT) DO use llms.txt
- robots.txt is advisory — well-behaved bots respect it, malicious ones don't
- Sitemap helps agents discover endpoints they'd otherwise miss
- See isitagentready.com for comprehensive scoring
