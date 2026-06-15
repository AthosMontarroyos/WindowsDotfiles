#!/usr/bin/env bash

# ============================================================
#  ENABLE SERVICES — WSL (Docker, PostgreSQL)
#  Pode ser sourced ou executado diretamente
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    source "$SCRIPT_DIR/../lib/utils.sh"
fi

enable_services() {
    if command -v docker &>/dev/null; then
        log "Habilitando Docker..."
        sudo systemctl enable docker
        sudo usermod -aG docker "$USER"
        log "Docker habilitado. Reabra o terminal para o grupo surtir efeito."
    else
        warn "Docker nao encontrado — pulando."
    fi

    if command -v psql &>/dev/null; then
        log "Inicializando PostgreSQL..."
        if [[ ! -d /var/lib/postgres/data ]]; then
            sudo -u postgres initdb -D /var/lib/postgres/data
        else
            warn "PostgreSQL ja inicializado — pulando initdb."
        fi
        sudo systemctl enable --now postgresql
        log "PostgreSQL habilitado."
    else
        warn "PostgreSQL nao encontrado — pulando."
    fi

    log "Servicos configurados."
}

# Standalone execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    enable_services
fi