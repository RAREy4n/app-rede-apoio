import { Router } from 'express';
import { z } from 'zod';
import { v4 as uuidv4 } from 'uuid';
import { redis } from '../../config/redis.js';

export const locationRoutes = Router();

const SHARE_BASE_URL = process.env.SHARE_BASE_URL || 'http://localhost:5173/track';
const MAX_DURATION_MIN = Number(process.env.SHARE_MAX_DURATION_MIN) || 60;

// ── POST /share ────────────────────────────────────────────────────────────
// Cria uma sessão de compartilhamento de localização temporária.

const shareSchema = z.object({
  duration_min: z.number().int().min(5).max(MAX_DURATION_MIN),
  label: z.string().max(50).optional(), // Rótulo opcional (ex: "Minha localização")
});

locationRoutes.post('/share', async (req, res) => {
  try {
    const parsed = shareSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json({
        error: 'Parâmetros inválidos.',
        details: parsed.error.flatten().fieldErrors,
      });
      return;
    }

    const { duration_min, label } = parsed.data;
    const token = uuidv4();
    const ttlSeconds = duration_min * 60;

    const session = {
      token,
      label: label || 'Localização compartilhada',
      created_at: new Date().toISOString(),
      expires_at: new Date(Date.now() + ttlSeconds * 1000).toISOString(),
      duration_min,
      lat: null,
      lng: null,
      updated_at: null,
    };

    // Salvar no Redis com TTL automático
    await redis.set(
      `location:${token}`,
      JSON.stringify(session),
      'EX',
      ttlSeconds,
    );

    const shareUrl = `${SHARE_BASE_URL}?token=${token}`;

    res.status(201).json({
      data: {
        token,
        share_url: shareUrl,
        duration_min,
        expires_at: session.expires_at,
      },
    });
  } catch (err) {
    console.error('[location/share]', err);
    res.status(500).json({ error: 'Erro ao criar sessão de compartilhamento.' });
  }
});

// ── POST /revoke ───────────────────────────────────────────────────────────
// Encerra uma sessão de compartilhamento antes do prazo.

const revokeSchema = z.object({
  token: z.string().uuid(),
});

locationRoutes.post('/revoke', async (req, res) => {
  try {
    const parsed = revokeSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json({ error: 'Token inválido.' });
      return;
    }

    const { token } = parsed.data;
    const deleted = await redis.del(`location:${token}`);

    if (deleted === 0) {
      res.status(404).json({ error: 'Sessão não encontrada ou já expirada.' });
      return;
    }

    res.json({ message: 'Sessão encerrada com sucesso.' });
  } catch (err) {
    console.error('[location/revoke]', err);
    res.status(500).json({ error: 'Erro ao encerrar sessão.' });
  }
});

// ── GET /status ────────────────────────────────────────────────────────────
// Verifica se uma sessão está ativa.

locationRoutes.get('/status', async (req, res) => {
  try {
    const token = req.query.token as string;
    if (!token) {
      res.status(400).json({ error: 'Token é obrigatório.' });
      return;
    }

    const raw = await redis.get(`location:${token}`);
    if (!raw) {
      res.json({ active: false });
      return;
    }

    const session = JSON.parse(raw);
    const ttl = await redis.ttl(`location:${token}`);

    res.json({
      active: true,
      remaining_seconds: ttl,
      expires_at: session.expires_at,
      last_update: session.updated_at,
    });
  } catch (err) {
    console.error('[location/status]', err);
    res.status(500).json({ error: 'Erro ao verificar sessão.' });
  }
});
