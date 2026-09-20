# Guia para agentes de desenvolvimento

Este arquivo é o ponto de entrada para qualquer IA ou desenvolvedor que for continuar o projeto.

## Contexto rápido

**Rede de Apoio** é um projeto extensionista brasileiro para facilitar o acesso de mulheres à rede de proteção, a contatos de confiança e a canais oficiais. É uma ferramenta de orientação e conexão; não substitui polícia, Justiça, saúde, assistência social ou atendimento humano especializado.

Leia também:

- [README.md](README.md): visão geral, execução e fluxo de interface.
- [docs/AMBIENTE-ANDROID.md](docs/AMBIENTE-ANDROID.md): instalação, emulador, validação e diagnóstico do Android.
- [docs/CONTEXTO-PARA-IAS.md](docs/CONTEXTO-PARA-IAS.md): produto, limites e decisões.
- [docs/ESCOPO.md](docs/ESCOPO.md): recorte acadêmico e MVP.
- [docs/PENDENCIAS.md](docs/PENDENCIAS.md): trabalho pendente e prioridades.

## Estado atual

- O aplicativo Flutter em `app/` funciona no Android e foi validado no emulador `medium_phone`.
- Há uma primeira interface de onboarding e início; ela usa conteúdo de demonstração.
- A landing page React em `landing-page/` ainda não foi inicializada.
- O backend em `backend/` ainda não foi implementado.
- Não há integração real com WhatsApp, localização, SOS, boletim de ocorrência ou APIs governamentais.

## Regras inegociáveis de segurança

1. A ajuda imediata não pode depender de login, cadastro ou internet.
2. Nunca alegar que uma ação automática acionou polícia, emergência ou boletim de ocorrência.
3. Localização só pode ser coletada e compartilhada mediante consentimento explícito, específico e revogável.
4. Não persistir localização contínua, relatos, documentos ou evidências sem arquitetura de segurança, LGPD, retenção mínima e revisão humana.
5. Falhas de rede, permissões e integrações são estados normais da interface e devem ter uma saída segura.
6. Não prometer “invisibilidade total” diante de um agressor; comunicar os limites de segurança com honestidade.
7. Integrações com órgãos públicos dependem de parceria, canal oficial e validação jurídica/técnica. Não simular esse envio.

## Convenções técnicas

- Flutter: organize código em `app/lib/features/`, `app/lib/core/` e `app/lib/app/`.
- Landing page: React com JavaScript, em `landing-page/`.
- Todo pacote novo exige justificativa de privacidade, manutenção e licença.
- Não versionar APKs, caches, arquivos locais do Android, chaves, tokens ou arquivos `.env`.
- Antes de concluir uma mudança Flutter, rode `flutter analyze` e `flutter test` dentro de `app/`.
- Atualize `docs/PENDENCIAS.md` quando uma etapa for concluída ou o escopo mudar.

## Próxima entrega recomendada

Construir a tela local de **Pessoa de confiança**: nome, telefone, revisão das permissões e opção de pular. Nesta etapa, não integrar GPS, WhatsApp, backend ou envio real de alertas.
