# Ambiente Android para testes

Este guia permite que uma pessoa ou IA prepare o ambiente para executar o aplicativo Flutter em um emulador Android. O projeto já foi validado com Flutter 3.47.5, Dart 3.13.4 e o emulador `medium_phone`.

## 1. Instalar as ferramentas

Instale:

1. [Flutter SDK](https://docs.flutter.dev/get-started/install/windows/mobile).
2. Android Studio.
3. Plugins **Flutter** e **Dart** pelo menu `File > Settings > Plugins` do Android Studio.

Após descompactar o Flutter, adicione a pasta `bin` dele ao `PATH` do Windows. Feche e abra um novo PowerShell e confirme:

```powershell
flutter --version
dart --version
```

## 2. Configurar Android Studio e SDK

No Android Studio, abra `More Actions > SDK Manager`.

Em **SDK Platforms**, instale uma versão recente da plataforma Android (este projeto foi testado com Android 16 / API 36).

Em **SDK Tools**, confirme a instalação de:

- Android SDK Build-Tools;
- Android SDK Platform-Tools;
- Android SDK Command-line Tools;
- Android Emulator;
- NDK (Side by side), se o `flutter doctor` solicitar.

Anote o caminho do Android SDK. No ambiente já configurado ele é:

```text
C:\Users\yanlu\AppData\Local\Android\Sdk
```

O caminho pode variar para cada desenvolvedor e não deve ser enviado ao Git.

## 3. Aceitar licenças e diagnosticar

No PowerShell, execute:

```powershell
flutter doctor
flutter doctor --android-licenses
```

Aceite todas as licenças. Repita `flutter doctor` até a seção **Android toolchain** não apresentar erro.

## 4. Criar o emulador Android

No Android Studio, abra `More Actions > Virtual Device Manager` e selecione `Create device`.

Configuração recomendada:

| Campo | Valor sugerido |
| --- | --- |
| Categoria | Phone |
| Perfil | Medium Phone ou equivalente |
| Imagem de sistema | API 36, x86_64, Google APIs |
| Nome | `medium_phone` |

Finalize a criação e inicie o emulador pelo botão de reprodução. Na primeira abertura, aguarde a tela inicial do Android aparecer por completo.

## 5. Executar o projeto

**1. Ligue o emulador e espere o Android abrir por completo** (30 s a 1 min). O jeito mais confiável, porque mostra erros:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -list-avds
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd medium_phone
```

Deixe esse terminal aberto. Também dá para ligar pelo Android Studio em **Device Manager → ▶**. O comando `flutter emulators --launch medium_phone` funciona, mas não mostra erro se o emulador falhar.

**2. Em outro terminal, rode o app:**

```powershell
cd C:\projetos\app-rede-apoio\app
flutter pub get
flutter devices
flutter run
```

Só rode `flutter run` quando `flutter devices` listar o Android (ex.: `emulator-5554`). Com mais de um aparelho, use `flutter run -d <id>`.

**Teste rápido no navegador:** `flutter run -d chrome`. Mapa, lista e guias funcionam; GPS, discador e WhatsApp se comportam diferente do celular.

**Guardar o log de uma execução** (para investigar erros):

```powershell
flutter run -d chrome > run_log.txt 2>&1
```

Feche qualquer outro `flutter run` antes; senão o arquivo fica "em uso por outro processo".

## 6. Validar antes de alterar ou enviar código

Dentro da pasta `app/`, execute:

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

O APK resultante fica em `app/build/app/outputs/flutter-apk/`. É um artefato local: não deve ser enviado ao Git.

## Diagnóstico rápido

| Sintoma | Verificação ou ação |
| --- | --- |
| `flutter` não é reconhecido | Corrigir o `PATH` com a pasta `bin` do Flutter e abrir um novo terminal. |
| Nenhum emulador aparece | Ligue pelo `emulator.exe -avd` (acima) para ver o erro, espere o Android abrir e rode `flutter devices` de novo. |
| `No supported devices found with name or id matching 'emulator-5554'` | O emulador não está ligado ou tem outro id. Rode `flutter devices` e use o id listado. |
| Erro de hypervisor/WHPX/aceleração | Ative "Plataforma do Hipervisor do Windows" em Recursos do Windows e reinicie. |
| Tela branca com `Unexpected null value` repetido | Veja o **primeiro** erro no log (`run_log.txt`). Um caso conhecido: botão dentro de `Row` sem `minimumSize` (ver `app/README.md`). |
| `run_log.txt ... being used by another process` | Outro `flutter run` ainda está aberto: aperte `q` nele. |
| Erro de licenças | Execute `flutter doctor --android-licenses`. |
| Falha na instalação do APK | Reinicie o emulador, confirme espaço disponível e rode `flutter run` novamente. |
| Android toolchain com erro | Abra SDK Manager, instale os componentes solicitados e consulte `flutter doctor -v`. |
| Projeto executado da pasta errada | Os comandos Flutter devem ser rodados em `C:\projetos\app-rede-apoio\app`, onde está o `pubspec.yaml`. |

## Pendências do ambiente

- iOS ainda não está configurado; essa etapa requer macOS e Xcode.
- O emulador serve para desenvolvimento. Antes de distribuir o app, testar em aparelhos Android físicos de versões diferentes.
- Integrações futuras de localização, chamadas, SMS ou notificações devem ser testadas em aparelho físico, pois emuladores têm limitações de permissões e sensores.
