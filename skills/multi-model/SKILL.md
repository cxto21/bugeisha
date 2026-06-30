---
name: multi-model
description: >
  Orchestrate multiple AI models in a single Bugeisha workflow.
  Use this when building multi-model pipelines, routing tasks to
  specialized models, or combining different AI capabilities.
  Covers model routing, fallback chains, and result assembly.
---

# Skill: multi-model

Multiple models, one coordinator. Route by capability, not by hype.

## Pattern: Model registry

```ts
// models.ts — Define which model does what
export const MODEL_REGISTRY = {
  analyst: {
    model: '@cf/meta/llama-3.1-70b-instruct',
    maxTokens: 4096,
    useCase: 'deep analysis, reasoning',
  },
  writer: {
    model: '@cf/meta/llama-3.1-8b-instruct',
    maxTokens: 2048,
    useCase: 'creative writing, drafts',
  },
  summarizer: {
    model: '@cf/google/gemma-2b-it',
    maxTokens: 512,
    useCase: 'quick summaries, extraction',
  },
  translator: {
    model: '@cf/meta/llama-3.1-8b-instruct',
    maxTokens: 1024,
    useCase: 'language translation',
  },
};
```

## Pattern: Role-based routing

```ts
// In coordinator — route subtask to model by role
export async function executeWithModel(role: string, prompt: string, env: Env) {
  const config = MODEL_REGISTRY[role];
  if (!config) throw new Error(`Unknown role: ${role}`);

  const result = await env.AI.run(config.model, {
    messages: [{ role: 'user', content: prompt }],
    max_tokens: config.maxTokens,
  });

  return result.response;
}

// Usage in task handler
const research = await executeWithModel('analyst', 'Analyze trends', env);
const draft = await executeWithModel('writer', `Write about: ${research}`, env);
const summary = await executeWithModel('summarizer', `Summarize: ${draft}`, env);
```

## Pattern: Pipeline with different models

```ts
// Multi-model pipeline: cheap → expensive → cheap
export async function smartPipeline(prompt: string, env: Env) {
  // Step 1: Quick classification (cheap model)
  const classification = await env.AI.run('@cf/google/gemma-2b-it', {
    messages: [{
      role: 'system',
      content: 'Classify this request as: simple, complex, or creative. Reply with one word.',
    }, { role: 'user', content: prompt }],
  });

  const type = classification.response.trim().toLowerCase();

  // Step 2: Route to appropriate model
  const modelMap = {
    simple: '@cf/google/gemma-2b-it',
    complex: '@cf/meta/llama-3.1-70b-instruct',
    creative: '@cf/meta/llama-3.1-8b-instruct',
  };

  const result = await env.AI.run(modelMap[type], {
    messages: [{ role: 'user', content: prompt }],
  });

  return result.response;
}
```

## Pattern: Fallback chain

```ts
// Try primary, fall back to alternatives
export async function withFallback(prompt: string, env: Env) {
  const models = [
    '@cf/meta/llama-3.1-70b-instruct',  // Primary: best quality
    '@cf/meta/llama-3.1-8b-instruct',   // Fallback: faster
    '@cf/google/gemma-2b-it',            // Last resort: cheapest
  ];

  for (const model of models) {
    try {
      const result = await env.AI.run(model, {
        messages: [{ role: 'user', content: prompt }],
      });
      return { result: result.response, model };
    } catch (e) {
      console.warn(`Model ${model} failed, trying next...`);
    }
  }

  throw new Error('All models failed');
}
```

## Pattern: Parallel multi-model

```ts
// Run multiple models simultaneously
export async function parallelAnalysis(prompt: string, env: Env) {
  const [technical, creative, concise] = await Promise.all([
    env.AI.run('@cf/meta/llama-3.1-70b-instruct', {
      messages: [{ role: 'user', content: `Technical analysis: ${prompt}` }],
    }),
    env.AI.run('@cf/meta/llama-3.1-8b-instruct', {
      messages: [{ role: 'user', content: `Creative interpretation: ${prompt}` }],
    }),
    env.AI.run('@cf/google/gemma-2b-it', {
      messages: [{ role: 'user', content: `One paragraph summary: ${prompt}` }],
    }),
  ]);

  return {
    technical: technical.response,
    creative: creative.response,
    concise: concise.response,
  };
}
```

## Integration with coordinator

```ts
// Register agents with model capabilities
await register({ name: 'deep-analyst', role: 'analyst', capabilities: ['llama-70b'] });
await register({ name: 'fast-writer', role: 'writer', capabilities: ['llama-8b'] });
await register({ name: 'quick-summary', role: 'summarizer', capabilities: ['gemma-2b'] });

// Task execution uses model registry
createTask({
  title: 'Research and write',
  subtasks: [
    { role: 'analyst', description: 'Deep analysis of topic' },
    { role: 'writer', description: 'Write article from analysis' },
    { role: 'summarizer', description: 'Create executive summary' },
  ],
});
```

## Gotchas

- Larger models are slower and more expensive — use them only when needed
- Streaming works with all models but chunk size varies
- Function calling only with Llama 3.1+ models
- Model availability may change — always handle errors
- Token limits differ per model — check before sending long prompts
- Rate limits are per-account — parallel calls count against limit
