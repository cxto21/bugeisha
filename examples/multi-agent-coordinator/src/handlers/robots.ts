// Robots.txt — Agent-aware crawl directives
import type { CoordinatorRequest, Env } from '../types';

export function robots(request: CoordinatorRequest, env: Env): Response {
  const body = `# Multi-Agent Coordinator — Agent-Native Robots.txt
# AI agents: crawl freely, respect rate limits

User-agent: *
Allow: /
Disallow: /chat/send

# AI-specific directives
User-agent: GPTBot
Allow: /
Allow: /chat
Allow: /tasks/*
Allow: /agents/*
Crawl-delay: 1

User-agent: ChatGPT-User
Allow: /
Crawl-delay: 1

User-agent: ClaudeBot
Allow: /
Allow: /chat
Allow: /tasks/*
Allow: /agents/*
Crawl-delay: 1

User-agent: Anthropic-AI
Allow: /
Crawl-delay: 1

User-agent: PerplexityBot
Allow: /
Crawl-delay: 1

User-agent: CCBot
Disallow: /chat/send
Disallow: /tasks/create
Disallow: /agents/register

User-agent: Google-Extended
Allow: /

# Agent discovery
# This service coordinates multiple AI agents for complex tasks.
# Visit /llms.txt for a full description.
# Visit /sitemap.xml for all endpoints.

Sitemap: /sitemap.xml
`;

  return new Response(body, {
    headers: { 'Content-Type': 'text/plain;charset=UTF-8' },
  });
}
