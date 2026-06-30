// Sitemap.xml — Endpoint discovery for agents and search engines
import type { CoordinatorRequest, Env } from '../types';

export function sitemap(request: CoordinatorRequest, env: Env): Response {
  const url = new URL(request.url);
  const base = `${url.protocol}//${url.host}`;

  const routes = [
    { path: '/', priority: '1.0', changefreq: 'daily' },
    { path: '/status', priority: '0.9', changefreq: 'hourly' },
    { path: '/chat', priority: '0.8', changefreq: 'daily' },
    { path: '/agents', priority: '0.8', changefreq: 'hourly' },
    { path: '/tasks', priority: '0.8', changefreq: 'hourly' },
    { path: '/dashboard', priority: '0.7', changefreq: 'daily' },
    { path: '/logs', priority: '0.5', changefreq: 'hourly' },
    { path: '/robots.txt', priority: '0.3', changefreq: 'monthly' },
    { path: '/llms.txt', priority: '0.3', changefreq: 'monthly' },
  ];

  const urls = routes.map(r => `  <url>
    <loc>${base}${r.path}</loc>
    <changefreq>${r.changefreq}</changefreq>
    <priority>${r.priority}</priority>
  </url>`).join('\n');

  const body = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>`;

  return new Response(body, {
    headers: { 'Content-Type': 'application/xml;charset=UTF-8' },
  });
}
