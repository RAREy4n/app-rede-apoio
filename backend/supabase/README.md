# Supabase — Rede de Apoio

Piloto atual: **Curitiba/PR**. Contrato da API para o front: [docs/API.md](../../docs/API.md).

## Regras do banco

- **Toda mudança é uma migration nova** em `migrations/`, com nome `AAAAMMDDHHMMSS_descricao.sql`. Nunca edite uma migration que já foi aplicada.
- As migrations são **idempotentes**: rodar de novo não duplica dados nem quebra.
- Tabelas com dados sensíveis (`location_shares`, `institution_review_queue`) têm RLS ativo **sem política pública**. O front só usa as funções RPC.
- Depois de mudar o banco, atualize `docs/API.md` e rode `tests/api_test.sql`.

## Aplicar as migrations

### Opção A — Supabase CLI (recomendado)

```bash
cd backend
supabase login
supabase link --project-ref xozcsujnjzoinqhifgfm
```

**Só na primeira vez, no banco de produção atual:** os antigos `01_schema.sql` a `04_seed_curitiba.sql` já foram aplicados à mão. Marque as migrations equivalentes como aplicadas:

```bash
supabase migration repair --status applied 20260920120000 20260920120100 20260924120000 20260924120100
```

Depois, sempre:

```bash
supabase db push      # aplica só as migrations novas
```

Para um banco local de desenvolvimento: `supabase start` e `supabase db reset` (precisa do Docker).

### Opção B — SQL Editor do painel

Cole e rode, **em ordem**, os arquivos de `migrations/` que ainda não foram aplicados. No banco de produção atual faltam só:

1. `20260925120000_canais_categorias_conteudo.sql`
2. `20260925120100_compartilhamento_localizacao.sql`
3. `20260926120000_rede_curitiba_ippuc.sql` (amplia a rede para ~90 instituições)

Se as duas primeiras já foram aplicadas, rode só a terceira.

### Limpeza automática da localização

A migration de localização tenta agendar a limpeza com **pg_cron** a cada 15 min. Se o painel avisar que o pg_cron não está habilitado, ative em **Database → Extensions → pg_cron** e rode a migration de novo. Mesmo sem pg_cron, a limpeza roda a cada nova sessão criada.

## Testar

Cole `tests/api_test.sql` no SQL Editor e rode. Ele simula o app (papel `anon`), testa todo o contrato e desfaz tudo no final (`ROLLBACK`), então é seguro em produção. O resultado esperado são 4 avisos `ok: ...`. Se algo quebrar, aparece `FALHOU: ...`.

Com o CLI ou psql:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/api_test.sql
```

## Curadoria dos dados (obrigatória em produção)

A base é **curada**: nenhum dado vindo de busca automática é publicado sem revisão humana.

- **Instituições:** cada uma tem `source_name`, `source_url`, `verified_at` e `verified_by`. O app mostra "Verificado em dd/mm/aaaa" ou "Dados a confirmar". Registros sem verificação há mais de 180 dias aparecem na view `institutions_stale`.
- **Fila de revisão:** novas instituições, alterações e reverificações entram em `institution_review_queue` com status `pendente`. Só quem tem a `service_role` (painel/admin) lê e aprova.
- **Coordenadas:** `location_precision = 'aproximada'` indica posição estimada. O app usa o endereço na rota "Como chegar" nesses casos.
- **Canais de emergência:** tabela `emergency_channels`, com fonte e data de verificação.
- **Guias de direitos:** tabela `guides`. `reviewed_at` fica vazio até um profissional da rede de atendimento revisar o texto.
- **Sigilo:** a categoria `casa_abrigo` nunca é retornada. Endereços de abrigos não devem ser cadastrados.

Rotina mensal sugerida:

1. `select * from institutions_stale;` e `select * from institution_review_queue where status = 'pendente';`
2. Conferir cada item na fonte oficial e, se possível, por telefone.
3. Atualizar o registro (`verified_at = now()`, `verified_by = '<nome>'`) e marcar a pendência como `aprovado` ou `rejeitado`.

Para mudar dados em produção, prefira uma migration nova (fica registrado no Git) a editar pelo painel.

## Fontes oficiais usadas no levantamento de Curitiba

**Base principal (25/09/2026):** [IPPUC — GeoCuritiba, Equipamentos Urbanos](https://geocuritiba.ippuc.org.br/server/rest/services/Publico_GeoCuritiba_Equipamentos_Urbanos/MapServer), serviço público de mapas da Prefeitura com endereço, telefone, horário e coordenadas oficiais. Camadas usadas: 34 (CRAS), 38 (CREAS), 105 (Defensoria Pública), 108 (Centro de Referência de Atendimento à Mulher), 129 (Hospitais públicos), 130 (UPAs) e 143 (Polícia Civil). Para atualizar a base, consulte a camada com `/query?where=1%3D1&outFields=*&f=json` e compare com o banco.

**Levantamento inicial (24/09/2026):**

- [Prefeitura — Rede de Atenção às mulheres em situação de violências](https://mulhereigualdade.curitiba.pr.gov.br/conteudo/rede-de-atencao-as-mulheres-em-situacao-de-violencias/12)
- [Prefeitura — Portal Locais: Casa da Mulher Brasileira](https://locais.curitiba.pr.gov.br/centro-de-referencia-de-atendimento-a-mulher-casa-da-mulher-brasileira/2117)
- [TJPR/CEVID — Onde procurar ajuda](https://www.tjpr.jus.br/web/cevid/onde-procurar-ajuda)
- [Polícia Científica do PR — Hospitais de referência em violência sexual](https://www.policiacientifica.pr.gov.br/sites/policia-cientifica/arquivos_restritos/files/documento/2026-04/hospitais_de_referencia-_violencia_sexual-1.pdf)
- [FAS — Endereços dos CRAS](https://fas.curitiba.pr.gov.br/conteudo.aspx?idf=75) (próxima importação)
