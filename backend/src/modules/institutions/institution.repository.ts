import { query } from '../../config/database.js';
import type { Institution, NearbyQuery, SearchQuery } from './institution.types.js';

/**
 * Busca instituições próximas a uma coordenada usando PostGIS.
 *
 * Usa ST_DWithin para filtro geoespacial eficiente (usa índice GIST)
 * e ST_Distance para ordenar por distância real.
 */
export async function findNearby(params: NearbyQuery): Promise<Institution[]> {
  const {
    lat,
    lng,
    radius = 5000,
    category,
    limit = 20,
  } = params;

  const categoryFilter = category
    ? `AND i.category = ANY($4::text[])`
    : '';

  const sql = `
    SELECT
      i.id,
      i.name,
      i.category,
      i.subcategory,
      i.address,
      i.city,
      i.state,
      i.zip_code,
      i.phone,
      i.phone2,
      i.email,
      i.website,
      i.opening_hours,
      ST_Y(i.location::geometry) AS latitude,
      ST_X(i.location::geometry) AS longitude,
      i.services,
      i.verified_at,
      i.is_active,
      ROUND((ST_Distance(
        i.location,
        ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography
      ) / 1000.0)::numeric, 2) AS distance_km
    FROM institutions i
    WHERE i.is_active = true
      AND ST_DWithin(
        i.location,
        ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography,
        $3
      )
      ${categoryFilter}
    ORDER BY distance_km ASC
    LIMIT ${Math.min(limit, 50)}
  `;

  const queryParams: any[] = [lat, lng, radius];
  if (category) {
    queryParams.push(category.split(',').map(c => c.trim()));
  }

  const result = await query<Institution>(sql, queryParams);
  return result.rows;
}

/**
 * Busca uma instituição pelo ID.
 */
export async function findById(id: string): Promise<Institution | null> {
  const sql = `
    SELECT
      i.id,
      i.name,
      i.category,
      i.subcategory,
      i.address,
      i.city,
      i.state,
      i.zip_code,
      i.phone,
      i.phone2,
      i.email,
      i.website,
      i.opening_hours,
      ST_Y(i.location::geometry) AS latitude,
      ST_X(i.location::geometry) AS longitude,
      i.services,
      i.verified_at,
      i.is_active
    FROM institutions i
    WHERE i.id = $1
  `;

  const result = await query<Institution>(sql, [id]);
  return result.rows[0] ?? null;
}

/**
 * Busca instituições por texto, estado ou cidade.
 */
export async function search(params: SearchQuery): Promise<Institution[]> {
  const { q, state, city, category, limit = 20 } = params;

  const conditions: string[] = ['i.is_active = true'];
  const queryParams: any[] = [];
  let paramIndex = 1;

  if (q) {
    conditions.push(`(
      i.name ILIKE $${paramIndex}
      OR i.address ILIKE $${paramIndex}
      OR i.subcategory ILIKE $${paramIndex}
    )`);
    queryParams.push(`%${q}%`);
    paramIndex++;
  }

  if (state) {
    conditions.push(`i.state = $${paramIndex}`);
    queryParams.push(state.toUpperCase());
    paramIndex++;
  }

  if (city) {
    conditions.push(`i.city ILIKE $${paramIndex}`);
    queryParams.push(`%${city}%`);
    paramIndex++;
  }

  if (category) {
    conditions.push(`i.category = ANY($${paramIndex}::text[])`);
    queryParams.push(category.split(',').map(c => c.trim()));
    paramIndex++;
  }

  const sql = `
    SELECT
      i.id,
      i.name,
      i.category,
      i.subcategory,
      i.address,
      i.city,
      i.state,
      i.zip_code,
      i.phone,
      i.phone2,
      i.email,
      i.website,
      i.opening_hours,
      ST_Y(i.location::geometry) AS latitude,
      ST_X(i.location::geometry) AS longitude,
      i.services,
      i.verified_at,
      i.is_active
    FROM institutions i
    WHERE ${conditions.join(' AND ')}
    ORDER BY i.name ASC
    LIMIT ${Math.min(limit, 50)}
  `;

  const result = await query<Institution>(sql, queryParams);
  return result.rows;
}
