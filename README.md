# WindowsDotfiles

Dotfiles pessoais para Windows e Arch no WSL: Fish/Bash, Starship, PowerShell,
Fastfetch e OpenCode. Pacotes Linux exclusivamente dos repositorios oficiais.

## Estrutura

```text
Install/autounattend.xml   personalizacoes da instalacao do Windows
Windows/install.ps1       aplica o perfil PowerShell com backup
Windows/PowerShell/       perfil compartilhado entre hosts da edicao escolhida
WSL/bootstrap/archwsl.sh  prepara usuario, sudo e systemd em uma distribuicao nova
WSL/install.sh           entrada principal da instalacao Linux
WSL/lib/                 utilitarios e atualizacao de wsl.conf
WSL/modules/             pacotes, dotfiles e servicos opcionais
WSL/packages/            manifestos oficiais por finalidade
WSL/dots/                arquivos copiados para o home
docs/relatorio.md        auditoria, decisoes e limites de verificacao
tests/smoke.sh           verificacoes locais sem instalar pacotes
```

## Antes de formatar

Guarde este repositorio e seus arquivos pessoais fora do disco que sera formatado.
Exporte distribuicoes WSL que queira recuperar (`wsl --export <distribuicao> <arquivo.tar>`)
e confirme que o backup pode ser lido. Chaves SSH, credenciais, bancos e configuracoes
locais de assistentes nao fazem parte destes dotfiles.

`Install/autounattend.xml` e opcional: copie para a raiz da midia de instalacao.
O arquivo conserva as personalizacoes, remocoes de apps e bypasses de requisitos
do Windows do setup anterior. Revise-o e teste na ISO pretendida antes de formatar.
A criacao de conta/senha acontece no OOBE; nao ha conta ou autologon predefinidos.
Os scripts de primeiro login e sua lista de aplicativos foram preservados.
Falhas do WinGet sao registradas nos logs em `C:\Windows\Setup\Scripts`.
IDs e disponibilidade dos aplicativos dependem das fontes do WinGet no dia da instalacao.

## 1. Preparar ArchWSL

Instale WSL e uma distribuicao Arch. O projeto original usa
[ArchWSL](https://github.com/yuk7/ArchWSL). Verifique `wsl --list --verbose` no Windows.
Abra uma sessao root (`wsl -d <distribuicao> -u root`) e disponibilize uma copia deste
repositorio dentro dela. Da raiz do repositorio:

```bash
bash WSL/bootstrap/archwsl.sh --dry-run athos
bash WSL/bootstrap/archwsl.sh athos
```

Troque `athos` pelo seu usuario Linux. O bootstrap instala `sudo` e `git`, pede senha
somente ao criar uma conta nova, concede sudo com senha e ajusta as chaves `user/default`
e `boot/systemd` de `/etc/wsl.conf`, preservando as demais configuracoes.
Se detectar secoes duplicadas ou sudoers conflitante, pede correcao manual.
Nao redefine senha de conta existente. Se uma criacao for interrompida antes do `passwd`,
defina a senha da conta com `passwd <usuario>` antes de continuar.

No PowerShell, execute `wsl --shutdown` e reabra a distribuicao. Isso encerra todas
as distribuicoes em execucao; salve o trabalho antes. Systemd iniciara servicos ja
habilitados. A partir daqui, execute como usuario comum.

Se a copia veio do Windows/root, mantenha uma copia pertencente ao seu usuario em
`~/WindowsDotfiles`. Todos os comandos abaixo partem da raiz dela; o nome da pasta e livre.
Os scripts usam LF via `.gitattributes`; nao precisam de conversao `sed`.

## 2. Instalar pacotes e aplicar dotfiles

```bash
# Conferir sem modificar o sistema (tambem funciona no Git Bash)
bash WSL/install.sh --dry-run

# Shell, ferramentas diarias e OpenCode
bash WSL/install.sh

# Desenvolvimento Node/Python, ferramentas Git e Docker
bash WSL/install.sh --profile dev --with-containers
```

| Opcao | Conteudo / comportamento |
| --- | --- |
| `--profile core` | Padrao: Fish, Starship, Git/GitHub, CLI, Neovim, Fastfetch e OpenCode |
| `--profile dev` | Acrescenta base-devel, Node/npm/pnpm, Python/uv, SQLite e ferramentas Git |
| `--with-containers` | Docker/Compose/Buildx/Lazydocker; habilita e inicia Docker com systemd |
| `--with-postgres` | Instala somente PostgreSQL; nenhum initdb ou servico automatico |
| `--with-gpu` | Inclui containers e toolkit NVIDIA; configuracao do runtime e manual |
| `--with-fonts` | Fontes Linux/WSLg; nao altera a fonte do terminal Windows |
| `--with-toolchains` | Linguagens e ferramentas especializadas do setup antigo |
| `--keep-shell` | Aplica configuracoes sem mudar o shell de login para Fish |
| `--dry-run` | Mostra comandos e arquivos sem executar alteracoes |

O instalador faz uma transacao `pacman -Syu --needed` e mantem a confirmacao do Pacman.
Manifestos ausentes, selecao vazia, opcoes desconhecidas e nomes invalidos falham antes de instalar.
Pacotes retirados das listas **nao sao desinstalados** de maquinas existentes.
No setup novo, somente os perfis escolhidos sao instalados.

Docker utiliza `sudo docker`; nao se altera o grupo do usuario nem o socket.
Se voce usa Docker Desktop integrado ao WSL, omita `--with-containers` para evitar
instalar outro daemon. GPU depende de hardware e driver NVIDIA apropriados no Windows.
PostgreSQL e Rust precisam da inicializacao manual especifica do seu projeto.
Se um Arch muito antigo falhar por keyring, consulte o procedimento de recuperacao
do Arch antes de repetir; os scripts nao desabilitam verificacoes de assinatura.

## 3. Configuracoes e autenticacao

Dotfiles sao copiados arquivo a arquivo. Somente os destinos gerenciados sao alterados.
Arquivos diferentes existentes sao movidos para
`${XDG_STATE_HOME:-~/.local/state}/windows-dotfiles/backups/<data-id>/`, preservando
seu caminho relativo. Execucoes iguais nao criam novos backups.
Para restaurar, copie o arquivo correspondente do backup para seu caminho no home.
Nao ha remocao automatica de configuracoes antigas que deixaram de ser gerenciadas.

Git, GitHub, SSH e provedores de IA permanecem configuracoes pessoais:

```bash
git config --global user.name "Seu nome"
git config --global user.email "Seu email"
gh auth login
opencode
```

No OpenCode, use `/connect` para escolher seu provedor. O alias e `oc`.
OpenCode e instalado e atualizado pelo Pacman; nao ha instalador remoto, AUR,
configuracao de Harness, modelos, tokens ou MCPs predefinidos.
Seu futuro Harness pode ser configurado separadamente depois da formatacao.
O instalador nao remove instalacoes ou dados existentes de outros assistentes.

Fastfetch usa um logo Arch portavel. No Fish, `ff-random` usa uma das imagens
preservadas em `.config/fastfetch/logo`; a exibicao depende do suporte do terminal.
O comando nao edita o config nem apaga caches. `ff` usa o logo padrao.

## 4. Perfil Windows

Execute na edicao do PowerShell em que quer usar o perfil (5.1 ou 7):

```powershell
.\Windows\install.ps1 -WhatIf
.\Windows\install.ps1
```

O destino e `$PROFILE.CurrentUserAllHosts`; se ja existir, um backup fica ao lado.
O perfil so inicia Oh My Posh quando instalado. Se outro perfil do host ja inicializa
o prompt, revise essa sobreposicao manualmente. A fonte do Windows e configurada no
proprio terminal (JetBrains Mono Nerd Font permanece na lista de aplicativos).

## Verificar

```bash
bash tests/smoke.sh
```

Os testes usam diretorios temporarios e simulam comandos de pacotes/servicos.
Conferem sintaxe Bash, modo seco, argumentos, manifestos, backup/idempotencia e INI.
Se disponiveis, ShellCheck e `fish --no-execute` tambem rodam.
Eles nao substituem um teste de instalacao em ArchWSL nem um teste de OOBE em VM.
