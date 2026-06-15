#!/usr/bin/env bash

# ============================================================
#  APLICAR CONFIGURACOES — Sistema, SDDM, Dots pessoais
#  Tudo vem do repositorio — sem downloads externos
#  Pode ser sourced ou executado diretamente
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    source "$SCRIPT_DIR/../lib/utils.sh"
fi

# ----------------------------------------------------------
# DOTS PESSOAIS
# ----------------------------------------------------------
apply_personal_dots() {
    log "Aplicando configs pessoais..."

    local src_base="$DOTFILES_DIR/Dots/home/user"

    if [[ ! -d "$src_base" ]]; then
        warn "Dots/home/user nao encontrado — pulando configs pessoais."
        return
    fi

    if [[ -d "$src_base/.config" ]]; then
        log "Copiando .config..."
        mkdir -p "$HOME/.config"
        cp -rf "$src_base/.config/." "$HOME/.config/"
    fi

    if [[ -d "$src_base/.icons" ]]; then
        log "Copiando .icons..."
        mkdir -p "$HOME/.icons"
        cp -rf "$src_base/.icons/." "$HOME/.icons/"
    fi

    if [[ -d "$src_base/.local" ]]; then
        log "Copiando .local..."
        mkdir -p "$HOME/.local"
        cp -rf "$src_base/.local/." "$HOME/.local/"
    fi

    log "Configs pessoais aplicadas."
}

# Standalone execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    apply_personal_dots
fi
