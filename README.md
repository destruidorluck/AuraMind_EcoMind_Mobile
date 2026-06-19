
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
  <img src="https://img.shields.io/badge/Release-1.0.1%2B2-7C3AED?style=for-the-badge" alt="Release 1.0.1+2" />
</p>

> AuraMind combina voz, texto, automação e feedback contextual para reduzir fricção cognitiva e deixar a rotina mais fluida.

## Visão Geral

Este repositório é focado exclusivamente no aplicativo mobile Flutter do projeto AuraMind.

- interface mobile com experiência multimodal;
- autenticação e sincronização com Supabase;
- perfis principal e gerenciados com fotos persistidas;
- grupos, rotinas, dispositivos e EcoMind;
- reprodução de mídia persistente entre as telas do app;
- integração com backend via HTTPS;
- build pronta para APK de release.

## Estrutura do Repositório

- [flutter_app](flutter_app) — app Flutter principal;
- [guidelines](guidelines) — referências técnicas e documentação de apoio;
- [README.md](README.md) — visão geral do projeto.

## Arquitetura Rápida

```text
flutter_app/
├── lib/core/          # configuração, rede, tema e armazenamento
├── lib/features/      # repositórios e regras de dados
├── lib/screens/       # telas e navegação
├── lib/services/      # integrações nativas, Supabase e EcoMind
├── lib/state/         # estado global e sincronização
├── supabase/          # schema SQL e políticas
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
flutter build apk --release
```

O artefato final será gerado em:

- [flutter_app/build/app/outputs/flutter-apk/app-release.apk](flutter_app/build/app/outputs/flutter-apk/app-release.apk)

## Configuração

A versão final do app já foi preparada para trabalhar com valores embutidos na build, evitando que o usuário precise executar comandos manuais com `--dart-define`.

## Documentação

- [flutter_app/README.md](flutter_app/README.md) — instruções detalhadas do app;
- [guidelines/Guidelines.md](guidelines/Guidelines.md) — referências técnicas e fluxo de desenvolvimento.
- [CHANGELOG.md](CHANGELOG.md) — histórico das versões.

## Estado da Release

Versão atual: `1.0.1+2`.

- `flutter analyze --no-pub`: aprovado sem apontamentos;
- `flutter test --no-pub`: 21 testes aprovados;
- `flutter build apk --release --no-pub`: aprovado;
- APK: `flutter_app/build/app/outputs/flutter-apk/app-release.apk`;
- tamanho do artefato: aproximadamente 64,4 MB.

A validação manual deve ser feita em um aparelho Android com as credenciais do
ambiente de destino, especialmente para login, upload de fotos, Bluetooth e
reprodução do YouTube.

## Observação Importante

Esta versão do projeto foi organizada exclusivamente para o aplicativo Flutter. A parte React foi removida da documentação para manter o repositório alinhado com o produto final mobile.
