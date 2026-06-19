# Aura Mind Mobile

Aplicativo Flutter para o ecossistema Aura Mind, com integração para autenticação, sincronização com Supabase, backend de IA e recursos de automação.

## Visão geral

O projeto inclui:

- autenticação com Supabase;
- sincronização de perfil, preferências e dados locais;
- comunicação com backend via HTTPS;
- integração com dispositivos e automações;
- interface mobile pensada para uso diário.

## Stack principal

- Flutter
- Dart
- Supabase
- REST APIs
- Material Design

## Estrutura do projeto

- `lib/` — código principal do app
- `lib/core/` — configuração, tema, rede e utilidades
- `lib/features/` — regras de negócio e repositórios
- `lib/screens/` — telas e navegação
- `lib/services/` — integrações nativas e serviços externos
- `lib/state/` — estado global da aplicação
- `supabase/` — schema SQL para o banco
- `test/` — testes automatizados

## Requisitos

- Flutter SDK
- Android Studio ou VS Code com extensão Flutter
- Emulador Android ou dispositivo físico
- Projeto Supabase configurado
- Backend com URL HTTPS válida

## Configuração do app

Para desenvolvimento local, o app pode receber as variáveis abaixo em tempo de build:

- `ORACLE_API_BASE_URL`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Exemplo:

```powershell
flutter run `
  --dart-define=ORACLE_API_BASE_URL=https://seu-backend.ngrok-free.dev `
  --dart-define=SUPABASE_URL=https://seu-projeto.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=sua-chave-publicavel
```

Para a versão final distribuída aos usuários, o app já foi preparado para usar valores embutidos na build, evitando a necessidade do usuário executar comandos com `--dart-define`.

> Em produção, valores sensíveis devem continuar sendo tratados com secrets ou pipeline de build.

## Como rodar

### Android emulator

```powershell
flutter run
```

### Dispositivo físico

```powershell
flutter run --device-id=<seu-dispositivo>
```

## Build do APK

```powershell
flutter build apk
```

O artefato final será gerado em:

- `build/app/outputs/flutter-apk/app-release.apk`

## Distribuição

O APK gerado pode ser compartilhado diretamente para testes ou instalação manual em dispositivos Android.

## Supabase

O schema base do projeto está em:

- `supabase/aura_mind_schema.sql`

Esse arquivo define tabelas para:

- perfil e preferências;
- contatos;
- dispositivos;
- notificações;
- mensagens e sessões;
- grupos e permissões.

## Testes

```powershell
flutter test
```

## Qualidade

```powershell
flutter analyze
```

## Release notes

- O app aceita configuração por build-time values.
- O backend deve estar acessível por HTTPS.
- A autenticação depende corretamente da URL e da chave Supabase.
- A build de release já foi validada com APK pronto para uso.

## Contribuição

1. Crie uma branch para a sua feature.
2. Faça commits claros.
3. Execute testes e análise.
4. Abra um pull request com descrição do impacto.
