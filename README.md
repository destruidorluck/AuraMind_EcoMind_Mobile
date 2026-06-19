
# AuraMind

### IA conversacional, automação residencial e experiência multimodal em um único ecossistema mobile

<p align="center">
  <a href="./README.md">Início</a> |
  <a href="./flutter_app/README.md">Flutter App</a> |
  <a href="./guidelines/Guidelines.md">Docs</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Mobile-0B1020?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-Language-111827?style=for-the-badge&logo=dart&logoColor=00D9FF" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-Auth%20%26%20Data-062B2B?style=for-the-badge&logo=supabase&logoColor=3ECF8E" alt="Supabase" />
  <img src="https://img.shields.io/badge/API-Backend-4B0082?style=for-the-badge&logo=fastapi&logoColor=white" alt="Backend API" />
</p>

> AuraMind combina voz, texto, automação e feedback contextual para reduzir fricção cognitiva e deixar a rotina mais fluida.

## Visão Geral

Este repositório é focado exclusivamente no aplicativo mobile Flutter do projeto AuraMind.

- interface mobile com experiência multimodal;
- autenticação e sincronização com Supabase;
- integração com backend via HTTPS;
- build pronta para APK de release.

## Estrutura do Repositório

- [flutter_app](flutter_app) — app Flutter principal;
- [guidelines](guidelines) — referências técnicas e documentação de apoio;
- [README.md](README.md) — visão geral do projeto.

## Arquitetura Rápida

```text
flutter_app/
├── lib/               # código principal do app
├── assets/            # imagens, sons e recursos
├── supabase/          # schema SQL de apoio
└── test/              # testes automatizados
```

## Como Rodar

### 1. Pré-requisitos

- Flutter SDK instalado;
- Android Studio ou VS Code com extensão Flutter;
- emulador Android ou dispositivo físico.

### 2. Configuração local

O app utiliza valores de configuração em tempo de build para conectar com o backend e com o Supabase.

Exemplo:

```powershell
flutter run `
  --dart-define=ORACLE_API_BASE_URL=https://seu-backend `
  --dart-define=SUPABASE_URL=https://seu-projeto.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=sua-chave-publicavel
```

### 3. Build do APK

```powershell
flutter build apk
```

O artefato final será gerado em:

- [flutter_app/build/app/outputs/flutter-apk/app-release.apk](flutter_app/build/app/outputs/flutter-apk/app-release.apk)

## Configuração

A versão final do app já foi preparada para trabalhar com valores embutidos na build, evitando que o usuário precise executar comandos manuais com `--dart-define`.

## Documentação

- [flutter_app/README.md](flutter_app/README.md) — instruções detalhadas do app;
- [guidelines/Guidelines.md](guidelines/Guidelines.md) — referências técnicas e fluxo de desenvolvimento.

## Observação Importante

Esta versão do projeto foi organizada exclusivamente para o aplicativo Flutter. A parte React foi removida da documentação para manter o repositório alinhado com o produto final mobile.
