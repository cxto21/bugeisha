---
name: agents-md
description: >
  Create AGENTS.md files for Bugeisha projects. Use this when adding agent instructions
  to a project, configuring multi-agent coordination, or documenting build/test/style
  rules for AI assistants working on the codebase.
---

# Skill: agents-md

Add `AGENTS.md` files so AI agents understand your project. Complements README.md (human docs → `README.md`, agent docs → `AGENTS.md`).

## Structure

```markdown
# AGENTS.md — Project Name

## Project Overview
One paragraph: what it does, stack, philosophy.

## Setup Commands
npm install / npm run dev / npm test

## Code Style
TypeScript strict, explicit routes, no magic, etc.

## Testing Instructions
Test commands, frameworks, conventions.

## Project Structure
Folder tree with one-line descriptions.

## Gotchas
Things agents get wrong without this file.
```

## Rules

| Rule | Detail |
|------|--------|
| Format | Standard Markdown, no YAML required |
| Location | Project root, or nested in monorepos (closest to edited file wins) |
| Scope | Build/test commands, code style, conventions, gotchas |
| Avoid | Business logic, feature docs, user guides → those go in README |
| Completeness | Cover what an agent MUST know to avoid breaking the build |

## Bugeisha AGENTS.md Template

```markdown
# AGENTS.md — [Project]

## Project Overview
Agent-native API for [purpose]. TypeScript, Itty Router, Cloudflare Workers.

## Setup Commands
npm install | npm run dev | npm test | npm run deploy

## Code Style
- TypeScript strict mode
- Explicit route registration (no decorators)
- Middleware returns Response to stop, void to continue
- Bind fetch: `export default { fetch: router.fetch.bind(router) }`

## Project Structure
src/router.ts — Core routes
src/middleware/ — Agent detect, CORS, auth, rate-limit
src/handlers/ — Route handlers

## Gotchas
- Always bind fetch to router (this context loss)
- Rate limit is per-isolate (not distributed)
- KV is eventually consistent (~60s)
```

## Gotchas

- README is for humans, AGENTS.md is for agents — don't duplicate
- Nested AGENTS.md overrides parent in monorepos
- Keep it short: agents scan, not read
- Include test commands — agents that don't test break builds
- Include gotchas — agents repeat the same mistakes without them
