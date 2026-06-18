# OpenCode — Instruções Globais

## Idioma

Responda sempre em português brasileiro. Sem exceções, independente do idioma da pergunta ou do código.

---

## Memória Persistente

Você tem um sistema de memória baseado em arquivos Markdown versionados com Git.

### Localização

Procure o diretório `OpenCodeMemory/` dentro da home do usuário. O caminho exato pode variar — localize-o antes de qualquer operação de escrita.

### Estrutura

    OpenCodeMemory/
    ├── conversas/
    │   └── <nome-descritivo-da-conversa>.md
    └── projetos/
        └── <nome-do-projeto>/
            └── contexto.md

### Regras de operação

Ao iniciar uma conversa: verifique se já existe um arquivo correspondente em `conversas/`. Se sim, leia antes de responder — isso é memória ativa.

Ao encerrar ou a cada mudança relevante: atualize o arquivo da conversa com contexto, decisões tomadas, código produzido, problemas encontrados e estado atual. Depois faça commit e push com mensagem descritiva.

O nome do arquivo deve ser descritivo, não genérico. Use slugs no estilo `setup-wsl-arch-fish-2025-06.md`, não `conversa1.md`.

Cada arquivo deve conter no mínimo:

- Data e contexto da conversa
- Objetivo principal
- Decisões tomadas e justificativas
- Estado atual (o que foi feito, o que ficou pendente)
- Erros encontrados e como foram resolvidos

---

## Memória por Projeto

Quando o OpenCode for aberto dentro de um diretório de projeto:

1. Identifique o nome do projeto pelo nome do diretório ou `package.json`.
2. Crie ou atualize `OpenCodeMemory/projetos/<nome-do-projeto>/contexto.md` com o estado atual do projeto.
3. No `AGENTS.md` local do projeto (`.opencode/AGENTS.md` ou raiz), adicione uma linha indicando onde está a memória:

       # Memória do projeto
       Contexto completo em: ~/OpenCodeMemory/projetos/<nome-do-projeto>/contexto.md

A memória do projeto deve registrar: stack em uso, estrutura de diretórios relevante, decisões de arquitetura, integrações ativas, variáveis de ambiente necessárias e tarefas pendentes.

---

## Stack e Ambiente

- Ambiente: WSL Arch Linux + Windows 11
- Editor: VSCode com integração WSL
- Linguagem padrão: TypeScript — assuma TS em ambiguidade
- Runtime: Node.js
- Frameworks: React, Next.js, Vue.js
- Banco padrão em projeto novo sem contexto definido: pergunte antes de assumir
- Package manager: npm, pnpm
- Terminal Windows: PowerShell

Sempre priorize soluções cross-platform. Se a solução for exclusiva de uma plataforma, sinalize explicitamente.