#!/usr/bin/env bash

# ============================================================
#  SETUP SHELL — fish como shell padrao
#  Pode ser sourced ou executado diretamente
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    source "$SCRIPT_DIR/../lib/utils.sh"
fi

set_default_shell() {
    local fish_path
    fish_path="$(which fish 2>/dev/null || true)"

    if [[ -z "$fish_path" ]]; then
        warn "fish nao encontrado — instala via packages.txt."
        return
    fi

    if [[ "$SHELL" != "$fish_path" ]]; then
        log "Definindo fish como shell padrao..."
        chsh -s "$fish_path"
    else
        log "fish ja e o shell padrao."
    fi
}

# Standalone execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set_default_shell
fi
