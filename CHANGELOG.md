# Changelog

Todas as mudanças relevantes do AuraMind Mobile são registradas aqui.

## 1.0.1+2 — 19 de junho de 2026

### Corrigido

- login processado duas vezes e criação de proprietários duplicados;
- encerramento indevido da sessão em eventos transitórios do Supabase;
- aparente perda de dados ao migrar do identificador local para o UUID;
- foto do perfil principal não persistida em `profiles`;
- proprietário salvo incorretamente em `group_members`;
- player do YouTube desmontado ao sair da tela Mídia;
- erro `InvalidParam` causado por ID ou parâmetros inválidos.

### Melhorado

- deduplicação de contas por ID e e-mail;
- migração segura do armazenamento local;
- player persistente entre as rotas do aplicativo;
- documentação de arquitetura, sessão, fotos, mídia e release.

### Validado

- análise estática sem apontamentos;
- 21 testes automatizados aprovados;
- APK release gerado com aproximadamente 64,4 MB.

## 1.0.0+1

- primeira versão consolidada do aplicativo Flutter AuraMind.
