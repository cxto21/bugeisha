# AGENTS.md — Bugeisha Framework

Agent-native micro-framework for Cloudflare Workers. Ultra-light, explicit routes, no magic.

## Project Overview

Bugeisha is a minimal framework for building APIs that serve both humans and AI agents. Same routes, different responses: JSON for agents, HTML for humans.

**Stack**: TypeScript, Itty Router v5, Cloudflare Workers
** Philosophy**: Extreme minimalism. Explicit routes. No magic. Linear flow.

## Setup Commands

```bash
npm install          # Install dependencies
npm run dev          # Start local dev server (wrangler)
npm run deploy       # Deploy to Cloudflare Workers
npm test             # Run tests with Vitest
npm run test:watch   # Run tests in watch mode
```

## Code Style

- TypeScript strict mode
- Explicit route registration (no decorators, no magic)
- Middleware returns `Response` to stop, `void` to continue
- Always bind `fetch` to router: `export default { fetch: router.fetch.bind(router) }`
- Use `BugeishaRequest` type for request objects with `isAgent` flag
- Handlers receive `(request, env)` — keep them pure when possible

## Testing Instructions

```bash
npm test             # Run all tests
npm run test:watch   # Watch mode
```

- Test handlers as pure functions
- Mock `env` and `ctx` for unit tests
- Use Vitest with Cloudflare Workers pool
- Verify both agent (JSON) and human (HTML) responses

## Project Structure

```
src/
├── index.ts              # Entry point + exports
├── router.ts             # Core router with middleware pipeline
├── types.ts              # Env, BugeishaRequest, BugeishaHandler types
├── middleware/
│   ├── agent-detect.ts   # AI/bot/human detection
│   ├── cors.ts           # CORS preflight handling
│   ├── auth.ts           # Bearer token authentication
│   └── rate-limit.ts     # In-memory rate limiting
└── handlers/
    ├── home.ts           # Home (dual response)
    ├── health.ts         # Health check
    ├── agent.ts          # Agent info endpoint
    ├── agent-tools.ts    # Tool definitions for function calling
    ├── robots.ts         # Agent-aware robots.txt
    ├── llms.ts           # Service description for agents
    └── sitemap.ts        # XML sitemap for discovery
```

## Skills

Skills are in `skills/` as folders with `SKILL.md` + optional scripts/assets. Each skill follows AgentSkills.io standard:

```bash
ls skills/
# core/  security/  agent-native/  storage/  devex/
# devops/  static-assets/  queues/  protocols/  agent-discoverability/
```

To use a skill: read `skills/<name>/SKILL.md` for instructions.

## Agent-Native Patterns

- **Agent detection**: Check User-Agent for AI patterns (openai, gpt, claude, anthropic)
- **Dual responses**: Same route returns JSON for agents, HTML for humans
- **Tool definitions**: `/agent/tools` returns OpenAI-compatible function calling format
- **Discoverability**: `/robots.txt`, `/llms.txt`, `/sitemap.xml` for agent discovery

## Deployment

```bash
npm run deploy              # Deploy to production
wrangler deploy --env staging  # Deploy to staging
wrangler secret put API_KEY    # Add secrets
wrangler tail                 # Live logs
```

## Gotchas

- Always bind `fetch` to router — forgetting `.bind(router)` causes `this` context loss
- Rate limit is per-isolate — use KV/D1 for distributed rate limiting in production
- KV is eventually consistent (~60s propagation) — D1 for strong consistency
- Agent detection is best-effort — agents can spoof User-Agent
- `error()` from itty-router returns a Response, not throws — no try/catch needed
