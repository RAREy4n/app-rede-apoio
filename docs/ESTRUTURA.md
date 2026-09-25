# Estrutura do Projeto

A estrutura de pastas completa e a convenção por funcionalidade estão em [ARQUITETURA.md](ARQUITETURA.md), seção 5.

Resumo:

```text
app-rede-apoio/
├── app/                 # App Flutter
│   ├── lib/api.dart     # Camada de dados: único import que as telas usam
│   ├── lib/core/        # Configuração, conteúdo, serviços do aparelho, tema
│   └── lib/features/    # Cada funcionalidade: data/ domain/ presentation/
├── backend/supabase/    # Migrations (banco + API) e testes
├── landing-page/        # Landing page e página /acompanhar
└── docs/                # Arquitetura, API, escopo e pendências
```

Regra: `data/` e `domain/` ficam prontos para o front; `presentation/` é onde o front trabalha. Crie camadas só quando houver código real.
