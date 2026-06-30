# AGENTS.md — Bugeisha 🪆

Ultra-light agent-native micro-framework for Cloudflare Workers. ~200 LOC. TypeScript + Itty Router v5.

## Language Rule

**All project files, documentation, comments, and commit messages MUST be in English.**  
The maintainer speaks Spanish, but the codebase is English-only. Never write in Spanish in any project file.

## What It Does

APIs that serve two audiences: **humans** (HTML) and **AI agents** (JSON). Same route, different response. No magic, no decorators.

## How to Run

```bash
npm install
npm run dev        # localhost:8787
npm test           # 26 tests (vitest)
```

## Project Structure

```
src/
├── index.ts          # Entry point + exports
├── router.ts         # createBugeisha() + middleware pipeline
├── types.ts          # Env, BugeishaRequest, BugeishaHandler
├── middleware/        # agent-detect, auth, cors, rate-limit
└── handlers/         # home, health, agent, agent-tools, robots, llms, sitemap

examples/
└── multi-agent-coordinator/   # Full example with DO + WebSocket

skills/               # Guides, not code (14 skills)

docs/
├── architecture.md   # How it works internally
├── conventions.md    # Naming, structure, patterns
├── roadmap.md        # Current status and next steps
└── decisions/        # Architecture Decision Records

tasks/
├── TODO.md           # Pending work
├── current.md        # What I'm doing now
└── backlog.md        # Ideas and priorities
```

## Style Rules

- TypeScript strict mode
- Explicit routes (no decorators, no magic)
- Middleware returns `Response` to stop, `void` to continue
- Always bind: `export default { fetch: router.fetch.bind(router) }`
- Pure handlers: `(request, env) => Response`
- Only Itty Router as core dependency

## Files Never to Modify

- `src/router.ts` — Core logic
- `src/types.ts` — Shared types
- `wrangler.toml` — Cloudflare config
- `package.json` — Dependencies

## How to Run Tests

```bash
npm test                    # All
npm run test:watch          # Watch mode
npm test -- middleware       # Middleware only
npm test -- handlers        # Handlers only
```

Tests use lightweight inline mocks. No extra test dependencies.

## What to Read First

1. **This file** — Overview
2. `docs/architecture.md` — How it works internally
3. `docs/conventions.md` — Naming, structure, patterns
4. `src/types.ts` — Available types

## Agent Protocol

When working on this repo, follow this protocol:

1. **Read** `AGENTS.md` first (this file)
2. **Read** `CURRENT_TASK.md` to understand current state
3. **Execute** the task
4. **Update** `CURRENT_TASK.md` with results
5. **Add decisions** to `docs/DECISIONS.md` if any were made
6. **Update** `tasks/TODO.md` if needed

This allows any agent (Claude, Codex, Gemini, etc.) to continue where another left off.  
Switch models without losing continuity.

## Gotchas

- `request.url` is a string, not a URL — use `new URL(request.url)` for searchParams
- Rate limit is per-isolate — use KV/D1 for production
- Agent detection is best-effort — agents can spoof User-Agent
- KV is eventually consistent (~60s) — D1 for strong consistency
