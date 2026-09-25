import { Server as HttpServer } from 'http';
import { Server as SocketServer } from 'socket.io';
import { redis } from '../../config/redis.js';

let io: SocketServer;

/**
 * Configura o Socket.IO para compartilhamento de localização em tempo real.
 *
 * Fluxo:
 * 1. App Flutter conecta via WS e envia "location_update" a cada 15s.
 * 2. Backend salva no Redis e repassa para a sala do token.
 * 3. Página web do contato recebe "position" com lat/lng atualizados.
 * 4. Sessão encerra por TTL do Redis ou revogação manual.
 */
export function setupSocketIO(httpServer: HttpServer): void {
  io = new SocketServer(httpServer, {
    cors: {
      origin: process.env.CORS_ORIGINS?.split(',').map(s => s.trim()) || '*',
      methods: ['GET', 'POST'],
    },
    path: '/ws',
  });

  // ── Middleware de autenticação por token ─────────────────────────────────

  io.use(async (socket, next) => {
    const token = socket.handshake.query.token as string;

    if (!token) {
      return next(new Error('Token é obrigatório.'));
    }

    // Verificar se a sessão existe no Redis
    const exists = await redis.exists(`location:${token}`);
    if (!exists) {
      return next(new Error('Sessão expirada ou inexistente.'));
    }

    // Anexar token ao socket para uso posterior
    socket.data.token = token;
    next();
  });

  // ── Eventos de conexão ──────────────────────────────────────────────────

  io.on('connection', (socket) => {
    const token = socket.data.token as string;
    const room = `track:${token}`;

    // Entrar na sala do token
    socket.join(room);
    console.log(`[WS] Conexão na sala ${room} (${socket.id})`);

    // ── Receber atualização de localização do app ────────────────────────

    socket.on('location_update', async (data: { lat: number; lng: number }) => {
      try {
        const raw = await redis.get(`location:${token}`);
        if (!raw) {
          socket.emit('session_expired');
          socket.disconnect();
          return;
        }

        const session = JSON.parse(raw);
        session.lat = data.lat;
        session.lng = data.lng;
        session.updated_at = new Date().toISOString();

        // Atualizar no Redis mantendo o TTL restante
        const ttl = await redis.ttl(`location:${token}`);
        if (ttl > 0) {
          await redis.set(
            `location:${token}`,
            JSON.stringify(session),
            'EX',
            ttl,
          );
        }

        // Emitir posição para todos na sala (página web do contato)
        io.to(room).emit('position', {
          lat: data.lat,
          lng: data.lng,
          updated_at: session.updated_at,
        });
      } catch (err) {
        console.error('[WS] Erro ao processar location_update:', err);
      }
    });

    // ── Encerramento manual ─────────────────────────────────────────────

    socket.on('revoke_session', async () => {
      try {
        await redis.del(`location:${token}`);
        io.to(room).emit('session_ended');
        socket.disconnect();
      } catch (err) {
        console.error('[WS] Erro ao revogar sessão:', err);
      }
    });

    // ── Desconexão ──────────────────────────────────────────────────────

    socket.on('disconnect', () => {
      console.log(`[WS] Desconexão da sala ${room} (${socket.id})`);
    });
  });
}

export { io };
