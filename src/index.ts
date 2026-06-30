// Bugeisha — Ultra-light agent-native micro-framework for Cloudflare Workers
//
// Philosophy: Extreme minimalism. Explicit routes. No magic. Linear flow.
//
// Usage:
//   import bugeisha from './router';
//   export default bugeisha;
//
// Or customize:
//   import { createBugeisha } from './router';
//   const router = createBugeisha({ base: '/api', middlewares: [...] });
//   export default router;

export { router as default, createBugeisha } from './router';
export type { Env, BugeishaRequest, BugeishaHandler, BugeishaMiddleware } from './types';
export { detectAgent, cors, auth, rateLimit } from './middleware';
