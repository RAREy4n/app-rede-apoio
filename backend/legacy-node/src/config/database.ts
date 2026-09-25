import pg from 'pg';

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 5_000,
});

pool.on('error', (err) => {
  console.error('[DB] Erro inesperado na conexão:', err.message);
});

/**
 * Executa uma query SQL parametrizada no pool de conexões.
 *
 * Exemplo:
 * ```ts
 * const result = await query('SELECT * FROM institutions WHERE id = $1', [id]);
 * ```
 */
export async function query<T extends pg.QueryResultRow = any>(
  text: string,
  params?: any[],
): Promise<pg.QueryResult<T>> {
  return pool.query<T>(text, params);
}

/**
 * Verifica a conectividade com o banco de dados.
 */
export async function testConnection(): Promise<boolean> {
  try {
    await pool.query('SELECT 1');
    return true;
  } catch {
    return false;
  }
}

export { pool };
