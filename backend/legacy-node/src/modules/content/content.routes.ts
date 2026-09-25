import { Router } from 'express';
import * as repo from './content.repository.js';

export const contentRoutes = Router();

// ── GET /guides ────────────────────────────────────────────────────────────
// Lista todos os guias de orientação.

contentRoutes.get('/guides', async (_req, res) => {
  try {
    const guides = await repo.findAllGuides();
    res.json({ data: guides });
  } catch (err) {
    console.error('[content/guides]', err);
    res.status(500).json({ error: 'Erro ao buscar orientações.' });
  }
});

// ── GET /guides/:slug ──────────────────────────────────────────────────────
// Busca o conteúdo completo de um guia pelo slug.

contentRoutes.get('/guides/:slug', async (req, res) => {
  try {
    const guide = await repo.findGuideBySlug(req.params.slug);

    if (!guide) {
      res.status(404).json({ error: 'Orientação não encontrada.' });
      return;
    }

    res.json({ data: guide });
  } catch (err) {
    console.error('[content/guides/:slug]', err);
    res.status(500).json({ error: 'Erro ao buscar orientação.' });
  }
});
