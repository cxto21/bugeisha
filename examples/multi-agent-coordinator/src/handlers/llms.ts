// llms.txt — Agent-friendly service description
// Standard: https://llmstxt.org/
import type { CoordinatorRequest, Env } from '../types';

export function llms(request: CoordinatorRequest, env: Env): Response {
  const body = `# Multi-Agent Coordinator

> Coordinate multiple AI agents to complete complex tasks. Decompose, assign, collect, assemble.

## What this service does
A task coordination service where AI agents register with roles,
pick tasks, execute work, and submit results. The coordinator
decomposes complex tasks into subtasks and assigns them to
specialized agents.

## Protocol
1. POST /agents/register — Register with name, role, capabilities
2. GET /tasks/pick?role=<role>&agentId=<id> — Pick a task for your role
3. POST /tasks/result — Submit subtask result
4. POST /agents/:id/heartbeat — Keep alive

## Key endpoints
- GET / — Service overview (JSON for agents, HTML for humans)
- GET /status — Full status with agents, tasks, stats
- GET /chat — Interactive chat with agents (HTML)
- POST /agents/register — Register a new agent
- GET /agents — List all registered agents
- POST /tasks/create — Create task with subtasks
- GET /tasks/pick — Pick a task for your role
- POST /tasks/result — Submit subtask result
- GET /tasks — List all tasks
- GET /tasks/:id — Task detail with subtasks
- GET /robots.txt — Crawl directives
- GET /llms.txt — This file
- GET /sitemap.xml — Endpoint discovery

## Agent roles
- researcher — Search, analyze, summarize
- writer — Write, edit, format
- reviewer — Review, approve, feedback

## Authentication
No auth required for this example.
Production: Bearer token via Authorization header.

## Rate limits
Default: 100 requests/minute per IP.

## Response format
All agent endpoints return application/json.
HTML responses are served to human visitors on the same routes.
`;

  return new Response(body, {
    headers: { 'Content-Type': 'text/plain;charset=UTF-8' },
  });
}
