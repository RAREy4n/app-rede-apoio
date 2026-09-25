-- ============================================================================
-- Rede de Apoio — Migration: base inicial do piloto Curitiba/PR (antigo 04)
-- Depende de: 20260924120000_busca_curadoria. Idempotente (usa external_key).
--
-- Levantamento feito em 24/09/2026 a partir de fontes oficiais online.
-- verified_at marca a data em que o registro foi CONFERIDO com a fonte oficial
-- citada em source_url; não significa que a equipe ligou para o local.
-- Antes de uso real, a equipe deve confirmar cada telefone por ligação e
-- registrar o nome de quem verificou em verified_by.
--
-- location_precision = 'aproximada': coordenada estimada a partir do endereço;
-- precisa ser conferida no mapa antes do uso real (a rota "Como chegar"
-- usa o endereço no app quando a coordenada é aproximada).
--
-- Fora desta base, de propósito:
--   * Pousada de Maria (casa-abrigo): endereço sigiloso, acesso só via
--     encaminhamento da Casa da Mulher Brasileira.
--   * Canais só por telefone (190, 153/Patrulha Maria da Penha, 156, Ligue 180):
--     ficam nos atalhos do app, não no mapa.
-- ============================================================================

-- 1. Desativa os dados de demonstração de São Paulo (não apaga: histórico).
UPDATE public.institutions
SET is_active = false,
    notes = coalesce(notes || ' | ', '') || 'Desativado: dado de demonstração do antigo piloto SP.'
WHERE state = 'SP' AND external_key IS NULL AND is_active = true;

-- 2. Base de Curitiba --------------------------------------------------------
INSERT INTO public.institutions (
  external_key, name, category, subcategory, address, district, city, state,
  zip_code, phone, phone2, email, opening_hours, location, location_precision,
  services, target_audience, verified_at, verified_by, source_name, source_url, notes
)
VALUES
(
  'cwb-casa-mulher-brasileira',
  'Casa da Mulher Brasileira de Curitiba',
  'centro_referencia',
  'Centro de Referência de Atendimento à Mulher (CRAM)',
  'Av. Paraná, 870 - Cabral', 'Cabral', 'Curitiba', 'PR', '80035-130',
  '(41) 3221-2701', '(41) 3221-2710', 'cmb@curitiba.pr.gov.br',
  '{"seg":"24h","ter":"24h","qua":"24h","qui":"24h","sex":"24h","sab":"24h","dom":"24h"}'::jsonb,
  ST_SetSRID(ST_MakePoint(-49.25013167, -25.40468353), 4326)::geography, 'exata',
  ARRAY['acolhimento','atendimento_psicossocial','orientacao_juridica','defensoria_publica',
        'juizado_violencia_domestica','ministerio_publico','patrulha_maria_da_penha',
        'alojamento_temporario','autonomia_economica','brinquedoteca'],
  'Mulheres em situação de violência doméstica e familiar',
  now(), 'levantamento inicial (fonte oficial online)',
  'Prefeitura de Curitiba — Portal Locais',
  'https://locais.curitiba.pr.gov.br/centro-de-referencia-de-atendimento-a-mulher-casa-da-mulher-brasileira/2117',
  'Casa e delegacia 24h; demais serviços das 8h às 18h (fonte: Prefeitura, "Rede de proteção à mulher").'
),
(
  'cwb-delegacia-mulher',
  'Delegacia da Mulher de Curitiba',
  'delegacia_mulher',
  'Funciona dentro da Casa da Mulher Brasileira',
  'Av. Paraná, 870 - Cabral', 'Cabral', 'Curitiba', 'PR', '80035-130',
  '(41) 3221-2742', '(41) 3221-2745', NULL,
  '{"seg":"24h","ter":"24h","qua":"24h","qui":"24h","sex":"24h","sab":"24h","dom":"24h"}'::jsonb,
  ST_SetSRID(ST_MakePoint(-49.25013167, -25.40468353), 4326)::geography, 'exata',
  ARRAY['boletim_ocorrencia','medida_protetiva','violencia_domestica','violencia_sexual'],
  'Mulheres em situação de violência doméstica, familiar e sexual',
  now(), 'levantamento inicial (fonte oficial online)',
  'Prefeitura de Curitiba — Secretaria da Mulher e Igualdade Étnico-Racial',
  'https://mulhereigualdade.curitiba.pr.gov.br/conteudo/rede-de-atencao-as-mulheres-em-situacao-de-violencias/12',
  NULL
),
(
  'cwb-hc-ufpr',
  'Complexo Hospital de Clínicas da UFPR',
  'hospital',
  'Referência em violência sexual',
  'Rua General Carneiro, 181 - Alto da Glória', 'Alto da Glória', 'Curitiba', 'PR', '80060-150',
  '(41) 3360-1800', NULL, NULL,
  '{"seg":"24h","ter":"24h","qua":"24h","qui":"24h","sex":"24h","sab":"24h","dom":"24h"}'::jsonb,
  ST_SetSRID(ST_MakePoint(-49.2612, -25.4246), 4326)::geography, 'aproximada',
  ARRAY['atendimento_violencia_sexual','urgencia'],
  'Mulheres a partir de 12 anos, incluindo mulheres trans e travestis',
  now(), 'levantamento inicial (fonte oficial online)',
  'TJPR — CEVID, Onde procurar ajuda',
  'https://www.tjpr.jus.br/web/cevid/onde-procurar-ajuda',
  'Também listado pela Prefeitura e pela Polícia Científica do PR.'
),
(
  'cwb-evangelico-mackenzie',
  'Hospital Universitário Evangélico Mackenzie',
  'hospital',
  'Referência em violência sexual',
  'Alameda Augusto Stellfeld, 1908 - Bigorrilho', 'Bigorrilho', 'Curitiba', 'PR', '80730-150',
  '(41) 3240-5000', NULL, NULL,
  '{"seg":"24h","ter":"24h","qua":"24h","qui":"24h","sex":"24h","sab":"24h","dom":"24h"}'::jsonb,
  ST_SetSRID(ST_MakePoint(-49.2870, -25.4296), 4326)::geography, 'aproximada',
  ARRAY['atendimento_violencia_sexual','urgencia'],
  'Mulheres a partir de 12 anos',
  now(), 'levantamento inicial (fonte oficial online)',
  'TJPR — CEVID, Onde procurar ajuda',
  'https://www.tjpr.jus.br/web/cevid/onde-procurar-ajuda',
  NULL
),
(
  'cwb-hospital-trabalhador',
  'Complexo Hospitalar do Trabalhador (CHT)',
  'hospital',
  'Referência em violência sexual',
  'Av. República Argentina, 4406 - Novo Mundo', 'Novo Mundo', 'Curitiba', 'PR', NULL,
  NULL, NULL, NULL,
  NULL,
  ST_SetSRID(ST_MakePoint(-49.2940, -25.4940), 4326)::geography, 'aproximada',
  ARRAY['atendimento_violencia_sexual','urgencia'],
  'Meninas e mulheres a partir de 12 anos',
  NULL, NULL,
  'Polícia Científica do PR — Hospitais de referência (violência sexual)',
  'https://www.policiacientifica.pr.gov.br/sites/policia-cientifica/arquivos_restritos/files/documento/2026-04/hospitais_de_referencia-_violencia_sexual-1.pdf',
  'PENDENTE: fontes divergem no endereço (Prefeitura cita Rua Isaac Guelmann s/n). Telefone não informado nas fontes.'
),
(
  'cwb-pequeno-principe',
  'Hospital Pequeno Príncipe',
  'hospital',
  'Referência em violência sexual contra crianças',
  'Rua Desembargador Motta, 1070 - Água Verde', 'Água Verde', 'Curitiba', 'PR', '80250-060',
  '(41) 3310-1010', NULL, NULL,
  '{"seg":"24h","ter":"24h","qua":"24h","qui":"24h","sex":"24h","sab":"24h","dom":"24h"}'::jsonb,
  ST_SetSRID(ST_MakePoint(-49.2775, -25.4440), 4326)::geography, 'aproximada',
  ARRAY['atendimento_violencia_sexual','atendimento_infantil'],
  'Crianças (até 11 ou 12 anos — as fontes divergem)',
  now(), 'levantamento inicial (fonte oficial online)',
  'TJPR — CEVID, Onde procurar ajuda',
  'https://www.tjpr.jus.br/web/cevid/onde-procurar-ajuda',
  NULL
),
(
  'cwb-nucria',
  'NUCRIA — Núcleo de Proteção à Criança e ao Adolescente',
  'delegacia_comum',
  'Delegacia especializada: crianças e adolescentes',
  'Rua Vicente Machado, 2560 - Campina do Siqueira', 'Campina do Siqueira', 'Curitiba', 'PR', NULL,
  '(41) 3270-3370', NULL, NULL,
  NULL,
  ST_SetSRID(ST_MakePoint(-49.2995, -25.4400), 4326)::geography, 'aproximada',
  ARRAY['boletim_ocorrencia','protecao_crianca_adolescente'],
  'Crianças e adolescentes vítimas de crimes',
  now(), 'levantamento inicial (fonte oficial online)',
  'Prefeitura de Curitiba — Secretaria da Mulher e Igualdade Étnico-Racial',
  'https://mulhereigualdade.curitiba.pr.gov.br/conteudo/rede-de-atencao-as-mulheres-em-situacao-de-violencias/12',
  'Horário não informado na fonte.'
),
(
  'cwb-nuciber',
  'NUCIBER — Delegacia de Crimes Cibernéticos',
  'delegacia_comum',
  'Delegacia especializada: crimes na internet',
  'Rua Pedro Ivo, 672 - Centro', 'Centro', 'Curitiba', 'PR', NULL,
  '(41) 3304-6800', NULL, NULL,
  NULL,
  ST_SetSRID(ST_MakePoint(-49.2720, -25.4360), 4326)::geography, 'aproximada',
  ARRAY['boletim_ocorrencia','crimes_ciberneticos','importunacao_sexual_online'],
  'Vítimas de crimes no ambiente virtual',
  now(), 'levantamento inicial (fonte oficial online)',
  'Prefeitura de Curitiba — Secretaria da Mulher e Igualdade Étnico-Racial',
  'https://mulhereigualdade.curitiba.pr.gov.br/conteudo/rede-de-atencao-as-mulheres-em-situacao-de-violencias/12',
  'Horário não informado na fonte.'
)
ON CONFLICT (external_key) DO UPDATE SET
  name = EXCLUDED.name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  address = EXCLUDED.address,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  state = EXCLUDED.state,
  zip_code = EXCLUDED.zip_code,
  phone = EXCLUDED.phone,
  phone2 = EXCLUDED.phone2,
  email = EXCLUDED.email,
  opening_hours = EXCLUDED.opening_hours,
  location = EXCLUDED.location,
  location_precision = EXCLUDED.location_precision,
  services = EXCLUDED.services,
  target_audience = EXCLUDED.target_audience,
  verified_at = EXCLUDED.verified_at,
  verified_by = EXCLUDED.verified_by,
  source_name = EXCLUDED.source_name,
  source_url = EXCLUDED.source_url,
  notes = EXCLUDED.notes,
  is_active = true;

-- 3. Pendências de curadoria já conhecidas -----------------------------------
INSERT INTO public.institution_review_queue (external_key, kind, source_name, source_url, notes)
SELECT v.external_key, CASE WHEN v.external_key = 'cwb-cras-creas' THEN 'novo' ELSE 'reverificacao' END, v.source_name, v.source_url, v.notes
FROM (VALUES
  ('cwb-hospital-trabalhador', 'Prefeitura de Curitiba',
   'https://mulhereigualdade.curitiba.pr.gov.br/conteudo/rede-de-atencao-as-mulheres-em-situacao-de-violencias/12',
   'Confirmar endereço (Av. República Argentina, 4406 x Rua Isaac Guelmann s/n) e telefone.'),
  ('cwb-hc-ufpr', NULL, NULL, 'Conferir coordenada no mapa (aproximada).'),
  ('cwb-evangelico-mackenzie', NULL, NULL, 'Conferir coordenada no mapa (aproximada).'),
  ('cwb-pequeno-principe', NULL, NULL, 'Conferir coordenada e faixa etária atendida.'),
  ('cwb-nucria', NULL, NULL, 'Conferir coordenada e horário de atendimento.'),
  ('cwb-nuciber', NULL, NULL, 'Conferir coordenada e horário de atendimento.'),
  ('cwb-cras-creas', 'FAS Curitiba', 'https://fas.curitiba.pr.gov.br/conteudo.aspx?idf=75',
   'Próxima coleta: importar CRAS e CREAS das regionais.')
) AS v(external_key, source_name, source_url, notes)
WHERE NOT EXISTS (
  SELECT 1 FROM public.institution_review_queue r
  WHERE r.external_key = v.external_key AND r.status = 'pendente'
);

UPDATE public.institution_review_queue r
SET institution_id = i.id
FROM public.institutions i
WHERE r.institution_id IS NULL AND r.external_key = i.external_key;
