# AuraMind Mobile

Aplicativo Flutter para o ecossistema AuraMind, com integração para autenticação, sincronização com Supabase, backend de IA e recursos de automação.

## Visão Geral

O projeto inclui:

- autenticação com Supabase;
- sincronização de perfil, preferências e dados locais;
- comunicação com backend via HTTPS;
- integração com dispositivos e automações;
- interface mobile pensada para uso diário.

## Stack Principal

- Flutter;
- Dart;
- Supabase;
- REST APIs;
- Material Design.

## Estrutura do Projeto

- `lib/` — código principal do app;
- `lib/core/` — configuração, tema, rede e utilidades;
- `lib/features/` — regras de negócio e repositórios;
- `lib/screens/` — telas e navegação;
- `lib/services/` — integrações nativas e serviços externos;
- `lib/state/` — estado global da aplicação;
- `supabase/` — schema SQL para o banco;
- `test/` — testes automatizados.

## Requisitos

- Flutter SDK;
- Android Studio ou VS Code com extensão Flutter;
- emulador Android ou dispositivo físico;
- projeto Supabase configurado;
- backend com URL HTTPS válida.

## Configuração do App

Para desenvolvimento local, o app pode receber as variáveis abaixo em tempo de build:

- `ORACLE_API_BASE_URL`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Exemplo:

```powershell
flutter run `
  --dart-define=ORACLE_API_BASE_URL=https://seu-backend `
  --dart-define=SUPABASE_URL=https://seu-projeto.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=sua-chave-publicavel
```

Para a versão final distribuída aos usuários, o app já foi preparado para usar valores embutidos na build, evitando a necessidade de o usuário executar comandos com `--dart-define`.

## Como Rodar

### Android Emulator

```powershell
flutter run
```

### Dispositivo Físico

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

## Release Notes

- o app aceita configuração por build-time values;
- o backend deve estar acessível por HTTPS;
- a autenticação depende corretamente da URL e da chave Supabase;
- a build de release já foi validada com APK pronto para uso.

## Contribuição

1. Crie uma branch para a sua feature.
2. Faça commits claros.
3. Execute testes e análise.
4. Abra um pull request com descrição do impacto.
