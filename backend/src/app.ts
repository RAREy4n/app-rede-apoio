import 'dotenv/config';

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { createServer } from 'http';

import { institutionRoutes } from './modules/institutions/institution.routes.js';
import { contentRoutes } from './modules/content/content.routes.js';
import { locationRoutes } from './modules/location/location.routes.js';
import { setupSocketIO } from './modules/location/location.socket.js';

const app = express();
const httpServer = createServer(app);

// ── Middleware global ──────────────────────────────────────────────────────

app.use(helmet());

app.use(cors({
  origin: process.env.CORS_ORIGINS?.split(',').map(s => s.trim()) || '*',
  methods: ['GET', 'POST'],
}));

app.use(express.json({ limit: '1mb' }));

app.use(rateLimit({
  windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: Number(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Muitas requisições. Tente novamente em alguns minutos.' },
}));

// ── Health check ───────────────────────────────────────────────────────────

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ── Rotas ──────────────────────────────────────────────────────────────────

app.use('/api/v1/institutions', institutionRoutes);
app.use('/api/v1/content', contentRoutes);
app.use('/api/v1/location', locationRoutes);

// ── WebSocket (Socket.IO) ─────────────────────────────────────────────────

setupSocketIO(httpServer);

// ── Tratamento de erros ───────────────────────────────────────────────────

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('[ERRO]', err.message);
  res.status(500).json({ error: 'Erro interno do servidor.' });
});

// ── Iniciar servidor ──────────────────────────────────────────────────────

const PORT = Number(process.env.PORT) || 3000;

httpServer.listen(PORT, () => {
  console.log(`\n🟢 Rede de Apoio — Backend rodando na porta ${PORT}`);
  console.log(`   Health check: http://localhost:${PORT}/api/health`);
  console.log(`   Ambiente: ${process.env.NODE_ENV || 'development'}\n`);
});

export { app, httpServer };
