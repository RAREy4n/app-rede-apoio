-- ============================================================================
-- Rede de Apoio — Schema do banco de dados
-- Requer extensão PostGIS habilitada.
-- ============================================================================

-- Habilitar PostGIS (executar como superuser se necessário)
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Tabela de instituições ──────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS institutions (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          VARCHAR(200) NOT NULL,
  category      VARCHAR(50) NOT NULL,
  subcategory   VARCHAR(100),
  address       TEXT NOT NULL,
  city          VARCHAR(100) NOT NULL,
  state         CHAR(2) NOT NULL,
  zip_code      VARCHAR(10),
  phone         VARCHAR(20),
  phone2        VARCHAR(20),
  email         VARCHAR(150),
  website       VARCHAR(250),
  opening_hours JSONB,
  location      GEOGRAPHY(Point, 4326) NOT NULL,
  services      TEXT[],
  verified_at   TIMESTAMPTZ,
  is_active     BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_institutions_location ON institutions USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_institutions_category ON institutions(category);
CREATE INDEX IF NOT EXISTS idx_institutions_state    ON institutions(state);
CREATE INDEX IF NOT EXISTS idx_institutions_city     ON institutions(city);
CREATE INDEX IF NOT EXISTS idx_institutions_active   ON institutions(is_active);

-- ── Tabela de guias de orientação ───────────────────────────────────────────

CREATE TABLE IF NOT EXISTS guides (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug       VARCHAR(100) UNIQUE NOT NULL,
  title      VARCHAR(200) NOT NULL,
  icon       VARCHAR(10),
  summary    TEXT NOT NULL,
  content    TEXT NOT NULL,
  category   VARCHAR(50) NOT NULL,
  priority   INTEGER DEFAULT 0,
  is_active  BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_guides_slug     ON guides(slug);
CREATE INDEX IF NOT EXISTS idx_guides_category ON guides(category);
CREATE INDEX IF NOT EXISTS idx_guides_active   ON guides(is_active);
