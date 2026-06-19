# Guia Técnico do AuraMind Mobile

Este documento registra as decisões que precisam permanecer verdadeiras durante
a evolução do aplicativo.

## Arquitetura

O app segue uma divisão simples:

- `core`: configuração, rede, armazenamento e tema;
- `features`: repositórios por domínio;
- `services`: recursos nativos e integrações externas;
- `state/AuraController`: orquestra sessão, navegação e estado visível;
- `screens` e `widgets`: apresentação;
- `supabase`: schema, Storage e políticas de acesso.

As telas não devem gravar diretamente no Supabase. Elas acionam o controller,
que delega a persistência ao repositório do domínio.

## Identidade da Conta

O UUID retornado pelo Supabase Auth é o identificador canônico do proprietário.

- `profiles.id` recebe o UUID autenticado;
- `group_members` contém somente perfis gerenciados;
- o proprietário sempre aparece primeiro na interface;
- contas são deduplicadas por ID e por e-mail normalizado;
- o login local de demonstração usa o ID estável `local-aura-user`.

Nunca crie um proprietário com timestamp. Isso recria o bug de duas contas
proprietárias para o mesmo e-mail.

## Ciclo de Sessão

Quando o Supabase está configurado, somente `onAuthStateChange` confirma o
login. A tela de login não chama o login local depois do `signInWithEmail`.

Durante a hidratação:

1. dependências locais são abertas;
2. dados legados são migrados para o UUID;
3. perfil e foto são carregados;
4. configurações, grupos, dispositivos e dados do app são sincronizados;
5. a persistência automática volta a ser habilitada.

Somente o evento explícito `signedOut` deve limpar o estado em memória. A
limpeza não apaga registros locais ou remotos.

## Fotos

O bucket utilizado é `aura-profile-photos`.

- proprietário: `<userId>/profile/avatar.<ext>`;
- membro: `<ownerId>/managed/<memberId>/avatar.<ext>`;
- grupo: `<ownerId>/groups/<groupId>/avatar.<ext>`.

O upload acontece antes da atualização completa de `profiles`. Não faça upsert
parcial contendo apenas `id` e `avatar_url`, pois schemas com campos obrigatórios
podem rejeitar a operação. Prefira persistir `avatar_path` e gerar URL assinada
na leitura.

## Dados Locais

As chaves seguem o formato `user:<userId>:<dominio>`. Ao trocar um identificador
local pelo UUID do Supabase, a migração copia apenas chaves ausentes e confirma
o proprietário pelo e-mail normalizado.

A gravação deve verificar novamente o usuário ativo depois de operações
assíncronas. Isso impede que uma sessão antiga sobrescreva a sessão atual.

## Player de Mídia

Áudio com `audio_url` usa o serviço nativo. Mídia do YouTube usa
`youtube_player_iframe`.

O `YoutubePlayer` deve permanecer montado no widget raiz. A tela Mídia pode
mostrar somente a capa; desmontar o iframe ao trocar de rota interrompe o áudio
e faz o mini-player enviar comandos para um player inexistente.

Antes de carregar, o ID precisa corresponder a `[A-Za-z0-9_-]{11}`. URLs
`watch`, `youtu.be`, `embed`, `shorts` e `live` podem ser convertidas para esse
ID. O parâmetro inicial de tempo deve ser omitido quando a posição for zero.

## Qualidade e Release

Execute antes de publicar:

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --release --no-pub
```

Também valide em aparelho real:

- login, logout e reinício do app;
- foto do proprietário após novo login;
- criação, edição e exclusão de membro;
- música ao navegar entre todas as abas;
- Bluetooth e comandos da EcoMind;
- rotinas e exclusão por gesto lateral.

O APK final fica em
`flutter_app/build/app/outputs/flutter-apk/app-release.apk`.
