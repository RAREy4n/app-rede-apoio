-- ============================================================================
-- Rede de Apoio — Migration: guias iniciais (parte de conteúdo do antigo 02_seed.sql)
-- As instituições de demonstração de São Paulo do 02_seed.sql NÃO foram trazidas:
-- o piloto agora é Curitiba (ver migration base_curitiba).
-- Idempotente (ON CONFLICT no slug).
-- ============================================================================

-- Guias de orientação e direitos (conteúdo original aplicado em produção).
-- Revisões de conteúdo ficam em migrations posteriores.

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
