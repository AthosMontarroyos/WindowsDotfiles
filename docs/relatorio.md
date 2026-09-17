# Relatorio de reorganizacao — 17/09/2026

## Resultado

Repositorio convertido em um conjunto de dotfiles com entrada unica para ArchWSL,
bootstrap separado e perfis opcionais. As alteracoes foram feitas no repositorio;
nenhum instalador de sistema, formatacao, login, criacao de conta ou servico foi
executado na maquina atual. O futuro Harness nao foi criado nem migrado nesta tarefa.

## Mudancas

- `WSL/install.sh`: valida argumentos, mostra `--dry-run`, carrega manifestos sem
  repeticoes e faz uma transacao completa `pacman -Syu --needed`. Mantem confirmacao.
- `WSL/bootstrap/archwsl.sh`: prepara uma distribuicao nova como root; instala os
  requisitos, valida usuario/sudoers e preserva outras chaves de `wsl.conf`.
- `WSL/modules/`: separa pacotes, arquivos pessoais e servicos; removidos os antigos
  modulos em `WSL/Config` e o bootstrap em `WSL/Install/Script`.
- `WSL/dots/`: substitui `WSL/Dots/home/user`. Copia arquivo a arquivo com backup
  dos destinos alterados; uma segunda execucao com conteudo igual nao cria backup.
- `.gitattributes`: LF explicito para scripts Linux, Fish, configuracoes e manifestos;
  CRLF para PowerShell/XML. Retirada a conversao de arquivos durante a instalacao.
- `.vscode/settings.json`: removido por conter apenas exclusoes genericas de editor.
- `Windows/install.ps1`: aplica o perfil para a edicao de PowerShell em uso, com
  `-WhatIf`, backup e comparacao de conteudo. Perfil movido para `Windows/PowerShell`.
- `README.md`: atualizado para os caminhos reais, perfis, preparacao para formatacao,
  recuperacao de backups e autenticacao pessoal.

## Pacotes

O perfil core tem 30 pacotes explicitamente declarados. Selecionando todos os
perfis, sao 70 nomes unicos; dependencias resolvidas pelo Pacman nao entram na conta.

| Acao | Pacotes / motivo |
| --- | --- |
| Remover AUR/yay | Nao ha pacote exclusivo do AUR necessario ao conjunto escolhido |
| Usar oficiais | lazygit, nvidia-container-toolkit e ttf-meslo-nerd |
| Remover sobreposicoes | htop (btop), tree (eza), ncdu (dust), wget (curl), nano (Neovim) |
| Retirar da lista explicita | gcc, pkgconf, which: dependencias de base-devel no perfil de desenvolvimento |
| Retirar sem consumidor nos dots | inetutils, bc, python-pip (fluxo Python com uv) |
| Atualizar nome | p7zip para 7zip |
| Adicionar | fastfetch (configuracao ja existia), opencode e sudo explicito no core |
| Tornar opcionais | containers, PostgreSQL, GPU, fontes Linux e toolchains especializados |

As listas controlam instalacoes novas. Nenhum pacote ja instalado e removido.
Fonts Linux ficaram opcionais porque o terminal Windows utiliza fontes do Windows.
As toolchains antigas continuam disponiveis juntas em `--with-toolchains`.

## OpenCode e configuracoes pessoais

Retirados instalador, chamadas e aliases do Codex. OpenCode vem do pacote oficial
Arch e usa o alias `oc` no Bash/Fish. Nao ha `curl | sh`, npm global ou AUR para ele.
As entradas `OpenAI.Codex` e `9PLM9XGG6VKS` foram retiradas do setup Windows.
Nenhum dado ou aplicativo do assistente instalado nesta maquina foi apagado.

Correcao do plano inicial: a pagina principal oficial documenta instalacao por
Pacman, e o catalogo Arch confirma `opencode`. A pagina v2 citada na auditoria
anterior descrevia outro conjunto de canais; ela nao orientou esta implementacao.

O logo Fastfetch fixo apontava para usuario e imagem ausentes. Agora usa o logo
Arch embutido; `ff-random` permite usar as duas imagens existentes sem editar config
ou excluir cache. Ambas as imagens foram preservadas. Fish protege a inicializacao
de ferramentas ausentes; Bash ganhou Starship e PATH sem duplicacao a cada source.
Foi retirado o limite de historico Fish sem suporte demonstrado e a escrita de
variavel universal em toda abertura do terminal.

## Seguranca e servicos

Hiro participou da revisao delimitada apos autorizacao explicita do usuario.

- Removidos login GitHub, geracao de chave sem senha, envio de chave e sobrescrita
  de `~/.ssh/config` do instalador. Configuracao/auth ficam manuais e documentadas.
- Bootstrap nao redefine senha do root ou de usuario existente. Usa regra sudo
  individual com senha, validada por visudo; recusa arquivo conflitante.
- `wsl.conf` tem backup quando muda; atualizacao preserva outras chaves e recusa
  secoes user/boot duplicadas. Systemd exige reiniciar WSL.
- Docker so inicia com opcao de containers/GPU; nao concede grupo docker.
- PostgreSQL e somente um pacote opt-in: sem initdb, inicio, mudanca de autenticacao
  ou acesso a dados. Nenhum banco real foi alterado.
- Retirados conta administrativa sem senha, autologon com credencial em texto claro
  e flags SkipUserOOBE/SkipMachineOOBE. Conta e senha serao escolhidas no OOBE.
  O segredo removido pode continuar no historico Git: troque-o onde tiver sido usado.
  O historico nao foi reescrito.

## Windows

Preservadas as escolhas locais anteriores (incluindo navegadores e Mullvad) e os
demais aplicativos, com excecao das entradas do assistente removido. Corrigido
`python3` para o ID especifico `Python.Python.3.14`. WinGet usa correspondencia exata
e registra retorno nao zero para facilitar tentativas manuais posteriores.

O XML ainda contem as personalizacoes e bypasses de requisitos herdados; esta tarefa
nao os revalidou para todas as versoes de Windows. Mudancas no OOBE precisam de teste
na ISO de destino. A lista inteira de aplicativos WinGet nao foi instalada ou
verificada online individualmente.

## Verificacoes e limites

- `bash -n`: scripts Bash e `.bashrc` aprovados no Git Bash disponivel.
- `tests/smoke.sh`: aprovado; verifica argumentos invalidos, root rejeitado no
  bootstrap, manifests sem duplicatas, uma transacao Pacman, dry-run sem sudo,
  copia/backup/reexecucao em home temporario, preservacao/idempotencia do INI e
  ausencia de comandos PostgreSQL. Docker e simulado, nao executado.
- XML e todos os scripts PowerShell embutidos: parsing aprovado.
- Scripts Windows: parsing e `Windows/install.ps1 -WhatIf` aprovados.
- Fastfetch: JSON parseavel, sem caminho absoluto pessoal.
- ShellCheck e interpretador Fish ausentes neste ambiente: essas verificacoes
  adicionais nao foram executadas; a suite as executa quando disponiveis.
- Catalogo Arch: consultas primarias confirmaram as mudancas relevantes
  (OpenCode, lazygit, toolkit NVIDIA, Meslo, Fastfetch, 7zip e base-devel).
  A tentativa automatizada dos 70 nomes confirmou 24; 46 consultas falharam por
  SSL/timeout. Isso nao significa pacote inexistente; o catalogo completo fica
  como verificacao pendente em um ambiente com conexao funcional.
- Nao houve instalacao em ArchWSL limpo ou teste Windows/OOBE em VM. A validacao
  local cobre comportamento dos scripts, nao garante uma instalacao completa.
- Sem commits ou push nesta tarefa; alteracoes disponiveis para revisao local.

## Fontes primarias

- [OpenCode: instalacao](https://opencode.ai/docs/)
- [OpenCode no Arch](https://archlinux.org/packages/extra/x86_64/opencode/)
- [Lazygit](https://archlinux.org/packages/extra/x86_64/lazygit/)
- [Toolkit NVIDIA](https://archlinux.org/packages/extra/x86_64/nvidia-container-toolkit/)
- [Meslo Nerd](https://archlinux.org/packages/extra/any/ttf-meslo-nerd/)
- [7zip](https://archlinux.org/packages/extra/x86_64/7zip/)
- [base-devel](https://archlinux.org/packages/core/any/base-devel/)
- [Configuracao WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)
- [OOBE](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/automate-oobe)
- [Configuracao Python da Microsoft](https://github.com/microsoft/WindowsDeveloperConfig/blob/main/windows-dev-config/dev-config.winget)
