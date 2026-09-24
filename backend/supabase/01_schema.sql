-- ============================================================================
-- Rede de Apoio — Schema Supabase
-- Execute no SQL Editor do Supabase Dashboard
-- ============================================================================

-- 1. Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS postgis SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions;

-- ============================================================================
-- 2. TABELA: institutions (rede de apoio geolocalizada)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.institutions (
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
  location      geography(Point, 4326) NOT NULL,
  services      TEXT[],
  verified_at   TIMESTAMPTZ,
  is_active     BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_institutions_location ON public.institutions USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_institutions_category ON public.institutions(category);
CREATE INDEX IF NOT EXISTS idx_institutions_state    ON public.institutions(state);
CREATE INDEX IF NOT EXISTS idx_institutions_city     ON public.institutions(city);
CREATE INDEX IF NOT EXISTS idx_institutions_active   ON public.institutions(is_active);

-- RLS (Row Level Security) — leitura pública, escrita restrita
ALTER TABLE public.institutions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Instituições são visíveis publicamente"
  ON public.institutions FOR SELECT
  USING (is_active = true);

-- ============================================================================
-- 3. TABELA: guides (orientações e direitos)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.guides (
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

CREATE INDEX IF NOT EXISTS idx_guides_slug     ON public.guides(slug);
CREATE INDEX IF NOT EXISTS idx_guides_category ON public.guides(category);
CREATE INDEX IF NOT EXISTS idx_guides_active   ON public.guides(is_active);

-- RLS — leitura pública
ALTER TABLE public.guides ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Guias são visíveis publicamente"
  ON public.guides FOR SELECT
  USING (is_active = true);

-- ============================================================================
-- 4. FUNÇÃO RPC: nearby_institutions (busca geoespacial)
-- ============================================================================
-- Chamada pelo Flutter via: supabase.rpc('nearby_institutions', params: {...})

CREATE OR REPLACE FUNCTION public.nearby_institutions(
  lat FLOAT,
  lng FLOAT,
  radius_meters INT DEFAULT 5000,
  filter_category TEXT DEFAULT NULL,
  max_results INT DEFAULT 20
)
RETURNS TABLE (
  id UUID,
  name VARCHAR(200),
  category VARCHAR(50),
  subcategory VARCHAR(100),
  address TEXT,
  city VARCHAR(100),
  state CHAR(2),
  zip_code VARCHAR(10),
  phone VARCHAR(20),
  phone2 VARCHAR(20),
  email VARCHAR(150),
  website VARCHAR(250),
  opening_hours JSONB,
  latitude FLOAT,
  longitude FLOAT,
  services TEXT[],
  verified_at TIMESTAMPTZ,
  distance_km FLOAT
)
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
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
    ST_Y(i.location::geometry)::FLOAT AS latitude,
    ST_X(i.location::geometry)::FLOAT AS longitude,
    i.services,
    i.verified_at,
    ROUND((ST_Distance(
      i.location,
      ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography
    ) / 1000.0)::numeric, 2)::FLOAT AS distance_km
  FROM public.institutions i
  WHERE i.is_active = true
    AND (
      radius_meters IS NULL 
      OR radius_meters <= 0 
      OR ST_DWithin(i.location, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography, radius_meters)
    )
    AND (filter_category IS NULL OR i.category = filter_category)
  ORDER BY distance_km ASC
  LIMIT LEAST(max_results, 50);
$$;
