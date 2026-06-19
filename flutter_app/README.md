# AuraMind Mobile

Aplicativo Flutter para o ecossistema AuraMind, com integração para autenticação, sincronização com Supabase, backend de IA e recursos de automação.

> Release atual: `1.0.1+2`

## Visão Geral

O projeto inclui:

- autenticação com Supabase;
- sincronização de perfil, preferências e dados locais;
- fotos do proprietário, membros e grupos no Storage do Supabase;
- migração segura dos dados locais para o UUID autenticado;
- player de mídia persistente durante a navegação interna;
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
flutter build apk --release
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

Execute o arquivo no SQL Editor do projeto antes dos testes integrados. O
proprietário da conta é salvo em `profiles`; somente contas gerenciadas são
salvas em `group_members`. Essa separação evita proprietários duplicados.

As fotos usam o bucket privado `aura-profile-photos`. O banco mantém
`avatar_path`, e o app cria URLs assinadas quando carrega o perfil.

## Sessão e Persistência

- o listener do Supabase é a única fonte de login quando o serviço está configurado;
- eventos transitórios sem sessão não encerram a conta;
- carregamentos simultâneos da mesma sessão são consolidados;
- caches antigos são migrados pelo e-mail para o UUID do Supabase;
- a gravação automática fica suspensa enquanto a conta está sendo hidratada.

## Mídia

Áudios diretos usam o player nativo. Resultados do YouTube usam um player
persistente mantido no nível raiz do aplicativo, permitindo continuar a música
ao navegar entre Início, Mensagens, Dispositivos e Mais. A tela Mídia mostra a
capa e os controles, sem transformar a experiência principal em uma tela de
vídeo.

## Testes

```powershell
flutter test
```

## Qualidade

```powershell
flutter analyze
```

## Release Notes

### 1.0.1+2

- corrigida a duplicação do proprietário após o login;
- preservados dados criados com o identificador local antigo;
- corrigida a persistência da foto do perfil principal;
- proprietário removido da coleção de membros gerenciados;
- player do YouTube mantido entre as telas;
- validação do ID de vídeo e recuperação única de `InvalidParam`;
- 21 testes automatizados aprovados;
- APK release validado com aproximadamente 64,4 MB.

## Contribuição

1. Crie uma branch para a sua feature.
2. Faça commits claros.
3. Execute testes e análise.
4. Abra um pull request com descrição do impacto.
