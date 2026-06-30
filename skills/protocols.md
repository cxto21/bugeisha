---
name: protocols
description: >
  Integrate external protocols (MCP, x402) into a Nesa service. Use this when
  adding Model Context Protocol for tool discovery, implementing payment-gated
  endpoints with x402, or connecting to external agent networks. These are
  heavy integrations — add only when specifically needed.
---

# Skill: protocols

MCP + x402 — external protocol integrations for agent-native services.

## MCP (Model Context Protocol)

```ts
// Requires @cloudflare/agents-sdk — NOT bundled with Nesa
// Use for: tool discovery, function calling, agent-to-agent communication

import { McpAgent } from 'agents/mcp';

class MyMCP extends McpAgent {
  server = new McpServer({ name: 'my-service', version: '1.0' });

  setup() {
    this.server.tool('get_user', { id: z.string() }, async ({ id }) => {
      const user = await this.env.DB.prepare('SELECT * FROM users WHERE id = ?')
        .bind(id).first();
      return { content: [{ type: 'text', text: JSON.stringify(user) }] };
    });
  }
}

// Mount on route
router.all('/mcp/*', (request) => MyMCP.serve('/mcp').fetch(request));
```

## x402 (Payment-gated endpoints)

```ts
// Requires x402 npm package — NOT bundled with Nesa
// Use for: paid APIs, micro-payments, usage-based billing

import { verifyPayment } from 'x402/facilitator';

router.get('/premium-data', async (request) => {
  const payment = await verifyPayment(request, {
    amount: '0.01',
    currency: 'USDC',
  });

  if (!payment.verified) {
    return new Response('Payment required', {
      status: 402,
      headers: { 'X-Payment-Required': '0.01 USDC' },
    });
  }

  return { data: 'premium content' };
});
```

## Gotchas

- Both MCP and x402 require their own SDK — Nesa stays minimal by design
- MCP via `@cloudflare/agents-sdk` — heavy dependency, add only when needed
- x402 requires blockchain settlement — not instant like regular auth
- For simple tool definitions, use `/agent/tools` endpoint instead of full MCP
- For simple paid APIs, use JWT + custom logic instead of x402 unless you need micropayments
