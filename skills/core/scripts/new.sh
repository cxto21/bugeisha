#!/usr/bin/env bash
# scaffold a new Nesa project
# Usage: bash scripts/new.sh <project-name>

set -euo pipefail

PROJECT_NAME="${1:?Usage: bash scripts/new.sh <project-name>}"

if [ -d "$PROJECT_NAME" ]; then
  echo "Error: Directory '$PROJECT_NAME' already exists"
  exit 1
fi

echo "Scaffolding Nesa project: $PROJECT_NAME"

mkdir -p "$PROJECT_NAME"/src/{handlers,middleware} "$PROJECT_NAME"/public

# package.json
cat > "$PROJECT_NAME/package.json" << 'PKGJSON'
{
  "name": "PROJECT_NAME",
  "version": "0.1.0",
  "description": "Nesa agent-native micro-framework app",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "wrangler dev",
    "deploy": "wrangler deploy",
    "test": "vitest run",
    "test:watch": "vitest"
  },
  "dependencies": {
    "itty-router": "^5.0.0"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.0.0",
    "typescript": "^5.5.0",
    "vitest": "^2.0.0",
    "wrangler": "^3.0.0"
  }
}
PKGJSON

# tsconfig.json
cat > "$PROJECT_NAME/tsconfig.json" << 'TSCONFIG'
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ESNext"],
    "types": ["@cloudflare/workers-types"],
    "strict": true,
    "noEmit": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "isolatedModules": true
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules"]
}
TSCONFIG

# wrangler.toml
cat > "$PROJECT_NAME/wrangler.toml" << 'WRANGLER'
name = "PROJECT_NAME"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[assets]
directory = "public"
binding = "ASSETS"
WRANGLER

# src/types.ts
cat > "$PROJECT_NAME/src/types.ts" << 'TYPES'
import type { IRequest } from 'itty-router';

export interface Env {
  ASSETS: Fetcher;
  CACHE?: KVNamespace;
  DB?: D1Database;
  QUEUE?: Queue;
  API_KEY?: string;
}

export interface NesaRequest extends IRequest {
  isAgent?: boolean;
}
TYPES

# src/middleware/agent-detect.ts
cat > "$PROJECT_NAME/src/middleware/agent-detect.ts" << 'AGENTDETECT'
import type { NesaRequest } from '../types';

export function detectAgent(request: NesaRequest): void {
  const ua = request.headers.get('User-Agent')?.toLowerCase() ?? '';
  request.isAgent = ['openai', 'gpt', 'claude', 'anthropic', 'bot', 'curl']
    .some(p => ua.includes(p));
}
AGENTDETECT

# src/middleware/cors.ts
cat > "$PROJECT_NAME/src/middleware/cors.ts" << 'CORS'
export function cors(request: Request): Response | void {
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });
  }
}
CORS

# src/handlers/home.ts
cat > "$PROJECT_NAME/src/handlers/home.ts" << 'HOME'
import type { NesaRequest, Env } from '../types';

export function home(request: NesaRequest, env: Env): Response | object {
  if (request.isAgent) {
    return {
      service: 'PROJECT_NAME',
      version: '0.1.0',
      endpoints: [
        { path: '/', method: 'GET', description: 'Service overview' },
        { path: '/health', method: 'GET', description: 'Health check' },
      ],
    };
  }

  return new Response('<h1>PROJECT_NAME</h1><p>Agent-native API</p>', {
    headers: { 'Content-Type': 'text/html' },
  });
}
HOME

# src/handlers/health.ts
cat > "$PROJECT_NAME/src/handlers/health.ts" << 'HEALTH'
export function health(): object {
  return { status: 'ok', timestamp: new Date().toISOString() };
}
HEALTH

# src/index.ts
cat > "$PROJECT_NAME/src/index.ts" << 'INDEX'
import { Router, error, json } from 'itty-router';
import type { NesaRequest, Env } from './types';
import { detectAgent } from './middleware/agent-detect';
import { cors } from './middleware/cors';
import { home } from './handlers/home';
import { health } from './handlers/health';

const router = Router({
  before: [detectAgent, cors],
  catch: (err) => error(err),
  finally: [json],
});

router.get('/', home);
router.get('/health', health);
router.all('*', () => error(404, 'Not found'));

export default {
  fetch: router.fetch.bind(router),
};
INDEX

# public/index.html
cat > "$PROJECT_NAME/public/index.html" << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PROJECT_NAME</title>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebAPI",
    "name": "PROJECT_NAME",
    "description": "Agent-native API service",
    "documentation": "/agent/info"
  }
  </script>
</head>
<body>
  <h1>PROJECT_NAME</h1>
  <p>Agent-native API service built with Nesa</p>
  <ul>
    <li><a href="/health">/health</a> — Health check</li>
    <li><a href="/agent/info">/agent/info</a> — Service info</li>
  </ul>
</body>
</html>
HTML

# .gitignore
cat > "$PROJECT_NAME/.gitignore" << 'GITIGNORE'
node_modules/
.wrangler/
.dev.vars
dist/
GITIGNORE

# Replace PROJECT_NAME in all files
find "$PROJECT_NAME" -type f \( -name "*.json" -o -name "*.toml" -o -name "*.ts" -o -name "*.html" \) \
  -exec sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" {} +

echo "✅ Project scaffolded: $PROJECT_NAME"
echo "   cd $PROJECT_NAME && npm install && npm run dev"
