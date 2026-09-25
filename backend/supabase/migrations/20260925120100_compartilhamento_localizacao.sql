-- ============================================================================
-- Rede de Apoio — Migration: compartilhamento temporário de localização
-- Substitui o módulo location do backend Node (Redis + Socket.IO).
-- Idempotente.
--
-- Fluxo:
--   1. App chama location_share_start(duration_min) e recebe DOIS tokens:
--        publisher_token — SECRETO, fica só no app, serve para enviar/encerrar;
--        viewer_token    — vai no link para a pessoa de confiança, só permite ver.
--   2. App chama location_share_update(publisher_token, lat, lng) a cada ~15 s.
--   3. A página de acompanhamento chama location_share_view(viewer_token)
--      a cada ~15 s (polling) e mostra a última posição.
--   4. Termina por prazo (expires_at) ou por location_share_stop(publisher_token).
--
-- Privacidade:
--   * guarda SÓ a última posição (sem histórico de trajeto);
--   * tokens guardados apenas como hash SHA-256;
--   * nome/telefone da pessoa de confiança NUNCA chegam ao servidor;
--   * ao encerrar, a posição é apagada na hora; a linha é removida em até 1 h;
--   * tabela sem acesso direto: só as funções abaixo leem/escrevem.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA extensions;

-- 1. Tabela ------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.location_shares (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  publisher_token_hash  TEXT NOT NULL UNIQUE,
  viewer_token_hash     TEXT NOT NULL UNIQUE,
  label                 VARCHAR(40),
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at            TIMESTAMPTZ NOT NULL,
  ended_at              TIMESTAMPTZ,
  last_lat              DOUBLE PRECISION,
  last_lng              DOUBLE PRECISION,
  last_accuracy_m       REAL,
  last_update_at        TIMESTAMPTZ,
  creator_hash          TEXT            -- hash diário do IP, só para limitar abuso
);

CREATE INDEX IF NOT EXISTS idx_location_shares_expires ON public.location_shares(expires_at);
CREATE INDEX IF NOT EXISTS idx_location_shares_creator ON public.location_shares(creator_hash, created_at);

ALTER TABLE public.location_shares ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.location_shares FROM anon, authenticated;

-- 2. Funções auxiliares (não expostas) ----------------------------------------
CREATE OR REPLACE FUNCTION public._ls_hash(token TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
SET search_path = ''
AS $$
  SELECT encode(extensions.digest(coalesce(token, ''), 'sha256'), 'hex');
$$;

CREATE OR REPLACE FUNCTION public._ls_new_token()
RETURNS TEXT
LANGUAGE sql
VOLATILE
SET search_path = ''
AS $$
  -- 24 bytes aleatórios em base64url (32 caracteres)
  SELECT translate(encode(extensions.gen_random_bytes(24), 'base64'), '+/', '-_');
$$;

-- IP da requisição (PostgREST repassa os headers). Hash com o dia, para não
-- guardar o IP e não permitir rastrear a mesma pessoa entre dias.
CREATE OR REPLACE FUNCTION public._ls_creator_hash()
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SET search_path = ''
AS $$
DECLARE
  ip TEXT;
BEGIN
  ip := split_part(
    coalesce(current_setting('request.headers', true)::json ->> 'x-forwarded-for', ''),
    ',', 1);
  IF trim(ip) = '' THEN
    RETURN NULL;
  END IF;
  RETURN encode(extensions.digest(trim(ip) || '|' || current_date::text, 'sha256'), 'hex');
END;
$$;

REVOKE ALL ON FUNCTION public._ls_hash(TEXT), public._ls_new_token(), public._ls_creator_hash()
  FROM PUBLIC, anon, authenticated;

-- 3. Limpeza ------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.location_share_cleanup()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  removidas INTEGER;
BEGIN
  -- Apaga coordenadas de sessões vencidas imediatamente.
  UPDATE public.location_shares
  SET last_lat = NULL, last_lng = NULL, last_accuracy_m = NULL
  WHERE last_lat IS NOT NULL
    AND (expires_at <= now() OR ended_at IS NOT NULL);

  -- Remove a linha 1 h depois (tempo para a página mostrar "encerrado").
  DELETE FROM public.location_shares
  WHERE coalesce(ended_at, expires_at) < now() - INTERVAL '1 hour';
  GET DIAGNOSTICS removidas = ROW_COUNT;
  RETURN removidas;
END;
$$;

REVOKE ALL ON FUNCTION public.location_share_cleanup() FROM PUBLIC, anon, authenticated;

-- 4. API: iniciar -------------------------------------------------------------
DROP FUNCTION IF EXISTS public.location_share_start(INTEGER, TEXT);
CREATE FUNCTION public.location_share_start(
  duration_min INTEGER,
  label        TEXT DEFAULT NULL
)
RETURNS TABLE (
  share_id        UUID,
  publisher_token TEXT,
  viewer_token    TEXT,
  expires_at      TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_pub     TEXT := public._ls_new_token();
  v_view    TEXT := public._ls_new_token();
  v_creator TEXT := public._ls_creator_hash();
  v_id      UUID;
  v_exp     TIMESTAMPTZ;
BEGIN
  IF duration_min IS NULL OR duration_min < 5 OR duration_min > 60 THEN
    RAISE EXCEPTION 'duracao_invalida'
      USING ERRCODE = '22023', HINT = 'duration_min deve estar entre 5 e 60.';
  END IF;

  PERFORM public.location_share_cleanup();

  IF v_creator IS NOT NULL AND (
    SELECT count(*) FROM public.location_shares s
    WHERE s.creator_hash = v_creator AND s.created_at > now() - INTERVAL '1 hour'
  ) >= 10 THEN
    RAISE EXCEPTION 'limite_de_sessoes'
      USING ERRCODE = 'P0001', HINT = 'Muitas sessões criadas na última hora. Tente mais tarde.';
  END IF;

  v_exp := now() + make_interval(mins => duration_min);

  INSERT INTO public.location_shares
    (publisher_token_hash, viewer_token_hash, label, expires_at, creator_hash)
  VALUES
    (public._ls_hash(v_pub), public._ls_hash(v_view),
     nullif(left(trim(coalesce(label, '')), 40), ''), v_exp, v_creator)
  RETURNING id INTO v_id;

  RETURN QUERY SELECT v_id, v_pub, v_view, v_exp;
END;
$$;

-- 5. API: enviar posição ------------------------------------------------------
DROP FUNCTION IF EXISTS public.location_share_update(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, REAL);
CREATE FUNCTION public.location_share_update(
  publisher_token TEXT,
  lat             DOUBLE PRECISION,
  lng             DOUBLE PRECISION,
  accuracy_m      REAL DEFAULT NULL
)
RETURNS TABLE (
  active     BOOLEAN,
  expires_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  s public.location_shares%ROWTYPE;
BEGIN
  IF lat IS NULL OR lng IS NULL OR lat < -90 OR lat > 90 OR lng < -180 OR lng > 180 THEN
    RAISE EXCEPTION 'coordenada_invalida' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO s
  FROM public.location_shares ls
  WHERE ls.publisher_token_hash = public._ls_hash(publisher_token)
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'sessao_inexistente' USING ERRCODE = 'P0002';
  END IF;

  IF s.ended_at IS NOT NULL OR s.expires_at <= now() THEN
    RETURN QUERY SELECT false, s.expires_at;
    RETURN;
  END IF;

  -- Ignora envios muito frequentes (menos de 3 s), sem erro.
  IF s.last_update_at IS NULL OR s.last_update_at < now() - INTERVAL '3 seconds' THEN
    UPDATE public.location_shares ls
    SET last_lat = lat,
        last_lng = lng,
        last_accuracy_m = CASE WHEN accuracy_m >= 0 THEN accuracy_m END,
        last_update_at = now()
    WHERE ls.id = s.id;
  END IF;

  RETURN QUERY SELECT true, s.expires_at;
END;
$$;

-- 6. API: encerrar ------------------------------------------------------------
DROP FUNCTION IF EXISTS public.location_share_stop(TEXT);
CREATE FUNCTION public.location_share_stop(publisher_token TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  UPDATE public.location_shares ls
  SET ended_at = coalesce(ls.ended_at, now()),
      last_lat = NULL, last_lng = NULL, last_accuracy_m = NULL
  WHERE ls.publisher_token_hash = public._ls_hash(publisher_token);
  RETURN FOUND;
END;
$$;

-- 7. API: acompanhar (página da pessoa de confiança) --------------------------
DROP FUNCTION IF EXISTS public.location_share_view(TEXT);
CREATE FUNCTION public.location_share_view(viewer_token TEXT)
RETURNS TABLE (
  status          TEXT,          -- 'ativo' | 'aguardando' | 'encerrado' | 'expirado' | 'inexistente'
  label           TEXT,
  latitude        DOUBLE PRECISION,
  longitude       DOUBLE PRECISION,
  accuracy_m      REAL,
  updated_at      TIMESTAMPTZ,
  expires_at      TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  s public.location_shares%ROWTYPE;
BEGIN
  SELECT * INTO s
  FROM public.location_shares ls
  WHERE ls.viewer_token_hash = public._ls_hash(viewer_token);

  IF NOT FOUND THEN
    RETURN QUERY SELECT 'inexistente'::TEXT, NULL::TEXT, NULL::DOUBLE PRECISION,
      NULL::DOUBLE PRECISION, NULL::REAL, NULL::TIMESTAMPTZ, NULL::TIMESTAMPTZ;
  ELSIF s.ended_at IS NOT NULL THEN
    RETURN QUERY SELECT 'encerrado'::TEXT, s.label::TEXT, NULL::DOUBLE PRECISION,
      NULL::DOUBLE PRECISION, NULL::REAL, s.ended_at, s.expires_at;
  ELSIF s.expires_at <= now() THEN
    RETURN QUERY SELECT 'expirado'::TEXT, s.label::TEXT, NULL::DOUBLE PRECISION,
      NULL::DOUBLE PRECISION, NULL::REAL, s.expires_at, s.expires_at;
  ELSIF s.last_lat IS NULL THEN
    RETURN QUERY SELECT 'aguardando'::TEXT, s.label::TEXT, NULL::DOUBLE PRECISION,
      NULL::DOUBLE PRECISION, NULL::REAL, NULL::TIMESTAMPTZ, s.expires_at;
  ELSE
    RETURN QUERY SELECT 'ativo'::TEXT, s.label::TEXT, s.last_lat, s.last_lng,
      s.last_accuracy_m, s.last_update_at, s.expires_at;
  END IF;
END;
$$;

-- 8. Permissões da API --------------------------------------------------------
REVOKE ALL ON FUNCTION
  public.location_share_start(INTEGER, TEXT),
  public.location_share_update(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, REAL),
  public.location_share_stop(TEXT),
  public.location_share_view(TEXT)
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
  public.location_share_start(INTEGER, TEXT),
  public.location_share_update(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, REAL),
  public.location_share_stop(TEXT),
  public.location_share_view(TEXT)
TO anon, authenticated;

-- 9. Limpeza agendada (pg_cron), se disponível --------------------------------
-- No Supabase, habilite a extensão pg_cron em Database > Extensions caso este
-- bloco não consiga habilitá-la. Sem pg_cron, a limpeza ainda roda a cada
-- location_share_start.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'pg_cron') THEN
    BEGIN
      CREATE EXTENSION IF NOT EXISTS pg_cron;
      PERFORM cron.schedule(
        'location-share-cleanup',
        '*/15 * * * *',
        'SELECT public.location_share_cleanup();'
      );
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'pg_cron indisponível (%). Limpeza só via location_share_start.', SQLERRM;
    END;
  END IF;
END $$;
