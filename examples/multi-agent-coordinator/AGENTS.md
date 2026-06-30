# AGENTS.md — Multi-Agent Coordinator

Nesa example: coordinate multiple AI agents to complete complex tasks.

## Project Overview

A task coordination service where AI agents register with roles, pick tasks, execute work, and submit results. The coordinator decomposes complex tasks into subtasks and assigns them to specialized agents.

**Stack**: TypeScript, Itty Router v5, Cloudflare Workers, KV for state
**State**: KV (local simulation via Miniflare)

## Setup Commands

```bash
npm install          # Install dependencies
npm run dev          # Start local dev server (http://localhost:8787)
npm run deploy       # Deploy to Cloudflare Workers
```

## Code Style

- TypeScript strict mode
- Async handlers for KV operations
- Explicit route registration (no decorators, no magic)
- Dual responses: JSON for agents, HTML for humans
- Types in `src/types.ts`, coordinator logic in `src/coordinator.ts`

## Testing the API

### Register an agent
```bash
curl -X POST http://localhost:8787/agents/register \
  -H "Content-Type: application/json" \
  -d '{"name": "researcher-1", "role": "researcher", "capabilities": ["search"]}'
```

### Create a task
```bash
curl -X POST http://localhost:8787/tasks/create \
  -H "Content-Type: application/json" \
  -d '{"title": "Blog post", "description": "Write about edge computing", "subtasks": [{"role": "researcher", "description": "Research trends"}, {"role": "writer", "description": "Write draft"}]}'
```

### Pick a task (as agent)
```bash
curl "http://localhost:8787/tasks/pick?role=researcher&agentId=YOUR_AGENT_ID"
```

### Submit result
```bash
curl -X POST http://localhost:8787/tasks/result \
  -H "Content-Type: application/json" \
  -d '{"subtaskId": "YOUR_SUBTASK_ID", "result": "Research findings..."}'
```

### Check status
```bash
curl -H "User-Agent: OpenAI-GPT" http://localhost:8787/status
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Home — JSON for agents, HTML for humans |
| GET | `/dashboard` | Human dashboard with stats |
| GET | `/status` | JSON status for agents |
| POST | `/agents/register` | Register a new agent |
| GET | `/agents` | List all agents |
| POST | `/agents/:id/heartbeat` | Agent heartbeat |
| POST | `/tasks/create` | Create a task with subtasks |
| GET | `/tasks/pick?role=<role>` | Pick a task for your role |
| POST | `/tasks/result` | Submit subtask result |
| GET | `/tasks` | List all tasks |
| GET | `/tasks/:id` | Task detail with subtasks |

## Project Structure

```
src/
├── index.ts              # Entry point + router
├── types.ts              # TypeScript types (Agent, Task, Subtask, Env)
├── coordinator.ts        # Core: agent registry + task engine (KV-backed)
└── handlers/
    ├── home.ts           # Home (JSON/HTML dual response)
    ├── agents.ts         # Agent registration, listing, heartbeat
    ├── tasks.ts          # Task create, pick, result, list, detail
    ├── dashboard.ts      # Human-facing dashboard
    └── status.ts         # JSON status endpoint for agents
```

## Architecture

```
Agent A (researcher)  ─┐
Agent B (writer)      ─┼──> Coordinator ──> Assembled Result
Agent C (reviewer)    ─┘
```

## State Management

Uses Cloudflare KV for persistent state (survives cold starts):
- `agents` key: Map of registered agents
- `tasks` key: Map of tasks with subtasks

Local simulation via Miniflare (no cloud connection needed).

## Gotchas

- KV state resets if you change wrangler.toml bindings
- Agent IDs are UUIDs — store them after registration
- Subtask IDs follow pattern: `{taskId}-st-{index}`
- Heartbeat updates `lastSeen` timestamp — call periodically to stay alive
- All subtasks must complete for task status to become `completed`
