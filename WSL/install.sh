#!/usr/bin/env bash
set -euo pipefail

WSL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$WSL_DIR/lib/common.sh"
source "$WSL_DIR/modules/packages.sh"
source "$WSL_DIR/modules/dotfiles.sh"
source "$WSL_DIR/modules/services.sh"

usage() {
    printf '%s\n' \
        'Uso: bash WSL/install.sh [opcoes]' \
        '  --profile core|dev   core e o padrao; dev acrescenta Node/Python e ferramentas Git' \
        '  --with-containers    Docker, Compose, Buildx e Lazydocker; habilita Docker' \
        '  --with-postgres      Instala PostgreSQL; inicializacao fica manual' \
        '  --with-gpu           Toolkit NVIDIA (implica containers); configuracao manual' \
        '  --with-fonts         Fontes para aplicativos Linux/WSLg' \
        '  --with-toolchains    Demais linguagens, compiladores e bibliotecas cientificas' \
        '  --keep-shell         Mantem o shell de login atual' \
        '  --dry-run            Mostra o plano sem instalar ou modificar arquivos' \
        '  --help               Mostra esta ajuda'
}

DRY_RUN=0
PROFILE=core
KEEP_SHELL=0
CONTAINERS=0
POSTGRES=0
GPU=0
FONTS=0
TOOLCHAINS=0
while (($#)); do
    case "$1" in
        --profile)
            (($# >= 2)) || die '--profile precisa de core ou dev.'
            PROFILE="$2"; shift
            [[ "$PROFILE" = core || "$PROFILE" = dev ]] || die "Perfil desconhecido: $PROFILE"
            ;;
        --with-containers) CONTAINERS=1 ;;
        --with-postgres) POSTGRES=1 ;;
        --with-gpu) GPU=1; CONTAINERS=1 ;;
        --with-fonts) FONTS=1 ;;
        --with-toolchains) TOOLCHAINS=1 ;;
        --keep-shell) KEEP_SHELL=1 ;;
        --dry-run) DRY_RUN=1 ;;
        --help|-h) usage; exit 0 ;;
        *) die "Opcao desconhecida: $1" ;;
    esac
    shift
done

GROUPS_SELECTED=(core)
[[ "$PROFILE" != dev ]] || GROUPS_SELECTED+=(dev)
(( ! CONTAINERS )) || GROUPS_SELECTED+=(containers)
(( ! POSTGRES )) || GROUPS_SELECTED+=(database)
(( ! GPU )) || GROUPS_SELECTED+=(gpu)
(( ! FONTS )) || GROUPS_SELECTED+=(fonts)
(( ! TOOLCHAINS )) || GROUPS_SELECTED+=(toolchains)
load_packages
[[ -d "$WSL_DIR/dots" ]] || die 'Diretorio dots ausente.'
if (( ! DRY_RUN )); then
    require_arch
    (( EUID != 0 )) || die 'Execute com seu usuario comum, sem sudo; use bootstrap para preparar root.'
    command -v sudo >/dev/null || die 'Execute o bootstrap antes.'
    # Falhe antes de instalar/copiar caso o servico solicitado nao possa iniciar.
    if (( CONTAINERS )); then
        [[ -d /run/systemd/system ]] || die 'Docker requer systemd. Execute o bootstrap e reinicie o WSL.'
    fi
    sudo -v
fi
install_packages
apply_dotfiles
(( KEEP_SHELL )) || setup_fish
configure_services
log 'Concluido. Autentique o OpenCode com /connect ao abrir opencode (alias oc).'
log 'Git/GitHub: configure sua identidade e execute gh auth login quando desejar.'
