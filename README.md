# Rede de Apoio

Projeto extensionista para facilitar o acesso de mulheres à rede de proteção, a contatos de confiança e a canais oficiais. A proposta é orientar e conectar: o produto **não substitui** polícia, Justiça, saúde, assistência social ou atendimento humano especializado.

## Estado atual

| Área | Situação |
| --- | --- |
| Aplicativo Flutter | Estrutura funcional, com onboarding e tela inicial demonstrativos. |
| Android | SDK, emulador e build validados localmente. |
| Landing page React | Planejada, ainda não inicializada. |
| Backend | Planejado, ainda não implementado. |
| Integrações sensíveis | Não existem integrações reais com SOS, WhatsApp, GPS, BO ou órgãos públicos. |

## Estrutura

```text
app-rede-apoio/
├── app/             # Aplicativo Flutter/Dart
├── landing-page/    # Futura landing page React/JavaScript
├── backend/         # Futura API e regras de negócio
├── docs/            # Escopo, contexto e pendências
├── AGENTS.md        # Instruções para IAs e colaboradores
└── README.md        # Visão geral do projeto
```

## Executar o aplicativo Android

Pré-requisitos: Flutter, Android Studio/SDK e o emulador `medium_phone` configurados.

```powershell
cd C:\projetos\app-rede-apoio\app
flutter pub get
flutter emulators --launch medium_phone
flutter run -d emulator-5554
```

Comandos úteis:

```powershell
flutter devices
flutter analyze
flutter test
flutter build apk --debug
```

O APK gerado é somente um artefato local de desenvolvimento e não deve ser enviado ao Git.

Para instalar ou recuperar todo o ambiente de testes Android, consulte o [guia completo de Android Studio e emulador](docs/AMBIENTE-ANDROID.md).

## Fluxo inicial de interface

```mermaid
flowchart TD
    A[Abertura do aplicativo] --> B[Onboarding]
    B -->|Configurar agora| C[Pessoa de confiança\nplanejado]
    B -->|Acessar ajuda agora| D[Início]
    C --> D
    D --> E[Emergência\nligação 190 planejada]
    D --> F[Pessoa de confiança]
    D --> G[Rede de apoio]
    D --> H[Orientações e direitos]
    G --> I[Mapa e lista de serviços\nplanejado]
    F --> J[Compartilhamento com consentimento\nplanejado]
    E --> K[Canal oficial]
    H --> K
```

O acesso a ajuda imediata deve permanecer disponível sem login. Itens marcados como “planejado” não devem ser apresentados como funcionais até terem implementação, validação e testes de segurança.

## Tecnologias

- **Mobile:** Flutter e Dart.
- **Landing page:** React e JavaScript.
- **Backend:** a definir após a validação do MVP e dos requisitos de LGPD, segurança e operação.

## Segurança e limites do produto

- Localização e alertas só podem existir com consentimento explícito, revogável e informado.
- Não prometer acionamento automático de polícia, emergência ou boletim de ocorrência.
- Integrações com governos e canais oficiais exigem parceria e validação jurídica/técnica.
- Não coletar ou manter dados sensíveis sem necessidade clara, proteção adequada e política de retenção.

## Documentação para continuar o projeto

- [Guia para IAs e colaboradores](AGENTS.md)
- [Ambiente Android e testes](docs/AMBIENTE-ANDROID.md)
- [Escopo do projeto](docs/ESCOPO.md)
- [Contexto detalhado para IAs](docs/CONTEXTO-PARA-IAS.md)
- [Estrutura do repositório](docs/ESTRUTURA.md)
- [Pendências e prioridades](docs/PENDENCIAS.md)
