import { query } from '../../config/database.js';

export interface Guide {
  id: string;
  slug: string;
  title: string;
  icon: string;
  summary: string;
  content: string;
  category: string;
  priority: number;
  is_active: boolean;
}

/**
 * Lista todos os guias ativos, ordenados por prioridade.
 */
export async function findAllGuides(): Promise<Omit<Guide, 'content'>[]> {
  const sql = `
    SELECT id, slug, title, icon, summary, category, priority
    FROM guides
    WHERE is_active = true
    ORDER BY priority DESC, title ASC
  `;
  const result = await query(sql);
  return result.rows;
}

/**
 * Busca um guia pelo slug.
 */
export async function findGuideBySlug(slug: string): Promise<Guide | null> {
  const sql = `
    SELECT id, slug, title, icon, summary, content, category, priority
    FROM guides
    WHERE slug = $1 AND is_active = true
  `;
  const result = await query(sql, [slug]);
  return result.rows[0] ?? null;
}
