# Guia para agentes de desenvolvimento

Este arquivo é o ponto de entrada para qualquer IA ou desenvolvedor que for continuar o projeto.

## Contexto rápido

**Rede de Apoio** é um projeto extensionista brasileiro para facilitar o acesso de mulheres à rede de proteção, a contatos de confiança e a canais oficiais. É uma ferramenta de orientação e conexão; não substitui polícia, Justiça, saúde, assistência social ou atendimento humano especializado.

Leia também:

- [README.md](README.md): visão geral, execução e fluxo de interface.
- [docs/ARQUITETURA.md](docs/ARQUITETURA.md): arquitetura, decisões e funcionalidades.
- [docs/API.md](docs/API.md): contrato da API que o front consome.
- [docs/AMBIENTE-ANDROID.md](docs/AMBIENTE-ANDROID.md): instalação, emulador, validação e diagnóstico do Android.
- [docs/CONTEXTO-PARA-IAS.md](docs/CONTEXTO-PARA-IAS.md): produto, limites e decisões.
- [docs/ESCOPO.md](docs/ESCOPO.md): recorte acadêmico e MVP.
- [docs/PENDENCIAS.md](docs/PENDENCIAS.md): trabalho pendente e prioridades.

## Estado atual

- Backend 100% Supabase em `backend/supabase/migrations/` (a API Node em `backend/legacy-node/` está arquivada).
- Camada de dados do app pronta em `app/lib/api.dart`: rede de apoio, canais de emergência, guias, pessoa de confiança (só no aparelho) e localização ao vivo.
- Telas existentes: onboarding, início, cadastro de pessoa de confiança (ainda sem salvar) e rede de apoio.
- Piloto: Curitiba/PR.
- Não há integração com polícia, BO ou órgãos públicos.

## Regras inegociáveis de segurança

1. A ajuda imediata não pode depender de login, cadastro ou internet.
2. Nunca alegar que uma ação automática acionou polícia, emergência ou boletim de ocorrência.
3. Localização só pode ser coletada e compartilhada mediante consentimento explícito, específico e revogável.
4. Não persistir localização contínua, relatos, documentos ou evidências sem arquitetura de segurança, LGPD, retenção mínima e revisão humana.
5. Falhas de rede, permissões e integrações são estados normais da interface e devem ter uma saída segura.
6. Não prometer “invisibilidade total” diante de um agressor; comunicar os limites de segurança com honestidade.
7. Integrações com órgãos públicos dependem de parceria, canal oficial e validação jurídica/técnica. Não simular esse envio.

## Convenções técnicas

- Flutter: organize código em `app/lib/features/`, `app/lib/core/` e `app/lib/app/`. Em cada feature: `data/` (acesso a dados), `domain/` (modelos) e `presentation/` (telas).
- Telas só usam o que está exportado em `app/lib/api.dart`; não chamam o Supabase diretamente.
- Banco: toda mudança é uma migration nova em `backend/supabase/migrations/`; atualize `docs/API.md` e rode `backend/supabase/tests/api_test.sql`.
- Landing page: React com JavaScript, em `landing-page/`.
- Todo pacote novo exige justificativa de privacidade, manutenção e licença.
- Não versionar APKs, caches, arquivos locais do Android, chaves, tokens ou arquivos `.env`.
- Antes de concluir uma mudança Flutter, rode `flutter analyze` e `flutter test` dentro de `app/`.
- Atualize `docs/PENDENCIAS.md` quando uma etapa for concluída ou o escopo mudar.

## Próxima entrega recomendada

Telas do front consumindo `lib/api.dart` (ver docs/ARQUITETURA.md, seção 4): mapa da rede de apoio, botão de emergência com canais do bootstrap, salvar a pessoa de confiança, tela "Avisar pessoa de confiança" com confirmação e botão de parar, tela de direitos e saída rápida. Também criar a página web `/acompanhar`.
