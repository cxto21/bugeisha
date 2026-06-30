# Multi-Agent Coordinator

A Bugeisha example: coordinate multiple AI agents to complete complex tasks.

[![Deploy to Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/cxto21/bugeisha/tree/main/examples/multi-agent-coordinator)

## What It Does

1. **Agents register** with roles (researcher, writer, reviewer, etc.)
2. **User submits a task** broken into subtasks
3. **Coordinator assigns** subtasks to agents by role
4. **Agents pick up work**, execute, and submit results
5. **Coordinator assembles** the final result

### Cloudflare Agents SDK Concepts

This example integrates key concepts from the Cloudflare Agents SDK:

| Concept | Implementation | Benefit |
|---------|----------------|---------|
| **Durable Objects** | Each agent has its own DO instance | Persistent state per agent, survives cold starts |
| **WebSocket** | `/ws/agent/:id` endpoint | Real-time updates (replaces polling) |
| **State Broadcasting** | `this.broadcast()` in DO | Notify all connected clients on state changes |
| **Scheduled Tasks** | DO alarms (every 30s) | Automatic heartbeat, agent liveness detection |
| **Sub-Agents** | Parent/child agent hierarchy | Parallel task execution, hierarchical coordination |

## Quick Start

```bash
cd bugeisha/examples/multi-agent-coordinator
npm install
npm run dev
```

Visit `http://localhost:8787/dashboard` for the human dashboard.

## Agent Protocol

### 1. Register

```bash
curl -X POST http://localhost:8787/agents/register \
  -H "Content-Type: application/json" \
  -d '{"name": "researcher-1", "role": "researcher", "capabilities": ["search", "summarize"]}'
```

Response:
```json
{
  "message": "Agent registered",
  "agent": {
    "id": "researcher-1",
    "name": "researcher-1",
    "role": "researcher",
    "capabilities": ["search", "summarize"],
    "status": "idle"
  },
  "instructions": {
    "pickTask": "GET /tasks/pick?role=researcher",
    "submitResult": "POST /tasks/result",
    "heartbeat": "POST /agents/researcher-1/heartbeat"
  }
}
```

### 2. Create a Task

```bash
curl -X POST http://localhost:8787/tasks/create \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Write article about AI trends",
    "description": "Research and write a comprehensive article",
    "subtasks": [
      { "role": "researcher", "description": "Research latest AI trends 2026" },
      { "role": "writer", "description": "Write the article based on research" },
      { "role": "reviewer", "description": "Review and provide feedback" }
    ]
  }'
```

### 3. Pick a Task (as agent)

```bash
curl "http://localhost:8787/tasks/pick?role=researcher&agentId=researcher-1"
```

### 4. Submit Result

```bash
curl -X POST http://localhost:8787/tasks/result \
  -H "Content-Type: application/json" \
  -d '{"subtaskId": "abc-123-st-0", "result": "Research findings: AI agents are..."}'
```

### 5. Check Status

```bash
curl http://localhost:8787/status
```

## WebSocket (Real-time Updates)

Connect to an agent's WebSocket for real-time state updates:

```javascript
const ws = new WebSocket('ws://localhost:8787/ws/agent/researcher-1');

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log(message.type, message.data);
  // Types: state-update, task-assigned, task-completed, heartbeat, sub-agent-spawned
};

// Send heartbeat
ws.send(JSON.stringify({ type: 'heartbeat' }));

// Update state
ws.send(JSON.stringify({ type: 'update-state', data: { status: 'working' } }));
```

## Sub-Agents

Spawn child agents for parallel execution:

```bash
# Spawn a sub-agent
curl -X POST http://localhost:8787/agents/researcher-1/spawn \
  -H "Content-Type: application/json" \
  -d '{"name": "researcher-1a", "role": "researcher", "capabilities": ["search"]}'

# List sub-agents
curl http://localhost:8787/agents/researcher-1/subagents
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Home — JSON for agents, HTML for humans |
| GET | `/dashboard` | Human dashboard with stats |
| GET | `/status` | JSON status for agents |
| GET | `/logs` | Interaction logs (JSON/HTML) |
| POST | `/agents/register` | Register a new agent |
| GET | `/agents` | List all agents |
| POST | `/agents/:id/heartbeat` | Agent heartbeat |
| GET | `/ws/agent/:id` | WebSocket — real-time agent updates |
| POST | `/agents/:id/call` | Call method on agent DO |
| POST | `/agents/:id/spawn` | Spawn a sub-agent |
| GET | `/agents/:id/subagents` | List sub-agents |
| POST | `/tasks/create` | Create a task with subtasks |
| GET | `/tasks/pick?role=<role>` | Pick a task for your role |
| POST | `/tasks/result` | Submit subtask result |
| GET | `/tasks` | List all tasks |
| GET | `/tasks/:id` | Task detail with subtasks |
| GET | `/chat` | Chat UI with @mentions |
| GET | `/chat/messages` | Chat messages (JSON) |
| POST | `/chat/send` | Send chat message |

## Architecture

```
                    ┌─────────────────────┐
                    │    Coordinator      │
                    │   (itty-router)     │
                    └──────────┬──────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
   ┌────▼────┐           ┌────▼────┐           ┌────▼────┐
   │ AgentDO │           │ AgentDO │           │ AgentDO │
   │ (SQLite)│           │ (SQLite)│           │ (SQLite)│
   │   WebSocket ──►     │         │     ◄── WebSocket │
   └─────────┘           └─────────┘           └─────────┘
        │                      │                      │
        └──────────────────────┼──────────────────────┘
                               │
                         ┌─────▼─────┐
                         │  KV Tasks │
                         │ (shared)  │
                         └───────────┘
```

## State Management

| Storage | What | Why |
|---------|------|-----|
| **Durable Objects** | Agent state (per-instance) | Persistent, WebSocket, scheduled tasks |
| **KV** | Tasks (shared) | Readable by all agents, simple key-value |
| **KV** | Agent index | Lists all agent names for enumeration |
| **KV** | Chat messages | Recent message history |
| **KV** | Logs | Interaction audit trail |

## Use Cases

| Case | Why it works |
|------|--------------|
| **Content pipeline** | Research → Write → Review → Publish |
| **Code review** | Linter → Security → Performance → Approval |
| **Data processing** | Extract → Transform → Validate → Load |
| **Multi-model AI** | Different models for different tasks |
| **Customer support** | Classifier → Specialist → Escalation |

## Files

```
src/
├── index.ts              # Entry point + router
├── types.ts              # TypeScript types (DO, WebSocket, SubAgent)
├── agent-do.ts           # Durable Object: state + WebSocket + callable methods
├── coordinator.ts        # Core: registry + task engine (DO + KV)
└── handlers/
    ├── home.ts           # Home (JSON/HTML)
    ├── agents.ts         # Agent registration
    ├── tasks.ts          # Task management
    ├── dashboard.ts      # Human dashboard
    ├── status.ts         # JSON status
    ├── logs.ts           # Interaction logs
    ├── chat.ts           # Chat with @mentions
    ├── ws.ts             # WebSocket + DO callable
    ├── subagents.ts      # Sub-agent spawn/list
    ├── robots.txt.ts     # Agent crawl directives
    ├── llms.ts           # Service description
    └── sitemap.ts        # Endpoint discovery
```

## Testing

```bash
npm test             # Run all 30 tests
npm run test:watch   # Watch mode
```

Tests mock both KV and Durable Object namespaces for local testing.
