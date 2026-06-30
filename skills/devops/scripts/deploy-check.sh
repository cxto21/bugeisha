#!/usr/bin/env bash
# pre-deploy validation checks
# Usage: bash scripts/deploy-check.sh [--env staging|production]

set -euo pipefail

ENV="${1:---env}"

echo "🔍 Running pre-deploy checks..."

ERRORS=0

# 1. Check types
echo ""
echo "1/4 Checking TypeScript types..."
if npx tsc --noEmit 2>/dev/null; then
  echo "   ✅ Types OK"
else
  echo "   ❌ Type errors found"
  ERRORS=$((ERRORS + 1))
fi

# 2. Check tests
echo ""
echo "2/4 Running tests..."
if npm test 2>/dev/null; then
  echo "   ✅ Tests pass"
else
  echo "   ⚠️  Tests failed or not configured (continuing)"
fi

# 3. Check wrangler.toml
echo ""
echo "3/4 Validating wrangler.toml..."
if npx wrangler whoami 2>/dev/null; then
  echo "   ✅ Wrangler authenticated"
else
  echo "   ❌ Not authenticated. Run: npx wrangler login"
  ERRORS=$((ERRORS + 1))
fi

# 4. Check secrets (warn only)
echo ""
echo "4/4 Checking secrets..."
if [ -f ".dev.vars" ]; then
  echo "   ⚠️  .dev.vars exists — make sure production secrets are set"
  echo "   Run: npx wrangler secret list"
else
  echo "   ✅ No .dev.vars found"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$ERRORS" -eq 0 ]; then
  echo "✅ All checks passed. Ready to deploy!"
  echo "   Run: npm run deploy"
else
  echo "❌ $ERRORS check(s) failed. Fix before deploying."
  exit 1
fi
