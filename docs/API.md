# API do Rede de Apoio — guia para o front

Tudo o que o front precisa para construir as telas. O backend é o Supabase; **o front não escreve SQL nem acessa tabelas diretamente**.

- **App Flutter:** importe só `package:rede_apoio/api.dart` e use as classes da seção 2.
- **Página web `/acompanhar`:** use a chamada HTTP da seção 3.
- Visão geral e fluxos: [ARQUITETURA.md](ARQUITETURA.md).

## 1. Conexão

| Item | Valor |
| --- | --- |
| URL | `https://xozcsujnjzoinqhifgfm.supabase.co` |
| Chave | `anon` (pública; está em `app/lib/core/config/supabase_config.dart`) |
| RPC via HTTP | `POST {URL}/rest/v1/rpc/<nome_da_funcao>` com headers `apikey: <anon>` e `Content-Type: application/json` |

O app já inicializa o Supabase em `main.dart` (`SupabaseConfig.initialize()`). Sem internet, todas as classes abaixo têm um comportamento offline definido.

## 2. App Flutter — classes prontas

```dart
import 'package:rede_apoio/api.dart';
```

### 2.1 Conteúdo inicial: canais de emergência, categorias e guias

Chame uma vez ao abrir o app (ex.: na Home). Funciona offline: servidor → cache do aparelho → versão embutida.

```dart
final conteudo = await AppContentRepository.instance.carregar();

conteudo.origin;                // ContentOrigin.servidor | cache | embutido
conteudo.primaryEmergency;      // EmergencyChannel do 190
conteudo.emergencyChannels;     // List<EmergencyChannel>, já ordenada
conteudo.filterGroups;          // {'delegacias': 'Delegacias', 'acolhimento': 'Acolhimento', ...}
conteudo.categoriesOfGroup('delegacias'); // ['delegacia_mulher', 'delegacia_comum']
conteudo.guides;                // List<Guide>, por prioridade
conteudo.guideBySlug('medida-protetiva');
```

`EmergencyChannel`: `id`, `name`, `phone`, `whatsapp`, `description`, `whenToUse`, `kind` (`emergencia|orientacao|saude|protecao`), `is24h`, `sourceUrl`.

`Guide`: `slug`, `title`, `icon` (emoji), `summary`, `content` (**Markdown**), `category`, `sourceName`, `sourceUrl`, `reviewedAt` (`null` = aguardando revisão profissional; mostrar aviso), `isReviewed`.

`InstitutionCategory`: `id`, `label`, `filterGroup`, `filterGroupLabel`, `iconKey` (`police|heart|law|health` — o front escolhe o ícone).

Para renderizar o Markdown dos guias, o front pode adicionar um pacote como `flutter_markdown` (justificar no PR, conforme AGENTS.md).

### 2.2 Botão de emergência

```dart
// Com confirmação (obrigatório no botão principal):
final abriu = await EmergencyService.confirmarELigar190(context);

// Qualquer canal vindo do conteúdo:
final ok = await EmergencyService.discar(canal.phone!);
if (!ok) { /* OBRIGATÓRIO: mostrar o número grande para discagem manual */ }

// WhatsApp do Ligue 180:
await ContactMessenger.abrirWhatsApp(canal.whatsapp!, 'Olá, preciso de orientação.');
```

### 2.3 Rede de apoio (instituições)

```dart
final resultado = await SupportNetworkService.buscarInstituicoes(
  texto: 'delegacia',                         // opcional; ignora acentos
  categorias: conteudo.categoriesOfGroup('delegacias'), // opcional; [] = todas
  lat: posicao?.latitude, lng: posicao?.longitude,      // opcional; ordena por distância
);
resultado.offline;        // true = lista de contingência do aparelho (mostrar aviso)
resultado.instituicoes;   // List<SupportInstitution>
```

Posição da usuária: `final posicao = await LocationService.obterPosicaoAtual();` (`null` se sem permissão, GPS desligado ou timeout; `LocationService.verificarPermissoes()` devolve a mensagem de erro para exibir).

Campos úteis de `SupportInstitution` para mapa e lista:

| Campo | Uso |
| --- | --- |
| `latitude`, `longitude` | Pino no mapa |
| `hasApproximateLocation` | Pino "aproximado" (ex.: borda tracejada) |
| `name`, `categoryLabel`, `icon`, `themeColor` | Cabeçalho do card |
| `address`, `district`, `city` | Endereço |
| `formattedDistance` | "450 m" / "2.3 km" (quando há posição) |
| `formattedOpeningHours`, `is24Hours` | Horário |
| `phone`, `phone2` | Botões de ligar (`SupportNetworkService.ligar(phone)`) |
| `targetAudience` | "Quem é atendido" |
| `isVerified()`, `verificationLabel()` | Selo "Verificado em…" / "Dados a confirmar" |
| `sourceName`, `sourceUrl` | Link "Fonte" (`SupportNetworkService.abrirFonte(url)`) |
| `servicesLabels` | Etiquetas de serviços |

Rota: `SupportNetworkService.abrirNoMapa(instituicao)` (usa o endereço quando a coordenada é aproximada).

### 2.4 Pessoa de confiança (fica só no aparelho)

```dart
final contato = TrustedContact.fromInput(name: apelido, phone: telefoneDigitado);
if (contato == null) { /* "Informe um apelido e um celular com DDD" */ }
await TrustedContactRepository.instance.salvar(contato!);

final salvo = await TrustedContactRepository.instance.carregar(); // null se não houver
salvo?.formattedPhone; // "(41) 99999-8888"
await TrustedContactRepository.instance.remover();
```

### 2.5 Avisar a pessoa de confiança

**Sempre mostre uma confirmação** explicando o que será compartilhado, com quem e por quanto tempo.

Localização atual (uma vez, sem backend):

```dart
final r = await ShareLocationService.enviarComFallback(
  telefone: contato.whatsappNumber, nomeContato: contato.name, context: context);
// r: ShareResult.sucesso | semLocalizacao | whatsappIndisponivel | falhaGeral
```

Acompanhamento ao vivo (15, 30 ou 60 min — `AppConfig.duracoesCompartilhamento`):

```dart
final ctrl = LocationShareController();   // guarde no State; chame ctrl.dispose() no dispose

if (!AppConfig.compartilhamentoAoVivoDisponivel) {
  // Página /acompanhar ainda não configurada: ofereça só a localização atual.
}

try {
  await ctrl.iniciar(contato: contato, minutos: 30, rotulo: contato.name);
} on LocationShareException catch (e) {
  // e.mensagem já está pronta para a usuária; ofereça a localização atual.
}

// Interface reativa:
ListenableBuilder(listenable: ctrl, builder: (context, _) {
  ctrl.status;              // inativo | iniciando | ativo | instavel | encerrado | erro
  ctrl.sessao?.remaining;   // tempo restante
  ctrl.ultimoEnvio;         // última posição enviada
  ctrl.mensagemErro;
  ...
});

await ctrl.encerrar();      // botão "Parar de compartilhar" — sempre visível
```

`instavel` = o último envio falhou (sem GPS ou internet); o controller continua tentando. Hoje o envio acontece com o app aberto; avise a usuária para mantê-lo aberto.

Para ativar o modo ao vivo no build:

```powershell
flutter run --dart-define=TRACKING_PAGE_URL=https://seu-dominio/acompanhar
```

## 3. Referência das RPCs (HTTP)

Todas aceitam `POST {URL}/rest/v1/rpc/<nome>` com JSON no corpo. Erros vêm como HTTP 4xx com `{"code", "message", "hint"}`; o campo `message` traz o código de erro listado.

### `search_institutions`

| Parâmetro | Tipo | Padrão | Descrição |
| --- | --- | --- | --- |
| `q` | text | null | Palavras; todas precisam aparecer; ignora acentos |
| `lat`, `lng` | float | null | Posição da usuária; ordena por distância |
| `filter_categories` | text[] | null | Ex.: `["delegacia_mulher","delegacia_comum"]` |
| `filter_city` | text | null | Ex.: `"Curitiba"` |
| `radius_meters` | int | null | null ou ≤ 0 = sem limite |
| `max_results` | int | 30 | Máximo 50 |

Resposta (lista):

```json
[{
  "id": "b588c2df-…", "external_key": "cwb-nuciber",
  "name": "NUCIBER — Delegacia de Crimes Cibernéticos",
  "category": "delegacia_comum", "subcategory": "Delegacia especializada: crimes na internet",
  "address": "Rua Pedro Ivo, 672 - Centro", "district": "Centro", "city": "Curitiba", "state": "PR",
  "zip_code": null, "phone": "(41) 3304-6800", "phone2": null, "email": null, "website": null,
  "opening_hours": null, "latitude": -25.436, "longitude": -49.272,
  "services": ["boletim_ocorrencia", "crimes_ciberneticos"],
  "target_audience": "Vítimas de crimes no ambiente virtual",
  "verified_at": "2026-09-24T…", "source_name": "Prefeitura de Curitiba — …", "source_url": "https://…",
  "location_precision": "aproximada", "distance_km": 0.69
}]
```

`opening_hours`: `{"seg": "08:00-17:00", ..., "dom": "24h"}` ou `null` (não informado).

### `get_app_bootstrap`

Parâmetros: `p_state` (padrão `"PR"`), `p_city` (padrão `"Curitiba"`). Resposta: objeto com `content_version`, `generated_at`, `location`, `emergency_channels[]`, `institution_categories[]`, `guides[]`. Exemplo completo: `app/assets/offline/bootstrap_curitiba.json`.

### `get_emergency_channels`

Parâmetros: `p_state`, `p_city`. Resposta: lista de canais nacionais + do estado + da cidade, ordenada.

### `location_share_start`

| Parâmetro | Tipo | Descrição |
| --- | --- | --- |
| `duration_min` | int | 5 a 60 |
| `label` | text | Opcional, até 40 caracteres, aparece na página (evite nome completo) |

Resposta:

```json
[{ "share_id": "f7503291-…", "publisher_token": "BMF_Vmb…", "viewer_token": "78QnhY2…",
   "expires_at": "2026-09-25T02:23:41+00:00" }]
```

Erros: `duracao_invalida`; `limite_de_sessoes` (mais de 10 por hora da mesma origem).

### `location_share_update`

Parâmetros: `publisher_token`, `lat`, `lng`, `accuracy_m` (opcional). Resposta: `[{ "active": true, "expires_at": "…" }]`. Quando `active` é `false`, a sessão terminou: parar de enviar. Envios com menos de 3 s de intervalo são ignorados. Erros: `coordenada_invalida`, `sessao_inexistente`.

### `location_share_stop`

Parâmetro: `publisher_token`. Resposta: `true` (encerrou) ou `false` (token não existe). Apaga a posição na hora.

### `location_share_view` (página `/acompanhar`)

Parâmetro: `viewer_token`. Resposta:

```json
[{ "status": "ativo", "label": "Ana", "latitude": -25.43, "longitude": -49.27,
   "accuracy_m": 12, "updated_at": "…", "expires_at": "…" }]
```

| `status` | O que a página mostra |
| --- | --- |
| `aguardando` | "Aguardando a primeira localização…" |
| `ativo` | Mapa com a posição, horário da última atualização e tempo restante |
| `encerrado` | "O compartilhamento foi encerrado." (sem posição) |
| `expirado` | "O tempo de compartilhamento terminou." (sem posição) |
| `inexistente` | "Link inválido ou expirado." |

Exemplo para a página (JavaScript, consultando a cada 15 s):

```js
const token = new URLSearchParams(location.hash.slice(1)).get('t');
const r = await fetch(`${SUPABASE_URL}/rest/v1/rpc/location_share_view`, {
  method: 'POST',
  headers: { apikey: SUPABASE_ANON_KEY, 'Content-Type': 'application/json' },
  body: JSON.stringify({ viewer_token: token }),
});
const [estado] = await r.json();
```

A página deve: não salvar o token nem a posição; mostrar um aviso de que o link pode ser encaminhado; indicar os canais 190 e 180.

### Leitura direta de tabelas (opcional)

Liberadas só para leitura: `institutions` (ativas, sem Casa-Abrigo), `guides`, `emergency_channels`, `institution_categories`. Prefira as RPCs acima. **Sem acesso:** `location_shares`, `institution_review_queue`, `institutions_stale`.

## 4. Mudanças na API

Mudou o banco? Crie uma migration nova em `backend/supabase/migrations/`, atualize este arquivo e rode `backend/supabase/tests/api_test.sql`. Se mudar o formato de `get_app_bootstrap`, regenere `app/assets/offline/bootstrap_curitiba.json` com:

```sql
select get_app_bootstrap('PR', 'Curitiba');
```
