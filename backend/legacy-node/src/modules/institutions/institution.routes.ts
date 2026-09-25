import { Router } from 'express';
import { z } from 'zod';
import * as repo from './institution.repository.js';
import { INSTITUTION_CATEGORIES } from './institution.types.js';

export const institutionRoutes = Router();

// ── GET /nearby ────────────────────────────────────────────────────────────
// Busca instituições próximas a uma coordenada.

const nearbySchema = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lng: z.coerce.number().min(-180).max(180),
  radius: z.coerce.number().min(100).max(50_000).default(5000),
  category: z.string().optional(),
  limit: z.coerce.number().min(1).max(50).default(20),
});

institutionRoutes.get('/nearby', async (req, res) => {
  try {
    const parsed = nearbySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(400).json({
        error: 'Parâmetros inválidos.',
        details: parsed.error.flatten().fieldErrors,
      });
      return;
    }

    const data = await repo.findNearby(parsed.data);

    res.json({
      data,
      total: data.length,
      radius_km: parsed.data.radius / 1000,
    });
  } catch (err) {
    console.error('[institutions/nearby]', err);
    res.status(500).json({ error: 'Erro ao buscar instituições próximas.' });
  }
});

// ── GET /search ────────────────────────────────────────────────────────────
// Busca instituições por texto, estado ou cidade.

const searchSchema = z.object({
  q: z.string().min(2).optional(),
  state: z.string().length(2).optional(),
  city: z.string().min(2).optional(),
  category: z.string().optional(),
  limit: z.coerce.number().min(1).max(50).default(20),
});

institutionRoutes.get('/search', async (req, res) => {
  try {
    const parsed = searchSchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(400).json({
        error: 'Parâmetros inválidos.',
        details: parsed.error.flatten().fieldErrors,
      });
      return;
    }

    const data = await repo.search(parsed.data);

    res.json({ data, total: data.length });
  } catch (err) {
    console.error('[institutions/search]', err);
    res.status(500).json({ error: 'Erro ao buscar instituições.' });
  }
});

// ── GET /categories ────────────────────────────────────────────────────────
// Lista todas as categorias disponíveis.

institutionRoutes.get('/categories', (_req, res) => {
  const categories = Object.entries(INSTITUTION_CATEGORIES).map(
    ([key, value]) => ({
      id: key,
      ...value,
    }),
  );
  res.json({ data: categories });
});

// ── GET /:id ───────────────────────────────────────────────────────────────
// Busca uma instituição pelo ID.

institutionRoutes.get('/:id', async (req, res) => {
  try {
    const institution = await repo.findById(req.params.id);

    if (!institution) {
      res.status(404).json({ error: 'Instituição não encontrada.' });
      return;
    }

    res.json({ data: institution });
  } catch (err) {
    console.error('[institutions/:id]', err);
    res.status(500).json({ error: 'Erro ao buscar instituição.' });
  }
});
