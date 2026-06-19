
# Aura Mind Project

Este workspace reúne os principais componentes do ecossistema Aura Mind:

- **Aplicativo mobile** em [flutter_app](flutter_app)
- **Site/web** na raiz do projeto
- **Documentação e referências** em [guidelines](guidelines)

## Visão geral

O repositório foi organizado para manter:

- o app Flutter com configuração pronta para build de release;
- a interface web do projeto;
- a documentação necessária para publicação e manutenção.

## Estrutura do projeto

- [flutter_app](flutter_app) — aplicativo mobile Flutter
- [src](src) — frontend web
- [public](public) — assets públicos do site
- [guidelines](guidelines) — documentos de apoio e referência

## Objetivo

Acompanhar o desenvolvimento do ecossistema Aura Mind com:

- experiência mobile inteligente;
- integração com backend e Supabase;
- navegação visual do site;
- documentação clara para publicação em GitHub.

## Documentação por área

- O README do app explica instalação, execução, build e distribuição.
- O README do site explica como visualizar e manter a interface web.
- Variáveis sensíveis devem permanecer fora do código público e serem tratadas via build pipeline ou secrets.

## Build e release

- O aplicativo mobile pode gerar um APK de release com o comando:
  - `flutter build apk`
- O arquivo final esperado está em:
  - [flutter_app/build/app/outputs/flutter-apk/app-release.apk](flutter_app/build/app/outputs/flutter-apk/app-release.apk)

## Próximo passo

Após finalizar a documentação, o próximo passo é configurar os remotes do GitHub e publicar os repositórios conforme a estratégia definida.
