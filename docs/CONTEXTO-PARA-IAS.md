# Contexto do Projeto para IAs

## Instrução principal

Você está ajudando a desenvolver o projeto Rede de Apoio, uma plataforma extensionista de orientação e conexão rápida com a rede de proteção às mulheres em situação de violência no Brasil.

Priorize segurança, privacidade, acessibilidade, clareza e viabilidade acadêmica. Não invente integrações com órgãos públicos. Não trate protótipos como serviços oficiais. Não prometa que o app salvará uma vida, acionará a polícia automaticamente ou eliminará todos os rastros do dispositivo.

## Produto

O produto possui duas interfaces principais:

1. Landing page pública feita em React com JavaScript.
2. Aplicativo mobile multiplataforma feito em Flutter com Dart.

O backend será responsável pelos dados da rede de apoio, contatos autorizados e compartilhamento temporário de localização.

## Proposta de valor

Facilitar o acesso a serviços e contatos de apoio sem obrigar a usuária a navegar por vários sites e órgãos diferentes.

## Estado atual do repositório

- O aplicativo Flutter em `app/` funciona no Android e possui onboarding e tela inicial demonstrativos.
- O Android foi validado no emulador `medium_phone`; Flutter, Dart, SDK e licenças estão configurados localmente.
- A landing page React em `landing-page/` ainda não foi inicializada.
- O backend em `backend/` ainda não foi implementado.
- Não há integração real com localização, WhatsApp, SOS, boletim de ocorrência, APIs governamentais ou armazenamento de dados sensíveis.

## Como validar o estado atual

Dentro de `app/`, execute:

```powershell
flutter analyze
flutter test
flutter run -d emulator-5554
```

## Próximo recorte de implementação

Implementar apenas a experiência local de cadastro de uma pessoa de confiança: nome, telefone, explicação de consentimento, revisão e opção de pular. Não incluir GPS, WhatsApp, backend nem envio real de alerta nessa etapa.

## Funcionalidades prioritárias

- acesso imediato ao 190;
- acesso ao Ligue 180;
- mapa de instituições verificadas;
- busca por categoria e distância;
- cadastro de pessoa de confiança;
- envio de localização atual por WhatsApp ou SMS;
- compartilhamento de localização por tempo limitado através de link seguro;
- botão de encerramento do compartilhamento;
- orientação sobre BO e medida protetiva;
- modo discreto e notificações neutras;
- botão de saída rápida.

## Regras de produto

- Emergência não pode ficar bloqueada atrás de login.
- O app não substitui 190, 180, polícia, Justiça, saúde ou assistência social.
- Nenhuma localização deve ser compartilhada sem confirmação clara.
- Todo compartilhamento deve ter duração definida.
- Dados pessoais devem ser minimizados.
- A interface deve ser compreensível sob estresse.
- O sistema deve explicar falhas de GPS, internet, bateria e permissões.
- Não adicionar IA para diagnosticar violência ou tomar decisões policiais.
- Não armazenar provas sensíveis no MVP.

## Regra sobre WhatsApp

O aplicativo pode abrir uma conversa com mensagem ou link preparado. Ele não deve presumir que consegue controlar silenciosamente a função de localização em tempo real do WhatsApp.

Para localização em tempo real sem que o familiar instale o app, usar uma página web temporária com token expirável. Para localização dentro do app, ambos os usuários precisariam instalar o aplicativo e aceitar o vínculo.

## Regra sobre nome e ícone

Personalização interna é permitida. Ícones alternativos no Android e iOS dependem de recursos nativos e devem ser previamente preparados. Não prometer nome ou ícone arbitrário em todos os dispositivos. Modo discreto não significa anonimato ou eliminação de rastros.

## Stack

- Mobile: Flutter/Dart.
- Landing page: React/JavaScript.
- Mapas: provedor de mapas com licença adequada.
- Backend: API segura e banco relacional.
- Autenticação: mínima e opcional onde possível.
- Comunicação: links oficiais, telefone, SMS e notificações autorizadas.

## Padrão de resposta para tarefas técnicas

Antes de implementar:

1. identificar se a mudança afeta segurança ou privacidade;
2. indicar limitações do Android, iOS, navegador ou WhatsApp;
3. propor a solução mais simples para o MVP;
4. separar protótipo de integração oficial;
5. sugerir testes de erro e de abuso;
6. evitar coletar dados que não sejam necessários.

## Fora do escopo

- BO automático para qualquer estado;
- botão do pânico conectado à polícia sem parceria;
- rastreamento contínuo sem consentimento;
- atendimento humano 24 horas sem equipe responsável;
- promessa de segurança absoluta;
- ocultação total do app no aparelho;
- compartilhamento irreversível de localização.

## Tom e interface

Use linguagem acolhedora, direta e não culpabilizante. Evite excesso de texto na emergência. Use botões grandes, contraste adequado, leitura por tela, linguagem simples e suporte a diferentes perfis de usuárias.
