# Estrutura do Projeto

```text
app-rede-apoio/
├── app/                         # Aplicativo Flutter
│   ├── lib/
│   │   ├── app/                 # Configuração do aplicativo
│   │   ├── core/                # Tema e componentes compartilhados
│   │   └── features/            # Funcionalidades isoladas
│   │       ├── onboarding/
│   │       ├── home/
│   │       ├── trusted_contact/
│   │       ├── support_network/
│   │       └── guidance/
│   └── test/                    # Testes Flutter
├── landing-page/                # Landing page React/JavaScript
├── docs/                        # Escopo e decisões
└── README.md
```

## Regra de organização do app

Cada funcionalidade deve permanecer em sua pasta dentro de `features`. Conforme o projeto crescer, uma funcionalidade pode receber:

```text
feature/
├── data/          # APIs, armazenamento e modelos externos
├── domain/        # Regras e entidades de negócio
└── presentation/  # Telas, componentes e estado da interface
```

No MVP, só criaremos essas camadas quando houver código real para evitar pastas vazias e complexidade prematura.
