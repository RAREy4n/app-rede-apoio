> **ARQUIVADO (25/09/2026).** Esta API Node/Express não é usada pelo app. O backend oficial é o Supabase em `backend/supabase/` (veja `backend/README.md`). Pontos conhecidos: o módulo de localização usava o mesmo token para enviar e para ver a posição (falha de segurança) e exigia hospedar Node + Redis. Mantido só como referência; pode ser apagado.

# Backend — Rede de Apoio

API para a rede de proteção, localização temporária e conteúdo informativo.

## Stack

- **Node.js** + **Express** + **TypeScript**
- **PostgreSQL** + **PostGIS** (busca geoespacial)
- **Redis** (sessões de localização temporária)
- **Socket.IO** (localização em tempo real)
- **Zod** (validação de entrada)

## Pré-requisitos

- Node.js >= 20
- PostgreSQL com extensão PostGIS
- Redis

## Configuração

```bash
# 1. Instalar dependências
npm install

# 2. Copiar variáveis de ambiente
cp .env.example .env
# Editar .env com suas credenciais

# 3. Criar banco e habilitar PostGIS
psql -U postgres -c "CREATE DATABASE rede_apoio;"
psql -U postgres -d rede_apoio -c "CREATE EXTENSION IF NOT EXISTS postgis;"
psql -U postgres -d rede_apoio -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

# 4. Executar schema e seed
npm run seed

# 5. Iniciar servidor
npm run dev
```

## Endpoints

### Instituições

```
GET  /api/v1/institutions/nearby?lat=-23.55&lng=-46.63&radius=5000&category=delegacia_mulher
GET  /api/v1/institutions/search?q=delegacia&state=SP&city=São Paulo
GET  /api/v1/institutions/categories
GET  /api/v1/institutions/:id
```

### Conteúdo

```
GET  /api/v1/content/guides
GET  /api/v1/content/guides/:slug
```

### Localização temporária

```
POST /api/v1/location/share    { duration_min: 30, label: "..." }
POST /api/v1/location/revoke   { token: "uuid" }
GET  /api/v1/location/status?token=uuid
WS   /ws?token=uuid            (Socket.IO)
```

### Health check

```
GET  /api/health
```

## Restrições obrigatórias

- Não guardar localização contínua por padrão.
- Não guardar evidências sem base legal e revisão.
- Não enviar dados a órgãos públicos sem parceria oficial.
- LGPD, minimização de dados e revogação de consentimento desde o início.

## Estrutura

```
src/
├── app.ts                    # Entry point
├── config/
│   ├── database.ts           # Pool PostgreSQL
│   └── redis.ts              # Cliente Redis
├── modules/
│   ├── institutions/         # CRUD e busca geoespacial
│   ├── content/              # Orientações e direitos
│   └── location/             # Compartilhamento temporário
└── scripts/
    ├── schema.sql            # Schema do banco
    └── seed.ts               # Dados iniciais
```
