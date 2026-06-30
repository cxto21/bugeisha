---
name: queues
description: >
  Add background job processing to a Bugeisha service using Cloudflare Queues.
  Use this when handling concurrent writes to D1/KV, implementing batch processing,
  offloading heavy work from request handlers, or building ordered processing
  pipelines. Covers queue producers, consumers, and retry configuration.
---

# Skill: queues

Race condition prevention via Cloudflare Queues. Offload writes, process sequentially.

## Setup

```toml
# wrangler.toml
[[queues]]
binding = "QUEUE"
queue = "bugeisha-queue"
max_retries = 3
```

## Producer (in handler)

```ts
router.post('/tasks', async (request, env) => {
  const task = await request.json();

  // Offload to queue — returns immediately
  await env.QUEUE.send({
    action: 'create',
    data: task,
    timestamp: Date.now(),
  });

  return { status: 'queued', message: 'Task accepted for processing' };
});
```

## Consumer (separate Worker)

```ts
export default {
  async queue(batch: MessageBatch, env: Env) {
    for (const msg of batch.messages) {
      const { action, data } = msg.body;

      switch (action) {
        case 'create':
          await env.DB.prepare('INSERT INTO tasks (...) VALUES (...)')
            .bind(...).run();
          break;
        case 'update':
          await env.DB.prepare('UPDATE tasks SET ... WHERE id = ?')
            .bind(...).run();
          break;
      }

      // Acknowledge success (automatic on return)
      // Throw to retry (up to max_retries)
    }
  },
};
```

## When to use queues

| Use case | Why queues |
|----------|------------|
| Concurrent writes to D1/KV | Prevent race conditions |
| Batch processing | Don't block request handler |
| Rate-limited API calls | Respect external API limits |
| Ordered operations | Sequential processing guarantee |

## Consumer template

See `scripts/consumer-example.ts` for a complete consumer Worker template with CRUD handlers, error handling, and retry logic. Copy it to a separate Worker project.

## Gotchas

- Queue consumer runs in a **separate Worker** — no shared state with request handler
- Max message size: 128 KB — use R2 for larger payloads
- Retries are automatic — throw to retry, return to ack
- `batch.messages` can contain up to 100 messages per batch
- Queue latency: ~1-5 seconds typical, not instant
