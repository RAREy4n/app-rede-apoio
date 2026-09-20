# Aplicativo Rede de Apoio

Aplicativo mobile em Flutter/Dart.

## Estado atual

A estrutura Dart, a primeira navegação e o diretório nativo `android/` estão preparados. O aplicativo foi compilado e executado no emulador Android. O diretório `ios/` será gerado e testado futuramente em um Mac.

## Preparação do ambiente

1. Flutter 3.47.5 e Dart 3.13.4 instalados em `C:\Users\yanlu\develop\flutter`.
2. Android Studio, Android SDK, NDK e emulador já estão configurados.
3. Executar em um emulador ou aparelho físico.
4. Para iOS, configurar um Mac com Xcode quando essa etapa for necessária.

Antes de gerar arquivos dentro desta pasta, preserve os arquivos existentes em `lib/`, `test/` e `pubspec.yaml`.

## Direção de arquitetura

- `app/`: configuração global e ponto de entrada da interface.
- `core/`: tema e componentes compartilhados.
- `features/`: módulos organizados por funcionalidade.

O MVP começa sem dependências externas para reduzir conflitos. A análise estática e o teste inicial estão passando.
