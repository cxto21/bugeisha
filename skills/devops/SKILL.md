---
name: devops
description: >
  Test and deploy a Nesa service to Cloudflare Workers. Use this when setting
  up Vitest for handler testing, running `wrangler deploy`, managing secrets,
  configuring environments (staging/production), or debugging with live logs.
---

# Skill: devops

Testing + deployment — quality and shipping workflows.

## Testing with Vitest

```ts
import { describe, it, expect } from 'vitest';
import worker from '../src/index';

describe('Nesa worker', () => {
  it('GET /health returns 200', async () => {
    const res = await worker.fetch(new Request('http://localhost/health'));
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body.status).toBe('ok');
  });

  it('GET /unknown returns 404', async () => {
    const res = await worker.fetch(new Request('http://localhost/unknown'));
    expect(res.status).toBe(404);
  });
});
```

## Deploy workflow

```bash
# Pre-deploy checklist
wrangler types                    # Generate types
wrangler dev                      # Local testing
wrangler deploy                   # Push to edge

# Secrets
wrangler secret put API_KEY       # Add secret
wrangler secret list              # List secrets

# Environments
wrangler deploy --env staging     # Deploy to staging
wrangler deploy --env production  # Deploy to production

# Monitoring
wrangler tail                     # Live logs
wrangler rollback                 # Rollback last deploy
```

## Pre-deploy check

```bash
bash scripts/deploy-check.sh
```

Verifies types, tests, wrangler auth, and secrets before deploying.

## Gotchas

- Test handlers as pure functions — mock `env` and `ctx`
- `wrangler deploy` uploads to all environments by default — use `--env` to target
- Secrets are per-environment — `staging` and `production` have separate secrets
- `wrangler tail` shows real-time logs from the deployed worker
- Rollback reverts to previous version, not a specific commit
