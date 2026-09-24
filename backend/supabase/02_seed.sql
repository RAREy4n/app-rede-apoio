-- ============================================================================
-- Rede de Apoio — Seed Data Supabase
-- Execute no SQL Editor do Supabase Dashboard após rodar o 01_schema.sql
-- ============================================================================

-- 1. INSTITUIÇÕES DE DEMONSTRAÇÃO (Região de São Paulo — Piloto)
-- Substituir por dados verificados do município-alvo na fase de produção

INSERT INTO public.institutions (name, category, address, city, state, zip_code, phone, location, services, opening_hours, verified_at)
VALUES
(
  'DEAM Centro — Delegacia da Mulher',
  'delegacia_mulher',
  'Rua Dr. Falcão Filho, 100 - Centro',
  'São Paulo',
  'SP',
  '01007-010',
  '(11) 3101-1234',
  ST_SetSRID(ST_MakePoint(-46.6380, -23.5437), 4326)::geography,
  ARRAY['boletim_ocorrencia', 'medida_protetiva', 'acolhimento'],
  '{"seg": "24h", "ter": "24h", "qua": "24h", "qui": "24h", "sex": "24h", "sab": "24h", "dom": "24h"}'::jsonb,
  NOW()
),
(
  '1ª DDM — Delegacia de Defesa da Mulher',
  'delegacia_mulher',
  'Rua Augusta, 235 - Consolação',
  'São Paulo',
  'SP',
  '01305-000',
  '(11) 3151-5678',
  ST_SetSRID(ST_MakePoint(-46.6558, -23.5519), 4326)::geography,
  ARRAY['boletim_ocorrencia', 'medida_protetiva'],
  '{"seg": "08:00-18:00", "ter": "08:00-18:00", "qua": "08:00-18:00", "qui": "08:00-18:00", "sex": "08:00-18:00"}'::jsonb,
  NOW()
),
(
  'CREAS Centro',
  'creas',
  'Rua Libero Badaró, 600 - Centro',
  'São Paulo',
  'SP',
  '01008-000',
  '(11) 3104-5678',
  ST_SetSRID(ST_MakePoint(-46.6350, -23.5470), 4326)::geography,
  ARRAY['acolhimento', 'orientacao_juridica', 'atendimento_psicologico'],
  '{"seg": "08:00-17:00", "ter": "08:00-17:00", "qua": "08:00-17:00", "qui": "08:00-17:00", "sex": "08:00-17:00"}'::jsonb,
  NOW()
),
(
  'CRAS Sé',
  'cras',
  'Rua Álvares Penteado, 100 - Centro',
  'São Paulo',
  'SP',
  '01012-000',
  '(11) 3101-0000',
  ST_SetSRID(ST_MakePoint(-46.6345, -23.5450), 4326)::geography,
  ARRAY['cadastro_unico', 'beneficios', 'orientacao_social'],
  '{"seg": "08:00-17:00", "ter": "08:00-17:00", "qua": "08:00-17:00", "qui": "08:00-17:00", "sex": "08:00-17:00"}'::jsonb,
  NOW()
),
(
  'Defensoria Pública do Estado de SP — Núcleo da Mulher',
  'defensoria',
  'Rua Boa Vista, 200 - Centro',
  'São Paulo',
  'SP',
  '01014-000',
  '(11) 3105-1234',
  ST_SetSRID(ST_MakePoint(-46.6332, -23.5455), 4326)::geography,
  ARRAY['orientacao_juridica', 'medida_protetiva', 'divorcio'],
  '{"seg": "09:00-17:00", "ter": "09:00-17:00", "qua": "09:00-17:00", "qui": "09:00-17:00", "sex": "09:00-17:00"}'::jsonb,
  NOW()
),
(
  'Hospital Municipal Dr. Cármino Caricchio',
  'hospital',
  'Av. Celso Garcia, 4815 - Tatuapé',
  'São Paulo',
  'SP',
  '03063-000',
  '(11) 2799-0000',
  ST_SetSRID(ST_MakePoint(-46.5720, -23.5360), 4326)::geography,
  ARRAY['urgencia', 'atendimento_vitimas_violencia'],
  '{"seg": "24h", "ter": "24h", "qua": "24h", "qui": "24h", "sex": "24h", "sab": "24h", "dom": "24h"}'::jsonb,
  NOW()
),
(
  'Centro de Referência da Mulher — Casa Eliane de Grammont',
  'centro_referencia',
  'Rua Dr. Bittencourt Rodrigues, 200 - Sé',
  'São Paulo',
  'SP',
  '01020-040',
  '(11) 3106-1234',
  ST_SetSRID(ST_MakePoint(-46.6310, -23.5490), 4326)::geography,
  ARRAY['atendimento_psicologico', 'orientacao_juridica', 'grupo_apoio'],
  '{"seg": "08:00-17:00", "ter": "08:00-17:00", "qua": "08:00-17:00", "qui": "08:00-17:00", "sex": "08:00-17:00"}'::jsonb,
  NOW()
),
(
  'Ministério Público — Promotoria de Violência Doméstica',
  'ministerio_publico',
  'Rua Riachuelo, 115 - Sé',
  'São Paulo',
  'SP',
  '01007-000',
  '(11) 3103-0000',
  ST_SetSRID(ST_MakePoint(-46.6370, -23.5480), 4326)::geography,
  ARRAY['denuncia', 'medida_protetiva', 'acompanhamento_processo'],
  '{"seg": "09:00-18:00", "ter": "09:00-18:00", "qua": "09:00-18:00", "qui": "09:00-18:00", "sex": "09:00-18:00"}'::jsonb,
  NOW()
);

-- 2. GUIAS DE ORIENTAÇÃO E DIREITOS

INSERT INTO public.guides (slug, title, icon, summary, content, category, priority)
VALUES
(
  'emergencia',
  'Em caso de emergência',
  '🔴',
  'Saiba o que fazer em uma situação de risco imediato.',
  '# Em caso de emergência

## Risco imediato? Ligue 190.
O **190** é o número da Polícia Militar. A ligação é gratuita e funciona 24 horas.

### O que falar:
- Diga que precisa de ajuda.
- Informe seu endereço ou localização, se souber.
- Descreva brevemente a situação.
- Se não puder falar, mantenha a linha aberta — a central pode rastrear a chamada.

## Precisa de orientação? Ligue 180.
O **Ligue 180** é a Central de Atendimento à Mulher:
- Funciona **24 horas**, **7 dias por semana**.
- A ligação é **gratuita e sigilosa**.
- Orienta sobre direitos, serviços de proteção e como denunciar.

## Não está em risco imediato?
Se você está planejando sair de uma situação de violência, veja o guia "Plano de segurança". Cada passo conta.',
  'emergencia',
  100
),
(
  'boletim-de-ocorrencia',
  'Como fazer um Boletim de Ocorrência',
  '📋',
  'Passo a passo para registrar um B.O. presencial ou online.',
  '# Como fazer um Boletim de Ocorrência

## Presencial
1. Vá a uma **Delegacia da Mulher (DEAM)** ou a qualquer delegacia.
2. Relate o ocorrido com o máximo de detalhes.
3. Peça a **medida protetiva** no momento do registro (é seu direito).
4. Guarde uma cópia do B.O.

## Online
Muitos estados contam com Delegacia Eletrônica para casos de violência doméstica.
> **Atenção:** Em casos de risco iminente ou agressão física recente, vá presencialmente ou acione o 190.',
  'direitos',
  90
),
(
  'medida-protetiva',
  'Medida Protetiva de Urgência',
  '🛡️',
  'O que é, como pedir e o que esperar da medida protetiva.',
  '# Medida Protetiva de Urgência

## O que é?
Uma ordem judicial que protege você do agressor, determinando:
- Afastamento do agressor do lar
- Proibição de contato e aproximação
- Distância mínima obrigatória

## Como pedir?
- Na delegacia ao fazer o B.O.
- Na Defensoria Pública
- No Ministério Público

**Você não precisa de advogado particular para pedir medida protetiva.**',
  'direitos',
  85
),
(
  'lei-maria-da-penha',
  'Seus Direitos — Lei Maria da Penha',
  '⚖️',
  'Conheça os tipos de violência e seus direitos garantidos por lei.',
  '# Lei Maria da Penha (Lei nº 11.340/2006)

## Tipos de violência reconhecidos:
- **Física:** agressões corporais, empurrões, socos.
- **Psicológica:** humilhação, isolamento, ameaça, perseguição.
- **Sexual:** relação sem consentimento, coerção.
- **Patrimonial:** retenção de documentos, destruição de bens, controle financeiro.
- **Moral:** calúnia, injúria e difamação.',
  'direitos',
  80
),
(
  'apoio-financeiro',
  'Apoio Financeiro e Benefícios',
  '💰',
  'Benefícios e programas socioassistenciais para recomeçar.',
  '# Apoio Financeiro

## CRAS — Porta de Entrada
Procure o CRAS para inscrição no **CadÚnico** e acesso a programas sociais:
- Bolsa Família
- Auxílio-aluguel (disponível em alguns municípios para mulheres com medida protetiva)
- Afastamento remunerado do trabalho previsto na Lei Maria da Penha (até 6 meses via benefício previdenciário).',
  'financeiro',
  75
),
(
  'seguranca-digital',
  'Segurança Digital no Celular',
  '📱',
  'Cuidados com o celular e proteção de informações confidenciais.',
  '# Segurança Digital

- Apague históricos e registros de pesquisas sobre suporte e violência.
- Use guias anônimas.
- Ative verificação em duas etapas no WhatsApp.
- Esteja atenta a aplicativos espiões.
- **Aviso:** Nenhum aplicativo é 100% invisível em um aparelho nas mãos de terceiros.',
  'seguranca',
  65
)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  icon = EXCLUDED.icon,
  summary = EXCLUDED.summary,
  content = EXCLUDED.content,
  category = EXCLUDED.category,
  priority = EXCLUDED.priority,
  updated_at = now();
