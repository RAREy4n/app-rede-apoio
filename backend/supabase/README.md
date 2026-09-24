# Configuração do Supabase — Rede de Apoio

Scripts para o banco no **Supabase** (plano gratuito). Piloto atual: **Curitiba/PR**.

## 1. Criar o projeto

1. Acesse [supabase.com](https://supabase.com) e crie uma conta.
2. Clique em **New Project** e escolha a região `sa-east-1` (São Paulo).
3. Guarde a senha do banco gerada.

## 2. Executar os scripts (SQL Editor → New Query → Run), nesta ordem

| Ordem | Arquivo | O que faz |
| --- | --- | --- |
| 1 | [01_schema.sql](01_schema.sql) | PostGIS, tabelas `institutions` e `guides`, RLS de leitura pública e RPC `nearby_institutions`. |
| 2 | [02_seed.sql](02_seed.sql) | Guias de orientação e instituições de demonstração do antigo piloto SP. |
| 3 | [03_busca_curadoria.sql](03_busca_curadoria.sql) | Busca sem acento (`search_institutions`), campos de fonte/verificação, fila de revisão e bloqueio de Casa-Abrigo. |
| 4 | [04_seed_curitiba.sql](04_seed_curitiba.sql) | Base inicial de Curitiba (fontes oficiais) e desativação dos dados de SP. |

Os scripts 03 e 04 são idempotentes: podem ser executados de novo sem duplicar dados.

## 3. Conectar ao app Flutter

Em **Project Settings → API**, copie a **Project URL** e a **anon key** (pública, protegida por RLS) para `app/lib/core/config/supabase_config.dart`.

O app busca instituições pela RPC:

```dart
final response = await Supabase.instance.client.rpc(
  'search_institutions',
  params: {
    'q': 'delegacia cabral',          // opcional, ignora acentos
    'lat': -25.43, 'lng': -49.27,     // opcional, ordena por distância
    'filter_categories': ['delegacia_mulher', 'delegacia_comum'], // opcional
    'max_results': 30,
  },
);
```

Sem internet, o app usa a lista de contingência em `support_network_service.dart`, que deve espelhar os registros verificados do `04_seed_curitiba.sql`.

## 4. Curadoria dos dados (obrigatória em produção)

A base é **curada**: nenhum dado vindo de busca automática é publicado sem revisão humana.

- **Fonte e verificação:** cada instituição tem `source_name`, `source_url`, `verified_at` e `verified_by`. O app mostra "Verificado em dd/mm/aaaa" ou "Dados a confirmar".
- **Validade:** registros sem verificação há mais de 180 dias aparecem na view `institutions_stale` e o app os marca como possivelmente desatualizados.
- **Fila de revisão:** novas instituições, alterações e reverificações entram em `institution_review_queue` com status `pendente`. Só quem tem a `service_role` (painel/admin) lê e aprova.
- **Coordenadas:** `location_precision = 'aproximada'` indica posição estimada. O app usa o endereço (e não a coordenada) na rota "Como chegar" nesses casos.
- **Sigilo:** a categoria `casa_abrigo` nunca é retornada pela RLS nem pela RPC. Endereços de abrigos não devem ser cadastrados.

Rotina sugerida (mensal):

1. Consultar `select * from institutions_stale;` e as pendências `select * from institution_review_queue where status = 'pendente';`.
2. Conferir cada item na fonte oficial e, se possível, por telefone.
3. Atualizar o registro (`verified_at = now()`, `verified_by = '<nome>'`) e marcar a pendência como `aprovado` ou `rejeitado`.

Fontes oficiais usadas no levantamento de Curitiba (24/09/2026):

- [Prefeitura — Rede de Atenção às mulheres em situação de violências](https://mulhereigualdade.curitiba.pr.gov.br/conteudo/rede-de-atencao-as-mulheres-em-situacao-de-violencias/12)
- [Prefeitura — Portal Locais: Casa da Mulher Brasileira](https://locais.curitiba.pr.gov.br/centro-de-referencia-de-atendimento-a-mulher-casa-da-mulher-brasileira/2117)
- [TJPR/CEVID — Onde procurar ajuda](https://www.tjpr.jus.br/web/cevid/onde-procurar-ajuda)
- [Polícia Científica do PR — Hospitais de referência em violência sexual](https://www.policiacientifica.pr.gov.br/sites/policia-cientifica/arquivos_restritos/files/documento/2026-04/hospitais_de_referencia-_violencia_sexual-1.pdf)
- [FAS — Endereços dos CRAS](https://fas.curitiba.pr.gov.br/conteudo.aspx?idf=75) (próxima importação)
