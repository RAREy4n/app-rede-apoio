# Escopo do Projeto — Rede de Apoio

> **Situação em 25/09/2026:** Fase 3 (MVP técnico) em andamento. Piloto em Curitiba/PR. O que já funciona está no [README](../README.md) e o que falta em [PENDENCIAS.md](PENDENCIAS.md).

## 1. Visão geral

O Rede de Apoio é um projeto extensionista para criar uma solução digital de acesso simples à rede de proteção às mulheres em situação de violência.

A solução será composta por:

1. uma landing page pública;
2. um aplicativo mobile;
3. uma estrutura de dados para instituições e contatos autorizados;
4. documentação educativa e de segurança.

## 2. Problema

Mulheres em situação de violência podem enfrentar medo, dependência financeira, isolamento, falta de informação, dificuldade de deslocamento, baixa confiança nas instituições e risco de monitoramento pelo agressor.

Os canais de apoio existem, mas estão distribuídos entre órgãos diferentes e podem ser difíceis de localizar em uma situação de urgência.

## 3. Objetivo geral

Facilitar o acesso rápido, seguro e compreensível a informações, contatos e serviços da rede de proteção às mulheres.

## 4. Objetivos específicos

- reunir instituições de apoio em um mapa pesquisável;
- indicar canais oficiais, como 190 e Ligue 180;
- orientar sobre registro de ocorrência e medida protetiva;
- permitir cadastro de uma pessoa de confiança;
- permitir o envio de uma localização atual ou temporária;
- reduzir a quantidade de dados pessoais coletados;
- oferecer modo discreto com limitações claramente informadas;
- produzir uma solução acessível para diferentes perfis de usuárias;
- validar a proposta com profissionais e organizações da rede de atendimento.

## 5. Público-alvo

### Público primário

- mulheres em situação de violência ou risco;
- mulheres buscando informação para prevenção e planejamento de segurança.

### Público secundário

- familiares e pessoas de confiança;
- testemunhas;
- profissionais e organizações da rede de atendimento;
- comunidade acadêmica e extensionista.

## 6. MVP

### 6.1 Landing page

- apresentação do problema e da proposta;
- explicação dos limites da ferramenta;
- botão para baixar o aplicativo;
- QR Code para download;
- acesso rápido ao 190 e ao Ligue 180;
- seção sobre privacidade e segurança;
- seção para instituições interessadas em parceria.

### 6.2 Aplicativo mobile

- tela inicial com acesso imediato à emergência;
- botão para ligação ao 190;
- botão para contato com o Ligue 180;
- mapa da rede de apoio;
- busca por tipo de serviço e localização;
- detalhes de cada instituição;
- cadastro de pessoa de confiança;
- envio de mensagem com localização atual;
- compartilhamento de localização por tempo limitado através de link seguro;
- encerramento manual do compartilhamento;
- orientação sobre BO, denúncia e medida protetiva;
- modo discreto visual;
- notificações neutras;
- botão de saída rápida.

### 6.3 Painel administrativo futuro

- cadastro e edição de instituições;
- atualização de telefone, horário e endereço;
- registro da data de verificação;
- aprovação de alterações;
- controle de usuários administrativos;
- relatório de serviços desatualizados.

## 7. Fora do escopo inicial

Não fazem parte do primeiro MVP:

- envio automático de BO aos sistemas governamentais;
- concessão automática de medida protetiva;
- acionamento direto de viatura sem parceria institucional;
- atendimento psicológico ou jurídico dentro do app;
- monitoramento permanente da usuária;
- armazenamento de provas sensíveis;
- inteligência artificial para decidir nível de risco;
- garantia de anonimato ou eliminação total de rastros;
- funcionamento garantido sem bateria, sinal, internet ou GPS.

## 8. Fluxo principal da usuária

1. Abre o aplicativo.
2. Visualiza as opções de emergência sem precisar preencher cadastro.
3. Escolhe entre ligar para o 190, acessar o 180, encontrar apoio ou avisar uma pessoa de confiança.
4. Se necessário, cadastra um contato confiável.
5. Escolhe o tipo de compartilhamento: localização atual ou localização temporária.
6. Define a duração do compartilhamento.
7. Confirma a ação.
8. Pode interromper o compartilhamento a qualquer momento.

## 9. Compartilhamento de localização

### Localização atual

O aplicativo gera um link ou mensagem e abre o WhatsApp ou SMS. O envio final deve ser confirmado pela usuária.

### Localização temporária

O aplicativo envia coordenadas para um backend durante um período definido, por exemplo, 15, 30 ou 60 minutos. A pessoa de confiança acompanha a posição por uma página web protegida, sem precisar instalar o aplicativo.

### Regras de segurança

- consentimento explícito antes de iniciar;
- duração obrigatória;
- encerramento manual;
- link com token aleatório;
- expiração automática;
- possibilidade de revogar o token;
- coleta mínima de dados;
- não exibir nome completo desnecessariamente;
- informar que o link pode ser encaminhado por quem o receber.

## 10. Privacidade e segurança

- não exigir login antes do acesso à emergência;
- coletar somente dados necessários;
- explicar cada permissão solicitada;
- evitar histórico sensível no dispositivo;
- usar notificações neutras;
- não afirmar que o aplicativo não deixa rastros;
- proteger dados em trânsito e em repouso;
- definir política de retenção e exclusão;
- realizar testes com profissionais especializados antes de uso real;
- seguir a LGPD e avaliar dados de localização como dados pessoais.

## 11. Personalização discreta

Será permitido personalizar a aparência interna do app e, futuramente, selecionar opções predefinidas de ícone e nome neutro.

Não será prometida a troca livre do nome e ícone do aplicativo em todos os dispositivos. Android e iOS possuem limitações próprias, e a alteração não remove registros das configurações, notificações, loja ou histórico do celular.

## 12. Critérios de sucesso

- usuária encontra um serviço adequado em poucos passos;
- contatos e telefones estão atualizados;
- botões de emergência são facilmente identificáveis;
- usuária entende o que será compartilhado;
- compartilhamento possui início, duração e encerramento claros;
- interface é acessível e funciona em telas pequenas;
- testes não revelam exposição desnecessária de informações;
- profissionais da rede consideram os encaminhamentos úteis.

## 13. Fases de desenvolvimento

### Fase 1 — Descoberta

- entrevistas com profissionais e organizações;
- levantamento da rede de apoio local;
- análise de riscos;
- definição do município ou estado-piloto (**definido: Curitiba/PR**).

### Fase 2 — UX e protótipo

- fluxos de emergência;
- protótipo da landing page;
- protótipo do aplicativo;
- testes de compreensão e acessibilidade.

### Fase 3 — MVP técnico

- landing page React;
- aplicativo Flutter;
- mapa e base inicial de serviços;
- contatos confiáveis;
- localização atual;
- link temporário de localização.

### Fase 4 — Validação

- testes técnicos;
- testes de segurança;
- avaliação com profissionais;
- correção de falhas;
- documentação para apresentação extensionista.

### Fase 5 — Parcerias e expansão

- validação com órgãos públicos;
- atualização contínua da rede;
- estudo de integrações oficiais;
- expansão para outras localidades.
