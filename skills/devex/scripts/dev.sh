#!/usr/bin/env bash
# start local dev with type checking and live reload
# Usage: bash scripts/dev.sh [port]

set -euo pipefail

PORT="${1:-8787}"

echo "Starting Nesa dev server..."

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
  echo "Error: wrangler not found. Run 'npm install' first."
  exit 1
fi

# Type check in background
if command -v tsc &> /dev/null; then
  echo "Running type check..."
  npx tsc --noEmit &
  TSC_PID=$!
fi

# Start wrangler dev
echo "Starting wrangler on port $PORT..."
npx wrangler dev --ip 0.0.0.0 --port "$PORT" --live-reload

# Cleanup type check if running
if [ -n "${TSC_PID:-}" ]; then
  kill "$TSC_PID" 2>/dev/null || true
fi
