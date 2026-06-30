---
name: agents-sandbox
description: >
  Use Cloudflare Sandbox for secure code execution in Bugeisha agents.
  Use this when agents need to run untrusted code, execute LLM-generated
  scripts, or provide isolated environments per agent. Covers setup,
  file operations, command execution, and cost considerations.
---

# Skill: agents-sandbox

Sandbox for agents. Isolated code execution, per-agent containers.

## Setup

```toml
# wrangler.toml
[[containers]]
class_name = "Sandbox"
image = "./Dockerfile"
instance_type = "lite"
max_instances = 1

[[migrations]]
tag = "v2"
new_sqlite_classes = ["Sandbox"]
```

```ts
// index.ts — Required export
export { Sandbox } from '@cloudflare/sandbox';
```

```ts
// types.ts
export interface Env {
  Sandbox: any;  // Sandbox namespace
}
```

## Basic usage in agent

```ts
import { getSandbox } from '@cloudflare/sandbox';

// Get sandbox for this agent (same ID = same container)
const sandbox = getSandbox(env.Sandbox, agentId);

// Execute command
const result = await sandbox.exec('python --version');
console.log(result.stdout);  // "Python 3.11.x"

// Write file
await sandbox.writeFile('/workspace/script.py', `
import pandas as pd
data = pd.read_csv('/workspace/data.csv')
print(data.describe())
`);

// Run the script
const output = await sandbox.exec('python /workspace/script.py');
```

## Code interpreter (for LLM-generated code)

```ts
// Create context for stateful execution
const ctx = await sandbox.createCodeContext({ language: 'python' });

// Execute code blocks — state persists
await sandbox.runCode('import pandas as pd', { context: ctx });
await sandbox.runCode('data = [1, 2, 3, 4, 5]', { context: ctx });
const result = await sandbox.runCode('sum(data)', { context: ctx });

// result.results[0].text = "15"
```

## File operations

```ts
// Create project structure
await sandbox.mkdir('/workspace/src', { recursive: true });
await sandbox.writeFile('/workspace/src/main.py', code);
await sandbox.writeFile('/workspace/requirements.txt', 'pandas\nrequests');

// Read files
const file = await sandbox.readFile('/workspace/src/main.py');
const files = await sandbox.listFiles('/workspace');
```

## Agent with sandbox execution

```ts
// Register sandbox-enabled agent
await register({
  name: 'code-executor',
  role: 'executor',
  capabilities: ['python', 'javascript', 'shell'],
});

// Execute task in sandbox
export async function executeInSandbox(subtaskId: string, env: Env) {
  const subtask = await getSubtask(subtaskId);
  const sandbox = getSandbox(env.Sandbox, subtaskId);

  // Write code from task description
  await sandbox.writeFile('/workspace/execute.py', subtask.code);

  // Run with timeout
  const result = await sandbox.exec('python /workspace/execute.py', {
    timeout: 30000,  // 30 seconds
  });

  await submitResult(subtaskId, result.stdout || result.stderr);
}
```

## Expose services (preview URLs)

```ts
// Start a web server in sandbox
await sandbox.exec('python -m http.server 8080');

// Expose to the world
const { url } = await sandbox.exposePort(8080);
// url: "https://sandbox-abc.yourdomain.com"
```

## Custom Dockerfile

```dockerfile
FROM docker.io/cloudflare/sandbox:0.7.0

# Python packages
RUN pip install pandas requests beautifulsoup4

# Node packages
RUN npm install -g typescript vite

# System packages
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

EXPOSE 8080
```

## Cleanup

```ts
// Destroy sandbox when done (frees resources)
await sandbox.destroy();

// Or let it sleep (auto-sleeps after 10min inactivity)
```

## Cost awareness

| Instance | vCPU | Memory | Cost/hour |
|----------|------|--------|-----------|
| `lite` | 1/16 | 256 MiB | ~$0.01 |
| `basic` | 1/4 | 1 GiB | ~$0.04 |
| `standard-1` | 1/2 | 4 GiB | ~$0.15 |

**Tip**: Use `lite` for most agent tasks. Only upgrade when you need more resources.

## Gotchas

- Same `sandboxId` = same container (state persists)
- Containers sleep after 10min inactivity (configurable)
- Docker required for local development
- Cold start ~2-5 seconds
- Each sandbox is a Durable Object — billing applies
- `export { Sandbox }` is REQUIRED in entry point
- Don't hardcode sandbox IDs for multi-user — use agent ID
