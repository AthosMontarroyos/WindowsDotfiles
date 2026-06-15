#!/usr/bin/env bash

# ============================================================
#  SETUP INICIAL — yay + base
#  Pode ser sourced ou executado diretamente
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    source "$SCRIPT_DIR/../lib/utils.sh"
fi

install_yay() {
    if command -v yay &>/dev/null; then
        log "yay ja instalado, pulando."
        return
    fi

    log "Instalando yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
    log "yay instalado com sucesso."
}

# Standalone execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_yay
fi
