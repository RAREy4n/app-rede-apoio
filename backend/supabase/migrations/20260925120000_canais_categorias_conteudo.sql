-- ============================================================================
-- Rede de Apoio — Migration: canais de emergência, categorias e conteúdo
-- Depende de: base_curitiba. Idempotente.
--
-- Cria o que o front precisa para não ter nada "chumbado" no código:
--   * emergency_channels   — telefones oficiais (190, 180, 192, 153...)
--   * institution_categories — nomes e grupos de filtro das categorias
--   * guides (colunas novas) — fonte, revisão e abrangência do conteúdo
--   * RPC get_emergency_channels(state, city)
--   * RPC get_app_bootstrap(state, city) — tudo acima em uma chamada, para o
--     app guardar em cache e funcionar sem internet.
-- ============================================================================

-- 1. Canais de emergência e orientação ---------------------------------------
CREATE TABLE IF NOT EXISTS public.emergency_channels (
  id           VARCHAR(60) PRIMARY KEY,           -- slug estável, ex.: 'pm-190'
  name         VARCHAR(120) NOT NULL,
  phone        VARCHAR(20),                       -- número para discar
  whatsapp     VARCHAR(20),                       -- só dígitos, com DDI (ex.: 556196100180)
  description  TEXT NOT NULL,
  when_to_use  TEXT,
  kind         VARCHAR(20) NOT NULL DEFAULT 'orientacao'
               CHECK (kind IN ('emergencia', 'orientacao', 'saude', 'protecao')),
  scope        VARCHAR(20) NOT NULL DEFAULT 'nacional'
               CHECK (scope IN ('nacional', 'estadual', 'municipal')),
  state        CHAR(2),
  city         VARCHAR(100),
  is_24h       BOOLEAN NOT NULL DEFAULT false,
  sort_order   INTEGER NOT NULL DEFAULT 100,
  is_active    BOOLEAN NOT NULL DEFAULT true,
  source_name  TEXT,
  source_url   TEXT,
  verified_at  TIMESTAMPTZ,
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT emergency_channels_contact_chk CHECK (phone IS NOT NULL OR whatsapp IS NOT NULL),
  CONSTRAINT emergency_channels_scope_chk CHECK (
    (scope = 'nacional'  AND state IS NULL AND city IS NULL) OR
    (scope = 'estadual'  AND state IS NOT NULL AND city IS NULL) OR
    (scope = 'municipal' AND state IS NOT NULL AND city IS NOT NULL)
  )
);

ALTER TABLE public.emergency_channels ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Canais ativos são públicos" ON public.emergency_channels;
CREATE POLICY "Canais ativos são públicos"
  ON public.emergency_channels FOR SELECT
  USING (is_active = true);

INSERT INTO public.emergency_channels
  (id, name, phone, whatsapp, description, when_to_use, kind, scope, state, city,
   is_24h, sort_order, source_name, source_url, verified_at)
VALUES
  ('pm-190', 'Polícia Militar', '190', NULL,
   'Atendimento de urgência policial. Ligação gratuita.',
   'Risco imediato: agressão acontecendo agora ou ameaça grave.',
   'emergencia', 'nacional', NULL, NULL, true, 10,
   'Prefeitura de Curitiba — Rede de Atenção às mulheres',
   'https://mulhereigualdade.curitiba.pr.gov.br/conteudo/rede-de-atencao-as-mulheres-em-situacao-de-violencias/12',
   now()),
  ('ligue-180', 'Ligue 180 — Central de Atendimento à Mulher', '180', '556196100180',
   'Orientação, denúncia e encaminhamento para a rede de atendimento. Gratuito e sigiloso.',
   'Quando precisar de orientação sobre direitos, serviços ou como denunciar.',
   'orientacao', 'nacional', NULL, NULL, true, 20,
   'Prefeitura de Curitiba — Rede de Atenção às mulheres',
   'https://mulhereigualdade.curitiba.pr.gov.br/conteudo/rede-de-atencao-as-mulheres-em-situacao-de-violencias/12',
   now()),
  ('samu-192', 'SAMU', '192', NULL,
   'Atendimento médico de urgência.',
   'Quando houver ferimento ou mal-estar que precise de socorro médico.',
   'saude', 'nacional', NULL, NULL, true, 30,
   NULL, NULL, NULL),
  ('cwb-guarda-153', 'Guarda Municipal de Curitiba — Patrulha Maria da Penha', '153', NULL,
   'Atende mulheres com medida protetiva em Curitiba.',
   'Se você tem medida protetiva e o agressor descumpriu ou se aproximou.',
   'protecao', 'municipal', 'PR', 'Curitiba', true, 40,
   'Prefeitura de Curitiba — Rede de Atenção às mulheres',
   'https://mulhereigualdade.curitiba.pr.gov.br/conteudo/rede-de-atencao-as-mulheres-em-situacao-de-violencias/12',
   now())
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, phone = EXCLUDED.phone, whatsapp = EXCLUDED.whatsapp,
  description = EXCLUDED.description, when_to_use = EXCLUDED.when_to_use,
  kind = EXCLUDED.kind, scope = EXCLUDED.scope, state = EXCLUDED.state,
  city = EXCLUDED.city, is_24h = EXCLUDED.is_24h, sort_order = EXCLUDED.sort_order,
  source_name = EXCLUDED.source_name, source_url = EXCLUDED.source_url,
  verified_at = EXCLUDED.verified_at, updated_at = now();

-- 2. Categorias de instituições ----------------------------------------------
CREATE TABLE IF NOT EXISTS public.institution_categories (
  id                 VARCHAR(50) PRIMARY KEY,   -- igual a institutions.category
  label              VARCHAR(80) NOT NULL,
  description        TEXT,
  filter_group       VARCHAR(30) NOT NULL,      -- chip de filtro no app
  filter_group_label VARCHAR(40) NOT NULL,
  icon_key           VARCHAR(30) NOT NULL,      -- nome lógico; o app mapeia para o ícone
  sort_order         INTEGER NOT NULL DEFAULT 100,
  is_public          BOOLEAN NOT NULL DEFAULT true
);

ALTER TABLE public.institution_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Categorias públicas" ON public.institution_categories;
CREATE POLICY "Categorias públicas"
  ON public.institution_categories FOR SELECT
  USING (is_public = true);

INSERT INTO public.institution_categories
  (id, label, description, filter_group, filter_group_label, icon_key, sort_order, is_public)
VALUES
  ('delegacia_mulher',   'Delegacia da Mulher', 'Delegacia especializada no atendimento à mulher', 'delegacias', 'Delegacias', 'police', 10, true),
  ('delegacia_comum',    'Delegacia Especializada', 'Outras delegacias especializadas (ex.: crianças, crimes on-line)', 'delegacias', 'Delegacias', 'police', 20, true),
  ('centro_referencia',  'Centro de Referência da Mulher', 'Atendimento psicológico, social e jurídico', 'acolhimento', 'Acolhimento', 'heart', 30, true),
  ('creas',              'CREAS', 'Centro de Referência Especializado de Assistência Social', 'acolhimento', 'Acolhimento', 'heart', 40, true),
  ('cras',               'CRAS', 'Centro de Referência de Assistência Social', 'acolhimento', 'Acolhimento', 'heart', 50, true),
  ('ong',                'Organização de apoio', 'Organização não governamental de apoio à mulher', 'acolhimento', 'Acolhimento', 'heart', 60, true),
  ('defensoria',         'Defensoria Pública', 'Orientação e defesa jurídica gratuita', 'juridico', 'Jurídico', 'law', 70, true),
  ('ministerio_publico', 'Ministério Público', 'Promotoria de Justiça', 'juridico', 'Jurídico', 'law', 80, true),
  ('forum',              'Vara / Fórum', 'Vara de Violência Doméstica e Familiar', 'juridico', 'Jurídico', 'law', 90, true),
  ('hospital',           'Hospital / Saúde', 'Atendimento de saúde, incluindo violência sexual', 'saude', 'Saúde', 'health', 100, true),
  ('upa',                'UPA', 'Unidade de Pronto Atendimento', 'saude', 'Saúde', 'health', 110, true),
  ('casa_abrigo',        'Casa-Abrigo', 'Endereço sigiloso: acesso só por encaminhamento', 'acolhimento', 'Acolhimento', 'heart', 999, false)
ON CONFLICT (id) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description,
  filter_group = EXCLUDED.filter_group, filter_group_label = EXCLUDED.filter_group_label,
  icon_key = EXCLUDED.icon_key, sort_order = EXCLUDED.sort_order, is_public = EXCLUDED.is_public;

-- 3. Conteúdo (guias): fonte, revisão e abrangência --------------------------
ALTER TABLE public.guides
  ADD COLUMN IF NOT EXISTS source_name TEXT,
  ADD COLUMN IF NOT EXISTS source_url  TEXT,
  ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ,   -- revisão por profissional da rede
  ADD COLUMN IF NOT EXISTS reviewed_by TEXT,
  ADD COLUMN IF NOT EXISTS state       CHAR(2),       -- NULL = vale para todo o Brasil
  ADD COLUMN IF NOT EXISTS city        VARCHAR(100);

-- Correções de conteúdo: remove promessas que o produto não pode garantir e
-- referências a guias inexistentes. Todo guia fica "aguardando revisão"
-- (reviewed_at NULL) até ser validado por profissional da rede de atendimento.
UPDATE public.guides SET
  content = '# Em caso de emergência

## Risco imediato? Ligue 190.
O **190** é o número da Polícia Militar. A ligação é gratuita e funciona 24 horas.

### O que falar
- Diga que precisa de ajuda.
- Informe seu endereço ou um ponto de referência, se souber.
- Descreva brevemente a situação.

## Precisa de orientação? Ligue 180.
O **Ligue 180** é a Central de Atendimento à Mulher:
- Funciona **24 horas**, **7 dias por semana**.
- A ligação é **gratuita e sigilosa**.
- Também atende por WhatsApp.
- Orienta sobre direitos, serviços de proteção e como denunciar.

## Está ferida?
Ligue **192** (SAMU) ou procure o hospital mais próximo.

## Não está em risco imediato?
Veja o guia **Plano de segurança**. Cada passo conta.',
  source_name = 'Lei nº 11.340/2006 (Lei Maria da Penha)',
  source_url  = 'https://www.planalto.gov.br/ccivil_03/_ato2004-2006/2006/lei/l11340.htm',
  updated_at  = now()
WHERE slug = 'emergencia';

UPDATE public.guides SET
  content = '# Apoio financeiro

## CRAS — porta de entrada
Procure o CRAS para se inscrever no **CadÚnico** e acessar programas sociais, como o Bolsa Família.

## Direitos previstos na Lei Maria da Penha
- **Manutenção do emprego:** quando for preciso se afastar do trabalho, a lei garante a manutenção do vínculo trabalhista por até **6 meses** (art. 9º, § 2º, II).
- **Auxílio-aluguel:** pode ser determinado pelo juiz como medida protetiva para mulheres em situação de vulnerabilidade social e econômica.

Procure a **Defensoria Pública** para saber como pedir e sobre a remuneração durante o afastamento.',
  source_name = 'Lei nº 11.340/2006 (Lei Maria da Penha)',
  source_url  = 'https://www.planalto.gov.br/ccivil_03/_ato2004-2006/2006/lei/l11340.htm',
  updated_at  = now()
WHERE slug = 'apoio-financeiro';

UPDATE public.guides SET
  source_name = 'Lei nº 11.340/2006 (Lei Maria da Penha)',
  source_url  = 'https://www.planalto.gov.br/ccivil_03/_ato2004-2006/2006/lei/l11340.htm'
WHERE slug IN ('boletim-de-ocorrencia', 'medida-protetiva', 'lei-maria-da-penha')
  AND source_url IS NULL;

INSERT INTO public.guides (slug, title, icon, summary, content, category, priority)
VALUES (
  'plano-de-seguranca',
  'Plano de segurança',
  '🧭',
  'Passos práticos para se preparar para sair de uma situação de risco.',
  '# Plano de segurança

Um plano de segurança ajuda a agir mais rápido se precisar sair de casa.

## Combine com alguém de confiança
- Escolha uma pessoa que possa ser avisada.
- Combinem uma **palavra-código** que signifique "preciso de ajuda".

## Separe o essencial
Se for possível sem colocar você em risco, deixe em um lugar seguro ou com alguém de confiança:
- documentos (RG, CPF, certidões, cartão do SUS, documentos dos filhos);
- remédios de uso contínuo;
- cópia de chaves, um pouco de dinheiro e um carregador de celular.

## Conheça os lugares de apoio
Veja no app os serviços perto de você e anote o endereço da **Casa da Mulher Brasileira** ou do centro de referência da sua cidade.

## Cuidado com o celular
Veja o guia **Segurança digital no celular**.

> Em risco imediato, ligue **190**. Para orientação, ligue **180**.',
  'seguranca',
  95
)
ON CONFLICT (slug) DO NOTHING;

-- 4. RPC: canais de emergência para a localidade -----------------------------
CREATE OR REPLACE FUNCTION public.get_emergency_channels(
  p_state TEXT DEFAULT NULL,
  p_city  TEXT DEFAULT NULL
)
RETURNS SETOF public.emergency_channels
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
  SELECT c.*
  FROM public.emergency_channels c
  WHERE c.is_active
    AND (
      c.scope = 'nacional'
      OR (c.scope = 'estadual'  AND upper(c.state) = upper(p_state))
      OR (c.scope = 'municipal' AND upper(c.state) = upper(p_state)
                                AND public.f_normalize(c.city) = public.f_normalize(p_city))
    )
  ORDER BY c.sort_order, c.name;
$$;

-- 5. RPC: pacote inicial do app (cache offline) -------------------------------
-- Uma chamada só no início do app. O front guarda o JSON e usa sem internet.
-- content_version muda sempre que algum conteúdo muda: se for igual ao que o
-- app já tem, não precisa substituir o cache.
CREATE OR REPLACE FUNCTION public.get_app_bootstrap(
  p_state TEXT DEFAULT 'PR',
  p_city  TEXT DEFAULT 'Curitiba'
)
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
  SELECT jsonb_build_object(
    'content_version', (
      SELECT to_char(max(v) AT TIME ZONE 'UTC', 'YYYYMMDDHH24MISS')
      FROM (
        SELECT max(updated_at) AS v FROM public.guides
        UNION ALL SELECT max(updated_at) FROM public.emergency_channels
        UNION ALL SELECT max(updated_at) FROM public.institutions
      ) t
    ),
    'generated_at', now(),
    'location', jsonb_build_object('state', p_state, 'city', p_city),
    'emergency_channels', coalesce((
      SELECT jsonb_agg(to_jsonb(c) ORDER BY c.sort_order, c.name)
      FROM public.get_emergency_channels(p_state, p_city) c
    ), '[]'::jsonb),
    'institution_categories', coalesce((
      SELECT jsonb_agg(to_jsonb(ic) ORDER BY ic.sort_order)
      FROM public.institution_categories ic
      WHERE ic.is_public
    ), '[]'::jsonb),
    'guides', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
        'slug', g.slug, 'title', g.title, 'icon', g.icon, 'summary', g.summary,
        'content', g.content, 'category', g.category, 'priority', g.priority,
        'source_name', g.source_name, 'source_url', g.source_url,
        'reviewed_at', g.reviewed_at, 'updated_at', g.updated_at
      ) ORDER BY g.priority DESC, g.title)
      FROM public.guides g
      WHERE g.is_active
        AND (g.state IS NULL OR upper(g.state) = upper(p_state))
        AND (g.city IS NULL OR public.f_normalize(g.city) = public.f_normalize(p_city))
    ), '[]'::jsonb)
  );
$$;

GRANT SELECT ON public.emergency_channels, public.institution_categories TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_emergency_channels(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_app_bootstrap(TEXT, TEXT) TO anon, authenticated;
