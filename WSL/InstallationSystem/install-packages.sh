#!/usr/bin/env bash

# corrigir CRLF
sed -i 's/\r//' "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/../lib/utils.sh
find "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" -name "*.sh" -exec sed -i 's/\r//' {} +

# ============================================================
#  INSTALAR PACOTES — oficiais + AUR
#  Pode ser sourced ou executado diretamente
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    source "$SCRIPT_DIR/../lib/utils.sh"
fi

install_official_packages() {
    local pkg_file="$SCRIPT_DIR/../packages/packages.txt"

    if [[ ! -f "$pkg_file" ]]; then
        warn "packages.txt nao encontrado — pulando pacotes oficiais."
        return
    fi

    sed -i 's/\r//' "$pkg_file"

    log "Inicializando keyring..."
    sudo pacman-key --init
    sudo pacman-key --populate archlinux
    sudo pacman -Sy --noconfirm archlinux-keyring

    log "Atualizando sistema..."
    sudo pacman -Syu --noconfirm

    log "Instalando pacotes oficiais..."
    grep -v '^\s*#' "$pkg_file" | grep -v '^\s*$' | sed 's/#.*//' | tr -d ' \t' | grep -v '^\s*$' | \
        sudo pacman -S --needed --noconfirm -
}

install_aur_packages() {
    local aur_file="$SCRIPT_DIR/../packages/aur.txt"

    if [[ ! -f "$aur_file" ]]; then
        warn "aur.txt nao encontrado — pulando pacotes AUR."
        return
    fi

    sed -i 's/\r//' "$aur_file"

    if ! command -v yay &>/dev/null; then
        err "yay nao encontrado. Execute setup-initial.sh primeiro."
    fi

    log "Instalando pacotes AUR..."
    grep -v '^\s*#' "$aur_file" | grep -v '^\s*$' | sed 's/#.*//' | tr -d ' \t' | grep -v '^\s*$' | \
        xargs yay -S --needed --noconfirm
}

# Standalone execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_official_packages
    install_aur_packages
fi
