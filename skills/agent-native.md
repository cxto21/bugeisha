---
name: agent-native
description: >
  Optimize a Nesa service for AI agent consumption. Use this when building
  endpoints that serve both humans and AI agents, implementing dual responses
  (JSON for agents, HTML for humans), or adding agent detection headers.
  Covers User-Agent detection, response format negotiation, and agent-specific headers.
---

# Skill: agent-native

Agent detection, dual responses, robots.txt, AGENTS.md — agent optimization.

## Agent detection

```ts
import type { NesaRequest } from './types';

export function detectAgent(request: NesaRequest): void {
  const ua = request.headers.get('User-Agent')?.toLowerCase() ?? '';
  request.isAgent = ['openai', 'gpt', 'claude', 'anthropic', 'bot', 'curl']
    .some(p => ua.includes(p));
}
```

## Dual response pattern

```ts
// Same route, different response format
router.get('/', (request: NesaRequest) => {
  const data = { service: 'my-api', version: '1.0', endpoints: [...] };

  if (request.isAgent) {
    return Response.json(data, {
      headers: { 'X-Agent-Optimized': 'true' },
    });
  }

  return new Response(renderHTML(data), {
    headers: { 'Content-Type': 'text/html' },
  });
});
```

## Agent-specific headers

```ts
// Always include for agent responses
headers: {
  'X-Agent-Optimized': 'true',    // Signals this endpoint is agent-friendly
  'Content-Type': 'application/json',  // Explicit content type
  'X-RateLimit-Limit': '100',     // Let agents know limits
  'X-RateLimit-Remaining': '95',
}
```

## Gotchas

- User-Agent detection is best-effort — agents can spoof it
- Always provide `Accept: application/json` override for explicit JSON requests
- Don't assume all agents are the same — GPTBot, ClaudeBot, Perplexity all behave differently
- `X-Agent-Optimized` is non-standard but useful for agent routing decisions
- HTML responses should still include structured data (JSON-LD) for hybrid consumers
