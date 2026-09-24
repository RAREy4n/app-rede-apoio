# Pendências do MVP

Legenda: `[ ]` pendente, `[x]` concluído.

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
- [ ] Inicializar controle de versão Git, caso desejado.

## Configuração inicial

- [ ] Definir se haverá conta ou somente configuração local no MVP.
- [x] Criar fluxo inicial de cadastro local de pessoa de confiança.
- [x] Cadastrar nome e telefone em interface de demonstração.
- [ ] Persistir o contato localmente com proteção adequada.
- [ ] Criar envio de mensagem de teste.
- [x] Permitir pular configuração e acessar a tela inicial.

## Canais oficiais

- [x] Abrir ligação para 190 com confirmação.
- [x] Abrir ligação ou canal oficial do Ligue 180.
- [ ] Exibir aviso sobre limitações do aplicativo.
- [ ] Testar funcionamento sem internet quando aplicável.

## Localização e contato

- [x] Solicitar permissão de localização somente quando necessária.
- [x] Enviar localização atual por WhatsApp ou SMS.
- [ ] Definir backend para localização temporária.
- [ ] Criar link seguro e expirável.
- [ ] Permitir duração de 15, 30 ou 60 minutos.
- [ ] Permitir encerramento e revogação imediatos.
- [ ] Projetar falhas de GPS, bateria e rede.

## Rede de apoio

- [x] Escolher município ou estado-piloto (São Paulo / Região Metropolitana).
- [x] Definir fonte dos dados (Supabase PostgreSQL + PostGIS).
- [x] Criar modelo de instituição (`SupportInstitution`).
- [x] Implementar prévia visual de mapa com filtros demonstrativos.
- [x] Integrar consulta de dados de instituições verificadas com cálculo de distância (Supabase RPC `nearby_institutions`).
- [x] Implementar tela completa da Rede de Apoio com busca textual, categorias, ação de ligar e rotas no mapa (`SupportNetworkPage`).
- [x] Implementar filtros por serviço e categoria.
- [ ] Exibir data da última verificação.

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
