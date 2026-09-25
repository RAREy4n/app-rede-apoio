-- ============================================================================
-- Rede de Apoio — Testes da API (contrato usado pelo front)
--
-- Roda tudo dentro de uma transação e desfaz no final (ROLLBACK):
-- é seguro executar no SQL Editor do Supabase, inclusive em produção.
-- Se algum teste falhar, a execução para com "FALHOU: ...".
--
-- Local: psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f backend/supabase/tests/api_test.sql
-- ============================================================================

BEGIN;

-- Simula uma requisição anônima do app vinda do PostgREST.
SET LOCAL ROLE anon;
SELECT set_config('request.headers', '{"x-forwarded-for": "203.0.113.7, 10.0.0.1"}', true);

-- ── Instituições ─────────────────────────────────────────────────────────────
DO $$
DECLARE n INT; primeiro TEXT;
BEGIN
  SELECT count(*) INTO n FROM public.search_institutions();
  IF n = 0 THEN RAISE EXCEPTION 'FALHOU: search_institutions sem filtros não retornou nada'; END IF;

  SELECT name INTO primeiro FROM public.search_institutions(q => 'AGUA verde') LIMIT 1;
  IF primeiro IS DISTINCT FROM 'Hospital Pequeno Príncipe' THEN
    RAISE EXCEPTION 'FALHOU: busca sem acento (obtido: %)', primeiro;
  END IF;

  SELECT count(*) INTO n FROM public.search_institutions(
    filter_categories => ARRAY['delegacia_mulher', 'delegacia_comum']);
  IF n < 1 OR EXISTS (
    SELECT 1 FROM public.search_institutions(filter_categories => ARRAY['delegacia_mulher'])
    WHERE category <> 'delegacia_mulher') THEN
    RAISE EXCEPTION 'FALHOU: filtro por categoria';
  END IF;

  SELECT name INTO primeiro FROM public.search_institutions(lat => -25.4047, lng => -49.2502) LIMIT 1;
  IF primeiro NOT IN ('Casa da Mulher Brasileira de Curitiba', 'Delegacia da Mulher de Curitiba') THEN
    RAISE EXCEPTION 'FALHOU: ordenação por distância (primeiro: %)', primeiro;
  END IF;

  IF EXISTS (SELECT 1 FROM public.institutions WHERE category = 'casa_abrigo') THEN
    RAISE EXCEPTION 'FALHOU: casa_abrigo visível para anon';
  END IF;
  RAISE NOTICE 'ok: instituições';
END $$;

-- ── Canais, categorias e bootstrap ──────────────────────────────────────────
DO $$
DECLARE n INT; b JSONB;
BEGIN
  SELECT count(*) INTO n FROM public.get_emergency_channels('PR', 'curitiba');
  IF n < 4 THEN RAISE EXCEPTION 'FALHOU: canais de Curitiba (obtido %)', n; END IF;

  SELECT count(*) INTO n FROM public.get_emergency_channels('SP', 'São Paulo');
  IF EXISTS (SELECT 1 FROM public.get_emergency_channels('SP', 'São Paulo') WHERE scope = 'municipal') THEN
    RAISE EXCEPTION 'FALHOU: canal municipal de Curitiba apareceu para SP';
  END IF;

  IF EXISTS (SELECT 1 FROM public.institution_categories WHERE id = 'casa_abrigo') THEN
    RAISE EXCEPTION 'FALHOU: categoria casa_abrigo exposta';
  END IF;

  b := public.get_app_bootstrap('PR', 'Curitiba');
  IF b->>'content_version' IS NULL
     OR jsonb_array_length(b->'emergency_channels') < 4
     OR jsonb_array_length(b->'institution_categories') < 5
     OR jsonb_array_length(b->'guides') < 5 THEN
    RAISE EXCEPTION 'FALHOU: bootstrap incompleto: %', left(b::text, 300);
  END IF;
  RAISE NOTICE 'ok: canais, categorias e bootstrap';
END $$;

-- ── Localização temporária ───────────────────────────────────────────────────
DO $$
DECLARE
  s RECORD; v RECORD; u RECORD; ok BOOLEAN;
BEGIN
  -- Acesso direto à tabela é proibido.
  BEGIN
    PERFORM 1 FROM public.location_shares;
    RAISE EXCEPTION 'FALHOU: anon conseguiu ler location_shares';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;

  -- Duração inválida.
  BEGIN
    PERFORM public.location_share_start(120);
    RAISE EXCEPTION 'FALHOU: aceitou duração de 120 min';
  EXCEPTION WHEN invalid_parameter_value THEN NULL;
  END;

  SELECT * INTO s FROM public.location_share_start(30, 'Maria');
  IF s.publisher_token = s.viewer_token OR length(s.viewer_token) < 30 THEN
    RAISE EXCEPTION 'FALHOU: tokens inválidos';
  END IF;

  SELECT * INTO v FROM public.location_share_view(s.viewer_token);
  IF v.status <> 'aguardando' THEN RAISE EXCEPTION 'FALHOU: status inicial %', v.status; END IF;

  SELECT * INTO u FROM public.location_share_update(s.publisher_token, -25.43, -49.27, 12);
  IF NOT u.active THEN RAISE EXCEPTION 'FALHOU: update não ativo'; END IF;

  SELECT * INTO v FROM public.location_share_view(s.viewer_token);
  IF v.status <> 'ativo' OR v.latitude <> -25.43 OR v.label <> 'Maria' THEN
    RAISE EXCEPTION 'FALHOU: view após update: % %', v.status, v.latitude;
  END IF;

  -- O token de visualização NÃO pode enviar posição nem encerrar.
  BEGIN
    PERFORM public.location_share_update(s.viewer_token, 0, 0);
    RAISE EXCEPTION 'FALHOU: viewer_token conseguiu enviar posição';
  EXCEPTION WHEN no_data_found THEN NULL;
  END;
  IF public.location_share_stop(s.viewer_token) THEN
    RAISE EXCEPTION 'FALHOU: viewer_token conseguiu encerrar';
  END IF;

  -- Coordenada inválida.
  BEGIN
    PERFORM public.location_share_update(s.publisher_token, 200, 0);
    RAISE EXCEPTION 'FALHOU: aceitou latitude 200';
  EXCEPTION WHEN invalid_parameter_value THEN NULL;
  END;

  -- Encerrar apaga a posição.
  ok := public.location_share_stop(s.publisher_token);
  SELECT * INTO v FROM public.location_share_view(s.viewer_token);
  IF NOT ok OR v.status <> 'encerrado' OR v.latitude IS NOT NULL THEN
    RAISE EXCEPTION 'FALHOU: encerramento (% %)', v.status, v.latitude;
  END IF;

  SELECT * INTO u FROM public.location_share_update(s.publisher_token, -25.43, -49.27);
  IF u.active THEN RAISE EXCEPTION 'FALHOU: sessão encerrada aceitou update'; END IF;

  SELECT * INTO v FROM public.location_share_view('token-que-nao-existe');
  IF v.status <> 'inexistente' THEN RAISE EXCEPTION 'FALHOU: token inexistente'; END IF;

  RAISE NOTICE 'ok: localização temporária';
END $$;

-- Limite de sessões por origem (10 por hora).
DO $$
DECLARE i INT;
BEGIN
  FOR i IN 1..20 LOOP
    PERFORM public.location_share_start(15);
  END LOOP;
  RAISE EXCEPTION 'FALHOU: limite de sessões não foi aplicado';
EXCEPTION WHEN raise_exception THEN
  IF SQLERRM <> 'limite_de_sessoes' THEN RAISE; END IF;
  RAISE NOTICE 'ok: limite de sessões';
END $$;

ROLLBACK;
