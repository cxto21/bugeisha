// Consumer Worker template for Cloudflare Queues
// Copy this to a separate Worker project for queue processing
// Docs: https://developers.cloudflare.com/queues/configuration/configure-queues/

import type { Env } from '../types';

export interface QueueMessage {
  action: 'create' | 'update' | 'delete';
  data: Record<string, unknown>;
  timestamp: number;
}

export default {
  async queue(batch: MessageBatch<QueueMessage>, env: Env): Promise<void> {
    console.log(`Processing ${batch.messages.length} messages`);

    for (const msg of batch.messages) {
      const { action, data, timestamp } = msg.body;

      try {
        switch (action) {
          case 'create':
            await handleCreate(env, data);
            break;
          case 'update':
            await handleUpdate(env, data);
            break;
          case 'delete':
            await handleDelete(env, data);
            break;
        }

        // Message acked automatically on successful return
        console.log(`✅ Processed ${action} for ${data.id || 'unknown'} (${Date.now() - timestamp}ms)`);
      } catch (err) {
        // Throwing retries the message (up to max_retries)
        console.error(`❌ Failed ${action}:`, err);
        throw err;
      }
    }
  },
};

async function handleCreate(env: Env, data: Record<string, unknown>): Promise<void> {
  // Example: Insert into D1
  if (env.DB) {
    await env.DB.prepare('INSERT INTO items (id, name, created_at) VALUES (?, ?, ?)')
      .bind(data.id, data.name, new Date().toISOString())
      .run();
  }
}

async function handleUpdate(env: Env, data: Record<string, unknown>): Promise<void> {
  if (env.DB) {
    await env.DB.prepare('UPDATE items SET name = ?, updated_at = ? WHERE id = ?')
      .bind(data.name, new Date().toISOString(), data.id)
      .run();
  }
}

async function handleDelete(env: Env, data: Record<string, unknown>): Promise<void> {
  if (env.DB) {
    await env.DB.prepare('DELETE FROM items WHERE id = ?')
      .bind(data.id)
      .run();
  }
}
