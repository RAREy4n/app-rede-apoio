-- ============================================================================
-- Rede de Apoio — 03: Busca de instituições e curadoria de dados
-- Execute no SQL Editor do Supabase DEPOIS de 01_schema.sql e 02_seed.sql.
-- O script é idempotente: pode ser executado mais de uma vez.
--
-- O que este script faz:
--   1. Habilita unaccent + pg_trgm (busca sem acento e tolerante a trechos).
--   2. Acrescenta campos de curadoria: fonte oficial, verificação, bairro,
--      público atendido, precisão da coordenada e chave estável (external_key).
--   3. Mantém uma coluna search_text normalizada (sem acento, minúscula).
--   4. Cria a função RPC search_institutions (texto + categoria + cidade +
--      distância), usada pelo app.
--   5. Cria a fila de revisão humana (institution_review_queue) e a view de
--      registros com verificação vencida (institutions_stale).
--   6. Garante que Casa-Abrigo (endereço sigiloso) NUNCA seja exposta.
-- ============================================================================

-- 1. Extensões ---------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS unaccent SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_trgm  SCHEMA extensions;

-- unaccent() não é IMMUTABLE; este wrapper permite usá-lo em índices/triggers.
CREATE OR REPLACE FUNCTION public.f_normalize(txt TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
SET search_path = ''
AS $$
  SELECT lower(extensions.unaccent('extensions.unaccent'::regdictionary, coalesce(txt, '')));
$$;

-- 2. Campos de curadoria -----------------------------------------------------
ALTER TABLE public.institutions
  ADD COLUMN IF NOT EXISTS external_key       VARCHAR(100),
  ADD COLUMN IF NOT EXISTS district           VARCHAR(100),
  ADD COLUMN IF NOT EXISTS target_audience    TEXT,
  ADD COLUMN IF NOT EXISTS source_name        TEXT,
  ADD COLUMN IF NOT EXISTS source_url         TEXT,
  ADD COLUMN IF NOT EXISTS verified_by        TEXT,
  ADD COLUMN IF NOT EXISTS location_precision VARCHAR(20) NOT NULL DEFAULT 'exata',
  ADD COLUMN IF NOT EXISTS notes              TEXT,
  ADD COLUMN IF NOT EXISTS search_text        TEXT;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'institutions_location_precision_chk'
  ) THEN
    ALTER TABLE public.institutions
      ADD CONSTRAINT institutions_location_precision_chk
      CHECK (location_precision IN ('exata', 'aproximada'));
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_institutions_external_key
  ON public.institutions(external_key);

-- 3. Texto de busca normalizado ---------------------------------------------
CREATE OR REPLACE FUNCTION public.institutions_build_search_text()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  NEW.search_text := public.f_normalize(concat_ws(' ',
    NEW.name,
    NEW.category,
    replace(NEW.category, '_', ' '),
    NEW.subcategory,
    NEW.address,
    NEW.district,
    NEW.city,
    NEW.target_audience,
    replace(array_to_string(NEW.services, ' '), '_', ' ')
  ));
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_institutions_search_text ON public.institutions;
CREATE TRIGGER trg_institutions_search_text
  BEFORE INSERT OR UPDATE ON public.institutions
  FOR EACH ROW EXECUTE FUNCTION public.institutions_build_search_text();

-- Preenche registros já existentes (dispara o trigger).
UPDATE public.institutions SET name = name;

CREATE INDEX IF NOT EXISTS idx_institutions_search_trgm
  ON public.institutions USING GIN (search_text extensions.gin_trgm_ops);

-- 4. Sigilo: Casa-Abrigo nunca é pública ------------------------------------
DROP POLICY IF EXISTS "Instituições são visíveis publicamente" ON public.institutions;
CREATE POLICY "Instituições são visíveis publicamente"
  ON public.institutions FOR SELECT
  USING (is_active = true AND category <> 'casa_abrigo');

-- 5. RPC de busca ------------------------------------------------------------
-- Chamada pelo Flutter:
--   supabase.rpc('search_institutions', params: {
--     'q': 'delegacia cabral', 'lat': -25.43, 'lng': -49.27,
--     'filter_categories': ['delegacia_mulher'], 'filter_city': 'Curitiba'
--   })
-- Regras:
--   * cada palavra digitada precisa aparecer (sem acento) no search_text;
--   * com lat/lng, ordena por distância; sem lat/lng, por relevância e nome;
--   * radius_meters NULL ou <= 0 = sem limite de distância.
DROP FUNCTION IF EXISTS public.search_institutions(TEXT, FLOAT, FLOAT, TEXT, TEXT[], INT, INT);

CREATE FUNCTION public.search_institutions(
  q                 TEXT    DEFAULT NULL,
  lat               FLOAT   DEFAULT NULL,
  lng               FLOAT   DEFAULT NULL,
  filter_city       TEXT    DEFAULT NULL,
  filter_categories TEXT[]  DEFAULT NULL,
  radius_meters     INT     DEFAULT NULL,
  max_results       INT     DEFAULT 30
)
RETURNS TABLE (
  id                 UUID,
  external_key       VARCHAR(100),
  name               VARCHAR(200),
  category           VARCHAR(50),
  subcategory        VARCHAR(100),
  address            TEXT,
  district           VARCHAR(100),
  city               VARCHAR(100),
  state              CHAR(2),
  zip_code           VARCHAR(10),
  phone              VARCHAR(20),
  phone2             VARCHAR(20),
  email              VARCHAR(150),
  website            VARCHAR(250),
  opening_hours      JSONB,
  latitude           FLOAT,
  longitude          FLOAT,
  services           TEXT[],
  target_audience    TEXT,
  verified_at        TIMESTAMPTZ,
  source_name        TEXT,
  source_url         TEXT,
  location_precision VARCHAR(20),
  distance_km        FLOAT
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
  WITH params AS (
    SELECT
      CASE WHEN lat IS NOT NULL AND lng IS NOT NULL
           THEN extensions.ST_SetSRID(extensions.ST_MakePoint(lng, lat), 4326)::extensions.geography
      END AS origin,
      array_remove(
        regexp_split_to_array(public.f_normalize(trim(coalesce(q, ''))), '\s+'),
        ''
      ) AS terms
  )
  SELECT
    i.id,
    i.external_key,
    i.name,
    i.category,
    i.subcategory,
    i.address,
    i.district,
    i.city,
    i.state,
    i.zip_code,
    i.phone,
    i.phone2,
    i.email,
    i.website,
    i.opening_hours,
    extensions.ST_Y(i.location::extensions.geometry)::FLOAT AS latitude,
    extensions.ST_X(i.location::extensions.geometry)::FLOAT AS longitude,
    i.services,
    i.target_audience,
    i.verified_at,
    i.source_name,
    i.source_url,
    i.location_precision,
    CASE WHEN p.origin IS NOT NULL
         THEN round((extensions.ST_Distance(i.location, p.origin) / 1000.0)::numeric, 2)::FLOAT
    END AS distance_km
  FROM public.institutions i
  CROSS JOIN params p
  WHERE i.is_active = true
    AND i.category <> 'casa_abrigo'
    AND (filter_city IS NULL OR public.f_normalize(i.city) = public.f_normalize(filter_city))
    AND (filter_categories IS NULL OR cardinality(filter_categories) = 0
         OR i.category = ANY (filter_categories))
    AND NOT EXISTS (
      SELECT 1 FROM unnest(p.terms) AS t(term)
      WHERE position(t.term IN i.search_text) = 0
    )
    AND (
      p.origin IS NULL OR radius_meters IS NULL OR radius_meters <= 0
      OR extensions.ST_DWithin(i.location, p.origin, radius_meters)
    )
  ORDER BY
    CASE WHEN p.origin IS NOT NULL THEN extensions.ST_Distance(i.location, p.origin) END ASC NULLS LAST,
    CASE WHEN cardinality(p.terms) > 0
         THEN extensions.similarity(i.search_text, array_to_string(p.terms, ' ')) END DESC NULLS LAST,
    i.name ASC
  LIMIT LEAST(GREATEST(coalesce(max_results, 30), 1), 50);
$$;

GRANT EXECUTE ON FUNCTION public.search_institutions(TEXT, FLOAT, FLOAT, TEXT, TEXT[], INT, INT)
  TO anon, authenticated;

-- 6. Curadoria: fila de revisão humana --------------------------------------
-- Toda alteração detectada (por coleta programada ou relato de usuária/parceiro)
-- entra aqui como 'pendente'. Nada é publicado sem aprovação humana.
CREATE TABLE IF NOT EXISTS public.institution_review_queue (
  id             UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  institution_id UUID REFERENCES public.institutions(id) ON DELETE CASCADE,
  external_key   VARCHAR(100),
  kind           VARCHAR(20) NOT NULL
                 CHECK (kind IN ('novo', 'alteracao', 'desativacao', 'reverificacao')),
  proposed       JSONB,
  source_name    TEXT,
  source_url     TEXT,
  detected_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  status         VARCHAR(20) NOT NULL DEFAULT 'pendente'
                 CHECK (status IN ('pendente', 'aprovado', 'rejeitado')),
  reviewed_by    TEXT,
  reviewed_at    TIMESTAMPTZ,
  notes          TEXT
);

CREATE INDEX IF NOT EXISTS idx_review_queue_status
  ON public.institution_review_queue(status, detected_at);

-- RLS ativo e SEM políticas públicas: só service_role (painel/admin) acessa.
ALTER TABLE public.institution_review_queue ENABLE ROW LEVEL SECURITY;

-- Registros ativos sem verificação ou verificados há mais de 180 dias.
-- Use para gerar a lista mensal de reverificação.
CREATE OR REPLACE VIEW public.institutions_stale
WITH (security_invoker = true) AS
SELECT
  i.id, i.external_key, i.name, i.category, i.city, i.phone,
  i.verified_at, i.source_url,
  CASE WHEN i.verified_at IS NULL THEN 'nunca verificado'
       ELSE 'verificado há ' || (now()::date - i.verified_at::date) || ' dias'
  END AS situacao
FROM public.institutions i
WHERE i.is_active = true
  AND (i.verified_at IS NULL OR i.verified_at < now() - INTERVAL '180 days')
ORDER BY i.verified_at NULLS FIRST;

REVOKE ALL ON public.institutions_stale FROM anon, authenticated;
