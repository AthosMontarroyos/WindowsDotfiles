#!/usr/bin/env bash

# ============================================================
#  SETUP FISH — seta fish como shell padrão
#  Pode ser sourced ou executado diretamente
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    source "$SCRIPT_DIR/../lib/utils.sh"
fi

setup_fish() {
    if ! command -v fish &>/dev/null; then
        err "fish nao encontrado — instale antes de continuar."
    fi

    local fish_path
    fish_path="$(command -v fish)"

    if grep -qx "$fish_path" /etc/shells; then
        warn "fish ja esta em /etc/shells — pulando."
    else
        log "Adicionando fish ao /etc/shells..."
        echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
    fi

    if [[ "$SHELL" == "$fish_path" ]]; then
        warn "fish ja e o shell padrao — pulando."
    else
        log "Setando fish como shell padrao para $USER..."
        chsh -s "$fish_path"
        log "Shell alterado. Reabra o terminal para aplicar."
    fi

    log "Fish configurado."
}

# Standalone execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_fish
fi
