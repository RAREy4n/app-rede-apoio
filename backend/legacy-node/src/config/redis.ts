import Redis from 'ioredis';

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

export const redis = new Redis(redisUrl, {
  maxRetriesPerRequest: 3,
  retryStrategy(times) {
    const delay = Math.min(times * 200, 3000);
    return delay;
  },
  lazyConnect: true,
});

redis.on('error', (err) => {
  console.error('[REDIS] Erro de conexão:', err.message);
});

redis.on('connect', () => {
  console.log('[REDIS] Conectado');
});

/**
 * Verifica a conectividade com o Redis.
 */
export async function testRedisConnection(): Promise<boolean> {
  try {
    await redis.connect();
    const pong = await redis.ping();
    return pong === 'PONG';
  } catch {
    return false;
  }
}
