---
name: workers-ai
description: >
  Integrate Cloudflare Workers AI with Bugeisha agents.
  Use this when adding AI inference to agent handlers, building
  AI-powered task execution, or connecting LLMs to your agent workflows.
  Covers model selection, streaming, function calling, and cost optimization.
---

# Skill: workers-ai

Workers AI in Bugeisha agents. Add inference to handlers, not magic.

## Setup

```toml
# wrangler.toml
[ai]
binding = "AI"
```

```ts
// types.ts
export interface Env {
  AI: Ai;  // Cloudflare Workers AI binding
}
```

## Basic inference in handler

```ts
// handlers/analyze.ts
export async function analyze(request: BugeishaRequest, env: Env) {
  const body = await request.json();
  const result = await env.AI.run('@cf/meta/llama-3.1-8b-instruct', {
    messages: [{ role: 'user', content: body.prompt }],
  });

  return Response.json({ result: result.response });
}
```

## Agent with AI capabilities

```ts
// Register an AI-powered agent
await register({
  name: 'ai-writer',
  role: 'writer',
  capabilities: ['generate', 'summarize', 'translate'],
});

// In task handler — use AI for the actual work
export async function executeSubtask(subtaskId: string, env: Env) {
  const subtask = await getSubtask(subtaskId);

  const result = await env.AI.run('@cf/meta/llama-3.1-8b-instruct', {
    messages: [
      { role: 'system', content: `You are a ${subtask.role}. Complete: ${subtask.description}` },
      { role: 'user', content: subtask.context ?? 'Execute this task.' },
    ],
  });

  await submitResult(subtaskId, result.response);
}
```

## Streaming for long tasks

```ts
// Stream response to client
const stream = await env.AI.run('@cf/meta/llama-3.1-8b-instruct', {
  messages: [{ role: 'user', content: prompt }],
  stream: true,
});

return new Response(stream, {
  headers: { 'Content-Type': 'text/event-stream' },
});
```

## Function calling (tool use)

```ts
const result = await env.AI.run('@cf/meta/llama-3.1-8b-instruct', {
  messages: [{ role: 'user', content: 'Research edge computing trends' }],
  tools: [
    {
      type: 'function',
      function: {
        name: 'search_web',
        description: 'Search the web for information',
        parameters: {
          type: 'object',
          properties: {
            query: { type: 'string', description: 'Search query' },
          },
          required: ['query'],
        },
      },
    },
  ],
});

// result.tool_calls contains the function calls
```

## Available models

| Model | Use case | Speed |
|-------|----------|-------|
| `@cf/meta/llama-3.1-8b-instruct` | General chat, reasoning | Fast |
| `@cf/meta/llama-3.1-70b-instruct` | Complex tasks, analysis | Medium |
| `@cf/mistral/mistral-7b-instruct` | Fast inference | Fast |
| `@cf/google/gemma-2b-it` | Lightweight tasks | Very fast |
| `@cf/openai/whisper` | Speech-to-text | Medium |

## Cost optimization

```ts
// Use smallest model for simple tasks
const simpleTask = await env.AI.run('@cf/google/gemma-2b-it', {
  messages: [{ role: 'user', content: 'Summarize in 3 words' }],
});

// Use larger model only for complex tasks
const complexTask = await env.AI.run('@cf/meta/llama-3.1-70b-instruct', {
  messages: [{ role: 'user', content: 'Analyze this codebase architecture' }],
});
```

## Gotchas

- AI binding is global — no cold start penalty
- Streaming requires `stream: true` in options
- Function calling only works with models that support it (Llama 3.1+)
- Token limits vary by model — check docs
- Rate limits apply per-account, not per-worker
- Always handle AI errors gracefully — models can timeout
