# Configuração do Supabase — Rede de Apoio

Este diretório contém os scripts necessários para rodar o banco de dados no **Supabase** (plano gratuito).

---

## 1. Criar o Projeto no Supabase
1. Acesse [supabase.com](https://supabase.com) e crie uma conta gratuita.
2. Clique em **"New Project"**.
3. Escolha uma região próxima (ex: `sa-east-1` São Paulo).
4. Guarde a senha do banco gerada.

---

## 2. Executar os Scripts SQL
No menu lateral do Dashboard do Supabase:
1. Vá em **SQL Editor** -> **New Query**.
2. Cole o conteúdo de [01_schema.sql](file:///c:/projetos/app-rede-apoio/backend/supabase/01_schema.sql) e clique em **Run**.
   - Isso habilita a extensão **PostGIS**, cria as tabelas `institutions` e `guides`, ativa as políticas de segurança (RLS - somente leitura pública) e cria a função de busca geoespacial `nearby_institutions`.
3. Cole o conteúdo de [02_seed.sql](file:///c:/projetos/app-rede-apoio/backend/supabase/02_seed.sql) e clique em **Run**.
   - Isso popula instituições de exemplo e os guias práticos sobre direitos e emergência.

---

## 3. Conectar ao Aplicativo Flutter
No Dashboard do Supabase:
1. Vá em **Project Settings** -> **API**.
2. Copie:
   - **Project URL** (ex: `https://xyzcompany.supabase.co`)
   - **anon / public key** (chave de API pública, segura para ficar no app mobile)

No Flutter, a busca por instituições próximas é feita diretamente chamando a função RPC:
```dart
final response = await Supabase.instance.client.rpc(
  'nearby_institutions',
  params: {
    'lat': userLatitude,
    'lng': userLongitude,
    'radius_meters': 5000,
  },
);
```
