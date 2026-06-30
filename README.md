# Bugeisha

**Ultra-light agent-native micro-framework for Cloudflare Workers.**

*Inspired by Parina PHP. Built fresh for the edge.*

[![Deploy to Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/cxto21/bugeisha)

---

## Philosophy

**Extreme minimalism. Explicit routes. No magic. Linear flow.**

Bugeisha takes Parina's core principles — clarity over abstraction, control over convenience — and rebuilds them for Cloudflare Workers with Itty Router.

---

## Architecture in 10 Lines

1. Request enters via Cloudflare Workers fetch handler.
2. Itty Router matches the route.
3. Middleware pipeline runs (`before` hooks).
4. Agent detection identifies AI/bot/human.
5. CORS handles preflight.
6. Rate limiting protects endpoints.
7. Handler executes core logic.
8. Response transforms run (`finally` hooks).
9. JSON serialization for API responses.
10. Edge response in microseconds.

---

## Quick Start

```bash
cd bugeisha
npm install
npm run dev
```

---

## Usage

### Minimal (default router)

```ts
// src/index.ts
export { default } from './router';
```

### Custom router

```ts
import { createBugeisha } from './router';
import { auth } from './middleware';

const router = createBugeisha({
  base: '/api',
  middlewares: [auth],
});

router.get('/protected', ProtectedHandler);
export default { fetch: router.fetch.bind(router) };
```

### With Durable Objects

```ts
// src/index.ts
import { Router } from 'itty-router';

const router = Router();

// Regular routes
router.get('/api/data', handler);

// Durable Object WebSocket
router.get('/ws/agent/:id', (request, env) => {
  const agentId = env.AgentDO.idFromName(request.params.id);
  const stub = env.AgentDO.get(agentId);
  return stub.fetch(request);
});

export default { fetch: router.fetch.bind(router) };
```

---

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Home — JSON for agents, HTML for humans |
| GET | `/health` | Health check |
| GET | `/robots.txt` | Agent-aware robots.txt |
| GET | `/llms.txt` | Service description for LLMs |
| GET | `/sitemap.xml` | Endpoint discovery for agents |
| GET | `/agent/info` | Service capabilities |
| GET | `/agent/tools` | Tool definitions for AI function calling |

---

## Agent-Native Features

- **Agent Detection**: Identifies AI agents, bots, and humans via User-Agent
- **Dual Responses**: JSON for agents, HTML for humans on the same route
- **Tool Definitions**: OpenAI-compatible function calling format at `/agent/tools`
- **Robots.txt**: AI-specific directives for GPTBot, ClaudeBot, Anthropic-AI
- **Agent Discoverability**: robots.txt + llms.txt + sitemap.xml for agent discovery

---

## Durable Objects Integration

Bugeisha supports Cloudflare Durable Objects for stateful agent patterns:

```ts
// wrangler.toml
[durable_objects]
bindings = [
  { name = "AgentDO", class_name = "AgentDO" }
]

[[migrations]]
tag = "v1"
new_sqlite_classes = ["AgentDO"]
```

Key features:
- **Per-agent state**: Each agent gets its own Durable Object instance
- **WebSocket**: Real-time communication via DO WebSocket support
- **Callable methods**: RPC-style method invocation via POST
- **Scheduled tasks**: DO alarms for heartbeats and periodic checks
- **Sub-agents**: Parent/child agent hierarchy

---

## Middleware

| Middleware | Description |
|------------|-------------|
| `detectAgent` | Identifies AI/bot/human from User-Agent |
| `cors` | Handles CORS preflight (OPTIONS) |
| `rateLimit` | In-memory rate limiting (per-isolate) |
| `auth` | Bearer token authentication |

---

## Skills

14 minimal skills in `/skills/` — guides, not code:

| Skill | Description |
|-------|-------------|
| `core` | Router + middleware pipeline |
| `security` | CORS, rate limiting, JWT auth |
| `agent-native` | Agent detection, dual responses, robots.txt, AGENTS.md |
| `storage` | KV + D1 persistence |
| `devex` | Logger, errors, env config |
| `protocols` | MCP + x402 integrations |
| `devops` | Testing + deployment |
| `static-assets` | Serve static files |
| `queues` | Race condition prevention via Cloudflare Queues |
| `agent-discoverability` | robots.txt + llms.txt + sitemap for agent discovery |
| `agents-md` | Create AGENTS.md files for agent instruction |
| `workers-ai` | Integrate Workers AI with agents (inference, streaming, function calling) |
| `multi-model` | Orchestrate multiple AI models (routing, fallbacks, pipelines) |
| `agents-sandbox` | Secure code execution with Cloudflare Sandbox |

---

## Examples

Ready-to-deploy example apps:

| Example | Description | Deploy |
|---------|-------------|--------|
| [Multi-Agent Coordinator](examples/multi-agent-coordinator/) | Coordinate multiple AI agents with Durable Objects, WebSocket, and sub-agents | [![Deploy](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/cxto21/bugeisha/tree/main/examples/multi-agent-coordinator) |

---

## Learn More

- **[Cloudflare Agents SDK](https://developers.cloudflare.com/agents/)** — Full agent framework with state, RPC, scheduling
- **[Durable Objects](https://developers.cloudflare.com/durable-objects/)** — Stateful coordination for Workers
- **[Itty Router](https://itty-router.dev/)** — Lightweight router for Cloudflare Workers

---

## License

MIT
