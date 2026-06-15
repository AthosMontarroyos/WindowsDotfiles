#!/usr/bin/env bash

# Corrige CRLF em todos os scripts antes de qualquer execucao
sed -i 's/\r//' "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/../lib/utils.sh
find "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" -name "*.sh" -exec sed -i 's/\r//' {} +

# ... resto do script
# ============================================================
#  INSTALL MODULE — orquestrador principal
#  Pode ser sourced ou executado diretamente
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    source "$SCRIPT_DIR/../lib/utils.sh"
fi

# Source sub-modules
source "$SCRIPT_DIR/setup-initial.sh"
source "$SCRIPT_DIR/install-packages.sh"
source "$SCRIPT_DIR/apply-configs.sh"
source "$SCRIPT_DIR/services.sh"

run_install_module() {
    log "Iniciando modulo de instalacao — $(date)"

    # 1. yay (necessario antes de qualquer AUR)
    install_yay

    # 2. Pacotes base (pacman + AUR pessoal)
    install_official_packages
    install_aur_packages

    # 3.
    apply_dots

    # 4. Servicos
    enable_services

    log "Modulo de instalacao concluido."
}

# Standalone execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_install_module
fi
