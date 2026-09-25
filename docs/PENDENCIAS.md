# Pendências do MVP

Legenda: `[ ]` pendente, `[x]` concluído.

## Arquitetura

- [x] Backend só Supabase, organizado em migrations (`backend/supabase/`).
- [x] Contrato da API para o front (`docs/API.md`) e camada de dados (`app/lib/api.dart`).
- [x] Testes do contrato (`backend/supabase/tests/api_test.sql`).
- [ ] Aplicar as migrations novas no Supabase de produção.
- [x] Rodar `flutter pub get`, `flutter analyze` e `flutter test` com a nova camada de dados (31 testes passando).
- [x] Tela de direitos e orientações (`GuidancePage` + `GuideDetailPage`), com aviso de revisão e cache offline.
- [ ] Confirmar no Chrome a correção da tela branca (botões em `Row` com largura infinita do tema).
- [ ] Testar o app completo no emulador ou celular Android após as últimas mudanças.
- [x] README com fluxograma do estado atual.
- [ ] Revisão dos guias de direitos por profissional da rede (`guides.reviewed_at`).

## Base do projeto

- [x] Definir escopo inicial.
- [x] Definir Flutter/Dart para o app.
- [x] Definir React/JavaScript para a landing page.
- [x] Criar estrutura inicial do código Flutter.
- [x] Criar tema e telas iniciais.
- [x] Instalar Flutter SDK e Dart no ambiente.
- [x] Executar `flutter doctor`.
- [x] Gerar projeto nativo Android.
- [ ] Gerar projeto nativo iOS (requer macOS para compilação e teste).
- [x] Executar testes e análise estática.
- [x] Instalar Android Studio e Android SDK.
- [x] Aceitar as licenças do Android SDK.
- [x] Criar emulador Android.
- [x] Gerar e instalar APK de teste no emulador.
- [x] Inicializar controle de versão Git.

## Configuração inicial

- [x] Definir se haverá conta ou somente configuração local no MVP (sem conta; pessoa de confiança só no aparelho).
- [x] Criar fluxo inicial de cadastro local de pessoa de confiança.
- [x] Cadastrar nome e telefone em interface de demonstração.
- [x] Camada de dados para persistir o contato com criptografia (`TrustedContactRepository`).
- [ ] Tela de cadastro usar `TrustedContactRepository` (front).
- [ ] Criar envio de mensagem de teste.
- [ ] "Enviar localização" da Home usar o contato salvo.
- [x] Permitir pular configuração e acessar a tela inicial.

## Canais oficiais

- [x] Abrir ligação para 190 com confirmação.
- [x] Abrir ligação ou canal oficial do Ligue 180.
- [x] Canais de emergência vindos da API com cache offline (`get_app_bootstrap`).
- [x] Corrigir abertura do discador no Android 11+ (manifest + sem `canLaunchUrl`).
- [ ] Exibir aviso sobre limitações do aplicativo.
- [ ] Testar funcionamento sem internet quando aplicável.

## Localização e contato

- [x] Solicitar permissão de localização somente quando necessária.
- [x] Enviar localização atual por WhatsApp ou SMS.
- [x] Definir backend para localização temporária (Supabase, RPCs `location_share_*`).
- [x] Criar link seguro e expirável (tokens separados de envio e visualização).
- [x] Permitir duração de 15, 30 ou 60 minutos (`LocationShareController`).
- [x] Permitir encerramento e revogação imediatos.
- [ ] Criar e hospedar a página `/acompanhar`.
- [ ] Tela "Avisar pessoa de confiança" com confirmação (front).
- [ ] Envio em segundo plano (serviço em primeiro plano no Android).
- [ ] Projetar falhas de GPS, bateria e rede.

## Rede de apoio

- [x] Escolher município ou estado-piloto (**Curitiba/PR** — substituiu o piloto inicial de São Paulo).
- [x] Definir fonte dos dados (Supabase PostgreSQL + PostGIS).
- [x] Criar modelo de instituição (`SupportInstitution`).
- [x] Implementar prévia visual de mapa com filtros demonstrativos.
- [x] Mapa OpenStreetMap real na Home, com filtros, localização sob demanda e tela cheia.
- [ ] Trocar o servidor de tiles do OSM por um provedor adequado antes de divulgar (`MAP_TILE_URL`).
- [x] Integrar consulta de dados de instituições verificadas com cálculo de distância (Supabase RPC `nearby_institutions`).
- [x] Implementar tela completa da Rede de Apoio com busca textual, categorias, ação de ligar e rotas no mapa (`SupportNetworkPage`).
- [x] Implementar filtros por serviço e categoria.
- [x] Exibir data da última verificação e fonte oficial de cada instituição.
- [x] Busca no servidor sem acento (RPC `search_institutions`, `03_busca_curadoria.sql`).
- [x] Base inicial de Curitiba a partir de fontes oficiais (`04_seed_curitiba.sql`).
- [x] Lista offline de contingência com dados de Curitiba verificados.
- [x] Fila de revisão humana (`institution_review_queue`) e view `institutions_stale`.
- [ ] Confirmar por telefone os contatos da base de Curitiba e registrar `verified_by`.
- [x] Coordenadas oficiais do IPPUC para 87 registros; restam 2 aproximadas (Evangélico Mackenzie e Pequeno Príncipe).
- [ ] Conferir no mapa as 2 coordenadas ainda marcadas como `aproximada`.
- [x] Resolver divergência de endereço do Hospital do Trabalhador (confirmado pelo IPPUC).
- [x] Importar CRAS (39), CREAS (10), UPAs (9), delegacias (14), Defensoria (9) e CRAM CIC do IPPUC (`20260926120000_rede_curitiba_ippuc.sql`).
- [ ] Aplicar a migration `20260926120000_rede_curitiba_ippuc.sql` no Supabase de produção.
- [ ] Confirmar os telefones da Delegacia da Mulher (IPPUC e Prefeitura divergem).
- [ ] Criar coleta programada (mensal) que compara fontes oficiais e abre pendências.
- [ ] Criar painel simples para aprovar/rejeitar pendências da fila.

## Privacidade e segurança

- [ ] Elaborar política de privacidade.
- [ ] Definir retenção e exclusão de dados.
- [ ] Definir notificações neutras.
- [ ] Implementar botão de saída rápida.
- [ ] Definir opções predefinidas de modo discreto.
- [ ] Fazer revisão LGPD.
- [ ] Realizar testes de abuso e exposição de dados.

## Landing page

- [ ] Inicializar React com JavaScript.
- [ ] Criar apresentação do projeto.
- [ ] Adicionar links oficiais 190 e 180.
- [ ] Criar seção de privacidade.
- [ ] Preparar QR Code e links das lojas.
- [ ] Criar formulário de interesse para instituições.

## Validação extensionista

- [ ] Identificar organizações parceiras.
- [ ] Entrevistar profissionais da rede de atendimento.
- [ ] Validar linguagem e fluxos.
- [ ] Testar acessibilidade.
- [ ] Definir métricas de impacto.
- [ ] Documentar resultados para apresentação acadêmica.
